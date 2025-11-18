# Raspberry Pi Deployment Guide

This guide will help you deploy the BrainrotGenerator slot machine on a Raspberry Pi with GPIO buttons.

## Hardware Requirements

- Raspberry Pi (3B+ or newer recommended)
- 3x Push buttons or switches connected to GPIO pins:
  - GPIO 23 → Reel A (left)
  - GPIO 27 → Reel B (middle)
  - GPIO 22 → Reel C (right)
- HDMI display
- Keyboard (for initial setup only)
- Network connection (WiFi or Ethernet)

## Quick Setup

### 1. Transfer Files to Raspberry Pi

```bash
# On your computer, compress the project
cd /path/to/BrainrotGenerator
zip -r slotmachine.zip slotmachine/

# Copy to Raspberry Pi (replace with your Pi's IP)
scp slotmachine.zip pi@192.168.1.XXX:~/

# On the Pi, extract
ssh pi@192.168.1.XXX
cd ~
unzip slotmachine.zip
cd slotmachine
```

### 2. Run Setup Script

```bash
# Make scripts executable
chmod +x setup_pi.sh setup_kiosk.sh

# Run the main setup
bash setup_pi.sh
```

This will:
- Update system packages
- Install Python 3 and GPIO libraries
- Create Python virtual environment
- Install all dependencies
- Create systemd service for auto-start
- Set up pigpio daemon for GPIO

### 3. Configure OpenAI API Key

```bash
# Edit the .env file
nano .env

# Add your OpenAI API key:
OPENAI_API_KEY=sk-your-actual-key-here

# Save and exit (Ctrl+X, Y, Enter)
```

### 4. Test the Backend

```bash
cd backend
../env/bin/python main.py
```

Open a browser on another device and navigate to `http://[PI_IP_ADDRESS]:8000` to test.

### 5. Set Up Static IP (Recommended)

```bash
# Configure static IP using NetworkManager
sudo nmcli connection modify "YOUR_WIFI_NAME" \
  ipv4.addresses 192.168.178.150/24 \
  ipv4.gateway 192.168.178.1 \
  ipv4.dns "8.8.8.8,8.8.4.4" \
  ipv4.method manual

# Restart connection
sudo nmcli connection down "YOUR_WIFI_NAME"
sudo nmcli connection up "YOUR_WIFI_NAME"
```

Replace `YOUR_WIFI_NAME` with your actual WiFi network name (use `nmcli connection show` to list).

### 6. Enable Auto-Start Service

```bash
# Start the backend service
sudo systemctl start brainrot-backend

# Check status
sudo systemctl status brainrot-backend

# View logs
sudo journalctl -u brainrot-backend -f
```

The service will now start automatically on boot.

### 7. Set Up Kiosk Mode (Optional)

```bash
# Run kiosk setup script
bash setup_kiosk.sh

# Reboot to activate kiosk mode
sudo reboot
```

After reboot, the Pi will automatically launch Chromium in fullscreen mode showing the slot machine.

## Testing GPIO Buttons

Test if GPIO buttons are working:

```bash
# Install GPIO test utility
sudo apt install -y python3-gpiozero

# Test button on GPIO 23
python3 -c "from gpiozero import Button; b = Button(23); print('Press button...'); b.wait_for_press(); print('Button works!')"
```

## Troubleshooting

### Backend Won't Start

```bash
# Check service status
sudo systemctl status brainrot-backend

# View detailed logs
sudo journalctl -u brainrot-backend -n 50

# Test manually
cd ~/slotmachine/backend
../env/bin/python main.py
```

### GPIO Buttons Not Working

```bash
# Check if pigpiod is running
sudo systemctl status pigpiod

# Restart pigpiod
sudo systemctl restart pigpiod

# Check GPIO permissions
sudo usermod -aG gpio $USER
# Log out and back in for this to take effect
```

### Images Not Generating

1. Check OpenAI API key in `.env`
2. Verify network connectivity: `ping api.openai.com`
3. Check backend logs: `sudo journalctl -u brainrot-backend -f`

### Screen Blanking

```bash
# Disable screen blanking
sudo raspi-config
# Navigate to: Display Options → Screen Blanking → No
```

### Kiosk Mode Not Starting

```bash
# Check autostart file
cat ~/.config/lxsession/LXDE-pi/autostart

# Test Chromium manually
DISPLAY=:0 chromium-browser --kiosk http://localhost:8000
```

## Gallery Page Navigation

From the gallery page, press any GPIO button to return to the slot machine.

## Maintenance

### View Backend Logs
```bash
sudo journalctl -u brainrot-backend -f
```

### Restart Backend
```bash
sudo systemctl restart brainrot-backend
```

### Stop Auto-Start
```bash
sudo systemctl stop brainrot-backend
sudo systemctl disable brainrot-backend
```

### Update Code
```bash
cd ~/slotmachine
git pull  # If using git
# Or manually copy updated files

# Restart service
sudo systemctl restart brainrot-backend
```

### Clear Generated Images
```bash
cd ~/slotmachine/frontend/generated
rm *.png
echo "[]" > manifest.jsonl
```

## Performance Tips

- Use Raspberry Pi 4 or 5 for better performance
- Close unnecessary background applications
- Consider using a lightweight OS (Raspberry Pi OS Lite + minimal X server)
- Reduce animation complexity if experiencing lag

## Security Notes

- Change default Pi password: `passwd`
- Use firewall if exposing to network: `sudo apt install ufw`
- Keep `.env` file secure (contains API key)
- Regularly update system: `sudo apt update && sudo apt upgrade`
