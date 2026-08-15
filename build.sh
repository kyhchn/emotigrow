#!/bin/bash

git clone https://github.com/flutter/flutter.git --depth 1 -b 3.35.6 "$HOME/flutter"

export PATH="$HOME/flutter/bin:$PATH"

flutter config --enable-web

flutter pub get

flutter build web --release