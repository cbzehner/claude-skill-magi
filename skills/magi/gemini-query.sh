#!/usr/bin/env bash
# Gemini query adapter — centralizes model selection and output handling.
# Usage: bash gemini-query.sh "prompt text here"
set -euo pipefail

PROMPT="$1"
MODEL="gemini-3.1-pro-preview"

gemini -p "$PROMPT" --model "$MODEL" --sandbox -o json 2>/dev/null
