# Agent Search Routing Design

## Goal

Create a narrow skill that helps OpenClaw choose between `Exa`, `Tavily`, and `Brave` for web search tasks.

The skill is only a routing guide. It does not install tools, configure MCP servers, manage credentials, orchestrate retries, or execute multi-step search pipelines.

## Context

- In OpenClaw, `Brave` is already exposed as the configured `web search` tool.
- `Exa` and `Tavily` are available through MCP integrations.
- The user wants a skill that maps query intent to the correct search backend in `AI Agent / OpenClaw / Claude Code / Codex CLI` workflows.

## Scope

### In Scope

- Detect when a request is a search-routing decision.
- Classify the request into one of three search intents.
- Recommend `Exa`, `Tavily`, or `Brave` based on that intent.
- Document a few high-value boundary cases.

### Out of Scope

- Executing the search.
- Combining multiple engines in one workflow.
- Fallback logic, retries, reranking, or cost optimization.
- Installation, authentication, MCP setup, or OpenClaw config changes.

## Recommended Skill Name

Use `agent-search-routing`.

Reasoning:

- It is short.
- It signals the skill is for agent decision-making, not generic search tips.
- It leaves room for future skills that might cover search execution or orchestration.

## Skill Structure

Create only the files that support routing decisions directly:

```text
agent-search-routing/
├── SKILL.md
├── agents/
│   └── openai.yaml
└── references/
    └── search-routing.md
```

No scripts or assets are needed because this skill does not perform execution.

## Trigger Strategy

The frontmatter description should trigger when Codex needs to decide which search tool to use for a user request involving:

- web search
- technical research
- fact lookup
- documentation discovery
- GitHub or paper search
- choosing between `Exa`, `Tavily`, and `Brave`

The description should also make the boundary explicit:

- `Brave` is the existing OpenClaw web search tool
- `Exa` and `Tavily` are MCP-backed options
- the skill chooses a tool based on intent and stops there

## Routing Model

Use intent-first routing rather than keyword-only routing.

### 1. Technical Research -> `Exa`

Pick `Exa` when the request is about finding high-quality technical sources rather than getting one quick answer.

Strong signals:

- GitHub repositories
- API docs
- SDK usage
- implementation patterns
- papers or Arxiv
- developer blogs
- semantic matching across technical content

Examples:

- "Find docs for FastMCP authentication"
- "Search GitHub for an Obsidian CLI tool"
- "Find papers on retrieval-augmented agents"

### 2. Direct QA / Fact Lookup -> `Tavily`

Pick `Tavily` when the request is best handled by retrieving concise web content that can be consumed directly by an LLM to answer a question.

Strong signals:

- direct questions
- comparison or summary requests
- fact lookup
- background explanations
- quick answer generation from clean web results

Examples:

- "What is MCP and how is it different from function calling?"
- "Summarize the current state of AI agent frameworks"
- "What does this company do?"

### 3. Broad Web Discovery -> `Brave`

Pick `Brave` when the request is general-purpose web search and broad coverage matters more than semantic ranking or LLM-optimized summaries.

Strong signals:

- general websites
- brands
- products
- news
- latest information
- broad discovery without a technical-research frame

Examples:

- "Find the latest news about Anthropic"
- "Search for the official website of this startup"
- "Look up pricing pages for note-taking apps"

## Boundary Rules

Keep boundary rules short and memorable:

1. A question does not automatically mean `Tavily`.
If the user is asking for technical docs, repositories, or papers, route to `Exa`.

2. The word `research` does not automatically mean `Exa`.
If the request is about general market/news discovery rather than technical sources, route to `Brave`.

3. Requests involving `latest`, `today`, `news`, or broad current-web discovery default toward `Brave`.

## Resource Design

### `SKILL.md`

Keep it concise and procedural:

- one-paragraph purpose
- the three-intent routing workflow
- the three engine choices
- the short boundary rules
- one pointer to `references/search-routing.md`

### `references/search-routing.md`

Store the richer material here:

- comparison table for `Exa`, `Tavily`, and `Brave`
- short descriptions of each engine
- examples for each intent bucket
- edge cases that commonly confuse routing

## Draft Content Direction

The final skill should read like a decision guide for another agent:

1. Decide whether the user wants technical research, direct question answering, or broad web discovery.
2. Choose `Exa`, `Tavily`, or `Brave`.
3. Stop after making the routing decision.

## Risks

- If the trigger description is too broad, the skill may activate on general research tasks where routing is not the real problem.
- If the rules lean too hard on question syntax, technical questions may be misrouted to `Tavily`.
- If the body becomes a long market comparison, it will waste context and weaken triggering.

## Implementation Notes

When implementation begins:

1. Initialize `agent-search-routing` with `references/` support.
2. Write `SKILL.md` as a short routing guide.
3. Write `references/search-routing.md` using the user's Exa/Tavily/Brave framing.
4. Generate `agents/openai.yaml`.
5. Validate the skill folder.
