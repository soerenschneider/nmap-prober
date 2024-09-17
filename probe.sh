#!/bin/sh

set -eu -o pipefail

# Perform the nmap scan and capture the output
SCAN_OUTPUT=$(nmap -p "$PORTS" "$TARGET")

# Print the scan output
echo "${SCAN_OUTPUT}"

# Check if any port is open and set the exit code
if echo "${SCAN_OUTPUT}" | grep -q "open"; then
  echo "At least one port is open."
  STATUS="1"
else
  echo "No ports are open."
  STATUS="0"
fi

# If pushgateway_addr is set, push the outcome to Pushgateway
if [ -n "${PUSHGATEWAY_ADDR}" ]; then
  TIMESTAMP=$(date +%s)
  METRICS=$(cat <<EOF
# TYPE nmap_prober_open_ports_bool gauge
# HELP nmap_prober_open_ports_bool A boolean metric indicating if any port was open (1) or not (0)
nmap_prober_open_ports_bool{target="$TARGET"} $STATUS

# TYPE nmap_prober_timestamp gauge
# HELP nmap_prober_timestamp The timestamp when the scan was performed
nmap_prober_timestamp{target="$TARGET"} $TIMESTAMP
EOF
  )

  echo "${METRICS}" | curl --retry 3 \
       --retry-delay 5 \
       --retry-max-time 30 \
       --max-time 60 \
       --silent \
       --show-error \
       --data-binary @- \
       "${PUSHGATEWAY_ADDR}/metrics/job/nmap_prober"
fi

# signal result as exit code
exit "${STATUS}"
