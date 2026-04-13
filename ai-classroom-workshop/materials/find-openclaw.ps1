# OpenClaw Diagnostic Script for Windows
# Run this in PowerShell as Administrator for best results
# Created for finding HIM (7800X3D) OpenClaw installation

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   OpenClaw Diagnostic Tool" -ForegroundColor Cyan
Write-Host "   Finding your installation..." -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$found = @()

# 1. Check if openclaw command is available
Write-Host "[1/8] Checking PATH for 'openclaw' command..." -ForegroundColor Yellow
try {
    $openclawCmd = Get-Command openclaw -ErrorAction SilentlyContinue
    if ($openclawCmd) {
        Write-Host "   ✅ Found: $($openclawCmd.Source)" -ForegroundColor Green
        $found += $openclawCmd.Source
    } else {
        Write-Host "   ❌ 'openclaw' not in PATH" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Not found in PATH" -ForegroundColor Red
}

# 2. Check npm global installation
Write-Host "`n[2/8] Checking npm global packages..." -ForegroundColor Yellow
try {
    $npmGlobal = npm list -g --depth=0 2>$null | Select-String "openclaw"
    if ($npmGlobal) {
        Write-Host "   ✅ Found in npm global:" -ForegroundColor Green
        $npmGlobal | ForEach-Object { Write-Host "      $_" -ForegroundColor Gray }
    } else {
        Write-Host "   ❌ Not in npm global packages" -ForegroundColor Red
    }
} catch {
    Write-Host "   ⚠️  npm not available or error occurred" -ForegroundColor Yellow
}

# 3. Check common installation paths
Write-Host "`n[3/8] Checking common installation paths..." -ForegroundColor Yellow
$commonPaths = @(
    "$env:ProgramFiles\nodejs\openclaw*",
    "$env:ProgramFiles\nodejs\node_modules\openclaw",
    "$env:LOCALAPPDATA\Programs\OpenClaw",
    "$env:ProgramFiles\OpenClaw",
    "C:\openclaw",
    "C:\Program Files\OpenClaw",
    "$env:APPDATA\npm\node_modules\openclaw",
    "$env:USERPROFILE\AppData\Roaming\npm\node_modules\openclaw"
)

foreach ($path in $commonPaths) {
    if (Test-Path $path) {
        Write-Host "   ✅ Found: $path" -ForegroundColor Green
        $found += $path
    }
}

if ($found.Count -eq 0) {
    Write-Host "   ❌ No installations found in common paths" -ForegroundColor Red
}

# 4. Check for workspace directory
Write-Host "`n[4/8] Looking for OpenClaw workspace..." -ForegroundColor Yellow
$workspacePaths = @(
    "$env:USERPROFILE\.openclaw\workspace",
    "$env:USERPROFILE\openclaw-workspace",
    "C:\openclaw-workspace",
    "$env:LOCALAPPDATA\.openclaw\workspace"
)

$workspaceFound = $false
foreach ($path in $workspacePaths) {
    if (Test-Path $path) {
        Write-Host "   ✅ Found workspace: $path" -ForegroundColor Green
        $workspaceFound = $true
        
        # Check for key files
        $identityFile = Join-Path $path "IDENTITY.md"
        $userFile = Join-Path $path "USER.md"
        $memoryFile = Join-Path $path "MEMORY.md"
        
        if (Test-Path $identityFile) {
            Write-Host "      📄 IDENTITY.md exists" -ForegroundColor Gray
        }
        if (Test-Path $userFile) {
            Write-Host "      📄 USER.md exists" -ForegroundColor Gray
        }
        if (Test-Path $memoryFile) {
            Write-Host "      📄 MEMORY.md exists" -ForegroundColor Gray
        }
    }
}

if (-not $workspaceFound) {
    Write-Host "   ❌ No workspace found" -ForegroundColor Red
}

# 5. Check for running gateway processes
Write-Host "`n[5/8] Checking for running OpenClaw processes..." -ForegroundColor Yellow
$processes = Get-Process -Name "*claw*", "*node*" -ErrorAction SilentlyContinue | 
    Where-Object { $_.ProcessName -match "claw|node" }

if ($processes) {
    foreach ($proc in $processes) {
        Write-Host "   ✅ Found process: $($proc.ProcessName) (PID: $($proc.Id))" -ForegroundColor Green
        try {
            $cmdLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $($proc.Id)").CommandLine
            if ($cmdLine -match "openclaw|gateway") {
                Write-Host "      Command: $cmdLine" -ForegroundColor Gray
            }
        } catch {}
    }
} else {
    Write-Host "   ❌ No OpenClaw processes running" -ForegroundColor Red
}

# 6. Check Node.js installation
Write-Host "`n[6/8] Checking Node.js installation..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version 2>$null
    $npmVersion = npm --version 2>$null
    if ($nodeVersion) {
        Write-Host "   ✅ Node.js: $nodeVersion" -ForegroundColor Green
        Write-Host "   ✅ npm: $npmVersion" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Node.js not found" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Node.js not installed or not in PATH" -ForegroundColor Red
}

# 7. Check configuration files
Write-Host "`n[7/8] Checking for OpenClaw config files..." -ForegroundColor Yellow
$configPaths = @(
    "$env:USERPROFILE\.openclaw\config.yaml",
    "$env:USERPROFILE\.openclaw\config.yml",
    "$env:USERPROFILE\.openclaw\.env",
    "$env:APPDATA\OpenClaw\config.yaml",
    "C:\openclaw\config.yaml"
)

$configFound = $false
foreach ($path in $configPaths) {
    if (Test-Path $path) {
        Write-Host "   ✅ Found config: $path" -ForegroundColor Green
        $configFound = $true
    }
}

if (-not $configFound) {
    Write-Host "   ❌ No config files found" -ForegroundColor Red
}

# 8. Summary and recommendations
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   SUMMARY" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

if ($found.Count -gt 0 -or $workspaceFound) {
    Write-Host "✅ OpenClaw appears to be installed on this system!" -ForegroundColor Green
    
    Write-Host "`n📋 Quick Commands:" -ForegroundColor Yellow
    Write-Host "   Start gateway:     openclaw gateway start" -ForegroundColor Gray
    Write-Host "   Check status:      openclaw status" -ForegroundColor Gray
    Write-Host "   View logs:         openclaw logs" -ForegroundColor Gray
    
    if ($workspaceFound) {
        Write-Host "`n📁 Your workspace should be at:" -ForegroundColor Yellow
        $workspacePaths | Where-Object { Test-Path $_ } | ForEach-Object {
            Write-Host "   $_" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "❌ OpenClaw installation not found on this system." -ForegroundColor Red
    
    Write-Host "`n🔧 Installation Options:" -ForegroundColor Yellow
    Write-Host "   1. Install via npm (recommended):" -ForegroundColor White
    Write-Host "      npm install -g openclaw" -ForegroundColor Gray
    Write-Host "`n   2. Or download from:" -ForegroundColor White
    Write-Host "      https://docs.openclaw.ai/installation" -ForegroundColor Gray
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Press any key to exit..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
