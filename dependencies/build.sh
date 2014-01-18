#!/bin/sh

#ARMSYSROOT="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/FakeMacOSX10.9.sdk"
ARMSYSROOT="/Users/chyhfj/Development/MiraSDK/Products/android/android-toolchain-arm/sysroot"
FLAGS="--sysroot $ARMSYSROOT"
PREFIX="$ARMSYSROOT/usr"

checkError()
{
    if [ "${1}" -ne "0" ]; then
        echo "*** Error: ${2}"
        exit ${1}
    fi
}


buildHarfbuzz()
{
	if [ ! -d harfbuzz-0.9.25 ]; then
		if [ ! -f harfbuzz-0.9.25.tar.bz2 ]; then
			echo "Downloading harfbuzz-0.9.25.tar.bz2..."
			
		fi
		
		tar -xvf harfbuzz-0.9.25.tar.bz2
	fi
	
	pushd harfbuzz-0.9.25
	
	
	CC=arm-linux-androideabi-clang CXX=arm-linux-androideabi-clang++ AR=arm-linux-androideabi-ar CPPFLAGS="$FLAGS" CFLAGS="$FLAGS" ./configure --host=arm-linux-androideabi --prefix=$ARMSYSROOT/usr --enable-static
	checkError $? "configure harfbuzz failed"
	
	#patch makefile
	#patch libtool
	#make
	
	checkError $? "Make harfbuzz failed"
	
	popd
}

buildLibiconv()
{
	
	if [ ! -d libiconv-1.14 ]; then
		if [ ! -f libiconv-1.14.tar.gz ]; then
			echo "Downloading libiconv-1.14.tar.gz..."
			curl http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz -o libiconv-1.14.tar.gz
		fi
		tar -xvf libiconv-1.14.tar.gz
	fi
	pushd libiconv-1.14
	
	#patch config
	cp /tmp/config.sub build-aux/config.sub
	cp /tmp/config.sub libcharset/build-aux/config.sub
	cp /tmp/config.guess build-aux/config.guess
	cp /tmp/config.guess libcharset/build-aux/config.guess
	
	gl_cv_header_working_stdint_h=yes CC=arm-linux-androideabi-clang CXX=arm-linux-androideabi-clang++ AR=arm-linux-androideabi-ar CPPFLAGS="$FLAGS" CFLAGS="$FLAGS" ./configure --host=arm-linux-androideabi --prefix="$PREFIX" --enable-static	
	checkError $? "configure libiconv failed"
	
	make -j4
	make install
	
	popd

}

buildLibgettext()
{
	
	if [ ! -d gettext-0.18.2 ]; then
		if [ ! -f gettext-0.18.2.tar.gz ]; then
			echo "Downloading gettext-0.18.2.tar.gz..."
			curl http://ftp.gnu.org/pub/gnu/gettext/gettext-0.18.2.tar.gz -o gettext-0.18.2.tar.gz
		fi
		tar -xvf gettext-0.18.2.tar.gz
		pushd gettext-0.18.2/gettext-tools/src
			patch -i ../../../gettext_gecos.patch
		popd
	fi
	pushd  gettext-0.18.2
		
	gl_cv_header_working_stdint_h=yes CC=arm-linux-androideabi-clang CXX=arm-linux-androideabi-clang++ AR=arm-linux-androideabi-ar CPPFLAGS="$FLAGS" CFLAGS="$FLAGS" ./configure --host=arm-linux-androideabi --prefix=$PREFIX --enable-static --disable-java --disable-native-java
	checkError $? "configure libgettext failed"
	
	make -j4
	make install
	
	popd

}

buildGlib()
{
	# need iconv
	if [ ! -f $PREFIX/lib/libiconv.a ]; then
		buildLibiconv
		checkError $? "Make libiconv failed"
	fi
	
	if [ ! -f $PREFIX/lib/libgettextlib.so ]; then
		buildLibgettext
		checkError $? "Make libgettext failed"
	fi
	
	if [ ! -d glib-2.39.2 ]; then
		if [ ! -f glib-2.39.2.tar.xz ]; then
			echo "Downloading glib-2.39.2.tar.xz..."
			curl http://ftp.gnome.org/pub/GNOME/sources/glib/2.39/glib-2.39.2.tar.xz -o glib-2.39.2.tar.xz
		fi
		tar -xvf glib-2.39.2.tar.xz
	fi
	
	if [ ! -d glib-2.34.3 ]; then
		if [ ! -f glib-2.34.3.tar.xz ]; then
			echo "Downloading glib-2.34.3.tar.xz..."
			curl http://ftp.gnome.org/pub/gnome/sources/glib/2.34/glib-2.34.3.tar.xz -o glib-2.34.3.tar.xz
		fi
		tar -xvf glib-2.34.3.tar.xz
		
		pushd glib-2.34.3
			patch -p1 -i ../glib-android.patch
		popd
	fi
	
	#pushd glib-2.39.2
	pushd glib-2.34.3

	cp ../glib_android.cache android.cache
	
	PATH=$PREFIX/bin:$PATH ./configure --host=arm-linux-androideabi --prefix="$PREFIX"  --with-sysroot="$ARMSYSROOT/usr"  CPPFLAGS="$FLAGS" CFLAGS="$FLAGS" --enable-static --cache-file=android.cache --disable-modular-tests
	
	# needs patch dependency_libs in $ARMSYSROOT/usr/lib/libintl.la
	# needs patch: G_THREAD_LIBS_FOR_GTHREAD = -lpthread
	make
	popd

}

buildPango()
{
	if [ ! -d pango-1.36.1 ]; then
		if [ ! -f pango-1.36.1.tar.xz ]; then
			echo "Downloading pango-1.36.1.tar.xz..."
			curl http://ftp.gnome.org/pub/GNOME/sources/pango/1.36/pango-1.36.1.tar.xz -o pango-1.36.1.tar.xz
		fi
		
		tar -xvf pango-1.36.1.tar.xz
		
		pushd pango-1.36.1
			patch -p1 -i ../pango_language_locale.patch
		popd
		
	fi
	
	pushd pango-1.36.1
	
	CC=arm-linux-androideabi-clang CXX=arm-linux-androideabi-clang++ AR=arm-linux-androideabi-ar CPPFLAGS="-DANDROID=1 -g $FLAGS" CFLAGS="-DANDROID=1 -g $FLAGS" ./configure --host=arm-linux-androideabi --prefix="$PREFIX" --enable-static --with-included-modules=yes --with-dynamic-modules=no
	checkError $? "configure pango failed"
	
	#patch compile pangofc-font.o
	
	
	popd
}

export PKG_CONFIG_LIBDIR=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/FakeMacOSX10.9.sdk/usr/lib/pkgconfig
export PKG_CONFIG_PATH=$PKG_CONFIG_LIBDIR

if [ ! -f $ARMSYSROOT/usr/lib/libharfbuzz.la ]; then
	buildHarfbuzz
fi

if [ ! -f /tmp/config.sub ]; then
	curl -o /tmp/config.sub "git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD"
	curl -o /tmp/config.guess "git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD"
fi

#buildGlib
#buildHarfbuzz
buildPango
