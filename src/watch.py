import time, subprocess, pathlib, configparser
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

config = configparser.ConfigParser()
config.read(pathlib.Path(__file__).parent.parent / "config.ini")

WATCH_DIR  = config["paths"]["watch_dir"]
SCRIPT     = pathlib.Path(config["paths"]["scripts_dir"]) / "batch2md.py"
DEBOUNCE_S = int(config["settings"]["debounce_seconds"])
supported  = {".pdf", ".epub", ".xps"}

last_event = 0
triggered  = False

class Handler(FileSystemEventHandler):
    def on_created(self, event):
        global last_event, triggered
        if not event.is_directory:
            if pathlib.Path(event.src_path).suffix.lower() in supported:
                last_event = time.time()
                triggered  = True

observer = Observer()
observer.schedule(Handler(), WATCH_DIR, recursive=False)
observer.start()

try:
    while True:
        time.sleep(1)
        if triggered and (time.time() - last_event) >= DEBOUNCE_S:
            triggered = False
            subprocess.run(["python", str(SCRIPT)])
except KeyboardInterrupt:
    observer.stop()
observer.join()