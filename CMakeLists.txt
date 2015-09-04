cmake_minimum_required(VERSION 3.0)
project(GDCM VERSION 2.0.12 LANGUAGES C CXX)
set(CMAKE_POSITION_INDEPENDENT_CODE YES)
# Dont expose the inner JPEG libraries
set(JPEG_INSTALL_NO_DEVELOPMENT YES)

#-----------------------------------------------------------------------------
# New cmake policy thingy
if(COMMAND CMAKE_POLICY)
  CMAKE_POLICY(SET CMP0003 NEW)
endif()

set(GDCM_CMAKE_DIR "${GDCM_SOURCE_DIR}/CMake" CACHE INTERNAL "")
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${GDCM_CMAKE_DIR}")

set(GDCM_PACKAGE_DESCRIPTION_SUMMARY "GDCM - Grassroots DICOM. GDCM is yet another DICOM library.")
set(GDCM_PACKAGE_CONTACT "Mathieu Malaterre <gdcm-developers@lists.sourceforge.net>")

if(${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION} GREATER 2.6)
  set(NAMELINK_ONLY NAMELINK_ONLY)
  set(NAMELINK_SKIP NAMELINK_SKIP)
else()
  set(NAMELINK_ONLY)
  set(NAMELINK_SKIP)
endif()

set( CMAKE_DEBUG_POSTFIX "d" )

# TODO
# http://www.vtk.org/pipermail/vtkusers/2007-May/090968.html 
# 
# False memory leak reports are caused by VTK dlls loading *before* MFC dlls.
# You have to use the linker's /delayload flag to avoid this issue.
# 
# The /delayload flag should be correct by default in the MFC examples if you
# are using CVS VTK... If you are using a previous version of VTK (5.0 or
# earlier) then you will have to figure out a way to link with that flag.
# 
# See the CVS version of files in VTK/GUISupport/MFC for details. Or grep the
# VTK source tree for "DELAYLOAD"

#-----------------------------------------------------------------------------
set(GDCM_BUILD_VERSION ${GDCM_VERSION_MAJOR})
set(GDCM_API_VERSION
  "${GDCM_VERSION_MAJOR}.${GDCM_VERSION_MINOR}")
set(GDCM_LIBRARY_PROPERTIES ${GDCM_LIBRARY_PROPERTIES}
  VERSION "${GDCM_VERSION}"
  SOVERSION "${GDCM_API_VERSION}"
)
set(GDCM_EXECUTABLE_PROPERTIES)
if(GDCM_NO_EXECUTABLE_PROPERTIES)
  set(GDCM_EXECUTABLE_PROPERTIES)
  set(python_site_package "python/site-packages")
else()
  set(python_site_package "")
endif()

#-----------------------------------------------------------------------------
INCLUDE(${GDCM_SOURCE_DIR}/CMake/UseCopyright.cmake)
CREATE_COPYRIGHT_FILE(${CMAKE_CURRENT_BINARY_DIR}/Copyright.txt)
APPEND_COPYRIGHT(${CMAKE_CURRENT_SOURCE_DIR}/Copyright.txt)

#-----------------------------------------------------------------------------
if(GDCM_VERSION_MINOR MATCHES "[02468]$")
  # Are we building a release branch / tag (read: even number)?
  # By default dashboard are expected to run with Design by Contract on
  # to trigger any of the assert, but on the other hand no user really
  # can figure out they need to change this value
  # So unless the user *specifically* requested a particular cmake_build_type
  # do the work internally and append the NDEBUG def flag (hopefully portable)
  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DNDEBUG")
  endif()
  # Since we are on a release branch, chance is that people don't care about testing
  # let's disable it for them
  set(GDCM_BUILD_TESTING_DEFAULT OFF)
else()
  set(GDCM_BUILD_TESTING_DEFAULT ON)
endif()

#-----------------------------------------------------------------------------
# VS 2005 declared that some C functions were deprecated...
if(MSVC)
  ADD_DEFINITIONS(-D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_DEPRECATE)
  ADD_DEFINITIONS(-D_SCL_SECURE_NO_DEPRECATE)
endif()

#-----------------------------------------------------------------------------
# Build shared lib by default
OPTION(GDCM_BUILD_SHARED_LIBS "Build GDCM with shared libraries." OFF)
set(BUILD_SHARED_LIBS ${GDCM_BUILD_SHARED_LIBS})

#-----------------------------------------------------------------------------
SET (EXECUTABLE_OUTPUT_PATH ${GDCM_BINARY_DIR}/bin CACHE PATH "Single output directory for building all executables.")
SET (LIBRARY_OUTPUT_PATH ${GDCM_BINARY_DIR}/bin CACHE PATH "Single output directory for building all libraries.")

#-----------------------------------------------------------------------------
# Adding GDCM_DATA_ROOT
FIND_PATH(GDCM_DATA_ROOT gdcm-ACR-LibIDO.acr
  ${GDCM_SOURCE_DIR}/../gdcmData
  $ENV{GDCM_DATA_ROOT}
  $ENV{PUB_DICT_PATH}/../../gdcmData
  )

