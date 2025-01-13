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

./configure \
     --prefix="${PREFIX}" \
     --disable-static \
     --enable-gfal \
     --enable-s3 \
     --with-xrootd="${PREFIX}" \
     --disable-doc \
     --enable-internal \
     --disable-ldns \
     --with-python="${PYTHON}" \
     "${CONFIGURE_FLAGS[@]}"


make "-j${CPU_COUNT}"

# This is disabled as it takes a VERY long time
# make check

make install

make installcheck
