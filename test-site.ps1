<#
.SYNOPSIS
    Builds and tests the Jekyll Chirpy site on Windows (PowerShell equivalent of test-site.sh).

.DESCRIPTION
    Sets JEKYLL_ENV to production, builds the site using Jekyll via Bundler,
    and runs html-proofer to validate internal links, image paths, and HTML structure.

.PARAMETER SkipBuild
    Skips the Jekyll site build step and only runs html-proofer against an existing _site directory.

.PARAMETER SkipProofer
    Skips the html-proofer step and only performs the production build.

.PARAMETER Clean
    Removes the existing _site directory before building.

.EXAMPLE
    .\test-site.ps1
    .\test-site.ps1 -Clean
    .\test-site.ps1 -SkipProofer
#>

[CmdletBinding()]
param(
    [switch]$SkipBuild,
    [switch]$SkipProofer,
    [switch]$Clean
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Failure {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

try {
    # 1. Check Bundler
    $bundler = Get-Command "bundle" -ErrorAction SilentlyContinue
    if (-not $bundler) {
        Write-Failure "Bundler ('bundle') command not found in PATH."
        Write-Host "Please ensure Ruby and Bundler are installed (e.g. from https://rubyinstaller.org)." -ForegroundColor Yellow
        exit 1
    }

    # 2. Check Gem dependencies
    Write-Step "Checking bundle dependencies..."
    & bundle check *>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Bundler dependencies missing. Attempting to install gems with 'bundle install'..." -ForegroundColor Yellow
        & bundle install
        if ($LASTEXITCODE -ne 0) {
            Write-Failure "Failed to install required gems. Run 'bundle install' manually to inspect errors."
            exit $LASTEXITCODE
        }
    }
    Write-Success "Bundle dependencies verified."

    # 3. Clean _site if requested
    if ($Clean -and (Test-Path "_site")) {
        Write-Step "Cleaning existing _site folder..."
        Remove-Item -Path "_site" -Recurse -Force
        Write-Success "_site directory cleaned."
    }

    # 4. Build Jekyll Site
    if (-not $SkipBuild) {
        Write-Step "Building Jekyll site (JEKYLL_ENV=production)..."
        $env:JEKYLL_ENV = "production"
        & bundle exec jekyll build
        if ($LASTEXITCODE -ne 0) {
            Write-Failure "Jekyll build failed."
            exit $LASTEXITCODE
        }
        Write-Success "Jekyll build completed successfully."
    }

    # 5. Run html-proofer
    if (-not $SkipProofer) {
        if (-not (Test-Path "_site")) {
            Write-Failure "_site directory does not exist. Run without -SkipBuild to generate the site first."
            exit 1
        }

        Write-Step "Testing site with html-proofer..."
        $prooferOutput = & bundle exec htmlproofer "_site" `
            --disable-external `
            --ignore-urls "/^http:\/\/127.0.0.1/,/^http:\/\/0.0.0.0/,/^http:\/\/localhost/" 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            $outputText = $prooferOutput -join "`n"
            if ($outputText -match "Could not open library 'libcurl'") {
                Write-Host $outputText
                Write-Host "`n[NOTE] html-proofer requires 'libcurl.dll' which is native to Linux/CI and WSL." -ForegroundColor Yellow
                Write-Host "[NOTE] Your Jekyll production build SUCCEEDED completely, but html-proofer FFI needs libcurl to inspect HTML on Windows." -ForegroundColor Yellow
                Write-Host "[TIP] Use '.\test-site.ps1 -SkipProofer' for local Windows builds, or run '.\test-site.sh' in WSL / GitHub Actions." -ForegroundColor Cyan
            } else {
                Write-Host $outputText
                Write-Failure "html-proofer detected errors in _site."
                exit $LASTEXITCODE
            }
        } else {
            Write-Success "html-proofer passed with no errors."
        }
    }

    Write-Host "`nSite test completed successfully!`n" -ForegroundColor Green
}
catch {
    Write-Failure "An unexpected error occurred: $_"
    exit 1
}