#-----------------------------------------------------------------------------
FIND_PATH(GDCM_DATA_EXTRA_ROOT gdcmData.tar.gz
  ${GDCM_SOURCE_DIR}/../gdcmDataExtra
  $ENV{GDCM_DATA_EXTRA_ROOT}
  $ENV{PUB_DICT_PATH}/../../gdcmDataExtra
  )

# Define a temp directory in which we can output stuff
set(GDCM_TEMP_DIRECTORY "${GDCM_BINARY_DIR}/Testing/Temporary" CACHE PATH "Path to a valid temp directory")

#-----------------------------------------------------------------------------
include(CheckIncludeFile)
include(CheckIncludeFiles)
# Check if header file exists and add it to the list.
MACRO(CHECK_INCLUDE_FILE_CONCAT FILE VARIABLE)
  CHECK_INCLUDE_FILES("${UUID_INCLUDES};${FILE}" ${VARIABLE})
  if(${VARIABLE})
    set(UUID_INCLUDES ${UUID_INCLUDES} ${FILE})
  endif()
ENDMACRO(CHECK_INCLUDE_FILE_CONCAT)

CHECK_INCLUDE_FILE("stdint.h"       CMAKE_HAVE_STDINT_H)
if(UNIX) #Avoid polluting Win32 cmakecache
  CHECK_INCLUDE_FILE("inttypes.h"     CMAKE_HAVE_INTTYPES_H)
endif()

#-----------------------------------------------------------------------------
# Build the main lib...
if(MSVC)
  include_directories(
    "${GDCM_SOURCE_DIR}/Utilities/C99"
  )
  # Process the install rules from C99
  add_subdirectory(Utilities/C99)
endif()

# --------------------------------------------------------------------------
# Configure the export configuration

# You will also need to define a value for the following variables:
# GDCM_INSTALL_BIN_DIR          - binary dir (executables)
# GDCM_INSTALL_LIB_DIR          - library dir (libs)
# GDCM_CMAKE_PACKAGE_DIR        - cmake dir (cmake configuration)
# GDCM_INSTALL_DATA_DIR         - share dir (say, examples, data, etc)
# GDCM_INSTALL_INCLUDE_DIR      - include dir (headers)
# GDCM_INSTALL_PACKAGE_DIR      - package/export configuration files
# GDCM_VTK_INSTALL_PACKAGE_DIR  - VTK package/export configuration files
# GDCM_INSTALL_NO_DEVELOPMENT   - do not install development files
# GDCM_INSTALL_NO_RUNTIME       - do not install runtime files
# GDCM_INSTALL_NO_DOCUMENTATION - do not install documentation files

# --------------------------------------------------------------------------
# Install directories

STRING(TOLOWER ${PROJECT_NAME} projectname)
set(subdir "${projectname}-${GDCM_VERSION_MAJOR}.${GDCM_VERSION_MINOR}")
#MESSAGE(${subdir})

if(NOT GDCM_INSTALL_BIN_DIR)
  set(GDCM_INSTALL_BIN_DIR "bin")
endif()

if(NOT GDCM_INSTALL_LIB_DIR)
  #set(GDCM_INSTALL_LIB_DIR "lib/${PROJECT_NAME}")
  set(GDCM_INSTALL_LIB_DIR "lib")
endif()

if(NOT GDCM_INSTALL_DATA_DIR)
  set(GDCM_INSTALL_DATA_DIR "share/${subdir}")
endif()

if(NOT GDCM_INSTALL_INCLUDE_DIR)
  set(GDCM_INSTALL_INCLUDE_DIR "include/${subdir}")
endif()

if(NOT GDCM_INSTALL_DOC_DIR)
  set(GDCM_INSTALL_DOC_DIR "share/doc/${subdir}")
endif()

if(NOT GDCM_INSTALL_MAN_DIR)
  set(GDCM_INSTALL_MAN_DIR "man")
endif()

if(NOT GDCM_CMAKE_PACKAGE_DIR)
  set(GDCM_CMAKE_PACKAGE_DIR cmake)
endif()

if(NOT GDCM_INSTALL_PACKAGE_DIR)
  set(GDCM_INSTALL_PACKAGE_DIR ${GDCM_INSTALL_LIB_DIR}/${subdir}
    CACHE INTERNAL "")
endif()

if(NOT GDCM_VTK_INSTALL_PACKAGE_DIR)
  set(GDCM_VTK_INSTALL_PACKAGE_DIR ${VTK_INSTALL_PACKAGE_DIR})
endif()

if(NOT GDCM_INSTALL_NO_DEVELOPMENT)
  set(GDCM_INSTALL_NO_DEVELOPMENT 0)
endif()

