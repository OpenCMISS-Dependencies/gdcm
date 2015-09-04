# Wrapping and stuff

# Do jpeg (8,12, 16 lossly lossless). From ijg
if(NOT GDCM_USE_SYSTEM_LJPEG)
  set(JPEG_NAMESPACE "GDCMJPEG")
  set(JPEG_INSTALL_NO_LIBRARIES ${GDCM_INSTALL_NO_LIBRARIES})
  set(JPEG_INSTALL_BIN_DIR      ${GDCM_INSTALL_BIN_DIR})
  set(JPEG_INSTALL_LIB_DIR      ${GDCM_INSTALL_LIB_DIR})
  set(JPEG_INSTALL_INCLUDE_DIR  ${GDCM_INSTALL_INCLUDE_DIR})
  add_subdirectory(gdcmjpeg)
endif()

# Do expat
if(NOT GDCM_USE_SYSTEM_EXPAT)
  set(EXPAT_NAMESPACE "GDCMEXPAT")
  set(EXPAT_INSTALL_NO_LIBRARIES ${GDCM_INSTALL_NO_LIBRARIES})
  set(EXPAT_INSTALL_BIN_DIR      ${GDCM_INSTALL_BIN_DIR})
  set(EXPAT_INSTALL_LIB_DIR      ${GDCM_INSTALL_LIB_DIR})
  add_subdirectory(gdcmexpat)
endif()

# Do openjpeg (jpeg2000 implementation)
if(NOT GDCM_USE_SYSTEM_OPENJPEG)
  set(OPENJPEG_NAMESPACE "GDCMOPENJPEG")
  set(OPENJPEG_INSTALL_NO_LIBRARIES ${GDCM_INSTALL_NO_LIBRARIES})
  set(OPENJPEG_INSTALL_BIN_DIR      ${GDCM_INSTALL_BIN_DIR})
  set(OPENJPEG_INSTALL_LIB_DIR      ${GDCM_INSTALL_LIB_DIR})
  set(OPENJPEG_INSTALL_INCLUDE_DIR  ${GDCM_INSTALL_INCLUDE_DIR})
  add_subdirectory(gdcmopenjpeg)
endif()

# Do jpegls (JPEG-LS aka near lossless implementation)
if(GDCM_USE_JPEGLS)
  set(CHARLS_NAMESPACE "GDCMCHARLS")
  set(CHARLS_INSTALL_NO_LIBRARIES ${GDCM_INSTALL_NO_LIBRARIES})
  set(CHARLS_INSTALL_BIN_DIR      ${GDCM_INSTALL_BIN_DIR})
  set(CHARLS_INSTALL_LIB_DIR      ${GDCM_INSTALL_LIB_DIR})
  set(CHARLS_INSTALL_INCLUDE_DIR  ${GDCM_INSTALL_INCLUDE_DIR})
  add_subdirectory(gdcmcharls)
endif()

# Do md5
if(GDCM_BUILD_TESTING)
if(NOT GDCM_USE_SYSTEM_MD5)
  set(MD5_NAMESPACE "GDCMMD5")
  set(MD5_INSTALL_NO_LIBRARIES ${GDCM_INSTALL_NO_LIBRARIES})
  set(MD5_INSTALL_BIN_DIR      ${GDCM_INSTALL_BIN_DIR})
  set(MD5_INSTALL_LIB_DIR      ${GDCM_INSTALL_LIB_DIR})
  add_subdirectory(gdcmmd5)
endif()
endif()

# Do zlib
if(NOT GDCM_USE_SYSTEM_ZLIB)
  set(ZLIB_NAMESPACE "GDCMZLIB")
  set(ZLIB_INSTALL_NO_LIBRARIES ${GDCM_INSTALL_NO_LIBRARIES})
  set(ZLIB_INSTALL_BIN_DIR      ${GDCM_INSTALL_BIN_DIR})
  set(ZLIB_INSTALL_LIB_DIR      ${GDCM_INSTALL_LIB_DIR})
  add_subdirectory(gdcmzlib)
endif()

# Do polarssl
#if(NOT GDCM_USE_SYSTEM_POLARSSL)
#  set(POLARSSL_NAMESPACE "GDCMPOLARSSL")
#  set(POLARSSL_INSTALL_NO_LIBRARIES ${GDCM_INSTALL_NO_LIBRARIES})
#  set(POLARSSL_INSTALL_BIN_DIR      ${GDCM_INSTALL_BIN_DIR})
#  set(POLARSSL_INSTALL_LIB_DIR      ${GDCM_INSTALL_LIB_DIR})
#  add_subdirectory(gdcmpolarssl)
#endif()

# Do getopt
if(WIN32 AND NOT CYGWIN)
  set(GETOPT_NAMESPACE "GDCMGETOPT")
  set(GETOPT_INSTALL_NO_LIBRARIES ${GDCM_INSTALL_NO_LIBRARIES})
  set(GETOPT_INSTALL_BIN_DIR      ${GDCM_INSTALL_BIN_DIR})
  set(GETOPT_INSTALL_LIB_DIR      ${GDCM_INSTALL_LIB_DIR})
  add_subdirectory(getopt)
endif()

add_subdirectory(doxygen)

# you could be running mingw32 on linux in which case you do NOT want the gdcmuuid lib
if(NOT WIN32 AND NOT MINGW)
  if(NOT GDCM_USE_SYSTEM_UUID)
    set(UUID_NAMESPACE "GDCMUUID")
    set(UUID_INSTALL_NO_LIBRARIES ${GDCM_INSTALL_NO_LIBRARIES})
    set(UUID_INSTALL_BIN_DIR      ${GDCM_INSTALL_BIN_DIR})
    set(UUID_INSTALL_LIB_DIR      ${GDCM_INSTALL_LIB_DIR})
    add_subdirectory(gdcmuuid)
  endif()
endif()

if(GDCM_USE_PVRG)
  add_subdirectory(pvrg)
endif()

if(GDCM_USE_RLE)
  add_subdirectory(rle)
endif()

#if(NOT GDCM_INSTALL_NO_DEVELOPMENT)
##  FILE(GLOB header_files "*.h" "*.txx")
#  INSTALL(FILES 
##${header_files}
#gdcm_expat.h
##gdcm_md5.h # In an install tree there should not be the need for the md5 lib...
#gdcm_openjpeg.h
#gdcm_uuid.h
#gdcm_zlib.h
#    DESTINATION ${GDCM_INSTALL_INCLUDE_DIR} COMPONENT Headers
#  )
#endif()

