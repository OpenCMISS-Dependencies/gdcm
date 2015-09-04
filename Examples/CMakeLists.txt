CMAKE_MINIMUM_REQUIRED(VERSION 2.4)

# Remove these policy lines when CMake 2.6 is the minimum version.
if(COMMAND CMAKE_POLICY)
  CMAKE_POLICY(SET CMP0003 NEW)
endif()

# Choose behavior based on whether we are building inside the GDCM tree.
if(GDCM_BINARY_DIR)
add_subdirectory(Cxx)

if(GDCM_WRAP_PYTHON)
  add_subdirectory(Python)
endif()

if(GDCM_WRAP_CSHARP)
  add_subdirectory(Csharp)
endif()

if(GDCM_WRAP_JAVA)
  add_subdirectory(Java)
endif()

else()

  # We are building outside the GDCM tree.  Build the examples directly.
  PROJECT(GDCMExamples)

  # Find and load the VTK configuration.
  FIND_PACKAGE(GDCM REQUIRED)
  INCLUDE(${GDCM_USE_FILE})

  add_subdirectory(Cxx)

endif()

