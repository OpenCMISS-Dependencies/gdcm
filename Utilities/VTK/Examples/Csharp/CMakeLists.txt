set(DEP)
if(GDCM_USE_ACTIVIZ)
  #FIND_PACKAGE(ACTIVIZ REQUIRED)
set(examples 
HelloActiviz2
HelloActiviz3
HelloActiviz4
HelloActiviz5
RefCounting
)
foreach(example ${examples})
  file(TO_NATIVE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/${example}.cs result)
  #file(TO_NATIVE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/vtkGDCMImageReader.cs result2)
  ADD_CUSTOM_COMMAND(
    OUTPUT ${GDCM_EXECUTABLE_DIR}/${example}.exe
    #COMMAND ${CMAKE_CSHARP_COMPILER} ARGS "/r:${GDCM_LIBRARY_DIR}/gdcm_csharp.dll" "/out:${GDCM_EXECUTABLE_DIR}/${example}.exe" ${CMAKE_CURRENT_SOURCE_DIR}/${example}.cs
    COMMAND ${CMAKE_CSHARP_COMPILER} ARGS "/r:${ACTIVIZ_KITWARE_VTK_LIBRARY}" "/r:${ACTIVIZ_KITWARE_MUMMY_RUNTIME_LIBRARY}" "/r:${GDCM_LIBRARY_DIR}/vtkgdcm-sharp.dll" "/out:${GDCM_EXECUTABLE_DIR}/${example}.exe" ${result}
    #WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    DEPENDS ${GDCM_LIBRARY_DIR}/vtkgdcm-sharp.dll
            ${CMAKE_CURRENT_SOURCE_DIR}/${example}.cs
            #${CMAKE_CURRENT_SOURCE_DIR}/vtkGDCMImageReader.cs
    COMMENT "Create ${example}.exe"
  )
  set(DEP ${DEP} ${GDCM_EXECUTABLE_DIR}/${example}.exe)
endforeach()

if(BUILD_TESTING)
  get_filename_component(runtimepath ${ACTIVIZ_KITWARE_VTK_LIBRARY} PATH)
  if(GDCM_DATA_ROOT)
    SET_SOURCE_FILES_PROPERTIES(${GDCM_EXECUTABLE_DIR}/HelloActiviz5.exe PROPERTIES RUNTIMEPATH ${runtimepath})
    ADD_CSHARP_TEST(TestHelloActiviz5CSharp ${GDCM_EXECUTABLE_DIR}/HelloActiviz5.exe)
  endif()
  SET_SOURCE_FILES_PROPERTIES(${GDCM_EXECUTABLE_DIR}/RefCounting.exe PROPERTIES RUNTIMEPATH ${runtimepath})
  ADD_CSHARP_TEST(TestRefCountingCSharp ${GDCM_EXECUTABLE_DIR}/RefCounting.exe)
endif()

else()

set(CSHARP_EXAMPLES
  HelloVTKWorld
  HelloVTKWorld2
  )

foreach(example ${CSHARP_EXAMPLES})
  file(TO_NATIVE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/${example}.cs result)
  #file(TO_NATIVE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/vtkGDCMImageReader.cs result2)
# WORKING_DIRECTORY is set to the src dir because of a strange issue with CSC compiler on Win32 system:
# http://groups.google.com/group/microsoft.public.dotnet.languages.csharp/browse_thread/thread/9d3ac7eb9f7f56be
  ADD_CUSTOM_COMMAND(
    OUTPUT ${GDCM_EXECUTABLE_DIR}/${example}.exe
    #COMMAND ${CMAKE_CSHARP_COMPILER} ARGS "/r:${GDCM_LIBRARY_DIR}/gdcm_csharp.dll" "/out:${GDCM_EXECUTABLE_DIR}/${example}.exe" ${CMAKE_CURRENT_SOURCE_DIR}/${example}.cs
    #COMMAND ${CMAKE_CSHARP_COMPILER} ARGS "/r:${ACTIVIZ_KITWARE_VTK_LIBRARY}" "/r:${ACTIVIZ_KITWARE_MUMMY_RUNTIME_LIBRARY}" "/r:${GDCM_LIBRARY_DIR}/vtkgdcm-sharp.dll" "/out:${GDCM_EXECUTABLE_DIR}/${example}.exe" ${result}
    COMMAND ${CMAKE_CSHARP_COMPILER} ARGS "/r:${GDCM_LIBRARY_DIR}/vtkgdcm-sharp.dll" "/out:${GDCM_EXECUTABLE_DIR}/${example}.exe" ${result}
    #WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    DEPENDS ${GDCM_LIBRARY_DIR}/vtkgdcm-sharp.dll
            ${CMAKE_CURRENT_SOURCE_DIR}/${example}.cs
            #${CMAKE_CURRENT_SOURCE_DIR}/vtkGDCMImageReader.cs
    COMMENT "Create ${example}.exe"
  )
  set(DEP ${DEP} ${GDCM_EXECUTABLE_DIR}/${example}.exe)
endforeach()
endif()

ADD_CUSTOM_TARGET(VTKGDCMExampleCSharp ALL
  DEPENDS ${DEP}
  COMMENT "building examples"
)


