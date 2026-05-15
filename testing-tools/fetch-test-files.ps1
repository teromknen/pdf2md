# fetch-test-files.ps1
#
# Lataa testiaineiston Microsoft markitdown -projektin testikansiosta.
# Tiedostot tallennetaan <repojuuri>\tests\test-files\-kansioon (gitignoressa).
#
# Kaytto:
#   .\testing-tools\fetch-test-files.ps1            # lataa vain puuttuvat tiedostot
#   .\testing-tools\fetch-test-files.ps1 -Force     # lataa kaikki uudelleen
#
# Lahde: https://github.com/microsoft/markitdown/tree/main/packages/markitdown/tests/test_files

param(
    [switch]$Force
)

# $PSScriptRoot on testing-tools\, noustaan ylos repojuureen
$repoRoot = (Resolve-Path "$PSScriptRoot\..").Path
$destDir  = "$repoRoot\tests\test-files"
$baseUrl  = "https://raw.githubusercontent.com/microsoft/markitdown/main/packages/markitdown/tests/test_files"

# Ladattavat tiedostot - audio, zip ja random.bin jätetty pois
$files = @(
    # PDF
    "test.pdf"
    "REPAIR-2022-INV-001_multipage.pdf"
    "SPARSE-2024-INV-1234_borderless_table.pdf"
    "MEDRPT-2024-PAT-3847_medical_report_scan.pdf"
    "RECEIPT-2024-TXN-98765_retail_purchase.pdf"
    "masterformat_partial_numbering.pdf"
    "movie-theater-booking-2024.pdf"

    # Word
    "test.docx"
    "test_with_comment.docx"
    "equations.docx"
    "rlink.docx"

    # Muut Office
    "test.pptx"
    "test.xlsx"
    "test.xls"

    # Web ja teksti
    "test_blog.html"
    "test_wikipedia.html"
    "test_serp.html"
    "test.json"
    "test_rss.xml"
    "test_mskanji.csv"

    # Muut
    "test.epub"
    "test.jpg"
    "test_llm.jpg"
)

if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir | Out-Null
    Write-Host "Luotu kansio: $destDir"
}

$ladattu  = 0
$ohitettu = 0
$virhe    = 0

foreach ($file in $files) {
    $dest = "$destDir\$file"

    if ((Test-Path $dest) -and -not $Force) {
        $ohitettu++
        continue
    }

    try {
        Invoke-WebRequest -Uri "$baseUrl/$file" -OutFile $dest -ErrorAction Stop
        Write-Host "OK:  $file"
        $ladattu++
    } catch {
        Write-Warning "VIRHE: $file - $_"
        $virhe++
    }
}

Write-Host ""
Write-Host "Ladattu: $ladattu | Ohitettu: $ohitettu | Virheita: $virhe"
Write-Host "Tiedostot: $destDir"
