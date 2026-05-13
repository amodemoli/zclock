#!/bin/bash

WAIT_FOR_NETWORK_RETRY=5
CURL_TIMEOUT=30
MAX_RETRIES=999
RETRY_DELAY=10

if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo: sudo $0"
    exit 1
fi

while true; do
    echo "Waiting for internet connection..."
    
    while true; do
        if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
            echo "Internet connection detected"
            break
        fi
        if ping -c 1 -W 2 google.com > /dev/null 2>&1; then
            echo "Internet connection detected"
            break
        fi
        if curl -s --max-time 5 --connect-timeout 3 https://google.com > /dev/null 2>&1; then
            echo "Internet connection detected"
            break
        fi
        sleep $WAIT_FOR_NETWORK_RETRY
    done

    echo "Attempting to fetch accurate time..."

    RETRY_COUNT=0
    TIME_SET_SUCCESS=0

    while [ $RETRY_COUNT -lt $MAX_RETRIES ] && [ $TIME_SET_SUCCESS -eq 0 ]; do
        RETRY_COUNT=$((RETRY_COUNT + 1))
        echo "Request attempt $RETRY_COUNT (max $MAX_RETRIES) - timeout: ${CURL_TIMEOUT}s"
        
        DATE_STRING=$(curl -sI --max-time $CURL_TIMEOUT --connect-timeout 10 https://google.com 2>/dev/null | grep -i "^Date:" | head -1 | sed 's/^[Dd]ate: //gI' | tr -d '\r')
        
        if [ -z "$DATE_STRING" ]; then
            DATE_STRING=$(curl -sI --max-time $CURL_TIMEOUT --connect-timeout 10 http://google.com 2>/dev/null | grep -i "^Date:" | head -1 | sed 's/^[Dd]ate: //gI' | tr -d '\r')
        fi
        
        if [ -z "$DATE_STRING" ]; then
            DATE_STRING=$(curl -sI --max-time $CURL_TIMEOUT --connect-timeout 10 https://cloudflare.com 2>/dev/null | grep -i "^Date:" | head -1 | sed 's/^[Dd]ate: //gI' | tr -d '\r')
        fi
        
        if [ -z "$DATE_STRING" ]; then
            DATE_STRING=$(curl -sI --max-time $CURL_TIMEOUT --connect-timeout 10 http://www.microsoft.com 2>/dev/null | grep -i "^Date:" | head -1 | sed 's/^[Dd]ate: //gI' | tr -d '\r')
        fi

        if [ -n "$DATE_STRING" ]; then
            echo "Received time: $DATE_STRING"
            date -s "$DATE_STRING" 2>/dev/null
            if [ $? -eq 0 ]; then
                hwclock --systohc 2>/dev/null
                echo "System time updated successfully: $(date)"
                TIME_SET_SUCCESS=1
            else
                echo "Failed to parse date string, retrying..."
            fi
        else
            echo "Request timeout or failed - retrying in ${RETRY_DELAY} seconds..."
        fi
        
        if [ $TIME_SET_SUCCESS -eq 0 ] && [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            sleep $RETRY_DELAY
        fi
    done

    if [ $TIME_SET_SUCCESS -eq 1 ]; then
        echo "Time synchronization completed successfully"
        exit 0
    else
        echo "All retry attempts failed. Cannot fetch time from any server."
        echo "Waiting ${RETRY_DELAY} seconds before starting over from network check..."
        sleep $RETRY_DELAY
    fi
done
