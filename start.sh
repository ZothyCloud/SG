#!/bin/bash

# Create vm_data if missing
mkdir -p vm_data

# Install ttyd
curl -Lo ttyd.tar.gz https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd-linux.x86_64.tar.gz
tar -xzf ttyd.tar.gz
chmod +x ttyd && sudo mv ttyd /usr/local/bin/ttyd

# Install cloudflared
curl -Lo cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x cloudflared && sudo mv cloudflared /usr/local/bin/cloudflared

# Run ttyd
nohup ttyd -p 7681 bash > /dev/null 2>&1 &

# Run Cloudflare tunnel
nohup cloudflared tunnel --url http://localhost:7681 > /dev/null 2>&1 &

# Backup every 5 hours
cat << 'EOF' > backup.sh
#!/bin/bash
while true; do
  sleep 18000
  echo "🔁 Auto-backup at $(date)"
  git config --global user.email "auto@vm.zothy"
  git config --global user.name "Zothy VM"
  git add vm_data
  git commit -m "💾 Auto-backup at $(date '+%Y-%m-%d %H:%M:%S')" || echo "Nothing to commit"
  git push origin vm-data
done
EOF

chmod +x backup.sh
nohup ./backup.sh > /dev/null 2>&1 &
