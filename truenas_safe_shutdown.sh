#!/bin/bash

# This script installs Docker
# ------------------------------------------------------------------------------
# How to use:
# 1. Login to TrueNAS via SSH: ssh truenas_admin@<address>
# 2. To become root, run: sudo su
# 3. Check if scripts folder exists, if not create it at: /root/scripts
# 4. Save the script on: /root/scripts/truenas_safe_shutdown.sh
# 5. Give permission: chmod +x truenas_safe_shutdown.sh
# 3. Create a cron job, go to System > Advanced Settings > Cron Jobs > Add in the TrueNAS Web UI.
# 4. Edit Cron job with:
#   Description: Safe Shutdown.
#   Command: /root/scripts/safe_shutdown.sh
#   Run As user: root
#   Schedule: Daily (0 0 * * *) At 00:00 (12:00 AM)
# 5. Save and Apply the changes.
# ------------------------------------------------------------------------------

EMAIL="augusto@coody.me"

send_email() {
  local subject="$1"
  local message="$2"
  echo "$message" | mail -s "$subject" "$EMAIL"
}

log_message() {
  local message="$1"
  echo "$(date): $message" >> /var/log/safe_shutdown.log
}

echo "Checking if ZFS scrub or resilver is in progress..."
scrub_status=$(zpool status | grep -E "scrub in progress|resilver in progress")
if [ ! -z "$scrub_status" ]; then
  message="A ZFS scrub or resilver is in progress. Shutdown aborted."
  echo "$message"
  send_email "TrueNAS Shutdown Aborted" "$message"
  log_message "$message"
  exit 1
fi

echo "Checking if any SMART test is in progress..."
smart_status=$(for disk in $(smartctl --scan | awk '{print $1}'); do smartctl -a "$disk" | grep -i "self-test execution status"; done)
if echo "$smart_status" | grep -q "Self-test in progress"; then
  message="A SMART test is in progress. Shutdown aborted."
  echo "$message"
  send_email "TrueNAS Shutdown Aborted" "$message"
  log_message "$message"
  exit 1
fi

message="No scrub or SMART tests in progress. Proceeding with shutdown."
echo "$message"
log_message "$message"
send_email "TrueNAS Safe Shutdown" "$message"
sleep 5 | shutdown now