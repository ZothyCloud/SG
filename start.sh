#!/bin/bash

echo "✅ Starting VM Setup..."

# Update & install basics
sudo apt update -y
sudo apt install -y curl unzip

# Create vm_data directory if not exists
mkdir -p vm_data
cd vm_data || exit

# Download ttyd if not present
if [ ! -f ../ttyd ]; then
  curl -Lo ../ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd_linux.x86_64
  chmod +x ../ttyd
fi

cd ..

# Start ttyd on port 7681 inside vm_data folder
nohup ./ttyd -p 7681 bash -c "cd vm_data && bash" > ttyd.log 2>&1 &

# Download cloudflared if not present
if [ ! -f cloudflared ]; then
  curl -Lo cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
  chmod +x cloudflared
fi

# Start cloudflared tunnel
nohup ./cloudflared tunnel --url http://localhost:7681 > tunnel.log 2>&1 &

# Wait a few seconds for tunnel URL to be ready
sleep 5

# Extract URL from tunnel log
URL=$(grep -o 'https://[a-z0-9.-]*\.trycloudflare\.com' tunnel.log | head -n1)

echo "✅ Public TTYD URL:"
echo "$URL"

# (Optional) Keep script running to keep VM alive
while true; do
  sleep 300
done
