#!/usr/bin/env bash

# Update package lists
apt-get update

# Extension:Diagrams
apt-get install graphviz mscgen plantuml

# Extension:Widgets
git clone --depth=1 --branch REL1_42 https://gerrit.wikimedia.org/r/mediawiki/extensions/Widgets.git "$EXTENSION_DIR/Widgets"

# Clean up
rm -rf /var/lib/apt/lists/*
