---
name: workspace-organizer
description: Organize and manage a workspace directory structure. Use this skill whenever the user mentions the workspace being messy, files needing categorization, creating git repos, configuring .gitignore, cluttered project directories, misplaced files, or even just casually says "help me tidy this up". Must trigger for any task involving workspace file organization, directory normalization, or version control initialization — even if the user doesn't explicitly say "organize".
---

# Workspace Organization Guide

## Core Principles

### 1. Dynamic Project Root Identification
Always identify the target workspace/project root directory before starting. Do not assume paths like `~/.openclaw/workspace/`. Use the environment's current working directory or ask the user to specify the root.

### 2. Keep the Root Directory Minimal

The root directory is the entry point of the workspace. Files piling up here make the entire workspace hard to maintain. Only essential root-level files belong here (e.g., `README.md`, `LICENSE`, global configuration files).

Everything else goes into subdirectories: project code, temp files, caches, logs, config files, and dependency directories do not belong in the root.

### 3. Categorize Files Into Subdirectories (Flexible Taxonomy)

Propose a taxonomy that fits the context of the specific project. A general AI workspace might look like this:

```
<workspace_root>/
├── docs/              # Documentation
├── skills/            # Skill projects
├── plugins/           # Plugin projects
├── projects/          # Application code
├── scripts/           # Utility scripts
├── data/              # Data files
├── logs/              # Log files
├── memory/            # Daily memory logs
├── config/            # Configuration files
└── archive/           # Archived files
```
*Note: Adapt these directories based on what files actually exist in the workspace.*

### 4. Each Module Gets Its Own Git Repo — No Root-Level Git

Never create a `.git` repo in a global workspace root containing independent projects. The right approach is for each functional module to have its own git in its own subdirectory. This keeps each module independently versioned.

> If a `.git` already exists in the root, leave it — don't delete it. Just start new modules in subdirectories going forward.

### 5. Configure .gitignore for Every Git Repo

A repo without `.gitignore` is prone to accidentally committing caches, secrets, and large files. Create `.gitignore` immediately after initializing any git repo.

### 6. Preserve Executability — Moving Is Not Enough

**Moving a file is not done until the code still runs.** A reorganized workspace that breaks scripts is worse than a messy one.

Before moving anything, audit what references what. After moving, fix every broken reference. After fixing, verify by actually running the code. Only then is the move complete.

Common breakage categories:
- **Relative paths in scripts** (`../config.json`, `./data/` → no longer valid after moving)
- **Hardcoded absolute paths** → stale
- **Interpreter/shebang lines** that rely on a specific working directory
- **Config files** that contain paths to other files (`settings.yaml`, `.env`, `pyproject.toml`, `package.json` `main`/`scripts` fields)
- **Import statements** in Python/Node that use relative paths
- **Cron jobs or systemd units** that reference the old path

---

## Execution Workflow

**IMPORTANT:** Always prefer utilizing native agent tools (e.g., `list_directory`, `glob`, `grep_search`, `write_file`, `replace`) over raw shell commands (like `ls`, `grep -r`, `cat >`) to prevent context overflow, handle large output safely, and ensure robust file modifications.

### Step 1: Analyze Current State
Use native tools (`list_directory`, `glob`) to identify:
- Files/directories that shouldn't be in the root
- Existing git repo locations (to avoid nested git issues)
- Which categorized subdirectories already exist

### Step 2: Propose Directory Structure
Based on the files found, propose a directory structure. 
Use native tools to create any missing directories (e.g., `run_shell_command("mkdir -p ...")`).

### Step 3: Pre-Move Audit — Find Path Dependencies
**Before moving anything**, scan for references that will break.
**WARNING:** Avoid running global `grep_search` across entire unignored workspaces as it may cause context overflow. Always use `exclude_pattern` (e.g., excluding `.git`, `node_modules`, `build`, caches) or target specific file types.

Use `grep_search` to find:
- Hardcoded paths referencing the current location
- Relative imports and path references (e.g., `from .`, `import .` in Python)
- Relative requires in Node (e.g., `require("./`)
- `scripts`/`main` fields in `package.json`

For each file being moved, record dependencies.

### Step 3.5: User Approval (Dry Run)
**CRITICAL:** Before executing any `mv` commands or modifying imports, present a summarized list of the planned moves and structural changes to the user and ask for explicit confirmation.

### Step 4: Move Files
Move files by type to their designated directories. Before moving, confirm no file with the same name exists at the destination to avoid overwrites. Use `run_shell_command` with safe `mv` commands.

### Step 5: Fix Internal References After Moving
For every file moved, update its internal path references using the `replace` tool.

**Config files that reference paths** (`pyproject.toml`, `package.json`, `.env`, `settings.yaml`):
- Update every path value to reflect the new location
- Pay attention to `scripts`, `main`, `include`, `exclude`, `entry` fields

*Note: Automated text replacement is fragile. Be aware of dynamic imports or aliases (like `@/components`) that may not be easily fixed by regex. Notify the user if complex AST-level refactoring is required.*

### Step 6: Verify Execution After Moving
**Do not skip this.** Actually run the scripts and code after moving and fixing paths using `run_shell_command`.

If a script fails after moving:
1. Read the error — it will tell you exactly which path it can't find
2. Fix that specific reference
3. Re-run until it passes
4. Only then proceed to the next file

### Step 7: Initialize Git and .gitignore
Initialize Git for new modules and use the `write_file` tool to create a `.gitignore` to exclude caches, dependencies, and sensitive information (`.env`, `*.key`).

### Step 8: Initial Commit
Use `run_shell_command` to stage files, confirm status, and create the initial commit.

---

## Completion Checklist

**Structure:**
- [ ] Root contains only essential top-level files.
- [ ] All code is in corresponding subdirectories.
- [ ] No dangerous `.git` setups in the root (or existing ones left untouched).
- [ ] Each functional module has its own `.git` and `.gitignore`.
- [ ] Sensitive files (`.env`, `*.key`) are excluded via `.gitignore`.

**Executability (must verify, not assume):**
- [ ] Pre-move audit completed and User Approved.
- [ ] All internal path references updated in moved files.
- [ ] All moved scripts/programs actually executed successfully after moving.
- [ ] Any temporary symlinks documented and scheduled for removal.
- [ ] No stale path references remain.

**Version control:**
- [ ] All changes committed.
