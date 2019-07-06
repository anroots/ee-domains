#!/usr/bin/env bash

set -e

# Download .ee AXFR
dig @zone.internet.ee ee. axfr > zone.ee


# Extract only domain names from the zone file
grep "^[^;]"  zone.ee | cut -f 1 | cut -f 1 -d ' ' | sed 's/\.$//' | grep '.ee' | sort | uniq > lists/ee-domains.txt