if(NOT GDCM_INSTALL_NO_RUNTIME)
  set(GDCM_INSTALL_NO_RUNTIME 0)
endif()

if(NOT GDCM_INSTALL_NO_DOCUMENTATION)
  set(GDCM_INSTALL_NO_DOCUMENTATION 0)
endif()

set(GDCM_INSTALL_NO_LIBRARIES)
if(GDCM_BUILD_SHARED_LIBS)
  if(GDCM_INSTALL_NO_RUNTIME AND GDCM_INSTALL_NO_DEVELOPMENT)
    set(GDCM_INSTALL_NO_LIBRARIES 1)
  endif()
else()
  if(GDCM_INSTALL_NO_DEVELOPMENT)
    set(GDCM_INSTALL_NO_LIBRARIES 1)
  endif()
endif()

#-----------------------------------------------------------------------------
#System stuff, mainly for packager or paranoid people with up-to-date lib moto
OPTION(GDCM_USE_SYSTEM_ZLIB "Use system zlib" OFF)
#OPTION(GDCM_USE_SYSTEM_POLARSSL "Use system polarssl (xyssl)" OFF)
OPTION(GDCM_USE_SYSTEM_OPENSSL  "Use system OpenSSL" OFF)
OPTION(GDCM_USE_SYSTEM_EXPAT "Use system expat" OFF)
OPTION(GDCM_USE_SYSTEM_LJPEG "Use system ljpeg (ijg lib)" OFF)
OPTION(GDCM_USE_SYSTEM_OPENJPEG "Use system openjpeg (1.x)" OFF)
OPTION(GDCM_USE_SYSTEM_POPPLER "Use system poppler (pdf)" OFF)
if(GDCM_USE_SYSTEM_POPPLER)
  FIND_PACKAGE(Poppler REQUIRED)
endif()

if(GDCM_USE_SYSTEM_LJPEG)
  find_package(LJPEG REQUIRED)
  set(GDCM_LJPEG_LIBRARIES ${LJPEG_LIBRARIES})
else()
  set(GDCM_LJPEG_LIBRARIES gdcmjpeg8 gdcmjpeg12 gdcmjpeg16)
endif()

if(GDCM_USE_SYSTEM_OPENJPEG)
  find_package(OpenJPEG REQUIRED)
  set(GDCM_OPENJPEG_LIBRARIES ${OPENJPEG_LIBRARIES})
else()
  set(GDCM_OPENJPEG_LIBRARIES gdcmopenjpeg)
endif()

# Very advanced user option:
# This will cause building of the broken JPEG library released by the Standford PVRG group:
option(GDCM_USE_PVRG "Use pvrg lib, only turn it on if you know what you are doing." OFF)

if(GDCM_USE_SYSTEM_ZLIB)
  find_package(ZLIB ${ZLIB_VERSION} REQUIRED)
  set(GDCM_ZLIB_LIBRARIES zlib)
else()
  set(GDCM_ZLIB_LIBRARIES gdcmzlib)
endif()

if(GDCM_USE_SYSTEM_OPENSSL)
  find_package(OpenSSL2 REQUIRED)
endif()

# If user say so, then this is a requirement !
find_package(UUID QUIET)
if(UUID_FOUND)  
  set(GDCM_UUID_LIBRARIES ${UUID_LIBRARIES})
else()
  set(GDCM_UUID_LIBRARIES gdcmuuid)
endif()

if(GDCM_USE_SYSTEM_EXPAT)
  # If user say so, then this is a requirement !
  find_package(EXPAT REQUIRED)
  set(GDCM_EXPAT_LIBRARIES ${EXPAT_LIBRARIES})
else()
  set(GDCM_EXPAT_LIBRARIES gdcmexpat)
endif()


#-----------------------------------------------------------------------------
option(GDCM_BUILD_EXAMPLES "Build GDCM examples." OFF)
set(BUILD_EXAMPLES ${GDCM_BUILD_EXAMPLES})

#-----------------------------------------------------------------------------
# Add the testing directories
option(GDCM_BUILD_TESTING "Build testing." ${GDCM_BUILD_TESTING_DEFAULT})
set(BUILD_TESTING ${GDCM_BUILD_TESTING} CACHE BOOL "" FORCE)

#-----------------------------------------------------------------------------
# Python install
#FIND_PACKAGE(PythonInterp REQUIRED)
#MACRO(GET_PYTHON_SITE_PACKAGE dir)
#  EXECUTE_PROCESS(
#  	COMMAND ${PYTHON_EXECUTABLE} "-c" "from distutils import sysconfig; print sysconfig.get_python_lib()"
#  	#WORKING_DIRECTORY @LIBRARY_OUTPUT_PATH@
#  	RESULT_VARIABLE import_res
#  	OUTPUT_VARIABLE import_output
#  	ERROR_VARIABLE  import_error
#    OUTPUT_STRIP_TRAILING_WHITESPACE
#  )
#  #set(dir ${import_output})
#ENDMACRO(GET_PYTHON_SITE_PACKAGE)
#
#
#GET_PYTHON_SITE_PACKAGE(python_site_package)
#if(import_output)
#STRING(LENGTH ${import_output} len)
## let's remove the "/usr/lib" part...
#MATH(EXPR fileend "${len} - 9") 
#STRING(SUBSTRING ${import_output} 9 ${fileend} dummy1)
#if(UNIX)
#  set(python_site_package ${dummy1})
#  MESSAGE(${python_site_package})
#endif()
#endif()

