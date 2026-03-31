#!/bin/bash
# 将 API keys 从 .env 文件迁移到 .authinfo.gpg

set -euo pipefail

PROVIDERS_DIR="$HOME/.config/claude/providers"
AUTHINFO_TEMP=$(mktemp)

echo "=== Claude Provider API Key Migration ==="
echo

# 解密现有的 .authinfo.gpg (如果存在)
if [[ -f "$HOME/.authinfo.gpg" ]]; then
    echo "Decrypting existing .authinfo.gpg..."
    if ! gpg -d "$HOME/.authinfo.gpg" > "$AUTHINFO_TEMP" 2>/dev/null; then
        echo "Error: Failed to decrypt .authinfo.gpg"
        echo "Please ensure your GPG passphrase is correct."
        rm -f "$AUTHINFO_TEMP"
        exit 1
    fi
    echo "✓ Decrypted successfully"
else
    echo "No existing .authinfo.gpg found, creating new one..."
    touch "$AUTHINFO_TEMP"
fi

# 提取 tokens 从现有的 .env 文件
echo
echo "Extracting API keys from .env files..."

# 从 glm.env 提取
if [[ -f "$PROVIDERS_DIR/glm.env" ]]; then
    GLM_TOKEN=$(grep '^export ANTHROPIC_AUTH_TOKEN=' "$PROVIDERS_DIR/glm.env" | sed 's/export ANTHROPIC_AUTH_TOKEN="//; s/"$//')
    if [[ -n "$GLM_TOKEN" ]]; then
        echo "Found GLM token: ${GLM_TOKEN:0:10}..."
        # 检查是否已存在
        if ! grep -q "machine open.bigmodel.cn" "$AUTHINFO_TEMP"; then
            echo "machine open.bigmodel.cn login anthropic password $GLM_TOKEN" >> "$AUTHINFO_TEMP"
            echo "✓ Added GLM token"
        else
            echo "ℹ GLM token already exists in .authinfo.gpg"
        fi
    fi
fi

# 从 aliyun.env 提取（取最后一行的，因为文件中有两个）
if [[ -f "$PROVIDERS_DIR/aliyun.env" ]]; then
    ALIYUN_TOKEN=$(grep '^export ANTHROPIC_AUTH_TOKEN=' "$PROVIDERS_DIR/aliyun.env" | tail -1 | sed 's/export ANTHROPIC_AUTH_TOKEN="//; s/"$//')
    if [[ -n "$ALIYUN_TOKEN" ]]; then
        echo "Found Aliyun token: ${ALIYUN_TOKEN:0:10}..."
        # 检查是否已存在
        if ! grep -q "machine dashscope.aliyuncs.com" "$AUTHINFO_TEMP"; then
            echo "machine dashscope.aliyuncs.com login anthropic password $ALIYUN_TOKEN" >> "$AUTHINFO_TEMP"
            echo "✓ Added Aliyun token"
        else
            echo "ℹ Aliyun token already exists in .authinfo.gpg"
        fi
    fi
fi

echo
echo "Current .authinfo content:"
echo "----------------------------------------"
cat "$AUTHINFO_TEMP"
echo "----------------------------------------"
echo

# 加密回 .authinfo.gpg
echo "Encrypting to .authinfo.gpg..."
echo "Please enter your GPG passphrase..."

# 获取默认 GPG key
DEFAULT_KEY=$(gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -E 'sec.*\[SC\]' | head -1 | awk '{print $2}' | cut -d'/' -f2)

if [[ -n "$DEFAULT_KEY" ]]; then
    echo "Using GPG key: $DEFAULT_KEY"
    gpg -e -r "$DEFAULT_KEY" "$AUTHINFO_TEMP" -o "$HOME/.authinfo.gpg.new"
else
    gpg -e "$AUTHINFO_TEMP" -o "$HOME/.authinfo.gpg.new"
fi

# 备份旧的 .authinfo.gpg 并替换
if [[ -f "$HOME/.authinfo.gpg" ]]; then
    mv "$HOME/.authinfo.gpg" "$HOME/.authinfo.gpg.backup.$(date +%Y%m%d%H%M%S)"
fi

mv "$HOME/.authinfo.gpg.new" "$HOME/.authinfo.gpg"
rm -f "$AUTHINFO_TEMP"

echo "✓ Migration complete!"
echo
echo "Next steps:"
echo "1. Run: source ~/.zshrc"
echo "2. The .env files now have dummy tokens"
echo "3. The real tokens are stored in .authinfo.gpg"
echo
