# Agent Search Routing Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a new `agent-search-routing` skill that guides OpenClaw, Claude Code, and Codex CLI to choose between `Exa`, `Tavily`, and `Brave` based on search intent.

**Architecture:** Build a documentation-only skill with one concise `SKILL.md`, one supporting reference file, and generated UI metadata. Keep the implementation narrow: route by intent, document boundary cases, and avoid execution/orchestration logic.

**Tech Stack:** Markdown, YAML, Git, `/home/lv5railgun/.codex/skills/.system/skill-creator/scripts/init_skill.py`, `/home/lv5railgun/.codex/skills/.system/skill-creator/scripts/generate_openai_yaml.py`, `/home/lv5railgun/.codex/skills/.system/skill-creator/scripts/quick_validate.py`

---

## File Map

- Create: `skills/agent-search-routing/SKILL.md`
- Create: `skills/agent-search-routing/references/search-routing.md`
- Create: `skills/agent-search-routing/agents/openai.yaml`
- Modify: `docs/superpowers/specs/2026-03-15-agent-search-routing-design.md` only if the implementation reveals a design gap
- Reference only: `/home/lv5railgun/.codex/skills/.system/skill-creator/references/openai_yaml.md`

## Chunk 1: Initialize the Skill Skeleton

### Task 1: Create the skill directory with the expected layout

**Files:**
- Create: `skills/agent-search-routing/SKILL.md`
- Create: `skills/agent-search-routing/references/`
- Create: `skills/agent-search-routing/agents/openai.yaml`

- [ ] **Step 1: Confirm the target path is unused**

Run: `test ! -e skills/agent-search-routing && echo OK`
Expected: `OK`

- [ ] **Step 2: Read the OpenAI agent metadata reference**

Run: `sed -n '1,220p' /home/lv5railgun/.codex/skills/.system/skill-creator/references/openai_yaml.md`
Expected: Field descriptions for `display_name`, `short_description`, and `default_prompt`

- [ ] **Step 3: Initialize the new skill with references support**

Run:

```bash
.venv/bin/python /home/lv5railgun/.codex/skills/.system/skill-creator/scripts/init_skill.py \
  agent-search-routing \
  --path skills \
  --resources references \
  --interface display_name="Agent Search Routing" \
  --interface short_description="Route search requests to Exa, Tavily, or Brave based on intent." \
  --interface default_prompt="Choose the right search backend for this request."
```

Expected: A new `skills/agent-search-routing/` directory containing `SKILL.md`, `references/`, and `agents/openai.yaml`

- [ ] **Step 4: Inspect generated files before editing**

Run: `find skills/agent-search-routing -maxdepth 3 -type f | sort`
Expected: `SKILL.md`, `references/` contents if any, and `agents/openai.yaml`

- [ ] **Step 5: Commit the initialized skeleton**

```bash
git add skills/agent-search-routing
git commit -m "feat: initialize agent-search-routing skill"
```

## Chunk 2: Write the Routing Guidance

### Task 2: Replace template content in `SKILL.md`

**Files:**
- Modify: `skills/agent-search-routing/SKILL.md`

- [ ] **Step 1: Write a failing content checklist**

Add this checklist as a temporary local note or working scratch:

```text
- frontmatter uses only name + description
- description triggers on search-tool selection tasks
- body stays focused on routing only
- body points to references/search-routing.md
```

Expected: A concrete checklist to validate the finished file against the design

- [ ] **Step 2: Rewrite the frontmatter**

Write frontmatter with:

```yaml
---
name: agent-search-routing
description: Choose between Exa, Tavily, and Brave for AI-agent search tasks in OpenClaw, Claude Code, and Codex CLI. Use when Codex needs to route web search, technical research, documentation lookup, fact lookup, GitHub search, or paper search to the right backend. Brave is the configured OpenClaw web search tool, while Exa and Tavily are MCP-backed options. This skill only decides which search source to use; it does not install, configure, or orchestrate searches.
---
```

Expected: No extra frontmatter keys

- [ ] **Step 3: Write the minimal routing body**

Include:

```md
# Agent Search Routing

Classify the request by intent before choosing a search backend.

## Routing Order

1. If the user needs technical research, use `Exa`.
2. Otherwise, if the user needs a direct answer from clean web results, use `Tavily`.
3. Otherwise, use OpenClaw's configured web search tool, `Brave`.

## Intent Guide

### Use `Exa`
- technical docs
- API/SDK usage
- GitHub repos
- papers
- developer blogs

### Use `Tavily`
- direct questions
- comparisons
- summaries
- background explanations

### Use `Brave`
- general web discovery
- brands
- products
- news
- latest information

## Boundary Rules

- A question about docs, repos, or papers still routes to `Exa`.
- The word `research` alone does not force `Exa`; broad market/news discovery stays with `Brave`.
- Requests centered on `latest`, `today`, or `news` default to `Brave`.

See `references/search-routing.md` for examples and comparisons.
```

