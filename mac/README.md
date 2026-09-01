# Ficus for macOS

Blocks social media sites on macOS, at the OS level, the same way the [Windows version](../windows/) does: by redirecting domains to nowhere in `/etc/hosts`, so it applies across every browser at once.

Built and syntax-checked on a Windows machine, not yet run on an actual Mac. If something's off, please open an issue.

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

Same caveats as the [Windows version](../windows/README.md): browsers with Secure DNS/DNS-over-HTTPS enabled can bypass `/etc/hosts`, and this only affects the machine it's run on.

See the [repo root](../README.md) for what Ficus is and licensing.
