---
name: surgical-refactoring
description: >-
  Use when a user or reviewer requests helper consolidation, removal of duplication
  or wrappers, comparison of refactor options, API-shape changes, or implementation
  simplification. Evaluate concrete alternatives and preserve behavior without
  introducing speculative abstractions.
---

# Surgical refactoring

Make the requested flow easier to understand without changing its contract unless
explicitly approved. Stay within scope; skip design comparisons for trivial
renames.

Respect the host repository's instructions, safety rules, side-effect boundaries,
and toolchain conventions. A request for analysis does not authorize edits.

## Inputs and scope

Identify the requested simplification, affected entry points, current revision,
and whether implementation or analysis is authorized. Separate required behavior
from preferences about code shape.

Inspect relevant implementations and tests before designing. If a missing
contract would change the design, identify the uncertainty and request the
smallest necessary clarification.

## 1. Establish the contract before designing

- Separate structural changes from explicitly approved behavior changes. Record
  required differences between callers, including permissive/fail-open fallbacks.
  Simplification is not approval to remove them.
- Inventory real entry points: handlers, commands, workers, consumers, diagnostics,
  and mutation paths. Trace transitive helpers rather than only similarly named APIs.
- Decompose caller differences into input provenance, shared work, output mapping,
  and side-effect/failure policy. Identify what requires independent sequencing
  versus what documented input/result semantics can express.
- Record request versus loaded-state meaning, classification versus authorization,
  domain errors versus transport failures, and relevant public/package boundaries.
- Identify external calls, cache reads/writes, persistent mutations, and
  context/cancellation ownership.
- Include cache hits, cold loads, stale state, and configuration mismatch refreshes
  where relevant. A warm-cache happy path is not the whole contract.
- Keep a small behavior table or call graph in working notes or the handoff.
  Resolve unknowns from evidence; a review allegation is not a confirmed defect.

## 2. Compare plausible small designs concretely

For branching or shared logic, evaluate applicable alternatives before defending
the current design. Sketch real candidate signatures and callers when useful.

| Alternative | Shape to evaluate | Question |
| --- | --- | --- |
| Extend a local branch | Existing operation branches internally | Is this already the right owner? |
| Share a private operation, retain adapters | Adapter A/B calls a common core | Do adapters preserve genuine caller contracts? |
| Expand an existing entry point | Return a meaningful result already computed internally | Can documented inputs/results eliminate extra helpers? |
| Orchestrate at the boundary | Handler loads, checks, and maps the result | Is the difference truly boundary-specific? |

Before rejecting consolidation as impossible or requiring caller modes, show a
concrete failing supported input. Trace public validation/normalization and
documented direct API contracts. Arbitrary raw inputs are not automatically
reachable counterexamples.

A compile-time call-site migration is not itself a behavior change. When
implementation is authorized, use a small candidate diff if needed to resolve
uncertainty. Revisit alternatives as evidence changes. Earlier recommendations
and model consensus are not proof; no design is the default winner.

## 3. Evaluate the whole flow, not patch size

- Compare concepts a reader must learn, independent policy locations, wrapper
  depth, exported surface, duplicate work, error paths, and caller changes.
  Counts inform comparison; minimizing wrappers is not itself the goal.
- Distinguish mechanical signature updates from new caller decisions. More
  mechanically updated files can be simpler than another abstraction.
- Name each adapter's unique work. Compare direct calls, private-core reuse, and
  receiver methods; count thin public aliases while recognizing useful semantic
  boundaries. Moving or renaming a wrapper does not remove it.
- Do not chain semantically different public adapters merely to reuse a helper.
- Prefer existing local branches and helpers. Introduce abstractions only for
  demonstrated, stable repetition that reduces complexity today. Minor duplication
  may be clearer than a registry, callback interface, or options framework.
- Explain the selected trade-off using actual candidate signatures or call graphs,
  not hypothetical future callers.

## 4. Separate data dependencies from incidental ordering

- Identify the information each decision needs. If a choice depends on loaded
  metadata, evaluate it after that load rather than assuming routing must happen
  first.
- Preserve whether decisions use request data or loaded state. Different sources
  are a semantic choice, not proof that separate loading APIs are necessary.
- Load shared state once and pass the same object through the continuation when
  the contract requires consistency. Reinvoking a loader can duplicate work and
  observe different state.
- Document optional data's absence/presence semantics. Provenance must not silently
  grant permission or activate fallback simply because inputs correlate.
- Reject fabricated inputs, magic values, undocumented null semantics, and
  booleans hiding caller modes. Explicit policy inputs are appropriate only for
  real, current semantics.
- Define every result. A resource classification or selected operation does not
  prove permission, successful execution, or absence of an error.

## 5. Place shared rules and caller differences deliberately

