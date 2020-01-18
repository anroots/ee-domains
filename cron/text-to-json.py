import json

files = ['added.txt', 'deleted.txt', 'domains.txt', 'last-update.txt']

for filename in files:
    with open(filename) as f:
       lines = [line.rstrip('\n') for line in f]

    with open(filename.replace('txt', 'json'), 'w') as outfile:
        json.dump(lines, outfile)

    print('Converted {}'.format(filename))