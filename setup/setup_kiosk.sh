#!/bin/bash
# Chromium Kiosk Mode Setup for Raspberry Pi
# Configures the Pi to boot directly into the slot machine interface

set -e

echo "===== Chromium Kiosk Mode Setup ====="
echo ""

# Install Chromium and X server if not installed
echo "[1/4] Installing Chromium and X server..."
sudo apt install -y chromium-browser xserver-xorg x11-xserver-utils xinit openbox

# Disable screen blanking and power management
echo "[2/4] Disabling screen blanking..."
sudo tee /etc/xdg/openbox/autostart > /dev/null <<'EOF'
# Disable screen blanking
xset s off
xset s noblank
xset -dpms

# Hide mouse cursor after inactivity
unclutter -idle 0.1 &

# Start Chromium in kiosk mode
chromium-browser --noerrdialogs --disable-infobars --kiosk --disable-session-crashed-bubble --disable-restore-session-state http://localhost:8000 &
EOF

# Install unclutter to hide mouse cursor
echo "[3/4] Installing unclutter..."
sudo apt install -y unclutter

# Set up auto-login and auto-start X
echo "[4/4] Configuring auto-login..."
sudo raspi-config nonint do_boot_behaviour B4  # Auto-login to desktop

# Create autostart script for current user
mkdir -p ~/.config/lxsession/LXDE-pi
tee ~/.config/lxsession/LXDE-pi/autostart > /dev/null <<'EOF'
@lxpanel --profile LXDE-pi
@pcmanfm --desktop --profile LXDE-pi
@xscreensaver -no-splash
@point-rpi

# Disable screen blanking
@xset s off
@xset s noblank
@xset -dpms

# Hide cursor
@unclutter -idle 0.1 -root

# Launch Chromium in kiosk mode
@chromium-browser --noerrdialogs --disable-infobars --kiosk --disable-session-crashed-bubble --disable-restore-session-state http://localhost:8000
EOF

echo ""
echo "===== Kiosk Mode Setup Complete! ====="
echo ""
echo "The Raspberry Pi will now:"
echo "- Auto-login on boot"
echo "- Launch Chromium in fullscreen kiosk mode"
echo "- Open http://localhost:8000 automatically"
echo "- Hide the mouse cursor"
echo "- Disable screen blanking"
echo ""
echo "Reboot to test:"
echo "  sudo reboot"
echo ""
echo "To disable kiosk mode, remove:"
echo "  ~/.config/lxsession/LXDE-pi/autostart"
echo ""
