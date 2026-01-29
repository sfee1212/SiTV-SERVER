#!/bin/bash
set -e

# ================= 配置区域 =================
# 请将下面的 URL 替换为您 GitHub Actions 构建出来的 Linux 二进制下载链接
EXE_URL="https://gh-proxy.com/https://github.com/sfee1212/SiTV-SERVER/releases/download/v1.0.0/saileitv-server-linux"
# ===========================================

INSTALL_DIR="/opt/sitv"
EXE_NAME="saileitv-server"

echo ">>> SiTV Linux 一键部署"

# 1. 准备目录
if [ ! -d "$INSTALL_DIR" ]; then
    sudo mkdir -p "$INSTALL_DIR"
    echo "[OK] 创建目录: $INSTALL_DIR"
fi

# 2. 下载
echo ">>> 正在下载..."
sudo curl -L -o "$INSTALL_DIR/$EXE_NAME" "$EXE_URL"
sudo chmod +x "$INSTALL_DIR/$EXE_NAME"
echo "[OK] 下载完成"

# 3. 配置 Systemd
echo ">>> 配置服务..."
sudo bash -c "cat > /etc/systemd/system/sitv.service <<EOF
[Unit]
Description=SiTV Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/$EXE_NAME
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
