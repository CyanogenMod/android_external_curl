#!/bin/sh

# Check if we need to build
if [ -f install/curl ]
then
	echo "Nothing to build in cURL. Delete install/curl to force a rebuild"
	exit 0
fi

# Build both PPC and i386 targets
rm -rf build install
mkdir -p build/ppc build/i386 install
cd build/ppc
../../configure --disable-ldap --with-ssl=`pwd`/../../../openssl --enable-static --disable-shared --target=powerpc-apple CFLAGS="-mmacosx-version-min=10.5 -arch ppc" CXXFLAGS="-mmacosx-version-min=10.5 -arch ppc" LDFLAGS="-mmacosx-version-min=10.5 -arch ppc" --prefix=`pwd`/../../install/ppc
make
make install
cd ../i386
../../configure --disable-ldap --with-ssl=`pwd`/../../../openssl --enable-static --disable-shared --target=i386-apple CFLAGS="-mmacosx-version-min=10.5 -arch i386" CXXFLAGS="-mmacosx-version-min=10.5 -arch i386" LDFLAGS="-mmacosx-version-min=10.5 -arch i386" --prefix=`pwd`/../../install/i386
make
make install
cd ../..

# Now merge i386 and PPC
lipo -create ./install/ppc/bin/curl ./install/i386/bin/curl -output ./install/curl
lipo -create ./install/ppc/lib/libcurl.a ./install/i386/lib/libcurl.a -output ./install/libtpncurl.a

# Headers are the same for i386 and ppc
ln -s i386/include install/include

# clean up
/opt/local/bin/git checkout -- include/curl/curlbuild.h

