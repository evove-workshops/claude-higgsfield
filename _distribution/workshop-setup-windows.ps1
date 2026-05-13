# ============================================================
# OPEN Interactive Global, LLC
# Workshop Setup - Windows
# Goal: Install Claude Desktop + connect the Higgsfield MCP server
#       so the attendee arrives ready to work in Cowork.
# Version 1.0  ·  May 2026
# Run in PowerShell 5.1+ or PowerShell 7. Admin not required.
# ============================================================

$ErrorActionPreference = "Stop"

$HiggsfieldMcpUrl = "https://mcp.higgsfield.ai/mcp"
$ClaudeExeUrl     = "https://claude.ai/download/windows"   # 302s to current installer
$ConfigDir        = Join-Path $env:APPDATA "Claude"
$ConfigFile       = Join-Path $ConfigDir "claude_desktop_config.json"

function Write-Banner {
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Blue
    Write-Host "  OPEN Interactive Global, LLC"                                    -ForegroundColor Blue
    Write-Host "  Workshop Setup  -  Windows"                                      -ForegroundColor Blue
    Write-Host "  Installs Claude Desktop + connects Higgsfield MCP"               -ForegroundColor Blue
    Write-Host "================================================================" -ForegroundColor Blue
    Write-Host ""
}
function Log  ($m) { Write-Host "[*]  $m" -ForegroundColor Cyan }
function Ok   ($m) { Write-Host "[OK] $m" -ForegroundColor Green }
function Warn ($m) { Write-Host "[!]  $m" -ForegroundColor Yellow }

Write-Banner

# ----- 1. winget detection -----
$useWinget = $false
try { winget --version | Out-Null; $useWinget = $true; Ok "winget detected." }
catch { Warn "winget not available - using direct installers." }

# ----- 2. Node.js (needed by mcp-remote bridge) -----
$nodeOk = $false
try {
    & node -v | Out-Null
    $nodeOk = $true
} catch {}

if (-not $nodeOk) {
    if ($useWinget) {
        Log "Installing Node.js LTS via winget..."
        winget install --id OpenJS.NodeJS.LTS -e --silent `
            --accept-source-agreements --accept-package-agreements
    } else {
        Log "Downloading Node.js MSI..."
        $NodeMsiUrl = "https://nodejs.org/dist/v22.14.0/node-v22.14.0-x64.msi"
        $tmpMsi = Join-Path $env:TEMP "node-x64.msi"
        Invoke-WebRequest -Uri $NodeMsiUrl -OutFile $tmpMsi -UseBasicParsing
        Start-Process msiexec.exe -ArgumentList "/i `"$tmpMsi`" /qn /norestart" -Wait
    }
} else {
    Ok "Node $(node -v) present."
}

# Refresh PATH so npx is visible in this session.
$env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + `
            [Environment]::GetEnvironmentVariable("Path","User")

# ----- 3. Claude Desktop -----
$ClaudeInstalled = $false
$ClaudeExePaths = @(
    (Join-Path $env:LOCALAPPDATA "AnthropicClaude\Claude.exe"),
    (Join-Path $env:LOCALAPPDATA "Programs\Claude\Claude.exe"),
    (Join-Path ${env:ProgramFiles} "Claude\Claude.exe")
)
foreach ($p in $ClaudeExePaths) {
    if (Test-Path $p) { $ClaudeInstalled = $true; $ClaudeExe = $p; break }
}

if ($ClaudeInstalled) {
    Ok "Claude Desktop already installed at $ClaudeExe"
} else {
    if ($useWinget) {
        Log "Installing Claude Desktop via winget..."
        try {
            winget install --id Anthropic.Claude -e --silent `
                --accept-source-agreements --accept-package-agreements
        } catch {
            Warn "winget Anthropic.Claude install failed - falling back to direct EXE."
            $useWinget = $false
        }
    }
    if (-not $useWinget) {
        Log "Downloading Claude Desktop installer..."
        $tmpExe = Join-Path $env:TEMP "claude-setup.exe"
        Invoke-WebRequest -Uri $ClaudeExeUrl -OutFile $tmpExe -UseBasicParsing
        Log "Running Claude Desktop installer (silent if supported)..."
        try {
            Start-Process -FilePath $tmpExe -ArgumentList "/S" -Wait
        } catch {
            Warn "Silent install rejected by installer - launching interactive."
            Start-Process -FilePath $tmpExe -Wait
        }
    }
    foreach ($p in $ClaudeExePaths) {
        if (Test-Path $p) { $ClaudeExe = $p; break }
    }
}

# ----- 4. Write Higgsfield MCP into Claude Desktop config -----
Log "Configuring Higgsfield MCP server in Claude Desktop..."
if (-not (Test-Path $ConfigDir)) {
    New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
}

$HiggsfieldEntry = [ordered]@{
    command = "npx"
    args    = @("-y", "mcp-remote", $HiggsfieldMcpUrl)
}

if (Test-Path $ConfigFile) {
    Copy-Item $ConfigFile "$ConfigFile.bak" -Force
    try {
        $cfg = Get-Content $ConfigFile -Raw | ConvertFrom-Json
    } catch {
        Warn "Existing config is not valid JSON - writing fresh (backup at $ConfigFile.bak)."
        $cfg = [PSCustomObject]@{}
    }

    if (-not ($cfg.PSObject.Properties.Name -contains "mcpServers")) {
        $cfg | Add-Member -NotePropertyName mcpServers -NotePropertyValue (New-Object PSObject)
    }

    if ($cfg.mcpServers.PSObject.Properties.Name -contains "higgsfield") {
        $cfg.mcpServers.higgsfield = $HiggsfieldEntry
    } else {
        $cfg.mcpServers | Add-Member -NotePropertyName higgsfield -NotePropertyValue $HiggsfieldEntry
    }

    ($cfg | ConvertTo-Json -Depth 10) | Set-Content -Path $ConfigFile -Encoding UTF8
    Ok "Merged Higgsfield entry into existing config (backup at $ConfigFile.bak)."
} else {
    $newCfg = [ordered]@{
        mcpServers = [ordered]@{
            higgsfield = $HiggsfieldEntry
        }
    }
    ($newCfg | ConvertTo-Json -Depth 10) | Set-Content -Path $ConfigFile -Encoding UTF8
    Ok "Wrote new config to $ConfigFile"
}

# ----- 5. Pre-warm the mcp-remote bridge -----
Log "Pre-fetching mcp-remote (one-time)..."
try { npx -y mcp-remote --help | Out-Null } catch { Warn "mcp-remote pre-fetch returned non-zero - it will still work on first run." }

# ----- 6. Launch Claude Desktop -----
if ($ClaudeExe -and (Test-Path $ClaudeExe)) {
    Log "Launching Claude Desktop..."
    Start-Process -FilePath $ClaudeExe
} else {
    Warn "Could not locate Claude.exe to launch - open Claude from the Start menu."
}

# ----- 7. Done -----
Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host "  Setup complete!"                                                  -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "In Claude Desktop:"
Write-Host "  1. Sign in to your Anthropic account."
Write-Host "  2. Switch to the Cowork tab."
Write-Host "  3. When Higgsfield asks to authenticate, approve it in the browser."
Write-Host ""
Write-Host "If anything is missing, the auth station at the workshop will help."
Write-Host ""
