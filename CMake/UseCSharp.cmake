# - C# module for CMake
# Defines the following macros:
#   CSHARP_ADD_EXECUTABLE(name [ files ])
#     - Define C# executable with given name
#   CSHARP_ADD_LIBRARY(name [ files ])
#     - Define C# library with given name
#   CSHARP_LINK_LIBRARIES(name [ libraries ])
#     - Link libraries to csharp library
#
#  Copyright (c) 2006-2009 Mathieu Malaterre <mathieu.malaterre@gmail.com>
#
#  Redistribution and use is allowed according to the terms of the New
#  BSD license.
#  For details see the accompanying COPYING-CMAKE-SCRIPTS file.
#

# TODO:
# http://www.cs.nuim.ie/~jpower/Research/csharp/Index.html

if(WIN32)
  INCLUDE(${DotNETFrameworkSDK_USE_FILE})
  # remap
  set(CMAKE_CSHARP1_COMPILER ${CSC_v1_EXECUTABLE})
  set(CMAKE_CSHARP2_COMPILER ${CSC_v2_EXECUTABLE})
  set(CMAKE_CSHARP3_COMPILER ${CSC_v3_EXECUTABLE})

  #set(CMAKE_CSHARP3_INTERPRETER ${MONO_EXECUTABLE})
else()
  INCLUDE(${MONO_USE_FILE})
  set(CMAKE_CSHARP1_COMPILER ${MCS_EXECUTABLE})
  set(CMAKE_CSHARP2_COMPILER ${GMCS_EXECUTABLE})
  set(CMAKE_CSHARP3_COMPILER ${SMCS_EXECUTABLE})

  set(CMAKE_CSHARP_INTERPRETER ${MONO_EXECUTABLE})
endif()

set(DESIRED_CSHARP_COMPILER_VERSION 2 CACHE STRING "Pick a version for C# compiler to use: 1, 2 or 3")
MARK_AS_ADVANCED(DESIRED_CSHARP_COMPILER_VERSION)

# default to v1:
if(DESIRED_CSHARP_COMPILER_VERSION MATCHES 1)
  set(CMAKE_CSHARP_COMPILER ${CMAKE_CSHARP1_COMPILER})
ELSEif(DESIRED_CSHARP_COMPILER_VERSION MATCHES 2)
  set(CMAKE_CSHARP_COMPILER ${CMAKE_CSHARP2_COMPILER})
ELSEif(DESIRED_CSHARP_COMPILER_VERSION MATCHES 3)
  set(CMAKE_CSHARP_COMPILER ${CMAKE_CSHARP3_COMPILER})
else()
  MESSAGE(FATAL_ERROR "Do not know this version")
endif()

# Check something is found:
if(NOT CMAKE_CSHARP_COMPILER)
  # status message only for now:
  MESSAGE("Sorry C# v${DESIRED_CSHARP_COMPILER_VERSION} was not found on your system")
endif()

MACRO(CSHARP_ADD_LIBRARY name)
  set(csharp_cs_sources)
  set(csharp_cs_sources_dep)
  foreach(it ${ARGN})
    if(EXISTS ${it})
      set(csharp_cs_sources "${csharp_cs_sources} ${it}")
      set(csharp_cs_sources_dep ${csharp_cs_sources_dep} ${it})
    else()
      if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${it})
        set(csharp_cs_sources "${csharp_cs_sources} ${CMAKE_CURRENT_SOURCE_DIR}/${it}")
        set(csharp_cs_sources_dep ${csharp_cs_sources_dep} ${CMAKE_CURRENT_SOURCE_DIR}/${it})
      else()
        #MESSAGE("Could not find: ${it}")
        set(csharp_cs_sources "${csharp_cs_sources} ${it}")
      endif()
    endif()
  endforeach()

  #set(SHARP #)
  SEPARATE_ARGUMENTS(csharp_cs_sources)
  ADD_CUSTOM_COMMAND(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${name}.dll
    COMMAND ${CMAKE_CSHARP_COMPILER}
    ARGS "/t:library" "/out:${name}.dll" ${csharp_cs_sources}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS "${csharp_cs_sources_dep}"
    COMMENT "Creating Csharp library ${name}.cs"
  )
  ADD_CUSTOM_TARGET(CSharp_${name} ALL
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${name}.dll
  )
ENDMACRO(CSHARP_ADD_LIBRARY)

MACRO(CSHARP_ADD_EXECUTABLE name)
  set(csharp_cs_sources)
  foreach(it ${ARGN})
    if(EXISTS ${it})
      set(csharp_cs_sources "${csharp_cs_sources} ${it}")
    else()
      if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${it})
        set(csharp_cs_sources "${csharp_cs_sources} ${CMAKE_CURRENT_SOURCE_DIR}/${it}")
      else()
        #MESSAGE("Could not find: ${it}")
        set(csharp_cs_sources "${csharp_cs_sources} ${it}")
      endif()
    endif()
  endforeach()

  set(CSHARP_EXECUTABLE_${name}_ARGS
    #"/out:${name}.dll" ${csharp_cs_sources}
    #"/r:gdcm_csharp.dll" 
    "/out:${name}.exe ${csharp_cs_sources}"
  )

ENDMACRO(CSHARP_ADD_EXECUTABLE)

MACRO(CSHARP_LINK_LIBRARIES name)
  set(csharp_libraries)
  set(csharp_libraries_depends)
  foreach(it ${ARGN})
    #if(EXISTS ${it}.dll)
      set(csharp_libraries "${csharp_libraries} /r:${it}.dll")
    #  set(csharp_libraries_depends ${it}.dll)
    #else()
    #  if(EXISTS ${CMAKE_CURRENT_BINARY_DIR}/${it}.dll)
    #    set(csharp_libraries "${csharp_libraries} /r:${it}.dll")
    #    set(csharp_libraries_depends ${CMAKE_CURRENT_BINARY_DIR}/${it}.dll)
    #  else()
    #    MESSAGE("Could not find: ${it}")
    #  endif()
    #endif()
  endforeach()
  set(CSHARP_EXECUTABLE_${name}_ARGS " ${csharp_libraries} ${CSHARP_EXECUTABLE_${name}_ARGS}")
  #MESSAGE( "DEBUG: ${CSHARP_EXECUTABLE_${name}_ARGS}" )

  # BAD DESIGN !
  # This should be in the _ADD_EXECUTABLE...
  SEPARATE_ARGUMENTS(CSHARP_EXECUTABLE_${name}_ARGS)
  ADD_CUSTOM_COMMAND(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${name}.exe
    COMMAND ${CMAKE_CSHARP_COMPILER}
    #ARGS "/r:gdcm_csharp.dll" "/out:${name}.exe" ${csharp_cs_sources}
    ARGS ${CSHARP_EXECUTABLE_${name}_ARGS}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    #DEPENDS ${csharp_cs_sources}
    COMMENT "Create HelloWorld.exe"
  )

  #MESSAGE("DEBUG2:${csharp_libraries_depends}")
  ADD_CUSTOM_TARGET(CSHARP_EXECUTABLE_${name} ALL
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${name}.exe
            ${csharp_libraries_depends}
  )

ENDMACRO(CSHARP_LINK_LIBRARIES)

