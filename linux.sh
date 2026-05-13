#!/bin/bash

set -emu

RED='\033[31m'
BLUE='\033[34m'
GREEN='\033[32m'
YELLOW='\033[33m'
BOLD='\033[1m'
NC='\033[0m'

WAIT_FOR_NETWORK_RETRY=5
CURL_TIMEOUT=30
MAX_RETRIES=999
RETRY_DELAY=10
TRY_COUNT_CONNECTION=3

TIME_SERVERS=(
  "google.com"
  "cloudflare.com"
  "amazon.com"
)

if [ "$EUID" -ne 0 ]; then
  echo -e "[${RED}Error${NC}] ${GREEN}Please run with sudo: ${NC}sudo $0"
  exit 1
fi

get_date_str() {
  local server="$1"
  curl -sI --max-time $CURL_TIMEOUT --connect-timeout 10 "https://$server" 2>/dev/null |
    grep -i "^Date:" |
    head -1 |
    sed 's/^[Dd]ate: //gI' |
    tr -d '\r'
}
eprint() {
  echo -e "[${RED}Error${NC}] ${YELLOW}$1${NC}"
}
check_connection() {
  local server="$1"
  local count=0

  while [ $count -lt $TRY_COUNT_CONNECTION ]; do
    if ping -c 1 -W 2 "$server" &>>/dev/null; then
      echo "$server"
      return 0
    else
      return 1
    fi
    ((count++))
    sleep "$WAIT_FOR_NETWORK_RETRY"
  done
  return 1
}

exit_error() {
  echo -e "[${RED}Error${NC}] ${YELLOW}$1${NC}"
  exit 1
}

#Started point program
while true; do
  echo -e "${BLUE}Waiting for internet connection${NC}..."

  #check connection
  ntp_server=""
  for srv in "${TIME_SERVERS[@]}"; do
    ntp_server=$(check_connection "$srv") || exit_error "connection lost"
    if [ -n "$ntp_server" ]; then
      echo -e "${GREEN}Connected to ${NC}${BOLD} $ntp_server${NC}"
      break
    else
      exit_error "connection lost"
    fi
  done

  echo -e "${BLUE}Attempting to fetch accurate time...${NC}"

  RETRY_COUNT=0
  TIME_SET_SUCCESS=0

  while [ $RETRY_COUNT -lt $MAX_RETRIES ] && [ $TIME_SET_SUCCESS -eq 0 ]; do
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo -e "${GREEN}Request attempt ${NC}$RETRY_COUNT ${GREEN}(max ${NC}$MAX_RETRIES${GREEN}) - timeout: ${NC}${CURL_TIMEOUT}s"

    DATE_STRING=$(get_date_str "$ntp_server")

    if [ -z "$DATE_STRING" ]; then
      DATE_STRING=$(get_date_str "$ntp_server")
    fi

    if [ -n "$DATE_STRING" ]; then
      echo -e "${GREEN}Received time: ${YELLOW}$DATE_STRING${NC}"
      date -s "$DATE_STRING" &>/dev/null
      if [ $? -eq 0 ]; then
        hwclock --systohc 2>/dev/null
        echo -e "${GREEN}System time updated successfully: ${NC}$(date)"
        TIME_SET_SUCCESS=1
      else
        echo -e "${RED}Failed to parse date string, retrying...${NC}"
      fi
    else
      echo -e "${RED}Request timeout or failed ${NC}- ${GREEN}retrying in ${NC}${RETRY_DELAY} ${GREEN}seconds...${NC}"
    fi

    if [ $TIME_SET_SUCCESS -eq 0 ] && [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
      sleep $RETRY_DELAY
    fi
  done

  if [ $TIME_SET_SUCCESS -eq 1 ]; then
    echo -e "${GREEN}${BOLD}<==Time synchronization completed successfully==>${NC}"
    exit 0
  else
    eprint "All retry attempts failed. Cannot fetch time from any server."
    eprint "Waiting ${RETRY_DELAY} seconds before starting over from network check..."
    sleep $RETRY_DELAY
  fi
done
