# - find DCMTK libraries and applications
#

#  DCMTK_INCLUDE_DIR   - Directories to include to use DCMTK
#  DCMTK_LIBRARIES     - Files to link against to use DCMTK
#  DCMTK_FOUND         - If false, don't try to use DCMTK
#  DCMTK_DIR           - (optional) Source directory for DCMTK
#
# DCMTK_DIR can be used to make it simpler to find the various include
# directories and compiled libraries if you've just compiled it in the
# source tree. Just set it to the root of the tree where you extracted
# the source.
#
# Written for VXL by Amitha Perera.
# Upgraded for GDCM by Mathieu Malaterre.
# 
# For debian you need:
# sudo apt-get install libdcmtk1-dev dcmtk
#
#  Copyright (c) 2006-2009 Mathieu Malaterre <mathieu.malaterre@gmail.com>
#
#  Redistribution and use is allowed according to the terms of the New
#  BSD license.
#  For details see the accompanying COPYING-CMAKE-SCRIPTS file.
#

if( NOT DCMTK_FOUND )
  set( DCMTK_DIR "/usr/include/dcmtk/"
    CACHE PATH "Root of DCMTK source tree (optional)." )
  MARK_AS_ADVANCED( DCMTK_DIR )
endif()


FIND_PATH( DCMTK_config_INCLUDE_DIR osconfig.h
  ${DCMTK_DIR}/config/include
  ${DCMTK_DIR}/config
  ${DCMTK_DIR}/include
)

FIND_PATH( DCMTK_ofstd_INCLUDE_DIR ofstdinc.h
  ${DCMTK_DIR}/ofstd/include
  ${DCMTK_DIR}/ofstd
  ${DCMTK_DIR}/include/ofstd
)

FIND_LIBRARY( DCMTK_ofstd_LIBRARY ofstd
  ${DCMTK_DIR}/ofstd/libsrc
  ${DCMTK_DIR}/ofstd/libsrc/Release
  ${DCMTK_DIR}/ofstd/libsrc/Debug
  ${DCMTK_DIR}/ofstd/Release
  ${DCMTK_DIR}/ofstd/Debug
  ${DCMTK_DIR}/lib
)


FIND_PATH( DCMTK_dcmdata_INCLUDE_DIR dctypes.h
  ${DCMTK_DIR}/include/dcmdata
  ${DCMTK_DIR}/dcmdata
  ${DCMTK_DIR}/dcmdata/include
)

FIND_LIBRARY( DCMTK_dcmdata_LIBRARY dcmdata
  ${DCMTK_DIR}/dcmdata/libsrc
  ${DCMTK_DIR}/dcmdata/libsrc/Release
  ${DCMTK_DIR}/dcmdata/libsrc/Debug
  ${DCMTK_DIR}/dcmdata/Release
  ${DCMTK_DIR}/dcmdata/Debug
  ${DCMTK_DIR}/lib
)


FIND_PATH( DCMTK_dcmimgle_INCLUDE_DIR dcmimage.h
  ${DCMTK_DIR}/dcmimgle/include
  ${DCMTK_DIR}/dcmimgle
  ${DCMTK_DIR}/include/dcmimgle
)

FIND_LIBRARY( DCMTK_dcmimgle_LIBRARY dcmimgle
  ${DCMTK_DIR}/dcmimgle/libsrc
  ${DCMTK_DIR}/dcmimgle/libsrc/Release
  ${DCMTK_DIR}/dcmimgle/libsrc/Debug
  ${DCMTK_DIR}/dcmimgle/Release
  ${DCMTK_DIR}/dcmimgle/Debug
  ${DCMTK_DIR}/lib
)

#FIND_LIBRARY(DCMTK_imagedb_LIBRARY imagedb 
#  ${DCMTK_DIR}/imagectn/libsrc/Release
#  ${DCMTK_DIR}/imagectn/libsrc/
#  ${DCMTK_DIR}/imagectn/libsrc/Debug
#  )

FIND_LIBRARY(DCMTK_dcmnet_LIBRARY dcmnet 
  ${DCMTK_DIR}/dcmnet/libsrc/Release
  ${DCMTK_DIR}/dcmnet/libsrc/Debug
  ${DCMTK_DIR}/dcmnet/libsrc/
  )


if( DCMTK_config_INCLUDE_DIR )
if( DCMTK_ofstd_INCLUDE_DIR )
if( DCMTK_ofstd_LIBRARY )
if( DCMTK_dcmdata_INCLUDE_DIR )
if( DCMTK_dcmdata_LIBRARY )
if( DCMTK_dcmimgle_INCLUDE_DIR )
if( DCMTK_dcmimgle_LIBRARY )

  set( DCMTK_FOUND "YES" )
  set( DCMTK_INCLUDE_DIR
    ${DCMTK_config_INCLUDE_DIR}
    ${DCMTK_ofstd_INCLUDE_DIR}
    ${DCMTK_dcmdata_INCLUDE_DIR}
    ${DCMTK_dcmimgle_INCLUDE_DIR}
  )

  set( DCMTK_LIBRARIES
    ${DCMTK_dcmimgle_LIBRARY}
    ${DCMTK_dcmdata_LIBRARY}
    ${DCMTK_ofstd_LIBRARY}
    ${DCMTK_config_LIBRARY}
  )

  if(DCMTK_imagedb_LIBRARY)
   set( DCMTK_LIBRARIES
   ${DCMTK_LIBRARIES}
   ${DCMTK_imagedb_LIBRARY}
   )
  endif()

  if(DCMTK_dcmnet_LIBRARY)
   set( DCMTK_LIBRARIES
   ${DCMTK_LIBRARIES}
   ${DCMTK_dcmnet_LIBRARY}
   )
  endif()

  if( WIN32 )
    set( DCMTK_LIBRARIES ${DCMTK_LIBRARIES} netapi32 )
  endif()

endif()
endif()
endif()
endif()
endif()
endif()
endif()

FIND_PROGRAM(DCMTK_DCMDUMP_EXECUTABLE dcmdump
  ${DCMTK_DIR}/bin
  )

FIND_PROGRAM(DCMTK_DCMDJPEG_EXECUTABLE dcmdjpeg
  ${DCMTK_DIR}/bin
  )

FIND_PROGRAM(DCMTK_DCMDRLE_EXECUTABLE dcmdrle
  ${DCMTK_DIR}/bin
  )

MARK_AS_ADVANCED(
  DCMTK_DCMDUMP_EXECUTABLE
  DCMTK_DCMDJPEG_EXECUTABLE
  DCMTK_DCMDRLE_EXECUTABLE
  DCMTK_config_INCLUDE_DIR
  DCMTK_dcmdata_INCLUDE_DIR
  DCMTK_dcmdata_LIBRARY
  DCMTK_dcmimgle_INCLUDE_DIR
  DCMTK_dcmimgle_LIBRARY
  DCMTK_dcmnet_LIBRARY
  DCMTK_ofstd_INCLUDE_DIR
  DCMTK_ofstd_LIBRARY
  )

