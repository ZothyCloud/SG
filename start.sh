#!/bin/bash

# Create persistent mount point
mkdir -p /vm_data

# Restore previous VM data if available
if [ -d ".vm_data" ]; then
  echo "🔁 Restoring previous VM data..."
  cp -r .vm_data/* /vm_data/
fi

# Install Cloudflare Tunnel
echo "🌐 Installing Cloudflare Tunnel..."
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
mv cloudflared-linux-amd64 cloudflared
chmod +x cloudflared

# Install gotty (Go Terminal)
echo "🖥️ Installing gotty..."
wget -q https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz
tar -xzf gotty_linux_amd64.tar.gz
chmod +x gotty

# Start gotty on port 7681
echo "🚀 Starting gotty terminal on port 7681..."
nohup ./gotty -p 7681 bash > gotty.log 2>&1 &

# Start Cloudflare Tunnel
echo "☁️ Starting Cloudflare tunnel..."
nohup ./cloudflared tunnel --url http://localhost:7681 > cf.log 2>&1 &

sleep 5
echo "🌍 Waiting for public Cloudflare link..."

# Display the Cloudflare URL
grep -o 'https://[-a-zA-Z0-9]*\.trycloudflare\.com' cf.log | head -n1
