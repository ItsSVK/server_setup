#!/bin/bash

set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

USERNAME="shouvik"
PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGengeX6byGkthoE8076K3h2QbvG1jrGb795ca5oKHQa connectshouvik@gmail.com"

echo "🚀 Starting minimal secure server setup..."

# Update system
apt update && apt upgrade -y

# Install essentials only
apt install -y curl wget git ufw fail2ban nginx

# Create user if not exists
if getent passwd "$USERNAME" > /dev/null; then
  echo "User $USERNAME already exists"
else
  useradd -m -s /bin/bash "$USERNAME"
fi

# Add to sudo group
usermod -aG sudo $USERNAME

# Setup SSH directory
mkdir -p /home/$USERNAME/.ssh
chmod 700 /home/$USERNAME/.ssh

# Add your public key here 👇
if [ ! -f /home/$USERNAME/.ssh/authorized_keys ]; then
  touch /home/$USERNAME/.ssh/authorized_keys
fi

if ! grep -qxF "$PUBLIC_KEY" /home/$USERNAME/.ssh/authorized_keys; then
  echo "$PUBLIC_KEY" >> /home/$USERNAME/.ssh/authorized_keys
fi

chmod 600 /home/$USERNAME/.ssh/authorized_keys

chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
chown $USERNAME:$USERNAME /home/$USERNAME
chmod 755 /home/$USERNAME

# Harden SSH (no port change)
SSHD_CONFIG="/etc/ssh/sshd_config"

grep -q "^PermitRootLogin" $SSHD_CONFIG && \
sed -i "s/^PermitRootLogin.*/PermitRootLogin no/" $SSHD_CONFIG || \
echo "PermitRootLogin no" >> $SSHD_CONFIG

grep -q "^PasswordAuthentication" $SSHD_CONFIG && \
sed -i "s/^PasswordAuthentication.*/PasswordAuthentication no/" $SSHD_CONFIG || \
echo "PasswordAuthentication no" >> $SSHD_CONFIG


grep -q "^ChallengeResponseAuthentication" $SSHD_CONFIG && \
sed -i "s/^ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/" $SSHD_CONFIG || \
echo "ChallengeResponseAuthentication no" >> $SSHD_CONFIG

# Enforce public key authentication
grep -q "^PubkeyAuthentication" $SSHD_CONFIG && \
sed -i "s/^PubkeyAuthentication.*/PubkeyAuthentication yes/" $SSHD_CONFIG || \
echo "PubkeyAuthentication yes" >> $SSHD_CONFIG

sshd -t && systemctl restart ssh

# UFW setup
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# Fail2Ban setup
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Enable ssh protection
sed -i "/^\[sshd\]/,/^\[/{s/enabled = false/enabled = true/}" /etc/fail2ban/jail.local
grep -q "maxretry = 5" /etc/fail2ban/jail.local || \
sed -i "/^\[sshd\]/a maxretry = 5\nbantime = 3600" /etc/fail2ban/jail.local

systemctl enable fail2ban
systemctl restart fail2ban

# Lock root account
passwd -l root

# Enable nginx
systemctl enable nginx
systemctl start nginx

# Setup docker
apt remove -y docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc || true

# Add Docker's official GPG key:
apt update
apt install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# Install Docker
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable docker
systemctl start docker

# Add to docker group
usermod -aG docker $USERNAME

# Setup swap (2GB)
fallocate -l 2G /swapfile || true
chmod 600 /swapfile
mkswap /swapfile || true
swapon /swapfile || true
grep -q swapfile /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Passwordless sudo (optional)
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME
chmod 440 /etc/sudoers.d/$USERNAME

echo "✅ Setup complete!"
echo "👉 Now login using:"
echo "ssh $USERNAME@YOUR_SERVER_IP"