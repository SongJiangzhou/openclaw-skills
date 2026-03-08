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

# 交互式多选菜单
interactive_select() {
    local skills=($(get_available_skills))
    local total=${#skills[@]}
    
    if [ $total -eq 0 ]; then
        echo "没有找到可用的 skills"
        return 1
    fi

    # 初始化状态数组 (0=未选中, 1=选中)
    local selected=()
    for ((i=0; i<total; i++)); do
        selected[$i]=0
    done
    
    local cursor=0
    local all_selected=0

    # 保存终端设置
    local old_stty
    old_stty=$(stty -g)
    stty -icanon -echo min 1 time 0

    # 隐藏光标，退出时恢复
    tput civis 2>/dev/null || true
    trap 'tput cnorm 2>/dev/null; stty "$old_stty"' EXIT INT TERM

    clear
    while true; do
        # 归位 + 清除到底，避免闪烁
        tput cup 0 0 2>/dev/null
        tput ed 2>/dev/null
        show_menu
        echo "${BOLD}请选择要安装的 skills:${NC}"
        echo "${CYAN}↑↓${NC} 移动  ${CYAN}空格${NC} 选中/取消  ${CYAN}a${NC} 全选/全取消  ${CYAN}Enter${NC} 安装  ${CYAN}q${NC} 退出"
        echo ""

        # 显示列表
        for ((i=0; i<total; i++)); do
            local skill="${skills[$i]}"
            local checkbox="${BOLD}[ ]${NC}"
            local status=""

            # 选中状态
            if [ ${selected[$i]} -eq 1 ]; then
                checkbox="${GREEN}${BOLD}[✓]${NC}"
            fi

            # 安装状态
            if is_installed "$skill"; then
                status="${CYAN}[已安装]${NC}"
            else
                status="${YELLOW}[未安装]${NC}"
            fi

            # 打印行：光标行高亮
            if [ $i -eq $cursor ]; then
                echo "  ${checkbox} ${BOLD}${GREEN}▶ ${skill}${NC} ${status}"
            else
                echo "  ${checkbox}   ${skill} ${status}"
            fi
        done

        # 读取按键
        local key
        IFS= read -r -n1 key

        # 处理特殊键 (ESC 序列)，加 0.1s 超时避免卡住
        if [ "$key" = $'\x1b' ]; then
            IFS= read -r -t 0.1 -n1 key
            if [ "$key" = "[" ]; then
                IFS= read -r -t 0.1 -n1 key
                case "$key" in
                    A) # 上箭头
                        ((cursor--))
                        if [ $cursor -lt 0 ]; then
                            cursor=$((total-1))
                        fi
                        ;;
                    B) # 下箭头
                        ((cursor++))
                        if [ $cursor -ge $total ]; then
                            cursor=0
                        fi
                        ;;
                esac
            fi
        else
            case "$key" in
                ' ') # 空格 - 切换选中状态
                    if [ ${selected[$cursor]} -eq 0 ]; then
                        selected[$cursor]=1
                    else
                        selected[$cursor]=0
                    fi
                    ;;
                a|A) # 全选/取消全选
                    if [ $all_selected -eq 0 ]; then
                        for ((i=0; i<total; i++)); do
                            selected[$i]=1
                        done
                        all_selected=1
                    else
                        for ((i=0; i<total; i++)); do
                            selected[$i]=0
                        done
                        all_selected=0
                    fi
                    ;;
                '') # 回车 - 确认
                    break
                    ;;
                q|Q) # 退出
                    tput cnorm 2>/dev/null || true
                    trap - EXIT INT TERM
                    stty "$old_stty"
                    clear
                    echo ""
                    echo "已取消安装"
                    exit 0
                    ;;
            esac
        fi
    done

    # 恢复终端设置
    tput cnorm 2>/dev/null || true
    trap - EXIT INT TERM
    stty "$old_stty"
    clear

    # 收集选中的 skills
    local to_install=()
    for ((i=0; i<total; i++)); do
        if [ ${selected[$i]} -eq 1 ]; then
            to_install+=("${skills[$i]}")
        fi
    done

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
