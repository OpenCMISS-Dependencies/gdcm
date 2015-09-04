# Define the tests for vtk-gdcm
# vtkGDCM
set(VTK_GDCM_TEST_SRCS
  TestvtkGDCMImageReader
  TestvtkGDCMImageReader2
  TestvtkGDCMImageReader4
  TestvtkGDCMImageReaderIsLossy
  #TestvtkGDCMImageActor
  #TestvtkGDCMImageViewer
)
if( "${VTK_MAJOR_VERSION}.${VTK_MINOR_VERSION}" GREATER 4.5 )
  set(VTK_GDCM_TEST_SRCS
    ${VTK_GDCM_TEST_SRCS}
    TestvtkGDCMImageWriter
    TestvtkGDCMImageWriter2
    TestvtkGDCMThreadedImageReader2
  )
endif()

# Need gdcmDataExtra
if(GDCM_DATA_EXTRA_ROOT)
  set(VTK_GDCM_TEST_SRCS
    ${VTK_GDCM_TEST_SRCS}
    TestvtkGDCMImageReader3
    TestvtkGDCMPolyDataReader
  )
endif()
if(CMAKE_HAVE_PTHREAD_H)
  set(VTK_GDCM_TEST_SRCS
    ${VTK_GDCM_TEST_SRCS}
    TestvtkGDCMThreadedImageReader
  )
endif()

# Add the include paths
INCLUDE_DIRECTORIES(
  "${GDCM_SOURCE_DIR}/Utilities/VTK"
  "${GDCM_BINARY_DIR}/Testing/Source/Data" # for gdcmDataImages.h
  )

CREATE_TEST_SOURCELIST(vtkGDCMTests gdcmvtkGDCMTests.cxx ${VTK_GDCM_TEST_SRCS})
ADD_EXECUTABLE(gdcmvtkGDCMTests ${vtkGDCMTests})
if( "${VTK_MAJOR_VERSION}.${VTK_MINOR_VERSION}" LESS 4.5 )
  TARGET_LINK_LIBRARIES(gdcmvtkGDCMTests ${VTKGDCM_NAME} vtkRendering)
else()
  TARGET_LINK_LIBRARIES(gdcmvtkGDCMTests ${VTKGDCM_NAME} vtkVolumeRendering)
endif()

# Need full path to executable:
set(GDCM_VTK_GDCM_TESTS "${EXECUTABLE_OUTPUT_PATH}/gdcmvtkGDCMTests")

# Loop over files and create executables
foreach(name ${VTK_GDCM_TEST_SRCS})
  ADD_TEST(${name} ${GDCM_VTK_GDCM_TESTS} ${name})
endforeach()

