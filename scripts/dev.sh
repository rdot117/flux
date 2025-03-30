#!/bin/sh

set -e

# make build directory
mkdir -p build

# update sourcemap
rojo sourcemap default.project.json --output sourcemap.json --watch

# run darklua process on changes
darklua process src build/src --watch &
darklua process packages build/packages --watch &

# sync to roblox
rojo serve build.project.json
