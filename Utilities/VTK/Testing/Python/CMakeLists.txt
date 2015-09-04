# VTK-Python testing
if(GDCM_WRAP_PYTHON)
  if(VTK_PYTHONPATH_DIRS)
     if(WIN32)
       #MESSAGE(${VTK_PYTHONPATH_DIRS})
       #STRING(REGEX REPLACE ";" ";" UNIX_VTK_PYTHONPATH_DIRS "${VTK_PYTHONPATH_DIRS}")
       set(UNIX_VTK_PYTHONPATH_DIRS "${VTK_PYTHONPATH_DIRS}")
     else()
       STRING(REGEX REPLACE ";" ":" UNIX_VTK_PYTHONPATH_DIRS "${VTK_PYTHONPATH_DIRS}")
     endif()
  else()
  # if VTK_PYTHONPATH_DIRS is not given (very old VTK) then simply hope the user set his pythonpath properly:
  #  set(UNIX_VTK_PYTHONPATH_DIRS "$ENV{PYTHONPATH}")
  # previous solution was not safe, let's hope the following are set properly:
   if(WIN32)
     set(PATH_SEPARATOR ";")
   else()
     set(PATH_SEPARATOR ":")
   endif()
     if(VTK_SOURCE_DIR)
      set(UNIX_VTK_PYTHONPATH_DIRS "${VTK_SOURCE_DIR}/Wrapping/Python${PATH_SEPARATOR}${VTK_LIBRARY_DIRS}")
    else()
      # FIXME: hardcoded
      set(UNIX_VTK_PYTHONPATH_DIRS "/usr/local/src/vtk/build/Wrapping/Python${PATH_SEPARATOR}${VTK_LIBRARY_DIRS}")
    endif()
  endif()
  set(VTK_PYTHON_TESTS
    TestvtkGDCMImageReader
    TestvtkGDCMImageWriter
    TestMultiframeGrayscaleWordSecondaryCaptureImageStorage
  )
  if(CMAKE_HAVE_PTHREAD_H)
    set(VTK_PYTHON_TESTS ${VTK_PYTHON_TESTS}
      #TestvtkGDCMThreadedImageReader
      TestvtkGDCMThreadedImageReader2
    )
  endif()

  foreach(test ${VTK_PYTHON_TESTS})
          #MESSAGE(${UNIX_VTK_PYTHONPATH_DIRS})
    SET_SOURCE_FILES_PROPERTIES(${test}.py PROPERTIES PYTHONPATH "${UNIX_VTK_PYTHONPATH_DIRS}")
    ADD_PYTHON_TEST(${test}Python ${test}.py ${GDCM_DATA_ROOT}/test.acr)
  endforeach()

endif()

