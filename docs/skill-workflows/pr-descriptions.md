# Pull request descriptions

[Back to the code factory map](../skill-workflows.md) |
[Canonical skill source](../../skills/pr-descriptions/SKILL.md)

This skill turns factory evidence into a PR body that a person can scan before
making the final decision.

**Use it when:** a PR body must be written or restructured.

**Result:** a scannable description with visible decisions and collapsed
supporting detail.

```mermaid
flowchart TD
    A["Read diff, intent,<br/>facts, and repository template"] --> B["Invoke visual-explanations<br/>and consume the result"]
    B --> C["Write effect-focused summary"]
    C --> D["Add one main flow diagram"]
    D --> E["Add business cases<br/>when inputs differ"]
    E --> F["List what changed and why"]
    F --> G["Show open decisions<br/>and required steps"]
    G --> H["Collapse supporting evidence<br/>and decisions already made"]
    H --> I{"Named person<br/>must answer?"}
    I -->|Yes| J["Draft one PR comment<br/>for that question"]
    I -->|No| K["Return description"]
    J --> K

    click B href "visual-explanations.md" "Open the visual-explanations workflow"
```

Writing a description does not authorize posting it. `copilot-review-loop`
supplies the PR facts and the hidden marker; this skill decides where they go.

## Delegated visual flow

[`visual-explanations`](visual-explanations.md) owns the diagram, table, and
alert decisions. This skill owns only the PR layout and visibility rules, so it
does not redraw that flow here.

## Synthetic example output

<details>
<summary>Open the synthetic pull request body</summary>

> [!NOTE]
> The PR body below is fictional and demonstrates structure only.

The billing ledger now posts one $60 debit for each usage event. Repeated or
concurrent delivery of the same event ID returns the original entry without a
second balance change.

```mermaid
flowchart LR
    EVENT["Usage event: usage-731"] --> FOUND{"Ledger entry exists?"}
    FOUND -->|Yes| RETURN["Return original $60 entry"]
    FOUND -->|No| VALIDATE["Calculate and validate charge"]
    VALIDATE --> POST["Append debit in ledger transaction"]
    POST --> BALANCE["Balance: $100 -> $40"]
```

### What changed and why

- `UsageChargeWorker` reuses the existing charge calculator and ledger
  transaction.
- A unique `(account_id, usage_event_id)` key protects concurrent retries.
- Invoice preview returns the calculated amount without posting it.
- A duplicate event returns the original entry and keeps the balance at $40.

### Needs human judgment

| Decision | Why it matters | Current PR behavior |
| --- | --- | --- |
| Fractional-cent rounding | Different rules can change the invoice total. | Keep the existing calculator pending a policy decision. |
| Negative balances | It changes credit and collections behavior. | Reject the post under the existing rule. |

### Testing

- Unit: fresh post, duplicate event, concurrent retry, and preview
- Local: format, lint, type check, full unit suite
- PR: Copilot review and CI completed

In a real PR, longer evidence, accepted decisions, and test output would move
into named collapsed sections. Questions for a named person would go in a PR
comment, not the body.

</details>
