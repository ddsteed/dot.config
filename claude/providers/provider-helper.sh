#!/bin/bash
# Helper script to load API credentials from .authinfo.gpg
#
# 用法 1: 在 .zshrc 中 source 此文件，使用 claudep 函数
# 用法 2: 在 source .env 之前调用 set_claude_token <provider>

# 检测当前 shell
if [[ -n "$ZSH_VERSION" ]]; then
    # Zsh: 不使用 export -f（会导致函数定义被打印）
    :
elif [[ -n "$BASH_VERSION" ]]; then
    # Bash: 正常使用 export -f
    :
fi

# 从 .authinfo.gpg 读取 API key
# 用法: get_auth_token <machine> [<login>]
get_auth_token() {
    local machine="$1"
    local login="${2:-anthropic}"

    # 使用 gpg 解密并查找匹配的行
    gpg --decrypt ~/.authinfo.gpg 2>/dev/null | \
        awk -v machine="$machine" -v login="$login" '
        $1 == "machine" && $2 == machine && $3 == "login" && $4 == login {
            for (i=5; i<=NF; i++) {
                if ($i ~ /^password=/) {
                    sub(/^password=/, "", $i)
                    print $i
                    exit
                }
            }
        }
        '
}

# 设置 provider 对应的 ANTHROPIC_AUTH_TOKEN 环境变量
# 用法: set_claude_token <provider>
set_claude_token() {
    local provider="$1"

    case "$provider" in
        aliyun)
            local token
            token=$(get_auth_token "dashscope.aliyuncs.com" "anthropic")
            if [[ -z "$token" ]]; then
                echo "Error: Failed to get Aliyun token from .authinfo.gpg" >&2
                return 1
            fi
            export ANTHROPIC_AUTH_TOKEN="$token"
            ;;
        glm)
            local token
            token=$(get_auth_token "open.bigmodel.cn" "anthropic")
            if [[ -z "$token" ]]; then
                echo "Error: Failed to get GLM token from .authinfo.gpg" >&2
                return 1
            fi
            export ANTHROPIC_AUTH_TOKEN="$token"
            ;;
        *)
            echo "Error: Unknown provider '$provider'. Use 'aliyun' or 'glm'." >&2
            return 1
            ;;
    esac
}

# 兼容原有用法：设置 token 并 source .env 文件
# 用法: claudep <provider>
claudep() {
    local provider="$1"
    shift || true

    # 设置 token
    if ! set_claude_token "$provider"; then
        return 1
    fi

    # source 对应的 .env 文件（token 已被覆盖）
    case "$provider" in
        aliyun)
            source ~/.config/claude/providers/aliyun.env
            echo "[Claude] provider=aliyun model=${ANTHROPIC_MODEL}"
            ;;
        glm)
            source ~/.config/claude/providers/glm.env
            echo "[Claude] provider=glm opus=${ANTHROPIC_DEFAULT_OPUS_MODEL} sonnet=${ANTHROPIC_DEFAULT_SONNET_MODEL}"
            ;;
    esac

    echo
    claude "$@"
}
