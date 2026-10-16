---
name: refine-agent-guidance
description: >-
  Use when asked to improve, refine, or evaluate skills, instruction files, or
  agent guidance using representative tasks or historical replays. Diagnose
  observed decision failures, run only authorized isolated evaluations, and
  make bounded, evidence-based guidance revisions.
---

# Refine agent guidance

Improve decisions, not agreement with a preferred answer. Start with the smallest
useful evaluation: source inspection and a tabletop case may suffice.

Respect the host repository's instructions, safety rules, and data policies.
Keep mandatory constraints always-on; a request-triggered skill must not make
them optional. Authoring guidance does not authorize trial agents, publishing,
or production changes.

## Inputs and scope

Establish the guidance being revised, the observed problem or intended workflow,
available task evidence, and the authorized scope of changes and evaluation.

If no failure evidence exists, label the work as initial authoring or a
hypothesis-driven revision rather than claiming a demonstrated improvement.
Missing authorization blocks trials, not ordinary source inspection or an
explicitly requested draft.

## 1. Diagnose the observed failure

- Read relevant code, review discussion, instructions, and authorized historical
  evidence. Cite sources and distinguish observations from hypotheses.
- Reconstruct the actual decision. An alternative considered but over-dismissed
  differs from one never considered. Frustration or model consensus does not prove
  a reasoning defect or a preferred design's superiority.
- Separate reasoning failures, missing evidence, environment/bootstrap problems,
  and confirmed implementation bugs. An unreachable injected-error case may expose
  structural weakness without demonstrating a production defect.
- Identify a reusable missing decision or check, not a rule encoding the preferred
  final patch. Preserve useful guidance rather than rewriting everything.

## 2. Freeze the evaluation contract

- Pin the task, representative source revision, guidance revision, and setup.
  Record invariants and separately approved behavior changes.
- Define correctness, error contracts, forbidden side effects, and required
  context/cancellation and telemetry behavior before simplicity measures.
  Fewer lines or wrappers cannot compensate for lost semantics.
- Distinguish useful semantic aliases from redundant layers, and data provenance
  or classification from permission to perform an operation.
- State acceptance criteria, stopping criteria, and validation limits before
  iterating. Include a contrasting case where the preferred pattern should not
  be forced.
- Keep requirements stable across comparisons. An approved policy change starts
  a distinct stage, not a guidance-only comparison.

## 3. Authorize the smallest suitable trial

- Default to one manual/tabletop evaluation. Model trials require explicit
  approval for bounded model, revision, and session counts plus spending or
  resource limits. Do not silently expand into a campaign or evaluation framework.
- Ask before launching if delegation or resource limits are not authorized.
  Never invent a monetary ceiling.
- Select models from the host's available catalog and authoritative capability
  information. Do not infer suitability, rank, or access from names, versions,
  price, or automatic routing. Ask when necessary information is ambiguous.
- Confirm exact model IDs and supported settings before launch. Pin effective
  settings across guidance revisions; rebaseline if models change. Do not add
  providers or agents beyond the approved scope.
- Choose the evaluation mode in advance. Use fresh independent sessions for
  guidance-effectiveness measurement. Reuse sessions only for formative work,
  labeled non-blind. Restoring files or resuming a session does not reset context.
- Keep the coordinator/guidance author stateful across measured rounds; keep
  measured trial contexts independent.

## 4. Prepare isolated, reproducible fixtures

- Inspect branch and dirty state. Use trial-owned fixtures, not an active user
  checkout, a merged feature branch, or another trial's files.
- Preserve prior results in approved local artifacts or commits. Restore only
  explicitly authorized trial-owned paths to the pinned revision. Avoid broad
  destructive resets, cleanup, and shared-global state changes.
- Separate source setup, guidance installation, and implementation results so
  comparisons exclude fixture churn and earlier patches.
- Materialize identical pinned runtime/source plus candidate guidance before
  startup. Verify contents, not branch names. Exclude prior reports and logs
  from measured fixtures.
- Install guidance before startup when discovery is startup-scoped.
- Shared object stores and cross-session tools are not a hard sandbox. Document
  isolation limits; use stronger fixture/tool restrictions when required and
  authorized rather than claiming blindness from instructions alone.
- Record local, committed, pushed, and archived status. Do not automatically
  archive sessions containing persistent work or ongoing activity.

## 5. Verify actual guidance exposure

- For skills, verify successful activation through the host's supported mechanism
  before trial design or implementation. Record the loaded version or content
  hash and available activation evidence.
- If the host exposes a skill-invocation tool, require successful invocation;
  manually reading a file is not equivalent. For automatically loaded skills,
  establish supported evidence of loading rather than inventing a tool call.
