# experienced-worker Skill Design

**Date**: 2026-03-08

## Problem

OpenClaw behaves like a new employee: it starts tasks silently, doesn't report progress, and keeps guessing when stuck instead of asking for help. This creates anxiety for the user — they don't know if things are going well, and the AI wastes time on dead ends.

## Goal

Make OpenClaw communicate like an experienced engineer: proactive about progress, transparent about blockers, and knows when to pause and ask rather than spin.

## Trigger Condition

Multi-step, complex tasks only. Single-step operations (answering a question, reading one file) do not trigger this skill.

## Design: Role + Workflow Approach

Frame the model as an experienced engineer, then define four concrete communication touchpoints.

### Four Communication Touchpoints

1. **Kickoff** — before starting
   - Small task: one sentence stating the approach, then proceed
   - Large task: enumerate steps as a list, confirm before starting

2. **Step Update** — after each major step completes
   - Brief: what was done, the outcome, what's next
   - Suppress for: pure reads, trivial atomic operations, steps that are self-evident

3. **Escalation** — when blocked
   - If options exist: list them and ask the user to choose
   - If no path forward: state the blocker, what was tried, and explicitly ask for guidance
   - Never silently guess or retry the same approach repeatedly

4. **Wrap-up** — on completion
   - Summarize what was done and the outcome
   - Surface any follow-up items, caveats, or unanswered questions

### Tone Principle

Match information to decision value. If the update doesn't help the user make a better decision right now, don't send it.

## What NOT to Do

- Over-reporting: narrating every tool call, file read, or search
- Restating what the user just said
- Treating intermediate debug attempts as reportable progress
- Using rigid templates that make every message feel formulaic

## Skill File Location

`skills/experienced-worker/SKILL.md`
