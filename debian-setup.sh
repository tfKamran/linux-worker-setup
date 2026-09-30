# 1. Disable Suspend, Sleep, and Lid Switch Actions
echo "[+] Configuring power management to prevent sleep..."
mkdir -p /etc/systemd/logind.conf.d/
cat << 'EOF' > /etc/systemd/logind.conf.d/prevent-sleep.conf
[Login]
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
IdleAction=ignore
EOF

# Disable GNOME/Desktop idle sleep if a GUI is present
if command -v gsettings &> /dev/null; then
  echo "[+] Disabling GNOME desktop sleep settings..."
  sudo -u ${SUDO_USER:-$USER} gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
  sudo -u ${SUDO_USER:-$USER} gsettings set org.gnome.desktop.session idle-delay 0
fi

systemctl restart systemd-logind

# 2. Install and Configure OpenSSH Server
echo "[+] Installing and enabling OpenSSH Server..."
apt update && apt install -y openssh-server
systemctl enable --now ssh

# Configure firewall (UFW) if active
if ufw status | grep -q "Status: active"; then
  echo "[+] Allowing SSH through UFW firewall..."
  ufw allow ssh
fi
