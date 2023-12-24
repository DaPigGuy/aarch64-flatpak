# Lunar Client

## Installing
Installation of this patched app implies Flatpak. Otherwise, you're on your own.

```sh
git clone https://github.com/DaPigGuy/aarch64-flatpak
cd aarch64-flatpak/com.lunarclient.LunarClient
flatpak install org.freedesktop.Sdk//23.08 org.freedesktop.Platform//23.08 org.electronjs.Electron2.BaseApp//23.08 org.freedesktop.Sdk.Extension.node18//23.08
flatpak-builder build-dir com.lunarclient.LunarClient.yml --force-clean --user --install
```

## Changes
The changes from the official Linux x86_64 version of Lunar Client are pretty straight forward:
- Remove the bsdiff-node dependency
  - It is only used for "differential downloads." Since it's a rather pain in the ass to get building, it is not worth it for the slightly faster downloads/slightly less bandwidth used.
- Disable auto updates
  - Newer versions of Lunar Client could require new patches or break existing ones.
  - Auto updates will fail under a sandbox like Flatpak.
- Download a JRE for Linux aarch64 instead of Linux x86_64
- Download natives built for Linux aarch64 from this repo
  - For the paranoid, see [Building Natives](#building-natives) below for instructions on building your own.
- Identify as an `x64` system to Lunar Client authentication servers
  - `aarch64` will result in an unsupported system error.

See `patch.sh` for additional details.


The patched app is then packed with the latest version of Electron, rather than the older version used by Lunar Client, to include the latest fixes for ((16k page size) aarch64) Linux, (X)Wayland, etc.

# Building Natives
**This section is on building your own natives. This is not required and the patched app will download natives from this repo by default.**

You will need to do the following for several versions of LWJGL in order to support all versions of the game.

All versions will share the same `libwebp-imageio64.so`. Unfortunately, the upstream is unmaintained and does not support aarch64. However, there is a [pull request](https://github.com/sejda-pdf/webp-imageio/pull/6) to resolve this. Building is as simple as;
```sh
git clone https://github.com/gotson/webp-imageio.git
git checkout dev

# You will need Docker
./dockcross/dockcross-linux-arm64 bash -c './compile.sh Linux aarch64'

# Result at ./build/Linux/aarch64/src/main/c/libwebp-imageio.so
# Rename to libwebp-imageio64.so
```


You will then need the following LWJGL native libraries for each LWJGL version listed in the `natives.json` file: `libopenal`, `liblwjgl_tinyfd`, `liblwjgl_stb`, `liblwjgl_opengl`, `liblwjgl`, `libjemalloc`, `libglfw`. For 16k page sizes (Asahi Linux / Raspberry Pi 5), you will need a more up to date version of `libjemalloc` (from LWJGL 3.3.3). You can find them prebuilt on the [official LWJGL site](https://www.lwjgl.org/browse/release).


Compress your native libraries into a `.zip` archive for each LWJGL version and upload them. Update the corresponding information in `natives.json`. For the sha1 checksum, `sha1sum your.zip`. For the file size & file modified timestamp, `ls -l --time-style=+%s your.zip`. You can then reinstall the Flatpak, which will now use your natives.


LWJGL Versions
| Minecraft        | LWJGL             |
|------------------|-------------------|
| 1.7 / 1.8 / 1.12 | Not Yet Supported |
| 1.16-1.17        | 3.2.3             |
| 1.18-1.19        | 3.3.1             |
| 1.20             | 3.3.2             |