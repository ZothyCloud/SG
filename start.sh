#!/bin/bash

# ========== TTYD & CLOUDFLARED SETUP ==========

# Download fresh ttyd binary
curl -Lo ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd-linux.x86_64
chmod +x ttyd
mv ttyd /usr/local/bin/ttyd

# Download Cloudflare tunnel
curl -Lo cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x cloudflared
mv cloudflared /usr/local/bin/cloudflared

# ========== VM DATA SETUP ==========
mkdir -p /home/runner/work/SG/SG/vm_data
cd /home/runner/work/SG/SG/vm_data || exit

# ========== START TTYD ==========
nohup ttyd -p 7681 bash > /dev/null 2>&1 &

# ========== START CLOUDFLARED ==========
nohup cloudflared tunnel --url http://localhost:7681 > /dev/null 2>&1 &

# ========== BACKUP EVERY 5 HOURS ==========
while true; do
  sleep 18000  # 5 hours = 18000 seconds
  echo "🔁 Auto-committing backup at $(date)"
  cd /home/runner/work/SG/SG || exit
  git config --global user.email "auto@vm.zothy"
  git config --global user.name "Zothy VM"
  git add vm_data
  git commit -m "💾 Auto-backup at $(date '+%Y-%m-%d %H:%M:%S')" || echo "Nothing to commit"
  git push origin vm-data
done
