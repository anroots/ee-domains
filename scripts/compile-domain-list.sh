#!/usr/bin/env bash

set -e

cd public/lists

# Download .ee AXFR
echo "Downloading AXFR list from zone.internet.ee..."

# AXFR transfer sometimes fails for unknown reason
# https://github.com/anroots/ee-domains/actions/runs/13489291922/job/37684838747
# Error: Process completed with exit code 9.
#
# Theory - UDP packet loss? Temp NS error?
# Retry a few times, then give up
for i in {1..10}; do
    dig @zone.internet.ee ee. axfr > zone.ee && break
    head -n 100
    wc -l zone.ee
    echo "Attempt $i to transfer AXFR failed. Sleeping 45s and retrying..."
    sleep 45
done

# Check if the download succeeded
LINE_COUNT=$(wc -l < "zone.ee")
if [[ "$LINE_COUNT" -lt 100 ]]; then
    echo "Unable to download AXFR, network error? Exiting"
    echo "::error file=compile-domains-list.sh,title=AXFR download failed::Exceeded retry count, can not download AXFR, exiting"
    exit 1
fi

echo "AXFR database downloaded"

echo "Parsing domains from the zone file..."

# Extract only domain names from the zone file
# There are Many domain names in the zone, exactly 33 characters long. They don't WHOIS. Not sure what they are. `grep {35}` filters them out for noise reduction
# 
# Only look for NS records (there are other record types, but domains have a NS record) - ref https://github.com/anroots/ee-domains/issues/12
egrep '\s+IN\s+NS\s+[a-zA-Z0-9]' zone.ee | cut -f 1 | cut -f 1 -d ' ' | sed 's/\.$//' | grep '.ee' | grep -vE '^.{35}$' | uniq | sort > domains.new.txt

# Make sure old domains.txt is sorted (for comm)
sort -o domains.txt domains.txt

python3 ./../../scripts/validate-domains.py domains.new.txt

# Find diffs
comm -23 domains.txt domains.new.txt > deleted.txt
comm -13 domains.txt domains.new.txt > added.txt

# Sanity check: error out if added/deleted file has unexpectedly many entries
# Probably script broke, needs manual intervention
LINE_COUNT=$(wc -l < "added.txt")
if [[ "$LINE_COUNT" -gt 5000 ]]; then
    echo "::error file=compile-domains-list.sh,title=Parsing error::Error: added.txt has more than 5000 lines ($LINE_COUNT). Exiting."
    echo "First 300 lines of added.txt for debugging:"
    head -n 300 added.txt
    exit 1
fi
LINE_COUNT=$(wc -l < "deleted.txt")
if [[ "$LINE_COUNT" -gt 5000 ]]; then
    echo "Error: deleted.txt has more than 5000 lines ($LINE_COUNT). Exiting."
    echo "First 300 lines of deleted.txt for debugging:"
    head -n 300 deleted.txt
    exit 1
fi

mv domains.new.txt domains.txt

head -n 1000 domains.txt > first-1000.txt
date +%s > last-update.txt

# Create .json files
python3 ./../../scripts/text-to-json.py
cp last-update.json ../../data/last-update.json
wc -l domains.txt | cut -d ' ' -f 3 > ../../data/count.json

# Create timeline files
python3 ./../../scripts/compose-timeline.py

echo "Line counts in files:"
wc -l *.txt

rm -f zone.ee
echo "Domains parsed"