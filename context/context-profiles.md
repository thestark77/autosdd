# Context Profiles

> Defines which context sources are relevant for each task type.
> The Context Scout uses these profiles to filter before passing context to the orchestrator.
> Customize for your project's domain.

## frontend
always:
  - context/guidelines.md (design, UI conventions)
  - context/user_context.md
never:
  - context/business_logic.md (accounting, finance, backend internals)
maybe:
  - context/business_logic.md (domain entities, user-facing data models)

## backend-api
always:
  - context/guidelines.md (API conventions, error handling)
  - context/business_logic.md (domain rules, validation)
never:
  - brand references, visual style guides
maybe:
  - context/guidelines.md (database naming if touching data layer)

## database
always:
  - context/business_logic.md (data model, entity relationships)
  - context/guidelines.md (naming conventions, migration rules)
never:
  - frontend style guides, brand references, UI conventions
maybe:
  - context/business_logic.md (API contracts if schema change affects endpoints)

## testing
always:
  - context/guidelines.md (testing conventions)
  - context/business_logic.md (expected behaviors, edge cases)
never:
  - brand references, visual style guides
maybe:
  - context/user_context.md (if testing user-facing flows)

## architecture
always:
  - ALL context files (this is where full context justifies its cost)
never:
  - (nothing excluded — architecture needs the full picture)

## devops
always:
  - context/guidelines.md (deployment, CI/CD conventions)
never:
  - context/business_logic.md (domain details)
  - brand references, visual style guides
maybe:
  - context/guidelines.md (environment-specific configs)

## documentation
always:
  - context/business_logic.md (domain terminology)
  - context/user_context.md
never:
  - (nothing excluded — docs may reference anything)

## general
always:
  - context/user_context.md
maybe:
  - context/guidelines.md (scan headers for relevance)
  - context/business_logic.md (scan headers for relevance)