# On unix one have: "python2.4/site-packages"
# while on Win32: "c:/Python24/Lib/site-packages/"
# give up for now and place python modules stuff in a general 'python' subdir

# Typical runtime env should be then
# (assuming CMAKE_INSTALL_PREFIX:PATH=/tmp/local)
# One would do:
#   export PYTHONPATH=/tmp/local/lib/python/site-packages/gdcm-2.1
#   export LD_LIBRARY_PATH=/tmp/local/lib/
#   python
#   > import gdcm


#-----------------------------------------------------------------------------
# Wrapping
OPTION(GDCM_WRAP_PYTHON "build python wrapping" OFF)
if(GDCM_BUILD_WRAPPING)
  MESSAGE(STATUS "GDCM_BUILD_WRAPPING option is deprecate, please specify explicitely which target language to wrap")
  set(GDCM_WRAP_PYTHON ON CACHE BOOL "(deprecated) build python wrapping" FORCE)
endif()
OPTION(GDCM_WRAP_PHP "php wrapping (experimental !)" OFF)
OPTION(GDCM_WRAP_JAVA "build java wrapping" OFF)
OPTION(GDCM_WRAP_CSHARP "build csharp wrapping" OFF)
MARK_AS_ADVANCED(GDCM_WRAP_PHP) #GDCM_WRAP_JAVA) # GDCM_WRAP_CSHARP)
MARK_AS_ADVANCED(GDCM_USE_RLE)
MARK_AS_ADVANCED(GDCM_USE_ACTIVIZ)
MARK_AS_ADVANCED(GDCM_TEST_BOOSTRAP)
MARK_AS_ADVANCED(GDCM_USE_JPEGLS)
if(GDCM_WRAP_CSHARP)
    find_package(CSharp REQUIRED)
    include(${CSharp_USE_FILE})
    #enable_language(CSharp)
endif()

set(GDCM_LIBRARY_DIR ${LIBRARY_OUTPUT_PATH}/${CMAKE_CFG_INTDIR})
set(GDCM_EXECUTABLE_DIR ${EXECUTABLE_OUTPUT_PATH}/${CMAKE_CFG_INTDIR})

add_subdirectory(Wrapping)
if(GDCM_WRAP_CSHARP)
  add_subdirectory(Wrapping/Csharp)
endif()

# After Wrapping please
if(BUILD_EXAMPLES)
  add_subdirectory(Examples)
endif()

#-----------------------------------------------------------------------------
# Special CMake Module required when doing Python Testing
if(BUILD_TESTING AND GDCM_WRAP_PYTHON)
  INCLUDE(${GDCM_SOURCE_DIR}/CMake/UsePythonTest.cmake)
endif()

# Special CMake Module required when doing C# Testing
if(BUILD_TESTING AND GDCM_WRAP_CSHARP)
  INCLUDE(${GDCM_SOURCE_DIR}/CMake/UseCSharpTest.cmake)
endif()

# Special CMake Module required when doing Java Testing
if(BUILD_TESTING AND GDCM_WRAP_JAVA)
  INCLUDE(${GDCM_SOURCE_DIR}/CMake/UseJavaTest.cmake)
endif()

#-----------------------------------------------------------------------------
# Need pthread for the following class:
CHECK_INCLUDE_FILE("pthread.h" CMAKE_HAVE_PTHREAD_H)

# Big endian thing:
include(${CMAKE_ROOT}/Modules/TestBigEndian.cmake)
TEST_BIG_ENDIAN(GDCM_WORDS_BIGENDIAN)

add_subdirectory(Utilities)
add_subdirectory(Source)
  
if(BUILD_TESTING)
  CONFIGURE_FILE(${GDCM_SOURCE_DIR}/CMake/CTestCustom.ctest.in
      ${GDCM_BINARY_DIR}/CMake/CTestCustom.ctest @ONLY)
  FILE(WRITE ${GDCM_BINARY_DIR}/CTestCustom.cmake
    "INCLUDE(\"${GDCM_BINARY_DIR}/CMake/CTestCustom.ctest\")\n")
  MARK_AS_ADVANCED(DART_TESTING_TIMEOUT)
  ENABLE_TESTING()
  INCLUDE(CTest)
  add_subdirectory(Testing)
  if(NOT GDCM_DATA_ROOT)
    # http://gdcm.sourceforge.net/wiki/index.php/General_questions#What_is_gdcmData_.3F
    MESSAGE(FATAL_ERROR "If you want to build the test suite, you must set the path to GDCM_DATA_ROOT (advanced option); if you don't want, disable GDCM_BUILD_TESTING (advanced option) .")
  endif()
