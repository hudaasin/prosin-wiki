#!/usr/bin/env bash

# Update package lists
apt-get update

# Extension:Diagrams
apt-get install graphviz mscgen plantuml

# Clean up
rm -rf /var/lib/apt/lists/*
