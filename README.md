# copilot-guidance

Reusable agent skills for code explanations, reviews, and implementation planning.

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
