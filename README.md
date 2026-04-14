# opencode-anywhere

Access [OpenCode](https://opencode.ai) from your phone or any browser — from anywhere in the world, no VPN required.

Uses [Tailscale Funnel](https://tailscale.com/kb/1223/funnel) to expose your local OpenCode instance over a permanent public HTTPS URL. Your phone just needs a browser — no Tailscale app required.

## How it works

```
📱 Phone Browser (anywhere, any network)
        │  HTTPS
        ▼
☁️  Tailscale Funnel  (https://your-machine.tail-id.ts.net)
        │  encrypted tunnel
        ▼
🖥️  opencode web  (localhost:8443 on your Mac)
        │
        ▼
📁  Your local project files
```

Tailscale Funnel acts as a free reverse proxy — it gives your machine a **permanent public HTTPS URL** that never changes, even across reboots or IP changes. The password you set protects it from strangers.

## Requirements

- macOS (Apple Silicon or Intel)
- [OpenCode](https://opencode.ai/docs) installed
- [Tailscale](https://tailscale.com) installed via Homebrew (`brew install tailscale`)
- Tailscale Funnel enabled on your account ([enable it here](https://login.tailscale.com/admin/dns))

## Installation

```bash
git clone https://github.com/dhruvin3001/opencode-anywhere.git
cd opencode-anywhere
./install.sh
source ~/.zshrc
```

## Usage

### Foreground mode
Runs in your terminal. Press `Ctrl+C` to stop everything cleanly.

```bash
opencode-anywhere start
```

### Background mode
Detaches from the terminal — keeps running even after you close the window.

```bash
opencode-anywhere start --background
opencode-anywhere start -b          # same thing
```

### Other commands

```bash
opencode-anywhere stop              # stop the background instance
opencode-anywhere status            # check if running + show your URL
opencode-anywhere logs              # tail background logs
opencode-anywhere help              # show all commands
```

## Your permanent URL

Your public URL is based on your machine's Tailscale DNS name:

```
https://<your-machine-name>.tail-xxxx.ts.net
```

This URL **never changes** — it stays the same across reboots, network changes, and IP changes. Bookmark it on your phone.

## Password

On first run, you'll be prompted to set a password. It's saved to `~/.opencode-anywhere/.password` (chmod 600) so you're not asked again.

To change your password:
```bash
rm ~/.opencode-anywhere/.password
opencode-anywhere start
```

## What happens on startup

1. Checks that `tailscale` and `opencode` are installed
2. Auto-starts the Tailscale daemon if it's not running (asks for sudo once per boot)
3. Verifies you're logged into Tailscale
4. Prompts for (or loads) your access password
5. Starts Tailscale Funnel on port 8443
6. Prints your permanent public URL
7. Starts `opencode web` on `0.0.0.0:8443`

On `Ctrl+C` or `stop`: cleanly shuts down OpenCode and turns off the Funnel.

## State files

| Path | Description |
|------|-------------|
| `~/.opencode-anywhere/.password` | Saved access password (chmod 600) |
| `~/.opencode-anywhere/opencode.pid` | PID of running background process |
| `~/.opencode-anywhere/opencode.log` | Logs from background mode |

## One-time Tailscale setup

If you haven't set up Tailscale yet:

```bash
# Install
brew install tailscale

# Start daemon
sudo /opt/homebrew/opt/tailscale/bin/tailscaled --state=/var/lib/tailscale/tailscaled.state &

# Log in
tailscale up
```

Then [enable Funnel](https://login.tailscale.com/admin/dns) in the Tailscale admin console (DNS tab → enable HTTPS and Funnel).
