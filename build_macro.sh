#!/usr/bin/env bash

swift build --enable-experimental-prebuilts -c release
cp ./.build/release/HalleyMacroPlugin-tool macros/HalleyMacroPlugin