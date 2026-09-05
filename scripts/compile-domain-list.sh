#!/usr/bin/env bash

set -e

cd public/lists

# Download .ee AXFR
#
# AXFR transfer often fails: the registry NS times out or drops the connection,
# and sometimes hands back a truncated zone.
#
# Theory - the NS rate limits us. Successful runs have needed up to 9 attempts,
# so retry over a wide window and back off harder once the early ones fail.
MAX_ATTEMPTS=16
SLEEP_SHORT=45
SLEEP_LONG=90
SLOW_DOWN_AFTER=9

# The real zone is ~1.07M lines, so anything near 100k is already impossibly
# small. Guards against a truncated transfer that would otherwise parse fine
# and look like a mass deregistration.
MIN_ZONE_LINES=100000

# A complete AXFR ends with the zone's SOA record. dig appends its own
# ';;'-prefixed trailer after it, so compare against the last actual record.
zone_is_complete() {
    local last_record
    [[ -s zone.ee ]] || return 1
    [[ "$(wc -l < zone.ee)" -ge "$MIN_ZONE_LINES" ]] || return 1
    last_record=$(tail -n 20 zone.ee | grep -vE '^;|^$' | tail -n 1)
    grep -qE '^ee\.[[:space:]].*[[:space:]]IN[[:space:]]+SOA[[:space:]]' <<< "$last_record"
}

echo "Downloading AXFR list from zone.internet.ee, up to $MAX_ATTEMPTS attempts..."

transfer_ok=0
for (( attempt=1; attempt<=MAX_ATTEMPTS; attempt++ )); do
    dig @zone.internet.ee ee. axfr > zone.ee || true

    if zone_is_complete; then
        transfer_ok=1
        break
    fi

    echo "Attempt $attempt/$MAX_ATTEMPTS failed: got $(wc -l < zone.ee) lines, no trailing SOA. Last lines:"
    tail -n 10 zone.ee

    # Nothing to wait for after the final attempt
    if [[ "$attempt" -eq "$MAX_ATTEMPTS" ]]; then
        break
    fi

    if [[ "$attempt" -lt "$SLOW_DOWN_AFTER" ]]; then
        sleep "$SLEEP_SHORT"
    else
        sleep "$SLEEP_LONG"
    fi
done

if [[ "$transfer_ok" -ne 1 ]]; then
    echo "Unable to download a complete AXFR, network error? Exiting"
    echo "::error file=compile-domains-list.sh,title=AXFR download failed::Exceeded retry count, can not download a complete AXFR, exiting"
    exit 1
fi

echo "AXFR database downloaded ($(wc -l < zone.ee) lines, attempt $attempt)"

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