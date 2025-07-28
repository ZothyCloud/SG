#!/bin/bash

set -e

echo "✅ Starting VM Setup..."

# Install dependencies
sudo apt update
sudo apt install -y curl unzip

# Make sure we're in project root
cd "$(dirname "$0")"

# Setup /vm_data
mkdir -p /content/drive/MyDrive/colab_vm_data
ln -s /content/drive/MyDrive/colab_vm_data /vm_data || true

# Install TTYD
curl -LO https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd_linux.x86_64 && \
chmod +x ttyd_linux.x86_64 && \
mv ttyd_linux.x86_64 ttyd

# Start TTYD in /vm_data
nohup ./ttyd -p 7681 bash -c "cd /vm_data && bash" > ttyd.log 2>&1 &

# Install Cloudflare tunnel
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
chmod +x cloudflared

# Start Cloudflare tunnel and capture public URL
nohup ./cloudflared tunnel --url http://localhost:7681 --no-autoupdate > tunnel.log 2>&1 &
sleep 5

echo "✅ Cloudflare tunnel logs:"
cat tunnel.log | grep -o 'https://.*trycloudflare.com' | head -1

# Auto backup every 5 hours
(
  while true; do
    echo "🕒 Backing up /vm_data to GitHub..."
    git config --global user.name "ZothyBot"
    git config --global user.email "zothybot@example.com"

    git fetch origin vm-data || git checkout --orphan vm-data
    git checkout vm-data || git checkout -b vm-data
    cp -r /vm_data/* .
    git add .
    git commit -m "Auto-backup: $(date)" || true
    git push origin vm-data
    echo "✅ Backup complete. Sleeping 5h..."
    sleep 18000  # 5 hours
  done
) &

# Keep the script running so the VM stays alive
while true; do
  sleep 3600
done
