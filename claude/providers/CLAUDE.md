# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This directory contains environment configuration files for switching between different API providers that offer Anthropic-compatible interfaces. Each provider has its own `.env` file with API authentication and model mappings.

## Switching Providers

To use a different provider, source the corresponding `.env` file:

```bash
# Use GLM (BigModel/智谱)
source /Users/fengh/.config/claude/providers/glm.env

# Use Aliyun Dashscope
source /Users/fengh/.config/claude/providers/aliyun.env
```

Add the source command to your shell profile (`~/.zshrc` or `~/.bashrc`) to persist the selection.

## Provider Configurations

### GLM (BigModel/智谱)

**File:** `glm.env`

- **Base URL:** `https://open.bigmodel.cn/api/anthropic`
- **Default Models:**
  - Haiku: `glm-4.5-air` (lightweight, cost-effective)
  - Sonnet: `glm-4.7` (balanced performance)
  - Opus: `glm-5` (maximum capability)
- **Timeout:** 3000s (configured via `API_TIMEOUT_MS`)
- **Optimization:** Non-essential traffic disabled

### Aliyun Dashscope

**File:** `aliyun.env`

- **Base URL:** `https://dashscope.aliyuncs.com/apps/anthropic`
- **Default Models:**
  - `qwen3.5-plus` (current active model)
  - Alternative: `qwen3-coder-next`

## Model Mapping

These providers map their own models to Anthropic's model tiers:

| Anthropic Tier | GLM | Aliyun |
|----------------|-----|--------|
| Haiku | `glm-4.5-air` | (uses `ANTHROPIC_MODEL`) |
| Sonnet | `glm-4.7` | `qwen3.5-plus` |
| Opus | `glm-5` | (uses `ANTHROPIC_MODEL`) |

## Important Notes

- **API keys are sensitive** - never commit these files with real keys to version control
- The `ANTHROPIC_AUTH_TOKEN` contains the actual API key for each provider
- When switching providers, ensure you also update any cached model references
- Some providers may have different feature support or rate limits
