import argparse
import itertools
import string
import json


# Generate valid domain names out of all allowed characters
def generate_permutations(length=2, numbers=False):
    alphabet = list(string.ascii_lowercase) + ['-']
    if numbers:
        alphabet +=list(range(0, 9))

    tld = 'ee'
    for combination in itertools.combinations(alphabet, length):
        combination = ''.join(map(str, combination))
        if combination.startswith('-') or combination.endswith('-'):
            continue
        domain = '{}.{}'.format(combination, tld)

        yield domain


def main():
    parser = argparse.ArgumentParser(description='Find unregistrered domains of the shortest character length')
    parser.add_argument('length', metavar='L', type=int, nargs='?', default=2,
                        help='length of the domain name to search for in characters (ex: 2)')
    parser.add_argument('--with-numbers', action='store_true')
    args = parser.parse_args()

    with open('domains.json') as domains_file:
        registered_domains = json.load(domains_file)

    for perm in generate_permutations(args.length, args.with_numbers):
        if perm not in registered_domains:
            print(perm)


if __name__ == '__main__':
    main()
