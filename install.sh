#!/bin/bash
set -e

# ================= 配置区域 =================
RAW_BASE="https://raw.githubusercontent.com/sfee1212/SiTV-SERVER/main"
SOURCE_URL="$RAW_BASE/saileitv_server.py"
REQUIREMENTS_URL="$RAW_BASE/requirements.txt"
# ===========================================

# 通用下载函数 (现在仓库是 Public，无需 Token)
download_file() {
    sudo curl -fsSL -o "$2" "$1"
}

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
download_file "$SOURCE_URL" "$INSTALL_DIR/saileitv_server.py" || {
    echo "[ERROR] 下载失败！404 错误通常是因为仓库是私有的。"
    echo "请检查 GITHUB_TOKEN 是否设置，或将仓库设为 Public。"
    exit 1
}

download_file "$REQUIREMENTS_URL" "$INSTALL_DIR/requirements.txt" || {
    echo "[WARN] 无法从 $REQUIREMENTS_URL 下载依赖清单，尝试备用路径..."
    download_file "https://raw.githubusercontent.com/sfee1212/SiTV-SERVER/main/requirements.txt" "$INSTALL_DIR/requirements.txt"
}

# 安装项目依赖
echo ">>> 正在安装项目依赖..."
sudo "$INSTALL_DIR/venv/bin/pip" install -r "$INSTALL_DIR/requirements.txt"

# 5. 下载加密后的源码和运行时库
echo ">>> 正在下载加密源码和运行时..."
cd "$INSTALL_DIR"
download_file "$SOURCE_URL" "saileitv_server.py"

# 从截图看，pyarmor_runtime 文件直接在根目录 (__init__.py 和 pyarmor_runtime.so)
sudo mkdir -p "pyarmor_runtime"
echo ">>> 同步运行时环境..."
download_file "$RAW_BASE/__init__.py" "pyarmor_runtime/__init__.py"
download_file "$RAW_BASE/pyarmor_runtime.so" "pyarmor_runtime/pyarmor_runtime.so"

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


