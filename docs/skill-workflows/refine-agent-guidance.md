# Refine agent guidance

[Back to the code factory map](../skill-workflows.md) |
[Canonical skill source](../../skills/refine-agent-guidance/SKILL.md)

This skill improves the factory itself after a repeated decision failure. It
keeps evaluation narrow and separates guidance quality from model or fixture
changes.

**Use it when:** a skill or instruction file repeatedly causes an observed
decision failure.

**Result:** a narrow guidance change with explicit evidence and limits.

The coordinator first freezes two points. Point A is the start state: the
pinned task, source revision, and setup. Point B is the target: the acceptance
criteria and the forbidden side effects. When a trial is authorized, the
coordinator gives the candidate guidance to new, isolated trial agents. Each
agent starts at point A and works toward point B. The trial checks whether a
fresh agent with the candidate guidance reaches point B without help from the
coordinator.

> [!IMPORTANT]
> Trial agents are black boxes. Each agent gets only the point A fixture, the
> candidate guidance, and a neutral task brief. The coordinator judges its
> diffs, tests, and runtime evidence, not its own report.

```mermaid
%%{init: {"theme":"base","themeVariables":{"background":"#1a1b26","primaryColor":"#24283b","primaryTextColor":"#c0caf5","primaryBorderColor":"#7aa2f7","secondaryColor":"#1f2335","secondaryTextColor":"#c0caf5","secondaryBorderColor":"#bb9af7","tertiaryColor":"#16161e","tertiaryTextColor":"#c0caf5","tertiaryBorderColor":"#7dcfff","lineColor":"#7dcfff","textColor":"#c0caf5","mainBkg":"#24283b","nodeBorder":"#7aa2f7","clusterBkg":"#16161e","clusterBorder":"#565f89","defaultLinkColor":"#7dcfff","edgeLabelBackground":"#1a1b26","titleColor":"#bb9af7","fontFamily":"ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, Liberation Mono, monospace"},"flowchart":{"curve":"basis","htmlLabels":true,"nodeSpacing":30,"rankSpacing":34,"padding":10}}}%%
flowchart TD
    A("Diagnose the observed<br/>decision failure") --> B("Freeze the contract<br/>point A: pinned start state<br/>point B: acceptance criteria")
    B --> C{"Is a trial authorized?"}
    C -->|No| D("Use source inspection<br/>or a tabletop evaluation")
    C -->|Yes| E("Prepare fixtures at point A<br/>with candidate guidance")

    subgraph TRIAL["Black box: fresh, isolated trial agents"]
        F{{"Spawn a fresh agent<br/>neutral brief, fixed settings"}}
        V("Load candidate guidance<br/>and verify exposure")
        W("Work from point A<br/>toward point B")
    end

    E --> F --> V
    V -->|loaded| W
    V -->|not loaded| X(["Stop the measured trial<br/>diagnose bootstrap separately"])
    W -->|artifacts only| G("Audit against point B<br/>diffs, tests, and runtime evidence")
    D --> H("Revise one missing<br/>decision or check")
    G --> H
    H --> I("Check a contrasting case")
    I --> J{"Acceptance met or<br/>further work needs policy?"}
    J -->|No| B
    J -->|Yes| K(["Freeze artifact and report<br/>revision, evidence, and limits"])

    classDef stage fill:#24283b,stroke:#7aa2f7,stroke-width:1px,color:#c0caf5;
    classDef delegated fill:#1f2335,stroke:#bb9af7,stroke-width:1.5px,color:#c0caf5;
    classDef outcome fill:#1f2335,stroke:#9ece6a,stroke-width:1.5px,color:#c0caf5;
    classDef terminal fill:#16161e,stroke:#565f89,stroke-width:1px,color:#c0caf5;
    classDef decision fill:#16161e,stroke:#7dcfff,stroke-width:1.5px,color:#c0caf5;
    class A,B,D,E,V,W,G,H,I stage;
    class F delegated;
    class K outcome;
    class X terminal;
    class C,J decision;

    style TRIAL fill:#14151f,stroke:#bb9af7,stroke-width:1px,color:#bb9af7;
```

## What keeps a trial blind

- **New context:** each measured trial uses a new session. A reused or resumed
  session keeps its earlier context, so its result is formative and not blind.
- **Point A only:** the agent works in a trial-owned fixture at the pinned
  revision. The fixture has no prior reports, logs, or files from other trials.
- **Neutral brief:** the brief gives the task, invariants, and approved
  changes. It does not give the diagnosis, the expected design, earlier
  results, or coaching.
- **Real guidance exposure:** the agent must load the candidate guidance
  through the host's supported mechanism. If the guidance does not load, the
  run is a bootstrap failure, not evidence about guidance quality.
- **Same conditions:** every revision gets the same brief, models, settings,
  and validation commands, so the guidance revision is the only intended
  difference.
- **Stateful coordinator:** the coordinator remembers every round and revises
  the guidance. The trial agents remember nothing between rounds.

> [!NOTE]
> Fresh sessions and trial-owned fixtures make the isolation. Instructions
> alone do not. Shared tools or storage can still leak information, so the
> report records each isolation limit.

Guidance authoring does not authorize agent trials, publication, or production
changes.

## Synthetic refinement handoff

<details>
<summary>Open the synthetic guidance-refinement handoff</summary>

**Synthetic example:** The trial, observed failure, and guidance revision below
are fictional.

**Observed problem in the synthetic billing ledger**

A repeated guidance pattern said, "Remove wrappers and share the smallest
common helper." In two isolated trials, that pattern moved
`appendLedgerEntry` into the shared invoice-preview path. Preview began to write
a $60 debit, although the contract said only the worker may persist it.

**Frozen evaluation contract (point B)**

- Invoice preview may calculate a $60 charge, but may not write or schedule
  work.
- The billing worker posts one debit for `usage-731`.
- A repeated event returns the original entry and keeps the balance at $40.
- A contrasting safe case may still consolidate code when both callers have
  the same persistence contract.

**Trial setup (point A)**

Each guidance revision got two new trial agents. Each agent started in its own
copy of the pinned billing-ledger revision, loaded the guidance under test, and
received only this brief: "Remove duplicated charge logic between invoice
preview and the billing worker. Keep the listed invariants. Add tests." No
agent saw the diagnosis, the other trials, or the expected design.

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
