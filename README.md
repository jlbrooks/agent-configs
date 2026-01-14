# agent-configs

Shared configuration for Claude Code and OpenAI Codex CLI.

## Setup

```bash
./setup.sh
```

This symlinks configs to their expected locations:

| Source | Destination |
|--------|-------------|
| `AGENTS.md` | `~/.codex/AGENTS.md`, `~/.claude/AGENTS.md` |
| `CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `.claude/settings.json` | `~/.claude/settings.json` |
| `.codex/config.toml` | `~/.codex/config.toml` (merged) |
| `commands/` | `~/.claude/commands/`, `~/.codex/prompts/` |
| `hooks/` | `~/.claude/hooks/` |

## Structure

```
├── AGENTS.md              # Shared agent instructions (both tools)
├── CLAUDE.md              # Imports AGENTS.md for Claude Code
├── commands/              # Slash commands (shared)
├── hooks/                 # Claude Code hooks
│   └── git_safety_guard.py
├── .claude/
│   └── settings.json      # Claude Code settings
├── .codex/
│   └── config.toml        # Codex config (model, features)
└── setup.sh               # Installer
```

## Notes

- `config.toml` is merged, not symlinked. Base settings come from repo; local project trust entries are preserved below the marker line.
- Run `./setup.sh` again after pulling updates to refresh configs.
