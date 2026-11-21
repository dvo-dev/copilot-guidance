# Review-fix loop

[Back to the code factory map](../skill-workflows.md) |
[Canonical skill source](../../skills/review-fix-loop/SKILL.md)

This skill is the factory's local quality gate. It reduces the cost of later
PR fixes and records any valid work that remains at the cycle cap.

**Use it when:** a local code change needs deterministic checks, simplification,
review, and bounded fixes before a PR.

**Result:** clean, capped, escalated, or failed local review state.

```mermaid
%%{init: {"theme":"base","themeVariables":{"background":"#1a1b26","primaryColor":"#24283b","primaryTextColor":"#c0caf5","primaryBorderColor":"#7aa2f7","secondaryColor":"#1f2335","secondaryTextColor":"#c0caf5","secondaryBorderColor":"#bb9af7","tertiaryColor":"#16161e","tertiaryTextColor":"#c0caf5","tertiaryBorderColor":"#7dcfff","lineColor":"#7dcfff","textColor":"#c0caf5","mainBkg":"#24283b","nodeBorder":"#7aa2f7","clusterBkg":"#16161e","clusterBorder":"#565f89","defaultLinkColor":"#7dcfff","edgeLabelBackground":"#1a1b26","titleColor":"#bb9af7","fontFamily":"ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, Liberation Mono, monospace"},"flowchart":{"curve":"basis","htmlLabels":true,"nodeSpacing":30,"rankSpacing":34,"padding":10}}}%%
flowchart TD
    A("Preflight branch,<br/>scope, and worktree") --> B("Run format, lint,<br/>types, and tests")
    B -->|Fail outside baseline| C(["Repair or stop"])
    B -->|Pass| E{{"Invoke <a href='https://github.com/dvo-dev/copilot-guidance/blob/main/docs/skill-workflows/surgical-refactoring.md'>surgical-refactoring</a><br/>and consume decisions"}}
    E --> G{{"Invoke <a href='https://github.com/dvo-dev/copilot-guidance/blob/main/docs/skill-workflows/adversarial-review.md'>adversarial-review</a><br/>and consume dispositions"}}
    G --> H{"Outcome"}
    H -->|No fix items| I(["Done"])
    H -->|Failure or approach escalation| J(["Stop and report"])
    H -->|Fix items and cycle left| K("Reproduce with a test<br/>then make the smallest fix")
    K --> L("Run gate<br/>and commit explicit paths")
    L --> G
    H -->|Fix-cycle cap reached| M(["Report valid findings<br/>that remain unfixed"])

    classDef stage fill:#24283b,stroke:#7aa2f7,stroke-width:1px,color:#c0caf5;
    classDef delegated fill:#1f2335,stroke:#bb9af7,stroke-width:1.5px,color:#c0caf5;
    classDef outcome fill:#1f2335,stroke:#9ece6a,stroke-width:1.5px,color:#c0caf5;
    classDef terminal fill:#16161e,stroke:#565f89,stroke-width:1px,color:#c0caf5;
    classDef decision fill:#16161e,stroke:#7dcfff,stroke-width:1.5px,color:#c0caf5;
    class A,B,K,L stage;
    class E,G delegated;
    class I outcome;
    class C,J,M terminal;
    class H decision;

```

Every fix is followed by a fresh review. The simplification pass runs once,
before the initial adversarial review.

## Delegated skill flows

This page stops at each delegation boundary. The delegated page owns the
internal decisions for that call.

| When | Delegate to | Return used by this loop |
| --- | --- | --- |
| Simplification | [Surgical refactoring](surgical-refactoring.md) | Apply, keep, or needs-approval candidates |
| Initial and confirmation reviews | [Adversarial review](adversarial-review.md) | Fix, reject, defer, or escalate dispositions |

## Synthetic example output

<details>
<summary>Open the synthetic review-fix-loop handoff</summary>

**Synthetic example:** The commands, commit, and findings below are fictional.

**Case:** A billing ledger worker posts a $60 usage charge exactly once for event
`usage-731`. The opening balance is $100; the retry must keep the balance at
$40.

**Local loop handoff**

- **Result:** clean
- **Gate:** format, lint, type check, and unit tests passed
- **Simplify:** one option wrapper was removed; separate caller error mapping
  was kept
- **Reviews:** 2 dual-model rounds at xhigh
- **Fix cycles:** 1

| Finding | Before fix | Result |
| --- | --- | --- |
| L1.1 | The invoice preview called the same adapter as the final posting path and could persist a debit. | Split the preview from persistence while reusing the existing amount calculator and ledger entry builder. |
| L1.2 | A duplicate charge constructor existed in preview and worker code. | Reused the private entry builder while preserving the worker-only transaction boundary. |

**Commit:** `abc1234 Address review findings (cycle 1)`

**Fresh confirmation review:** no fix items
**Needs human judgment:** define the rounding rule for a fractional cent

</details>
