# Define the srcs for Media Storage And FileFormat
# MSFF
set(MSFF_SRCS
  gdcmAnonymizer.cxx
  gdcmDICOMDIRGenerator.cxx
  gdcmSpacing.cxx
  gdcmFileExplicitFilter.cxx
  gdcmFileDerivation.cxx
  gdcmImageFragmentSplitter.cxx
  gdcmTagPath.cxx
  gdcmSimpleSubjectWatcher.cxx
  gdcmAnonymizeEvent.cxx
  gdcmPixmap.cxx
  gdcmBitmap.cxx
  gdcmRescaler.cxx
  gdcmImageToImageFilter.cxx
  gdcmPixmapToPixmapFilter.cxx
  gdcmImageChangeTransferSyntax.cxx
  gdcmImageApplyLookupTable.cxx
  gdcmOrientation.cxx
  gdcmDataSetHelper.cxx
  gdcmImageChangePlanarConfiguration.cxx
  gdcmImageChangePhotometricInterpretation.cxx
  gdcmDirectionCosines.cxx
  gdcmSorter.cxx
  gdcmSerieHelper.cxx
  gdcmIPPSorter.cxx
  gdcmApplicationEntity.cxx
  gdcmDICOMDIR.cxx
  gdcmSpectroscopy.cxx
  gdcmEncapsulatedDocument.cxx
  gdcmSplitMosaicFilter.cxx
  gdcmFiducials.cxx
  gdcmWaveform.cxx
  gdcmPersonName.cxx
  gdcmIconImage.cxx
  gdcmUIDGenerator.cxx
  gdcmPrinter.cxx
  gdcmDictPrinter.cxx
  gdcmScanner.cxx
  gdcmPixmapReader.cxx
  gdcmImageReader.cxx
  gdcmPixmapWriter.cxx
  gdcmImageWriter.cxx
  gdcmStringFilter.cxx
  gdcmImageHelper.cxx
  gdcmValidate.cxx
  gdcmDumper.cxx
  gdcmImage.cxx
  gdcmImageConverter.cxx
  gdcmImageCodec.cxx
  gdcmJPEG12Codec.cxx
  gdcmRLECodec.cxx
  gdcmPDFCodec.cxx
  gdcmAudioCodec.cxx
  gdcmJPEG16Codec.cxx
  gdcmJPEG2000Codec.cxx
  gdcmJPEGLSCodec.cxx
  gdcmJPEG8Codec.cxx
  gdcmJPEGCodec.cxx
  gdcmPVRGCodec.cxx
  gdcmPNMCodec.cxx
  gdcmRAWCodec.cxx
  gdcmLookupTable.cxx
  gdcmOverlay.cxx
  gdcmCurve.cxx
  gdcmPhotometricInterpretation.cxx
  gdcmPixelFormat.cxx
  gdcmSegmentedPaletteColorLookupTable.cxx
  )

# Do the proper thing when building static...if only there was configured
# headers or def files instead
if(NOT BUILD_SHARED_LIBS)
  SET_SOURCE_FILES_PROPERTIES(gdcmJPEG2000Codec.cxx
                              PROPERTIES 
                              COMPILE_FLAGS -DOPJ_STATIC
                              )
endif()

