#!/usr/bin/python3
import click
import validators
import sys

@click.command()
@click.argument('domains_file', default='public/lists/domains.txt')
def main(domains_file):
    """Validate all domains in a text file are syntactically correct"""

    click.echo(f'Validating domains from {domains_file}...')
    cnt = 0

    with open(domains_file, 'r') as f:
        for domain in f:
            domain = domain.strip()
            cnt += 1
            if validators.domain(domain) is not True:
                click.secho(f'Domain "{domain}" failed validation', fg='red')
                sys.exit(1)

    click.secho(f'All {cnt} domains in {domains_file} are valid', fg='green')


if __name__ == '__main__':
    main()
