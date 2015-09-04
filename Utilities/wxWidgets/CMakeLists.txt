PROJECT(WXGDCM)
# wxWidgets stuff changed a lot within the 2.4.2 to 2.4.3
# I wonder if this has something to do with adding features on a stable branch?
CMAKE_MINIMUM_REQUIRED(VERSION 2.6.0)

if(COMMAND cmake_policy)
cmake_policy(SET CMP0003 NEW)
endif()


#-----------------------------------------------------------------------------
FIND_PACKAGE(VTK REQUIRED)
INCLUDE(${VTK_USE_FILE})

if(WIN32)
  set(GUI_EXECUTABLE WIN32)
else()
  if(APPLE)
    set(GUI_EXECUTABLE MACOSX_BUNDLE)
    if(VTK_USE_COCOA)
      SET_SOURCE_FILES_PROPERTIES(
        wxVTKRenderWindowInteractor.cxx
        PROPERTIES COMPILE_FLAGS "-ObjC++")
    endif()
  else()
    # Ok X11 for sure, but just check:
    if(NOT VTK_USE_X)
      MESSAGE(FATAL_ERROR "You need to have VTK_USE_X")
    endif()
    # See also:
    # FindGTK.cmake update
    # http://www.cmake.org/Bug/bug.php?op=show&bugid=3582
    #FIND_PACKAGE(GTK REQUIRED)
    #INCLUDE_DIRECTORIES(${GTK_INCLUDE_DIR} 
    #  #/usr/lib/wx/include/gtk-2.4/
    #)
    FIND_PACKAGE(PkgConfig)
    pkg_check_modules (GTK2 gtk+-2.0)
    #MESSAGE("${GTK2_INCLUDE_DIRS}")
    INCLUDE_DIRECTORIES(${GTK2_INCLUDE_DIRS})
    LINK_LIBRARIES(${GTK2_LIBRARIES})

    # Can I require all my user to have the gl lib on linux, even if they do not really need it...
    set(WXGLCANVASLIBS "gl")
  endif()
endif()

# wxWidgets is required to build the project
# For GTK we need a couple of stuff:
# gl: GLCanvas
# adv: wxSashLayoutWindow and such...
FIND_PACKAGE(wxWidgets COMPONENTS base core adv ${WXGLCANVASLIBS})

if(wxWidgets_FOUND)
  INCLUDE( ${wxWidgets_USE_FILE} )
endif()

INCLUDE_DIRECTORIES(
  ${GDCM_BINARY_DIR}/Source/Common # gdcmConfigure.h
  ${GDCM_SOURCE_DIR}/Source/Common
  ${GDCM_SOURCE_DIR}/Utilities/VTK
)

ADD_EXECUTABLE(wxGDCM main.cpp wxGDCMFrame.cpp wxGDCMFrameBase.cpp wxVTKRenderWindowInteractor.cxx)
TARGET_LINK_LIBRARIES(wxGDCM vtkRendering ${wxWidgets_LIBRARIES} vtkgdcm)
INSTALL(TARGETS wxGDCM
	RUNTIME DESTINATION bin
	LIBRARY DESTINATION lib
	ARCHIVE DESTINATION lib/static
  ${CPACK_NAMELINK_TYPE}
	)
