# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository contains OpenClaw skills. Each skill lives in its own subdirectory with a `SKILL.md` file.

## Structure

```
openclaw-skills/
└── <skill-name>/
    └── SKILL.md    # The entire skill definition
```

## Making Changes

Each skill is fully defined by its `SKILL.md`. To edit a skill, edit that file directly.

**Frontmatter fields** (YAML at the top of `SKILL.md`):
- `name` — identifier for the skill
- `description` — the primary triggering mechanism; controls when the skill gets invoked by OpenClaw

The body of `SKILL.md` contains the instructions the AI follows when the skill is active.

## Adding a New Skill

Create a new subdirectory and add a `SKILL.md` with frontmatter and body:

```
openclaw-skills/<new-skill-name>/SKILL.md
```

Skill directory names should use kebab-case and match the `name` field in frontmatter.
