#!/bin/bash

high_mem_process=$(ps -eo pid,%mem,comm --sort=-%mem | awk 'NR==2 {print $1}')

echo "Process with highest memory usage: $high_mem_process"

#Terminating the process
if [ -n "$high_mem_process" ]; then
      kill -9 "$high_mem_process"
      echo "Terminated the process of PID: $high_mem_process"
else
      echo "No process found to terminate"
fi
