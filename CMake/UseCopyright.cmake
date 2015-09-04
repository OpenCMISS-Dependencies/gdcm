# Handy macro to gather all copyright in a single file (to pass to cpack)
#
#  Copyright (c) 2006-2009 Mathieu Malaterre <mathieu.malaterre@gmail.com>
#
#  Redistribution and use is allowed according to the terms of the New
#  BSD license.
#  For details see the accompanying COPYING-CMAKE-SCRIPTS file.
#

MACRO(CREATE_COPYRIGHT_FILE name)
  # Always cleanup the file:
  FILE(WRITE ${name} "")
  set(COPYRIGHT_MODULE_FILENAME ${name})
ENDMACRO(CREATE_COPYRIGHT_FILE)

# Append copyright file
MACRO(APPEND_COPYRIGHT)
  # need to raise an error if COPYRIGHT_MODULE_FILENAME is not set...
  if(EXISTS ${COPYRIGHT_MODULE_FILENAME} )
    foreach(filename ${ARGN})
      FILE(READ ${filename} content)
      FILE(APPEND ${COPYRIGHT_MODULE_FILENAME} ${content})
    endforeach()
  endif()
ENDMACRO(APPEND_COPYRIGHT)


