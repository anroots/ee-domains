#!/usr/bin/env bash

set -e

# Download .ee AXFR
echo "Downloading AXFR list from zone.internet.ee..."
dig @zone.internet.ee ee. axfr > zone.ee
echo "AXFR downloaded"

# Extract only domain names from the zone file
echo "Parsing domains from the zone file..."
grep "^[^;]"  zone.ee | cut -f 1 | cut -f 1 -d ' ' | sed 's/\.$//' | grep '.ee' | sort | uniq > src/lists/domains.new.txt

comm -23 src/lists/domains.txt src/lists/domains.new.txt > src/lists/deleted.txt
comm -13 src/lists/domains.txt src/lists/domains.new.txt > src/lists/added.txt
mv src/lists/domains.new.txt src/lists/domains.txt

date +%s > src/lists/last-update.txt

echo "Line counts in files:"
wc -l src/lists/*.txt

echo "Domains parsed"