if(${CMAKE_SYSTEM_NAME} STREQUAL "Linux" AND ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64" )
	SET_SOURCE_FILES_PROPERTIES(${MSFF_SRCS}
		PROPERTIES COMPILE_FLAGS "-fPIC")
endif()

# Add the include paths
INCLUDE_DIRECTORIES(
  "${GDCM_SOURCE_DIR}/Source/Common"
  "${GDCM_BINARY_DIR}/Source/Common"
  "${GDCM_SOURCE_DIR}/Source/DataStructureAndEncodingDefinition"
  "${GDCM_SOURCE_DIR}/Source/DataDictionary"
  "${GDCM_SOURCE_DIR}/Source/InformationObjectDefinition"
  ${CMAKE_CURRENT_SOURCE_DIR}

  # FIXME:
  "${GDCM_SOURCE_DIR}/Utilities"
  "${GDCM_BINARY_DIR}/Utilities"
  )

# CharLS
if(GDCM_USE_JPEGLS)
  #INCLUDE_DIRECTORIES("${GDCM_BINARY_DIR}/Utilities/gdcmcharls")
endif()

if(GDCM_USE_SYSTEM_OPENJPEG)
  INCLUDE_DIRECTORIES(${OPENJPEG_INCLUDE_DIRS} )
else()
  INCLUDE_DIRECTORIES(
  "${GDCM_BINARY_DIR}/Utilities/gdcmopenjpeg"
    )
endif()
if(GDCM_USE_SYSTEM_LJPEG)
  #MESSAGE(${LJPEG_INCLUDE_DIRS} )
  INCLUDE_DIRECTORIES(${LJPEG_INCLUDE_DIRS} )
endif()
if(NOT GDCM_USE_SYSTEM_ZLIB)
  INCLUDE_DIRECTORIES(
    "${GDCM_BINARY_DIR}/Utilities/gdcmzlib"
  )
endif()
if(GDCM_USE_SYSTEM_UUID)
  INCLUDE_DIRECTORIES(
    ${UUID_INCLUDE_DIR}
  )
  set(GDCMUUID ${UUID_LIBRARIES})
else()
  INCLUDE_DIRECTORIES(
    "${GDCM_BINARY_DIR}/Utilities/gdcmuuid" # uuid_mangle.h
  )
  set(GDCMUUID gdcmuuid)
endif()

ADD_LIBRARY(gdcmMSFF ${MSFF_SRCS})
SET_TARGET_PROPERTIES(gdcmMSFF PROPERTIES ${GDCM_LIBRARY_PROPERTIES})

# main libs:
TARGET_LINK_LIBRARIES(gdcmMSFF gdcmDSED gdcmDICT ${GDCM_LJPEG_LIBRARIES} ${GDCM_OPENJPEG_LIBRARIES})
if(GDCM_USE_JPEGLS)
  TARGET_LINK_LIBRARIES(gdcmMSFF gdcmcharls)
endif()

if(CMAKE_COMPILER_IS_GNUCXX AND MINGW)
  # I am getting:
# CMakeFiles/gdcmMSFF.dir/gdcmScanner.obj(.text$_ZN4gdcm6ReaderC1Ev[gdcm::Reader::Reader()]+0x3a):gdcmScanner.cxx: variable 'vtable for gdcm::Reader' can't be auto-imported. Please read the documentation for ld's --enable-auto-import for details.
# CMakeFiles/gdcmMSFF.dir/gdcmImageReader.obj(.text$_ZN4gdcm6ReaderC2Ev[gdcm::Reader::Reader()]+0x3a):gdcmImageReader.cxx: variable 'vtable for gdcm::Reader' can't be auto-imported. Please read the documentation for ld's --enable-auto-import for details.
# CMakeFiles/gdcmMSFF.dir/gdcmImageWriter.obj(.text$_ZN4gdcm6WriterC2Ev[gdcm::Writer::Writer()]+0x3a):gdcmImageWriter.cxx: variable 'vtable for gdcm::Writer' can't be auto-imported. Please read the documentation for ld's --enable-auto-import for details.

  SET_TARGET_PROPERTIES(gdcmMSFF PROPERTIES LINK_FLAGS "-Wl,--enable-runtime-pseudo-reloc")
endif()
#if(HAVE_UUIDCREATE)
if(WIN32)
  # For UuidCreate
  # http://msdn.microsoft.com/en-us/library/aa379205(VS.85).aspx
  TARGET_LINK_LIBRARIES(gdcmMSFF rpcrt4)
#endif()
else()
TARGET_LINK_LIBRARIES(gdcmMSFF ${GDCMUUID})
endif()
if(NOT GDCM_INSTALL_NO_LIBRARIES)
	INSTALL(TARGETS gdcmMSFF EXPORT gdcm-abi-config
    RUNTIME DESTINATION ${GDCM_INSTALL_BIN_DIR} COMPONENT Applications
    LIBRARY DESTINATION ${GDCM_INSTALL_LIB_DIR} COMPONENT Libraries ${NAMELINK_SKIP}
    ARCHIVE DESTINATION ${GDCM_INSTALL_LIB_DIR} COMPONENT Development
  )
  #INSTALL(TARGETS gdcmMSFF
  #  LIBRARY DESTINATION ${GDCM_INSTALL_LIB_DIR} COMPONENT Development ${NAMELINK_ONLY}
  #  )
endif()

if(NOT GDCM_INSTALL_NO_DEVELOPMENT)
  FILE(GLOB header_files "*.h" "*.txx")
  INSTALL(FILES ${header_files}
    DESTINATION ${GDCM_INSTALL_INCLUDE_DIR} COMPONENT Headers
  )
endif()
