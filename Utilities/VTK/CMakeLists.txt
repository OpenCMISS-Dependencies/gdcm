PROJECT(vtkgdcm)
# We need VTK
# Technically we require VTK 5.0 and above
FIND_PACKAGE(VTK REQUIRED)
MARK_AS_ADVANCED(VTK_DIR)

# Define the src for the vtk-gdcm bridge
set(vtkgdcm_SRCS
  vtkGDCMTesting.cxx
  vtkGDCMImageReader.cxx
  vtkGDCMImageWriter.cxx
  vtkGDCMMedicalImageProperties.cxx
  )

if(CMAKE_HAVE_PTHREAD_H)
  set(vtkgdcm_SRCS ${vtkgdcm_SRCS}
  vtkGDCMThreadedImageReader.cxx
  )
endif()

INCLUDE(${VTK_USE_FILE})
INCLUDE_DIRECTORIES(
  ${GDCM_BINARY_DIR}/Source/Common
  ${GDCM_SOURCE_DIR}/Source/Common
  ${GDCM_SOURCE_DIR}/Source/DataStructureAndEncodingDefinition
  ${GDCM_SOURCE_DIR}/Source/MediaStorageAndFileFormat
  ${GDCM_SOURCE_DIR}/Source/DataDictionary
  ${GDCM_SOURCE_DIR}/Utilities/VTK
  )

# FIXME: temp fix
#if(UNIX)
#  LINK_DIRECTORIES(/usr/X11R6/lib)
#endif()

# List the kits from VTK that are needed by this project.
set(vtkgdcm_LIBS
  vtkCommon
  vtkIO
  vtkImaging
  vtkRendering
)

# Use wrapping hints for this project.
#set(VTK_WRAP_HINTS "${PROJECT_SOURCE_DIR}/hints")

set(VTKGDCM_NAME vtkgdcm CACHE STRING "vtk-gdcm lib name")
MARK_AS_ADVANCED(VTKGDCM_NAME)

