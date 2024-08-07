#!/bin/bash

echo "Creating express backend folder structure..."

# Check if the path parameter is provided
if [ $# -eq 0 ]; then
  echo "Please provide the path where you want to create the backend Express project structure."
  exit 1
fi

# Get the path from the first parameter
path=$1

# Create the src directory and subdirectories
echo "Creating src directory and subdirectories..."
mkdir -p "$path/src/configs" # Configuration files for the application
mkdir -p "$path/src/controllers" # Business logic for handling requests
mkdir -p "$path/src/middlewares" # Middleware functions for request/response processing
mkdir -p "$path/src/models" # Data models and schema definitions
mkdir -p "$path/src/repositories" # Data access and storage logic
mkdir -p "$path/src/routes" # API routes and endpoint definitions
mkdir -p "$path/src/schemas" # Schema definitions for data validation
mkdir -p "$path/src/services" # Business logic and utility functions
mkdir -p "$path/src/tests" # Unit tests and integration tests
mkdir -p "$path/src/utils" # Utility functions and helpers

# Create files in the root directory
echo "Creating files in the root directory..."
touch "$path/.env" # Environment variables and secrets
touch "$path/.gitignore" # Files and directories to ignore in version control

# Create the server.ts file in the src directory
echo "Creating server.ts file..."
touch "$path/src/server.ts" # Entry point for the Express server

# Add basic comments to the files
echo "Adding basic comments to files..."
echo "# Environment variables" >> "$path/.env"
echo "# Ignore node_modules and other files" >> "$path/.gitignore"
echo "import express from 'express';" >> "$path/src/server.ts"
echo "const app = express();" >> "$path/src/server.ts"
echo "app.listen(3000, () => {" >> "$path/src/server.ts"
echo "  console.log('Server listening on port 3000');" >> "$path/src/server.ts"
echo "});" >> "$path/src/server.ts"

echo "Done! Backend Express project structure created at $path."