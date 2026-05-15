# testing-tools

Kehittäjätyökalut muunnoslogiikan testaamiseen. Tarkoitettu omaan käyttöön ja forkaajille — ei kuulu normaaliin käyttöönottoon.

## Vaatimukset

- `pip install 'markitdown[all]' pymupdf4llm` molemmat asennettuna
- `src\config.ini` olemassa (kopioi `src\config.ini.example`)

## Testiaineiston lataus

```powershell
# Lataa testiaineisto (markitdown-projektin testitiedostot)
.\testing-tools\fetch-test-files.ps1

# Pakota uudelleenlataus
.\testing-tools\fetch-test-files.ps1 -Force
```

Tiedostot tallennetaan `tests\test-files\`-kansioon (gitignoressa).

## Muunnoksen testaus

```powershell
# Yksittäinen tiedosto, käyttää config.ini:n pdf_engine-asetusta
.\testing-tools\verify-conversion.ps1 -TestFile .\tests\test-files\test.docx

# Pakota tietty moottori — hyödyllinen rinnakkaisvertailuun
.\testing-tools\verify-conversion.ps1 -TestFile .\tests\test-files\test.pdf -Engine markitdown
.\testing-tools\verify-conversion.ps1 -TestFile .\tests\test-files\test.pdf -Engine pymupdf4llm
```

Skripti kopioi testitiedoston `tests\watch-dir\`-kansioon ja ajaa `batch2md.py`:n sitä vasten — tuotannon `watch_dir` pysyy koskemattomana. Tulos löytyy `tests\watch-dir\VVVVKKPP-HHMMSS\`-alikansiosta.

## Tyypillinen testauskulku

1. Lataa testiaineisto: `fetch-test-files.ps1`
2. Testaa haluamasi tiedostot `verify-conversion.ps1`:llä
3. Vertaa `.md`-tulosteet visuaalisesti eri moottoreilla
4. Vaihda `src\config.ini`:ssä `pdf_engine`-asetus ja ota käyttöön
