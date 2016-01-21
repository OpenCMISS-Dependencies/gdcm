#-----------------------------------------------------------------------------
# Rebuild gdcm whenever a file starting with gdcm* is modified
INCLUDE_REGULAR_EXPRESSION("^gdcm.*$")

# configure the .h file
OPTION(GDCM_SUPPORT_BROKEN_IMPLEMENTATION "Handle broken DICOM" ON)
OPTION(GDCM_WRITE_ODD_LENGTH "Do not change" OFF)
MARK_AS_ADVANCED(
  GDCM_SUPPORT_BROKEN_IMPLEMENTATION
  GDCM_WRITE_ODD_LENGTH
  )

#if(WIN32)
#  if(BUILD_SHARED_LIBS)
#    ADD_DEFINITIONS(-DPOLARSSL_DLL)
#  endif()
#endif()


CHECK_INCLUDE_FILE_CONCAT("sys/time.h"     HAVE_SYS_TIME_H)
CHECK_INCLUDE_FILE_CONCAT("winsock.h"       HAVE_WINSOCK_H)
CHECK_INCLUDE_FILE_CONCAT("byteswap.h"       HAVE_BYTESWAP_H)
CHECK_INCLUDE_FILE("rpc.h"       HAVE_RPC_H)

INCLUDE(CheckFunctionExists)
# See http://public.kitware.com/Bug/view.php?id=8246
INCLUDE(CheckSymbolExists)
#C99
#CHECK_FUNCTION_EXISTS(strcasecmp  HAVE_STRCASECMP)
CHECK_SYMBOL_EXISTS(strcasecmp "strings.h" HAVE_STRCASECMP)
#CHECK_FUNCTION_EXISTS(strncasecmp HAVE_STRNCASECMP)
CHECK_SYMBOL_EXISTS(strncasecmp "strings.h" HAVE_STRNCASECMP)
#CHECK_FUNCTION_EXISTS(snprintf    HAVE_SNPRINTF)
CHECK_SYMBOL_EXISTS(snprintf "stdio.h"    HAVE_SNPRINTF)
#M$ extension:
CHECK_FUNCTION_EXISTS(_stricmp    HAVE__STRICMP)
CHECK_FUNCTION_EXISTS(_strnicmp   HAVE__STRNICMP)
CHECK_FUNCTION_EXISTS(_snprintf   HAVE__SNPRINTF)

#INCLUDE(CheckSymbolExists)
CHECK_FUNCTION_EXISTS(gettimeofday HAVE_GETTIMEOFDAY)

CONFIGURE_FILE(
  "${GDCM_SOURCE_DIR}/Source/Common/gdcmConfigure.h.in"
  "${GDCM_BINARY_DIR}/Source/Common/gdcmConfigure.h"
  )

# Add the include paths
INCLUDE_DIRECTORIES(
  "${GDCM_BINARY_DIR}/Source/Common"
  "${GDCM_SOURCE_DIR}/Source/Common"
  "${GDCM_SOURCE_DIR}/Source/DataStructureAndEncodingDefinition"

  "${GDCM_BINARY_DIR}/Testing/Source/Data"
  "${GDCM_SOURCE_DIR}/Testing/Source/Data"

  "${GDCM_SOURCE_DIR}/Utilities"
  )

if(GDCM_BUILD_TESTING)
INCLUDE_DIRECTORIES(
  "${GDCM_BINARY_DIR}/Utilities/gdcmmd5"
)
endif()

if(NOT GDCM_USE_SYSTEM_ZLIB)
INCLUDE_DIRECTORIES(
  "${GDCM_BINARY_DIR}/Utilities/gdcmzlib"
)
endif()
#if(NOT GDCM_USE_SYSTEM_POLARSSL)
#INCLUDE_DIRECTORIES(
#  "${GDCM_SOURCE_DIR}/Utilities/gdcmpolarssl/include"
#)
#endif()

set(Common_SRCS
  gdcmVersion.cxx
  gdcmEvent.cxx
  gdcmCommand.cxx
  gdcmMD5.cxx
  gdcmBase64.cxx
  gdcmSHA1.cxx
  gdcmDummyValueGenerator.cxx
  gdcmCryptographicMessageSyntax.cxx
  gdcmASN1.cxx
  gdcmObject.cxx
  gdcmSubject.cxx
  gdcmDirectory.cxx
  gdcmTerminal.cxx
  gdcmString.cxx
  gdcmFilename.cxx
  gdcmFilenameGenerator.cxx
  gdcmSwapCode.cxx
  gdcmSystem.cxx
  gdcmTrace.cxx
  gdcmException.cxx
  gdcmDeflateStream.cxx
  gdcmByteSwap.cxx
  gdcmUnpacker12Bits.cxx
  )

if(GDCM_BUILD_TESTING)
set(Common_SRCS ${Common_SRCS}
  gdcmTesting.cxx
)
endif()

if(${CMAKE_SYSTEM_NAME} STREQUAL "Linux" AND ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64" )
	SET_SOURCE_FILES_PROPERTIES(${Common_SRCS}
		PROPERTIES COMPILE_FLAGS "-fPIC")
endif()

ADD_LIBRARY(gdcmCommon ${Common_SRCS})
SET_TARGET_PROPERTIES(gdcmCommon PROPERTIES ${GDCM_LIBRARY_PROPERTIES})

TARGET_LINK_LIBRARIES(gdcmCommon PUBLIC ${GDCM_ZLIB_LIBRARIES}) # ${GDCM_POLARSSL_LIBRARIES})
if(GDCM_BUILD_TESTING)
    TARGET_LINK_LIBRARIES(gdcmCommon PRIVATE gdcmmd5 )
endif()
if(APPLE)
  target_link_libraries(gdcmCommon PUBLIC ${COREFOUNDATION_LIBRARY})
endif()
if(UNIX)
  TARGET_LINK_LIBRARIES(gdcmCommon PUBLIC ${CMAKE_DL_LIBS})
endif()

if(WIN32)
  TARGET_LINK_LIBRARIES(gdcmCommon PUBLIC ws2_32)
endif()

if(GDCM_USE_SYSTEM_OPENSSL)
  INCLUDE_DIRECTORIES(${OPENSSL_INCLUDE_DIR})
  TARGET_LINK_LIBRARIES(gdcmCommon PUBLIC ${OPENSSL_LIBRARIES})
endif()


if(NOT GDCM_INSTALL_NO_LIBRARIES)
  # Runtime
  INSTALL(TARGETS gdcmCommon EXPORT gdcm-abi-config
    RUNTIME DESTINATION ${GDCM_INSTALL_BIN_DIR} COMPONENT Applications
    LIBRARY DESTINATION ${GDCM_INSTALL_LIB_DIR} COMPONENT Libraries ${NAMELINK_SKIP}
    ARCHIVE DESTINATION ${GDCM_INSTALL_LIB_DIR} COMPONENT Development
    INCLUDES DIRECTORY ${GDCM_INSTALL_INCLUDE_DIR}
  )
  #Development
  #INSTALL(TARGETS gdcmCommon
  #  LIBRARY DESTINATION ${GDCM_INSTALL_LIB_DIR} COMPONENT Development ${NAMELINK_ONLY}
  #)
endif()

if(NOT GDCM_INSTALL_NO_DEVELOPMENT)
  FILE(GLOB header_files "*.h" "*.txx")
  INSTALL(FILES ${header_files}
    "${GDCM_BINARY_DIR}/Source/Common/gdcmConfigure.h"
    DESTINATION ${GDCM_INSTALL_INCLUDE_DIR} COMPONENT Headers
  )
endif()
