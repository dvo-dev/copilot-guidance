---
name: pr-descriptions
description: >-
  Write or restructure a pull request description that people can scan: a
  one- or two-sentence summary of the change's effect, then the main flow
  diagram, with the business cases collapsed right after it, then what
  changed, a table of open decisions with why each matters, and required
  steps. Supporting detail and a table of decisions already made, with why
  each was accepted or deferred, go in named collapsed blocks. Questions for
  a named person go in a PR comment, not the body.
  Builds on the repository's PR template when one exists, and always uses
  visual-explanations for diagrams, tables, and alerts. Use when writing,
  updating, or restructuring a pull request description, including the draft
  PR body that copilot-review-loop writes.
---

# Pull request descriptions

People scan a pull request (PR) description before they read it. The first
screen tells them what the change does and what they must decide. All other
detail stays in the description, one click away.

Always invoke [visual-explanations](../visual-explanations/SKILL.md) as well,
before you write. It sets how diagrams, tables, and alerts look and when they
help. This skill sets the layout and what stays visible.

Respect the host repository's instructions and PR template. Writing a
description does not authorize posting it: open, edit, or update a PR only
when the task asks for it.

## Inputs and scope

- **The change:** the diff or commits, and the plan, issue, or request that
  explains why.
- **Facts to report:** tests and their results, review results, open
  questions with their owners, and steps that a person must do. Use only
  facts from these sources.
