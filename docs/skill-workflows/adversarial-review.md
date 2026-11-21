# Adversarial review

[Back to the code factory map](../skill-workflows.md) |
[Canonical skill source](../../skills/adversarial-review/SKILL.md)

This skill supplies independent review at the plan, local-change, and
Copilot-finding stages of the factory.

**Use it when:** a change, plan, question, or external findings need an
independent second opinion.

**Result:** verified finding dispositions: fix, reject, defer, or escalate.

```mermaid
%%{init: {"theme":"base","themeVariables":{"background":"#1a1b26","primaryColor":"#24283b","primaryTextColor":"#c0caf5","primaryBorderColor":"#7aa2f7","secondaryColor":"#1f2335","secondaryTextColor":"#c0caf5","secondaryBorderColor":"#bb9af7","tertiaryColor":"#16161e","tertiaryTextColor":"#c0caf5","tertiaryBorderColor":"#7dcfff","lineColor":"#7dcfff","textColor":"#c0caf5","mainBkg":"#24283b","nodeBorder":"#7aa2f7","clusterBkg":"#16161e","clusterBorder":"#565f89","defaultLinkColor":"#7dcfff","edgeLabelBackground":"#1a1b26","titleColor":"#bb9af7","fontFamily":"ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, Liberation Mono, monospace"},"flowchart":{"curve":"basis","htmlLabels":true,"nodeSpacing":30,"rankSpacing":34,"padding":10}}}%%
flowchart TD
    A("Resolve mode, target,<br/>intent, and reviewer effort") --> B("Freeze one identical<br/>review packet")
    B --> C{{"Anthropic reviewer<br/>read-only and isolated"}}
    B --> D{{"OpenAI reviewer<br/>read-only and isolated"}}
    C --> F{"Repository state<br/>unchanged?"}
    D --> F
    F -->|No: first drift| B
    F -->|No: second drift| T(["Stop<br/>discard round"])
    F -->|Yes| E("Save both raw results")
    E --> G("Cluster duplicate findings")
    G --> H("Verify each trigger<br/>and cited contract")
    H --> I{"Reject a high-impact<br/>or agreed finding?"}
    I -->|Yes| J{{"Run a fresh validator"}}
    J --> K("Classify each cluster")
    I -->|No| K
    K --> L("Record fix, reject,<br/>defer, or escalate")
    L --> M(["Return compact report<br/>and artifact paths"])

    classDef stage fill:#24283b,stroke:#7aa2f7,stroke-width:1px,color:#c0caf5;
    classDef delegated fill:#1f2335,stroke:#bb9af7,stroke-width:1.5px,color:#c0caf5;
    classDef human fill:#1f2335,stroke:#9ece6a,stroke-width:1.5px,color:#c0caf5;
    classDef terminal fill:#16161e,stroke:#565f89,stroke-width:1px,color:#c0caf5;
    classDef decision fill:#16161e,stroke:#7dcfff,stroke-width:1.5px,color:#c0caf5;
    class A,B,E,G,H,K,L stage;
    class C,D,J delegated;
    class M human;
    class T terminal;
    class F,I decision;
```

If both reviewer slots fail after retry, the round is a review failure, not a
clean review. Reviewer output is treated as a hypothesis until the parent
verifies it.

## Synthetic example output

<details>
<summary>Open the synthetic adversarial-review report</summary>

**Synthetic example:** This report is fictional. It shows the shape of the
review output, not repository evidence.

**Case:** A draft change posts a $60 usage charge to a billing ledger. A retry
with the same usage event ID must return the original ledger entry and leave the
balance unchanged at $40 from an opening balance of $100.

**Compact review report**

- **Mode:** `change`
- **Target:** `base...head` at synthetic SHA `abc1234`
- **Reviewers:** Claude Opus, xhigh; GPT-6.2 Astra, xhigh
- **Verdicts:** Slot A found one blocking issue; Slot B found the same issue
  and one scope question.

| ID | Finding | Verification | Disposition |
| --- | --- | --- | --- |
| R1.1 | Two concurrent requests can both read "not posted" and append a $60 debit. | A synthetic two-transaction reproduction creates two entries for one event ID. The insert has no unique-key protection. | **fix** — P1 |
| R1.2 | A $10.005 charge can round to a different cent total in preview and final posting. | Both paths call the same calculator, but the plan does not define the rounding rule. | **escalate** — needs a product decision |
| R1.3 | Cache the account balance to reduce reads. | Caching can improve throughput later, but the current defect and approved scope do not require it. | **defer** — follow up after load evidence |

**Human decision:** Which rounding rule must turn a fractional cent into a
ledger amount? The synthetic change must not choose a billing policy silently.

</details>
