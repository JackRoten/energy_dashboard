#!/bin/bash

# Build script for Lambda Layer using standard Python image
set -e

# LAYER_DIR="layer"
BUILD_DIR="python"
ZIP_FILE="lambda_layer.zip"
PYTHON_VERSION="3.11"

echo "Starting Lambda layer build..."

# Clean previous builds
rm -rf $BUILD_DIR
rm -f $ZIP_FILE

# Create the python directory (required structure for Lambda layers)
mkdir -p $BUILD_DIR

echo "Building layer with Docker..."

# Use manylinux image which is compatible with Lambda
docker run --rm \
  -v "$PWD:/var/task" \
  -v "$PWD/$BUILD_DIR:/var/output" \
  -w /var/task \
  python:${PYTHON_VERSION}-slim \
  pip install -r requirements.txt -t /var/output --platform manylinux2014_x86_64 --only-binary=:all: --upgrade --no-cache-dir

# Verify the build
echo "Verifying layer contents..."
if [ -d "$BUILD_DIR/psycopg2" ]; then
    echo "✓ psycopg2 found in layer"
    ls -la $BUILD_DIR/psycopg2/*.so 2>/dev/null || echo "⚠ No .so files found"
else
    echo "✗ psycopg2 NOT found in layer!"
    exit 1
fi

# Create zip file with proper structure
echo "Creating zip archive..."
zip -r $ZIP_FILE $BUILD_DIR -x "*.pyc" "*__pycache__*" "*.dist-info/*"

# Verify zip structure
echo "Verifying zip structure..."
unzip -l $ZIP_FILE | grep psycopg2 | head -10

# Clean up
rm -rf $BUILD_DIR

echo "✓ Layer built successfully: $ZIP_FILE"
echo "Layer size: $(du -h $ZIP_FILE | cut -f1)"