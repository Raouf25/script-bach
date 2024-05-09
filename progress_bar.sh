#!/bin/bash

    progress=$1
    current=$2
    total=$3
    width=50

    # Calculate the percentage completion
    percentage=$((current * 100 / total))
    # Calculate the number of characters to display
    progress=$((current * width / total))

    # Print the progress bar
    printf "\rProgress: [%-${width}s] %d%%" "$(printf '#%.0s' $(seq 1 $progress))" "$percentage"