- Keep invariant rules in one contained area. Keep caller-only compatibility and
  error mapping at the appropriate boundary.
- If boundary orchestration requires exporting an internal operation, count that
  API cost and reconsider placement before exporting it.
- If a continuation is needed, operate on the already-loaded state rather than
  starting the whole load again.
- Do not grow an options matrix or policy framework for possible future callers.
- If compatibility limits simplification, first evaluate the best preserving
  structure. Then describe any smaller structure requiring a named, separately
  approved policy change. Keep that second stage hypothetical until approval.
- Preservation does not excuse avoiding alternatives; wrapper reduction does not
  authorize changing policy. After approval, reconsider obsolete branches.
- Keep temporary flags local and separate extraction from behavior changes.

## 6. Preserve side-effect boundaries structurally

Synthetic example: a preview and a save operation both need a parsed document,
but only saving may persist it.

```text
Before:
preview -> public save adapter(mode=preview) -> parse -> conditional write

After:
preview -> private parse core -> render preview
save    -> private parse core -> validate -> persist
```

This is an example, not a universal API. Trace both real paths and their helpers.
The shared core must not acquire a write operation forbidden to preview. At the
same time, do not remove writes required by saving or assume that every other
side effect is forbidden without inspecting the contract.

A removed guard alone is not proof of a regression: locate the moved operation
and its concrete entry-point trace. Separate coverage gaps from demonstrated
runtime defects.

When moving calls, compare old/new instrumentation scopes. Distinguish context
identity, values, and cancellation from span parentage and metric duration.
Trace consumers before removing apparently duplicated context values. If required
measurement cannot be preserved, seek approval or isolate a proposed telemetry
change. Do not silently change instrumentation to reduce wrappers.

## 7. Validate exact contracts, including forbidden work

- Inspect existing tests before claiming missing coverage. Build a focused matrix
  from relevant input classes, cache states, refresh paths, flags, permission
  outcomes, and dependency failures.
- Classify failures by stage/provenance and accompanying result state. A wrapped
  downstream error may match the same error category as a local policy rejection.
  Where relevant, test both and verify that only the intended case triggers fallback.
- Use strict mocks plus explicit positive and negative assertions. Negative-call
  assertions must match the real method signature and cover all forbidden inputs;
  wrong-arity assertions can pass vacuously.
- Prove mock wiring with a positive control. Mock the actual side-effect client;
  indirect configuration or cache assertions do not prove no external call occurred.
- Exercise real entry points. In the synthetic preview/save case, prove that preview
  produces its expected output without persistence and save still performs its
  intended persistence.
- Assert contractually required call counts, such as one shared load, rather than
  incidental in-memory checks. Verify result state and error types independently.
- Where useful and authorized, introduce a reversible forbidden-call mutation.
  It must compile and fail for the intended assertion. Revert only that mutation,
  rerun to green, and repeat if subsequent edits move the target.
- Capture original globals, configuration, and client references before mutation.
  Restore originals during cleanup rather than hard-coded zero values.
- Run existing targeted tests first and expand as necessary. Follow host formatting,
  lint, and build conventions; avoid unrelated tests or dependency changes.
- For normal development, verify current target-branch compatibility. For frozen
  trials, retain pinned source rather than merging the live target.
- Anchor diff-based checks to the intended baseline, not post-change HEAD. Inspect
  wrapper defaults so they cannot silently hide findings.

## 8. Remove leftovers and make the proof reviewable

- Read the final flow as a new reviewer. If it requires lengthy defenses of wrappers
  or ordering, reconsider its structure rather than adding explanatory bulk.
- Remove obsolete adapters, exports, tests, documentation, and TODOs only where the
  requested change makes them obsolete. Preserve coverage for surviving behavior.
- Recheck every affected caller and the behavior table against the final diff.
- Report the chosen alternative, before/after evidence, approved behavior changes,
  actual checks, and precise validation limits.
- Separate code readiness from rollout prerequisites. State whether work is local,
  committed, pushed, or otherwise incomplete; do not claim it has landed.
- Stop when the scoped simplification and contract evidence are complete, or when
  further progress requires an explicit policy decision.

## Synthetic walkthrough cases

| Input | Expected behavior |
| --- | --- |
| Duplicate helpers with identical contracts | Compare local consolidation and private-core reuse; verify surviving callers. |
| Similar adapters with different error mappings | Preserve the mappings and allow adapters when they express a real contract. |
| Shared preview/save parser | Prove preview performs no persistence while save retains required writes. |
| Proposed fewer-wrapper design changes telemetry | Preserve required measurements or request explicit approval. |
| Unsupported input offered as proof consolidation is impossible | Check public validation and documented direct-call contracts before accepting it. |
| Refactor-options question only | Return analysis without modifying code or running mutations. |
