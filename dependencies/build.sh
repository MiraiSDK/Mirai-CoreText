#!/bin/sh

FLAGS="$ARCHFLAGS --sysroot $MIRAI_SDK_PATH"
PREFIX="$MIRAI_SDK_PATH/usr"


checkError()
{
    if [ "${1}" -ne "0" ]; then
        echo "*** Error: ${2}"
        exit ${1}
    fi
}

cleanUp()
{
	if [ "$MIRAI_CLEAN_UP" == "yes" ]; then
		#clean up
		rm -rf harfbuzz-0.9.25
		rm -f harfbuzz-0.9.25.tar.bz2
		
		#clean up
		rm -rf gettext-0.18.2
		rm -f gettext-0.18.2.tar.gz
		
		#clean up
		rm -rf glib-2.34.3
		rm -f glib-2.34.3.tar.xz
		
		#clean up
		rm -rf pango-1.36.1
		rm -f pango-1.36.1.tar.xz
	fi
}

buildHarfbuzz()
{
	if [ ! -d harfbuzz-0.9.25 ]; then
		if [ ! -f harfbuzz-0.9.25.tar.bz2 ]; then
			echo "Downloading harfbuzz-0.9.25.tar.bz2..."
			curl -L -O http://www.freedesktop.org/software/harfbuzz/release/harfbuzz-0.9.25.tar.bz2
			checkError $? "Download harfbuzz failed"
		fi
		
		tar -xvf harfbuzz-0.9.25.tar.bz2
		checkError $? "extract harfbuzz file failed"
		
		pushd harfbuzz-0.9.25
		#patch makefile.am, disable tests..
		patch -p0 -i ../harfbuzz_disable_test.patch
		autoreconf -ivf
		popd
	fi
	
	pushd harfbuzz-0.9.25
	
	CC=$CROSS_CLANG CXX=$CROSS_CLANGPP AR=$CROSS_AR CPPFLAGS="$FLAGS" CFLAGS="$FLAGS" \
	./configure --host=$HOSTEABI --prefix=$PREFIX --enable-static=yes
	checkError $? "configure harfbuzz failed"
	
	
	# crtbegin_so.o multiple used
	# patch libtool
	sed -i "" -E "s/(predep_objects *= *\").*/\1\"/" libtool
	sed -i "" -E "s/(postdep_objects *= *\").*/\1\"/" libtool
	
	make -j4
	
	checkError $? "Make harfbuzz failed"
	
	make install
	checkError $? "Install harfbuzz failed"
	
	make clean
	
	popd	
}

buildLibgettext()
{
	
	if [ ! -d gettext-0.18.2 ]; then
		if [ ! -f gettext-0.18.2.tar.gz ]; then
			echo "Downloading gettext-0.18.2.tar.gz..."
			curl http://ftp.gnu.org/pub/gnu/gettext/gettext-0.18.2.tar.gz -o gettext-0.18.2.tar.gz
			checkError $? "download libgettext failed"
		fi
		tar -xvf gettext-0.18.2.tar.gz
		pushd gettext-0.18.2/gettext-tools/src
			patch -i ../../../gettext_gecos.patch
		popd
	fi
	pushd  gettext-0.18.2
	
	gl_cv_header_working_stdint_h=yes CC=$CROSS_CLANG CXX=$CROSS_CLANGPP AR=$CROSS_AR CPPFLAGS="$FLAGS" CFLAGS="$FLAGS" \
	./configure --host=$HOSTEABI --prefix=$PREFIX --enable-static=yes --disable-java --disable-native-java
	checkError $? "configure libgettext failed"
	
	make -j4
	checkError $? "make libgettext failed"
	
	make install
	checkError $? "install libgettext failed"
	
	make clean
	
	popd
}

buildGlib()
{	
	if [ ! -f $PREFIX/lib/libgettextlib.so ]; then
		buildLibgettext
		checkError $? "Make libgettext failed"
	fi
		
	if [ ! -d glib-2.34.3 ]; then
		if [ ! -f glib-2.34.3.tar.xz ]; then
			echo "Downloading glib-2.34.3.tar.xz..."
			curl -L http://ftp.gnome.org/pub/gnome/sources/glib/2.34/glib-2.34.3.tar.xz -o glib-2.34.3.tar.xz
			checkError $? "download glib failed"
		fi
		tar -xvf glib-2.34.3.tar.xz
		checkError $? "extract glib failed"
		
		pushd glib-2.34.3
			patch -p1 -i ../glib-android.patch
			patch -p0 -i ../glib_lpthread.patch
			autoconf
		popd
	fi
	pushd glib-2.34.3

	cp ../glib_android.cache android.cache
	
	PATH=$PREFIX/bin:$PATH ./configure --host=$HOSTEABI --prefix="$PREFIX"  --with-sysroot="$MIRAI_SDK_PATH/usr" \
	CPPFLAGS="$FLAGS" CFLAGS="$FLAGS" --enable-static --cache-file=android.cache --disable-modular-tests
	checkError $? "configure glib failed"
	
	make -j4
	checkError $? "Make glib failed"
	
	make install
	
	make clean
	
	popd
}

buildPango()
{
	if [ ! -d pango-1.36.1 ]; then
		if [ ! -f pango-1.36.1.tar.xz ]; then
			echo "Downloading pango-1.36.1.tar.xz..."
			curl http://ftp.gnome.org/pub/GNOME/sources/pango/1.36/pango-1.36.1.tar.xz -o pango-1.36.1.tar.xz
			checkError $? "Download pango failed"
		fi
		
		tar -xvf pango-1.36.1.tar.xz
		
		pushd pango-1.36.1
			patch -p1 -i ../pango_language_locale.patch
		popd
		
	fi
	
	pushd pango-1.36.1
	## ld patch
	if [ ! -f ld.bak ]; then
		cp $STANDALONE_TOOLCHAIN_PATH/$HOSTEABI/bin/ld ld.bak
	fi
	
	cp ../pango_pthread_ld $STANDALONE_TOOLCHAIN_PATH/$HOSTEABI/bin/ld
	
	# without -mthumb, clang failed on compile pangofc-font.c
	CC=$CROSS_CLANG CXX=$CROSS_CLANGPP AR=$CROSS_AR \
	CPPFLAGS="-DANDROID=1 -mthumb $FLAGS" CFLAGS="-DANDROID=1 -mthumb $FLAGS" \
	./configure --host=$HOSTEABI --prefix="$PREFIX" --enable-static=yes --enable-shared=no --with-included-modules=yes --with-dynamic-modules=no
	checkError $? "configure pango failed"
	
	make -j4
	checkError $? "make pango failed"
	
	make install
	checkError $? "Install pango failed"
	
	#restore ld
	cp ld.bak $STANDALONE_TOOLCHAIN_PATH/$HOSTEABI/bin/ld
	
	make clean
	
	popd	
}

export PKG_CONFIG_LIBDIR=$MIRAI_SDK_PREFIX/lib/pkgconfig
export PKG_CONFIG_PATH=$PKG_CONFIG_LIBDIR

if [ ! -f $PREFIX/lib/libglib-2.0.a ]; then
	buildGlib
	checkError $? "build glib failed"
fi

if [ ! -f $PREFIX/lib/libharfbuzz.la ]; then
	buildHarfbuzz
	checkError $? "build harfbuzz failed"
fi

if [ ! -f $PREFIX/lib/libpango-1.0.a ]; then
	buildPango
	checkError $? "build pango failed"
fi

cleanUp

