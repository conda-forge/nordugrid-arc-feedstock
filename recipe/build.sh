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
CXXFLAGS=$(echo "${CXXFLAGS}" | sed -E 's@-std=c\+\+[^ ]+@-std=c\+\+14@g')
export CXXFLAGS

./autogen.sh

declare -a CONFIGURE_FLAGS

if python --version | grep -c PyPy; then
     CONFIGURE_FLAGS+=("--with-altpython=${PYTHON}")
else
     CONFIGURE_FLAGS+=("--with-python=${PYTHON}")
fi

./configure \
     --prefix="${PREFIX}" \
     --disable-static \
     --enable-gfal \
     --enable-s3 \
     --disable-doc \
     --enable-internal \
     "${CONFIGURE_FLAGS[@]}"

make "-j${CPU_COUNT}"

# This is disabled as it takes a VERY long time
# make check

make "-j${CPU_COUNT}" install

make installcheck
