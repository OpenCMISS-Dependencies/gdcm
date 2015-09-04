if(NOT CHARLS_NAMESPACE)
  set(CHARLS_NAMESPACE "CHARLS")
  set(CHARLS_STANDALONE 1)
endif()
# In all cases:
STRING(TOLOWER ${CHARLS_NAMESPACE} CHARLS_LIBRARY_NAME)

PROJECT(${CHARLS_NAMESPACE} CXX)
CMAKE_MINIMUM_REQUIRED(VERSION 2.6)


if(APPEND_COPYRIGHT)
APPEND_COPYRIGHT(${CMAKE_CURRENT_SOURCE_DIR}/License.txt)
endif()

#-----------------------------------------------------------------------------
# CHARLS version number
set(CHARLS_MAJOR_VERSION 1)
set(CHARLS_MINOR_VERSION 0)
set(CHARLS_BUILD_VERSION 0)
set(CHARLS_VERSION 
      "${CHARLS_MAJOR_VERSION}.${CHARLS_MINOR_VERSION}.${CHARLS_BUILD_VERSION}")

#-----------------------------------------------------------------------------
SET (EXECUTABLE_OUTPUT_PATH ${CHARLS_BINARY_DIR}/bin CACHE PATH "Single output directory for building all executables.")
SET (LIBRARY_OUTPUT_PATH ${CHARLS_BINARY_DIR}/bin CACHE PATH "Single output directory for building all libraries.")
MARK_AS_ADVANCED(LIBRARY_OUTPUT_PATH EXECUTABLE_OUTPUT_PATH)

if(NOT CHARLS_INSTALL_BIN_DIR)
  set(CHARLS_INSTALL_BIN_DIR "bin")
endif()
if(NOT CHARLS_INSTALL_LIB_DIR)
  set(CHARLS_INSTALL_LIB_DIR "lib")
endif()

#set(MANGLE_PREFIX ${JPEGLS_LIBRARY_NAME})
#CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/jpegls_mangle.h.in
#               ${CMAKE_CURRENT_BINARY_DIR}/jpegls_mangle.h
#               @ONLY IMMEDIATE)



# When user specify build type do not override settings:
if(NOT CMAKE_BUILD_TYPE)
  # The following compiler option are only meant for GCC:
  if(CMAKE_COMPILER_IS_GNUCC)
    set(CMAKE_CXX_FLAGS "-Wall -O3 -g" )
  endif()
endif()

#OPTION(charls_BUILD_SHARED_LIBS "Build CharLS with shared libraries." OFF)
#set(BUILD_SHARED_LIBS ${charls_BUILD_SHARED_LIBS})

add_library(${CHARLS_LIBRARY_NAME} header.cpp  interface.cpp  jpegls.cpp  
  stdafx.cpp
  )

# Install library
if(NOT CHARLS_INSTALL_NO_LIBRARIES)
  INSTALL(TARGETS ${CHARLS_LIBRARY_NAME}
    RUNTIME DESTINATION ${CHARLS_INSTALL_BIN_DIR} COMPONENT Applications
    LIBRARY DESTINATION ${CHARLS_INSTALL_LIB_DIR} COMPONENT Libraries
    ARCHIVE DESTINATION ${CHARLS_INSTALL_LIB_DIR} COMPONENT Development
  ${CPACK_NAMELINK_TYPE}
  )
endif()

if(NOT CHARLS_INSTALL_NO_DEVELOPMENT)
  FILE(GLOB header_files "*.h")
  INSTALL(FILES ${header_files}
    DESTINATION ${CHARLS_INSTALL_INCLUDE_DIR} COMPONENT Headers
  )
endif()
#add_executable(charlstest test/test.cpp test/time.cpp)
#target_link_libraries (charlstest CharLS)

#include(CTest)
#add_test(charlstest charlstest)
