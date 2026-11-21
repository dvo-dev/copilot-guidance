# Plan walkthrough and quiz

[Back to the code factory map](../skill-workflows.md) |
[Canonical skill source](../../skills/plan-walkthrough-quiz/SKILL.md)

This skill closes the plan-understanding gap before the approved plan enters
the factory.

**Use it when:** the user needs to understand a plan before approval.

**Result:** a code-verified teaching sequence and a recap table in the plan.

> [!WARNING]
> Mermaid links in this diagram are pinned to `main` because GitHub cannot
> resolve document-relative node links inside its Mermaid iframe. A new target
> can return 404 before merge; use the relative Markdown links below the
> diagram for same-ref navigation.

```mermaid
%%{init: {"theme":"base","themeVariables":{"background":"#1a1b26","primaryColor":"#24283b","primaryTextColor":"#c0caf5","primaryBorderColor":"#7aa2f7","secondaryColor":"#1f2335","secondaryTextColor":"#c0caf5","secondaryBorderColor":"#bb9af7","tertiaryColor":"#16161e","tertiaryTextColor":"#c0caf5","tertiaryBorderColor":"#7dcfff","lineColor":"#7dcfff","textColor":"#c0caf5","mainBkg":"#24283b","nodeBorder":"#7aa2f7","clusterBkg":"#16161e","clusterBorder":"#565f89","defaultLinkColor":"#7dcfff","edgeLabelBackground":"#1a1b26","titleColor":"#bb9af7","fontFamily":"ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, Liberation Mono, monospace"},"flowchart":{"curve":"basis","htmlLabels":true,"nodeSpacing":30,"rankSpacing":34,"padding":10}}}%%
flowchart TD
    A("Locate the plan<br/>and current code revision") --> B("Verify claims<br/>and label C, P, or D")
    B --> C("Teach ELI5 goal<br/>milestones, analogy, and persona")
    C --> D("Walk through<br/>each implementation task")
    D --> V{"Diagram needed?"}
    V -->|Yes| X{{"Invoke <a href='https://github.com/dvo-dev/copilot-guidance/blob/main/docs/skill-workflows/visual-explanations.md'>visual-explanations</a><br/>for this task"}}
    X --> E("Ask one scenario question")
    V -->|No| E
    E --> F{"Correct?"}
    F -->|No| G("Explain miss<br/>using the same analogy")
    G --> H("Update recap table")
    H --> E
    F -->|Yes| I("Update recap table<br/>and score the round")
    I --> J{"Ready for approval?"}
    J -->|Need another layer| D
    J -->|Yes| K(["Request plan approval"])

    classDef stage fill:#24283b,stroke:#7aa2f7,stroke-width:1px,color:#c0caf5;
    classDef delegated fill:#1f2335,stroke:#bb9af7,stroke-width:1.5px,color:#c0caf5;
    classDef outcome fill:#1f2335,stroke:#9ece6a,stroke-width:1.5px,color:#c0caf5;
    classDef decision fill:#16161e,stroke:#7dcfff,stroke-width:1.5px,color:#c0caf5;
    class A,B,C,D,E,G,H,I stage;
    class X delegated;
    class K outcome;
    class V,F,J decision;

```

The workflow can update the plan or session artifact. It does not change code,
push, or assume approval.

When a task walkthrough needs a diagram, it follows
[Visual explanations](visual-explanations.md) rather than duplicating that
flow here.

## Synthetic teaching excerpt

<details>
<summary>Open the synthetic plan walkthrough and quiz</summary>

**Synthetic example:** This plan, code names, and quiz are fictional.

**Goal**

Post each usage event to the billing ledger once, even when a worker retries or
two workers receive the same event. A $60 charge moves an account from $100 to
$40 and never to -$20 for a duplicate delivery.

**One analogy**

Treat the usage event ID like a stamped receipt number. The first cashier
stamps the receipt and records the debit. A later cashier with the same receipt
number returns the original record instead of charging the account again.

| Piece | Problem it solves | What breaks without it |
| --- | --- | --- |
| Event key | Identifies a retried event. | The same charge looks new. |
| Unique ledger constraint | Lets the transaction reject a concurrent duplicate. | Two workers can both debit. |
| Conflict reload | Converts the losing request into a retry result. | The losing worker sees an unexplained database error. |
| Preview boundary | Keeps invoice preview read-only. | A preview can move money. |

**Persona story**

Account `acct-9` has $100 available. Event `usage-731` charges $60. The first
request appends one entry and leaves $40. The worker retries after it loses the
response. The second request finds the same entry, returns it, and makes no
new debit.

**One-question quiz**

> Two workers process `usage-731` at the same time. Worker A and Worker B both
> finish their first lookup before either commits. What must happen?

The correct answer is: one transaction commits the uniquely keyed entry; the
other receives a conflict, reloads that entry, and returns it without a second
debit. Both callers can receive a successful result, but only one write
reaches the ledger.

| # | Question | Canonical answer |
| --- | --- | --- |
| 1 | Two workers post the same event concurrently | One unique entry commits; the loser reloads it; the balance changes once. |

</details>
