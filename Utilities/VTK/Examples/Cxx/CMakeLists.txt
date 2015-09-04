INCLUDE_DIRECTORIES(
  ${GDCM_SOURCE_DIR}/Utilities/VTK
  )


if( "${VTK_MAJOR_VERSION}.${VTK_MINOR_VERSION}" GREATER 5.0 )
  set(GDCM_VTK_APPS
    gdcmorthoplanes
    gdcmscene
    gdcmvolume
    gdcmtexture
  )
  if(GDCM_BUILD_TESTING)
  set(GDCM_VTK_APPS
    ${GDCM_VTK_APPS}
    ConvertRGBToLuminance
    Convert16BitsTo8Bits
  )
  endif()
endif()

foreach(app ${GDCM_VTK_APPS})
  ADD_EXECUTABLE(${app} ${app}.cxx)
  #SET_TARGET_PROPERTIES(${app} PROPERTIES ${GDCM_EXECUTABLE_PROPERTIES})
  TARGET_LINK_LIBRARIES(${app} ${VTKGDCM_NAME} vtkRendering)
  if( "${VTK_MAJOR_VERSION}.${VTK_MINOR_VERSION}" GREATER 5.0 )
    TARGET_LINK_LIBRARIES(${app} vtkWidgets vtkVolumeRendering)
  endif()
endforeach()

if(CMAKE_HAVE_PTHREAD_H)
# Dev only: I dont need to install that one:
  ADD_EXECUTABLE(threadgdcm threadgdcm.cxx)
  TARGET_LINK_LIBRARIES(threadgdcm gdcmMSFF pthread vtkIO)
endif()

#ADD_EXECUTABLE(gdcm2vtk gdcm2vtk.cxx)
#TARGET_LINK_LIBRARIES(gdcm2vtk gdcmMSFF pthread)


