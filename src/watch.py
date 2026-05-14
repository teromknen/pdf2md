import time, subprocess, pathlib
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

WATCH_DIR   = r"C:\Data\PDF2MD"
SCRIPT      = r"C:\Tools\python-scripts\batch2md.py"
DEBOUNCE_S  = 10
supported   = {".pdf", ".epub", ".xps"}

last_event  = 0
triggered   = False

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
            subprocess.run(["python", SCRIPT])
except KeyboardInterrupt:
    observer.stop()
observer.join()