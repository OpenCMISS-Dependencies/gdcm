# - Try to find the OpenSSL encryption library
# Once done this will define
#
#  OPENSSL_FOUND - system has the OpenSSL library
#  OPENSSL_INCLUDE_DIR - the OpenSSL include directory
#  OPENSSL_LIBRARIES - The libraries needed to use OpenSSL

# Copyright (c) 2006, Alexander Neundorf, <neundorf@kde.org>
# Copyright (c) 2009, Mathieu Malaterre, <mathieu.malaterre@gmail.com>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.


if(OPENSSL_LIBRARIES)
   set(OpenSSL_FIND_QUIETLY TRUE)
endif()

if(SSL_EAY_DEBUG AND SSL_EAY_RELEASE)
   set(LIB_FOUND 1)
endif()

# http://www.slproweb.com/products/Win32OpenSSL.html
FIND_PATH(OPENSSL_INCLUDE_DIR openssl/ssl.h 
  PATHS "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\OpenSSL (32-bit)_is1;Inno Setup: App Path]/include"
)

if(WIN32 AND MSVC)
   # /MD and /MDd are the standard values - if somone wants to use
   # others, the libnames have to change here too
   # use also ssl and ssleay32 in debug as fallback for openssl < 0.9.8b

   FIND_LIBRARY(LIB_EAY_DEBUG NAMES libeay32MDd libeay32
  PATHS "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\OpenSSL (32-bit)_is1;Inno Setup: App Path]/lib/VC"
)
    FIND_LIBRARY(LIB_EAY_RELEASE NAMES libeay32MD libeay32
  PATHS "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\OpenSSL (32-bit)_is1;Inno Setup: App Path]/lib/VC"
)
   # FIND_LIBRARY(SSL_EAY_DEBUG NAMES  ssleay32
   FIND_LIBRARY(SSL_EAY_DEBUG NAMES ssleay32MDd ssl ssleay32
  PATHS "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\OpenSSL (32-bit)_is1;Inno Setup: App Path]/lib/VC"
)
   #FIND_LIBRARY(SSL_EAY_RELEASE NAMES  ssleay32
   FIND_LIBRARY(SSL_EAY_RELEASE NAMES ssleay32MD ssl ssleay32
  PATHS "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\OpenSSL (32-bit)_is1;Inno Setup: App Path]/lib/VC"
)

   if(MSVC_IDE)
      if(SSL_EAY_DEBUG AND SSL_EAY_RELEASE)
         set(OPENSSL_LIBRARIES optimized ${SSL_EAY_RELEASE} ${LIB_EAY_RELEASE} debug ${SSL_EAY_DEBUG} ${LIB_EAY_DEBUG})
      else()
         set(OPENSSL_LIBRARIES NOTFOUND)
         MESSAGE(STATUS "Could not find the debug and release version of openssl")
      endif()
   else()
      STRING(TOLOWER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE_TOLOWER)
      if(CMAKE_BUILD_TYPE_TOLOWER MATCHES debug)
         set(OPENSSL_LIBRARIES ${SSL_EAY_DEBUG} ${LIB_EAY_DEBUG})
      else()
         set(OPENSSL_LIBRARIES ${SSL_EAY_RELEASE} ${LIB_EAY_RELEASE})
      endif()
   endif()
   MARK_AS_ADVANCED(SSL_EAY_DEBUG SSL_EAY_RELEASE)
   MARK_AS_ADVANCED(LIB_EAY_DEBUG LIB_EAY_RELEASE)
else()

   FIND_LIBRARY(OPENSSL_SSL_LIBRARIES NAMES ssl ssleay32 ssleay32MD)
   FIND_LIBRARY(OPENSSL_CRYPTO_LIBRARIES NAMES crypto)
   MARK_AS_ADVANCED(OPENSSL_CRYPTO_LIBRARIES OPENSSL_SSL_LIBRARIES)

   set(OPENSSL_LIBRARIES ${OPENSSL_SSL_LIBRARIES} ${OPENSSL_CRYPTO_LIBRARIES})

endif()

if(OPENSSL_INCLUDE_DIR AND OPENSSL_LIBRARIES)
   set(OPENSSL_FOUND TRUE)
else()
   set(OPENSSL_FOUND FALSE)
endif()

if(OPENSSL_FOUND)
   if(NOT OpenSSL_FIND_QUIETLY)
      MESSAGE(STATUS "Found OpenSSL: ${OPENSSL_LIBRARIES}")
   endif()
else()
   if(OpenSSL_FIND_REQUIRED)
      MESSAGE(FATAL_ERROR "Could NOT find OpenSSL")
   endif()
endif()

MARK_AS_ADVANCED(OPENSSL_INCLUDE_DIR OPENSSL_LIBRARIES)

