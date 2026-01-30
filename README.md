# 📺 SiTV 代理服务器

> **轻量 · 高效 · 安全 · 跨平台**
>
> SiTV 是一个基于 Python 开发的高性能 IPTV 直播源代理系统。它专为解决直播源不稳定、跨域限制及隐私保护而设计，提供了一套从源头获取、自动代理到终端播放的完整解决方案。

## ✨ 核心特性

*   **🚀 一键极速部署**：集成 GitHub Actions CI/CD 流程，全自动构建 Windows/Linux 客户端。配合独家的一键安装脚本，小白也能在 60 秒内完成服务器部署。
*   **🌐 IPv4/IPv6 双栈支持**：完美适配现代网络环境，优先支持 IPv6 直连，在移动/家庭宽带环境下无需公网 IPv4 也能流畅访问。
*   **🔒 安全鉴权体系**：内置 API Token 和 Web 管理密码双重认证机制，防止非法盗链和未授权访问。
*   **📡 智能代理转发**：自动处理 HTTP/HTTPS 直播流，让 PotPlayer、VLC、Tivimate 等播放器无障碍播放。
*   **💻 跨平台运行**：一套代码，同时支持 Windows (exe) 和 Linux (二进制) 环境，无需安装 Python 环境即可直接运行。

---

### 📥 一键部署 (推荐)

无需下载任何文件，直接在服务器/电脑终端执行下方命令即可。
*(脚本会自动从 GitHub 下载最新稳定版并安装)*

#### 🐧 Docker 启动（支持多架构）
适用于 X86、ARM64、ARMv7 等架构，自动适配设备架构。
```bash
docker run -d --restart=always -p 22125:22125 --name sitv-server yhtv/sitv-server:latest
```

#### 🐧 Linux 服务器
适用于 Ubuntu, CentOS, Debian 等系统。自动安装为 Systemd 服务，开机自启。
```bash
curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/sfee1212/SiTV-SERVER/main/install.sh | sudo bash
```

#### 🖥️ Windows 环境
适用于 Windows 10/11/Server。自动创建桌面快捷方式。
IPv6专用
```powershell
irm https://gh-proxy.com/https://raw.githubusercontent.com/sfee1212/SiTV-SERVER/main/install.ps1 | iex
```
IPv4专用
```powershell
irm https://gh-proxy.com/https://raw.githubusercontent.com/sfee1212/SiTV-SERVER/main/install_v4.ps1 | iex
```

## ✨ 有傻子都能看懂的管理页面
<img width="1270" height="906" alt="df4786c5-e681-4df4-9e68-24c93d81371b" src="https://github.com/user-attachments/assets/cb55bee3-5482-4fa3-87f9-afb171a8d64f" />


## 📺 直播画面
<img width="1060" height="589" alt="081dc456-b663-4f88-a4f5-a4831ff27616" src="https://github.com/user-attachments/assets/72610607-b98d-4c78-a99f-e59d14d811f1" />
<img width="1280" height="720" alt="fa3bd4dd-9a73-4123-accd-908b88cfa000" src="https://github.com/user-attachments/assets/3b94b5f5-ae36-4c61-8edc-62d6ab98ecb2" />
<img width="1280" height="720" alt="b46afae6-a718-4b76-984b-62cf610186d9" src="https://github.com/user-attachments/assets/752b4280-b4df-4aef-9c40-fb24129814eb" />
<img width="1280" height="720" alt="ee46cc6f-6f89-49e8-8d9f-e8d28322b39c" src="https://github.com/user-attachments/assets/47414ec2-91ab-4868-99f8-8f9b9eebdf1a" />

