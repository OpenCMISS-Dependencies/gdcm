#
# This module is provided as GDCM_USE_FILE by GDCMConfig.cmake.
# It can be INCLUDEd in a project to load the needed compiler and linker
# settings to use GDCM:
#   FIND_PACKAGE(GDCM REQUIRED)
#   INCLUDE(${GDCM_USE_FILE})

if(NOT GDCM_USE_FILE_INCLUDED)
  set(GDCM_USE_FILE_INCLUDED 1)

  # Load the compiler settings used for GDCM.
  if(GDCM_BUILD_SETTINGS_FILE)
    INCLUDE(${CMAKE_ROOT}/Modules/CMakeImportBuildSettings.cmake)
    CMAKE_IMPORT_BUILD_SETTINGS(${GDCM_BUILD_SETTINGS_FILE})
  endif()

  # Add compiler flags needed to use GDCM.
  set(CMAKE_C_FLAGS
    "${CMAKE_C_FLAGS} ${GDCM_REQUIRED_C_FLAGS}")
  set(CMAKE_CXX_FLAGS
    "${CMAKE_CXX_FLAGS} ${GDCM_REQUIRED_CXX_FLAGS}")
  set(CMAKE_EXE_LINKER_FLAGS
    "${CMAKE_EXE_LINKER_FLAGS} ${GDCM_REQUIRED_EXE_LINKER_FLAGS}")
  set(CMAKE_SHARED_LINKER_FLAGS
    "${CMAKE_SHARED_LINKER_FLAGS} ${GDCM_REQUIRED_SHARED_LINKER_FLAGS}")
  set(CMAKE_MODULE_LINKER_FLAGS
    "${CMAKE_MODULE_LINKER_FLAGS} ${GDCM_REQUIRED_MODULE_LINKER_FLAGS}")

  # Add include directories needed to use GDCM.
  INCLUDE_DIRECTORIES(${GDCM_INCLUDE_DIRS})

  # Add link directories needed to use GDCM.
  LINK_DIRECTORIES(${GDCM_LIBRARY_DIRS})

  # Add cmake module path.
  set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${GDCM_CMAKE_DIR}")

  # Use VTK.
  if(GDCM_USE_VTK)
    set(VTK_DIR ${GDCM_VTK_DIR})
    FIND_PACKAGE(VTK)
    if(VTK_FOUND)
      INCLUDE(${VTK_USE_FILE})
    else()
      MESSAGE("VTK not found in GDCM_VTK_DIR=\"${GDCM_VTK_DIR}\".")
    endif()
  endif()

endif()
