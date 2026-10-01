# OrcLife

**Orc**hestrated software development **Life**cycle for [Claude Code](https://claude.com/claude-code).

OrcLife runs one ticket as a small team of Claude Code sessions, each with one role, each in the ticket's own git worktree. A shell CLI (`orclife`), a set of hooks, two agents and two skills hold the sessions to the same rules: a gate before every push, one owner of the tree at a time, written handoffs between roles, and evidence attached to every review.

It knows nothing about any particular project. Everything project-specific lives in one untracked file per repository: `.local/orclife.json`.

## Roles

A ticket gets one terminal tab per session, managed through herdr.

| Role | Owns | Never |
|---|---|---|
| Orchestrator | The user's entry point. Environment, starting sessions, routing findings, PRs | Explores, writes specs or code, reviews |
| Propose | Exploration, grilling, the proposal artifacts | Writes code, reviews its own proposal |
| Apply | Implementing the committed proposal, the gate, fixes for review findings | Changes what the proposal means |
| Review | Reviewing the proposal and the code, the verifier, the findings report | Fixes what it finds |

Ownership moves forward only: propose, then apply, then review until merge. Only the owner edits the tree.

## What it enforces

- **Gate:** `orclife gate` runs the project's gate command and marks the exact tree. `git push` is refused without a fresh marker; `git merge` is always refused.
- **Test lock:** edits to test files are blocked unless `orclife test-lock on` is set for the worktree.
- **Handoffs:** `orclife handoff write` creates a handoff that already carries the receiving role's rules. A handoff read once is archived.
- **Evidence:** `orclife evidence` writes the diff's blast radius and affected tests to one file that every review pass and the verifier read.
- **Discoveries:** `/discover` records a rule learned on one ticket so later sessions don't relearn it.

`orclife help` lists every command.

## Requirements

Required: Claude Code, git, bash, [jq](https://jqlang.org), [gh](https://cli.github.com), herdr.

Optional:
- codegraph and codebase-memory-mcp, for `orclife evidence`
- Docker Compose, for a per-worktree stack (`orclife worktree up <ticket> --stack`)
- [direnv](https://direnv.net), for a per-repository GitHub account

## Install

```bash
git clone https://github.com/Umbra-Productions-Development/OrcLife.git
cd OrcLife && ./install.sh
```

`install.sh` links `orclife` into `~/.local/bin`, links the hooks, skills and agents into `~/.claude`, and registers the hooks in `~/.claude/settings.json`. It is idempotent; run it again after pulling.

## Quickstart

In the repository you want to work on:

```bash
mkdir -p .local && cp /path/to/OrcLife/orclife.example.json .local/orclife.json
# edit .local/orclife.json, then make sure .local/ is ignored by git
orclife worktree up ABC-123
```

Open Claude Code in the worktree. The SessionStart hook prints the session's context and points it at the `orclife` skill.

## Configuration

`.local/orclife.json`, one per repository, never committed.

| Key | What |
|---|---|
| `project` | Short project name, used in session names when no ticket applies |
| `sharedLocal` | Absolute path to the main checkout's `.local`, shared by every worktree |
| `baseBranch` | Branch new worktrees start from |
| `gate` | Command that must pass before a push |
| `testCommand` | Test runner `test-affected` calls with the affected files |
| `testGlob` | Regex for test file paths (test lock, affected tests) |
| `sourceGlob` | Regex for source file paths |
| `protectedBranches` | Branches no session may commit to |
| `ticketPattern` | Regex for ticket ids in paths and branch names |
| `roles` | Map of tab labels to role names |
| `reviewPasses` | Extra review passes: a skill, an agent, or `{"pass", "when"}` to run on matching paths only |
| `envFiles` | Env files linked into each worktree |
| `envCommand` | Command printing the worktree stack's env vars for the gate |
| `composeDir` | Directory holding the compose file for worktree stacks |
| `seedVolume` | Docker volume a worktree's database is seeded from |
| `migrateCommand` | Command run after a worktree stack starts |
| `prShareLimit` | Size under which small changes may share one PR |
| `consultantKb` | Knowledge base directory for the legacy consultant agent |
| `discoveriesDir` | Directory under `sharedLocal` holding discoveries |
| `handoffArchiveDays` | Days before consumed handoffs are archived |

## Contributing

See [PROJECT_PLAN.md](PROJECT_PLAN.md) for goals, rules and how changes land.

## License

[Apache-2.0](LICENSE)