endif()


#-----------------------------------------------------------------------------
OPTION(GDCM_DOCUMENTATION "Build source documentation using doxygen." OFF)
if(GDCM_DOCUMENTATION)
  OPTION(GDCM_PDF_DOCUMENTATION "Build source doxygen using doxygen as pdf" ON)
  MARK_AS_ADVANCED(GDCM_PDF_DOCUMENTATION)
endif()


#-----------------------------------------------------------------------------
OPTION(GDCM_USE_VTK "vtk bridge ?" OFF)
if(GDCM_USE_VTK AND GDCM_WRAP_CSHARP)
  OPTION(GDCM_USE_ACTIVIZ "vtk/Activiz bridge ?" OFF)
endif()

if(GDCM_USE_VTK)
  add_subdirectory(Utilities/VTK)
endif()

#-----------------------------------------------------------------------------
OPTION(GDCM_USE_ITK "itk bridge ?" OFF)
MARK_AS_ADVANCED(GDCM_USE_ITK)
if(GDCM_USE_ITK)
  MESSAGE(FATAL_ERROR "Do not use, instead prefer: ITK_USE_SYSTEM_GDCM, that was added after ITK 3.8")
  add_subdirectory(Utilities/Insight)
endif()

#-----------------------------------------------------------------------------
OPTION(GDCM_USE_WXWIDGETS "wxWidgets bridge ?" OFF)
MARK_AS_ADVANCED(GDCM_USE_WXWIDGETS)
if(GDCM_USE_WXWIDGETS)
  add_subdirectory(Utilities/wxWidgets)
endif()

#-----------------------------------------------------------------------------
OPTION(GDCM_BUILD_APPLICATIONS "apps ?" OFF)
set(BUILD_APPLICATIONS ${GDCM_BUILD_APPLICATIONS})
if(BUILD_APPLICATIONS)
  add_subdirectory(Applications)
endif()

