[CmdletBinding()]
param(
    [string]$OutDir,
    [int]$RetentionDays = 7
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

if (-not $OutDir -or [string]::IsNullOrWhiteSpace($OutDir)) {
    $OutDir = Join-Path $env:TEMP 'claude-screenshots'
}

if (-not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
}

if ($RetentionDays -gt 0) {
    $cutoff = (Get-Date).AddDays(-$RetentionDays)
    Get-ChildItem -Path $OutDir -File -Filter 'ss-*' -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -lt $cutoff } |
        Remove-Item -Force -ErrorAction SilentlyContinue
}

$clip = [System.Windows.Forms.Clipboard]::GetDataObject()
if ($null -eq $clip) {
    Write-Error "Clipboard empty."
    exit 1
}

$img = $null
if ($clip.GetDataPresent([System.Windows.Forms.DataFormats]::Bitmap)) {
    $img = $clip.GetData([System.Windows.Forms.DataFormats]::Bitmap)
} elseif ($clip.GetDataPresent([System.Windows.Forms.DataFormats]::FileDrop)) {
    $files = $clip.GetData([System.Windows.Forms.DataFormats]::FileDrop)
    $imgFile = $files | Where-Object { $_ -match '\.(png|jpg|jpeg|gif|bmp|webp)$' } | Select-Object -First 1
    if ($imgFile) {
        $ext = [System.IO.Path]::GetExtension($imgFile)
        $dest = Join-Path $OutDir ("ss-{0:yyyyMMdd-HHmmss}{1}" -f (Get-Date), $ext)
        Copy-Item -Path $imgFile -Destination $dest
        Write-Output $dest
        exit 0
    }
}

if ($null -eq $img) {
    Write-Error "No image on clipboard."
    exit 1
}

$ts = Get-Date -Format 'yyyyMMdd-HHmmss-fff'
$path = Join-Path $OutDir "ss-$ts.png"
$img.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
$img.Dispose()

Write-Output $path
