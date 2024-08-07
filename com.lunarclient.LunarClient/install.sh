mv squashfs-root/resources/extracted_asar/lunarclient-linux-arm64/ /app/lunarclient/

# Install app contents
install lunarclient "/${FLATPAK_DEST}/bin"
install -Dm644 com.lunarclient.LunarClient.metainfo.xml "${FLATPAK_DEST}/share/metainfo/${FLATPAK_ID}.metainfo.xml"
install -Dm644 com.lunarclient.LunarClient.desktop "${FLATPAK_DEST}/share/applications/${FLATPAK_ID}.desktop"
install -Dm644 com.lunarclient.LunarClient.png ${FLATPAK_DEST}/share/icons/hicolor/512x512/apps/lunarclient.png

# Cleanup
rm LunarClient.AppImage
rm -r squashfs-root
