# Build the vtk-gdcm simple viewer
INCLUDE_DIRECTORIES(
  ${GDCM_SOURCE_DIR}/Utilities/VTK
  )

if(WIN32 AND NOT CYGWIN)
  INCLUDE_DIRECTORIES(
    "${GDCM_SOURCE_DIR}/Utilities/getopt"
  )
endif()
if(WIN32)
  if(BUILD_SHARED_LIBS)
    ADD_DEFINITIONS(-DGETOPT_DLL)
  endif()
endif()

set(GDCM_VTK_APPS
  gdcmviewer # vtkImageViewer2
  gdcm2vtk
  )

foreach(app ${GDCM_VTK_APPS})
  ADD_EXECUTABLE(${app} ${app}.cxx)
  if(GDCM_EXECUTABLE_PROPERTIES)
    SET_TARGET_PROPERTIES(${app} PROPERTIES ${GDCM_EXECUTABLE_PROPERTIES})
  endif()
  TARGET_LINK_LIBRARIES(${app} ${VTKGDCM_NAME} vtkRendering)
  if( "${VTK_MAJOR_VERSION}.${VTK_MINOR_VERSION}" GREATER 5.0 )
    TARGET_LINK_LIBRARIES(${app} vtkWidgets)
  endif()
  if(WIN32 AND NOT CYGWIN)
    TARGET_LINK_LIBRARIES(${app} gdcmgetopt)
  endif()
  if(NOT GDCM_INSTALL_NO_RUNTIME)
    INSTALL(TARGETS ${app}
      RUNTIME DESTINATION ${GDCM_INSTALL_BIN_DIR} COMPONENT VTKApplications
      LIBRARY DESTINATION ${GDCM_INSTALL_LIB_DIR} COMPONENT VTKLibraries
      ARCHIVE DESTINATION ${GDCM_INSTALL_LIB_DIR} COMPONENT VTKDevelopment
    )
  endif()
endforeach()


