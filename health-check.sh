#!/bin/bash

echo "=== Health Check ==="
echo "Hostname: $(hostname)"
echo "Date: $(date)"
echo "Uptime:"
uptime
echo
echo "Disk Usage:"
df -h /
echo
echo "Memory:"
free -h
echo
echo "=== Health Check Completed ==="