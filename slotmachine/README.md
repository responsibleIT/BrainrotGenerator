# BrainrotGenerator Slot Machine

An interactive kiosk-style **slot machine** that generates AI art using OpenAI's DALL-E 3. Users stop three spinning reels (Animal, Fruit, Object) and the system generates a unique "brainrot" themed image combining all three elements.

Designed for **Raspberry Pi** with physical GPIO buttons, but also works on desktop for development and testing.

## ✨ Features

- **3D Spinning Reels**: Smooth CSS-based cylinder animations with realistic physics
- **Physical GPIO Integration**: Works with switches or push buttons on Raspberry Pi
- **AI-Powered Generation**: Uses GPT-4o-mini for creative prompts and DALL-E 3 for images
- **Real-time WebSocket Communication**: Instant feedback between hardware and UI
- **Gallery System**: View all generated images with metadata
- **Kiosk Mode Ready**: Fullscreen, cursor-hidden interface perfect for exhibitions
- **Error Recovery**: Automatic reset on API failures, robust handshake mechanism

## 🎨 Design

- Custom typography using Adobe Typekit fonts (ironmonger-inlaid, freehouse)
- Golden yellow accent color (#ffcc33) with dark theme
- 3D CSS transforms for realistic reel effects
- Responsive animations optimized for Raspberry Pi performance

## 📁 Project Structure

```
slotmachine/
├── backend/
│   └── main.py              # FastAPI server with WebSocket & GPIO
├── frontend/
│   ├── index.html           # Slot machine interface
│   ├── gallery.html         # Image gallery viewer
│   ├── styles/
│   │   ├── common.css       # Shared styles
│   │   ├── slot.css         # Slot machine specific
│   │   └── gallery.css      # Gallery specific
│   └── generated/           # Generated images & manifest
├── setup/ (Still needs to be tested)
│   ├── DEPLOYMENT.md        # Complete Raspberry Pi guide
│   ├── setup_pi.sh          # Auto-setup script
│   └── setup_kiosk.sh       # Kiosk mode configuration
├── env/                     # Python virtual environment
├── requirements.txt         # Python dependencies
└── README.md
```

## 🚀 Quick Start (Development)

### 1. Install Dependencies

```bash
# Create virtual environment
python -m venv env

# Windows
env\Scripts\activate

# macOS/Linux
source env/bin/activate

# Install packages
pip install -r requirements.txt
```

### 2. Configure OpenAI API

Create a `.env` file:

```bash
OPENAI_API_KEY=sk-your-actual-key-here
```

### 3. Run the Server

```bash
cd backend
python main.py
```

The server starts on `http://localhost:8000`

### 4. Test the Interface

- **Slot Machine**: `http://localhost:8000`
- **Gallery**: `http://localhost:8000/static/gallery.html`

**Keyboard Controls** (for testing without GPIO):
- `A`, `S`, `D` - Stop reels A, B, C
- `R` - Reset

## 🥧 Raspberry Pi Deployment

For complete Raspberry Pi setup with GPIO buttons and kiosk mode, see:

**[setup/DEPLOYMENT.md](setup/DEPLOYMENT.md)**

Quick setup:

```bash
# Transfer project to Pi
scp -r slotmachine/ pi@192.168.1.XXX:~/

# On the Pi
cd slotmachine
chmod +x setup/*.sh
bash setup/setup_pi.sh

# Edit .env with your OpenAI key
nano .env

# Optional: Enable kiosk mode
bash setup/setup_kiosk.sh
```

### GPIO Pin Mapping

- **GPIO 23** → Reel A (Left - Animal)
- **GPIO 27** → Reel B (Middle - Fruit)  
- **GPIO 22** → Reel C (Right - Object)

Works with both push buttons and toggle switches.

## 🎮 How It Works

1. **Spin**: Three reels start spinning automatically showing random items
2. **Stop**: Press GPIO buttons (or A/S/D keys) to stop each reel
3. **Generate**: After all reels stop, frontend sends handshake to backend
4. **Prompt**: GPT-4o-mini creates a creative Italian name and DALL-E prompt
5. **Image**: DALL-E 3 generates the image (1024x1024, vivid style)
6. **Display**: Image appears fullscreen with metadata
7. **Gallery**: All images saved with timestamps and accessible from gallery page

## 🛠️ Technology Stack

- **Backend**: FastAPI, WebSockets, gpiozero, pigpio
- **Frontend**: Vanilla HTML/CSS/JavaScript with 3D transforms
- **AI**: OpenAI GPT-4o-mini (prompts), DALL-E 3 (images)
- **Hardware**: Raspberry Pi with GPIO buttons/switches
- **Deployment**: systemd service, Chromium kiosk mode

## 🐛 Troubleshooting

### Backend won't start
```bash
# Check Python environment
which python
python --version

# Check dependencies
pip list | grep fastapi

# View errors
cd backend
python main.py
```

### GPIO buttons not working
```bash
# Check pigpiod service
sudo systemctl status pigpiod

# Test GPIO manually
python3 -c "from gpiozero import Button; Button(23).wait_for_press(); print('Works!')"
```

### Images not generating
- Verify OpenAI API key in `.env`
- Check network: `ping api.openai.com`
- View backend logs: `sudo journalctl -u brainrot-backend -f`

## 📝 Notes

- Uses handshake mechanism to prevent frontend/backend desync
- Supports both switch state changes and button presses
- Auto-reset on API errors with user-friendly messages
- Images saved to `frontend/generated/` with JSONL manifest
- CSS optimized for Raspberry Pi performance (no heavy animations)

## 🔐 Security

- Keep `.env` file private (contains API key)
- Change default Pi password
- Use static IP for stable kiosk deployment
- Consider firewall if exposing to network

## 📜 License

MIT

