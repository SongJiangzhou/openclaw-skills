#!/usr/bin/env bash
set -euo pipefail

PROMPT=""
SIZE="2K"
WATERMARK="true"
MODEL="doubao-seedream-5-0-260128"
BASE_URL="${ARK_BASE_URL:-https://ark.cn-beijing.volces.com/api/v3}"
OUTPUT_DIR="/home/lv5railgun/.openclaw/workspace/data/generated-images"
FILENAME=""
URL_ONLY="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prompt)
      PROMPT="${2:-}"
      shift 2
      ;;
    --size)
      SIZE="${2:-}"
      shift 2
      ;;
    --watermark)
      WATERMARK="${2:-}"
      shift 2
      ;;
    --output-dir)
      OUTPUT_DIR="${2:-}"
      shift 2
      ;;
    --filename)
      FILENAME="${2:-}"
      shift 2
      ;;
    --url-only)
      URL_ONLY="true"
      shift
      ;;
    --help|-h)
      cat <<'USAGE'
Usage: bash scripts/generate.sh --prompt '<text>' [--size 2K] [--watermark true|false] [--output-dir <dir>] [--filename <name>] [--url-only]
USAGE
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [[ -z "$PROMPT" ]]; then
  echo "Missing required --prompt" >&2
  exit 2
fi

if [[ -z "${ARK_API_KEY:-}" ]]; then
  echo "ARK_API_KEY is not set" >&2
  exit 2
fi

payload=$(jq -n \
  --arg model "$MODEL" \
  --arg prompt "$PROMPT" \
  --arg size "$SIZE" \
  --arg output_format "png" \
  --arg response_format "url" \
  --arg sequential_image_generation "disabled" \
  --argjson stream false \
  --argjson watermark "$WATERMARK" \
  '{model:$model,prompt:$prompt,sequential_image_generation:$sequential_image_generation,response_format:$response_format,output_format:$output_format,size:$size,stream:$stream,watermark:$watermark}')

response=$(curl -sS -X POST "$BASE_URL/images/generations" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ARK_API_KEY" \
  -d "$payload")

url=$(printf '%s' "$response" | jq -r '.data[0].url // empty')
if [[ -z "$url" ]]; then
  echo "API call failed:" >&2
  printf '%s\n' "$response" >&2
  exit 1
fi

if [[ "$URL_ONLY" == "true" ]]; then
  printf '%s\n' "$url"
  exit 0
fi

mkdir -p "$OUTPUT_DIR"

if [[ -z "$FILENAME" ]]; then
  ts=$(date '+%Y-%m-%d_%H%M%S')
  FILENAME="doubao_${ts}.png"
fi

case "$FILENAME" in
  */*)
    echo "--filename must be a plain file name, not a path" >&2
    exit 2
    ;;
esac

OUT_PATH="$OUTPUT_DIR/$FILENAME"
curl -L -sS "$url" -o "$OUT_PATH"

printf 'saved: %s\n' "$OUT_PATH"
printf 'url: %s\n' "$url"
