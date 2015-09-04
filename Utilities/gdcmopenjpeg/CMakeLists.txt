# Main CMakeLists.txt to build the OpenJPEG project using CMake (www.cmake.org)
# Written by Mathieu Malaterre

# This CMake project will by default create a library called openjpeg
# But if you want to use this project within your own (CMake) project
# you will eventually like to prefix the library to avoid linking confusion
# For this purpose you can define a CMake var: OPENJPEG_NAMESPACE to whatever you like
# e.g.:
# set(OPENJPEG_NAMESPACE "GDCMOPENJPEG")

CMAKE_MINIMUM_REQUIRED(VERSION 3.0)

PROJECT(${OPENJPEG_NAMESPACE} VERSION 2.0.12 LANGUAGES C)
if(NOT OPENJPEG_NAMESPACE)
  set(OPENJPEG_NAMESPACE "OPENJPEG")
  set(OPENJPEG_STANDALONE 1)
  set(OPENJPEG_INSTALL_BIN_DIR bin)
  set(OPENJPEG_INSTALL_LIB_DIR lib)
  set(OPENJPEG_INSTALL_INCLUDE_DIR include/openjpeg-1.0)
  OPTION(OPENJPEG_BUILD_SHARED_LIBS "Build OpenJPEG with shared libraries." OFF)
  set(BUILD_SHARED_LIBS ${OPENJPEG_BUILD_SHARED_LIBS})
else()
  APPEND_COPYRIGHT(${CMAKE_CURRENT_SOURCE_DIR}/BSDlicense.txt)
endif()
# In all cases:
STRING(TOLOWER ${OPENJPEG_NAMESPACE} OPENJPEG_LIBRARY_NAME)

if(COMMAND cmake_policy)
  cmake_policy(SET CMP0003 NEW)
endif()


# Do full dependency headers.
INCLUDE_REGULAR_EXPRESSION("^.*$")

#-----------------------------------------------------------------------------
# OPENJPEG version number, usefull for packaging and doxygen doc:
set(OPENJPEG_MAJOR_VERSION 1)
set(OPENJPEG_MINOR_VERSION 0)
set(OPENJPEG_BUILD_VERSION 0)
set(OPENJPEG_VERSION
  "${OPENJPEG_MAJOR_VERSION}.${OPENJPEG_MINOR_VERSION}.${OPENJPEG_BUILD_VERSION}")

set(OPENJPEG_LIBRARY_PROPERTIES ${OPENJPEG_LIBRARY_PROPERTIES}
  VERSION "${OPENJPEG_VERSION}"
  SOVERSION "${OPENJPEG_MAJOR_VERSION}.${OPENJPEG_MINOR_VERSION}"
)

#-----------------------------------------------------------------------------
# OpenJPEG build configuration options.
#OPTION(BUILD_SHARED_LIBS "Build OpenJPEG with shared libraries." OFF)

#-----------------------------------------------------------------------------
# For the codec...
OPTION(OPJ_BUILD_EXAMPLES "Build the Examples (codec...)." OFF)
set(BUILD_EXAMPLES ${OPJ_BUILD_EXAMPLES})
MARK_AS_ADVANCED(OPJ_BUILD_EXAMPLES)


# configure name mangling to allow multiple libraries to coexist
# peacefully
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/openjpeg_mangle.h.in)
set(MANGLE_PREFIX ${OPENJPEG_LIBRARY_NAME})
CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/openjpeg_mangle.h.in
               ${CMAKE_CURRENT_BINARY_DIR}/openjpeg_mangle.h
               @ONLY IMMEDIATE)
endif()

if(NOT OPENJPEG_INSTALL_NO_DEVELOPMENT)
  INSTALL(FILES 
      ${CMAKE_CURRENT_BINARY_DIR}/openjpeg_mangle.h
    DESTINATION ${OPENJPEG_INSTALL_INCLUDE_DIR} COMPONENT Headers
  )
endif()

#-----------------------------------------------------------------------------
# Always build the library
INCLUDE_DIRECTORIES(BEFORE ${CMAKE_CURRENT_BINARY_DIR})
SUBDIRS(
  libopenjpeg
  )
#-----------------------------------------------------------------------------
# Build example only if requested
if(BUILD_EXAMPLES)
  add_subdirectory(codec)
endif()

#-----------------------------------------------------------------------------
# For openjpeg team if they ever want Dart+CMake
if(OPJ_STANDALONE)
  INCLUDE(Dart)
  MARK_AS_ADVANCED(BUILD_TESTING DART_ROOT TCL_TCLSH)
  if(BUILD_TESTING)
    ENABLE_TESTING()
    set(BUILDNAME "OpenJPEG-${CMAKE_SYSTEM}-${CMAKE_C_COMPILER}" CACHE STRING "Name of build on the dashboard")
    MARK_AS_ADVANCED(BUILDNAME)
  endif()
endif()

# TODO, technically we should add tests, e.g:
# http://www.crc.ricoh.com/~gormish/jpeg2000conformance/

