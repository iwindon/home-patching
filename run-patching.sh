#!/usr/bin/env bash
set -euo pipefail

cd /opt/ansible/home-servers

RUN_ID="$(date '+%Y-%m-%d_%H%M%S')"
REPORT_DIR="/var/log/ansible/reports/${RUN_ID}"

install -d -m 0750 "$REPORT_DIR"

echo "Starting home-server patch run: $RUN_ID"
echo "Reports will be written to: $REPORT_DIR"
echo

ansible-playbook \
    patch-home-servers.yml \
    -e "patch_run_id=${RUN_ID}" \
    "$@"

echo
echo "Patch run completed."
echo "Report directory: $REPORT_DIR"
