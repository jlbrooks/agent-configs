---
name: omnifocus
description: >-
  Query Jacob's OmniFocus tasks via synced SQLite database.
  Use when asked about tasks, todos, what's due, inbox, projects,
  or anything related to OmniFocus or task management.
---

## Setup

Database syncs every 5 minutes from Omni Sync Server.

```bash
cd ~/projects/omnifocus-sync
.venv/bin/python query_db.py <command> [options]
```

## Common Queries

### Available Tasks (main perspective)
```bash
.venv/bin/python query_db.py tasks --due --limit 20
```

### Inbox
```bash
.venv/bin/python query_db.py tasks --inbox
```

### Flagged
```bash
.venv/bin/python query_db.py tasks --flagged
```

### Recently Completed
```bash
.venv/bin/python query_db.py sql "SELECT name, date_completed FROM Task WHERE date_completed IS NOT NULL ORDER BY date_completed DESC LIMIT 20"
```

### Tasks Due Soon
```bash
.venv/bin/python query_db.py sql "SELECT name, date_due FROM Task WHERE date_due IS NOT NULL AND date_completed IS NULL ORDER BY date_due LIMIT 20"
```

### Projects
```bash
.venv/bin/python query_db.py projects
```

### Contexts/Tags
```bash
.venv/bin/python query_db.py contexts
```

## JSON Output

Add `--json` for structured output:
```bash
.venv/bin/python query_db.py --json tasks --inbox
```

## Direct SQL

For complex queries:
```bash
.venv/bin/python query_db.py sql "SELECT t.name, f.name as folder FROM Task t JOIN Folder f ON t.project_folder = f.id WHERE t.date_completed IS NULL LIMIT 10"
```

## Schema Reference

**Task**: id, name, parent_task, project_folder, context, inbox, flagged, date_added, date_modified, date_due, date_start, date_completed, estimated_minutes, rank, note, is_project, project_status, sequential, deleted

**Context**: id, name, parent, rank

**Folder**: id, name, parent, rank

**Perspective**: id, name, filter_rules, value_data

## Manual Sync

Force sync if needed:
```bash
cd ~/projects/omnifocus-sync
OMNISYNC_USER=jlbrooks OMNISYNC_PASS="$OMNISYNC_PASS" .venv/bin/python sync_omnifocus.py
```

Note: Password stored in `~/.config/omnifocus-sync/credentials`
