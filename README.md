<img src="assets/ficus-logo.webp" alt="Ficus logo" width="80">

# ficus-desktop

Blocks social media at the OS level so it can't be undone by just switching browsers or apps.

This project is an extension of the [Ficus iOS app](https://somewhatproductive.com/ficus/), which makes it difficult to exit apps on your phone. Ficus-desktop has the same goal in mind but this repo works entirely on its own; you don't need the iOS app to use it.

## Download

Grab the zip for your platform from the [Releases](../../releases) page — each one is just that platform's folder, so you only download what you need.

| Platform | Status | |
|---|---|---|
| Windows | Available | [windows/](windows/) |
| macOS | Available | [mac/](mac/) |
| Linux | Available | [linux/](linux/) |

## Windows

Redirects social media domains to nothing via the Windows hosts file, so the block applies across every browser on the machine at once. Comes with both a GUI and a command-line script.

See [windows/README.md](windows/README.md) for setup and usage.

## macOS

Same idea via `/etc/hosts`, with an AppleScript-based GUI and a command-line script. Built on a Windows machine and not yet run on real hardware, so treat it as early and file an issue if something's wrong.

See [mac/README.md](mac/README.md) for setup and usage.

## Linux

Same idea again via `/etc/hosts`, with a `zenity`-based GUI and a command-line script. Also built on a Windows machine and not yet run on a real Linux box, same caveat as macOS.

See [linux/README.md](linux/README.md) for setup and usage.

## License

MIT. See [LICENSE](LICENSE).
