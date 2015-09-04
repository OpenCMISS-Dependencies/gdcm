# Generate the GDCMConfig.cmake file in the build tree. Also configure
# one for installation. The file tells external projects how to use
# GDCM.

# Help store a literal dollar in a string.  CMake 2.2 allows escaped
# dollars but we have to support CMake 2.0.
set(DOLLAR "$")

#-----------------------------------------------------------------------------
# Settings shared between the build tree and install tree.

EXPORT_LIBRARY_DEPENDENCIES(
  ${GDCM_BINARY_DIR}/GDCMLibraryDepends.cmake)
INCLUDE(${CMAKE_ROOT}/Modules/CMakeExportBuildSettings.cmake)
CMAKE_EXPORT_BUILD_SETTINGS(
  ${GDCM_BINARY_DIR}/GDCMBuildSettings.cmake)

if(NOT GDCM_INSTALL_NO_DEVELOPMENT)
  INSTALL(FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/UseGDCM.cmake
    ${GDCM_BINARY_DIR}/GDCMLibraryDepends.cmake
    ${GDCM_BINARY_DIR}/GDCMBuildSettings.cmake
    DESTINATION ${GDCM_INSTALL_PACKAGE_DIR} COMPONENT Development
    )
endif()

#-----------------------------------------------------------------------------
# Settings specific to the build tree.

# The install-only section is empty for the build tree.
set(GDCM_CONFIG_INSTALL_ONLY)

# The "use" file.
set(GDCM_USE_FILE_CONFIG 
  ${CMAKE_CURRENT_SOURCE_DIR}/UseGDCM.cmake)

# The build settings file.
set(GDCM_BUILD_SETTINGS_FILE_CONFIG 
  ${GDCM_BINARY_DIR}/GDCMBuildSettings.cmake)

# The library directories.
set(GDCM_LIBRARY_DIRS_CONFIG ${GDCM_LIBRARY_DIRS})

# The runtime directories.
set(GDCM_RUNTIME_DIRS_CONFIG ${GDCM_RUNTIME_DIRS})

# The include directories.
set(GDCM_INCLUDE_DIRS_CONFIG ${GDCM_INCLUDE_PATH})

# The library dependencies file.
set(GDCM_LIBRARY_DEPENDS_FILE 
  ${GDCM_BINARY_DIR}/GDCMLibraryDepends.cmake)

# The CMake macros dir.
set(GDCM_CMAKE_DIR_CONFIG 
  ${GDCM_CMAKE_DIR})

# The VTK options.
set(GDCM_VTK_DIR_CONFIG ${VTK_DIR})

# The build configuration information.
set(GDCM_CONFIGURATION_TYPES_CONFIG ${GDCM_CONFIGURATION_TYPES})
set(GDCM_BUILD_TYPE_CONFIG ${CMAKE_BUILD_TYPE})

# Configure GDCMConfig.cmake for the build tree.
CONFIGURE_FILE(
  ${CMAKE_CURRENT_SOURCE_DIR}/GDCMConfig.cmake.in
  ${GDCM_BINARY_DIR}/GDCMConfig.cmake @ONLY IMMEDIATE)

#-----------------------------------------------------------------------------
# Settings specific to the install tree.

# The "use" file.
set(GDCM_USE_FILE_CONFIG 
  ${DOLLAR}{GDCM_INSTALL_PREFIX}/${GDCM_INSTALL_PACKAGE_DIR}/UseGDCM.cmake)

# The build settings file.
set(GDCM_BUILD_SETTINGS_FILE_CONFIG 
  ${DOLLAR}{GDCM_INSTALL_PREFIX}/${GDCM_INSTALL_PACKAGE_DIR}/GDCMBuildSettings.cmake)

# The library directories.
if(CYGWIN AND GDCM_BUILD_SHARED_LIBS)
  # In Cygwin programs directly link to the .dll files.
  set(GDCM_LIBRARY_DIRS_CONFIG 
    ${DOLLAR}{GDCM_INSTALL_PREFIX}/${GDCM_INSTALL_BIN_DIR})
else()
  set(GDCM_LIBRARY_DIRS_CONFIG 
    ${DOLLAR}{GDCM_INSTALL_PREFIX}/${GDCM_INSTALL_LIB_DIR})
endif()

# The runtime directories.
if(WIN32)
  set(GDCM_RUNTIME_DIRS_CONFIG 
    ${DOLLAR}{GDCM_INSTALL_PREFIX}/${GDCM_INSTALL_BIN_DIR})
else()
  set(GDCM_RUNTIME_DIRS_CONFIG 
    ${DOLLAR}{GDCM_INSTALL_PREFIX}/${GDCM_INSTALL_LIB_DIR})
