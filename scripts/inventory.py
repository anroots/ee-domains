#!/usr/bin/python3
import click
from lib.scanner import scan_domain
import concurrent.futures
import json
import time

done_progress = 0
total_records = 0
start_time = 0


def track_progress(future):
    global done_progress
    global total_records
    done_progress += 1
    if done_progress % 100 == 0:
        seconds = round(time.time() - start_time)
        click.echo(f'{done_progress} of {total_records} done in {seconds}s')


@click.command()
@click.argument('domains_file', default='public/lists/first-1000.txt')
@click.argument('inventory_file', default='public/lists/domains-meta.json')
@click.option('-w', '--workers', default=30, type=int, help='Number of workers')
def main(domains_file, inventory_file, workers):
    """Scan a list of domains for basic inventory and write results to a file"""
    global start_time
    global total_records

    futures = []
    start_time = time.time()

    with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as executor:

        with open(domains_file, 'r') as f:
            for domain in f:
                future = executor.submit(scan_domain, domain.strip())
                future.add_done_callback(track_progress)
                futures.append(future)
                total_records += 1

    # Write done reports to inventory file as they complete
    with open(inventory_file, 'w+') as f:
        for future in concurrent.futures.as_completed(futures):

            try:
                result = future.result()
                scan_result = json.dumps(result)

                # \n delimited JSON objects for each domain
                f.write(f"{scan_result}\n")
            except Exception as err:
                click.secho(err, fg='red')

    seconds = round(time.time() - start_time)
    click.echo(f'Wrote {done_progress} lines to results file, took {seconds}s')


if __name__ == '__main__':
    main()
