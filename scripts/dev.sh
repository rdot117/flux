#!/bin/sh

set -e

BUILD_DIR=build
DARKLUA_CONFIG=.darklua.json
SOURCEMAP=sourcemap.json
PACKAGES=packages

# cleanup existing dir
rm -f $SOURCEMAP
rm -rf $BUILD_DIR

# make build directory
mkdir -p $BUILD_DIR

# copy necessary files
cp build.project.json $BUILD_DIR/build.project.json

# update sourcemap
rojo sourcemap build.project.json -o $SOURCEMAP
rojo sourcemap --watch build.project.json -o $SOURCEMAP &

# run darklua process on changes
darklua process -w src $BUILD_DIR/src &
darklua process -w packages $BUILD_DIR/packages &

# sync to roblox
rojo serve $BUILD_DIR/build.project.json
