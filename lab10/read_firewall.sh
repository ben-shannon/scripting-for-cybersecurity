#!/bin/bash

while read -r ACTION SRC ARROW DST; do
    PORT=${DST##*:}
    echo "$ACTION from $SRC to port $PORT"
done < case/logs/firewall.log
