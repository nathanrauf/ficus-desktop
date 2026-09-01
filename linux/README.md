# Ficus for Linux

Blocks social media sites on Linux, at the OS level, the same way the [Windows](../windows/) and [macOS](../mac/) versions do: by redirecting domains to nowhere in `/etc/hosts`, so it applies across every browser at once.

Built and syntax-checked on a Windows machine, not yet run on an actual Linux box. If something's off for your distro, please open an issue.

## Requirements

- `zenity` for the GUI dialogs. Usually available via your package manager: `sudo apt install zenity` (Debian/Ubuntu), `sudo dnf install zenity` (Fedora), `sudo pacman -S zenity` (Arch).
- `pkexec` for the admin password prompt. This ships with policykit, which most desktop distros already have installed. If it's missing, the CLI still works fine with `sudo`.

## Usage

### GUI

```bash
cd linux
bash ficus-gui.sh
```

It'll prompt for your password via a graphical dialog whenever you turn the block on or off.

### Command line

```bash
cd linux

# Turn the block on
sudo bash ficus-cli.sh

# Turn it off
sudo bash ficus-cli.sh --disable
```

The first time you run this, it backs up your original hosts file to `/etc/hosts.bak`.

## Customizing the list

In the GUI, use "Edit Sites" to check/uncheck domains or add your own — this is saved to `~/.ficus/domains.txt` and `~/.ficus/checked.txt`. On the command line, edit the `DEFAULT_DOMAINS` array near the top of [ficus_core.sh](ficus_core.sh).

## Known limitations

- **Requires admin/sudo rights each time you toggle it.** That's intentional, but it also means anyone else with sudo access on the machine can turn the block off just as easily as you can turn it on.
- **Browsers with Secure DNS (DNS-over-HTTPS) enabled can bypass `/etc/hosts` entirely**, since they resolve domains themselves instead of asking Linux. If a blocked site still loads, turn that off. In Chrome: Settings → Privacy and security → Security → "Use secure DNS" → off. In Firefox: Settings → Privacy & Security → DNS over HTTPS → off.
- **Apps that hardcode IP addresses instead of using domain names** won't be affected. This is rare in practice.
- DNS caching varies a lot across distros, so the cache-flush step is best-effort and may not do anything on your particular setup — that's fine, it doesn't affect whether the block actually works.
- This only blocks the Linux machine it's run on. It doesn't touch your phone or anything else on the network.

See the [repo root](../README.md) for what Ficus is and licensing.
