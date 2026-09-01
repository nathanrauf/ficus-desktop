<img src="assets/ficus-logo.webp" alt="Ficus logo" width="80">

# ficus-desktop

Blocks social media at the OS level so it can't be undone by just switching browsers or apps.

This project is an extension of the [Ficus iOS app](https://somewhatproductive.com/ficus/), which makes it genuinely difficult to exit apps on your phone. Same goal, desktop side. That said, this repo works entirely on its own; you don't need the iOS app to use it.

| Platform | Status | |
|---|---|---|
| Windows | Available | [windows/](windows/) |
| macOS | Planned | [mac/](mac/) |
| Linux | Planned | [linux/](linux/) |

## Windows

Redirects social media domains to nothing via the Windows hosts file, so the block applies across every browser on the machine at once. Comes with both a GUI and a command-line script.

See [windows/README.md](windows/README.md) for setup and usage.

## macOS

Not built yet. The plan is the same idea adapted to macOS, most likely via `/etc/hosts` plus a small menu bar app rather than a `System32` hosts file and WinForms GUI, since the platforms don't share much below the concept level. See [mac/](mac/) once it exists.

## Linux

Not built yet. Same underlying idea, likely via `/etc/hosts` again since that mechanism is shared with macOS, with the GUI question depending on which desktop environments end up mattering most. See [linux/](linux/) once it exists.

## License

MIT. See [LICENSE](LICENSE).
