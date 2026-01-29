$ErrorActionPreference = 'Stop'

# ================= 配置区域 =================
# 请将下面的 URL 替换为您 GitHub Actions 构建出来的 EXE 下载链接
# 或者您手动上传的 Release 链接
$ExeUrl = "https://gh-proxy.com/https://github.com/sfee1212/SiTV-SERVER/releases/download/v1.0.0/saileitv-server-win.1.0.exe"
# ===========================================

$InstallDir = "C:\SiTV"
$ExeName = "saileitv-server-win.exe"
$LocalExe = Join-Path $InstallDir $ExeName

Write-Host ">>> SiTV Windows 一键部署" -ForegroundColor Cyan

# 1. 创建目录
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
    Write-Host "[OK] 安装目录已创建: $InstallDir"
}

# 2. 下载
Write-Host ">>> 正在下载服务器程序..."
try {
    Invoke-WebRequest -Uri $ExeUrl -OutFile $LocalExe
}
catch {
    Write-Error "下载失败！请检查脚本中的 URL 是否正确。"
    exit 1
}
Write-Host "[OK] 下载完成"

# 3. 创建桌面快捷方式
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\SiTV Server.lnk")
$Shortcut.TargetPath = $LocalExe
$Shortcut.Description = "Start SiTV Server"
$Shortcut.WorkingDirectory = $InstallDir
$Shortcut.Save()
Write-Host "[OK] 桌面快捷方式已创建"

Write-Host "`n>>> 部署成功！" -ForegroundColor Green
Write-Host "您现在可以直接双击桌面的 'SiTV Server' 图标启动服务。"
# Start-Process $LocalExe

