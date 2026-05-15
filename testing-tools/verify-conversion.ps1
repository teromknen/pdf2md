# verify-conversion.ps1
#
# Testaa pdf2md-muunnoslogiikan worktree-haarasta ilman että worktreehen
# tarvitsee koskea muuten kuin kopioimalla gitignoressa oleva config.ini.
#
# Testitiedosto kopioidaan tilapäiseen tests\watch-dir\-kansioon, josta
# batch2md.py ajaa muunnoksen. Tuotannon watch_dir pysyy koskemattomana.
#
# Käyttö:
#   .\testing-tools\verify-conversion.ps1 -TestFile .\tests\test-files\test.docx
#   .\testing-tools\verify-conversion.ps1 -TestFile .\tests\test-files\test.pdf -Engine pymupdf4llm
#
# Parametrit:
#   -TestFile   Pakollinen. Muunnettava testitiedosto.
#   -Engine     Valinnainen. Ohittaa config.ini:n pdf_engine-asetuksen
#               testitarkoituksessa. Arvot: markitdown | pymupdf4llm

param(
    [Parameter(Mandatory)][string]$TestFile,
    [ValidateSet("markitdown", "pymupdf4llm")][string]$Engine
)

# Varmista oikea merkistokodaus konsolille
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- Polut ---
# $PSScriptRoot on testing-tools\, joten noustaan ylös repojuureen
$repoRoot       = (Resolve-Path "$PSScriptRoot\..").Path
$worktreeSrc    = "$repoRoot\.claude\worktrees\pensive-cerf-680154\src"
$mainConfig     = "$repoRoot\src\config.ini"
$worktreeConfig = "$worktreeSrc\config.ini"
$script         = "$worktreeSrc\batch2md.py"
$testWatchDir   = "$repoRoot\tests\watch-dir"

# --- Tarkistukset ---

if (-not (Test-Path $TestFile)) {
    Write-Error "Testitiedostoa ei löydy: $TestFile"
    exit 1
}

if (-not (Test-Path $script)) {
    Write-Error "Skriptiä ei löydy worktreestä: $script"
    Write-Error "Onko worktree-haara vielä olemassa?"
    exit 1
}

if (-not (Test-Path $mainConfig)) {
    Write-Error "config.ini puuttuu: $mainConfig"
    Write-Error "Kopioi src\config.ini.example nimellä src\config.ini ja muokkaa polut."
    exit 1
}

# --- Valmistele tilapäinen watch-dir ---
# Tyhjennä edellisen ajon jäämät, kopioi testitiedosto sinne
if (Test-Path $testWatchDir) {
    Remove-Item "$testWatchDir\*" -Recurse -Force
} else {
    New-Item -ItemType Directory -Path $testWatchDir | Out-Null
}
Copy-Item $TestFile $testWatchDir
Write-Host "Testitiedosto kopioitu: $testWatchDir\$(Split-Path $TestFile -Leaf)"

# --- Luo testi-config worktreehen ---
# Kopioi ensin oikea config, sitten ylikirjoita watch_dir testipolulla.
# config.ini on gitignoressa, joten tämä ei vaikuta PR:ään tai haaraan.
Copy-Item $mainConfig $worktreeConfig -Force
$content = Get-Content $worktreeConfig -Raw
$content = $content -replace "watch_dir\s*=.*", "watch_dir = $testWatchDir"

# Vaihda moottori jos -Engine annettu
if ($Engine) {
    if ($content -match "pdf_engine\s*=") {
        $content = $content -replace "pdf_engine\s*=.*", "pdf_engine = $Engine"
    } else {
        $content += "`npdf_engine = $Engine"
    }
    Write-Host "Testataan moottorilla: $Engine"
}

# Kirjoita ilman BOM-tavua - Python configparser ei osaa lukea BOMia
[System.IO.File]::WriteAllText($worktreeConfig, $content, [System.Text.UTF8Encoding]::new($false))

# --- Aja muunnos ---
Write-Host ""
Write-Host "Muunnetaan: $(Split-Path $TestFile -Leaf)"
Write-Host "---"
python $script

# --- Näytä tulos ---
# batch2md.py luo VVVVKKPP-HHMMSS-alikansion watch-diriin
$resultDir = Get-ChildItem $testWatchDir -Directory | Where-Object { $_.Name -match '^\d{8}-\d{6}$' } | Select-Object -Last 1
if ($resultDir) {
    $mdFile = Get-ChildItem $resultDir.FullName -Filter "*.md" | Select-Object -First 1
    if ($mdFile) {
        Write-Host ""
        Write-Host "--- Tulosteen alku ($($mdFile.Name)) ---"
        Get-Content $mdFile.FullName -TotalCount 20
        Write-Host "..."
        Write-Host ""
        Write-Host "Koko tulos: $($mdFile.FullName)"
    }
    $logFile = "$($resultDir.FullName)\archive\convert.log"
    if (Test-Path $logFile) {
        Write-Host ""
        Write-Host "--- Loki ---"
        Get-Content $logFile
    }
} else {
    Write-Warning "Tuloshakemistoa ei löydy. Tarkista loki tai virheilmoitukset yllä."
}
