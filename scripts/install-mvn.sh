#!/usr/bin/env bash
set -e

# Detect package manager and install Maven
if command -v apt-get &> /dev/null; then
  echo "Using apt-get to install Maven..."
  sudo apt-get update
  sudo apt-get install -y maven
elif command -v yum &> /dev/null; then
  echo "Using yum to install Maven..."
  sudo yum install -y maven
elif command -v brew &> /dev/null; then
  echo "Using Homebrew to install Maven..."
  brew update
  brew install maven
else
  echo "Error: Could not detect package manager. Please install Maven manually."
  exit 1
fi

# Verify installation
echo ""
echo "===== Maven Installation Complete ====="
mvn --version
