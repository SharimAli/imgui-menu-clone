<#
.SYNOPSIS
  Creates a complete, buildable Dear ImGui + Win32/D3D11 menu Visual Studio (.sln)
  project from the skill template: toolchain check, ImGui fetch, fonts, icon header,
  and optional first build via MSBuild.

  Author: Sharim Ali (https://github.com/SharimAli)
  License: MIT

  NOTE: this file is deliberately ASCII-only. Windows PowerShell 5.1 reads .ps1
  files as ANSI unless they carry a UTF-8 BOM, so non-ASCII characters here
  break parsing on a default Windows box.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File bootstrap_project.ps1 -Path D:\Projects\MyMenu -Build
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string] $Path,
    [string] $TemplateDir,
    [string] $ImGuiTag = 'v1.91.9b',
    [switch] $SkipFonts,
    [switch] $Build,
    [switch] $InstallMissing
)

$ErrorActionPreference = 'Stop'
function Info($m) { Write-Host "[bootstrap] $m" }
function Warn($m) { Write-Host "[bootstrap] $m" -ForegroundColor Yellow }

if (-not $TemplateDir) {
    $TemplateDir = Join-Path (Split-Path $PSScriptRoot -Parent) 'assets\template'
}
if (-not (Test-Path $TemplateDir)) { throw "Template not found: $TemplateDir" }

# --- 1. toolchain -----------------------------------------------------------
$missing = @()

if (-not (Get-Command git -ErrorAction SilentlyContinue)) { $missing += 'Git.Git' }

$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
$msbuild = $null
if (Test-Path $vswhere) {
    $msbuild = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -find "MSBuild\**\Bin\MSBuild.exe" | Select-Object -First 1
}
if (-not $msbuild) {
    $cmd = Get-Command msbuild -ErrorAction SilentlyContinue
    if ($cmd) { $msbuild = $cmd.Source }
}
if (-not $msbuild) { $missing += 'Microsoft.VisualStudio.2022.BuildTools' }

if ($missing.Count) {
    Warn "Missing toolchain components: $($missing -join ', ')"
    if ($InstallMissing) {
        foreach ($id in $missing) {
            Info "winget install $id"
            if ($id -like '*BuildTools*') {
                winget install --id $id -e --accept-package-agreements --accept-source-agreements --override '--quiet --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended'
            } else {
                winget install --id $id -e --accept-package-agreements --accept-source-agreements
            }
        }
        Warn 'Toolchain installed. Open a NEW shell so PATH is refreshed, then re-run.'
        return
    }
    Warn 'Re-run with -InstallMissing, or install manually:'
    foreach ($id in $missing) { Warn "  winget install --id $id -e" }
    if (-not $msbuild) { throw 'Visual Studio / MSBuild with C++ tools is required.' }
}

# --- 2. project skeleton ----------------------------------------------------
if (-not (Test-Path $Path)) { New-Item -ItemType Directory -Path $Path -Force | Out-Null }
Info "Copying template (.sln + .vcxproj) -> $Path"
Copy-Item -Path (Join-Path $TemplateDir '*') -Destination $Path -Recurse -Force

# --- 3. fetch Dear ImGui into vendor\imgui ----------------------------------
$imguiDir = Join-Path $Path 'vendor\imgui'
if (-not (Test-Path (Join-Path $imguiDir 'imgui.h'))) {
    Info "Fetching Dear ImGui ($ImGuiTag) -> $imguiDir"
    New-Item -ItemType Directory -Path (Split-Path $imguiDir -Parent) -Force | Out-Null
    & git -c advice.detachedHead=false clone --depth 1 --branch $ImGuiTag https://github.com/ocornut/imgui.git $imguiDir
    if ($LASTEXITCODE -ne 0) { throw "Failed to clone Dear ImGui ($ImGuiTag)." }
} else {
    Info "Dear ImGui already present at $imguiDir"
}

$fontDir = Join-Path $Path 'assets\fonts'
New-Item -ItemType Directory -Path $fontDir -Force | Out-Null

# --- 4. fonts + icon header -------------------------------------------------
# Glyphs identical to the reference cannot be guaranteed from a screenshot.
# Font Awesome 6 Free is the closest widely available match and ships named
# defines (ICON_FA_*), which removes all glyph-mapping guesswork.
if (-not $SkipFonts) {
    $assets = @(
        @{ Url = 'https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Medium.ttf';       Out = (Join-Path $fontDir 'Poppins-Medium.ttf') },
        @{ Url = 'https://github.com/google/fonts/raw/main/ofl/bungee/Bungee-Regular.ttf';        Out = (Join-Path $fontDir 'Bungee-Regular.ttf') },
        @{ Url = 'https://github.com/FortAwesome/Font-Awesome/raw/6.x/webfonts/fa-solid-900.ttf'; Out = (Join-Path $fontDir 'fa-solid-900.ttf') },
        @{ Url = 'https://raw.githubusercontent.com/juliettef/IconFontCppHeaders/main/IconsFontAwesome6.h'; Out = (Join-Path $Path 'ui\IconsFontAwesome6.h') }
    )
    $prevProgress = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
    foreach ($a in $assets) {
        $leaf = Split-Path $a.Out -Leaf
        try {
            Info "Fetching $leaf"
            Invoke-WebRequest -Uri $a.Url -OutFile $a.Out -UseBasicParsing -TimeoutSec 60
        } catch {
            Warn ("Failed: " + $a.Url + " -- " + $_.Exception.Message)
        }
    }
    $ProgressPreference = $prevProgress
}

# --- 5. build .sln with MSBuild ---------------------------------------------
Push-Location $Path
try {
    if ($Build) {
        Info "Building menu.sln (Release|x64) with MSBuild"
        & $msbuild 'menu.sln' '/p:Configuration=Release' '/p:Platform=x64' '/m' '/v:minimal'
        if ($LASTEXITCODE -ne 0) { throw 'MSBuild failed.' }

        $exe = Get-ChildItem -Path (Join-Path $Path 'build') -Filter 'menu.exe' -Recurse | Select-Object -First 1
        if ($exe) { Info ("OK -> " + $exe.FullName) }
    }
} finally {
    Pop-Location
}

Info 'Done.'
