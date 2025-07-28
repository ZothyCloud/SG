#!/bin/bash

echo "📦 Installing Cloudflared..."
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
chmod +x cloudflared
mv cloudflared /usr/local/bin/

echo "📦 Installing GoTTY..."
wget -q https://github.com/yudai/gotty/releases/latest/download/gotty_linux_amd64.tar.gz
tar -xzf gotty_linux_amd64.tar.gz
chmod +x gotty
mv gotty /usr/local/bin/

echo "🌐 Starting GoTTY terminal..."
# Gotty on http://localhost:8080
gotty -w --port 8080 bash &

echo "🕒 Automatic backup every 5 hours started in background..."
(
  while true; do
    echo "🔁 Backing up VM data..."
    rm -rf .vm_data
    cp -r /vm_data .vm_data
    git add .vm_data
    git commit -m "⏱️ Auto-backup at $(date)"
    git push origin vm-data
    sleep 18000  # 5 hours
  done
) &

echo "☁️ Starting Cloudflare tunnel... (public URL will appear below)"
# Run Cloudflared in foreground so the public URL is visible
cloudflared tunnel --url http://localhost:8080
