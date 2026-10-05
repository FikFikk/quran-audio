<#
.SYNOPSIS
    Skrip otomatis untuk mengunggah 114 berkas MP3 murottal ke GitHub Releases.

.PARAMETER AudioFolder
    Jalur direktori lokal tempat berkas 001.mp3 hingga 114.mp3 berada.

.PARAMETER Tag
    Nama tag rilis GitHub (bawaan: v1.0.0).

.EXAMPLE
    .\upload-release.ps1 -AudioFolder "C:\Users\Fikri\Music\Yasser-Al-Dosari"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$AudioFolder,

    [Parameter(Mandatory = $false)]
    [string]$Tag = "1.0.0",

    [Parameter(Mandatory = $false)]
    [string]$ReleaseTitle = "Murottal Syeikh Yasser Al-Dosari 114 Surah"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Menonaktifkan progress stream bawaan PowerShell agar proses unggah lebih stabil
$ProgressPreference = 'SilentlyContinue'

if (-not (Test-Path $AudioFolder)) {
    Write-Error "Direktori audio tidak ditemukan: $AudioFolder"
    exit 1
}

Write-Host "Mengambil autentikasi GitHub dari Git Credential Manager..." -ForegroundColor Cyan
$creds = "protocol=https`nhost=github.com`n`n" | git credential fill
$tokenLine = $creds | Select-String "password="
if (-not $tokenLine) {
    Write-Error "Tidak dapat menemukan token GitHub di Git Credential Manager."
    exit 1
}
$token = $tokenLine.Line.Replace("password=", "").Trim()

$owner = "FikFikk"
$repo = "quran-audio"
$apiBase = "https://api.github.com/repos/$owner/$repo"
$headers = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/vnd.github.v3+json"
    "User-Agent" = "QuranAudio-Uploader"
}

# 1. Periksa atau buat rilis baru
Write-Host "Memeriksa rilis tag '$Tag' di GitHub..." -ForegroundColor Cyan
$release = $null
try {
    $release = Invoke-RestMethod -Uri "$apiBase/releases/tags/$Tag" -Method Get -Headers $headers -TimeoutSec 60 -ErrorAction Stop
    Write-Host "Rilis '$Tag' sudah ada (ID: $($release.id))." -ForegroundColor Green
} catch {
    Write-Host "Rilis belum ada. Membuat rilis baru '$Tag'..." -ForegroundColor Yellow
    $body = @{
        tag_name = $Tag
        name = $ReleaseTitle
        body = "Dataset berkas audio murottal studio lengkap 114 Surah oleh Syeikh Yasser Al-Dosari."
        draft = $false
        prerelease = $false
    } | ConvertTo-Json

    $release = Invoke-RestMethod -Uri "$apiBase/releases" -Method Post -Headers $headers -Body $body -ContentType "application/json" -TimeoutSec 60
    Write-Host "Berhasil membuat rilis baru: $($release.html_url)" -ForegroundColor Green
}

# Ambil upload URL bersih
$uploadUrlTemplate = $release.upload_url -replace '\{\?name,label\}', ''

# 2. Ambil daftar file yang sudah terunggah di rilis ini dengan paginasi
$existingAssets = @{}
$page = 1
do {
    $assetsUri = "$apiBase/releases/$($release.id)/assets?per_page=100&page=$page"
    $pageAssets = Invoke-RestMethod -Uri $assetsUri -Method Get -Headers $headers -TimeoutSec 60
    if ($pageAssets) {
        foreach ($asset in $pageAssets) {
            $existingAssets[$asset.name] = $asset.id
        }
        $page++
    }
} while ($pageAssets -and $pageAssets.Count -eq 100)

# 3. Unggah seluruh file audio MP3
$mp3Files = Get-ChildItem -Path $AudioFolder -Filter "*.mp3" | Sort-Object Name
if ($mp3Files.Count -eq 0) {
    Write-Warning "Tidak ada berkas .mp3 ditemukan di $AudioFolder"
    exit 0
}

Write-Host "Ditemukan $($mp3Files.Count) berkas audio untuk diunggah ke rilis..." -ForegroundColor Cyan

$index = 1
foreach ($file in $mp3Files) {
    $fileName = $file.Name
    if ($existingAssets.ContainsKey($fileName)) {
        Write-Host "[$index/$($mp3Files.Count)] Lewati (sudah ada): $fileName" -ForegroundColor Gray
        $index++
        continue
    }

    Write-Host "[$index/$($mp3Files.Count)] Mengunggah: $fileName ($([math]::Round($file.Length / 1MB, 2)) MB)..." -ForegroundColor White
    $fileBytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $uploadUri = "$uploadUrlTemplate?name=$fileName"

    $uploadHeaders = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "audio/mpeg"
        "User-Agent" = "QuranAudio-Uploader"
    }

    try {
        $uploadResult = Invoke-RestMethod -Uri $uploadUri -Method Post -Headers $uploadHeaders -Body $fileBytes -TimeoutSec 600 -ErrorAction Stop
        Write-Host "   Selesai: $($uploadResult.browser_download_url)" -ForegroundColor Green
    } catch {
        Write-Error "   Gagal mengunggah $fileName : $($_.Exception.Message)"
    }
    $index++
}

Write-Host "`nSeluruh proses unggah berkas audio selesai!" -ForegroundColor Green
