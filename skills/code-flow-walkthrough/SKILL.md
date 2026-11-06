---
name: code-flow-walkthrough
description: >-
  Walk the user through how code executes by carrying one concrete scenario
  through the real functions, one major logical segment per turn: a call chain
  that marks where each segment sits, short excerpts labelled with their
  enclosing function, before-and-after state tables, and source links. Use when
  asked to explain, trace, or walk through a code flow, request path,
  lifecycle, or recovery path, or to restart or continue such a walkthrough.
  For a single focused call-path or branch question, use visual-explanations
  instead.
---

# Code flow walkthrough

Help the user build an accurate mental model of a code flow by following one
concrete scenario through the actual functions. Each turn covers one major
logical segment: where it sits in the call chain, the code that decides what
happens, and what the scenario's state looks like afterwards. Then pause and
let the user steer.

Respect the host repository's instructions, safety rules, and access
boundaries. An explanation request does not authorize code changes.

## Inputs and scope

Identify the entry point or behavior the user wants explained, the code
revision, and any scenario, actor, or analogy already in use in the
conversation. Default to the current checkout and state the inspected revision
once at the start, for example "The behavior below is from `abc1234`."
Identify the domain actor, business purpose, and outcome that the code supports.
Use these to frame the walkthrough, grounding claims in the inspected source.
Explain storage fields and helper calls as mechanisms serving that outcome,
not as the scenario itself. If the code does not establish the business meaning,
state that limit rather than inventing one.

Pick the scenario that exercises what the user asked about. If two scenarios
are equally plausible and would produce materially different walkthroughs, ask
which to follow with the host's question tool.

A simple location, property, or single-branch question does not need a
walkthrough. Answer it directly, or use visual-explanations for a focused
call-path or branch question.

## 1. Trace before presenting

- Start at the real entry point and follow the calls the scenario takes. Read
  every function you will show; do not infer behavior from names.
- Distinguish calls, returned data, and side effects, following
  visual-explanations. A returned field is not a call edge.
- Label claims: `[C]` confirmed in code and `[P]` planned or proposed but not
  in this code. Mark invented values as illustrative and injected failures as
  hypothetical, for example `[C, illustrative]`.
- Before each later turn, recheck sources if the revision may have changed,
  and say what changed.

## 2. Keep one running scenario

- Use a domain-level use case: name the actor and business operation, explain
  why it matters, and show the resulting business state. For example, follow a
  library member reserving a book and receiving a pickup notice,
  rather than making a low-level setter, field assignment, or test helper the
  story. Map implementation details back to this purpose.
- Use specific input values and explicit ordering or timestamps. Name
  successive inputs, such as Request A and Request B. Use small illustrative
  numbers and say they are illustrative.
- Ground the scenario in domain concepts and behavior actually supported by
  source. Don't infer policy, customer intent, or downstream effects from a
  method or field name alone. If needed, state the assumption or ask what
  business scenario the user wants to follow.
- When the flow exists to handle ordering, partial failure, or replay, a
  scenario that reaches those paths usually teaches more than the happy path.
- Carry the same scenario, names, values, and analogy through every segment,
  the recap, and any restart. Do not swap in a simpler standalone example to
  make one point; show the point with the running scenario. If a point truly
  needs another scenario, label it as a side example.

## 3. Open with the map

Split the traced path into major logical segments: phases that make a key
decision, write state, or hand off to another component. Most flows need three
to seven. Fold validation, guards, logging, and plumbing into a neighboring
segment unless they change the scenario's outcome.

The opening turn contains:

1. The revision line and a one- or two-sentence big picture.
2. The overview call chain: an ASCII tree in a fenced `text` block from the
   entry point down, with irrelevant helpers collapsed and a short bracketed
   note on each node saying what it does for this scenario. When the same
   function appears more than once, the notes say why each call happens. End
   with one line naming what the map omits, such as validation, flag checks, or
   retry loops.
