#
#  Copyright (c) 2006-2009 Mathieu Malaterre <mathieu.malaterre@gmail.com>
#
#  Redistribution and use is allowed according to the terms of the New
#  BSD license.
#  For details see the accompanying COPYING-CMAKE-SCRIPTS file.
#

FIND_PATH(POPPLER_INCLUDE_DIR poppler/poppler-config.h
/usr/local/include
/usr/include
)

FIND_LIBRARY(POPPLER_LIBRARY
  NAMES poppler
  PATHS /usr/lib /usr/local/lib
  )

if(POPPLER_LIBRARY AND POPPLER_INCLUDE_DIR)
    set(POPPLER_LIBRARIES ${POPPLER_LIBRARY})
    set(POPPLER_INCLUDE_DIRS ${POPPLER_INCLUDE_DIR} ${POPPLER_INCLUDE_DIR}/poppler)
    set(POPPLER_FOUND "YES")
else()
  set(POPPLER_FOUND "NO")
endif()


if(POPPLER_FOUND)
   if(NOT POPPLER_FIND_QUIETLY)
      MESSAGE(STATUS "Found POPPLER: ${POPPLER_LIBRARIES}")
   endif()
else()
   if(POPPLER_FIND_REQUIRED)
      MESSAGE(FATAL_ERROR "Could not find POPPLER library")
   endif()
endif()

MARK_AS_ADVANCED(
  POPPLER_LIBRARY
  POPPLER_INCLUDE_DIR
  )
