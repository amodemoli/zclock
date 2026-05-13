#! /bin/bash

set -emu

RED='\033[31m'
BLUE='\033[34m'
GREEN='\033[32m'
YELLOW='\033[33m'
BOLD='\033[1m'
NC='\033[0m'

UBIN_DIR="/usr/local/bin"
BIN_PATH="$UBIN_DIR/zima_clock.sh"
CURRENT_DIR=$(pwd)

SERVICE_PATH="/etc/systemd/system/zima_clock.service"
SERVICE_CONF=$(
  cat <<EOF
[Unit]
Description=Fix System Time/Date Bug
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/zima_clock.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
)

eprint() {
  echo -e "[${RED}Error${NC}] ${YELLOW}$1${NC}"
}

printed() {
  echo -e "[${BOLD}${GREEN}OK${NC}] ${BLUE}$1${NC}"
}

if [[ "$EUID" -ne 0 ]]; then
  eprint "Please run app as root"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  if [[ $1 == "replace" ]]; then
    if [[ -n "$SERVICE_PATH" && -n "$BIN_PATH" ]]; then
      printed "remove old conf"
      rm -rf "$SERVICE_PATH" "$BIN_PATH"
    fi
  fi
fi

if ! [[ -f $BIN_PATH ]]; then
  printed "creating binary file"
  if cp "$CURRENT_DIR/linux.sh" "$BIN_PATH" &>>/dev/null; then
    printed "creating binary file successfull"
  else
    eprint "failed creating binary file"
  fi
fi

if ! [[ -f $SERVICE_PATH ]]; then
  printed "config service"
  echo "$SERVICE_CONF" | tee "$SERVICE_PATH" >>/dev/null || eprint "failed configed zima_clock.service" && exit 1
fi

if ! systemctl is-active --quiet zima_clock.service; then
  eprint "service is not active"
  printed "activing..."
  systemctl start zima_clock.service
else
  printed "service is active"
fi

if ! systemctl is-enabled --quiet zima_clock.service; then
  eprint "service is not enabled"
  printed "enableing..."
  systemctl enable zima_clock.service
else
  printed "service is enabled"
fi

systemctl status zima_clock.service --lines=0 --no-pager 2>/dev/null || true

printed "config service successfull"
exit 0