3. The scenario and a starting-state table.
4. Segment 1, then the pause in [step 7](#7-pause-and-let-the-user-steer).

## 4. Present one segment per turn

Shape each segment like this:

1. **Heading:** `### N. functionName: plain-language purpose`, with the
   function name in code format, for example "### 2. `syncReservation`: try to
   reserve 5 units".
2. **You-are-here chain:** the path from the entry point to the current
   function, reusing the overview's nodes and notes, with `◀ you are here` on
   the current node. Collapse branches not on the path to one line or omit
   them.
3. **Excerpts:** each excerpt starts with a comment naming its enclosing
   function in the language's comment syntax, such as
   `// In (*Store).saveQuantity`, `// Later in (*Store).saveQuantity`, or
   `# In OrderService.save_quantity`.
4. **Scenario mapping:** which branch the scenario takes and with which
   values. Bold the values and conditions that matter.
5. **State table:** after any write or decision that changes state, show the
   records or stores touched, with the fields the scenario cares about. Bold
   changed cells. Write "—" or "not stored here" instead of leaving a cell
   blank. Follow with one sentence explaining what that state means for the
   domain actor or business outcome, not only which record changed.
6. **Sources:** short revision-pinned or repository-relative links with line
   ranges beside the claims they support, such as `(source)`, `(patch)`, or
   `(caller)`.

Excerpt rules:

- Copy code verbatim and elide with `...`. Do not insert invented comments or
  paraphrased code into an excerpt; explain in prose.
- Show the decision or write, usually under 15 lines, not the whole function.
- When a later segment revisits code already shown, reshow only the lines on
  the new branch or refer back, for example "the availability check from step 3
  is now false."

## 5. Triage error handling

Routine error handling gets at most a passing clause, such as "(errors return
to the caller)", or a mention in the map's omissions line. This covers input
validation, error wrapping and propagation, nil checks, logging, and metrics.
Do not give it a segment or a branch in the chain.

An error case is worth a closer look when it changes what the reader should
believe about final state or ordering. Signals include:

- a failure between two writes that are not atomic;
- recovery, retry, or replay that re-reads saved state;
- optimistic-concurrency conflicts or stale and out-of-order input;
- duplicate handling and idempotency;
- fail-open or fail-closed behavior when a dependency is unavailable;
- cancellation or a timeout between side effects.

For such a case, establish what has already persisted, what the caller sees,
whether anything rolls back, and what the partial state means for the domain
actor or business outcome. Label an injected failure as hypothetical, for
example "Now assume a storage error prevents this write." A test-constructible
failure is not evidence of production frequency.

Then decide how deep to go. If the case explains why the flow is shaped the
way it is, carry it through the running scenario. Otherwise mention it in one
sentence and offer it as a choice at the pause.

## 6. Add visuals where they help

