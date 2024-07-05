#!/usr/bin/env bash

swift build -c release
cp ./.build/release/HalleyMacroPlugin macros/HalleyMacroPlugin