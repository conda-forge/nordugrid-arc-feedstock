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

./autogen.sh

declare -a CONFIGURE_FLAGS

if python --version | grep -c PyPy; then
    CONFIGURE_FLAGS+=("PYTHON_CFLAGS=-I$($PYTHON -c 'from distutils import sysconfig; print(sysconfig.get_python_inc())')")
    PY_LIBS=$($PYTHON -c "from distutils import sysconfig; print(sysconfig.get_config_vars().get('LIBS'))" | sed s/None//)
    PY_SYSLIBS=$($PYTHON -c "from distutils import sysconfig; print(sysconfig.get_config_vars().get('SYSLIBS'))" | sed s/None//)
    CONFIGURE_FLAGS+=(PYTHON_LIBS="$PY_LIBS $PY_SYSLIBS")
fi

./configure \
     --prefix="${PREFIX}" \
     --disable-static \
     --enable-gfal \
     --enable-s3 \
     --disable-doc \
     --enable-internal \
     --disable-ldns \
     --with-python="${PYTHON}" \
     "${CONFIGURE_FLAGS[@]}"

make "-j${CPU_COUNT}"

# This is disabled as it takes a VERY long time
# make check

make "-j${CPU_COUNT}" install

make installcheck
