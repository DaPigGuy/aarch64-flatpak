# Extract the contents of the AppImage
unappimage LunarClient.AppImage

# Extract the contents of the app.asar file
cd squashfs-root/resources
npx @electron/asar extract app.asar extracted_asar

cd extracted_asar

# Get rid of the bsdiff-node dependency. It's a complete pain in the ass.
sed -i '/bsdiff-node/d' package.json
sed -i -E 's/,bsdiff=require\("bsdiff-node"\)//' dist-electron/electron/main.js
sed -i -E 's/await bsdiff\.patch\([a-zA-Z\.,]+\)/throw new Error("bsdiff-node dependency removed")/' dist-electron/electron/main.js

# Disable launcher auto-updates
sed -i -E 's/checkForUpdates\(([A-Z])\)\{/checkForUpdates(\1){return;/' dist-electron/electron/main.js
sed -i -E 's/setupListeners\(\)\{/setupListeners(){return;/' dist-electron/electron/main.js

# Replace the JRE
JRE_URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.9%2B9/OpenJDK17U-jre_aarch64_linux_hotspot_17.0.9_9.tar.gz"
JRE_NAME="jdk-17.0.9+9-jre"
JRE_CHECKSUM="3c9d7c21dff3bc99097bf26ef94d163377119e74"
sed -i -E 's#class JREStage extends LaunchStage\{constructor\(([A-Z]),([A-Z,]+)\)\{#class JREStage extends LaunchStage{constructor(\1,\2){\1.download.url="'$JRE_URL'";\1.executablePathInArchive=["'$JRE_NAME'", "bin", "java"];\1.folderChecksum="'$JRE_CHECKSUM'";#' dist-electron/electron/main.js

# Replace the natives
NATIVES_URL="https://raw.githubusercontent.com/DaPigGuy/aarch64-flatpak/master/com.lunarclient.LunarClient/client-natives-linux-aarch64.zip"
NATIVES_SHA1_CHECKSUM="2aa2d91b5079168300fbf28cd068c98e76539a1a"
NATIVES_SIZE="292770"
NATIVES_MODIFIED_TIME="1703321377"
sed -i -E 's#class ArtifactsStage extends LaunchStage\{constructor\(([A-Z]),([A-Z]),([A-Z,]+)\)\{#class ArtifactsStage extends LaunchStage{constructor(\1,\2,\3){const nativesFile=\2.filter(file=>file.type==="NATIVES")[0];nativesFile.name="client-natives-linux-aarch64.zip";nativesFile.sha1="'$NATIVES_SHA1_CHECKSUM'";nativesFile.size='$NATIVES_SIZE';nativesFile.mtime='$NATIVES_MODIFIED_TIME';#' dist-electron/electron/main.js

# Identify as an x64 system to Lunar Client servers
sed -i -E 's/cpuArchitecture:process\.arch/cpuArchitecture:"x64"/' dist-electron/electron/main.js

# Install packages
npm install

# Repackage the contents of the app.asar
npx electron-packager . --electron-version=28.0.0