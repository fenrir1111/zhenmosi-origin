#!/bin/bash
# 镇魔司：缘起 - 项目整合脚本
# Week 1-6 完整代码整合

echo "=================================="
echo "镇魔司：缘起 - 项目整合"
echo "Week 1-6 完整功能"
echo "=================================="
echo ""

PROJECT_DIR="/home/fenrir/.openclaw/workspace-game-leaddev/zhenmosi-prototype"

cd "$PROJECT_DIR" || exit 1

# 1. 检查Godot是否存在
if [ ! -f ~/bin/godot4 ]; then
    echo "❌ 错误：找不到Godot 4！"
    echo "   请确保Godot 4已安装在 ~/bin/godot4"
    exit 1
fi

echo "✅ Godot 4 已找到"

# 2. 创建必要的目录结构
echo "📁 创建目录结构..."
mkdir -p scenes/{player,enemies,levels,ui,test}
mkdir -p scripts/{core,player,enemies,ui,levels,utils,combat}
mkdir -p assets/{audio/sfx,sprites,fonts,effects}
mkdir -p resources

echo "✅ 目录结构已创建"

# 3. 检查核心脚本
echo ""
echo "🔍 检查核心脚本..."

CORE_SCRIPTS=(
    "scripts/core/GameManager.gd"
    "scripts/core/AudioManager.gd"
    "scripts/utils/HitStop.gd"
    "scripts/utils/ScreenShake.gd"
    "scripts/player/Player.gd"
    "scripts/enemies/Enemy.gd"
    "scripts/ui/HealthBar.gd"
    "scripts/ui/ExperienceBar.gd"
    "scripts/ui/GameHUD.gd"
    "scripts/ui/PauseMenu.gd"
    "scripts/ui/MainMenu.gd"
)

MISSING_COUNT=0
for script in "${CORE_SCRIPTS[@]}"; do
    if [ -f "$PROJECT_DIR/$script" ]; then
        echo "  ✅ $script"
    else
        echo "  ❌ 缺失: $script"
        ((MISSING_COUNT++))
    fi
done

if [ $MISSING_COUNT -gt 0 ]; then
    echo ""
    echo "⚠️  警告：有 $MISSING_COUNT 个核心脚本缺失"
else
    echo ""
    echo "✅ 所有核心脚本已就绪"
fi

# 4. 检查project.godot配置
echo ""
echo "🔍 检查project.godot配置..."

if grep -q "GameManager=" project.godot; then
    echo "  ✅ GameManager AutoLoad已配置"
else
    echo "  ⚠️  警告：GameManager未配置到AutoLoad"
fi

if grep -q "AudioManager=" project.godot; then
    echo "  ✅ AudioManager AutoLoad已配置"
else
    echo "  ⚠️  警告：AudioManager未配置到AutoLoad"
fi

# 5. 统计代码行数
echo ""
echo "📊 代码统计..."

TOTAL_LINES=$(find scripts -name "*.gd" -exec wc -l {} + | tail -1 | awk '{print $1}')
FILE_COUNT=$(find scripts -name "*.gd" | wc -l)

echo "  GDScript文件数量: $FILE_COUNT"
echo "  总代码行数: $TOTAL_LINES"

# 6. 生成快速启动说明
echo ""
echo "=================================="
echo "🎮 快速启动指南"
echo "=================================="
echo ""
echo "方式1：使用Godot编辑器"
echo "  ~/bin/godot4 --editor $PROJECT_DIR/project.godot"
echo ""
echo "方式2：直接运行游戏"
echo "  ~/bin/godot4 $PROJECT_DIR/project.godot"
echo ""
echo "=================================="
echo "📋 Week 1-6 功能清单"
echo "=================================="
echo ""
echo "✅ Week 1: 玩家移动、跳跃"
echo "✅ Week 2: 动画系统、生命值"
echo "✅ Week 3: 敌人AI、攻击系统"
echo "✅ Week 4: 战斗反馈（顿帧、震屏、连击）"
echo "✅ Week 5: UI系统（血条、经验、闪避、死亡重生）"
echo "✅ Week 6: 菜单系统、游戏管理器、性能优化"
echo ""
echo "=================================="
echo "⚠️  已知问题（需人工处理）"
echo "=================================="
echo ""
echo "1. 场景文件未创建（需在Godot编辑器中手动创建）"
echo "   - scenes/ui/MainMenu.tscn"
echo "   - scenes/ui/PauseMenu.tscn"
echo "   - scenes/player/Player.tscn"
echo "   - scenes/levels/TestLevel.tscn"
echo ""
echo "2. 音频文件缺失（需人工下载）"
echo "   - assets/audio/sfx/*.ogg"
echo ""
echo "3. 临时美术资源（使用ColorRect占位）"
echo "   - 血条使用ProgressBar"
echo "   - 角色使用Sprite2D + ColorRect"
echo ""
echo "=================================="
echo "📚 文档位置"
echo "=================================="
echo ""
echo "  测试报告: $PROJECT_DIR/Week*.md"
echo "  设计文档: /home/fenrir/.openclaw/workspace-game-pm/zhenmosi-game/"
echo "  美术文档: /home/fenrir/.openclaw/workspace-game-art/"
echo "  音频文档: /home/fenrir/.openclaw/workspace-game-audio/"
echo "  QA文档:   /home/fenrir/.openclaw/workspace-game-qa/"
echo ""
echo "=================================="
echo "🚀 整合完成！"
echo "=================================="
