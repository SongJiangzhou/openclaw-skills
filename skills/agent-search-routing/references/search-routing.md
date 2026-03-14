# Search Routing Reference

Use this reference when the routing choice is ambiguous. Keep `SKILL.md` short and use this file for examples.

## Quick Comparison

| Search | Type | Strength | Weakness | Best For |
| --- | --- | --- | --- | --- |
| Exa | AI semantic search | strong technical relevance | higher cost | technical research |
| Tavily | LLM-optimized search | clean summaries | narrower coverage | direct QA |
| Brave | traditional web search | broad coverage | noisier results | general discovery |

## Exa

### What It Is

`Exa` is an AI-first search tool with strong semantic matching for technical material.

### When To Use It

Use `Exa` when the goal is to find technical sources, not just answer a question quickly.

- documentation
- GitHub repositories
- SDK or API usage
- implementation writeups
- papers and research content

### When Not To Use It

Do not default to `Exa` for broad news discovery, brand lookup, or generic current-events search.

### Examples

- "Find docs for FastMCP authentication."
- "Search GitHub for an Obsidian CLI tool."
- "Find papers on retrieval-augmented agents."

## Tavily

### What It Is

`Tavily` is an LLM-oriented web search that returns results already shaped for answer generation.

### When To Use It

Use `Tavily` when the user wants a quick web-backed answer from relatively clean summaries and content.

- direct questions
- comparisons
- summaries
- explainers
- fast fact lookup

### When Not To Use It

Do not prefer `Tavily` when the real task is technical-source discovery or broad web exploration.

### Examples

- "What is MCP and how is it different from function calling?"
- "Summarize the current state of AI agent frameworks."
- "What does this company do?"

## Brave

### What It Is

`Brave` is the general-purpose web search tool already configured in OpenClaw.

### When To Use It

Use `Brave` when coverage matters more than semantic ranking or answer-ready summaries.

- official websites
- brands
- products
- pricing pages
- news
- latest information

### When Not To Use It

Do not prefer `Brave` when the request is clearly about technical docs, repositories, or papers.

### Examples

- "Find the latest news about Anthropic."
- "Search for the official website of this startup."
- "Look up pricing pages for note-taking apps."

## Edge Cases

- "How do I use FastMCP with Claude Code?" -> `Exa`
This is phrased as a question, but the user is really asking for technical documentation.

- "Research AI note-taking tools launched this month." -> `Brave`
The word `research` appears, but the task is broad market discovery and current-web coverage.

- "What changed in the latest MCP ecosystem discussion?" -> `Brave`
The request is about current information, not technical-source discovery.
