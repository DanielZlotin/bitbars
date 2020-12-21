#!/bin/bash

# Prints time in LA and NY

echo "⌚LA:$(TZ=America/Los_Angeles date +'%H') NY:$(TZ=America/New_York date +'%H')"
