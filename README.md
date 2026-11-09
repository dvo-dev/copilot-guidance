# copilot-guidance

Reusable agent skills for code explanations, reviews, implementation planning,
and an agentic development pipeline.

## Install

With a GitHub CLI version that includes `gh skill`, install all skills for GitHub
Copilot at user scope:

```bash
gh skill install dvo-dev/copilot-guidance --all --agent github-copilot --scope user
```

## Update

```bash
gh skill update --dry-run
gh skill update --all
```

These commands check or update all installed skills, not just this repository's.
To update one skill, use its name, for example
`gh skill update visual-explanations`.

If you installed from the previous `.github/skills/` layout, reinstall once after
the new layout is available on the default branch to refresh the source metadata:

```bash
gh skill install dvo-dev/copilot-guidance --all --agent github-copilot --scope user --force
```

`--force` overwrites local edits to these skills; save any changes first. Start a
new agent session to load the updated skills.

## Development pipeline

Four skills turn an approved plan into a reviewed draft pull request and leave
the final decision to a human:

| Skill | What it does |
| --- | --- |
| `adversarial-review` | Has two isolated reviewers, the top Anthropic and top OpenAI models, independently review a change, plan, or batch of findings at the reasoning effort you choose. The agent verifies each finding before acting on it. |
| `review-fix-loop` | Runs the unit tests and fast checks, then iterates review and test-first fixes for 1 to 3 fix cycles. Every fix is re-reviewed. |
| `copilot-review-loop` | Opens a draft pull request and iterates with Copilot code review for 1 to 3 fix cycles. It triages findings with `adversarial-review`, fixes CI failures, replies to and resolves threads, requests a review of the final push without waiting for it, and posts a summary for human reviewers. |
| `plan-to-pr` | Chains the others: plan review, implementation, the local loop, a draft pull request, the Copilot loop, and a handoff. It passes your settings to each skill. |

### Settings

| Setting | Values | Default |
| --- | --- | --- |
| Reviewer effort (`adversarial-review`) | high, xhigh, max | xhigh |
| Copilot review effort (`copilot-review-loop`) | max, balanced (also called medium) | max |
| Fix cycles (each loop) | 1, 2, 3 | 3 |

Set them in your request, for example "run plan-to-pr with max reviewers and 2
fix cycles". For `plan-to-pr`, you can also add a line like
`Dev loop: reviewer effort max; fix cycles 2` to the plan, and you can keep
standing defaults in your personal or repository instructions. In an
interactive session, a skill you start yourself asks once whether to use the
defaults. Unattended runs, and skills called by other skills, never ask. Each
skill passes its settings to the skills it calls.

Requirements:

- An agent host that can launch subagents on both Anthropic and OpenAI models,
  with per-subagent model and reasoning-effort settings, such as GitHub Copilot
  CLI or the GitHub Copilot app.
- GitHub CLI authenticated with permission to push, open pull requests, request
  reviews, comment, resolve review threads, and rerun failed workflow runs.
- Copilot code review available for the repository. Max effort is in public
  preview. When the selected level is unavailable, the loop falls back to the
  highest available level below it and says so in its summary.

`plan-to-pr` starts when you ask for it, and when the session that owns an
approved, code-changing plan begins implementing it. To make the automatic
start reliable, add a line like this to your personal Copilot instructions:

```text
When a top-level session starts implementing an approved plan that changes code, invoke the plan-to-pr skill if it is available, unless I say "without plan-to-pr". For adversarial-review, I require the reviewer slots to use the top Anthropic and top OpenAI models at the reasoning effort the skill resolves; always pass the model and effort explicitly.
```

## Repository layout

The canonical sources live in `skills/<name>/SKILL.md`, where `gh skill` can
discover them without `--allow-hidden-dirs`. `.github/skills` is a relative symlink
to `../skills`, preserving repository-local discovery without duplicate files.
Edit the files under `skills/`.

If your checkout cannot materialize symlinks, install from the local sources
instead:

```bash
gh skill install . --from-local --all --agent github-copilot --scope user
```

Validate the skill layout and frontmatter without publishing:

```bash
gh skill publish --dry-run
```
