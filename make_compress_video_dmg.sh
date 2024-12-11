#!/bin/bash

# DMG Creation Script for Quick Action Installer

# Configuration
PRODUCT_NAME="Quick Actions X"
VERSION="0.0.1"
VOLUME_NAME="${PRODUCT_NAME} Installer"
QUICK_ACTION_SOURCE="./workflows/compress_video.workflow"

# Paths
STAGING_DIR="$(mktemp -d)"
FINAL_DMG="${PRODUCT_NAME}_v${VERSION}.dmg"

# Create staging directory structure
mkdir -p "${STAGING_DIR}/Installer"

# Copy installation files
cp main_installer.sh "${STAGING_DIR}/Installer/"
# cp README.md "${STAGING_DIR}/Installer/"
cp -R "${QUICK_ACTION_SOURCE}" "${STAGING_DIR}/Installer/"

# Create background image (optional, but professional)
# You'll need to create a background.png file separately
mkdir -p "${STAGING_DIR}/.background"
cp background.png "${STAGING_DIR}/.background/"

# Create DMG
hdiutil create -fs HFS+ -volname "${VOLUME_NAME}" -srcfolder "${STAGING_DIR}" "${FINAL_DMG}"

# Make DMG read-only and internet-enabled
hdiutil convert "${FINAL_DMG}" -format UDZO -o "${FINAL_DMG}"
hdiutil internet-enable -yes "${FINAL_DMG}"

# Clean up
rm -rf "${STAGING_DIR}"

echo "DMG created successfully: ${FINAL_DMG}"