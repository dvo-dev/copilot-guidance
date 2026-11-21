# Copilot review loop

[Back to the code factory map](../skill-workflows.md) |
[Canonical skill source](../../skills/copilot-review-loop/SKILL.md)

This skill is the factory's draft-PR review stage. It makes external review
progress visible, then stops when human or concurrent work needs ownership.

**Use it when:** the current branch should be reviewed through a draft PR, or
`plan-to-pr` reaches the PR phase.

**Result:** an iterated draft PR and a summary for human reviewers.

> [!WARNING]
> Mermaid links in this diagram are pinned to `main` because GitHub cannot
> resolve document-relative node links inside its Mermaid iframe. A new target
> can return 404 before merge; use the relative Markdown links below the
> diagram for same-ref navigation.

```mermaid
%%{init: {"theme":"base","themeVariables":{"background":"#1a1b26","primaryColor":"#24283b","primaryTextColor":"#c0caf5","primaryBorderColor":"#7aa2f7","secondaryColor":"#1f2335","secondaryTextColor":"#c0caf5","secondaryBorderColor":"#bb9af7","tertiaryColor":"#16161e","tertiaryTextColor":"#c0caf5","tertiaryBorderColor":"#7dcfff","lineColor":"#7dcfff","textColor":"#c0caf5","mainBkg":"#24283b","nodeBorder":"#7aa2f7","clusterBkg":"#16161e","clusterBorder":"#565f89","defaultLinkColor":"#7dcfff","edgeLabelBackground":"#1a1b26","titleColor":"#bb9af7","fontFamily":"ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, Liberation Mono, monospace"},"flowchart":{"curve":"basis","htmlLabels":true,"nodeSpacing":30,"rankSpacing":34,"padding":10}}}%%
flowchart TD
    A("Check clean branch,<br/>green gates, scope, and gh access") --> B{"PR state<br/>for this branch?"}
    B -->|No PR| C{{"Invoke <a href='https://github.com/dvo-dev/copilot-guidance/blob/main/docs/skill-workflows/pr-descriptions.md'>pr-descriptions</a><br/>for the draft body"}}
    C --> D("Push and open<br/>draft PR")
    B -->|Open draft,<br/>head owner matches| E("Reuse draft PR<br/>without editing its body")
    B -->|Open non-draft, closed,<br/>merged, lookup error,<br/>or head owner mismatch| Z(["Stop and hand off<br/>do not push"])
    D --> F("Request Copilot review")
    E --> P("Push local HEAD<br/>without force")
    P --> F
    F --> G("Wait for review and CI")
    G --> H("Collect threads and overview findings")
    H --> CLEAN{"No findings and<br/>CI green?"}
    CLEAN -->|Yes: done-clean| O
    CLEAN -->|No| I{{"Invoke <a href='https://github.com/dvo-dev/copilot-guidance/blob/main/docs/skill-workflows/adversarial-review.md'>adversarial-review</a><br/>and consume dispositions"}}
    I --> J("Classify CI failures<br/>and rerun failed Actions once")
    J --> K{"Actionable item<br/>and cycle left?"}
    K -->|Yes| L("Test-first fix, gate,<br/>commit, and push")
    L --> M("Reply to adjudicated threads;<br/>resolve only addressed,<br/>rejected, or deferred findings")
    K -->|No| M
    M --> N{"New push and<br/>cycle left?"}
    N -->|No push or stop| O(["Post or update<br/>human handoff summary"])
    N -->|Push, cycles remain| F
    N -->|Push, cap reached| Q("Request final review<br/>without waiting")
    Q --> O

    classDef stage fill:#24283b,stroke:#7aa2f7,stroke-width:1px,color:#c0caf5;
    classDef delegated fill:#1f2335,stroke:#bb9af7,stroke-width:1.5px,color:#c0caf5;
    classDef outcome fill:#1f2335,stroke:#9ece6a,stroke-width:1.5px,color:#c0caf5;
    classDef terminal fill:#16161e,stroke:#565f89,stroke-width:1px,color:#c0caf5;
    classDef decision fill:#16161e,stroke:#7dcfff,stroke-width:1.5px,color:#c0caf5;
    class A,D,E,F,G,H,J,L,M,P,Q stage;
    class C,I delegated;
    class O outcome;
    class Z terminal;
    class B,CLEAN,K,N decision;

```

The loop stops for a person review, another push, a no-longer-draft PR, a head
conflict, or a request failure. It never marks the PR ready or merges it.

## Delegated skill flows

| When | Delegate to | Return used by this loop |
| --- | --- | --- |
| A new draft PR needs a body | [Pull request descriptions](pr-descriptions.md) | A scan-friendly body that preserves this loop's required facts and markers |
| Copilot findings need judgment | [Adversarial review](adversarial-review.md) | Fix, reject, defer, or escalate dispositions |

The fix commit follows the explicit-path, test-first, and ledger rules from the
[review-fix loop](review-fix-loop.md), but this page does not redraw that loop.

## Synthetic example output

<details>
<summary>Open the synthetic Copilot review handoff</summary>

**Synthetic example:** The PR, review, CI result, and URLs below are fictional.

**Draft PR handoff comment**

**Case:** The billing ledger draft PR posts one $60 debit for `usage-731`.

**Status:** The draft completed one Copilot review cycle and is ready for human
judgment.

| Review item | Disposition | Human-facing result |
| --- | --- | --- |
| C1.1 | Fixed | A unique-key conflict now reloads and returns the original entry instead of surfacing a database error. |
| C1.2 | Rejected | Reusing the posting adapter from invoice preview would change a read-only path. Focused tests show preview must stay write-free. |
| C1.3 | Deferred | A cached ledger balance remains a follow-up because there is no load evidence for it. |

**CI:** The reviewed head was green after one failed run passed on rerun and
was recorded as a flake. The final push's CI check was not awaited and remains
`unknown (not awaited)`.

**Needs human judgment**

1. Which rule should round a fractional cent into a ledger amount?
2. May a posted usage charge take the ledger below zero, or must it reject?

**Final revision:** A review was requested after the last push but was not
awaited. The PR stays draft and is not marked ready or merged.

</details>
