#!/usr/bin/python3
import click
from lib.scanner import scan_domain
import concurrent.futures
import time
from queue import Queue
from lib.file import ResultWriter

done_progress = 0
total_records = 0
start_time = 0

results = Queue()

def track_progress(future):
    global done_progress
    global total_records
    done_progress += 1
    if done_progress % 10 == 0:
        seconds = round(time.time() - start_time)
        click.echo(f'{done_progress} of {total_records} done in {seconds}s')
    results.put(future.result())


@click.command()
@click.argument('domains_file', default='public/lists/first-1000.txt')
@click.argument('inventory_file', default='public/lists/domains-meta.json')
@click.option('-w', '--workers', default=30, type=int, help='Number of workers')
def main(domains_file, inventory_file, workers):
    """Scan a list of domains for basic inventory and write results to a file"""
    global start_time
    global total_records

    start_time = time.time()
    futures = []
    click.echo(f'Starting to collect inventory, using {workers} threads - this will take a while...')
    results_writer = ResultWriter(results,inventory_file)
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as executor:

        with open(domains_file, 'r') as f:
            for domain in f:
                future = executor.submit(scan_domain, domain.strip())
                futures.append(future)
                total_records += 1

    click.echo(f'Added {total_records} domains to the queue')
    results_writer.start()
    
    for future in concurrent.futures.as_completed(futures):
        track_progress(future)
    results.put(None)
    results.join()
    results_writer.join()

    seconds = round(time.time() - start_time)
    click.echo(f'Wrote {done_progress} lines to results file, took {seconds}s')


if __name__ == '__main__':
    main()
