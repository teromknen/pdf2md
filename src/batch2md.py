import pathlib, re, datetime, shutil, configparser
import pymupdf4llm
from markitdown import MarkItDown

config = configparser.ConfigParser()
config.read(pathlib.Path(__file__).parent / "config.ini")

src        = pathlib.Path(config["paths"]["watch_dir"])
pdf_engine = config["settings"].get("pdf_engine", "pymupdf4llm").strip().lower()

PYMUPDF_FORMATS    = {".pdf", ".epub", ".xps"}
MARKITDOWN_FORMATS = {".pdf", ".epub", ".docx", ".pptx", ".xlsx",
                      ".html", ".htm", ".csv", ".json", ".xml", ".zip",
                      ".jpg", ".jpeg", ".png", ".gif", ".webp"}

if pdf_engine == "pymupdf4llm":
    supported = PYMUPDF_FORMATS | MARKITDOWN_FORMATS
else:
    supported = MARKITDOWN_FORMATS

files = [f for f in src.iterdir() if f.suffix.lower() in supported]

if not files:
    exit()

md_client = MarkItDown()

def convert(f: pathlib.Path) -> str:
    suffix = f.suffix.lower()
    if pdf_engine == "pymupdf4llm" and suffix in PYMUPDF_FORMATS:
        md = pymupdf4llm.to_markdown(str(f), header=False, footer=False)
    else:
        md = md_client.convert_local(str(f)).text_content
    return re.sub(r'\n{3,}', '\n\n', md)

ts  = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
dst = src / ts
dst.mkdir(parents=True, exist_ok=True)

archive   = None
errors    = None
log_lines = [f"Ajo: {ts}\n", f"Moottori: {pdf_engine}\n", f"Tiedostoja: {len(files)}\n\n"]

for f in files:
    try:
        md = convert(f)
        (dst / f.with_suffix('.md').name).write_bytes(md.encode())
        if archive is None:
            archive = dst / "archive"
            archive.mkdir()
        shutil.move(str(f), archive / f.name)
        log_lines.append(f"OK:    {f.name}\n")
    except Exception as e:
        if errors is None:
            errors = dst / "errors"
            errors.mkdir()
        shutil.move(str(f), errors / f.name)
        log_lines.append(f"VIRHE: {f.name}: {e}\n")

log_lines.append(f"\nValmis: {dst}\n")
if archive is None:
    archive = dst / "archive"
    archive.mkdir()
(archive / "convert.log").write_text("".join(log_lines), encoding="utf-8")
