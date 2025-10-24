#!/usr/bin/env bash

swift build -c release
cp ./.build/release/HalleyMacroPlugin-tool macros/HalleyMacroPlugin