#!/bin/bash

swift build -c release
sudo cp .build/release/Swiftiger /usr/local/bin/swiftiger
