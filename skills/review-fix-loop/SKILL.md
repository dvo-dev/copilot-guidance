---
name: review-fix-loop
description: >-
  Harden the current code change locally before a pull request. Runs the
  repository's unit tests and fast checks first, then iterates
  adversarial-review, verification, test-first fixes, and commits for at most
  three fix cycles, with every fix re-reviewed by fresh reviewers. Stops early
  when a review finds nothing worth fixing, and escalates when the cap is
  reached or progress stalls. Use when asked to review and fix, harden,
  polish, or iterate on a change locally, or when plan-to-pr reaches its local
  review phase. Does not push or open pull requests.
---

# Review-fix loop

Get a change to a state that both the tests and two independent reviewers
accept, or stop with an honest list of what is left. Tests and other
deterministic checks run first and outrank any reviewer's opinion. Every fix
gets a fresh review, so the loop never ends on unreviewed work.

Respect the host repository's instructions, safety rules, and approval gates.
Fixes must stay within the scope the user or plan approved.

## Inputs and scope

- **Change:** the current branch compared with its merge base on the pull
  request base or the default branch.
- **Intent (optional):** the plan's goal, acceptance criteria, and non-goals.
  These are passed to the reviewers.
- **Mode:**
  - **Pipeline:** [plan-to-pr](../plan-to-pr/SKILL.md) called it and supplies
    the run directory and ledger.
  - **Standalone:** anything else, such as a request from the user or from
    another session. Keep `state.md` in plan-to-pr's shape, without the lock.
- **Path (pipeline only):** full or light. On the light path, fix cycles run
  only for blocking (P0 or P1) fix items; record the other fix items as
  "valid, not fixed: light path" and report them with the cap leftovers.
- **Check commands:** discover them from the repository's agent instructions,
  contributing guide, CI workflows, and build manifests, preferring documented
  commands. Use the repository's own environment setup, such as its virtual
  environment or pinned toolchain.
- **Run directory:** `dev-loop/<branch>/` in the host's session artifact
  directory. It holds `state.md`, `ledger.md`, `packets/`, and `reviews/`, and
  is shared with plan-to-pr and copilot-review-loop. Never write it into the
  repository.

## 1. Preflight

- Stop if the current branch is the default branch, or if there is no change.
- Inspect `git status --porcelain`:
  - **Pipeline:** the tree may contain only changes this run made. If any
    other modified or untracked path exists, stop and ask; never commit it.
  - **Standalone:** list the uncommitted paths and confirm with the user before
    committing them as the baseline. Leave out any path the user does not
    confirm. If any path stays unconfirmed, stop and ask the user to commit,
    move, or discard it: the gate and the review would otherwise run on a tree
    that differs from the change.
- Stage explicit paths only. Never use `git add -A`, `git add .`, or
  `git commit -a`.
- Record the base SHA, head SHA, and check commands in `state.md`.

## 2. Gate: deterministic checks

Run the repository's checks in this order: formatter check, linter, type
checker (when it is fast), and unit tests. Run targeted unit tests for the
changed areas first, then the full unit suite.

- **Green** means every check passes except baseline failures: failures that
  also happen on the base revision.
  - To confirm a suspected baseline failure, run the same check on the base
    revision in a temporary `git worktree` outside the repository.
  - Never stash, reset, or check out over the working tree to do this.
  - Record confirmed baseline failures. They are reported, not fixed.
- Fix failures that the change caused before any review; a red gate wastes
  reviewer effort. When this is the initial gate, before the first review,
  commit those repairs, and any uncommitted repairs the run inherited, such as
  Gate A's in pipeline mode, by explicit path as `Fix gate failures`. Then
  record the new head. Inside a fix cycle, leave gate repairs for the cycle
  commit.
- If the repository has no unit tests, run the strongest checks available and
  say so in the report.
- Use the repository's documented tooling. Do not install new tools for the
  gate. Read-only smoke runs, such as a script's usage errors or read-only API
  calls, are allowed.
- **Checks integrity:** never weaken, skip, or delete tests. Never mark tests as
  expected failures, lower thresholds, disable lint rules, or edit CI
  configuration to get green.
- If the gate cannot be made green, stop and report.

## 3. Review and adjudicate

Run [adversarial-review](../adversarial-review/SKILL.md) in `change` mode on
the base to `HEAD`, with fresh reviewers and finding IDs `L<round>.<n>`.

