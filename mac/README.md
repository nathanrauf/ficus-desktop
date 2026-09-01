# Ficus for macOS

Blocks social media sites on macOS, at the OS level, the same way the [Windows version](../windows/) does: by redirecting domains to nowhere in `/etc/hosts`, so it applies across every browser at once.

Verified working on a real Mac: the CLI blocks and unblocks correctly and `Ficus.applescript` compiles cleanly into a double-clickable app. If something's off, please open an issue.

## Usage

### GUI

Open [Ficus.applescript](Ficus.applescript) in Script Editor (just double-click it) and press Run. It'll ask for your Mac password whenever you turn the block on or off, since editing `/etc/hosts` requires admin rights.

Prefer something double-clickable? Open Terminal in this folder and run:

```bash
osacompile -o Ficus.app Ficus.applescript
```

Keep `Ficus.app` in this same folder afterward. It calls the `.sh` files sitting next to it, so it needs them nearby.

### Command line

```bash
cd mac

# Turn the block on
sudo bash ficus-cli.sh

# Turn it off
sudo bash ficus-cli.sh --disable
```

The first time you run this, it backs up your original hosts file to `/etc/hosts.bak`.

## Customizing the list

In the GUI, use "Edit Sites" to check/uncheck domains or add your own — this is saved to `~/.ficus/domains.txt` and `~/.ficus/checked.txt`. On the command line, edit the `DEFAULT_DOMAINS` array near the top of [ficus_core.sh](ficus_core.sh).

## Known limitations

- **Requires admin rights each time you toggle it.** That's intentional, but it also means anyone else with an admin account on the machine can turn the block off just as easily as you can turn it on.
- **Browsers with Secure DNS (DNS-over-HTTPS) enabled can bypass `/etc/hosts` entirely**, since they resolve domains themselves instead of asking macOS. If a blocked site still loads, turn that off. In Chrome: Settings → Privacy and security → Security → "Use secure DNS" → off. In Firefox: Settings → Privacy & Security → DNS over HTTPS → off. Safari doesn't have its own DoH toggle, but if iCloud Private Relay is turned on, it can route DNS around the hosts file too — turn it off under System Settings → [your name/Apple ID] → iCloud → Private Relay.
- **Apps that hardcode IP addresses instead of using domain names** won't be affected. This is rare in practice.
- This only blocks the Mac it's run on. It doesn't touch your phone or anything else on the network.

See the [repo root](../README.md) for what Ficus is and licensing.
