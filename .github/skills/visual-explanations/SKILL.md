---
name: visual-explanations
description: >-
  Explain code paths and branching outcomes with compact ASCII call graphs,
  decision trees, Markdown tables, and sparing GitHub alert callouts. Use for
  dependency or call-path questions, reviewer critiques, guard-removal what-ifs,
  branching preconditions, fail-open/fail-closed questions, or output comparisons.
---

# Visual explanations

Make the decision structure visible instead of burying it in prose. Lead with a
short verified conclusion, then choose a compact visual only when it helps.
This is a presentation and reasoning workflow, not a requirement to diagram
every answer.

Respect the host repository's instructions, safety rules, and access boundaries.
An explanation request does not authorize implementation or operational actions.

## Inputs and scope

Identify the user's question, relevant entry point or scenario, and requested
revision. Default to the current checkout and identify the inspected revision
when available. Reuse existing context, but recheck changed sources.

Use source, focused tests, and authorized supporting artifacts. Missing client
code or runtime evidence limits the conclusion; it does not grant permission to
fetch production data.

A simple location, property assignment, or confirmation normally needs only a
sentence and citation. Do not turn it into a graph or table.

## Procedure

1. **Frame the decision.**
   Identify what the reader needs to distinguish. Use a call graph for
   caller/dependency relationships, a decision tree for branch preconditions and
   early exits, or an outcome table for comparisons. When both help, the graph
   shows flow and the table shows outcomes; prose supplies the conclusion and
   uncertainty, not a third retelling.

2. **Trace before drawing.**
   Start at real entry points and follow validation, transformations, helpers,
   decisions, and response construction. Inspect focused tests, distinguishing
   inspection from execution.

   Track input provenance: request, cached state, refreshed state, or another
   verified source. Separate calls, returned objects, decisions, and side effects.
   Returned fields are data, not call edges.

   Inspect accessors before claiming side effects: lazy getters may load data,
   while configuration evaluations may use an in-memory snapshot. Verify remote
   and cache operations and their conditions rather than inferring them from names.

3. **Derive the scenarios.**
   State the exact conjunction required to reach an edge case, including earlier
   guards and validation. For guard-removal critiques, compare current and
   proposed behavior with the same inputs; trace callers and refresh paths before
   accepting or rejecting the runtime premise.

   Test-constructible state is not evidence of production occurrence or frequency.
   Preserve error, fail-open/fail-closed, and side-effect contracts.

   Keep relevant distinctions explicit: classification versus permission,
   request-owned routing versus loaded state, aggregate status versus individual
   results, and returned data versus actions actually performed. These are
   reasoning prompts, not assumptions about every system.

4. **Present and finish.**
   Show only branches and rows that answer the question, including material early
   exits and errors. Use exact field names and units. Choose columns for input
   state, result, error, and side effects as relevant. Reserve
   [alert callouts](#alert-callouts) for decisive takeaways.

   Mark "not returned", "not applicable", and "unknown" explicitly rather than
   treating them as false or zero. An uninspected call is not a verified absent
   or forbidden call.

   Distinguish what a producer emits from what a verified consumer reads or
   enforces. A field name or classification does not prove authorization.

   Put source citations or revision-pinned links beside the graph or table.
   Label evidence as source-observed behavior, inspected test, executed
   reproduction, proposed behavior, synthetic example, hypothesis, or unavailable
   evidence as appropriate.

   Stop when the question has a checkable answer. If evidence prevents a
   conclusion, identify the precise missing source and bound the answer.

## Visual conventions

Use ASCII in fenced text blocks: arrows, named branches, explicit conditions,
and early exits. Prefer this over Mermaid unless the user requests otherwise.
Make call edges and returned data visibly distinct; label field reads as state.

Collapse irrelevant helpers and disclose omitted branches. Split complex flows
only when useful. Avoid full Cartesian products, obligatory response sections,
and graph/table/prose combinations that all say the same thing.

## Alert callouts

Use a GitHub alert to make a decisive takeaway hard to miss, not to decorate
the answer. Many answers need none. Choose the type by the takeaway's role and
verified consequence, not by tone:

| Alert | Use for |
| --- | --- |
| `[!IMPORTANT]` | The verified conclusion, or a precondition the reader needs to act correctly. |
| `[!WARNING]` | Verified current behavior that already risks harm, such as a fail-open path, forbidden side effect, or broken error contract. |
| `[!CAUTION]` | The negative outcome of a proposed change or action, such as removing a guard. |
| `[!NOTE]` | An evidence limit that bounds the conclusion, such as an uninspected consumer. |
| `[!TIP]` | Rarely: a concrete check that would resolve an open question. |

- Use at most two alerts per answer, never back to back. Pick the takeaway that
  would change the reader's next decision; keep other caveats in prose or rows.
- Keep each alert to one to three lines with exact names, its evidence label,
  and a citation. Do not escalate a hypothesis, synthetic example, or
  test-constructible state into a verified production risk.
- The alert replaces the sentence it highlights; do not repeat it in prose.
- Write alerts as top-level blockquotes: `> [!TYPE]` alone on the first line,
  then every content line prefixed with `>`. Do not nest them in lists, tables,
  or other blockquotes, and keep ASCII graphs and tables outside them.
- Use alert syntax only where the destination is known to render it, such as
  GitHub issues, pull requests, discussions, comments, repository Markdown
  files, or a chat surface verified to support it. Elsewhere, including plain
  text and unknown renderers, use a bold lead-in such as `**Warning:**` under
  the same limits.

## Boundaries

Explanation and review requests are read-only unless separately authorized.
Do not edit code, contact production, publish replies, deploy, or modify shared
state merely to produce an explanation.

Do not simplify a visual by silently changing behavior or inventing consumer
logic. For implementation, incident response, or other operational tasks, follow
the host's applicable procedures and approval gates.

## Synthetic example

Prompt: "Show the request/cache mismatch branches. Does refreshing configuration
also change the request-selected route?"

Assume, only for this example, that routing is request-owned. A rendered answer
could lead with one alert, then show the graph and table:

```markdown
> [!IMPORTANT]
> Synthetic: refreshing changes only the loaded configuration. The
> request-owned route stays `A`, even when the refresh returns `B`.
```

```text
Request.mode vs cached.mode
    |
    +-- equal -> use cached configuration
    +-- differ -> reloadConfiguration()
                      |
                      +-- success -> use refreshed configuration
                      +-- error -> caller error handling
```

| Request / cache | Refresh result | Loaded configuration | Request-owned route |
| --- | --- | --- | --- |
| A / B | A | A; disagreement resolved | A |
| A / B | B | B; disagreement remains | A |
| A / B | Error | No successful refreshed result | Inspect the caller's error contract |

For a real answer, verify the routing source and error paths before using this
shape. Cite the actual implementation; the example establishes no repository fact.

## Walkthrough cases

| Input | Expected behavior |
| --- | --- |
| Source-backed call-path question | Trace entry points, distinguish calls from data, and cite relevant paths. |
| Guard-removal critique | State all preconditions and compare before/after with identical inputs. |
| Payload comparison | Compare exact fields, scope, errors, and verified consumer behavior. |
| Missing or contradictory evidence | State what is known and identify the precise gap. |
| Pull request reply where a proposed change would fail open | Use one `[!CAUTION]` alert with the verified condition and citation; keep the graph and table outside it. |
| Plain-text answer with one decisive caveat among several | Use a bold lead-in for the decisive caveat instead of alert syntax; keep the rest in prose or rows. |
| Simple property question | Give a short cited answer without a visual or alert. |
