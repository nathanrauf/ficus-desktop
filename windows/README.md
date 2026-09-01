# Ficus for Windows

Blocks social media sites on Windows, at the OS level, so it works across every browser instead of just one.

It works by pointing social media domains at `0.0.0.0` in the Windows hosts file (`C:\Windows\System32\drivers\etc\hosts`). Because Windows checks that file before doing a DNS lookup, this covers every browser on the machine, including private/incognito windows, and any other app that goes through the normal system resolver.

## Usage

### GUI

Double-click [Launch-GUI.bat](Launch-GUI.bat). You'll see:

- a status line showing BLOCKED or NOT BLOCKED
- a checklist of sites, check or uncheck to choose what gets blocked (saved automatically to `config.json`)
- a box for adding your own domains
- a Block Now / Unblock Now button

The first time it needs to write to the hosts file, Windows will show a UAC prompt asking for admin rights. That's normal; editing the hosts file requires elevation. If you change checkboxes while a block is already active, hit Unblock Now and then Block Now again so the new selection actually takes effect.

### Command line

Open PowerShell as Administrator, then:

```powershell
cd "C:\Coding Projects\ficus-desktop\windows"

# Turn the block on
.\Block-SocialMedia.ps1

# Turn it off
.\Block-SocialMedia.ps1 -Disable
```

The first time you run this, it backs up your original hosts file to `hosts.bak` in the same `drivers\etc` folder.

## Customizing the list

In the GUI, just use the checklist and the "Add site" box. On the command line, edit the `$DefaultDomains` array near the top of [SocialMediaBlockerCore.ps1](SocialMediaBlockerCore.ps1).

Running `Block-SocialMedia.ps1` again, with or without `-Disable`, is safe to repeat. It just replaces the block section of the hosts file rather than stacking up duplicate entries.

## Known limitations

- **Requires admin rights each time you toggle it.** That friction is intentional, but it also means anyone with an admin account on the machine can turn the block off just as easily as you can turn it on.
- **Browsers with Secure DNS (DNS-over-HTTPS) enabled can bypass the hosts file entirely**, since they resolve domains themselves instead of asking Windows. If a blocked site still loads, turn that off. In Chrome: Settings → Privacy and security → Security → "Use secure DNS" → off. In Firefox: Settings → Privacy & Security → DNS over HTTPS → off.
- **Apps that hardcode IP addresses instead of using domain names** won't be affected. This is rare in practice; if it turns out to matter, adding Windows Firewall rules as a backstop is a reasonable next step.
- This only blocks the Windows machine it's run on. It doesn't touch phones or anything else on the network.

## How it works

The script writes a marked block between `# >>> social-media-blocker >>>` and `# <<< social-media-blocker <<<` comments in the hosts file, so it can find and cleanly remove just its own entries without disturbing anything else already in the file. `SocialMediaBlockerCore.ps1` holds the actual blocking logic, and both the CLI script and the GUI call into it, so they can't drift apart.

See the [repo root](../README.md) for what Ficus is and licensing.
