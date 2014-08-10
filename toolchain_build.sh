#!/bin/bash

#Denpendencies (glib, pango)

if [ ! -f $MIRAI_SDK_PREFIX/lib/libpango.a ]; then
	pushd dependencies
	./build.sh
	popd
fi

if [ ! -f $MIRAI_SDK_PREFIX/lib/libCoreText.so ]; then
	xcodebuild -target CoreText-Android
fi

