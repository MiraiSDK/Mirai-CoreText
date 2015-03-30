#!/bin/bash

#Denpendencies (glib, pango)
checkError()
{
    if [ "${1}" -ne "0" ]; then
        echo "*** Error: ${2}"
        exit ${1}
    fi
}

if [ ! -f $MIRAI_SDK_PREFIX/lib/libpango.a ]; then
	pushd dependencies
	./build.sh
	checkError $? "build CoreText dependencies failed"
	popd
fi

if [ ! -f $MIRAI_SDK_PREFIX/lib/libCoreText.so ]; then
	xcodebuild -target CoreText-Android -xcconfig xcconfig/Android-$ABI.xcconfig clean
	
	xcodebuild -target CoreText-Android -xcconfig xcconfig/Android-$ABI.xcconfig
	checkError $? "build CoreText failed"
	
fi

