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
sed -i -E 's#class ArtifactsStage extends LaunchStage\{constructor\(([A-Z]),([A-Z]),([A-Z,]+)\)\{#class ArtifactsStage extends LaunchStage{constructor(\1,\2,\3){const nativesFile=\2.filter(file=>file.type==="NATIVES")[0];const natives='$(cat ../../../natives.json | jq -c)';const nativeName=natives.versions[Object.keys(natives.versions).filter(version=>nativesFile.name.includes("client-natives-linux-x86-"+version))[0]||"v1_20"];const native=natives.natives[nativeName];nativesFile.name=nativeName;nativesFile.url=native.url;nativesFile.sha1=native.sha1;nativesFile.size=native.size;nativesFile.mtime=native.mtime;#' dist-electron/electron/main.js

# Identify as an x64 system to Lunar Client servers
sed -i -E 's/process\.arch/"x64"/' dist-electron/electron/main.js

# Install packages
npm install

# Repackage the contents of the app.asar
npx electron-packager . --electron-version=28.0.0