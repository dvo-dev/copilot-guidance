# Surgical refactoring

[Back to the code factory map](../skill-workflows.md) |
[Canonical skill source](../../skills/surgical-refactoring/SKILL.md)

This skill runs during the local simplify pass when the factory needs a smaller
design before external review.

**Use it when:** duplicate logic, helpers, wrappers, or an API shape needs a
smaller design without a contract change.

**Result:** a behavior-preserving design, or a request for approval when policy
must change.

```mermaid
%%{init: {"theme":"base","themeVariables":{"background":"#1a1b26","primaryColor":"#24283b","primaryTextColor":"#c0caf5","primaryBorderColor":"#7aa2f7","secondaryColor":"#1f2335","secondaryTextColor":"#c0caf5","secondaryBorderColor":"#bb9af7","tertiaryColor":"#16161e","tertiaryTextColor":"#c0caf5","tertiaryBorderColor":"#7dcfff","lineColor":"#7dcfff","textColor":"#c0caf5","mainBkg":"#24283b","nodeBorder":"#7aa2f7","clusterBkg":"#16161e","clusterBorder":"#565f89","defaultLinkColor":"#7dcfff","edgeLabelBackground":"#1a1b26","titleColor":"#bb9af7","fontFamily":"ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, Liberation Mono, monospace"},"flowchart":{"curve":"basis","htmlLabels":true,"nodeSpacing":30,"rankSpacing":34,"padding":10}}}%%
flowchart TD
    A("Identify entry points,<br/>requested simplification, and authority") --> B("Establish required behavior")
    B --> C("Trace inputs, outputs,<br/>errors, and side effects")
    C --> D("Compare concrete<br/>small designs")
    D --> E{"Does a design preserve<br/>every contract?"}
    E -->|No| F(["Keep best preserving design<br/>or request approval"])
    E -->|Yes| AUTH{"Edits<br/>authorized?"}
    AUTH -->|No: analysis only| RETURN(["Return candidates,<br/>contracts, and validation limits"])
    AUTH -->|Yes| G("Apply smallest design")
    G --> H("Validate real entry points<br/>and forbidden work")
    H --> I("Remove obsolete code<br/>and keep surviving coverage")
    I --> J(["Report before and after,<br/>checks, and limits"])

    classDef stage fill:#24283b,stroke:#7aa2f7,stroke-width:1px,color:#c0caf5;
    classDef outcome fill:#1f2335,stroke:#9ece6a,stroke-width:1.5px,color:#c0caf5;
    classDef terminal fill:#16161e,stroke:#565f89,stroke-width:1px,color:#c0caf5;
    classDef decision fill:#16161e,stroke:#7dcfff,stroke-width:1.5px,color:#c0caf5;
    class A,B,C,D,G,H,I stage;
    class J,RETURN outcome;
    class F terminal;
    class E,AUTH decision;
```

The workflow prefers evidence over line counts or wrapper counts. It keeps
caller-specific behavior, error mapping, and side-effect boundaries.

## Synthetic example output

<details>
<summary>Open the synthetic refactoring recommendation</summary>

**Synthetic example:** This design recommendation and its code names are
fictional.

**Case:** In a billing ledger, invoice preview and a worker both calculate a $60 usage
charge. Only the worker may post the charge to the ledger. The two paths
duplicate amount calculation and ledger-entry construction.

**Chosen alternative**

```text
Before (each path duplicates calculation and entry construction):
preview -> inline charge math -> inline entry build -> return amount
worker  -> inline charge math -> inline entry build -> appendLedgerEntry()

After (existing calculator, one private builder, separate side effects):
preview -> charge calculator -> private entry builder -> return amount, no write
worker  -> charge calculator -> private entry builder -> appendLedgerEntry()
```

| Contract | Before | After |
| --- | --- | --- |
| Fresh event | Worker appends a $60 debit. | Same result through the existing ledger transaction. |
| Duplicate event | Worker returns the original entry. | Same result; the caller does not write twice. |
| Preview | Preview returns a calculated $60 amount. | Same result, with no ledger read cache or write side effect added. |
| Insufficient funds | Existing policy rejects the post. | Same policy remains at the worker boundary. |

**Why this design:** It reuses the existing calculator and
`appendLedgerEntry` transaction. It removes duplicate entry construction
without moving persistence into preview. A smaller-looking design is rejected
if it requires a public `preview` mode or changes either caller's policy.

**Validation limits:** Synthetic focused tests cover both entry points. A real
change would still verify the ledger transaction, unique event key, currency,
rounding boundary, and existing rollback behavior.

</details>
