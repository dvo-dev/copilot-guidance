# Visual explanations

[Back to the code factory map](../skill-workflows.md) |
[Canonical skill source](../../skills/visual-explanations/SKILL.md)

This skill supplies the compact diagrams, tables, and decisions that support
factory explanations and PR communication.

**Use it when:** one decision, call path, branch, or outcome comparison needs a
compact explanation.

**Result:** a verified conclusion with only the diagram or table that helps.

```mermaid
%%{init: {"theme":"base","themeVariables":{"background":"#1a1b26","primaryColor":"#24283b","primaryTextColor":"#c0caf5","primaryBorderColor":"#7aa2f7","secondaryColor":"#1f2335","secondaryTextColor":"#c0caf5","secondaryBorderColor":"#bb9af7","tertiaryColor":"#16161e","tertiaryTextColor":"#c0caf5","tertiaryBorderColor":"#7dcfff","lineColor":"#7dcfff","textColor":"#c0caf5","mainBkg":"#24283b","nodeBorder":"#7aa2f7","clusterBkg":"#16161e","clusterBorder":"#565f89","defaultLinkColor":"#7dcfff","edgeLabelBackground":"#1a1b26","titleColor":"#bb9af7","fontFamily":"ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, Liberation Mono, monospace"},"flowchart":{"curve":"basis","htmlLabels":true,"nodeSpacing":30,"rankSpacing":34,"padding":10}}}%%
flowchart TD
    A("Frame the exact<br/>decision or question") --> B{"Simple property<br/>or location?"}
    B -->|Yes| C(["Answer directly<br/>with a citation"])
    B -->|No| D("Trace real entry points,<br/>data, calls, and side effects")
    D --> E("Derive exact scenarios<br/>and material early exits")
    E --> F{"Best visual"}
    F -->|Relationships| G("Call graph")
    F -->|Branches| H("Decision tree")
    F -->|Input and result comparison| I("Outcome table")
    G --> J(["Present conclusion,<br/>evidence, and limit"])
    H --> J
    I --> J

    classDef stage fill:#24283b,stroke:#7aa2f7,stroke-width:1px,color:#c0caf5;
    classDef outcome fill:#1f2335,stroke:#9ece6a,stroke-width:1.5px,color:#c0caf5;
    classDef decision fill:#16161e,stroke:#7dcfff,stroke-width:1.5px,color:#c0caf5;
    class A,D,E,G,H,I stage;
    class C,J outcome;
    class B,F decision;
```

This skill is read-only unless another authorized task explicitly permits
implementation or posting.

For a pull request description, this skill owns the visual form only.
[Pull request descriptions](pr-descriptions.md) owns the summary order,
visible decisions, collapsed support, and posting boundary. Refer to that page
instead of duplicating the PR layout here.

## Synthetic example

<details>
<summary>Open the synthetic decision and outcome visual</summary>

**Synthetic example:** This billing ledger scenario is fictional. It
demonstrates the visual, not production behavior.

**Synthetic conclusion:** A duplicate event must return the original ledger
entry and perform no new write. The idempotency lookup and the unique event key
must protect the same write transaction.

```text
post(usage-731)
    |
    +-- entry exists -> return original entry
    |                   no write; balance stays $40
    |
    +-- no entry -> check policy
                      |
                      +-- rejected -> policy error
                      |               no write; balance stays $100
                      |
                      +-- allowed -> append $60 debit under unique event key
                                       |
                                       +-- conflict -> return winner's entry
                                       |               no second write; $40
                                       |
                                       +-- no conflict -> commit
                                                          balance $100 -> $40
```

| Input state | Result | New ledger write | Final balance |
| --- | --- | ---: | ---: |
| Fresh event, $100 balance | Charge $60 | 1 | $40 |
| Same event retried after success | Return original entry | 0 | $40 |
| Same event posted concurrently twice | One charge; losing request reloads it | 1 total | $40 |
| Invoice preview | Return calculated amount | 0 | $100 |
| Existing policy rejects insufficient funds | Return policy error | 0 | $100 |

The graph shows control flow. The table shows the observable outcomes. Neither
states that the behavior exists until source and tests verify it.

</details>
