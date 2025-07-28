#!/bin/bash

# Ensure vm_data exists
mkdir -p vm_data

# Install dependencies (for local/VM use — skip on GitHub Actions)
sudo apt update
sudo apt install -y curl unzip

# Download and set up ttyd
curl -Lo ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd-linux.x86_64
chmod +x ttyd && sudo mv ttyd /usr/local/bin/ttyd

# Download and set up Cloudflare tunnel
curl -Lo cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x cloudflared && sudo mv cloudflared /usr/local/bin/cloudflared

# Start ttyd and cloudflared
nohup ttyd -p 7681 bash > /dev/null 2>&1 &
nohup cloudflared tunnel --url http://localhost:7681 > /dev/null 2>&1 &

echo "✅ TTYD and Cloudflare tunnel are running"

# Backup loop every 5 hours
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
