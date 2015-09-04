# Build the GDCM applications
# Namely:
# gdcmdump
# gdcminfo
# gdcmconv
# gdcmanon


if(WIN32 AND NOT CYGWIN)
  INCLUDE_DIRECTORIES(
    "${GDCM_SOURCE_DIR}/Utilities/getopt"
  )
endif()

# Add the include paths
INCLUDE_DIRECTORIES(
  "${GDCM_BINARY_DIR}/Source/Common"
  "${GDCM_SOURCE_DIR}/Source/Common"
  "${GDCM_SOURCE_DIR}/Source/DataStructureAndEncodingDefinition"
  "${GDCM_SOURCE_DIR}/Source/MediaStorageAndFileFormat"
  "${GDCM_SOURCE_DIR}/Source/InformationObjectDefinition"
# FIXME:
  "${GDCM_SOURCE_DIR}/Source/DataDictionary"
  "${GDCM_SOURCE_DIR}/Utilities"
  )

if(WIN32)
  if(BUILD_SHARED_LIBS)
    ADD_DEFINITIONS(-DGETOPT_DLL)
  endif()
endif()

set(GDCM_EXECUTABLE_NAME
  gdcmdump
  gdcmraw
  gdcmscanner
  gdcmanon
  gdcmgendir
  #gdcmoverlay
  gdcmimg
  #deflate
  gdcmconv
  gdcmtar
  gdcminfo
  )
if(GDCM_USE_SYSTEM_POPPLER)
  INCLUDE(CheckCXXSourceCompiles)
  set(CMAKE_REQUIRED_INCLUDES ${POPPLER_INCLUDE_DIRS})
  set(CMAKE_REQUIRED_LIBRARIES ${POPPLER_LIBRARIES})
  CHECK_CXX_SOURCE_COMPILES(
    "\#include <poppler/GlobalParams.h>\nint main() { globalParams = new GlobalParams(0); return 0;}"
    LIBPOPPLER_GLOBALPARAMS_CSTOR_HAS_PARAM)
  if(LIBPOPPLER_GLOBALPARAMS_CSTOR_HAS_PARAM)
    SET_SOURCE_FILES_PROPERTIES(
      ${CMAKE_CURRENT_SOURCE_DIR}/gdcmpdf.cxx
      PROPERTIES COMPILE_FLAGS -DLIBPOPPLER_GLOBALPARAMS_CSTOR_HAS_PARAM)
  endif()
  INCLUDE_DIRECTORIES(${POPPLER_INCLUDE_DIRS})
  set(GDCM_EXECUTABLE_NAME
  ${GDCM_EXECUTABLE_NAME}
  gdcmpdf
)
endif()

foreach(exename ${GDCM_EXECUTABLE_NAME})
  if(${exename} STREQUAL "gdcminfo")
    ADD_EXECUTABLE(${exename} ${exename}.cxx puff.c)
  else()
    ADD_EXECUTABLE(${exename} ${exename}.cxx)
  endif()
  TARGET_LINK_LIBRARIES(${exename} gdcmMSFF)
  if(${exename} STREQUAL "gdcmpdf")
    TARGET_LINK_LIBRARIES(${exename} ${POPPLER_LIBRARIES})
  endif()
  if(GDCM_EXECUTABLE_PROPERTIES)
  SET_TARGET_PROPERTIES(${exename} PROPERTIES ${GDCM_EXECUTABLE_PROPERTIES})
  endif()
  if(WIN32 AND NOT CYGWIN)
    TARGET_LINK_LIBRARIES(${exename} gdcmgetopt)
  endif()
  if(NOT GDCM_INSTALL_NO_RUNTIME)
    INSTALL(TARGETS ${exename}
      RUNTIME DESTINATION ${GDCM_INSTALL_BIN_DIR} COMPONENT Applications
      LIBRARY DESTINATION ${GDCM_INSTALL_LIB_DIR} COMPONENT Libraries
      ARCHIVE DESTINATION ${GDCM_INSTALL_LIB_DIR} COMPONENT Development
    )
  endif()
endforeach()

#if(GDCM_USE_PVRG)
#  ADD_EXECUTABLE(gdcmpvrg gdcmpvrg.cxx)
#  TARGET_LINK_LIBRARIES(gdcmpvrg pvrg)
#endif()

#ADD_EXECUTABLE(deflate deflate.cxx)
#TARGET_LINK_LIBRARIES(deflate gdcmzlib)

