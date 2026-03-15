---
name: doubao-image-gen
description: Generate images with Doubao / Volcengine Ark image generation API using a local curl wrapper. Use when the user wants image generation through the Doubao Seedream model, especially for prompt-to-image generation with automatic download into the workspace, optional size selection, optional watermark control, and optional URL-only mode. Also use when creating PPT, slides, posters, documents, cover images, or other artifacts that need generated images saved as local files.
---

# Doubao Image Gen

Use the bundled curl wrapper to generate an image with Doubao / Volcengine Ark.

Default behavior:
- generate image
- download it into the workspace
- return both saved file path and source URL

## Inputs

- Required: `prompt`
- Optional: `size` (default `2K`)
- Optional: `watermark` (`false` by default)
- Optional: `output-dir` (default `/home/lv5railgun/.openclaw/workspace/data/generated-images`)
- Optional: `filename` (default auto-generated timestamp name)
- Optional: `url-only` (skip download and print only the URL)

Prefer defaults unless the user explicitly asks to change them.

## Environment

Read these environment variables:

- `ARK_API_KEY` — required
- `ARK_BASE_URL` — optional, default `https://ark.cn-beijing.volces.com/api/v3`

Do not hardcode secrets into commands or files.
Never echo `ARK_API_KEY`.

## Command

Run:

```bash
bash scripts/generate.sh --prompt '<prompt>' [--size 2K] [--watermark true|false] [--output-dir <dir>] [--filename <name>] [--url-only]
```

## Examples

Basic download:

```bash
bash scripts/generate.sh --prompt '一辆复古列车冲出黑洞，电影感，强冲击力，深蓝色调，超现实主义'
```

Explicit output directory and file name:

```bash
bash scripts/generate.sh --prompt '赛博朋克城市夜景，霓虹反射，雨夜街道，电影镜头感' --output-dir /tmp --filename city.png
```

URL only:

```bash
bash scripts/generate.sh --prompt '超现实主义海报' --url-only
```

## Output handling

- On success with download: print `saved:` and `url:` lines
- On success with `--url-only`: print the URL directly
- On failure: show the API error clearly
- Do not claim success if the response does not contain `.data[0].url`
- When downloading with default settings, validate that the downloaded file is actually `image/png`

## Notes

- Default model is fixed to `doubao-seedream-5-0-260128`
- Default response format is `url`
- Default output image format is `png`
- Default streaming is `false`
- If the API key is missing or invalid, report the exact problem

## Validation

Before saying it works, actually run the script and confirm that the file is saved or a URL is returned.

## Boundary

This skill currently does only one thing: prompt-to-image, then either download the file or return the URL.

Do not silently add:
- batch generation
- model switching
- prompt history storage

unless the user explicitly asks.

Keep it small and deterministic.