- **The repository's PR template**, if there is one; see
  [PR template](#pr-template).
- **Sections that another skill requires**, such as copilot-review-loop's
  Needs human judgment, review summary, and hidden marker. That skill decides
  what they contain; this skill decides where they go and what stays visible.

## Order

Without a PR template, use this order. With one, the template's sections set
the order; see [PR template](#pr-template).

1. **Summary.** One or two short, plain sentences that say what the change
   does and its effect: which inputs now give which results, for users or
   callers. A topic, event name, or ticket number alone is not a summary. Put
   nothing above it: no heading, alert, or table. The only exception is the
   first heading of a PR template.
   - Topic only: "Handle webhook retry events. This is task 2.1."
   - Effect: "Failed webhook deliveries now retry up to three times with
     backoff. Deliveries that fail with a 4xx status still fail at once."
2. **Main flow diagram**, when the change adds or alters a flow, such as a
   request, event, or code path: one diagram that shows the flow and where
   the change acts.
3. **Business cases**, when the change gives different results for different
   inputs: one table of examples, such as users, plans, or requests, with the
   result for each. Put it right after the flow diagram, in a collapsed block
   unless it is about five lines or shorter.
4. **What changed and why**, as a short list with exact names (files,
   sections, functions, settings).
5. **Open decisions** that need a person, such as Needs human judgment, as a
   visible table with one row for each: the decision needed, why it matters
   (what is at stake, and why a person must decide it), and what the PR does
   until then. Collapse the evidence. An item that already has a recorded
   decision, such as an accepted risk or a deferred fix, goes in the table of
   decisions already made instead; see
   [Visible and collapsed](#visible-and-collapsed). When a named person must
   answer, leave their name out of the row and ask them in a PR comment; see
   [Questions for a person](#questions-for-a-person).
6. **Testing, review, and how the change was produced**, each kept short.

Items 1 to 3 are the opening. Do not add empty sections of your own.

## Questions for a person

Do not ask a named person a question in the body, and do not @mention them
there. Write the question in a PR comment that mentions them, one line for
each question, with what the PR does until they answer. Post the comment only
when the task allows writes to the PR, such as when copilot-review-loop opens
it. Otherwise, give the comment text next to the description.

## PR template

Look for the repository's PR template before you write. GitHub reads
`pull_request_template.md` from the repository root, `.github/`, or `docs/`
(in any letter case, as `.md` or `.txt`), and several templates from a
`PULL_REQUEST_TEMPLATE/` folder in one of those places. If the repository has
none, the owner's `.github` repository can supply a default. With several
templates, use the one that fits the change, and say which one you used.

When a template exists, build the body on it:

- Keep its headings, with the same text and level, in their order. Do not
  rename, merge, or reorder them.
- Put the opening at the start of the first section when that section asks
  what the change does or why, such as "Summary", "Description", or "What
  are you trying to accomplish?". Otherwise, put it above the first heading.
- Put each other item under the section that matches it best, and open
  decisions under the section for reviewer attention, if there is one. Put
  items that match no section after the template.
- Treat the template's HTML comments as instructions to the author. Follow
  them, for example by deleting a section that the template says to delete
  when it does not apply. Keep the other comments.
- Keep checklists. Check an item only when the inputs show that it is true.
- When a section does not apply and the template does not say to delete it,
  keep the heading and write "N/A" with a short reason.
- Apply the visible and collapsed rules inside each section.

## Visible and collapsed

- **Keep visible** what a reviewer needs on the first read: the summary, the
  main flow diagram, what changed, the table of open decisions and open
  risks, and steps that a person must do, such as a deploy order. Apart from
  the main flow diagram, keep each point and table cell to one or two short
  sentences.
- **Collapse supporting detail** into `<details>` blocks: the business cases,
  the reasons and evidence for a point, decisions already made (including
  accepted risks and deferred fixes), other diagrams and case tables, file
  lists, test output, and review history. Collapse a part only when it is
  longer than about five lines; leave shorter parts visible, so a small PR
  often has no collapsed blocks.
- Put each block under the heading that it supports, and give its
  `<summary>` a name that tells what is inside, such as "Retry timing: delay
  before each attempt".
- **Decisions already made** go in one block, right after the open
  decisions, that holds only their table. Its `<summary>` lists their topics,
  not only their IDs, such as "Decisions already made: retry limit, backoff,
  4xx handling". Give each decision one row: the question, its status (such
  as accepted, deferred, or confirmed), the decision, and why it was accepted
  or deferred. That why is the reason the outcome is acceptable now, such as
  a constraint, evidence, cost, or who confirmed it; it does not restate the
  outcome or its effect. For a deferral, also say when to revisit it.
- **Never collapse** the main flow diagram, an open decision, an open risk, a
  required step, or an alert, at any length. Shorten each list item or table
  cell to one or two short sentences, and collapse only the supporting
  detail.

Put a blank line after `</summary>` and before `</details>`, or the Markdown
inside does not render:

```markdown
<details>
<summary>Retry timing: delay before each attempt</summary>

(diagram or table)

</details>
```

## Boundaries

- Do not invent facts, owners, severities, or results. When the inputs do not
  give a fact, say that it is unknown.
- Keep every fact that a reviewer needs. Collapsing moves detail; it does not
  delete it.
- Writing a description does not authorize pushing, opening, editing, or
  marking a PR ready.

## Synthetic example

This example describes no real system. A draft PR adds retries to a webhook
sender, and one question is open:

````markdown
Failed webhook deliveries now retry up to three times with backoff.
Deliveries that fail with a 4xx status still fail at once.

```text
Deliver(payload)
  |-- 2xx             -> done
  |-- 4xx             -> fail at once
  `-- timeout or 5xx  -> retry with backoff, at most 3 times -> then fail
```

<details>
<summary>Business cases: the result for each delivery outcome</summary>

| Delivery result | Before | After |
| --- | --- | --- |
| 2xx | Done | Done |
| 4xx | Fails at once | Fails at once |
| Timeout | Fails at once | Retries up to 3 times |
| 5xx | Fails at once | Retries up to 3 times |

</details>

## What changed and why

- `sender.Deliver` retries timeouts and 5xx responses with jittered backoff.
- New setting `webhooks.max_retries`, default 3.

## Needs human judgment

| Decision needed | Why it matters | Until decided |
| --- | --- | --- |
| Set the retry limit per endpoint? | Slow receivers may need fewer retries, and the API owners own that trade-off. | One global limit of 3 applies. |

<details>
<summary>Decisions already made: backoff, 4xx handling, per-endpoint metrics</summary>

| Question | Status | Decision | Why accepted or deferred |
| --- | --- | --- | --- |
| Backoff shape? | Accepted | Jittered exponential | It spreads retries after an outage, and the HTTP client already supports it. |
| Retry a 4xx? | Accepted | No | The receiver rejected the request, so a retry gives the same result. |
| Per-endpoint retry metrics? | Deferred | Not in this PR | They help only once per-endpoint limits exist. Revisit with that decision. |

</details>

## Testing

`go test ./sender/...` passed.
````

## Walkthrough cases

| Input | Expected behavior |
| --- | --- |
| Any PR description | Invoke visual-explanations as well, before writing. |
| Long PR with flows, case tables, and test logs | Open with the summary and the main flow diagram, both visible, then the business cases in a collapsed block. Keep open questions, open risks, and required steps visible; put other flows, tables, and logs in named `<details>` blocks. |
| Many decisions already made and one open question | The open question is one row in the visible open-decisions table: the decision needed, why it matters, and what the PR does until then. The decisions go in one collapsed block that lists their topics, as a table: question, status, decision, and why it was accepted or deferred. |
| During the run, the user accepted a risk or deferred a fix | Put it only in the table of decisions already made, with why it was accepted or deferred and when to revisit it. |
| An open question names the person who must answer it | Keep its row in the open-decisions table, without the name or an @mention, and say it was asked in a PR comment. Post that comment only when writes to the PR are allowed. |
| The repository has a PR template, and one question is open | Put the opening at the start of the template's first section when it asks what the change does or why. Keep every heading in order, and put the open question under the section for reviewer attention. |
| The template's first section is a checklist | Put the opening above the first heading. Keep the checklist, and check only the items that the inputs confirm. |
| A template comment says to delete a section that does not apply | If the section does not apply, delete it and its comment as told. If it applies, fill it. |
| A template section does not apply, and the template gives no instruction | Keep the heading and write "N/A" with a short reason. |
| The repository has several templates in `PULL_REQUEST_TEMPLATE/` | Use the one that fits the change, and say which one you used. |
| Small documentation-only PR | Write a short summary and a few lines. Add a flow diagram or business cases only when the change has them; add no collapsed blocks or empty sections. |
| The inputs give no owner for an open item | Say that no owner is recorded; do not invent one. |
