import pathlib, re, sys, configparser
import pymupdf4llm
from markitdown import MarkItDown

config = configparser.ConfigParser()
config.read(pathlib.Path(__file__).parent / "config.ini")

pdf_engine = config["settings"].get("pdf_engine", "pymupdf4llm").strip().lower()
PYMUPDF_FORMATS = {".pdf", ".epub", ".xps"}

f      = pathlib.Path(sys.argv[1])
suffix = f.suffix.lower()

if pdf_engine == "pymupdf4llm" and suffix in PYMUPDF_FORMATS:
    md = pymupdf4llm.to_markdown(str(f), header=False, footer=False)
else:
    md = MarkItDown().convert_local(str(f)).text_content

md  = re.sub(r'\n{3,}', '\n\n', md)
out = f.with_suffix('.md')
out.write_bytes(md.encode())
print(f"Valmis: {out}")
