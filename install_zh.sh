#!/bin/bash

# install.sh - 交互式安装 OpenClaw skills 到目标目录
# 空格: 选中/取消  回车: 确认安装  q: 退出

set -e

# 配置
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/skills"
TARGET_DIR="$HOME/.openclaw/workspace/skills"

# 检查终端是否支持颜色
USE_COLOR=0
if [ -t 1 ] && [ "$TERM" != "dumb" ] && command -v tput > /dev/null 2>&1; then
    if tput setaf 1 > /dev/null 2>&1; then
        USE_COLOR=1
    fi
fi

# 设置颜色变量（如果不支持则为空）
if [ $USE_COLOR -eq 1 ]; then
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4)
    CYAN=$(tput setaf 6)
    BOLD=$(tput bold)
    NC=$(tput sgr0)
else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    CYAN=""
    BOLD=""
    NC=""
fi

# 检查源目录是否存在
if [ ! -d "$SOURCE_DIR" ]; then
    echo "错误: 源目录不存在: $SOURCE_DIR"
    exit 1
fi

# 创建目标目录（如果不存在）
mkdir -p "$TARGET_DIR"

# 获取所有可用的 skills
get_available_skills() {
    local skills=()
    for skill_path in "$SOURCE_DIR"/*/; do
        if [ -d "$skill_path" ]; then
            skills+=("$(basename "$skill_path")")
        fi
    done
    echo "${skills[@]}"
}

# 检查 skill 是否已安装
is_installed() {
    local skill_name="$1"
    [ -d "$TARGET_DIR/$skill_name" ]
}

# 安装单个 skill 的函数
install_skill() {
    local skill_name="$1"
    local source_path="$SOURCE_DIR/$skill_name"
    local target_path="$TARGET_DIR/$skill_name"

    if [ ! -d "$source_path" ]; then
        echo "  ✗ Skill 不存在: $skill_name"
        return 1
    fi

    if [ -e "$target_path" ]; then
        echo "  → 删除旧链接: $skill_name"
        rm -rf "$target_path"
    fi

    ln -s "$source_path" "$target_path"
    echo "  ✓ 已链接: $skill_name"
}

# 显示主菜单
show_menu() {
    echo "${BOLD}╔════════════════════════════════════════════════╗${NC}"
    echo "${BOLD}║       OpenClaw Skills 交互式安装工具          ║${NC}"
    echo "${BOLD}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "${CYAN}源目录:${NC} $SOURCE_DIR"
    echo "${CYAN}目标目录:${NC} $TARGET_DIR"
    echo ""
}

# 交互式多选菜单（基于 fzf）
interactive_select() {
    # 检查 fzf 是否已安装
    if ! command -v fzf > /dev/null 2>&1; then
        echo "${RED}错误: 未找到 fzf${NC}"
        echo ""
        echo "请先安装 fzf:"
        echo "  ${CYAN}Arch/CachyOS:${NC}  sudo pacman -S fzf"
        echo "  ${CYAN}Ubuntu/Debian:${NC} sudo apt install fzf"
        echo "  ${CYAN}macOS:${NC}         brew install fzf"
        exit 1
    fi

    local skills=($(get_available_skills))
    local total=${#skills[@]}

    if [ $total -eq 0 ]; then
        echo "没有找到可用的 skills"
        return 1
    fi

    # 构建带状态标注的显示列表
    local items=()
    for skill in "${skills[@]}"; do
        if is_installed "$skill"; then
            items+=("$(printf '%-35s \033[36m[已安装]\033[0m' "$skill")")
        else
            items+=("$(printf '%-35s \033[33m[未安装]\033[0m' "$skill")")
        fi
    done

    # 运行 fzf 多选
    local selected_lines
    selected_lines=$(printf '%s\n' "${items[@]}" | fzf \
        --multi \
        --ansi \
        --prompt="  选择 > " \
        --header="↑↓ 移动  Tab/空格 选中  Ctrl-A 全选  Enter 确认  Esc 退出" \
        --header-first \
        --bind="ctrl-a:select-all,ctrl-d:deselect-all" \
        --color="header:cyan,prompt:green,pointer:green,marker:green,hl:yellow,hl+:yellow" \
        --marker="✓ " \
        --pointer="▶ " \
        ) || true

    clear

    if [ -z "$selected_lines" ]; then
        echo ""
        echo "未选择任何 skill，退出"
        exit 0
    fi

    # 从 fzf 输出中提取 skill 名称（第一列）
    local to_install=()
    while IFS= read -r line; do
        local skill_name
        skill_name=$(echo "$line" | awk '{print $1}')
        [ -n "$skill_name" ] && to_install+=("$skill_name")
    done <<< "$selected_lines"

    if [ ${#to_install[@]} -eq 0 ]; then
        echo "未选择任何 skill，退出"
        exit 0
    fi

    # 显示确认信息
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "将要安装以下 ${#to_install[@]} 个 skill(s):"
    echo ""
    for skill in "${to_install[@]}"; do
        local status=""
        if is_installed "$skill"; then
            status="(将覆盖)"
        fi
        echo "  ✓ ${skill} ${status}"
    done
    echo ""
    echo -n "确认安装? [Y/n] "
    read -r confirm

    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        echo ""
        echo "已取消安装"
        exit 0
    fi

    # 执行安装
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "开始安装..."
    echo ""

    local success=0
    local failed=0

    for skill in "${to_install[@]}"; do
        if install_skill "$skill"; then
            ((success++))
        else
            ((failed++))
        fi
    done

    # 显示结果
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "安装完成!"
    echo ""
    echo "  ✓ 成功: $success"
    if [ $failed -gt 0 ]; then
        echo "  ✗ 失败: $failed"
    fi
    echo ""
}

# 命令行模式安装
install_from_args() {
    local skills=("$@")
    local success=0
    local failed=0

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "开始安装指定的 skills..."
    echo ""

    for skill in "${skills[@]}"; do
        if install_skill "$skill"; then
            ((success++))
        else
            ((failed++))
        fi
    done

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "安装完成!"
    echo ""
    echo "  ✓ 成功: $success"
    if [ $failed -gt 0 ]; then
        echo "  ✗ 失败: $failed"
    fi
    echo ""
}

# 主逻辑
if [ $# -eq 0 ]; then
    interactive_select
else
    show_menu
    install_from_args "$@"
fi
