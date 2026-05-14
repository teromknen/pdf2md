# pdf2md

Muuntaa PDF- ja muita asiakirjoja Markdown-muotoon LLM-käyttöä varten (token-optimoitu).

## Vaatimukset

- Python 3.10+
- `pip install pymupdf4llm watchdog`

## Rakenne

```
src/
  batch2md.py        – eräkonversio, ajetaan manuaalisesti tai watcherin kautta
  watch.py           – tarkkailee kansiota ja triggeröi batch2md.py debounce-logiikalla
dist/                – deploytut versiot (deploy.ps1 kopioi tänne)
config.ini.example   – konfiguraatiomalli, kopioi nimellä config.ini
deploy.ps1           – kopioi src/ -> dist/ -> scripts_dir
```

## Konfigurointi

Kopioi `src/config.ini.example` nimellä `src/config.ini` ja muokkaa polut:

```ini
[paths]
watch_dir = C:\Data\PDF2MD              # kansio johon PDF:t pudotetaan
scripts_dir = C:\Tools\python-scripts   # kansio johon skriptit deploytaan

[settings]
debounce_seconds = 10                   # odotusaika sekunteina ennen konversiota
```

Luo `watch_dir`-kansio itse ennen käyttöä. `scripts_dir` luodaan automaattisesti deployn yhteydessä.


## Käyttö

1. Pudota tuettuja tiedostoja `watch_dir`-kansioon
2. Watcher triggeröi konversion automaattisesti `debounce_seconds`-odotusajan jälkeen
3. Tulosteet löytyvät `watch_dir\VVVVKKPP-HHMMSS\`

Onnistuneet originaalit siirtyvät `archive\`-alikansioon, epäonnistuneet `errors\`-alikansioon. Loki kirjoitetaan `archive\convert.log`-tiedostoon.

## Tuetut formaatit

PDF, EPUB, XPS

## Deploy

```powershell
.\deploy.ps1
```