# Lunar Client

## Installing
Installation of this patched app implies Flatpak. Otherwise, you're on your own.

```sh
git clone https://github.com/DaPigGuy/aarch64-flatpak
cd aarch64-flatpak/com.lunarclient.LunarClient
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
This section is on building your own natives. This is not required and the patched app will download natives from this repo by default.

You will need `libwebp-imageio.so` for Lunar Client. Unfortunately, the upstream is unmaintained and does not support aarch64. However, there is a [pull request](https://github.com/sejda-pdf/webp-imageio/pull/6) to resolve this.
```sh
git clone https://github.com/gotson/webp-imageio.git
git checkout dev

# You will need Docker
./dockcross/dockcross-linux-arm64 bash -c './compile.sh Linux aarch64'

# Result at ./build/Linux/aarch64/src/main/c/libwebp-imageio.so
```


If you plan to play on Minecraft versions prior to 1.13, you will also need to build LWJGL2.
```sh
# TODO
```


Create a `.zip` archive containing your natives and upload them somewhere. Change `NATIVES_URL` to your URL and update `NATIVES_SHA1_CHECKSUM`/`NATIVES_SIZE`/`NATIVES_MODIFIED_TIME` (values can be obtained with `sha1sum your.zip` and `ls -l --time-style=+%s your.zip`) in `patch.sh`. You can now reinstall the Flatpak.