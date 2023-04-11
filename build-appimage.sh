#!/bin/bash -e
# build-online-appimage.sh

ZSYNC_STRING="gh-releases-zsync|JaredWhiteOne|Vanilla-AppImage|latest|Vanilla_Netplay_V3-x86-64.AppImage.zsync"
APPIMAGE_STRING="Vanilla_Netplay_V3-x86-64.AppImage"

UPDATEPLUG_PATH="https://github.com/linuxdeploy/linuxdeploy-plugin-appimage/releases/download/continuous"
UPDATEPLUG_FILE="linuxdeploy-plugin-appimage-x86_64.AppImage"
UPDATEPLUG_URL="${UPDATEPLUG_PATH}/${UPDATEPLUG_FILE}"

UPDATETOOL_PATH="https://github.com/AppImage/AppImageUpdate/releases/download/continuous"
UPDATETOOL_FILE="appimageupdatetool-x86_64.AppImage"
UPDATETOOL_URL="${UPDATETOOL_PATH}/${UPDATETOOL_FILE}"

APPDIR_BIN="./AppDir/usr/bin"

# Grab various appimage binaries from GitHub if we don't have them
if [ ! -e ./Tools/linuxdeploy ]; then
	wget -c https://github.com/$(wget -q https://github.com/probonopd/go-appimage/releases/expanded_assets/continuous -O - | grep "appimagetool-.*-x86_64.AppImage" | head -n 1 | cut -d '"' -f 2)
	chmod +x appimagetool-*.AppImage
fi
if [ ! -e ./Tools/linuxdeploy-update-plugin ]; then
	wget ${UPDATEPLUG_URL} -O ./Tools/linuxdeploy-update-plugin
	chmod +x ./Tools/linuxdeploy-update-plugin
fi
if [ ! -e ./Tools/appimageupdatetool ]; then
	wget ${UPDATETOOL_URL} -O ./Tools/appimageupdatetool
	chmod +x ./Tools/appimageupdatetool
fi

# Delete the AppDir folder to prevent build issues
rm -rf ./AppDir/

# Build the AppDir directory for this image
mkdir -p AppDir
./linuxdeploy-plugin-appimage-x86_64 \
	--appdir=./AppDir \
	-e ./build/Binaries/ishiiruka \
	-d ./Data/ishiiruka.desktop \
	-i ./Data/ishiiruka.png

# Add the Sys dir to the AppDir for packaging
cp -r Data/Sys ${APPDIR_BIN}

echo "Using Netplay build config"

rm -f ${APPIMAGE_STRING}
		
# Package up the update tool within the AppImage
cp ./Tools/appimageupdatetool ./AppDir/usr/bin/

# remomve libs that will cause conflicts
rm ./AppDir/usr/lib/libgmodule*
rm ./AppDir/usr/lib/libgdk_pixbuf*
rm ./AppDir/usr/lib/libgio*
rm ./AppDir/usr/lib/libglib*
rm ./AppDir/usr/lib/libgobject*

# Bake an AppImage with the update metadata
export VERSION="2.3.1"
UPDATE_INFORMATION="${ZSYNC_STRING}" \
	./Tools/linuxdeploy-update-plugin --appdir=./AppDir/


mv Vanilla_Netplay_V3-$VERSION-x86_64.AppImage Vanilla_Netplay_V3-x86-64.AppImage
mv Vanilla_Netplay_V3-$VERSION-x86_64.AppImage.zsync Vanilla_Netplay_V3-x86-64.AppImage.zsync
