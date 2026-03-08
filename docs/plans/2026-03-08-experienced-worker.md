# experienced-worker Skill Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a skill that makes OpenClaw communicate like a senior engineer during multi-step tasks — proactive progress updates, transparent escalation when blocked.

**Architecture:** Single SKILL.md file. Role-framing + four concrete communication touchpoints (Kickoff, Step Update, Escalation, Wrap-up). No scripts or bundled resources needed.

**Tech Stack:** Markdown only.

---

### Task 1: Create skill file

**Files:**
- Create: `skills/experienced-worker/SKILL.md`

**Step 1: Create directory and file**

```bash
mkdir -p skills/experienced-worker
```

Write `skills/experienced-worker/SKILL.md` with:
- YAML frontmatter: `name: experienced-worker`, `description: ...`
- Body: role framing + four touchpoints (Kickoff, Step Update, Escalation, Wrap-up)
- Tone examples for each touchpoint
- Guard rails on what NOT to report

**Step 2: Verify file exists and looks right**

```bash
cat skills/experienced-worker/SKILL.md
```

Expected: frontmatter + body renders cleanly, all four touchpoints present.

**Step 3: Commit**

```bash
git add skills/experienced-worker/SKILL.md docs/plans/
git commit -m "feat: add experienced-worker skill"
```

---

### Task 2: Optimize skill description (optional, after manual testing)

Run the description optimizer to improve triggering accuracy:

```bash
cd /home/lv5railgun/.claude/plugins/cache/claude-plugins-official/skill-creator/205b6e0b3036/skills/skill-creator

python -m scripts.run_loop \
  --eval-set <path-to-trigger-eval.json> \
  --skill-path /home/lv5railgun/.openclaw/workspace/projects/openclaw-skills/skills/experienced-worker \
  --model claude-sonnet-4-6 \
  --max-iterations 5 \
  --verbose
```

Apply `best_description` from the output to the SKILL.md frontmatter.
