#!/bin/bash

echo "Creating folder structure..."

# Create the main src directory
mkdir -p src
echo "Created src directory."

# Create the subdirectories under src
cd src
mkdir api assets components context enums hooks models pages schemas services test utils
echo "Created directories under src."

cd api
mkdir interceptors
echo "Created interceptors directory under api."
cd interceptors
mkdir request response
echo "Created request and response directories under interceptors."
cd ../..

cd assets
mkdir images styles
echo "Created images and styles directories under assets."
cd ..

cd components
mkdir common features main
echo "Created common, features, and main directories under components."
cd ..

cd models
mkdir share
echo "Created share directory under models."
cd share
mkdir api
echo "Created api directory under share."
cd ../..

echo "Folder structure created successfully!"