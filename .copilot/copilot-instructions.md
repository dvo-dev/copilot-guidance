Write explanations with approximately 80% adherence to ASD-STE100 Simplified Technical English.

## First implementation plans

Apply this before you write the first implementation plan for a code change that adds or changes an API, service, job, or data path. Also apply it when you write a kickoff that asks another session for such a plan. Skip it for documentation-only or trivial changes.

- Do this also when the issue, the kickoff, or I name a design. A named design is an input, not a decision.
- Search for existing entry points, operator or admin paths, and engine functions that already do part of the job. Record each relevant one with `file:line`, its known callers, and its contract. Do not write that no reusable path exists unless you also record the searches that you ran.
- Put each real option in one of these classes:
  - **Reuse, same requirements:** it meets all stated requirements.
  - **Reuse, changed requirements:** it is materially simpler, but it drops or weakens one or more stated requirements. List each change.
  - **New implementation:** state the requirement or risk that no existing path can meet.
- Classify with care:
  - A requirement limits behavior, not code. A change to shared code that keeps the protected behavior is a risk to test, not a requirement change.
  - A gap that a small change can close, such as a branch, a flag check, or a guard, is part of the reuse option. It is not a reason to reject the option.
  - Do not add an option only to reject it.
- Reject an option yourself only when it cannot do the core job, or when it breaks a mandatory safety, authorization, or isolation control. Give the concrete failure and its evidence. If the only cost of an option is weaker stated requirements, put it under "Decision needed" with its list of changes, also when you recommend a different option.
- For the recommended option and each reuse option, check real callers, automatic retries, authorization, impact, reversibility, and recovery. A different ingress can change the risk, but it does not remove mandatory safety, authorization, or isolation controls.
- Put an "Alternatives" section before the task list. Show only real options; do not add options to reach a number. If the recommendation needs a requirement change, ask me before implementation.
- In a kickoff, quote my request and do not prescribe an architecture that I did not ask for. Tell the planning session to do these steps.

```markdown
## Alternatives
Searched: <queries and paths>
| Option | Class | Evidence (`file:line`) | Requirement changes | Callers, retries, auth, recovery | Cost |
Recommendation: <option>, because <reason>.
Decision needed: <each "reuse, changed requirements" option and its changes, or none>.
```

## Workflow documentation for this repository

Apply this section only in `dvo-dev/copilot-guidance`, and only when a task adds
or changes `docs/skill-workflows.md` or `docs/skill-workflows/<skill>.md`.

- Treat `skills/<name>/SKILL.md` as the canonical source. `.github/skills` is a
  discovery alias, not a second copy to edit or link. When a linked skill
  changes, check its workflow page and the coordinator phase table for drift.
- Keep the `plan-to-pr` page as the factory overview. Show every coordinator
  phase, one primary path, and material stop, approval, ownership, or rework
  branches. Move secondary variants and implementation detail to prose or a
  table.
- Name the human workflow connector the "meat proxy" in this factory overview,
  and define the term once as a human reviewer or decision maker.
- Give each delegated skill one focused page. State its trigger and result,
  show one primary Mermaid flow, then stop at each delegated-skill call. Link
  to the delegated page. Name a return only when a caller consumes it, and show
  verified writes or other side effects with their actor and conditions. Do not
  infer state change only because a call occurred.
- Each focused page must link back to the coordinator overview and to its
  canonical `skills/<name>/SKILL.md`.
- Reuse one clear synthetic case across related pages. Label the case and its
  output as fictional. If the skill produces a human-readable artifact, show a
  synthetic output or walkthrough.
- Put long synthetic output in `<details>` with one descriptive `<summary>`.
  Keep the core workflow visible. Put a blank line after `<summary>` and before
  `</details>`. Inside `<details>`, start with
  `**Synthetic example:**`; do not use GitHub alert syntax there because
  GitHub renders it as a normal blockquote with the `[!NOTE]` token visible.
  Top-level alerts may use GitHub alert syntax.
- Use Mermaid and keep one visual system. Copy the current `init` line and
  `classDef` set from `docs/skill-workflows.md`; do not maintain copied numeric
  values here. Use rounded nodes for stages, hexagons for skill or subagent
  invocations, diamonds for decisions, stadium or pill nodes for human
  outcomes, muted terminal nodes for stops, and dashed edges for optional or
  manual paths. Use solid edges for control flow or calls. Label dashed
  edges with their role, such as optional step, manual loop, or data feed.
  Avoid shadows and gradients.
- Keep calls, returned values, and side effects distinct. A returned field is
  not a call, and a producer's field does not prove that a consumer reads or
  enforces it.

### Mermaid links on GitHub

GitHub renders Mermaid in an isolated Viewscreen iframe. Node links therefore
do not inherit the enclosing Markdown file's document path, repository, or
ref. Do not use relative `<a href>` or relative `click` targets in Mermaid
nodes.

- Use ordinary relative Markdown links beside the diagram for same-ref
  navigation. Keep these links even when a node is clickable.
- If a node itself must be clickable, use the verified absolute
  `<a href="https://...">` label pattern. Before relying on it, inspect the
  rendered result in the target host or report that interaction is unverified.
- The current Mermaid node links are pinned to this repository's `main` branch
  because GitHub cannot provide a document-relative node destination. They may
  return 404 while the target file exists only in the draft PR branch. Place a
  top-level `[!WARNING]` immediately before every Mermaid diagram that contains
  a `main` node link. State the 404 tradeoff and keep the relative Markdown
  fallback.
- A `main` URL is not ref-aware. A branch URL is temporary, and a commit URL is
  immutable but frozen. Choose and explain the destination rather than calling
  it "document-relative."
- Before accepting a pre-merge 404 for a `main` URL, verify the exact path and
  heading against the proposed working tree and confirm that the target is
  new to `main`. A misspelled or wrong target is broken, not an expected 404.

### Documentation checks

- Check Mermaid init JSON, node/class assignments, Mermaid and Markdown link
  targets, code-fence balance, `<details>` balance, and relative source links.
- Static checks do not prove rendering. When a rendered GitHub view is
  available, inspect node links, `<details>`, diagrams, and synthetic callouts.
  Otherwise, report renderer behavior as unverified. Do not push only to run
  this check.

## Pull request descriptions

- When you write a pull request description, use `/pr-descriptions` to make it clear and easy for people to read.
