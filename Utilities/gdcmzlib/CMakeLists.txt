CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

if(NOT ZLIB_NAMESPACE)
  set(ZLIB_NAMESPACE "ZLIB")
  set(ZLIB_STANDALONE 1)
endif()
# In all cases:
STRING(TOLOWER ${ZLIB_NAMESPACE} ZLIB_LIBRARY_NAME)

PROJECT(${ZLIB_NAMESPACE} C)

APPEND_COPYRIGHT(${CMAKE_CURRENT_SOURCE_DIR}/COPYING)

# Do full dependency headers.
INCLUDE_REGULAR_EXPRESSION("^.*$")

# source files for zlib
set(ZLIB_SRCS
  adler32.c
  compress.c
  crc32.c
  deflate.c
  #example.c
  gzio.c
  infback.c
  inffast.c
  inflate.c
  inftrees.c
  #minigzip.c
  trees.c
  uncompr.c
  zutil.c
  )


# for windows add the .def and .rc files to the source list if building shared libs
if(WIN32)
  if(BUILD_SHARED_LIBS)
    set(ZLIB_DLL 1)
    if(NOT UNIX)
      if(NOT BORLAND)
        if(NOT MINGW)
          set(ZLIB_SRCS ${ZLIB_SRCS} zlib.def zlib.rc  )
        endif()
      endif() 
    endif()   
  endif()
endif()

  CONFIGURE_FILE(
    ${CMAKE_CURRENT_SOURCE_DIR}/zconf.in.h
    ${CMAKE_CURRENT_BINARY_DIR}/zconf.h
  )
INCLUDE_DIRECTORIES(
 ${CMAKE_CURRENT_BINARY_DIR}
)


ADD_LIBRARY(${ZLIB_LIBRARY_NAME} ${ZLIB_SRCS})
SET_TARGET_PROPERTIES(${ZLIB_LIBRARY_NAME} PROPERTIES ${GDCM_LIBRARY_PROPERTIES})
set_target_properties(${ZLIB_LIBRARY_NAME} PROPERTIES LINKER_LANGUAGE C)

if(NOT ZLIB_INSTALL_NO_LIBRARIES)
  INSTALL(TARGETS ${ZLIB_LIBRARY_NAME} EXPORT gdcm-abi-config
    RUNTIME DESTINATION ${ZLIB_INSTALL_BIN_DIR} COMPONENT Applications
    LIBRARY DESTINATION ${ZLIB_INSTALL_LIB_DIR} COMPONENT Libraries
    ARCHIVE DESTINATION ${ZLIB_INSTALL_LIB_DIR} COMPONENT Development
  ${CPACK_NAMELINK_TYPE}
  )
endif()
