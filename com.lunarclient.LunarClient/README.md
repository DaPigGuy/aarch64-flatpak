# Lunar Client

## Installing
Installation of this patched app implies Flatpak. Otherwise, you're on your own.

### From Flatpak Remote
```sh
flatpak remote-add --if-not-exists aarch64-flatpak https://dapigguy.github.io/aarch64-flatpak/aarch64-flatpak.flatpakrepo
flatpak install com.lunarclient.LunarClient
```

### From Source
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

## Building Natives
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


Pre-built binaries for LWJGL 2 are not available for Linux aarch64. In order to support legacy versions of Minecraft, you will need to build `liblwjgl.so` and `libjinput-linux.so` yourself with the following simple steps:
```sh
# Install JDK 8, Ant, and Maven
sudo dnf install java-1.8.0-openjdk-devel ant maven

git clone https://github.com/lwjgl/lwjgl.git
cd lwjgl
# Use the exact commit used by Lunar Client
git checkout e4b098c5e20b9f4465e3a5efc34cc40684df259d

# Ensure Java 8 is being used. The path may be different on your system.
export JAVA_HOME=/usr/lib/jvm/java-1.8.0

# Install necessary development headers
sudo dnf install libX11-devel libXt-devel libXcursor-devel libXrandr-devel libXxf86vm-devel

sed -i 's/i386/aarch64/' ./platform_build/linux_ant/build.xml

ant generate-all
ant compile
ant compile_native
# Result at ./lib/linux/liblwjgl.so

cd ..
git clone https://github.com/jinput/jinput.git
cd jinput
git checkout 70f1bc2a8ea89b0ae4ecd7d02ad8bcb7a065b07c

sed -i 's/<module>applet<\/module>//' pom.xml
sed -i 's/<module>uberjar<\/module>//' pom.xml
sed -i 's/<module>examples<\/module>//' pom.xml
sed -i 's/<module>tests<\/module>//' pom.xml

mvn package

jar xf plugins/linux/target/linux-plugin-2.0.10-SNAPSHOT-natives-linux.jar libjinput-linux.so
# Result at current directory
```
For the other native libraries, use their versions from LWJGL 3.3.1 rather than LWJGL 2.


Compress your native libraries into a `.zip` archive for each LWJGL version and upload them. Update the corresponding information in `natives.json`. For the sha1 checksum, `sha1sum your.zip`. For the file size & file modified timestamp, `ls -l --time-style=+%s your.zip`. You can then reinstall the Flatpak, which will now use your natives.


LWJGL Versions
| Minecraft        | LWJGL             |
|------------------|-------------------|
| 1.7 / 1.8 / 1.12 | 2.9.4-20150209    |
| 1.16-1.17        | 3.2.3             |
| 1.18-1.20.1      | 3.3.1             |
| 1.20.2-1.20.4    | 3.3.2             |