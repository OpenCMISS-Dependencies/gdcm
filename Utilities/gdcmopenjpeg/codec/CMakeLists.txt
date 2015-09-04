# Build the demo app, small examples

# First thing define the common source:
set(common_SRCS
  convert.c
  )
# Then check if getopt is present:
INCLUDE (${CMAKE_ROOT}/Modules/CheckIncludeFile.cmake)
set(DONT_HAVE_GETOPT 1)
if(UNIX) #I am pretty sure only *nix sys have this anyway
  CHECK_INCLUDE_FILE("getopt.h" CMAKE_HAVE_GETOPT_H)
  # Seems like we need the contrary:
  if(CMAKE_HAVE_GETOPT_H)
    set(DONT_HAVE_GETOPT 0)
  endif()
endif()

# If not getopt was found then add it to the lib:
if(DONT_HAVE_GETOPT)
  ADD_DEFINITIONS(-DDONT_HAVE_GETOPT)
  set(common_SRCS
    ${common_SRCS}
    compat/getopt.c
  )
endif()


# Headers file are located here:
INCLUDE_DIRECTORIES(
  ${${OPENJPEG_NAMESPACE}_SOURCE_DIR}/libopenjpeg
  )

# Do the proper thing when building static...if only there was configured
# headers or def files instead
if(NOT BUILD_SHARED_LIBS)
  ADD_DEFINITIONS(-DOPJ_STATIC)
endif()

# Loop over all executables:
foreach(exe j2k_to_image image_to_j2k)
  ADD_EXECUTABLE(${exe} ${exe}.c ${common_SRCS})
  TARGET_LINK_LIBRARIES(${exe} ${OPENJPEG_LIBRARY_NAME})
  # On unix you need to link to the math library:
  if(UNIX)
    TARGET_LINK_LIBRARIES(${exe} -lm)
  endif()
if(NOT OPENJPEG_INSTALL_NO_LIBRARIES)
  INSTALL(TARGETS ${exe}
    RUNTIME DESTINATION ${OPENJPEG_INSTALL_BIN_DIR} COMPONENT Applications
    LIBRARY DESTINATION ${OPENJPEG_INSTALL_LIB_DIR} COMPONENT Libraries
    ARCHIVE DESTINATION ${OPENJPEG_INSTALL_LIB_DIR} COMPONENT Development
  ${CPACK_NAMELINK_TYPE}
	)
endif()
endforeach()


