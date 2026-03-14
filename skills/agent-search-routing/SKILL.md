---
name: agent-search-routing
description: Choose between Exa, Tavily, and Brave for AI-agent search tasks in OpenClaw, Claude Code, and Codex CLI. Use when Codex needs to route web search, technical research, documentation lookup, fact lookup, GitHub search, or paper search to the right backend. Brave is the configured OpenClaw web search tool, while Exa and Tavily are MCP-backed options. This skill only decides which search source to use; it does not install, configure, or orchestrate searches.
---

# Agent Search Routing

Classify the request by intent before choosing a search backend. Keep this skill narrow: decide which search source to use, then stop.

## Routing Order

1. If the request is technical research, use `Exa`.
2. Otherwise, if the request needs a direct answer from clean web results, use `Tavily`.
3. Otherwise, use OpenClaw's configured web search tool, `Brave`.

## Intent Guide

### Use `Exa`

Choose `Exa` for technical-source discovery:

- API docs
- SDK usage
- GitHub repositories
- papers and Arxiv
- implementation patterns
- developer blogs

### Use `Tavily`

Choose `Tavily` for direct question answering from web content:

- fact lookup
- summaries
- comparisons
- background explanations
- concise web-backed answers

### Use `Brave`

Choose `Brave` for broad web discovery:

- general websites
- brands
- products
- news
- latest information
- broad current-web discovery

## Boundary Rules

- A question about docs, repositories, or papers still routes to `Exa`.
- The word `research` alone does not force `Exa`; broad market or news discovery stays with `Brave`.
- Requests centered on `latest`, `today`, `news`, or broad current-web discovery default to `Brave`.

See `references/search-routing.md` for examples and quick comparisons.
