# Refine agent guidance

[Back to the code factory map](../skill-workflows.md) |
[Canonical skill source](../../skills/refine-agent-guidance/SKILL.md)

This skill improves the factory itself after a repeated decision failure. It
keeps evaluation narrow and separates guidance quality from model or fixture
changes.

**Use it when:** a skill or instruction file repeatedly causes an observed
decision failure.

**Result:** a narrow guidance change with explicit evidence and limits.

```mermaid
%%{init: {"theme":"base","themeVariables":{"background":"#1a1b26","primaryColor":"#24283b","primaryTextColor":"#c0caf5","primaryBorderColor":"#7aa2f7","secondaryColor":"#1f2335","secondaryTextColor":"#c0caf5","secondaryBorderColor":"#bb9af7","tertiaryColor":"#16161e","tertiaryTextColor":"#c0caf5","tertiaryBorderColor":"#7dcfff","lineColor":"#7dcfff","textColor":"#c0caf5","mainBkg":"#24283b","nodeBorder":"#7aa2f7","clusterBkg":"#16161e","clusterBorder":"#565f89","defaultLinkColor":"#7dcfff","edgeLabelBackground":"#1a1b26","titleColor":"#bb9af7","fontFamily":"ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, Liberation Mono, monospace"},"flowchart":{"curve":"basis","htmlLabels":true}}}%%
flowchart TD
    A["Diagnose the observed<br/>decision failure"] --> B["Freeze task, revision,<br/>contracts, and stop criteria"]
    B --> C{"Is a trial authorized?"}
    C -->|No| D["Use source inspection<br/>or a tabletop evaluation"]
    C -->|Yes| E["Prepare isolated fixtures<br/>and verify guidance exposure"]
    E --> F["Run the same neutral task<br/>with fixed settings"]
    F --> G["Audit diffs, tests,<br/>and runtime evidence"]
    D --> H["Revise one missing<br/>decision or check"]
    G --> H
    H --> I["Check a contrasting case"]
    I --> J{"Acceptance met or<br/>further work needs policy?"}
    J -->|No| B
    J -->|Yes| K["Freeze artifact and report<br/>revision, evidence, and limits"]
```

Guidance authoring does not authorize agent trials, publication, or production
changes.

## Synthetic refinement handoff

<details>
<summary>Open the synthetic guidance-refinement handoff</summary>

> [!NOTE]
> The trial, observed failure, and guidance revision below are fictional.

**Observed problem in the synthetic billing ledger**

A repeated guidance pattern said, "Remove wrappers and share the smallest
common helper." In two isolated trials, that pattern moved
`appendLedgerEntry` into the shared invoice-preview path. Preview began to write
a $60 debit, although the contract said only the worker may persist it.

**Frozen evaluation contract**

- Invoice preview may calculate a $60 charge, but may not write or schedule
  work.
- The billing worker posts one debit for `usage-731`.
- A repeated event returns the original entry and keeps the balance at $40.
- A contrasting safe case may still consolidate code when both callers have
  the same persistence contract.

**Result**

| Revision | Outcome |
| --- | --- |
| Baseline guidance | Two trials consolidated the persistence boundary incorrectly. One produced a shared helper that could write from preview. |
| Candidate guidance | Both trials compared entry-point side effects before proposing consolidation. Both kept a pure calculation core and reused the existing ledger transaction only in the worker. |
| Contrasting case | The candidate still permitted consolidation when two caller paths had the same write contract. |

**Narrow guidance change**

Require a caller-by-caller side-effect table before recommending wrapper
removal. A helper may be shared only after each entry point's writes, external
calls, error mapping, and forbidden work are shown.

**Evidence limits**

- Synthetic tabletop and two-trial illustration; not a benchmark.
- No claim that this revision improves every task.
- Guidance was drafted, not published.
- The accepted contract and any production release still require separate
  human approval.

</details>
