#!/bin/bash

COUNT=$1

if [ "$COUNT" -ge 0 ]; then
    echo "Non-negative"
elif [ "$COUNT" -ge 10 ]; then
    echo "At least 10"
else
    echo "Negative"
fi
