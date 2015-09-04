INCLUDE_REGULAR_EXPRESSION("^.*$")
# Defines the source code for the library
set(OPENJPEG_SRCS
  bio.c
  cio.c
  dwt.c
  event.c
  image.c
  j2k.c
  j2k_lib.c
  jp2.c
  jpt.c
  mct.c
  mqc.c
  openjpeg.c
  pi.c
  raw.c
  t1.c
  t2.c
  tcd.c
  tgt.c
)

# Pass proper definition to preprocessor to generate shared lib
if(WIN32)
  if(BUILD_SHARED_LIBS)
    ADD_DEFINITIONS(-DOPJ_EXPORTS)
  else()
    ADD_DEFINITIONS(-DOPJ_STATIC)
  endif()
endif()

if(${CMAKE_SYSTEM_NAME} STREQUAL "Linux" AND ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64" )
	SET_SOURCE_FILES_PROPERTIES(${OPENJPEG_SRCS}
		PROPERTIES COMPILE_FLAGS "-fPIC")
endif()

# Create the library
ADD_LIBRARY(${OPENJPEG_LIBRARY_NAME} ${OPENJPEG_SRCS})
SET_TARGET_PROPERTIES(${OPENJPEG_LIBRARY_NAME} PROPERTIES ${OPENJPEG_LIBRARY_PROPERTIES})

# Install library
if(NOT OPENJPEG_INSTALL_NO_LIBRARIES)
	INSTALL(TARGETS ${OPENJPEG_LIBRARY_NAME} EXPORT gdcm-abi-config
    RUNTIME DESTINATION ${OPENJPEG_INSTALL_BIN_DIR} COMPONENT Applications
    LIBRARY DESTINATION ${OPENJPEG_INSTALL_LIB_DIR} COMPONENT Libraries
    ARCHIVE DESTINATION ${OPENJPEG_INSTALL_LIB_DIR} COMPONENT Development
  ${CPACK_NAMELINK_TYPE}
  )
endif()

if(NOT OPENJPEG_INSTALL_NO_DEVELOPMENT)
  FILE(GLOB header_files "*.h")
  INSTALL(FILES ${header_files}
    DESTINATION ${OPENJPEG_INSTALL_INCLUDE_DIR} COMPONENT Headers
  )
endif()
