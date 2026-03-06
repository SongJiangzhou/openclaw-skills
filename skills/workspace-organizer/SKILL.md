---
name: workspace-organizer
description: Organize and manage the ~/.openclaw/workspace directory structure. Use this skill whenever the user mentions the workspace being messy, files needing categorization, creating git repos, configuring .gitignore, cluttered project directories, misplaced files, or even just casually says "help me tidy this up". Must trigger for any task involving workspace file organization, directory normalization, or version control initialization — even if the user doesn't explicitly say "organize".
---

# OpenClaw Workspace Organization Guide

## Core Principles

### 1. Keep the Root Directory Minimal

The root directory is the entry point of the workspace. Files piling up here make the entire workspace hard to maintain. Only the following files belong in the root:

- `AGENTS.md` - Workspace rules
- `SOUL.md` - AI persona
- `USER.md` - User profile
- `MEMORY.md` - Long-term memory index
- `HEARTBEAT.md` - Heartbeat config
- Necessary hidden files (`.openclaw`, etc.)

Everything else goes into subdirectories: project code, temp files, caches, logs, config files, and dependency directories (`node_modules`, `__pycache__`, etc.) do not belong in the root.

### 2. Categorize Files Into Subdirectories

```
~/.openclaw/workspace/
├── docs/              # Documentation (AGENTS/SOUL/USER etc.)
├── skills/            # Skill projects
├── plugins/           # Plugin projects
├── projects/          # Application code
├── scripts/           # Utility scripts
├── data/              # Data files
├── memory/            # Daily memory logs
├── config/            # Configuration files
└── archive/           # Archived files
```

### 3. Each Module Gets Its Own Git Repo — No Root-Level Git

Never create a `.git` repo in the workspace root. A root-level git means every subdirectory's changes get mixed together, leading to: unreadable commit history, a skill change polluting a plugin's diff, and no way to push individual modules to separate remotes.

The right approach is for each functional module to have its own git in its own subdirectory:

- `skills/my-skill/` has its own `.git`
- `plugins/my-plugin/` has its own `.git`
- `projects/my-app/` has its own `.git`

This keeps each module independently versioned, independently pushable, and fully isolated.

> If a `.git` already exists in the root, leave it — don't delete it. Just start new modules in subdirectories going forward.

### 4. Configure .gitignore for Every Git Repo

A repo without `.gitignore` is prone to accidentally committing caches, secrets, and large files. Create `.gitignore` immediately after initializing any git repo.

### 5. Commit Regularly

Commit after completing a feature, reorganizing directories, or modifying config. Commit message format:

```
<type>: <description>
```

Types: `feat` (new feature), `fix` (bug fix), `docs` (documentation), `refactor` (refactor), `chore` (misc)

---

## Execution Workflow

### Step 1: Analyze Current State

```bash
ls -la ~/.openclaw/workspace/
```

Identify:
- Files/directories that shouldn't be in the root
- Existing git repo locations (to avoid nested git issues)
- Which categorized subdirectories already exist

### Step 2: Create Directory Structure

Create any missing directories:

```bash
cd ~/.openclaw/workspace
mkdir -p docs skills plugins projects scripts data memory config archive
```

### Step 3: Move Files

Move by type:
- Documentation (`.md` files, guides) → `docs/`
- Skill projects → `skills/`
- Plugins → `plugins/`
- Application code → `projects/` or `scripts/`
- Data files → `data/`
- Config files → `config/`

Before moving, confirm no file with the same name exists at the destination to avoid overwrites.

### Step 4: Initialize Git for Each Module

```bash
cd skills/my-skill
git init
git checkout -b main
```

### Step 5: Create .gitignore

```bash
cat > .gitignore << 'EOF'
# Editor and system files
.vscode/
.idea/
.DS_Store
*.swp
*~

# Caches and dependencies
__pycache__/
*.pyc
.pytest_cache/
.ruff_cache/
node_modules/

# Logs and data
*.log
*.db
*.sqlite
*.parquet
*.lance
data/cache/

# Sensitive information
.env
.env.local
*.pem
*.key
EOF
```

### Step 6: Initial Commit

```bash
git add .
git status          # Confirm staged content looks right — no sensitive files included
git commit -m "chore: init repository"

git add .gitignore
git commit -m "chore: add .gitignore"
```

---

## Before / After Example

**Before (cluttered root):**
```
~/.openclaw/workspace/
├── .git/              <- root-level git, dangerous
├── my-skill.py        <- code scattered in root
├── plugin.js
├── notes.md
├── data.csv
└── .env               <- secrets exposed
```

**After (clean structure):**
```
~/.openclaw/workspace/
├── AGENTS.md
├── SOUL.md
├── skills/
│   └── my-skill/
│       ├── .git/      <- independent git
│       ├── .gitignore
│       └── my-skill.py
├── plugins/
│   └── my-plugin/
│       ├── .git/
│       └── plugin.js
├── docs/
│   └── notes.md
├── data/
│   └── data.csv
└── config/
    └── .env           <- excluded via .gitignore
```

---

## FAQ

**Q: There's already a .git in the root — what do I do?**
Leave it. Don't delete it. Start all new modules in subdirectories from here on.

**Q: A project has multiple submodules?**
Create a project directory under `projects/`, and give each submodule its own git or use git submodules.

**Q: Where do temporary files go?**
Create a `tmp/` directory and add `tmp/` to `.gitignore`.

**Q: How do I handle sensitive info (API keys)?**
Move them to `config/.env`, make sure `.env` is in `.gitignore`, and never commit secrets to git.

---

## Completion Checklist

```bash
ls ~/.openclaw/workspace/                                        # root has only doc files
find ~/.openclaw/workspace -name ".git" -maxdepth 3             # git repos are in subdirs
```

- [ ] Root contains only AGENTS.md / SOUL.md / USER.md / MEMORY.md etc.
- [ ] All code is in corresponding subdirectories (skills/ plugins/ projects/)
- [ ] No `.git` in root (or existing one left untouched)
- [ ] Each functional module has its own `.git`
- [ ] Each git repo has a `.gitignore` at its root
- [ ] Sensitive files (`.env`, `*.key`) are excluded via `.gitignore`
- [ ] All changes committed
