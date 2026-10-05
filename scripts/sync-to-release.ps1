<#
.SYNOPSIS
    Mengunduh 114 surah MP3 Syeikh Yasser Al-Dosari dan langsung mengunggahnya ke GitHub Releases.
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$Tag = "1.0.0"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Mengambil autentikasi GitHub dari Git Credential Manager..." -ForegroundColor Cyan
$creds = "protocol=https`nhost=github.com`n`n" | git credential fill
$tokenLine = $creds | Select-String "password="
if (-not $tokenLine) {
    Write-Error "Token GitHub tidak ditemukan di Git Credential Manager."
    exit 1
}
$token = $tokenLine.Line.Replace("password=", "").Trim()

$owner = "FikFikk"
$repo = "quran-audio"
$apiBase = "https://api.github.com/repos/$owner/$repo"
$headers = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/vnd.github.v3+json"
    "User-Agent" = "QuranAudio-Sync"
}

# Menonaktifkan progress stream bawaan PowerShell agar unduhan berjalan maksimal tanpa bottleneck
$ProgressPreference = 'SilentlyContinue'

Write-Host "Mengambil informasi rilis tag '$Tag'..." -ForegroundColor Cyan
$release = Invoke-RestMethod -Uri "$apiBase/releases/tags/$Tag" -Method Get -Headers $headers -TimeoutSec 60
$uploadUrlTemplate = $release.upload_url -replace '\{\?name,label\}', ''

# Mengambil seluruh daftar aset yang sudah terunggah dengan menangani paginasi GitHub API (maksimal 100 per halaman)
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

$tempFolder = Join-Path $env:TEMP "quran_audio_sync"
if (-not (Test-Path $tempFolder)) {
    New-Item -ItemType Directory -Path $tempFolder -Force | Out-Null
}

Write-Host "Memulai proses sinkronisasi 114 Surah ke GitHub Releases ($Tag)..." -ForegroundColor Green

for ($i = 1; $i -le 114; $i++) {
    # Format nomor surah menjadi 3 digit (contoh: 001, 002, dst.)
    $surahStr = "{0:D3}" -f $i
    $fileName = "$surahStr.mp3"

    if ($existingAssets.ContainsKey($fileName)) {
        Write-Host "[$i/114] Lewati (sudah ada): $fileName" -ForegroundColor Gray
        continue
    }

    $sourceUrl = "https://cdn.equran.id/audio-full/Yasser-Al-Dosari/$fileName"
    $localFile = Join-Path $tempFolder $fileName

    Write-Host "[$i/114] Mengunduh $fileName dari sumber CDN..." -ForegroundColor White
    try {
        Invoke-WebRequest -Uri $sourceUrl -OutFile $localFile -TimeoutSec 600 -ErrorAction Stop
    } catch {
        Write-Warning "Gagal mengunduh $fileName : $($_.Exception.Message)"
        continue
    }

    Write-Host "       Mengunggah $fileName ke GitHub Release..." -ForegroundColor Cyan
    $fileBytes = [System.IO.File]::ReadAllBytes($localFile)
    $uploadUri = "$uploadUrlTemplate?name=$fileName"
    $uploadHeaders = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "audio/mpeg"
        "User-Agent" = "QuranAudio-Sync"
    }

    try {
        $res = Invoke-RestMethod -Uri $uploadUri -Method Post -Headers $uploadHeaders -Body $fileBytes -TimeoutSec 600 -ErrorAction Stop
        Write-Host "       Berhasil: $fileName terunggah!" -ForegroundColor Green
    } catch {
        Write-Warning "Gagal mengunggah $fileName : $($_.Exception.Message)"
    } finally {
        if (Test-Path $localFile) {
            Remove-Item $localFile -Force -ErrorAction SilentlyContinue
        }
    }
}

Write-Host "`nSeluruh proses sinkronisasi audio selesai!" -ForegroundColor Green
