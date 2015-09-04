#
#  Copyright (c) 2006-2009 Mathieu Malaterre <mathieu.malaterre@gmail.com>
#
#  Redistribution and use is allowed according to the terms of the New
#  BSD license.
#  For details see the accompanying COPYING-CMAKE-SCRIPTS file.
#

# Testing on Linux with:
# ActiViz.NET-5.4.0.455-Linux-x86_64-Personal

# Note:
# IMHO I cannot use FIND_LIBRARY on Linux because of the .dll extension...
# instead switch to FIND_FILE

FIND_FILE(ACTIVIZ_KITWARE_VTK_LIBRARY
  NAMES Kitware.VTK.dll
  PATHS /usr/lib /usr/local/lib
  "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Kitware\\ActiVizDotNet 5.2.1]/bin"
  $ENV{ACTIVIZ_ROOT}/bin
  )

FIND_FILE(ACTIVIZ_KITWARE_MUMMY_RUNTIME_LIBRARY
  NAMES Kitware.mummy.Runtime.dll
  PATHS /usr/lib /usr/local/lib
  "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Kitware\\ActiVizDotNet 5.2.1]/bin"
  $ENV{ACTIVIZ_ROOT}/bin
  )

if(ACTIVIZ_KITWARE_VTK_LIBRARY AND ACTIVIZ_KITWARE_MUMMY_RUNTIME_LIBRARY)
    set(ACTIVIZ_LIBRARIES ${ACTIVIZ_KITWARE_MUMMY_RUNTIME_LIBRARY} ${ACTIVIZ_KITWARE_VTK_LIBRARY})
    set(ACTIVIZ_FOUND "YES")
else()
  set(ACTIVIZ_FOUND "NO")
endif()


if(ACTIVIZ_FOUND)
   if(NOT ACTIVIZ_FIND_QUIETLY)
      MESSAGE(STATUS "Found ACTIVIZ: ${ACTIVIZ_LIBRARIES}")
   endif()
else()
   if(ACTIVIZ_FIND_REQUIRED)
      MESSAGE(FATAL_ERROR "Could not find ACTIVIZ library")
   endif()
endif()

MARK_AS_ADVANCED(
  ACTIVIZ_KITWARE_VTK_LIBRARY
  ACTIVIZ_KITWARE_MUMMY_RUNTIME_LIBRARY
  )
