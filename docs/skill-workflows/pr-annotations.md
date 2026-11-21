# Pull request annotations

[Back to the code factory map](../skill-workflows.md) |
[Canonical skill source](../../skills/pr-annotations/SKILL.md)

This optional stage reduces the manual review burden after the factory has
produced a PR.

**Use it when:** a reviewer needs an explanation of the main behavior changes in
a large or generated PR.

**Result:** one comment-only review with an overview and a few inline notes.

```mermaid
flowchart TD
    A["Read PR state, revisions,<br/>reviews, and existing annotations"] --> B{"Eligible and changed<br/>at this head?"}
    B -->|No| C["Stop<br/>or link the existing annotation"]
    B -->|Yes| D{"Prior annotation<br/>for an update?"}
    D -->|Yes| E["Incremental mode<br/>compare PR-relative changes"]
    D -->|No| F["Full mode<br/>compare merge base to head"]
    E --> G["Select at most six<br/>behavioral production segments"]
    F --> G
    G --> H["Apply visual-explanations<br/>trace and consume the result"]
    H --> I["Classify concern<br/>and state stated or inferred why"]
    I --> J["Draft overview and inline notes"]
    J --> K{"Head still unchanged?"}
    K -->|No| L["Stop<br/>Do not post stale anchors"]
    K -->|Yes| M["Submit one<br/>comment-only review"]

    click H href "visual-explanations.md" "Open the visual-explanations workflow"
```

Annotations explain control flow, changed outcomes, and review focus. They do
not find defects, approve, block, or replace human review.

## Delegated trace flow

Segment tracing follows [Visual explanations](visual-explanations.md). This
page keeps the annotation eligibility, selection, concern, anchoring, and
submission flow; it does not repeat the delegated trace procedure.

## Synthetic example annotation

<details>
<summary>Open the synthetic pull request annotation</summary>

> [!NOTE]
> The code locations, intent quote, and behavior below are fictional.

**Case:** A billing ledger posts usage event `usage-731` and changes an account
balance from $100 to $40. A repeated or concurrent request must return the
original entry.

### Annotation

**1. Idempotent usage debit** - Concern: **High**: a missed uniqueness
guard can charge the same event more than once.

**Why:** Stated (synthetic plan): "A usage event must create at most one
ledger debit, even when the worker retries."

**Control flow** (before -> after)
```text
Before: load account -> append $60 debit
After:  find event key
        +-- exists -> return original entry
        +-- missing -> append under unique event key
                         +-- conflict -> reload original entry
```

| Input / state | Before | After |
| --- | --- | --- |
| Fresh `usage-731` | Append one $60 debit; balance becomes $40. | Same visible result, now inside an event-keyed transaction. |
| Duplicate `usage-731` | A second debit could reach $20. | Return the original entry; balance stays $40. |
| Two concurrent requests | Both may append. | One append wins; the other reloads the winning entry. |

**Review focus:** Confirm the unique key includes `account_id` and
`usage_event_id`, and confirm a transaction conflict cannot change the balance
before the original entry is reloaded.

<sub>Evidence: synthetic before and after; tests: concurrent post and duplicate
post (illustrative, not run)</sub>

This is an explanatory review, not an approval or defect verdict.

</details>