- Pass the intent to the reviewers. Never pass earlier rounds.
- Adjudicate against the ledger as adversarial-review describes:
  - A finding rejected earlier with evidence stays rejected unless it brings
    new evidence.
  - A finding fixed earlier but raised again means the fix may be incomplete.

## 4. Decide

Take the first case that applies:

- **Review failure:** adversarial-review returned no result because both
  slots failed. Stop and report.
- **Approach-level escalation:** the reviewers show that the plan or design
  itself cannot meet the requirement. Stop and report; do not patch around it.
- **No fix items:** exit clean, and report any other escalations. If both
  slots listed the same changed file or area under `not_reviewed`, exit with
  an escalation that names it instead.
- **Fix cycles used up (3 done):** this review was the confirmation review.
  1. Adjudicate it fully, including verification.
  2. Report its fix items as "valid, not fixed: fix-cycle cap reached".
  3. Exit without fixing anything.
- **Otherwise:** start a fix cycle.

## 5. Fix cycle (at most 3)

For each fix item, highest severity first:

1. Write a failing test that reproduces it, when practical. If a test is
   impractical, for example for documentation or configuration, record why in
   the ledger. If the repository has no test suite, keep reproductions in the
   run directory, never in the repository, and cite them in the ledger.
2. Make the smallest fix that addresses the root cause, and stay in scope. A
   tightly coupled consequence of the fix, such as a gap that the fix makes
   reachable, may be fixed in the same cycle; record it in the ledger under
   that finding.
3. Run the targeted tests.

Then:

1. Run the full gate (step 2).
2. Commit the explicit paths as `Address review findings (cycle <n>)`. The
   commit body lists only the finding IDs, for example
   `Findings: L1.1, L1.3`. Keep finding text, dispositions, and reasons in the
   ledger, because later reviewers read the commit range.
3. Return to step 3 for a fresh review.

Escalate instead of spending another cycle when:

- a finding still recurs after a second fix; or
- the fix would change scope or behavior that the plan did not approve.

## 6. Report

Return to the caller or user:

- the exit reason: clean, cap reached, escalation, gate failure, or review
  failure;
- the reviews run and fix cycles used, and the models and efforts for each
  round, marking any degraded rounds;
- the commands actually run and their results, including baseline failures;
- counts of fixed, rejected, deferred, escalated, and valid-but-not-fixed
  findings, with blocking items (P0 or P1) first;
- the commits created and the run directory path.

## Boundaries

- Local only. Never push, open or edit pull requests, or post comments.
- Commit only on the current non-default branch. Never amend or rewrite
  commits that are already pushed, and never run destructive git commands.
- Fixes are surgical and within the approved scope.

## Synthetic example

This example describes no real system. A change adds pagination to a list
endpoint, and `make test` is green.

- **Round 1:**
  - L1.1, P1, both slots: an off-by-one error drops the last item when a page
    is full. Disposition: fix.
  - L1.2, P2, slot B: no test covers an empty page. Disposition: fix.
  - L1.3, P3: a naming preference. Disposition: defer.
- **Cycle 1:**
  1. Failing tests for L1.1 and L1.2, then the fixes.
  2. The gate is green.
  3. Commit `Address review findings (cycle 1)`.
- **Round 2:** fresh reviewers find nothing worth fixing, so the loop exits
  clean.

Report: "Clean after 2 reviews and 1 fix cycle (claude-opus-5.5 max,
gpt-6-astra max). Fixed L1.1 and L1.2; deferred L1.3. `make test` passes."

## Walkthrough cases

| Input | Expected behavior |
| --- | --- |
| A test fails on the change before any review | Fix it first. Review only a green change. |
| The same test fails on the base revision | Confirm it in a temporary worktree, record it as a baseline failure, and continue. |
| Round 2 raises a finding rejected in round 1, with no new evidence | Keep it rejected and note the recurrence. |
| L1.1 was fixed in cycle 1 and round 2 raises it again | Investigate the fix. If it still recurs after the next fix, escalate it. |
| The third fix cycle is done | Run the confirmation review, adjudicate it, report its fix items as valid but not fixed, and stop. |
| Reviewers show the design cannot meet the requirement | Escalate it as an approach-level problem and stop. |
| A pipeline run finds an unrelated untracked file | Stop and ask. Never commit it. |
| The repository has no unit tests | Run the strongest checks available and say so. |
| The quickest way to get green is skipping a flaky test | Do not skip it. Confirm whether it fails on base and report it. |
