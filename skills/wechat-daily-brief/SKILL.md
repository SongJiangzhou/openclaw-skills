---
name: wechat-daily-brief
description: Use when summarizing recent WeChat public account articles into a readable daily briefing, especially for requests about “recent 24 hours”, “today’s WeChat articles”, or saving a concise but thorough digest from WeWeRSS into Obsidian.
---

# WeChat Daily Brief

## Overview

Create a daily WeChat public account briefing for reading, not for database archiving.

Priorities:
- readability first
- important items first
- key points not omitted
- save into Obsidian as a date-based daily note

## Default Workflow

1. Pull articles from local WeWeRSS first.
2. If the user names sources, restrict to those public accounts.
3. Default window is the most recent 24 hours unless the user asks otherwise.
4. For each article, extract:
   - title
   - source
   - publish time
   - article id
5. Build the original article link as:
   - `[标题](https://mp.weixin.qq.com/s/<article_id>)`
6. Write or update the daily note at:
   - `projects/lv5railgun_vault/微信公众号/YYYY-MM-DD.md`
7. Reply with a concise chat summary after updating the note.

## Source Priority

Always use this order:
1. local WeWeRSS
2. public search / mirrors / public indexes
3. other supplementary public sources

Do not default to web search when WeWeRSS already has the needed articles.

## Output Standard

Optimize for daily reading.
Do not optimize for database structure.

Every important article should include:
- title
- source
- time
- Markdown hyperlink
- what the article is about
- key points
- why it is worth reading

Do not:
- merely repeat the title
- reduce the article to one vague sentence
- omit the key technical, product, or industry meaning

## Default Note Structure

Use this structure unless the user asks otherwise:

1. `今日总览`
   - summarize the main themes of the day

2. `今日最值得看`
   - usually 3-5 articles
   - these items should be the most detailed

3. `其他值得留意`
   - group remaining items by source or importance
   - still include a meaningful summary line

4. `今天真正值得记住的结论`
   - 3-5 takeaways
   - focus on what matters after reading everything

## Link Rules

Never use bare URLs in the Obsidian note.

Always use Markdown hyperlinks.

Preferred format:
- `[标题](url)`

Fallback only if needed:
- `[原文链接](url)`

## Obsidian Rules

Default directory:
- `projects/lv5railgun_vault/微信公众号/`

Default filename:
- `YYYY-MM-DD.md`

Default behavior:
- update the existing note for that date if it exists
- create it if it does not exist

## Writing Rules

Good output should be:
- easy to scan
- direct
- dense with useful information
- structured with clear hierarchy

Avoid:
- database-like field dumping
- long blocks of fluff
- overly academic wording
- excessive frontmatter
- splitting every article into a separate note by default

## Git Boundary

If the note is later committed or pushed, explicit user confirmation is still required.

Never push automatically.
