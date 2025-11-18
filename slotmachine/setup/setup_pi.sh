#!/bin/bash
# Raspberry Pi Setup Script for BrainrotGenerator Slot Machine
# This script installs all dependencies and configures the system for kiosk mode

set -e  # Exit on error

echo "===== BrainrotGenerator Raspberry Pi Setup ====="
echo ""

# Update system packages
echo "[1/7] Updating system packages..."
sudo apt update
sudo apt upgrade -y

# Install Python 3 and pip if not already installed
echo "[2/7] Installing Python 3 and pip..."
sudo apt install -y python3 python3-pip python3-venv

# Install system dependencies for GPIO
echo "[3/7] Installing GPIO dependencies..."
sudo apt install -y python3-gpiozero pigpio
sudo systemctl enable pigpiod
sudo systemctl start pigpiod

# Create virtual environment
echo "[4/7] Creating Python virtual environment..."
if [ ! -d "env" ]; then
    python3 -m venv env
fi

# Activate virtual environment and install Python packages
echo "[5/7] Installing Python packages..."
source env/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Create .env file if it doesn't exist
echo "[6/7] Setting up environment variables..."
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo "Created .env file from .env.example"
        echo "IMPORTANT: Edit .env and add your OPENAI_API_KEY"
    else
        echo "OPENAI_API_KEY=your_key_here" > .env
        echo "Created .env file"
        echo "IMPORTANT: Edit .env and add your OPENAI_API_KEY"
    fi
else
    echo ".env file already exists"
fi

# Create systemd service for auto-start
echo "[7/7] Creating systemd service..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo tee /etc/systemd/system/brainrot-backend.service > /dev/null <<EOF
[Unit]
Description=BrainrotGenerator Backend
After=network.target pigpiod.service

[Service]
Type=simple
User=$USER
WorkingDirectory=$SCRIPT_DIR
Environment="PATH=$SCRIPT_DIR/env/bin"
ExecStart=$SCRIPT_DIR/env/bin/python backend/main.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable brainrot-backend.service

echo ""
echo "===== Setup Complete! ====="
echo ""
echo "Next steps:"
echo "1. Edit .env and add your OPENAI_API_KEY"
echo "2. Test the backend manually:"
echo "   cd $SCRIPT_DIR/backend"
echo "   ../env/bin/python main.py"
echo ""
echo "3. Start the service:"
echo "   sudo systemctl start brainrot-backend"
echo "   sudo systemctl status brainrot-backend"
echo ""
echo "4. Configure Chromium kiosk mode (optional):"
echo "   Run: bash setup_kiosk.sh"
echo ""
