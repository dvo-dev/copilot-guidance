---
name: pr-descriptions
description: >-
  Write or restructure a pull request description that people can scan: a
  one- or two-sentence summary of the change's effect, then the main flow
  diagram and the business cases, then what changed, open questions, and
  required steps, with supporting detail and a table of decisions already
  made in named collapsed blocks. Questions for a named person go in a PR
  comment, not the body.
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
   result for each.
4. **What changed and why**, as a short list with exact names (files,
   sections, functions, settings).
5. **Open items** that need a person, such as Needs human judgment. Give each
   one visible line: what to decide and what the PR does until then. A
   question for a named person goes in a PR comment instead; see
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
- Put each other item under the section that matches it best, and open items
  under the section for reviewer attention, if there is one. Put items that
  match no section after the template.
- Treat the template's HTML comments as instructions to the author. Follow
  them, for example by deleting a section that the template says to delete
  when it does not apply. Keep the other comments.
- Keep checklists. Check an item only when the inputs show that it is true.
- When a section does not apply and the template does not say to delete it,
  keep the heading and write "N/A" with a short reason.
- Apply the visible and collapsed rules inside each section.

## Visible and collapsed

- **Keep visible** what a reviewer needs on the first read: the opening, what
  changed, open questions and open risks, and steps that a person must do,
  such as a deploy order. Apart from the main flow diagram and the business
  cases, keep each point to one or two lines.
- **Collapse supporting detail** into `<details>` blocks: the reasons and
  evidence for a point, decisions already made (including accepted risks),
  other diagrams and case tables, file lists, test output, and review
  history. Collapse a part only when it is longer than about five lines;
  leave shorter parts visible, so a small PR often has no collapsed blocks.
- Put each block under the heading that it supports, and give its
  `<summary>` a name that tells what is inside, such as "Retry timing: delay
  before each attempt". Put decisions already made in one block whose
  `<summary>` lists their topics, such as "Decisions already made: retry
  limit, backoff, 4xx handling". In that block, use a table with one row for
  each decision: the question, the decision, and why.
- **Never collapse** the main flow diagram, the business cases, an open
  question, an open risk, a required step, or an alert, at any length.
  Shorten each list item to one line, and collapse only its supporting
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

| Delivery result | Before | After |
| --- | --- | --- |
| 2xx | Done | Done |
| 4xx | Fails at once | Fails at once |
| Timeout or 5xx | Fails at once | Retries up to 3 times |

## What changed and why

- `sender.Deliver` retries timeouts and 5xx responses with jittered backoff.
- New setting `webhooks.max_retries`, default 3.

## Needs human judgment

- **Set the retry limit per endpoint?** The API owners decide. Until then,
  one global limit applies.

<details>
<summary>Decisions already made: backoff, 4xx handling</summary>

| Question | Decision | Why |
| --- | --- | --- |
| Backoff shape? | Jittered exponential | Spreads retries after an outage |
| Retry a 4xx? | No | The receiver rejected the request |

</details>

## Testing

`go test ./sender/...` passed.
````

## Walkthrough cases

| Input | Expected behavior |
| --- | --- |
| Any PR description | Invoke visual-explanations as well, before writing. |
| Long PR with flows, case tables, and test logs | Open with the summary, the main flow diagram, and the business cases, all visible. Keep open questions, open risks, and required steps visible; put other flows, tables, and logs in named `<details>` blocks. |
| Many decisions already made and one open question | The open-items section shows the one open question. The decisions go in one block whose title lists their topics, as a table: question, decision, and why. |
| An open question names the person who must answer it | Keep the question and the @mention out of the body. Put them in a PR comment, and post it only when writes to the PR are allowed. |
| The repository has a PR template, and one question is open | Put the opening at the start of the template's first section when it asks what the change does or why. Keep every heading in order, and put the open question under the section for reviewer attention. |
| The template's first section is a checklist | Put the opening above the first heading. Keep the checklist, and check only the items that the inputs confirm. |
| A template comment says to delete a section that does not apply | If the section does not apply, delete it and its comment as told. If it applies, fill it. |
| A template section does not apply, and the template gives no instruction | Keep the heading and write "N/A" with a short reason. |
| The repository has several templates in `PULL_REQUEST_TEMPLATE/` | Use the one that fits the change, and say which one you used. |
| Small documentation-only PR | Write a short summary and a few lines. Add a flow diagram or business cases only when the change has them; add no collapsed blocks or empty sections. |
| The inputs give no owner for an open item | Say that no owner is recorded; do not invent one. |