When a segment has a branch decision with several material outcomes, a
comparison of outcomes across inputs, or a decisive verified takeaway, invoke
the visual-explanations skill through the host's skill tool. If the host has
no skill tool, follow
[its conventions](../visual-explanations/SKILL.md#visual-conventions). Once it
is loaded, keep following it for later segments without invoking it again.

- Branch preconditions and early exits: a decision tree.
- Outcomes across inputs, such as a fresh request versus a duplicate: an
  outcome table.
- A verified risk or decisive conclusion: an alert callout, within that
  skill's limits.

Straight-line segments need only the you-are-here chain and the state table.
Do not let a graph, a table, and prose all retell the same thing.

## 7. Pause and let the user steer

Display the segment as ordinary chat text before pausing. Saving it to a file
or putting it in a tool call is not a substitute for showing it to the user.
Then use the host's question tool, such as `ask_user`, offering two to four
choices:

- "Next: *next segment's purpose*", listed first and marked recommended;
- "Go deeper: *a specific point from this segment*", when one exists;
- "What if: *an interesting failure or alternate branch*", when one exists;
- "Stop and show the recap".

Do not add a catch-all choice when the tool accepts freeform answers. If the
host cannot pause for input, list the choices as a short numbered list.

When the user responds:

- **Side question:** answer it in the same format, re-show the you-are-here
  chain, and resume the paused segment.
- **Restart:** start again from the overview map with the same scenario and
  format. Do not simplify the scenario or drop the call chain.
- **Format correction:** apply it to the rest of the walkthrough and keep it.
- **Quiz request:** do not quiz unless asked. If asked, ask one question at a
  time with the question tool, built on the running scenario.

## 8. Finish with a recap

After the last segment, or when the user stops, show:

- a checkpoint table with the columns Moment, Enclosing function, one column
  per record or store, and What happens, with one row per segment;
- the overview call chain with the scenario's notes;
- one or two sentences naming the invariants the flow protects.

Keep the recap's claims as conditional as the traced code. Before saying an
input does nothing or causes no writes, check the whole entry path, including
recovery or refresh work before its final classification.

If the user wants notes and the host has a plan or session artifact, mirror
the text actually shown there, not a separate draft. Ask before writing to
tracked files.

## Style

- One name per concept, used consistently across segments.
- Gloss jargon the first time it appears.
- Short paragraphs; keep each chat turn to one segment.
- Bold only the values and conditions that change the outcome.

## Boundaries

Walkthroughs are read-only. Do not edit code, contact production, publish
comments, or change shared state to produce an explanation. Inspecting or
running focused local tests is fine when it helps; label an executed
reproduction separately from source reading and hypothetical failures.

## Synthetic example

Keep reusable examples independent of private product rules, identifiers,
endpoints, and internal links; renaming a domain-specific example is not enough.
Derive each real walkthrough's business rules from the inspected source, not
from the example below.

This invented library example describes no real system, and its links are
omitted. Mira requests a book. One transaction creates her hold and reduces
available copies from two to one. The service then tries to email a pickup
notice. Assume sending the email fails before delivery; the committed hold is
not rolled back.

The walkthrough should explain whether Mira's book is reserved and whether she
has been notified, using the call chain and excerpts to show why. The
notification segment could render like this:

````markdown
### 2. `notify_member`: send Mira the pickup notice

```text
HoldService.place_hold
  -> reserve_copy                [commit Mira's hold and claim one copy]
  -> notify_member               ◀ you are here
       -> Mailer.send            [deliver the pickup notice]
```

**[synthetic, illustrative]** Mira's hold is already committed. This function
tries to send her notice, then records successful delivery:

```python
# In HoldService.notify_member
hold = self.store.read_hold(hold_id)
if hold.notice_sent:
    return "already_notified"
self.mailer.send(hold.member_email, hold.book_title)
self.store.mark_notified(hold_id)
return "notified"
```

**Now assume (hypothetical) sending fails before delivery.** The caller sees an
error, and `mark_notified` is not reached. The earlier reservation transaction
remains committed. (source, caller)

| Business state | Before the request | After the failed notice |
| --- | --- | --- |
| Available copies | 2 | **1** |
| Mira's hold | Not created | **Reserved** |
| Notice delivered | No | No |
| Hold marked notified | Not applicable | **No** |

Mira has a reserved copy, but she has not received the pickup instructions.
Retrying `notify_member` attempts the notice without reserving another copy.
This does not establish exactly-once delivery if sending succeeds but recording
that success fails.
````

The turn then pauses with choices such as "Next: retry Mira's pickup notice
(recommended)", "What if: the email is delivered but recording that fails",
and "Stop and show the recap".

## Walkthrough cases

| Input | Expected behavior |
| --- | --- |
| "Walk me through how this request is handled" | State the revision; frame a source-grounded business use case; show the overview chain, scenario, starting state, and segment 1; then pause. |
| "Where is this field set?" | Give a short cited answer without a walkthrough. |
| A flow whose only errors are validation and propagated storage errors | Mention them in the map's omissions line; add no error segment. |
| Two non-atomic writes with a recovery path | Carry a hypothetical failure between the writes through the scenario and show what recovery reads. |
| A segment whose outcome depends on an input flag | Invoke visual-explanations and add an outcome table; keep the you-are-here chain. |
| "Restart and present it interactively" | Restart from the overview map with the same scenario and format, one segment per turn. |
| A side question mid-walkthrough | Answer it, re-show the you-are-here chain, and resume the paused segment. |
| "Quiz me on this" | Ask one question at a time with the question tool, built on the running scenario. |