endif()

# The include directories.
set(GDCM_INCLUDE_DIRS_CONFIG
  ${DOLLAR}{GDCM_INSTALL_PREFIX}/${GDCM_INSTALL_INCLUDE_DIR})

# The library dependencies file.
set(GDCM_LIBRARY_DEPENDS_FILE 
  ${DOLLAR}{GDCM_INSTALL_PREFIX}/${GDCM_INSTALL_PACKAGE_DIR}/GDCMLibraryDepends.cmake)

# The CMake macros dir.
set(GDCM_CMAKE_DIR_CONFIG 
  ${DOLLAR}{GDCM_INSTALL_PREFIX}/${GDCM_INSTALL_PACKAGE_DIR}/CMake)

# The VTK options.
# If VTK_BINARY_DIR is set, then GDCM is part of a larger parent project
# that also builds VTK. In that case, GDCM_VTK_INSTALL_PACKAGE_DIR
# should be set to the value of VTK_INSTALL_PACKAGE_DIR. Otherwise, if not set,
# then we are using an outside VTK whose location will not change when we
# install.
#if(GDCM_USE_VTK)
if(VTK_BINARY_DIR)
  if(NOT GDCM_VTK_INSTALL_PACKAGE_DIR)
    MESSAGE(
      "GDCM_VTK_INSTALL_PACKAGE_DIR must be set by the parent project to the value of VTK_INSTALL_PACKAGE_DIR it uses to configure VTK.")
  endif()
  set(GDCM_VTK_DIR_CONFIG ${GDCM_VTK_INSTALL_PACKAGE_DIR})
else()
  set(GDCM_VTK_DIR_CONFIG ${VTK_DIR})
endif()
#endif()

# The build configuration information.
# The install tree only has one configuration.
set(GDCM_CONFIGURATION_TYPES_CONFIG)

# Configure GDCMConfig.cmake for the install tree.

# Construct the proper number of GET_FILENAME_COMPONENT(... PATH)
# calls to compute the installation prefix from GDCM_DIR.
STRING(REGEX REPLACE "/" ";" GDCM_INSTALL_PACKAGE_DIR_COUNT
  "${GDCM_INSTALL_PACKAGE_DIR}")
set(GDCM_CONFIG_INSTALL_ONLY "
# Compute the installation prefix from GDCM_DIR.
set(GDCM_INSTALL_PREFIX \"${DOLLAR}{GDCM_DIR}\")
")
foreach(p ${GDCM_INSTALL_PACKAGE_DIR_COUNT})
  set(GDCM_CONFIG_INSTALL_ONLY
    "${GDCM_CONFIG_INSTALL_ONLY}GET_FILENAME_COMPONENT(GDCM_INSTALL_PREFIX \"${DOLLAR}{GDCM_INSTALL_PREFIX}\" PATH)\n"
    )
endforeach()

if(CMAKE_CONFIGURATION_TYPES)
  # There are multiple build configurations.  Configure one
  # GDCMConfig.cmake for each configuration.
  foreach(config ${CMAKE_CONFIGURATION_TYPES})
    set(GDCM_BUILD_TYPE_CONFIG ${config})
    CONFIGURE_FILE(
      ${CMAKE_CURRENT_SOURCE_DIR}/GDCMConfig.cmake.in
      ${CMAKE_CURRENT_BINARY_DIR}/${config}/GDCMConfig.cmake
      @ONLY IMMEDIATE)
  endforeach()

  # Install the config file corresponding to the build configuration
  # specified when building the install target.  The BUILD_TYPE variable
  # will be set while CMake is processing the install files.
  if(NOT GDCM_INSTALL_NO_DEVELOPMENT)
    INSTALL(FILES
      ${CMAKE_CURRENT_BINARY_DIR}/${DOLLAR}{BUILD_TYPE}/GDCMConfig.cmake
      DESTINATION ${GDCM_INSTALL_PACKAGE_DIR} COMPONENT Development
    )
  endif()
else()
  # There is only one build configuration. Configure one GDCMConfig.cmake.
  set(GDCM_BUILD_TYPE_CONFIG ${CMAKE_BUILD_TYPE})
  CONFIGURE_FILE(
    ${CMAKE_CURRENT_SOURCE_DIR}/GDCMConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/GDCMConfig.cmake @ONLY IMMEDIATE)

  # Setup an install rule for the config file.
  if(NOT GDCM_INSTALL_NO_DEVELOPMENT)
    INSTALL(FILES
      ${CMAKE_CURRENT_BINARY_DIR}/GDCMConfig.cmake
      DESTINATION ${GDCM_INSTALL_PACKAGE_DIR} COMPONENT Development
    )
  endif()
endif()
