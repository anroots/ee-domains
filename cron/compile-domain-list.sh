#!/usr/bin/env bash

set -e

cd public/lists

# Download .ee AXFR
echo "Downloading AXFR list from zone.internet.ee..."
dig @zone.internet.ee ee. axfr > zone.ee
echo "AXFR downloaded"

echo "Parsing domains from the zone file..."

# Extract only domain names from the zone file
# There are Many domain names in the zone, exactly 33 characters long. They don't WHOIS. Not sure what they are. `grep {35}` filters them out for noise reduction
grep "^[^;]"  zone.ee | cut -f 1 | cut -f 1 -d ' ' | sed 's/\.$//' | grep '.ee' | grep -vE '^.{35}$' | uniq | sort > domains.new.txt

# Make sure old domains.txt is sorted (for comm)
sort -o domains.txt domains.txt

# Find diffs
comm -23 domains.txt domains.new.txt > deleted.txt
comm -13 domains.txt domains.new.txt > added.txt
mv domains.new.txt domains.txt

head -n 1000 domains.txt > first-1000.txt
date +%s > last-update.txt

# Create .json files
python3 ./../../cron/text-to-json.py
cp last-update.json ../../data/last-update.json

# Create timeline files
python3 ./../../cron/compose-timeline.py

echo "Line counts in files:"
wc -l *.txt

rm -f zone.ee
echo "Domains parsed"