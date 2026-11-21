# Repository Copilot instructions

## Workflow documentation

Apply this section when a task changes `docs/skill-workflows.md`,
`docs/skill-workflows/<skill>.md`, or a canonical `skills/<name>/SKILL.md` that
has a workflow page.

- Treat `skills/<name>/SKILL.md` as the canonical source. `.github/skills` is a
  discovery alias, not a second copy to edit or link. When a canonical skill
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
- Use Mermaid and keep one visual system. Copy the current `init` line from
  `docs/skill-workflows.md`, and use only the canonical class definitions from
  its `classDef` block. A diagram may omit classes it does not use, but a reused
  class name must keep the same value. Use rounded nodes for stages, hexagons
  for skill or subagent invocations, diamonds for decisions, stadium or pill
  nodes for human outcomes, muted terminal nodes for stops, and dashed edges
  for optional or manual paths. Use solid edges for control flow or calls.
  Label dashed edges with their role, such as optional step, manual loop, or
  data feed. Avoid shadows and gradients.
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
