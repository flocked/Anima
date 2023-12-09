# Remember to change these two variables 👇
###########################################

SCHEME="Anima" # Remember to change this
DOCC_BUNDLE_PATH="Sources/Anima/Anima.docc"

###########################################

# Paths used in the script.
DERIVED_DATA_DIR=".deriveddata"
BUILD_DIR=".build"
SYMBOL_GRAPHS_DIR="${BUILD_DIR}/symbol-graphs"
SYMBOL_GRAPHS_DIR_IOS="${SYMBOL_GRAPHS_DIR}/ios"
SYMBOL_GRAPHS_DIR_MACOS="${SYMBOL_GRAPHS_DIR}/macos"
DOCCARCHIVE_PATH="${PWD}/${SCHEME}.doccarchive"

# Generate *.symbols.json file for iOS.
mkdir -p "${SYMBOL_GRAPHS_DIR_IOS}"
xcodebuild build \
  -scheme "${SCHEME}" \
  -destination "generic/platform=iOS" \
  -derivedDataPath "${DERIVED_DATA_DIR}" \
  OTHER_SWIFT_FLAGS="-emit-symbol-graph -emit-symbol-graph-dir ${SYMBOL_GRAPHS_DIR_IOS}"

# Generate *.symbols.json file for macOS.
mkdir -p "${SYMBOL_GRAPHS_DIR_MACOS}"
xcodebuild build \
  -scheme "${SCHEME}" \
  -destination "generic/platform=macOS" \
  -derivedDataPath "${DERIVED_DATA_DIR}" \
  OTHER_SWIFT_FLAGS="-emit-symbol-graph -emit-symbol-graph-dir ${SYMBOL_GRAPHS_DIR_MACOS}"

# Create a .doccarchive from the symbols.
$(xcrun --find docc) convert "${DOCC_BUNDLE_PATH}" \
  --index \
  --fallback-display-name "${SCHEME}" \
  --fallback-bundle-identifier "${SCHEME}" \
  --fallback-bundle-version 0 \
  --output-dir "${DOCCARCHIVE_PATH}" \
  --additional-symbol-graph-dir "${SYMBOL_GRAPHS_DIR}"

# Clean up.
rm -rf "${DERIVED_DATA_DIR}"
rm -rf "${BUILD_DIR}"