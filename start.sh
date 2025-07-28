#!/bin/bash

set -e

echo "✅ Starting VM Setup..."

# Install dependencies
sudo apt update
sudo apt install -y curl unzip

# Ensure /vm_data exists
mkdir -p vm_data

# Install TTYD
curl -LO https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd_linux.x86_64
chmod +x ttyd_linux.x86_64
mv ttyd_linux.x86_64 ttyd

# Start TTYD in vm_data directory
nohup ./ttyd -p 7681 bash -c "cd vm_data && bash" > ttyd.log 2>&1 &

# Install Cloudflare tunnel
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
chmod +x cloudflared

# Start Cloudflare tunnel and capture URL
nohup ./cloudflared tunnel --url http://localhost:7681 --no-autoupdate > tunnel.log 2>&1 &
sleep 5

echo "✅ Public TTYD URL:"
cat tunnel.log | grep -o 'https://.*trycloudflare.com' | head -1

# Auto backup every 5 hours
(
  while true; do
    echo "🕒 Backing up vm_data to GitHub..."

    git config --global user.name "ZothyBot"
    git config --global user.email "zothybot@example.com"

    git fetch origin vm-data || true
    git checkout vm-data || git checkout -b vm-data
    cp -r vm_data/* .
    git add .
    git commit -m "Auto-backup: $(date)" || true
    git push origin vm-data
    echo "✅ Backup complete. Sleeping for 5h..."
    sleep 18000
  done
) &

# Keep the script alive
while true; do
  sleep 3600
done