# Create the instantiator for these classes.
# FIXME: Are instantiator really needed when only doing python wrapping ?
if( "${VTK_MAJOR_VERSION}.${VTK_MINOR_VERSION}" LESS 4.5 )
  set(vtkgdcm_SRCS ${vtkgdcm_SRCS}
    ${CMAKE_CURRENT_SOURCE_DIR}/VTK4/vtkMedicalImageProperties.cxx
    ${CMAKE_CURRENT_SOURCE_DIR}/VTK4/vtkStringArray.cxx
  )
  # Setup vtkInstantiator registration for this library's classes.
  INCLUDE_DIRECTORIES(
    ${GDCM_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/VTK4
  )
  VTK_MAKE_INSTANTIATOR2(
    "${VTKGDCM_NAME}Instantiator"
    vtkgdcmInstantiator_SRCS
    "${vtkgdcm_SRCS}"
    EXPORT_MACRO "" #GDCM_EXPORT
    HEADER_LOCATION ${GDCM_BINARY_DIR}
  )
else()
  set(vtkgdcm_SRCS ${vtkgdcm_SRCS}
    ${CMAKE_CURRENT_SOURCE_DIR}/vtkImageColorViewer.cxx
    ${CMAKE_CURRENT_SOURCE_DIR}/vtkImageMapToWindowLevelColors2.cxx
    ${CMAKE_CURRENT_SOURCE_DIR}/vtkImageYBRToRGB.cxx
    ${CMAKE_CURRENT_SOURCE_DIR}/vtkImageRGBToYBR.cxx
    ${CMAKE_CURRENT_SOURCE_DIR}/vtkGDCMPolyDataReader.cxx
    ${CMAKE_CURRENT_SOURCE_DIR}/vtkLookupTable16.cxx
    ${CMAKE_CURRENT_SOURCE_DIR}/vtkImageMapToColors16.cxx
    #${CMAKE_CURRENT_SOURCE_DIR}/vtkImagePlanarComponentsToComponents.cxx
  )
  #if(CMAKE_HAVE_PTHREAD_H)
    set(vtkgdcm_SRCS ${vtkgdcm_SRCS}
    vtkGDCMThreadedImageReader2.cxx
    )
  #endif()

  set(VTK_USE_INSTANTIATOR_NEW 1)
  VTK_MAKE_INSTANTIATOR3(
    "${VTKGDCM_NAME}Instantiator"
    vtkgdcmInstantiator_SRCS
    "${vtkgdcm_SRCS}"
    "" #"VTK_${VTKGDCM_NAME}_EXPORT"
    ${PROJECT_BINARY_DIR}
    "" #"${VTKGDCM_NAME}Configure.h"
  )
endif()

#Hum... not sure why this is needed.
#if(NOT VTK_BUILD_SHARED_LIBS AND GDCM_BUILD_SHARED_LIBS)
#  ADD_LIBRARY(vtkgdcm STATIC ${vtkgdcm_SRCS} ${vtkgdcmInstantiator_SRCS})
#else()
  ADD_LIBRARY(${VTKGDCM_NAME} ${vtkgdcm_SRCS} ${vtkgdcmInstantiator_SRCS})
#endif()

SET_TARGET_PROPERTIES(${VTKGDCM_NAME} PROPERTIES ${GDCM_LIBRARY_PROPERTIES})
TARGET_LINK_LIBRARIES(${VTKGDCM_NAME} gdcmMSFF ${vtkgdcm_LIBS})
# this need to be set on the vtkIO lib directly
#  SET_PROPERTY(TARGET ${VTKGDCM_NAME} PROPERTY LINK_INTERFACE_LIBRARIES "")
if(NOT GDCM_INSTALL_NO_LIBRARIES)
  INSTALL(TARGETS ${VTKGDCM_NAME}
    RUNTIME DESTINATION ${GDCM_INSTALL_BIN_DIR} COMPONENT VTKLibraries
    LIBRARY DESTINATION ${GDCM_INSTALL_LIB_DIR} COMPONENT VTKLibraries ${NAMELINK_SKIP}
    ARCHIVE DESTINATION ${GDCM_INSTALL_LIB_DIR} COMPONENT VTKDevelopment
  )
  #INSTALL(TARGETS vtkgdcm
  #  LIBRARY DESTINATION ${GDCM_INSTALL_LIB_DIR} COMPONENT Development ${NAMELINK_ONLY}
  #)
endif()

if(NOT GDCM_INSTALL_NO_DEVELOPMENT)
  set(header_files_glob "*.h" "*.txx")
  if( "${VTK_MAJOR_VERSION}.${VTK_MINOR_VERSION}" LESS 4.5 )
    set(header_files_glob ${header_files_glob}
      "VTK4/*.h"
    )
  endif()
  FILE(GLOB header_files ${header_files_glob})
  INSTALL(FILES ${header_files}
    DESTINATION ${GDCM_INSTALL_INCLUDE_DIR} COMPONENT VTKHeaders
  )
endif()

if(GDCM_WRAP_CSHARP)
  if( "${VTK_MAJOR_VERSION}.${VTK_MINOR_VERSION}" LESS 4.5 )
    MESSAGE(FATAL_ERROR "you need a newer VTK version >= 5.0")
  endif()
  if(GDCM_USE_ACTIVIZ)
    FIND_PACKAGE(ACTIVIZ REQUIRED)
  else()
    MESSAGE("You are using the SWIG version of VTKGDCM. This is not compatible with Activiz")
  endif()
  FIND_PACKAGE(SWIG REQUIRED)
  MARK_AS_ADVANCED(SWIG_DIR SWIG_EXECUTABLE SWIG_VERSION)
  INCLUDE(${SWIG_USE_FILE})
  SET_SOURCE_FILES_PROPERTIES(vtkgdcm.i PROPERTIES CPLUSPLUS ON)
  #SET_SOURCE_FILES_PROPERTIES(vtkgdcm.i PROPERTIES COMPILE_FLAGS -DUSEACTIVIZ)
  if(GDCM_USE_ACTIVIZ)
  set(CMAKE_SWIG_FLAGS "-namespace vtkgdcm -DUSEACTIVIZ")
  else()
  set(CMAKE_SWIG_FLAGS "-namespace vtkgdcm")
  endif()
  SEPARATE_ARGUMENTS(CMAKE_SWIG_FLAGS)
  SWIG_ADD_MODULE(vtkgdcmsharpglue csharp vtkgdcm.i)
  SWIG_LINK_LIBRARIES(vtkgdcmsharpglue vtkgdcm)
  # Stupid cmake-swig module is doing that for us, when not needed
  if(UNIX)
    SET_TARGET_PROPERTIES(${SWIG_MODULE_vtkgdcmsharpglue_REAL_NAME} PROPERTIES PREFIX "lib")
  endif()

if(NOT GDCM_INSTALL_NO_LIBRARIES)
  INSTALL(TARGETS ${SWIG_MODULE_vtkgdcmsharpglue_REAL_NAME}
    RUNTIME DESTINATION ${GDCM_INSTALL_BIN_DIR} COMPONENT Applications
    LIBRARY DESTINATION ${GDCM_INSTALL_LIB_DIR} COMPONENT Libraries
    ARCHIVE DESTINATION ${GDCM_INSTALL_LIB_DIR} COMPONENT Development
  )
endif()
  CONFIGURE_FILE(
    ${CMAKE_CURRENT_SOURCE_DIR}/AssemblyInfo.cs.in
    ${CMAKE_CURRENT_BINARY_DIR}/AssemblyInfo.cs
    @ONLY)
  if(GDCM_USE_ACTIVIZ)
  ADD_CUSTOM_COMMAND(
    OUTPUT ${GDCM_LIBRARY_DIR}/vtkgdcm-sharp.dll
    COMMAND ${CMAKE_CSHARP_COMPILER} ARGS "/r:${ACTIVIZ_KITWARE_VTK_LIBRARY}" "/r:${ACTIVIZ_KITWARE_MUMMY_RUNTIME_LIBRARY}" "/t:library" "/out:${GDCM_LIBRARY_DIR}/vtkgdcm-sharp.dll" "*.cs" 
    #COMMAND ${CMAKE_CSHARP_COMPILER} ARGS "/t:library" "/out:${GDCM_LIBRARY_DIR}/vtkgdcm-sharp.dll" "*.cs" 
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS "${swig_generated_file_fullname}"
      ${CMAKE_CURRENT_BINARY_DIR}/AssemblyInfo.cs
    COMMENT "csc *.cs"
  )
  else()
  ADD_CUSTOM_COMMAND(
    OUTPUT ${GDCM_LIBRARY_DIR}/vtkgdcm-sharp.dll
    #COMMAND ${CMAKE_CSHARP_COMPILER} ARGS "/r:${ACTIVIZ_KITWARE_VTK_LIBRARY}" "/r:${ACTIVIZ_KITWARE_MUMMY_RUNTIME_LIBRARY}" "/t:library" "/out:${GDCM_LIBRARY_DIR}/vtkgdcm-sharp.dll" "*.cs" 
    COMMAND ${CMAKE_CSHARP_COMPILER} ARGS "/t:library" "/out:${GDCM_LIBRARY_DIR}/vtkgdcm-sharp.dll" "*.cs" 
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS "${swig_generated_file_fullname}"
      ${CMAKE_CURRENT_BINARY_DIR}/AssemblyInfo.cs
    COMMENT "csc *.cs"
  )

  endif()

  ADD_CUSTOM_COMMAND(
    OUTPUT  ${GDCM_LIBRARY_DIR}/vtkgdcm-sharp.dll.config
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/vtkgdcm-sharp.dll.config ${GDCM_LIBRARY_DIR}
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/vtkgdcm-sharp.dll.config
    COMMENT "Copying vtkgdcm-sharp.dll.config"
  )

ADD_CUSTOM_TARGET(VTKGDCMCSharp ALL
  DEPENDS 
    ${GDCM_LIBRARY_DIR}/vtkgdcm-sharp.dll
    ${GDCM_LIBRARY_DIR}/vtkgdcm-sharp.dll.config
    #${GDCM_EXECUTABLE_DIR}/HelloWorld.exe
  COMMENT "building vtkgdcm-sharp.dll"
)

  # because vtkgdcm-sharp.dll is constructed with custom commands, it need the INSTALL(FILES signature:
set(GDCM_LIBRARY_DIR2 ${LIBRARY_OUTPUT_PATH}/\${BUILD_TYPE})
  INSTALL(FILES 
    ${GDCM_LIBRARY_DIR2}/vtkgdcm-sharp.dll
    ${GDCM_LIBRARY_DIR2}/vtkgdcm-sharp.dll.config
    DESTINATION ${GDCM_INSTALL_LIB_DIR} COMPONENT VTKCSharpModule
  )

endif()

if(GDCM_WRAP_JAVA)
  if(VTK_WRAP_JAVA)
    set(VTK_WRAP_JAVA3_INIT_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
    # Lars Matth�us patch (package vtk => imply vtk subdir )
    set(VTK_JAVA_HOME ${CMAKE_CURRENT_BINARY_DIR}/java/vtk)
    # This is *required* don't ask
    MAKE_DIRECTORY(${VTK_JAVA_HOME})
    INCLUDE(${VTK_CMAKE_DIR}/vtkWrapJava.cmake)
    INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR})

    VTK_WRAP_JAVA3(${VTKGDCM_NAME}Java vtkgdcmJAVA_SRCS "${vtkgdcm_SRCS}")
    ADD_LIBRARY(${VTKGDCM_NAME}Java SHARED ${vtkgdcmJAVA_SRCS})
    TARGET_LINK_LIBRARIES(${VTKGDCM_NAME}Java ${VTKGDCM_NAME})
    foreach(c ${vtkgdcm_LIBS})
      TARGET_LINK_LIBRARIES(${VTKGDCM_NAME}Java ${c}Java)
    endforeach()
    # Create the jar file:
    # I am pretty sure this *.java thingy will byte me one day, when someone will try
    # to recompile from an existing build tree with invalid generated *.java file...
    ADD_CUSTOM_COMMAND(
      OUTPUT ${LIBRARY_OUTPUT_PATH}/vtkgdcm.jar
      COMMAND ${JAVA_COMPILE} ARGS -cp ${VTK_JAVA_JAR} "vtk/*.java"
      COMMAND ${JAVA_ARCHIVE} ARGS cvf ${LIBRARY_OUTPUT_PATH}/${PROJECT_NAME}.jar vtk/*.class
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/java
      DEPENDS ${VTKGDCM_NAME}Java
      COMMENT   "*.java -> jar"
    )
    # Target to execute custom command:
    ADD_CUSTOM_TARGET(VTKGDCMJavaJar ALL
      DEPENDS ${LIBRARY_OUTPUT_PATH}/vtkgdcm.jar
      COMMENT "building vtkgdcm.jar"
    )
    # Install rules:
    if(NOT GDCM_INSTALL_NO_LIBRARIES)
      INSTALL(TARGETS ${VTKGDCM_NAME}Java
        RUNTIME DESTINATION ${GDCM_INSTALL_BIN_DIR} COMPONENT VTKApplications
        LIBRARY DESTINATION ${GDCM_INSTALL_LIB_DIR} COMPONENT VTKLibraries ${NAMELINK_SKIP}
        ARCHIVE DESTINATION ${GDCM_INSTALL_LIB_DIR} COMPONENT VTKDevelopment
      )
    endif()

  else()
    MESSAGE("GDCM_WRAP_JAVA canot be build without VTK_WRAP_JAVA")
  endif()
endif()

if(GDCM_WRAP_PYTHON)
  if(VTK_WRAP_PYTHON)
      set(DEXTENSION "")
    if( "${VTK_MAJOR_VERSION}.${VTK_MINOR_VERSION}" LESS 4.5 )
        VTK_WRAP_PYTHON2(${VTKGDCM_NAME}Python vtkgdcmPYTHON_SRCS ${vtkgdcm_SRCS})
    else()
    INCLUDE(${VTK_CMAKE_DIR}/vtkWrapPython.cmake)
        INCLUDE_DIRECTORIES(
          ${CMAKE_CURRENT_SOURCE_DIR}
        )
        VTK_WRAP_PYTHON3(${VTKGDCM_NAME}Python vtkgdcmPYTHON_SRCS "${vtkgdcm_SRCS}")
      set(DEXTENSION "D")
    endif()
    ADD_LIBRARY(${VTKGDCM_NAME}PythonD ${vtkgdcmPYTHON_SRCS})
    # this is a library set the version:
    SET_TARGET_PROPERTIES(${VTKGDCM_NAME}PythonD PROPERTIES ${GDCM_LIBRARY_PROPERTIES})
    ADD_LIBRARY(${VTKGDCM_NAME}Python MODULE ${VTKGDCM_NAME}PythonInit.cxx)
    # do not set the version on the Python module:
    #SET_TARGET_PROPERTIES(${VTKGDCM_NAME}Python PROPERTIES ${GDCM_LIBRARY_PROPERTIES})
    TARGET_LINK_LIBRARIES(${VTKGDCM_NAME}PythonD ${VTKGDCM_NAME})
    foreach(c ${vtkgdcm_LIBS})
      TARGET_LINK_LIBRARIES(${VTKGDCM_NAME}PythonD ${c}Python${DEXTENSION})
    endforeach()
    TARGET_LINK_LIBRARIES(${VTKGDCM_NAME}Python ${VTKGDCM_NAME}PythonD)
    # Python extension modules on Windows must have the extension ".pyd"
    # instead of ".dll" as of Python 2.5.  Older python versions do support
    # this suffix.
    if(WIN32 AND NOT CYGWIN)
      SET_TARGET_PROPERTIES(${VTKGDCM_NAME}Python PROPERTIES SUFFIX ".pyd")
    endif()

    ADD_CUSTOM_COMMAND(
      TARGET    ${VTKGDCM_NAME}Python
      POST_BUILD
      COMMAND   ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/vtkgdcm.py ${LIBRARY_OUTPUT_PATH}/${CMAKE_CFG_INTDIR}
      DEPENDS   "${CMAKE_CURRENT_SOURCE_DIR}/vtkgdcm.py"
      COMMENT   "Copy vtkgdcm.py into ${LIBRARY_OUTPUT_PATH}"
    )
    if(NOT GDCM_INSTALL_NO_LIBRARIES)
        INSTALL(TARGETS ${VTKGDCM_NAME}Python
          RUNTIME DESTINATION ${GDCM_INSTALL_BIN_DIR} COMPONENT                        VTKPythonModule
          LIBRARY DESTINATION ${GDCM_INSTALL_LIB_DIR}/${python_site_package} COMPONENT VTKPythonModule
          ARCHIVE DESTINATION ${GDCM_INSTALL_LIB_DIR}/${python_site_package} COMPONENT VTKPythonModule
        )
        INSTALL(TARGETS ${VTKGDCM_NAME}PythonD
          RUNTIME DESTINATION ${GDCM_INSTALL_BIN_DIR} COMPONENT VTKPythonModule
          LIBRARY DESTINATION ${GDCM_INSTALL_LIB_DIR} COMPONENT VTKPythonModule
          ARCHIVE DESTINATION ${GDCM_INSTALL_LIB_DIR} COMPONENT VTKPythonModule
        )
#        INSTALL(TARGETS ${VTKGDCM_NAME}PythonD ${VTKGDCM_NAME}Python
#          LIBRARY DESTINATION ${GDCM_INSTALL_LIB_DIR}/${python_site_package} COMPONENT VTKDevelopment ${NAMELINK_ONLY}
#  )
    # the python file is not a dev file, but part of the gdcm module...
      INSTALL(FILES ${CMAKE_CURRENT_SOURCE_DIR}/vtkgdcm.py 
        DESTINATION ${GDCM_INSTALL_LIB_DIR}/${python_site_package} COMPONENT VTKPythonModule
      )
    endif()

  else()
    MESSAGE("GDCM_WRAP_PYTHON canot be build without VTK_WRAP_PYTHON")
  endif()
endif()

if(BUILD_TESTING)
  add_subdirectory(Testing)
endif()

if(BUILD_APPLICATIONS)
  add_subdirectory(Applications)
endif()

if(BUILD_EXAMPLES)
  add_subdirectory(Examples)
endif()

