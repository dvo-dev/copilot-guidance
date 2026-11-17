---
name: review-fix-loop
description: >-
  Harden the current code change locally before a pull request. Runs the
  repository's unit tests and fast checks first, then one behavior-preserving
  simplification pass with surgical-refactoring, then iterates
  adversarial-review, verification, test-first fixes, and commits for up to
  the configured number of fix cycles (1 to 3, default 3), with every fix
  re-reviewed by fresh reviewers. Stops early
  when a review finds nothing worth fixing, and escalates when the cap is
  reached or progress stalls. Use when asked to review and fix, harden,
  polish, or iterate on a change locally, or when plan-to-pr reaches its local
  review phase. Does not push or open pull requests.
---

# Review-fix loop

Get a change to a state where the tests pass and no adjudicated review finding
still needs a fix, or stop with an honest list of what is left. Two
independent reviewers look for defects; the parent decides which are
established and worth fixing. Tests and other deterministic checks run first
and outrank any reviewer's opinion. One simplification pass then removes
structure the change does not need, so reviewers do not harden it. Every fix
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
    another session.
- **Path (pipeline only):** full or light. On the light path, fix cycles run
  only for blocking (P0 or P1) fix items; record the other fix items as
  "valid, not fixed: light path" and report them with the cap leftovers.
- **Check commands:** discover them from the repository's agent instructions,
  contributing guide, CI workflows, and build manifests, preferring documented
  commands. Use the repository's own environment setup, such as its virtual
  environment or pinned toolchain.
- **Run records:** `state.md`, `ledger.md`, and the other files in
  `dev-loop/<branch>/` in the host's session artifact directory, shared with
  plan-to-pr and copilot-review-loop and kept as
  [run state](../plan-to-pr/run-state.md) describes. Never write them into the
  repository.

## Settings

| Setting | Values | Default |
| --- | --- | --- |
| Fix cycles | 1, 2, or 3 | 3 |
| Reviewer effort | `high`, `xhigh`, or `max`, passed to every adversarial-review call | `xhigh` |