#-----------------------------------------------------------------------------
# CPack stuff
if(EXISTS "${CMAKE_ROOT}/Modules/CPack.cmake")
  if(EXISTS "${CMAKE_ROOT}/Modules/InstallRequiredSystemLibraries.cmake")
    set(CMAKE_INSTALL_MFC_LIBRARIES 0)
    set(CMAKE_INSTALL_DEBUG_LIBRARIES 0)
    INCLUDE(${CMAKE_ROOT}/Modules/InstallRequiredSystemLibraries.cmake)
  endif()

  set(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${GDCM_PACKAGE_DESCRIPTION_SUMMARY})
  set(CPACK_PACKAGE_VENDOR "GDCM")
  set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_BINARY_DIR}/Copyright.txt")
  set(CPACK_RESOURCE_FILE_LICENSE    "${CMAKE_CURRENT_BINARY_DIR}/Copyright.txt")
  set(CPACK_PACKAGE_VERSION_MAJOR "${GDCM_VERSION_MAJOR}")
  set(CPACK_PACKAGE_VERSION_MINOR "${GDCM_VERSION_MINOR}")
  set(CPACK_PACKAGE_VERSION_PATCH "${GDCM_BUILD_VERSION}")
  set(CPACK_PACKAGE_INSTALL_DIRECTORY "GDCM ${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}")
  set(CPACK_SOURCE_PACKAGE_FILE_NAME "gdcm-${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}")

  #set(CPACK_PACKAGE_INSTALL_DIRECTORY "CMake ${CMake_VERSION_MAJOR}.${CMake_VERSION_MINOR}")
  if(WIN32 AND NOT UNIX)
    #STRING(REGEX REPLACE "/" "\\\\\\\\" CPACK_PACKAGE_ICON "${CMAKE_CURRENT_SOURCE_DIR}/Utilities/Release/GDCMInstall.bmp")

    # There is a bug in NSI that does not handle full unix paths properly. Make
    # sure there is at least one set of four (4) backlasshes.
    #set(CPACK_PACKAGE_ICON "${CMake_SOURCE_DIR}/Utilities/Release\\\\InstallIcon.bmp")
    set(CPACK_NSIS_INSTALLED_ICON_NAME "bin\\\\gdcmviewer.exe")
    set(CPACK_NSIS_DISPLAY_NAME "${CPACK_PACKAGE_INSTALL_DIRECTORY}")
    set(CPACK_NSIS_HELP_LINK "http://gdcm.sourceforge.net")
    set(CPACK_NSIS_URL_INFO_ABOUT "http://gdcm.sourceforge.net")
    set(CPACK_NSIS_MODIFY_PATH ON)
    if(${CMAKE_INSTALL_PREFIX} MATCHES ${CPACK_PACKAGE_INSTALL_DIRECTORY})
    else()
    STRING(REPLACE ${PROJECT_NAME} ${CPACK_PACKAGE_INSTALL_DIRECTORY} dummy ${CMAKE_INSTALL_PREFIX} )
    set(CMAKE_INSTALL_PREFIX ${dummy} CACHE PATH "" FORCE)
    endif()
    
  else()
    # http://www.vtk.org/Wiki/CMake:CPackConfiguration
    # List of files to be stripped. Starting with CMake 2.6.0 CPACK_STRIP_FILES will be a boolean variable which enables
    # stripping of all files (a list of files evaluates to TRUE in CMake, so this change is compatible).
    set(CPACK_STRIP_FILES "bin/gdcmdump;bin/gdcmconv;bin/gdcmscanner;bin/gdcminfo;bin/gdcmraw;bin/gdcmimg;bin/gdcmtar")
    set(CPACK_SOURCE_STRIP_FILES "")
    set(CPACK_PACKAGE_EXECUTABLES "gdcmviewer" "VIEWER")

  endif()

  # cygwin stff also copied from cmake
  #if(NOT DEFINED CPACK_PACKAGE_FILE_NAME)
  #  # if the CPACK_PACKAGE_FILE_NAME is not defined by the cache
  #  # default to source package - system, on cygwin system is not
  #  # needed
  #  if(CYGWIN)
  #    set(CPACK_PACKAGE_FILE_NAME "${CPACK_SOURCE_PACKAGE_FILE_NAME}")
  #  else()
  #    set(CPACK_PACKAGE_FILE_NAME
  #      "${CPACK_SOURCE_PACKAGE_FILE_NAME}-${CPACK_SYSTEM_NAME}")
  #  endif()
  #endif()

  #Cygwin stuff copied from cmake
  if(NOT DEFINED CPACK_SYSTEM_NAME)
    # make sure package is not Cygwin-unknown, for Cygwin just
    # cygwin is good for the system name
    if("${CMAKE_SYSTEM_NAME}" STREQUAL "CYGWIN")
      set(CPACK_SYSTEM_NAME Cygwin)
    else()
      #set(CMAKE_SYSTEM_PROCESSOR "x86_64")
      #set(CPACK_GENERATOR "TGZ;TBZ2")
      #set(CPACK_SOURCE_GENERATOR "TGZ;TBZ2")
      set(CPACK_SYSTEM_NAME ${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR})
    endif()
  endif()

  # Need to set the architecture for debian package
  set(CPACK_PACKAGE_CONTACT ${GDCM_PACKAGE_CONTACT})
  set(CPACK_DEBIAN_PACKAGE_DEPENDS "libc6, libstdc++6 (>= 4.0.2-4), libuuid1, zlib1g (>= 1:1.2.1), libgcc1 (>= 1:4.0.2), libexpat1, swig") # bug: missing dep to python...
  set(CPACK_DEBIAN_PACKAGE_SUGGESTS "dcmtk")
  set(CPACK_SOURCE_IGNORE_FILES "/debian/" "/CVS/" "/\\\\.svn/" "TODO" ".NoDartCoverage")
  set(CPACK_IGNORE_FILES ${CPACK_SOURCE_IGNORE_FILES})

  # List executables
  #set(CPACK_PACKAGE_EXECUTABLES "gdcmviewer" "VIEWER")
  if(CYGWIN)
    set(CPACK_CYGWIN_PATCH_NUMBER 1)
    set(CPACK_CYGWIN_BUILD_SCRIPT
    "${GDCM_BINARY_DIR}/@CPACK_PACKAGE_FILE_NAME@-@CPACK_CYGWIN_PATCH_NUMBER@.sh")
    set(CPACK_CYGWIN_PATCH_FILE
  "${GDCM_BINARY_DIR}/@CPACK_PACKAGE_FILE_NAME@-@CPACK_CYGWIN_PATCH_NUMBER@.patch")
    CONFIGURE_FILE(${GDCM_SOURCE_DIR}/CMake/Release/cygwin-patch.diff.in ${CPACK_CYGWIN_PATCH_FILE})
    CONFIGURE_FILE(${GDCM_SOURCE_DIR}/CMake/Release/cygwin-package.sh.in ${CPACK_CYGWIN_BUILD_SCRIPT})
  endif()

  # Tell CPack all of the components to install. The "ALL"
  # refers to the fact that this is the set of components that
  # will be included when CPack is instructed to put everything
  # into the binary installer (the default behavior).
  if(GDCM_USE_VTK)
    set(CPACK_COMPONENTS_ALL Applications Libraries Headers VTKApplications VTKLibraries VTKHeaders PythonModule VTKPythonModule CSharpModule VTKCSharpModule)
  else()
    set(CPACK_COMPONENTS_ALL Applications Libraries Headers PythonModule CSharpModule)
  endif()
  
  # Set the displayed names for each of the components to install.
  # These will be displayed in the list of components inside the installer.
  set(CPACK_COMPONENT_APPLICATIONS_DISPLAY_NAME "GDCM Applications")
  set(CPACK_COMPONENT_LIBRARIES_DISPLAY_NAME "GDCM Libraries")
  set(CPACK_COMPONENT_HEADERS_DISPLAY_NAME "GDCM C/C++ Headers")
  set(CPACK_COMPONENT_PYTHONMODULE_DISPLAY_NAME "GDCM Python Module")
  set(CPACK_COMPONENT_CSHARPMODULE_DISPLAY_NAME "GDCM C# Module")
  if(GDCM_USE_VTK)
    set(CPACK_COMPONENT_VTKAPPLICATIONS_DISPLAY_NAME "VTK/GDCM Applications")
    set(CPACK_COMPONENT_VTKLIBRARIES_DISPLAY_NAME "VTK/GDCM Libraries")
    set(CPACK_COMPONENT_VTKHEADERS_DISPLAY_NAME "VTK/GDCM C/C++ Headers")
    set(CPACK_COMPONENT_VTKPYTHONMODULE_DISPLAY_NAME "VTK/GDCM Python Module")
    set(CPACK_COMPONENT_VTKCSHARPMODULE_DISPLAY_NAME "VTK/GDCM C# Module")
  endif()
  
  # Provide descriptions for each of the components to install.
  # When the user hovers the mouse over the name of a component,
  # the description will be shown in the "Description" box in the
  # installer. If no descriptions are provided, the "Description"
  # box will be removed.
  set(CPACK_COMPONENT_APPLICATIONS_DESCRIPTION
    "Command line applications that uses GDCM: gdcmconv, gdcmdump, gdcminfo, gdcmscanner, gdcmimg, gdcmanon")
  set(CPACK_COMPONENT_LIBRARIES_DESCRIPTION
    "Libraries used to build programs with GDCM")
  set(CPACK_COMPONENT_HEADERS_DESCRIPTION
    "C/C++ header files for use with GDCM")
  set(CPACK_COMPONENT_PYTHONMODULE_DESCRIPTION
    "Python Module for GDCM")
  set(CPACK_COMPONENT_CSHARPMODULE_DESCRIPTION
    "C# Module for GDCM")
  if(GDCM_USE_VTK)
    set(CPACK_COMPONENT_VTKAPPLICATIONS_DESCRIPTION
      "Command line applications that uses GDCM: gdcmviewer & gdcm2vtk")
    set(CPACK_COMPONENT_VTKLIBRARIES_DESCRIPTION
      "Libraries used to build programs with VTK/GDCM")
    set(CPACK_COMPONENT_VTKHEADERS_DESCRIPTION
      "C/C++ header files for use with VTK/GDCM")
    set(CPACK_COMPONENT_VTKPYTHONMODULE_DESCRIPTION
      "Python Module for VTK/GDCM")
    set(CPACK_COMPONENT_VTKCSHARPMODULE_DESCRIPTION
      "C# Module for VTK/GDCM")
  endif()


  # Put the components into two different groups: "Runtime" and "Development"
  set(CPACK_COMPONENT_APPLICATIONS_GROUP "Runtime")
  set(CPACK_COMPONENT_PYTHONMODULE_GROUP "Development")
  set(CPACK_COMPONENT_CSHARPMODULE_GROUP "Development")
  set(CPACK_COMPONENT_LIBRARIES_GROUP "Development")
  set(CPACK_COMPONENT_HEADERS_GROUP "Development")
  if(GDCM_USE_VTK)
  set(CPACK_COMPONENT_VTKAPPLICATIONS_GROUP "Runtime")
  set(CPACK_COMPONENT_VTKPYTHONMODULE_GROUP "Development")
  set(CPACK_COMPONENT_VTKCSHARPMODULE_GROUP "Development")
  set(CPACK_COMPONENT_VTKLIBRARIES_GROUP "Development")
  set(CPACK_COMPONENT_VTKHEADERS_GROUP "Development")
  endif()
  # Expand the "Development" group by default, since we have so few components.
  # Also, provide this group with a description.
  set(CPACK_COMPONENT_GROUP_DEVELOPMENT_EXPANDED ON)
  set(CPACK_COMPONENT_GROUP_DEVELOPMENT_DESCRIPTION
    "All of the tools you'll ever need to develop software using GDCM")
  
  # It doesn't make sense to install the headers without the libraries
  # (because you could never use the headers!), so make the headers component
  # depend on the libraries component.
  set(CPACK_COMPONENT_HEADERS_DEPENDS Libraries)
  set(CPACK_COMPONENT_APPLICATIONS_DEPENDS Libraries)
  set(CPACK_COMPONENT_PYTHONMODULE_DEPENDS Libraries)
  set(CPACK_COMPONENT_CSHARPMODULE_DEPENDS Libraries)
  if(GDCM_USE_VTK)
  set(CPACK_COMPONENT_VTKHEADERS_DEPENDS VTKLibraries)
  set(CPACK_COMPONENT_VTKLIBRARIES_DEPENDS Libraries)
  set(CPACK_COMPONENT_VTKAPPLICATIONS_DEPENDS VTKLibraries)
  set(CPACK_COMPONENT_VTKPYTHONMODULE_DEPENDS VTKLibraries)
  set(CPACK_COMPONENT_VTKCSHARPMODULE_DEPENDS VTKLibraries)
  endif()
  
  # Create two installation types with pre-selected components.
  # The "Developer" installation has just the library and headers,
  # while the "Full" installation has everything.
  set(CPACK_ALL_INSTALL_TYPES Full Developer)
  set(CPACK_INSTALL_TYPE_FULL_DISPLAY_NAME "Everything")
  set(CPACK_COMPONENT_LIBRARIES_INSTALL_TYPES Developer Full)
  set(CPACK_COMPONENT_HEADERS_INSTALL_TYPES Developer Full)
  set(CPACK_COMPONENT_APPLICATIONS_INSTALL_TYPES Full)
  set(CPACK_COMPONENT_PYTHONMODULE_INSTALL_TYPES Developer Full)
  set(CPACK_COMPONENT_CSHARPMODULE_INSTALL_TYPES Developer Full)
  if(GDCM_USE_VTK)
  set(CPACK_COMPONENT_VTKLIBRARIES_INSTALL_TYPES Developer Full)
  set(CPACK_COMPONENT_VTKHEADERS_INSTALL_TYPES Developer Full)
  set(CPACK_COMPONENT_VTKAPPLICATIONS_INSTALL_TYPES Full)
  set(CPACK_COMPONENT_VTKPYTHONMODULE_INSTALL_TYPES Developer Full)
  set(CPACK_COMPONENT_VTKCSHARPMODULE_INSTALL_TYPES Developer Full)
  endif()

  INCLUDE(CPack)

