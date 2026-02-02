#!/bin/bash
set -e

# ================= 配置区域 =================
RAW_BASE="https://raw.githubusercontent.com/sfee1212/SiTV/main/dist_encrypted"
SOURCE_URL="$RAW_BASE/saileitv_server.py"
# 注意：项目依赖清单通常在主仓库根目录
REQUIREMENTS_URL="https://raw.githubusercontent.com/sfee1212/SiTV/main/requirements.txt"
# ===========================================

INSTALL_DIR="/opt/sitv"

echo ">>> SiTV Linux 一键部署"

# 1. 准备目录
if [ ! -d "$INSTALL_DIR" ]; then
    sudo mkdir -p "$INSTALL_DIR"
    echo "[OK] 创建目录: $INSTALL_DIR"
fi

# 2. 安装系统依赖 (针对 Debian/Ubuntu)
echo ">>> 正在安装运行环境..."
sudo apt-get update && sudo apt-get install -y python3 python3-pip python3-venv libffi-dev

# 3. 准备虚拟环境并安装依赖
echo ">>> 正在准备 Python 环境..."
sudo python3 -m venv "$INSTALL_DIR/venv"
sudo "$INSTALL_DIR/venv/bin/pip" install --upgrade pip

# 4. 下载源码和依赖清单
echo ">>> 正在下载源码..."
# 使用 -f 选项，如果 404 则返回错误
sudo curl -fsSL -o "$INSTALL_DIR/saileitv_server.py" "$SOURCE_URL"
sudo curl -fsSL -o "$INSTALL_DIR/requirements.txt" "$REQUIREMENTS_URL" || {
    echo "[WARN] 无法从 $REQUIREMENTS_URL 下载依赖清单，尝试从通用路径下载..."
    sudo curl -fsSL -o "$INSTALL_DIR/requirements.txt" "https://raw.githubusercontent.com/sfee1212/SiTV-SERVER/main/requirements.txt"
}

# 安装项目依赖
echo ">>> 正在安装项目依赖..."
sudo "$INSTALL_DIR/venv/bin/pip" install -r "$INSTALL_DIR/requirements.txt"

# 5. 下载源码和运行时库
echo ">>> 正在下载源码库..."
# 如果本地有多个运行时目录，尝试自动识别并重命名为标准名称
cd "$INSTALL_DIR"
# 注意：PyArmor 生成的运行时目录可能叫 pyarmor_runtime_xxxxxx
# 我们在 GitHub 上手动管理的建议直接叫 pyarmor_runtime
# 如果您上传的是 pyarmor_runtime_000000，脚本会尝试处理
sudo mkdir -p "$INSTALL_DIR/pyarmor_runtime"

echo ">>> 同步运行时环境..."
# 逐个下载核心运行文件
sudo curl -fsSL -o "$INSTALL_DIR/pyarmor_runtime/__init__.py" "$RAW_BASE/pyarmor_runtime/__init__.py" || \
sudo curl -fsSL -o "$INSTALL_DIR/pyarmor_runtime/__init__.py" "$RAW_BASE/pyarmor_runtime_000000/__init__.py"

sudo curl -fsSL -o "$INSTALL_DIR/pyarmor_runtime/pyarmor_runtime.so" "$RAW_BASE/pyarmor_runtime/pyarmor_runtime.so" || \
sudo curl -fsSL -o "$INSTALL_DIR/pyarmor_runtime/pyarmor_runtime.so" "$RAW_BASE/pyarmor_runtime_000000/pyarmor_runtime.so"

echo "[OK] 环境配置完成"

# 6. 配置 Systemd
echo ">>> 配置服务..."
sudo bash -c "cat > /etc/systemd/system/sitv.service <<EOF
[Unit]
Description=SiTV Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$INSTALL_DIR
Environment=\"PATH=$INSTALL_DIR/venv/bin\"
Environment=\"PYTHONUNBUFFERED=1\"
ExecStart=$INSTALL_DIR/venv/bin/python saileitv_server.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF"

# 4. 启动
sudo systemctl daemon-reload
sudo systemctl enable sitv
sudo systemctl restart sitv

echo ">>> 部署成功！"
echo "服务状态: sudo systemctl status sitv"
echo "查看日志: sudo journalctl -u sitv -f"


