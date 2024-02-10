# aarch64 Flatpaks

This repo contains various Flatpaks for apps patched to (**unofficially**) support arm64 Linux. Apps have been tested on the Asahi Fedora Remix for Apple Silicon devices but should run fine on any arm64 devices/distros (Raspberry Pi 5, etc.)

## Flatpak Remote
A Flatpak remote is provided, managed by [GitHub Actions](https://github.com/DaPigGuy/aarch64-flatpak/blob/master/.github/workflows/flatpak_repo.yml) and hosted on [GitHub Pages](https://github.com/DaPigGuy/aarch64-flatpak/tree/gh-pages), in order to easily keep up with updates.

```sh
flatpak remote-add --if-not-exists aarch64-flatpak https://dapigguy.github.io/aarch64-flatpak/index.flatpakrepo
```