import pymupdf4llm, pathlib, re, sys

pdf = sys.argv[1]
md = pymupdf4llm.to_markdown(pdf, header=False, footer=False)
md = re.sub(r'\n{3,}', '\n\n', md)
out = pathlib.Path(pdf).with_suffix('.md')
out.write_bytes(md.encode())
print(f"Valmis: {out}")