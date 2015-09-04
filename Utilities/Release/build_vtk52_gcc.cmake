CMAKE_MINIMUM_REQUIRED(VERSION 2.2)
###################################################################
# The values in this section must always be provided
###################################################################

FIND_PROGRAM(HOSTNAME NAMES hostname)
FIND_PROGRAM(UNAME NAMES uname)

# Get the build name and hostname
EXEC_PROGRAM(${HOSTNAME} ARGS OUTPUT_VARIABLE hostname)
STRING(REGEX REPLACE "[/\\\\+<> #]" "-" hostname "${hostname}")

MESSAGE("HOSTNAME: ${hostname}")
set(MAKE make)
set(MAKEOPTS )
SET (CTEST_UPDATE_COMMAND      "/mnt/kitware/bin-${hostname}/cvs")
if(EXISTS /opt/OpenSource/xcdroast-0.98/opt/make/bin/gmake)
  set(MAKE "/opt/OpenSource/xcdroast-0.98/opt/make/bin/gmake")
  set(MAKEOPTS "-j 2")
endif()
if(EXISTS /etc/debian_version)
  set(MAKE "/usr/bin/make")
  set(MAKEOPTS "-j 2")
endif()

set(c_compiler "cc")
if($ENV{CXX})
  MESSAGE("ENV: $ENV{CXX}")
  set(mycxx "$ENV{CXX}")
else()
  if("${hostname}" MATCHES "boston")
    set(mycxx "g++")
  endif()
  if("${hostname}" MATCHES "styx")
    set(mycxx "g++")
  endif()
endif()

if(mycxx)
  set(compiler "${mycxx}")
  set(full_compiler "${mycxx}")
else()
  set(compiler aCC)
  set(full_compiler "/opt/aCC/bin/aCC")
endif()
MACRO(getuname name flag)
  EXEC_PROGRAM("${UNAME}" ARGS "${flag}" OUTPUT_VARIABLE "${name}")
  STRING(REGEX REPLACE "[/\\\\+<> #]" "-" "${name}" "${${name}}")
  STRING(REGEX REPLACE "^(......|.....|....|...|..|.).*" "\\1" "${name}" "${${name}}")
ENDMACRO(getuname)

getuname(osname -s)
getuname(osver  -v)
getuname(osrel  -r)
getuname(cpu    -m)

set(BUILDNAME "${osname}${osver}${osrel}${cpu}-${compiler}")
set(SHORT_BUILDNAME "${osname}${cpu}-${compiler}")
MESSAGE("BUILDNAME: ${BUILDNAME}")

# this is the cvs module name that should be checked out
SET (CTEST_MODULE_NAME VTK)

# Settings:
set(CTEST_DASHBOARD_ROOT    "/tmp")
set(CTEST_SITE              "${hostname}")
set(CTEST_BUILD_NAME        "${SHORT_BUILDNAME}")
set(CTEST_TIMEOUT           "1500")

# CVS command and the checkout command
if(NOT EXISTS "${CTEST_DASHBOARD_ROOT}/${CTEST_MODULE_NAME}")
  set(CTEST_CHECKOUT_COMMAND     "\"${CTEST_UPDATE_COMMAND}\" -q -z3 -d:pserver:anoncvs@www.vtk.org:/cvsroot/VTK co -d ${CTEST_MODULE_NAME} -r VTK-5-2 ${CTEST_MODULE_NAME}")
endif()

# Set the generator and build configuration
set(CTEST_CMAKE_GENERATOR      "Unix Makefiles")
set(CTEST_BUILD_CONFIGURATION  "Release")

# Extra special variables
set(ENV{DISPLAY}             "")
set(ENV{CC}                  "${c_compiler}")
set(ENV{CXX}                 "${full_compiler}")

#----------------------------------------------------------------------------------
# Should not need to edit under this line
#----------------------------------------------------------------------------------

# if you do not want to use the default location for a 
# dashboard then set this variable to the directory
# the dashboard should be in
#MAKE_DIRECTORY("${CTEST_DASHBOARD_ROOT}")
# these are the the name of the source and binary directory on disk. 
# They will be appended to DASHBOARD_ROOT
set(CTEST_SOURCE_DIRECTORY  "${CTEST_DASHBOARD_ROOT}/${CTEST_MODULE_NAME}")
set(CTEST_BINARY_DIRECTORY  "${CTEST_SOURCE_DIRECTORY}-${CTEST_BUILD_NAME}")
set(CTEST_BUILD_COMMAND     "${MAKE}")
set(CTEST_NOTES_FILES       "${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}")

##########################################################################
# wipe the binary dir
MESSAGE("Remove binary directory...")
CTEST_EMPTY_BINARY_DIRECTORY(${CTEST_BINARY_DIRECTORY})

MESSAGE("CTest Directory: ${CTEST_DASHBOARD_ROOT}")
MESSAGE("Initial checkout: ${CTEST_CVS_CHECKOUT}")
MESSAGE("Initial cmake: ${CTEST_CMAKE_COMMAND}")
MESSAGE("CTest command: ${CTEST_COMMAND}")

# this is the initial cache to use for the binary tree, be careful to escape
# any quotes inside of this string if you use it
FILE(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" "
SITE:STRING=${hostname}
BUILDNAME:STRING=${SHORT_BUILDNAME}
DART_ROOT:PATH=
CVSCOMMAND:FILEPATH=${CTEST_UPDATE_COMMAND}
//Command used to build entire project from the command line.
MAKECOMMAND:STRING=${MAKE} -i ${MAKEOPTS}
//make program
CMAKE_MAKE_PROGRAM:FILEPATH=${MAKE}
DROP_METHOD:STRING=http
BUILD_SHARED_LIBS:BOOL=OFF
VTK_USE_RENDERING:BOOL=ON
VTK_USE_PARALLEL:BOOL=OFF
")

MESSAGE("Start dashboard...")
CTEST_START(Nightly)
MESSAGE("  Update")
CTEST_UPDATE(SOURCE "${CTEST_SOURCE_DIRECTORY}" RETURN_VALUE res)
MESSAGE("  Configure")
CTEST_CONFIGURE(BUILD "${CTEST_BINARY_DIRECTORY}" RETURN_VALUE res)
CTEST_READ_CUSTOM_FILES( "${CTEST_BINARY_DIRECTORY}" )
MESSAGE("  Build")
CTEST_BUILD(BUILD "${CTEST_BINARY_DIRECTORY}" RETURN_VALUE res)
#MESSAGE("  Test")
#CTEST_TEST(BUILD "${CTEST_BINARY_DIRECTORY}" RETURN_VALUE res)
MESSAGE("  Submit")
CTEST_SUBMIT(RETURN_VALUE res)
MESSAGE("  All done")
