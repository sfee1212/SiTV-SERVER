#!/bin/bash
set -e

# ================= 配置区域 =================
RAW_BASE="https://raw.githubusercontent.com/sfee1212/SiTV/main/dist_encrypted"
SOURCE_URL="$RAW_BASE/saileitv_server.py"
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
sudo curl -L -o "$INSTALL_DIR/saileitv_server.py" "$SOURCE_URL"
sudo curl -L -o "$INSTALL_DIR/requirements.txt" "$REQUIREMENTS_URL"

# 安装项目依赖
echo ">>> 正在安装项目依赖..."
sudo "$INSTALL_DIR/venv/bin/pip" install -r "$INSTALL_DIR/requirements.txt"

# 5. 下载源码和运行时库
echo ">>> 正在下载源码和运行时..."
sudo curl -L -o "$INSTALL_DIR/saileitv_server.py" "$SOURCE_URL"

echo ">>> 正在同步 pyarmor_runtime..."
sudo mkdir -p "$INSTALL_DIR/pyarmor_runtime"
sudo curl -L -o "$INSTALL_DIR/pyarmor_runtime/__init__.py" "$RAW_BASE/pyarmor_runtime/__init__.py"
sudo curl -L -o "$INSTALL_DIR/pyarmor_runtime/pyarmor_runtime.so" "$RAW_BASE/pyarmor_runtime/pyarmor_runtime.so"

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

