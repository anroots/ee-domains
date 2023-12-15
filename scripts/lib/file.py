
from threading import Thread
from queue import Queue, Empty
import json
import time

class ResultWriter(Thread):
    results: Queue
    results_path: str

    def __init__(self, results: Queue, results_path: str):
        Thread.__init__(self)
        self.results = results
        self.results_path = results_path

    def run(self):
        results_file = open(self.results_path, 'w+')
        while True:
            try:
                result = self.results.get()
                if result is None:
                    results_file.close()
                    self.results.task_done()
                    return

                scan_result = json.dumps(result)

                # \n delimited JSON objects for each domain
                results_file.write(f"{scan_result}\n")
                self.results.task_done()

            except Empty:
                time.sleep(1)

