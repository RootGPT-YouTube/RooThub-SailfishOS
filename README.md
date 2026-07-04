<p align="center">
  <img src="images/roothub.svg" width="140" alt="RooThub icon">
</p>

<h1 align="center">RooThub</h1>

<p align="center"><b>A native GitHub client for Sailfish OS.</b></p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-Sailfish%20OS%205.0%20%2F%205.1-00b4d8">
  <img src="https://img.shields.io/badge/arch-aarch64%20%C2%B7%20armv7hl%20%C2%B7%20i486-00b4d8">
  <img src="https://img.shields.io/badge/license-GPL--3.0-00b4d8">
</p>

---

RooThub brings GitHub to your Sailfish phone as a fast, fully native **Silica** app.
Browse repositories, read and manage issues and pull requests, follow your
notifications, search GitHub, view profiles — and even edit files and commit
straight from the device. It's part of the **RooT\*** family, with a neon‑blue
circuit look (and a plain Silica theme if you prefer).

## Features

| Area | What you can do |
|------|-----------------|
| **Repositories** | Yours, starred, by user, or via search; overview with README, ★ star / 👁 watch, **make public/private**, and **delete** (admin) |
| **Code** | Browse the file tree, view files and images, and **edit + commit** files with a built‑in editor (Contents API) |
| **Issues** | List / filter (open·closed·all), read, comment, close/reopen, and open new issues |
| **Pull requests** | List, read, comment, close/reopen, and **merge** |
| **Notifications** | Inbox with unread markers; open threads, mark read / mark all read |
| **Search** | Repositories, issues & PRs, users, and code |
| **Profiles** | User/org profiles with follow/unfollow and their repositories |

The interface is available in **English** and **Italian** (it follows the phone
language and falls back to English).

## Sign in

RooThub never asks for your GitHub password. Choose one of:

- **OAuth Device Flow** *(recommended)* — create a GitHub **OAuth App** with
  *Device Flow* enabled and paste its **Client ID**. The app shows a code you
  confirm at `github.com/login/device`. No client secret is stored on the device.
- **Personal Access Token** — paste a token generated at
  `github.com/settings/tokens`. For full functionality grant the scopes:
  `repo`, `read:org`, `notifications`, `user`, `gist` (add `delete_repo` to delete
  repositories).

The token is stored locally on the device (dconf) and sent only to `api.github.com`.

## Building

RooThub is a **pure‑QML** harbour app (a minimal C++ launcher). It builds with the
Sailfish SDK (`sfdk`). ⚠️ `sfdk build` builds **in‑source**, so clean between
architectures:

```sh
cd harbour-roothub
for arch in aarch64 armv7hl i486; do
  rm -f Makefile .qmake.stash *.o moc_* qrc_* harbour-roothub; rm -rf installroot
  sfdk -c target=SailfishOS-5.0.0.62-$arch build
done
# RPMs land in RPMS/
```

## Installing

Copy the RPM for your device's architecture and install it:

```sh
scp RPMS/harbour-roothub-<version>-1.aarch64.rpm nemo@<device-ip>:/tmp/
ssh nemo@<device-ip> 'devel-su pkcon install-local -y /tmp/harbour-roothub-<version>-1.aarch64.rpm'
```

(Xperia 10 III / 10 IV are `aarch64`; older 32‑bit devices are `armv7hl`; the
emulator is `i486`.)

## Tested on

- Sony Xperia 10 III — Sailfish OS 5.1.0.11
- Jolla C2 — Sailfish OS 5.1.0.11

## Notes

This application was developed with the help of AI (Claude Code). If using an
LLM‑assisted app is not for you, please don't install it. The software is provided
**as is**, without warranty of any kind; you use it entirely at your own risk.

## License

GPL‑3.0 — see [LICENSE](LICENSE). © 2026 RootGPT.

The ambient circuit background (`images/bg_circuits.svg`) is shared with the
sibling project **RooTelegram** (same author, GPL‑3.0).
