# [Project Name] — Business Logic & Domain Knowledge

> **Purpose**: Persistent record of ALL business domain knowledge. Updated continuously. Preserves the "essence" — terminology, rules, workflows, and constraints that code alone doesn't capture.

---

## What Is [Project Name]?

[Description of the product/service — what problem does it solve, who uses it, what does it do at its core]

---

## Target Market

- **Primary market**: [Country/region or global]
- **Default currency**: [e.g. USD, EUR, ARS]
- **Default language**: [e.g. Spanish (neutral), English]

---

## User Roles & Permissions

| Role | Level | Access |
|------|-------|--------|
| [Role 1] | [e.g. Admin] | [What they can do] |
| [Role 2] | [e.g. Operator] | [What they can do] |
| [Role 3] | [e.g. Viewer] | [What they can do] |

---

## Core Business Entities

### [Entity 1]

- **Description**: [What this entity represents]
- **Key fields**: [Most important attributes]
- **Rules**:
  - [Business rule 1]
  - [Business rule 2]
- **Constraints**:
  - [Non-obvious constraints that affect implementation]

### [Entity 2]

- **Description**:
- **Key fields**:
- **Rules**:
- **Constraints**:

---

## Business Workflows

### [Workflow 1 — e.g. Onboarding]

```
STATE_A → [trigger] → STATE_B → [trigger] → STATE_C
                                    ↓
                              [error case] → STATE_ERROR
```

**States**: [List all possible states]
**Transitions**:
- `STATE_A → STATE_B`: [What triggers this, who can trigger it, what happens]
- `STATE_B → STATE_C`: [What triggers this, preconditions, side effects]

### [Workflow 2 — e.g. Payment Processing]

[Document state machines, lifecycle flows, approval chains]

---

## Industry Terminology

| Term | Definition |
|------|-----------|
| [Term 1] | [Plain language definition as used in THIS project] |
| [Term 2] | [Plain language definition] |
| [Term 3] | [Plain language definition] |

---

## Unique Business Rules & Constraints

> Non-obvious rules that directly affect implementation decisions.

1. **[Rule name]**: [What the rule is and why it exists]
2. **[Rule name]**: [What the rule is and why it exists]
3. **[Rule name]**: [Edge cases, exceptions, enforcement mechanism]

---

## Pricing & Financial Logic

[If applicable — billing cycles, trial periods, discount rules, tax handling, currency conversion]

---

## Regulatory & Compliance Requirements

[If applicable — data residency, GDPR, industry-specific regulations, audit requirements]

---

## Integration Points

| System | Purpose | Direction |
|--------|---------|-----------|
| [System 1] | [What data flows] | [Inbound / Outbound / Both] |
| [System 2] | [What data flows] | [Inbound / Outbound / Both] |

---

*Last updated: [date]*