Expected: The body remains under roughly 150 lines and contains no execution instructions

- [ ] **Step 4: Review the finished file**

Run: `sed -n '1,220p' skills/agent-search-routing/SKILL.md`
Expected: Clean frontmatter and concise routing instructions

- [ ] **Step 5: Commit the routing guide**

```bash
git add skills/agent-search-routing/SKILL.md
git commit -m "feat: add agent-search-routing skill guidance"
```

### Task 3: Write the supporting reference document

**Files:**
- Modify: `skills/agent-search-routing/references/search-routing.md`

- [ ] **Step 1: Create the comparison table**

Add a table covering:

```md
| Search | Type | Strength | Weakness | Best For |
| --- | --- | --- | --- | --- |
| Exa | AI semantic search | technical relevance | higher cost | technical research |
| Tavily | LLM-optimized search | clean summaries | narrower coverage | direct QA |
| Brave | traditional web search | broad coverage | noisier results | general discovery |
```

Expected: A fast visual summary that matches the approved design

- [ ] **Step 2: Add short sections for each engine**

Cover:
- what it is
- when to use it
- when not to use it

Expected: Three compact sections, one for each engine

- [ ] **Step 3: Add examples by intent**

Include at least:
- three `Exa` examples
- three `Tavily` examples
- three `Brave` examples
- three edge cases

Expected: Another agent can resolve ambiguous routing questions without expanding SKILL.md

- [ ] **Step 4: Review the reference file**

Run: `sed -n '1,260p' skills/agent-search-routing/references/search-routing.md`
Expected: A compact reference with examples, not a long market report

- [ ] **Step 5: Commit the reference**

```bash
git add skills/agent-search-routing/references/search-routing.md
git commit -m "docs: add search routing reference"
```

## Chunk 3: Generate Metadata and Validate

### Task 4: Ensure `agents/openai.yaml` matches the finished skill

**Files:**
- Modify: `skills/agent-search-routing/agents/openai.yaml`

- [ ] **Step 1: Regenerate UI metadata from the finished skill**

Run:

```bash
.venv/bin/python /home/lv5railgun/.codex/skills/.system/skill-creator/scripts/generate_openai_yaml.py \
  skills/agent-search-routing \
  --interface display_name="Agent Search Routing" \
  --interface short_description="Route search requests to Exa, Tavily, or Brave based on intent." \
  --interface default_prompt="Choose the right search backend for this request."
```

Expected: `skills/agent-search-routing/agents/openai.yaml` reflects the final skill state

- [ ] **Step 2: Inspect the generated metadata**

Run: `sed -n '1,220p' skills/agent-search-routing/agents/openai.yaml`
Expected: The file contains the provided interface values and no stale template content

- [ ] **Step 3: Validate the whole skill**

Run:

```bash
.venv/bin/python /home/lv5railgun/.codex/skills/.system/skill-creator/scripts/quick_validate.py \
  skills/agent-search-routing
```

Expected: Validation passes with no errors

- [ ] **Step 4: Do a final repository diff review**

Run: `git diff --stat HEAD~3..HEAD`
Expected: Only the new skill files and intended documentation changes appear

- [ ] **Step 5: Commit the validated skill**

```bash
git add skills/agent-search-routing/agents/openai.yaml
git add skills/agent-search-routing
git commit -m "feat: finalize agent-search-routing skill"
```

## Chunk 4: Handoff Checks

### Task 5: Verify the skill is ready for use

**Files:**
- Review: `skills/agent-search-routing/SKILL.md`
- Review: `skills/agent-search-routing/references/search-routing.md`
- Review: `skills/agent-search-routing/agents/openai.yaml`

- [ ] **Step 1: Re-read the design and compare against the implementation**

Run: `sed -n '1,260p' docs/superpowers/specs/2026-03-15-agent-search-routing-design.md`
Expected: No mismatch between design scope and implementation

- [ ] **Step 2: Verify the working tree is clean**

Run: `git status --short`
Expected: No output

- [ ] **Step 3: Prepare a short handoff summary**

Include:
- created files
- routing rule summary
- validation command used

Expected: A concise final note for the next implementer or reviewer