Resolve them as [adversarial-review](../adversarial-review/SKILL.md#settings)
describes; in pipeline mode, plan-to-pr passes them. Record them in
`state.md`. With N fix cycles, the loop runs at most N + 1 reviews: the review
after fix cycle N is the confirmation review.

## 1. Preflight

- Start, continue, or resume the run as
  [run state](../plan-to-pr/run-state.md#run-directory-and-run-identity)
  describes. When resuming, follow "Resume" below instead of this procedure.
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
- Record the base SHA, head SHA, and check commands in `state.md`, then set
  the local loop to `running`. A stop before this point leaves the loop
  `not started`, so invoking it again repeats the preflight.

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
  configuration to get green. The only exception is a test that the simplify
  pass (step 3) removes together with the construct it tests.
- If the gate cannot be made green, stop and report.

## 3. Simplify once

Agents often write more structure than a change needs, and reviewers then
harden that structure. Before the first review, run one simplification pass,
so that reviewers see the simpler code. Run it once per run, never in a fix
cycle; step 6 has its own complexity check for each fix.

Skip the pass, and record `simplify skipped: <reason>` in `state.md`, when:

- the run is on the light path, or, in standalone mode, every changed path is
  documentation, comments, or other non-executable text; or
- the user or the plan says to skip it.

Otherwise:

1. Set `In flight` to `simplify pass, head <sha>`.
2. Launch one fresh subagent with
   [adversarial-review](../adversarial-review/SKILL.md#1-choose-the-reviewer-models)'s
   slot A model at the reviewer effort, both passed explicitly. If that model
   is unavailable, use slot B's model and record the substitution. A fresh
   context reads the diff as a new reviewer would; the author tends to defend
   its own structure. Give it the base and head SHAs and the intent, but not
   the reasons for the current design. Tell it to:
   - invoke [surgical-refactoring](../surgical-refactoring/SKILL.md) for
     analysis only, and no other skills or subagents;
   - stay read-only: no file edits, git state changes, builds, or tests;
   - consider only code that this change adds or modifies;
   - return each candidate's location, the concept, branch, layer, option, or
     duplicate it removes, the smaller design, and the contracts it keeps;
   - also list current structure that has a real reason to stay.

   Save its output as `reviews/simplify.md` in the run directory.
3. Verify each candidate against the code and its callers, then decide:
   - **Apply** when it keeps every caller-visible contract: results, errors,
     side effects, and telemetry. To remove a guard, name the check that
     already prevents the state. A state that only a mock can create does not
     justify the guard.
   - **Keep** when the current structure has a real contract, such as an
     adapter with its own error mapping; when the plan or intent requires it;
     or when the candidate is only a style preference.
   - **Needs approval** when it needs a contract or scope change that the plan
     did not approve. Do not apply it.

   Record each decision and its reason in `reviews/simplify.md`.
4. Apply the accepted candidates. Add each path to `In flight` before changing
   it. Tests from the base revision stay unchanged. A test that this change
   added only for a removed construct, such as an option that no caller sets,
   goes with that construct; record each one. Never remove a test because it
   fails.
5. Run the full gate (step 2). If a candidate makes it fail, reverse only that
   candidate's edits, change its decision to keep, and run the gate again.
6. Commit the explicit paths as `Simplify implementation`. Keep the reasons
   in `reviews/simplify.md`, not in the commit message.
   Set `Head`, record `simplify committed <sha>` in `state.md`, and clear
   `In flight`. If no candidate was applied, record `simplify no change` and
   clear `In flight`.

## 4. Review and adjudicate

Run [adversarial-review](../adversarial-review/SKILL.md) in `change` mode on
the base to `HEAD`, with fresh reviewers and finding IDs `L<round>.<n>`. It
records the round in `In flight` and writes the round's ledger rows; then
update the review count.

- Pass the intent to the reviewers. Never pass earlier rounds.
- Adjudicate against the ledger as adversarial-review describes:
  - A finding rejected earlier with evidence stays rejected unless it brings
    new evidence.
  - A finding fixed earlier but raised again means the fix may be incomplete.

## 5. Decide

Take the first case that applies:

- **Review failure:** adversarial-review returned no result because both
  slots failed. Stop and report.
- **Approach-level escalation:** the reviewers show that the plan or design
  itself cannot meet the requirement. Stop and report; do not patch around it.
- **No fix items:** exit clean, and report any other escalations. If both
  slots listed the same changed file or area under `not_reviewed`, exit with
  an escalation that names it instead.
- **Fix cycles used up (N done, where N is the fix-cycle setting):** this
  review was the confirmation review.
  1. Adjudicate it fully, including verification.
  2. Report its fix items as "valid, not fixed: fix-cycle cap reached".
  3. Exit without fixing anything.
- **Otherwise:** start a fix cycle.

## 6. Fix cycle

Set `In flight` to `fix cycle <n> for <IDs>, touching <paths>`, and add each
path to it before changing that file. For each fix item, highest severity
first:

1. Write a failing test that reproduces it, when practical. If a test is
   impractical, for example for documentation or configuration, record why in
   the ledger. If the repository has no test suite, keep reproductions in the
   run directory, never in the repository, and cite them in the ledger.
2. Make the smallest fix that addresses the root cause, and stay in scope. A
   tightly coupled consequence of the fix, such as a gap that the fix makes
   reachable, may be fixed in the same cycle; record it in the ledger under
   that finding.
3. Check the fix once for added complexity. Ask: "Did this fix add a concept,
   branch, layer, or policy that the established defect did not require?"
   Compare it with the diff and its callers. Remove only what is unnecessary
   and in scope. Keep behavior the same, including edge inputs, errors, and
   side effects. If removal would change a caller-visible contract, keep the
   fix and note the concern in the ledger. Record the answer under the
   finding. This is a single check, not a new review or loop.
4. Run the targeted tests.

Then:

1. Run the full gate (step 2).
2. Commit the explicit paths as `Address review findings (cycle <n>)`. The
   commit body lists only the finding IDs, for example
   `Findings: L1.1, L1.3`. Keep finding text, dispositions, and reasons in the
   ledger, because later reviewers read the commit range.
3. Record the commit: set each fixed finding's State to `committed <sha>`,
   update `Head` and the fix-cycle count, and clear `In flight`.
4. Return to step 4 for a fresh review.

Escalate instead of spending another cycle when:

- a finding still recurs after a second fix; or
- the fix would change scope or behavior that the plan did not approve.

## 7. Report

Set the local loop to `done` with the exit reason, then return to the caller
or user:

- the exit reason: clean, cap reached, escalation, gate failure, or review
  failure;
- the settings used, the reviews run and fix cycles used, and the models and
  efforts for each round, marking any degraded rounds;
- the simplify result: skipped with its reason, no change, or the commit with
  `git diff --shortstat` from the base to the commit's parent and to the
  commit, plus each candidate that needs approval, in one line each;
- the commands actually run and their results, including baseline failures;
- counts of fixed, rejected, deferred, escalated, and valid-but-not-fixed
  findings, with blocking items (P0 or P1) first;
- the commits created and the run directory path.

## Resume

When `state.md` shows the local loop `running`, follow
[run state](../plan-to-pr/run-state.md#resume) first. It records steps that
happened, and finishes an in-flight simplify pass, round, or fix cycle; a
finished simplify pass or fix cycle continues at step 4. With nothing in
flight, run the gate (step 2). Then, if no review has run and no simplify
result is recorded, take step 3; if the review count equals the fix-cycle
count, take step 4; otherwise take step 5 for the latest round.

## Boundaries

- Local only. Never push, open or edit pull requests, or post comments.
- Commit only on the current non-default branch. Never amend or rewrite
  commits that are already pushed, and never run destructive git commands.
- Fixes are surgical and within the approved scope.

## Synthetic example

This example describes no real system. A change adds pagination to a list
endpoint, and `make test` is green.

- **Simplify:** the subagent finds a `PageWindow` class that only one handler
  uses and that only wraps two integers, and a `max_page_size` option that no
  caller sets. Both removals keep every result and error the same. Inline the
  class, remove the option and the test that this change added for it, run
  the gate, and commit `Simplify implementation`.
- **Round 1:**
  - L1.1, P1, both slots: an off-by-one error drops the last item when a page
    is full. Disposition: fix.
  - L1.2, P2, slot B: a request for page 0 returns the first page twice,
    because the handler treats 0 and 1 as the same page. Disposition: fix.
  - L1.3, P2, slot A: no test covers an empty page, and the empty case
    already returns an empty list. Disposition: reject (not established).
- **Cycle 1:**
  1. Failing tests for L1.1 and L1.2, then the fixes.
  2. The gate is green.
  3. Commit `Address review findings (cycle 1)`.
- **Round 2:** fresh reviewers find nothing worth fixing, so the loop exits
  clean.

Report: "Clean after 2 reviews and 1 of 3 fix cycles (claude-opus-5.5 xhigh,
gpt-6-astra xhigh). Simplify removed a single-use class and an unused option
(180 to 142 added lines). Fixed L1.1 and L1.2; rejected L1.3. `make test`
passes."

## Walkthrough cases

| Input | Expected behavior |
| --- | --- |
| A test fails on the change before any review | Fix it first. Review only a green change. |
| The same test fails on the base revision | Confirm it in a temporary worktree, record it as a baseline failure, and continue. |
| The simplify subagent finds a wrapper with one caller and no contract of its own | Inline it, run the gate, and commit `Simplify implementation` before the first review. |
| Two adapters look duplicate, but each maps errors differently for its callers | Keep both and record the error mapping as the reason. |
| A simplify candidate removes a guard because "the caller validates" | Apply it only after naming the check that prevents the state. Otherwise keep it. |
| A simplify candidate would change the error type that callers see | Do not apply it. Report it as needing approval. |
| The change edits only documentation, or the pipeline is on the light path | Skip the simplify pass and record the reason. |
| Round 2 raises a finding rejected in round 1, with no new evidence | Keep it rejected and note the recurrence. |
| L1.1 was fixed in cycle 1 and round 2 raises it again | Investigate the fix. If it still recurs after the next fix, escalate it. |
| The last allowed fix cycle is done, such as the second with fix cycles set to 2 | Run the confirmation review, adjudicate it, report its fix items as valid but not fixed, and stop. |
| "Review and fix this with 1 cycle at max" | Use 1 fix cycle and reviewer effort `max` without asking, for at most 2 reviews. |
| A fix for a missing null check also adds a new helper class and a config option | Fail the complexity check. Remove the helper and option, keep the check, rerun the targeted tests, and record it. |
| Reviewers show the design cannot meet the requirement | Escalate it as an approach-level problem and stop. |
| A pipeline run finds an unrelated untracked file | Stop and ask. Never commit it. |
| The session is reopened after the machine slept during fix cycle 2, with two edited files listed in `In flight` | Keep the edits, check each of the cycle's findings and finish any not yet fixed, then run the gate, commit cycle 2, record it, and continue with a fresh review. |
| The same loop is invoked again after it reported `done` | Rename the old run directory and start a new run with finding IDs from L1. |
| The repository has no unit tests | Run the strongest checks available and say so. |
| The quickest way to get green is skipping a flaky test | Do not skip it. Confirm whether it fails on base and report it. |
