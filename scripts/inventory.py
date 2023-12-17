#!/usr/bin/python3
import click
from lib.scanner import scan_domain
import concurrent.futures
import time
from queue import Queue
from lib.file import ResultWriter
import requests
import sys
import os
import logging
import traceback

LOGLEVEL = os.environ.get('LOGLEVEL', 'INFO').upper()
logging.basicConfig(level=LOGLEVEL)

done_progress = 0
total_records = 0
start_time = 0

results = Queue()

def track_progress(future):
    global done_progress
    global total_records
    done_progress += 1
    if done_progress % 500 == 0:
        seconds = round(time.time() - start_time)
        click.echo(f'{done_progress} of {total_records} done in {seconds}s')
    
    try:
        results.put(future.result())
    except Exception:
        click.secho(traceback.format_exc(),fg='red')
    click.echo('.', nl=False)


@click.command()
@click.argument('domains_file', default='public/lists/first-1000.txt')
@click.argument('inventory_file', default='public/lists/domains-meta.json')
@click.option('-w', '--workers', default=30, type=int, help='Number of workers')
@click.option('--verify-proxy', default='', type=str, help='Verify proxy is set')
def main(domains_file, inventory_file, workers, verify_proxy):
    """Scan a list of domains for basic inventory and write results to a file"""

    if verify_proxy:

        http_proxy = os.environ.get('HTTP_PROXY')
        https_proxy = os.environ.get('HTTPS_PROXY')
        click.echo(f'Running with proxy settings: HTTP_PROXY={http_proxy}; HTTPS_PROXY={https_proxy}')
        
        proxy_info = requests.get('https://api.myip.com/')
        proxy_info.raise_for_status()
        cc = proxy_info.json().get('cc')
        if not cc or verify_proxy != cc:
            click.secho(f'Proxy test failed, actual CC is {cc}, expected CC was {verify_proxy}', fg='red')
            sys.exit(1)
        click.secho(f'Verified proxy settings, reported CC is {cc}', fg='green')

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
                future.add_done_callback(track_progress)
                futures.append(future)
                total_records += 1

        click.echo(f'Added {total_records} domains to the queue')
        results_writer.start()
    
    click.echo('All scan targets done, waiting for results file writer to complete')
    results.put(None)
    results_writer.join()

    seconds = round(time.time() - start_time)
    click.echo(f'Done - wrote {done_progress} lines to results file, scan took {seconds}s')


if __name__ == '__main__':
    main()
