# Pull request descriptions

[Back to the code factory map](../skill-workflows.md) |
[Canonical skill source](../../skills/pr-descriptions/SKILL.md)

This skill turns factory evidence into a PR body that a person can scan before
making the final decision.

**Use it when:** a PR body must be written or restructured.

**Result:** a scannable description with visible decisions and collapsed
supporting detail.

```mermaid
%%{init: {"theme":"base","themeVariables":{"background":"#1a1b26","primaryColor":"#24283b","primaryTextColor":"#c0caf5","primaryBorderColor":"#7aa2f7","secondaryColor":"#1f2335","secondaryTextColor":"#c0caf5","secondaryBorderColor":"#bb9af7","tertiaryColor":"#16161e","tertiaryTextColor":"#c0caf5","tertiaryBorderColor":"#7dcfff","lineColor":"#7dcfff","textColor":"#c0caf5","mainBkg":"#24283b","nodeBorder":"#7aa2f7","clusterBkg":"#16161e","clusterBorder":"#565f89","defaultLinkColor":"#7dcfff","edgeLabelBackground":"#1a1b26","titleColor":"#bb9af7","fontFamily":"ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, Liberation Mono, monospace"},"flowchart":{"curve":"basis","htmlLabels":true}}}%%
flowchart TD
    A["Read diff, intent,<br/>facts, and repository template"] --> B["Invoke <a href='https://github.com/dvo-dev/copilot-guidance/blob/dvo-dev-document-dev-flows/docs/skill-workflows/visual-explanations.md'>visual-explanations</a><br/>and consume the result"]
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
%%{init: {"theme":"base","themeVariables":{"background":"#1a1b26","primaryColor":"#24283b","primaryTextColor":"#c0caf5","primaryBorderColor":"#7aa2f7","secondaryColor":"#1f2335","secondaryTextColor":"#c0caf5","secondaryBorderColor":"#bb9af7","tertiaryColor":"#16161e","tertiaryTextColor":"#c0caf5","tertiaryBorderColor":"#7dcfff","lineColor":"#7dcfff","textColor":"#c0caf5","mainBkg":"#24283b","nodeBorder":"#7aa2f7","clusterBkg":"#16161e","clusterBorder":"#565f89","defaultLinkColor":"#7dcfff","edgeLabelBackground":"#1a1b26","titleColor":"#bb9af7","fontFamily":"ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, Liberation Mono, monospace"},"flowchart":{"curve":"basis","htmlLabels":true}}}%%
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
