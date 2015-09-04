# Define the srcs for the Information Object Definition
# IOD
set(IOD_SRCS
  gdcmModule.cxx
  gdcmModules.cxx
  gdcmNestedModuleEntries.cxx
  gdcmIODEntry.cxx
  gdcmTableReader.cxx
  gdcmTable.cxx
  gdcmSeries.cxx
  gdcmDefs.cxx
  gdcmDefinedTerms.cxx
  gdcmEnumeratedValues.cxx
  gdcmStudy.cxx
  gdcmPatient.cxx
  gdcmType.cxx
  gdcmUsage.cxx
  gdcmIOD.cxx
  #gdcmXMLDictReader.cxx
  #gdcmXMLPrivateDictReader.cxx
  )

# expat stuff
if(NOT BUILD_SHARED_LIBS)
  SET_SOURCE_FILES_PROPERTIES(gdcmTableReader.cxx
                              PROPERTIES 
                              COMPILE_FLAGS -DXML_STATIC
                              )
endif()

if(${CMAKE_SYSTEM_NAME} STREQUAL "Linux" AND ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64" )
	SET_SOURCE_FILES_PROPERTIES(${IOD_SRCS}
		PROPERTIES COMPILE_FLAGS "-fPIC")
endif()

# Add the include paths
INCLUDE_DIRECTORIES(
  "${GDCM_SOURCE_DIR}/Source/Common"
  "${GDCM_BINARY_DIR}/Source/Common"
  "${GDCM_SOURCE_DIR}/Source/DataStructureAndEncodingDefinition"
  "${GDCM_SOURCE_DIR}/Source/DataDictionary"
  "${GDCM_SOURCE_DIR}/Utilities"
  )

ADD_LIBRARY(gdcmIOD ${IOD_SRCS})
SET_TARGET_PROPERTIES(gdcmIOD PROPERTIES ${GDCM_LIBRARY_PROPERTIES})
TARGET_LINK_LIBRARIES(gdcmIOD gdcmDSED gdcmCommon ${GDCM_EXPAT_LIBRARIES})
if(NOT GDCM_INSTALL_NO_LIBRARIES)
  # Runtime
  INSTALL(TARGETS gdcmIOD EXPORT gdcm-abi-config
    RUNTIME DESTINATION ${GDCM_INSTALL_BIN_DIR} COMPONENT Applications
    LIBRARY DESTINATION ${GDCM_INSTALL_LIB_DIR} COMPONENT Libraries ${NAMELINK_SKIP}
    ARCHIVE DESTINATION ${GDCM_INSTALL_LIB_DIR} COMPONENT Development
  )
  #Development
  #INSTALL(TARGETS gdcmIOD
  #  LIBRARY DESTINATION ${GDCM_INSTALL_LIB_DIR} COMPONENT Development ${NAMELINK_ONLY}
  #  )
endif()

if(NOT GDCM_INSTALL_NO_DEVELOPMENT)
  FILE(GLOB header_files "*.h" "*.txx")
  INSTALL(FILES ${header_files}
    DESTINATION ${GDCM_INSTALL_INCLUDE_DIR} COMPONENT Headers
  )
endif()

#-----------------------------------------------------------------------------
# Install Part3.xml
INSTALL(FILES ${CMAKE_CURRENT_SOURCE_DIR}/Part3.xml
  DESTINATION ${GDCM_INSTALL_DATA_DIR}/XML COMPONENT Libraries
)

#-----------------------------------------------------------------------------
FILE(GLOB GDCM_XML_TABLES_GLOB
  "${CMAKE_CURRENT_SOURCE_DIR}/*.xml"
  )

set(GDCM_XML_TABLES)
foreach(filename ${GDCM_XML_TABLES_GLOB})
  set(GDCM_XML_TABLES "${GDCM_XML_TABLES}\n\"${filename}\",")
endforeach()

# Populate GDCM_DATA_IMAGES:
CONFIGURE_FILE(
  "${CMAKE_CURRENT_SOURCE_DIR}/gdcmTables.h.in"
  "${CMAKE_CURRENT_BINARY_DIR}/gdcmTables.h"
  )

