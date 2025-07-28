#!/bin/bash

echo "🔄 Restoring VM data from .vm_data..."

# Restore data
sudo rm -rf /vm_data
mkdir -p /vm_data

if [ -d ".vm_data" ]; then
    cp -r .vm_data/* /vm_data/
    echo "✅ VM data restored to /vm_data"
else
    echo "⚠️ No .vm_data found, starting fresh"
fi

# Install gotty
if ! command -v gotty &> /dev/null; then
    echo "📦 Installing gotty..."
    wget https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz
    tar -xzf gotty_linux_amd64.tar.gz
    chmod +x gotty
    sudo mv gotty /usr/local/bin/
fi

# Install cloudflared
if ! command -v cloudflared &> /dev/null; then
    echo "📦 Installing cloudflared..."
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
    mv cloudflared-linux-amd64 cloudflared
    chmod +x cloudflared
    sudo mv cloudflared /usr/local/bin/
fi

# Start GoTTY
echo "🌐 Starting GoTTY terminal..."
nohup gotty -w bash > gotty.log 2>&1 &

# Start Cloudflare tunnel
sleep 3
echo "☁️ Starting Cloudflare tunnel..."
nohup cloudflared tunnel --url http://localhost:8080 > cf.log 2>&1 &

# Backup every 5 hours
echo "🕒 Automatic backup every 5 hours started in background..."
backup_loop() {
  while true; do
    sleep 18000  # 5 hours = 5*60*60 = 18000 seconds
    echo "💾 Backing up /vm_data to .vm_data..."
    rm -rf .vm_data
    mkdir .vm_data
    cp -r /vm_data/* .vm_data/
    echo "✅ Backup complete at $(date)"
  done
}

backup_loop &

# Keep the script alive
echo "✅ Setup complete! Press CTRL+C to stop."
wait

