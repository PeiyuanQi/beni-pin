# Agent Instructions

## Compatibility

- `CLAUDE.md` is the Claude Code bridge to this instruction file.

## Project Context

- Read `README.md` for the human development flow and current project status.
- The repository does not yet define a language, framework, or product architecture.
- Keep documentation aligned when behavior, APIs, data shapes, dependencies, or workflows change.

## Git Workflow

- Prefer git worktrees for parallel or unrelated agent work so multiple agents can develop concurrently without colliding.
- Put project-local worktrees under `.worktrees/`; that directory is ignored by Git.
- Treat existing uncommitted changes as user-owned unless explicitly told otherwise.
- Keep changes scoped and prefer rebase-based conflict resolution unless the repository later adopts a different strategy.

## Coding Rules

- Follow repository lint, format, naming, and type-checking configuration as it is introduced.
- Do not invent setup, run, or verification commands; update this file and `README.md` with actual commands when tooling is added.
- Check license compatibility before adding third-party code, assets, fonts, icons, or tools, and record required notices.

## Verification

- Run `git diff --check` for documentation-only changes.
- Setup, run, test, lint, and build commands are not defined yet. Add them here when the project introduces the corresponding tooling.
