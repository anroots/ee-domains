#!/usr/bin/env bash

set -e

cd src/lists

# Download .ee AXFR
echo "Downloading AXFR list from zone.internet.ee..."
dig @zone.internet.ee ee. axfr > zone.ee
echo "AXFR downloaded"

# Extract only domain names from the zone file
echo "Parsing domains from the zone file..."
grep "^[^;]"  zone.ee | cut -f 1 | cut -f 1 -d ' ' | sed 's/\.$//' | grep '.ee' | sort | uniq > domains.new.txt

comm -23 domains.txt domains.new.txt > deleted.txt
comm -13 domains.txt domains.new.txt > added.txt
mv domains.new.txt domains.txt

# Create .json files
python3 ././../.travis/text-to-json.py

date +%s > last-update.txt

echo "Line counts in files:"
wc -l *

rm -f zone.ee
echo "Domains parsed"