- For plain instructions, verify exact installed contents and exposure. Do not
  invent a skill invocation for non-skill guidance.
- If discovery or exposure fails, stop the measured trial. Diagnose bootstrap
  separately from guidance quality. Avoid repeated ineffective reloads.
- Repair setup only within approved scope, using a cold session when appropriate.
  Record failed launches separately and disclose any remaining exposure limit.

## 6. Run the same task independently

- Use the same neutral brief, fixed model/settings per comparison slot,
  validation, and acceptance criteria. Include invariants and approved changes,
  not prior results, correction dialogue, expected architecture, or coaching.
- Restrict measured trials to approved pinned sources. Prohibit earlier session
  histories, other-trial artifacts, later revisions, and remote discussions that
  reveal outcomes. These restrictions supplement isolation; they do not create it.
- For implementation trials, request concrete alternatives, implementation, and
  tests rather than opinions alone. Label tabletop-only evaluations explicitly.
- Record source/setup/result revisions, effective settings, guidance exposure,
  actual validation commands/outcomes, and environmental limits.
- Retain detailed transcripts in authorized session artifacts, not permanent
  how-to documents. Do not publish private logs or source material.

## 7. Audit artifacts and evidence

- Inspect actual diffs, call graphs, and test/runtime evidence, not just
  self-reported counts. Separate mechanical changes from behavioral changes.
- Test claimed impossibility against real input validation and reachable cases.
  Distinguish semantic conflicts from API-shape trade-offs; require a concrete
  counterexample before treating preference as a technical blocker.
- Verify contracts through real entry points, including cold, stale, refresh,
  failure, and forbidden-side-effect paths where relevant.
- Inspect strict mocks, correct negative-assertion signatures, positive wiring
  controls, and accompanying result/error state.
- Optional mutation checks must compile and fail for the intended assertion.
  Compile failures are not coverage evidence. Revert only the mutation, rerun
  successfully, and repeat if later edits move the target.
- Inspect actual command output and baselines. Diff-filtered checks must cover
  the intended diff against pinned setup/source, not post-change HEAD. Check
  wrappers for substituted defaults.
- Do not merge a live target branch into a frozen historical trial. Shipping a
  real change separately still requires current target-branch compatibility.
- Distinguish coordinator inspection, runner claims, observed results, and
  unverified limits. Passing one suite does not prove every contract.

## 8. Revise narrowly and interpret fairly

- Feed generic observed gaps to one guidance author rather than competing editors.
  Pin each revision and retain earlier guidance and results.
- Make small evidence-driven changes. Replace repetition rather than accumulating
  rules. Avoid overfitting to one model, repository, or desired architecture.
- Keep mandatory safety rules discoverable in host instructions. Validate skill
  metadata, triggers, headings, fences, links, and referenced artifacts.
- Check a contrasting formative case before replay: does the revision still allow
  a justified alternative, such as preserving an adapter with a real contract?
- Reused sessions provide formative, non-blind evidence. Fresh sessions remove
  conversation carryover, not model priors or bias in the revised guidance.
- Retain an untouched holdout for final checks; do not tune against it.
- Report task-policy changes separately from structural improvements under
  unchanged contracts.
- Do not claim causal skill-only gains, model superiority, or statistical
  benchmarking from a small or context-carrying comparison.

## 9. Stop, preserve, and hand off

- Stop when acceptance criteria are met, improvements no longer justify scope,
  or progress requires a policy decision. Do not iterate until a model parrots
  a favored answer or claim global mathematical minimality.
- Freeze the selected artifact and record its revision or content identity.
  Remaining style preferences do not automatically justify another round.
- Publishing guidance and shipping trial implementations are separate actions.
  Do not push, open/change pull requests, deploy, or alter shared work without
  authorization.
- Summarize the chosen revision, substantive changes, results, evidence limits,
  and whether context or policy changed. Report artifact and session status.
- State which checks actually ran. Tabletop authoring is not runtime validation.
  Follow the host's publication process only when publishing is authorized.

## Synthetic walkthrough cases

| Input | Expected behavior |
| --- | --- |
| An assistant repeatedly introduces unnecessary wrappers | Identify the missing comparison step; also test a case where an adapter preserves a real contract. |
| A skill fails to load | Stop measured work and classify the problem as bootstrap failure. |
| Requested comparison without trial authorization | Offer a tabletop check or request bounded authorization; launch no models. |
| A replay uses earlier correction dialogue | Label it formative and non-blind, not independent measurement. |
| A simpler result changes failure handling | Treat it as a contract violation unless the behavior change was separately approved. |
