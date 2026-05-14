# pdf2md

Muuntaa PDF- ja muita asiakirjoja Markdown-muotoon LLM-käyttöä varten (token-optimoitu).

## Vaatimukset

- Python 3.10+
- `pip install pymupdf4llm watchdog`

## Rakenne

```
src/
  batch2md.py   – eräkonversio, ajetaan manuaalisesti tai watcherin kautta
  watch.py      – tarkkailee kansiota ja triggeröi batch2md.py debounce-logiikalla
dist/           – deploytut versiot (deploy.ps1 kopioi tänne)
deploy.ps1      – kopioi src/ -> dist/ -> C:\Tools\python-scripts\
```

## Käyttö

1. Pudota PDF-tiedostot kansioon `C:\Data\PDF2MD\`
2. Watcher triggeröi konversion automaattisesti 10 sekunnin hiljaisuuden jälkeen
3. Tulosteet löytyvät `C:\Data\PDF2MD\VVVVKKPP-HHMMSS\`

Onnistuneet originaalit siirtyvät `archive\`-alikansioon, epäonnistuneet `errors\`-alikansioon. Loki kirjoitetaan `archive\convert.log`-tiedostoon.

## Tuetut formaatit

PDF, EPUB, XPS

## Deploy

```powershell
.\deploy.ps1
```