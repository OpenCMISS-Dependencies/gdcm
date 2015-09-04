#
#  Copyright (c) 2006-2009 Mathieu Malaterre <mathieu.malaterre@gmail.com>
#
#  Redistribution and use is allowed according to the terms of the New
#  BSD license.
#  For details see the accompanying COPYING-CMAKE-SCRIPTS file.
#

FIND_PATH(LJPEG_INCLUDE_DIR ljpeg-62/jpeglib.h
/usr/local/include
/usr/include
)

FIND_LIBRARY(LJPEG8_LIBRARY
  NAMES jpeg8
  PATHS /usr/lib /usr/local/lib
  )
FIND_LIBRARY(LJPEG12_LIBRARY
  NAMES jpeg12
  PATHS /usr/lib /usr/local/lib
  )
FIND_LIBRARY(LJPEG16_LIBRARY
  NAMES jpeg16
  PATHS /usr/lib /usr/local/lib
  )

if(LJPEG8_LIBRARY AND LJPEG_INCLUDE_DIR)
    set(LJPEG_LIBRARIES ${LJPEG8_LIBRARY} ${LJPEG12_LIBRARY} ${LJPEG16_LIBRARY})
    set(LJPEG_INCLUDE_DIRS ${LJPEG_INCLUDE_DIR})
    set(LJPEG_FOUND "YES")
else()
  set(LJPEG_FOUND "NO")
endif()


if(LJPEG_FOUND)
   if(NOT LJPEG_FIND_QUIETLY)
      MESSAGE(STATUS "Found LJPEG: ${LJPEG_LIBRARIES}")
   endif()
else()
   if(LJPEG_FIND_REQUIRED)
      MESSAGE(FATAL_ERROR "Could not find LJPEG library")
   endif()
endif()

MARK_AS_ADVANCED(
  LJPEG_LIBRARIES
  LJPEG_INCLUDE_DIR
  )
