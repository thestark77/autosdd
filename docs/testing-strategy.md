# Testing Strategy

AutoSDD enforces strict Test-Driven Development. No code ships without a failing test first. This document covers the full strategy across all three testing layers.

## The TDD Mandate

```
RED    — Write a failing test that defines the expected behavior
GREEN  — Write the minimum code needed to make the test pass
REFACTOR — Clean up without breaking the tests
```

This is not a suggestion. If an agent writes implementation code before a failing test, it violates the quality gate and must redo the work.

---

## Layer 1 — Vitest (Unit and Integration)

### Purpose

Fast, deterministic tests for all backend logic and data access. This is the primary feedback loop during development.

### What to Test

| Category | Examples |
|----------|---------|
| Multi-tenant isolation | Tenant A NEVER sees Tenant B data |
| Prisma extensions | Soft deletes auto-filter, tenant scoping correct |
| Auth logic | JWT creation, validation, expiration, role checks |
| Zod schemas | Valid input accepted, invalid input rejected with correct error codes |
| Financial logic | Transaction totals, reconciliation, balance calculations |
| API routes | Full request → response against real test database |
| Response helpers | `response()` always returns consistent structure |
| Request helpers | `postRequest()` injects device metadata |

### Critical Configuration

#### `pool: 'forks'` — MANDATORY for AsyncLocalStorage

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    pool: 'forks',  // NEVER use 'threads' with AsyncLocalStorage
    poolOptions: {
      forks: {
        singleFork: false,
      },
    },
  },
});
```

The default `threads` pool shares memory between tests, which breaks `AsyncLocalStorage`-based tenant context. This causes random test failures that are extremely hard to debug. Always use `forks`.

#### Env Loading Order — MANDATORY

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    envFile: '.env.test',         // Loads BEFORE module imports
    setupFiles: ['./src/__tests__/setup.ts'],
  },
});
```

If env variables are loaded after module imports, strict env validation (e.g. `process.exit(1)` on missing vars) fires at import time. The `envFile` option in Vitest config prevents this.

#### Real Database — Never Mock Prisma

```typescript
// WRONG — mocking Prisma hides real bugs
vi.mock('@/lib/prisma');

// CORRECT — use a real test database
// DATABASE_URL_TEST points to a separate test PostgreSQL database
```

Mocking Prisma means you test your mock behavior, not your actual database queries. All integration tests run against a real PostgreSQL database at `DATABASE_URL_TEST`.

### Test Isolation Pattern

Each test file is responsible for its own data:

```typescript
// src/__tests__/api/animals.test.ts
describe('Animals API', () => {
  let testTenant: Tenant;
  let testUser: User;

  beforeEach(async () => {
    // Seed fresh data for each test
    testTenant = await createTestTenant();
    testUser = await createTestUser({ tenantId: testTenant.id });
  });

  afterEach(async () => {
    // Clean up — order matters for FK constraints
    await prisma.user.deleteMany({ where: { tenantId: testTenant.id } });
    await prisma.tenant.delete({ where: { id: testTenant.id } });
  });
});
```

### Tenant Isolation Test Pattern

```typescript
it('should not expose Tenant A data to Tenant B', async () => {
  const tenantA = await createTestTenant({ slug: 'tenant-a' });
  const tenantB = await createTestTenant({ slug: 'tenant-b' });
  
  // Create data scoped to Tenant A
  await createAnimalForTenant(tenantA.id);

  // Query with Tenant B context
  const result = await getAnimalsInTenantContext(tenantB.id);
  
  expect(result).toHaveLength(0);
  
  // Cleanup
  await cleanupTenant(tenantA.id);
  await cleanupTenant(tenantB.id);
});
```

### Running Vitest

```bash
rtk vitest run                         # All tests
rtk vitest run src/__tests__/api/      # Specific directory
rtk vitest run --reporter=verbose      # Detailed output
```

---

## Layer 2 — Playwright (E2E)

### Purpose

Verify complete user flows from browser perspective. Tests what users actually experience.

### What to Test

| Flow | Test File |
|------|-----------|
| Login → dashboard | `auth.spec.ts` |
| Role-based access | `auth.spec.ts` |
| Tenant subdomain routing | `tenant-isolation.spec.ts` |
| Suspended tenant read-only | `tenant-isolation.spec.ts` |
| Form validation (error messages) | per-feature spec files |
| Mobile responsiveness | per-feature spec files with viewport |
| Landing page CMS | `landing-cms.spec.ts` |

### MCP-Driven Verification

During the verify phase, agents use Playwright MCP tools directly:

```
browser_navigate   — Navigate to pages
browser_snapshot   — Capture accessibility snapshot
browser_fill_form  — Fill and submit forms
browser_click      — Click elements
browser_take_screenshot — Visual capture
```

This allows agents to verify flows without writing spec files — useful for one-shot verification during development.

### Spec File Pattern

```typescript
// e2e/auth.spec.ts
import { test, expect } from '@playwright/test';
import { seedTestTenant, cleanupTestTenant } from './fixtures/tenant.fixture';

test.describe('Authentication', () => {
  let tenantSlug: string;

  test.beforeAll(async () => {
    tenantSlug = await seedTestTenant();
  });

  test.afterAll(async () => {
    await cleanupTestTenant(tenantSlug);
  });

  test('admin can log in and see dashboard', async ({ page }) => {
    await page.goto(`http://${tenantSlug}.localhost:3000/login`);
    await page.fill('[name=email]', 'admin@test.com');
    await page.fill('[name=password]', 'testpassword');
    await page.click('[type=submit]');
    
    await expect(page).toHaveURL(/dashboard/);
    await expect(page.locator('h1')).toContainText('Dashboard');
  });

  test('volunteer cannot access admin panel', async ({ page }) => {
    // Login as volunteer...
    await page.goto(`http://${tenantSlug}.localhost:3000/admin`);
    await expect(page).toHaveURL(/forbidden/);
  });
});
```

### Mobile Testing

```typescript
test('dashboard is usable on mobile', async ({ browser }) => {
  const context = await browser.newContext({
    viewport: { width: 390, height: 844 }, // iPhone 14
  });
  const page = await context.newPage();
  // Test mobile layout...
});
```

### Running Playwright

```bash
rtk playwright test                    # All E2E tests
rtk playwright test e2e/auth.spec.ts   # Specific file
rtk playwright test --ui               # Visual UI mode
rtk playwright test --headed           # See browser
```

---

## Layer 3 — When to Use Each

| Scenario | Vitest | Playwright |
|----------|--------|------------|
| New API endpoint | ✅ | ❌ |
| New UI component | ❌ | ✅ |
| Business logic change | ✅ | ✅ if user-facing |
| Bug fix | ✅ regression | ✅ if UI-related |
| Prisma schema change | ✅ | ❌ |
| Auth/permission change | ✅ | ✅ |
| Refactor | ✅ existing pass | ✅ existing pass |

---

## Redis in Tests

Use `ioredis-mock` to avoid needing a running Redis instance:

```typescript
// src/__tests__/setup.ts
import RedisMock from 'ioredis-mock';
vi.mock('ioredis', () => ({ default: RedisMock }));
```

---

## Quality Gate Commands

```bash
pnpm validate        # lint + typecheck + unit/integration
pnpm validate:full   # + E2E
```

Every change must pass `pnpm validate` before pushing. The pre-push hook enforces this — it cannot be bypassed.
