# Ficus for Linux

Not built yet. Same idea as [../windows/](../windows/) and [../mac/](../mac/): OS-level social media blocking, adapted to Linux.

Likely approach: entries in `/etc/hosts` (same mechanism as macOS), since that file works the same way across most Linux distros. A GUI would need a toolkit choice (GTK is the safest bet for cross-distro compatibility) or could be skipped in favor of a CLI script plus a systemd timer for scheduled blocking, if that ends up covering most of the need.