endif()

#-----------------------------------------------------------------------------
# we need to link against CoreFoundation so that we can use CFBundle to get the executable path.
if(APPLE)
  find_library(COREFOUNDATION_LIBRARY CoreFoundation)
endif()

#-----------------------------------------------------------------------------
# Need to be the last operation:
set(GDCM_INCLUDE_PATH
  "${GDCM_SOURCE_DIR}/Source/Common"
  "${GDCM_BINARY_DIR}/Source/Common"
  "${GDCM_SOURCE_DIR}/Source/DataStructureAndEncodingDefinition"
  "${GDCM_SOURCE_DIR}/Source/MediaStorageAndFileFormat"
  "${GDCM_SOURCE_DIR}/Source/DataDictionary"
  "${GDCM_SOURCE_DIR}/Source/InformationObjectDefinition"
  #"${GDCM_SOURCE_DIR}/Utilities"
  #"${GDCM_BINARY_DIR}/Utilities/openjpeg"
  )
if(MSVC)
  set(GDCM_INCLUDE_PATH
    ${GDCM_INCLUDE_PATH}
    "${GDCM_SOURCE_DIR}/Utilities/C99"
  )
endif()
if(GDCM_USE_VTK)
    set(GDCM_INCLUDE_PATH
      ${GDCM_INCLUDE_PATH}
      "${GDCM_SOURCE_DIR}/Utilities/VTK"
      )
