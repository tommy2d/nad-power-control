#!/bin/bash

( sleep 1; echo -e "$2" > $1 ) &
OUTPUT=$(timeout $3s cat < $1)
echo -e "$OUTPUT" | tr -d '\r'
wait
