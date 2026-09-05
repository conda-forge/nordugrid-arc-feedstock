#!/usr/bin/env bash

# Comping with C++17 doesn't work:
# In file included from SRMClient.h:18:0,
#                  from SRM1Client.h:6,
#                  from SRM1Client.cpp:6:
# SRMClientRequest.h:86:7: error: ISO C++1z does not allow dynamic exception specifications
#        throw (SRMInvalidRequestException)
#        ^~~~~
# In file included from SRMClient.h:18:0,
#                  from SRM22Client.h:6,
#                  from SRM22Client.cpp:6:
# SRMClientRequest.h:86:7: error: ISO C++1z does not allow dynamic exception specifications
#        throw (SRMInvalidRequestException)
#        ^~~~~
# SRMClientRequest.h:110:7: error: ISO C++1z does not allow dynamic exception specifications
#        throw (SRMInvalidRequestException)
#        ^~~~~
# SRMClientRequest.h:110:7: error: ISO C++1z does not allow dynamic exception specifications
#        throw (SRMInvalidRequestException)
#        ^~~~~
# In file included from SRMClient.h:18:0,
#                  from SRMClient.cpp:6:
# SRMClientRequest.h:86:7: error: ISO C++1z does not allow dynamic exception specifications
#        throw (SRMInvalidRequestException)
#        ^~~~~
# SRMClientRequest.h:110:7: error: ISO C++1z does not allow dynamic exception specifications
#        throw (SRMInvalidRequestException)
#        ^~~~~
# Check if changing the cxx standard is still required
grep -r 'throw (SRMInvalidRequestException)' .
CXXFLAGS=$(echo "${CXXFLAGS}" | sed -E 's@-std=c\+\+[^ ]+@-std=c\+\+14@g')
export CXXFLAGS

# Required for correct detection that Py_InitializeEx is not available for PyPy
export CFLAGS="${CFLAGS} -Werror-implicit-function-declaration"

./autogen.sh

declare -a CONFIGURE_FLAGS

if python --version | grep -c PyPy; then
    CONFIGURE_FLAGS+=("PYTHON_CFLAGS=-I$($PYTHON -c 'from distutils import sysconfig; print(sysconfig.get_python_inc())')")
    CONFIGURE_FLAGS+=(PYTHON_LIBS="-L${PREFIX}/lib -lpypy3-c")
fi

# configure autodetects the SYSV init script directory by probing the *build
# host's* /etc for init.d, rc.d/init.d, rc.d (first match wins), so the packaged
# layout depends on whichever container built it: alma9 has a real
# /etc/rc.d/init.d and gives etc/rc.d/init.d, while alma10 dropped the SysV
# initscripts and only /etc/rc.d survives, giving etc/rc.d. Pin it so the
# package is the same everywhere.
./configure \
     --prefix="${PREFIX}" \
     --disable-static \
     --enable-gfal \
     --enable-s3 \
     --with-xrootd="${PREFIX}" \
     --disable-doc \
     --enable-internal \
     --disable-ldns \
     --disable-arcrest-client \
     --with-python="${PYTHON}" \
     --with-sysv-scripts-location="${PREFIX}/etc/rc.d/init.d" \
     "${CONFIGURE_FLAGS[@]}"


make "-j${CPU_COUNT}"

# This is disabled as it takes a VERY long time
# make check

make install

make installcheck

# "make install"/"make installcheck" run python with -O/-OO, which writes
# byte-compiled copies of the imported stdlib modules into $PREFIX/lib/pythonX.Y.
# Drop these so the package does not ship files that belong to the python package.
find "${PREFIX}"/lib/python*/ -depth -type d -name __pycache__ -not -path '*/site-packages/*' -exec rm -rf {} + 2>/dev/null || true
