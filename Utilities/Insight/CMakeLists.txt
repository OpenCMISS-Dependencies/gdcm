PROJECT(itk_gdcm)
# We need ITK
FIND_PACKAGE(ITK REQUIRED)
MARK_AS_ADVANCED(ITK_DIR)

# Define the src for the itk-gdcm bridge
set(itkgdcm_SRCS
  itkGDCMImageIO2.cxx
  )

INCLUDE(${ITK_USE_FILE})
INCLUDE_DIRECTORIES(
  BEFORE
  ${GDCM_BINARY_DIR}/Source/Common
  ${GDCM_SOURCE_DIR}/Source/Common
  ${GDCM_SOURCE_DIR}/Source/DataStructureAndEncodingDefinition
  ${GDCM_SOURCE_DIR}/Source/MediaStorageAndFileFormat
  ${GDCM_SOURCE_DIR}/Source/DataDictionary
  )

ADD_LIBRARY(itkgdcm2 ${itkgdcm_SRCS})
SET_TARGET_PROPERTIES(itkgdcm2 PROPERTIES ${GDCM_LIBRARY_PROPERTIES})

TARGET_LINK_LIBRARIES(itkgdcm2 gdcmMSFF ITKIO)
if(NOT GDCM_INSTALL_NO_LIBRARIES)
  INSTALL(TARGETS itkgdcm2
    RUNTIME DESTINATION ${GDCM_INSTALL_BIN_DIR} COMPONENT Applications
    LIBRARY DESTINATION ${GDCM_INSTALL_LIB_DIR} COMPONENT Libraries
    ARCHIVE DESTINATION ${GDCM_INSTALL_LIB_DIR} COMPONENT Development
  )
endif()

if(BUILD_TESTING)
  add_subdirectory(Testing)
endif()

if(BUILD_APPLICATIONS)
  add_subdirectory(Applications)
endif()