endif()

# Add interface library to collect all generated targets into one
add_library(gdcm INTERFACE)
target_link_libraries(gdcm INTERFACE gdcmCommon gdcmCWRAPPER
    gdcmDICT gdcmDSED gdcmIOD gdcmMSFF)
if(NOT GDCM_USE_SYSTEM_OPENJPEG)
    target_link_libraries(gdcm INTERFACE gdcmopenjpeg) 
endif()
if(NOT GDCM_USE_SYSTEM_ZLIB)
    target_link_libraries(gdcm INTERFACE gdcmzlib) 
endif()
if(NOT UUID_FOUND)
    target_link_libraries(gdcm INTERFACE gdcmuuid) 
endif()
if(NOT GDCM_USE_SYSTEM_EXPAT)
    target_link_libraries(gdcm INTERFACE gdcmexpat) 
endif()
install(TARGETS gdcm 
    EXPORT gdcm-abi-config
    INCLUDES DESTINATION ${GDCM_INSTALL_INCLUDE_DIR})
install(EXPORT gdcm-abi-config
        DESTINATION ${GDCM_CMAKE_PACKAGE_DIR})
include(CMakePackageConfigHelpers)
WRITE_BASIC_PACKAGE_VERSION_FILE(${CMAKE_CURRENT_BINARY_DIR}/gdcm-abi-config-version.cmake
    COMPATIBILITY AnyNewerVersion)
install( FILES ${CMAKE_CURRENT_BINARY_DIR}/gdcm-abi-config-version.cmake
    DESTINATION ${GDCM_CMAKE_PACKAGE_DIR} )

