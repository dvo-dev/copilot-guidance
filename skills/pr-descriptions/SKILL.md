---
name: pr-descriptions
description: >-
  Write or restructure a pull request description that people can scan: a
  one- or two-sentence summary of the change's effect first, then what
  changed, open questions with their owners, and required steps, with
  supporting detail and decisions already made in named collapsed blocks.
  Keeps the repository's PR template and always uses visual-explanations for
  diagrams, tables, and alerts. Use when writing, updating, or restructuring a
  pull request description, including the draft PR body that
  copilot-review-loop writes.
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
- **The repository's PR template**, if there is one, such as
  `.github/pull_request_template.md`.
- **Sections that another skill requires**, such as copilot-review-loop's
  Needs human judgment, review summary, and hidden marker. That skill decides
  what they contain; this skill decides where they go and what stays visible.

## Order

1. **Summary.** One or two short, plain sentences that say what the change
   does and its effect: which inputs now give which results, for users or
   callers. A topic, event name, or ticket number alone is not a summary. Put
   nothing above it: no heading, alert, table, or template heading.
   - Topic only: "Handle webhook retry events. This is task 2.1."
   - Effect: "Failed webhook deliveries now retry up to three times with
     backoff. Deliveries that fail with a 4xx status still fail at once."
2. **Pointer to open items**, when there are any: one line that gives their
   number and links to the section that lists them.
3. **What changed and why**, as a short list with exact names (files,
   sections, functions, settings).
4. **Open items** that need a person, such as Needs human judgment. Give each
   one visible line: what to decide, who decides, and what the PR does until
   then.
5. **Testing, review, and how the change was produced**, each kept short.

With a repository PR template, keep its headings in their order. Put the
summary and the pointer above the first heading; if that heading is a summary
heading, such as "Summary", put the summary under it instead. Put each item
under the heading that matches it best, and put open items under the heading
for reviewer attention, if there is one. Put the rest after the template. Do
not add empty sections.

## Visible and collapsed

- **Keep visible** what a reviewer needs on the first read, in one or two
  lines for each point: the summary, what changed, open questions and open
  risks with their owners, and steps that a person must do, such as a deploy
  order.
- **Collapse supporting detail** into `<details>` blocks: the reasons and
  evidence for a point, decisions already made (including accepted risks),
  diagrams, case tables, file lists, test output, and review history.
  Collapse a part only when it is longer than about five lines; leave shorter
  parts visible, so a small PR often has no collapsed blocks.
- Put each block under the heading that it supports, and give its
  `<summary>` a name that tells what is inside, such as "Retry flow: where a
  delivery stops". Put decisions already made in one block whose `<summary>`
  lists their topics, such as "Decisions already made: retry limit, backoff,
  4xx handling".
- **Never collapse** an open question, open risk, required step, or alert,
  even in a long list: shorten each item to one line, and collapse only its
  supporting detail.

Put a blank line after `</summary>` and before `</details>`, or the Markdown
inside does not render:

```markdown
<details>
<summary>Retry flow: where a delivery stops</summary>

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

```markdown
Failed webhook deliveries now retry up to three times with backoff.
Deliveries that fail with a 4xx status still fail at once.

[1 open question](#needs-human-judgment): set the retry limit per endpoint?

## What changed and why

- `sender.Deliver` retries timeouts and 5xx responses with jittered backoff.
- New setting `webhooks.max_retries`, default 3.

<details>
<summary>Retry flow: where a delivery stops</summary>

(decision tree)

</details>

## Needs human judgment

- **Set the retry limit per endpoint?** The API owners decide. Until then,
  one global limit applies.

<details>
<summary>Decisions already made: backoff, 4xx handling</summary>

(one line each, with its reason)

</details>

## Testing

`go test ./sender/...` passed.
```

## Walkthrough cases

| Input | Expected behavior |
| --- | --- |
| Any PR description | Invoke visual-explanations as well, before writing. |
| Long PR with flows, case tables, and test logs | Start with a summary of the effect. Keep open questions, open risks, and required steps visible; put each flow, table, and log in a named `<details>` block. |
| Many decisions already made and one open question | The pointer and the open-items section show the one open question. The decisions go in one block whose title lists their topics. |
| The repository has a PR template, and one question is open | Put the summary and the pointer above the template. Keep the headings in order, and put the open question under the heading for reviewer attention. |
| The template's first heading is "Summary" | Put the summary under that heading, not above it. |
| Small documentation-only PR | Write a short summary and a few lines, with no collapsed blocks or empty sections. |
| The inputs give no owner for an open item | Say that no owner is recorded; do not invent one. |
