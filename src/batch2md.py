import pymupdf4llm, pathlib, re, datetime, shutil, configparser

config = configparser.ConfigParser()
config.read(pathlib.Path(__file__).parent / "config.ini")

src = pathlib.Path(config["paths"]["watch_dir"])
supported = {".pdf", ".epub", ".xps"}
files = [f for f in src.iterdir() if f.suffix.lower() in supported]

if not files:
    exit()

ts  = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
dst = src / ts
dst.mkdir(parents=True, exist_ok=True)

archive = None
errors  = None
log_lines = [f"Ajo: {ts}\n", f"Tiedostoja: {len(files)}\n\n"]

for pdf in files:
    try:
        md = pymupdf4llm.to_markdown(str(pdf), header=False, footer=False)
        md = re.sub(r'\n{3,}', '\n\n', md)
        (dst / pdf.with_suffix('.md').name).write_bytes(md.encode())
        if archive is None:
            archive = dst / "archive"
            archive.mkdir()
        shutil.move(str(pdf), archive / pdf.name)
        log_lines.append(f"OK:    {pdf.name}\n")
    except Exception as e:
        if errors is None:
            errors = dst / "errors"
            errors.mkdir()
        shutil.move(str(pdf), errors / pdf.name)
        log_lines.append(f"VIRHE: {pdf.name}: {e}\n")

log_lines.append(f"\nValmis: {dst}\n")
if archive is None:
    archive = dst / "archive"
    archive.mkdir()
(archive / "convert.log").write_text("".join(log_lines), encoding="utf-8")