# Define the tests for Media Storage and File Format
# MSFF
set(MSFF_TEST_SRCS
  TestAnonymizer
  TestAnonymizer2
  TestDataElementValueAsSQ
  TestSpacing
  TestFileExplicitFilter
  TestImageFragmentSplitter
  TestTagPath
  TestOrientation
  TestIconImage
  TestImageHelper
  TestImageToImageFilter
  TestImageChangeTransferSyntax
  TestImageChangePhotometricInterpretation
  #TestImageChangePhotometricInterpretation2 # does not compile on mingw...
  TestImageChangeTransferSyntax2
  TestImageChangeTransferSyntax3
  TestImageChangeTransferSyntax4
  # see below
  TestImageChangeTransferSyntax6
  TestImageChangeTransferSyntax7
  TestImageApplyLookupTable
  TestImageChangePlanarConfiguration
  TestCoder
  TestDecoder
  TestRescaler
  TestDumper
  TestDictPrinter
  TestApplicationEntity
  TestStringFilter
  TestUIDGenerator
  #TestUIDGenerator3
  TestPrinter
  TestPrint
  TestSorter
  TestImageReader
  TestDirectionCosines
  TestImageWriter
  TestImageWriter2
  TestCodec
  TestPDFCodec
  TestRLECodec
  TestAudioCodec
  TestImage
  TestPhotometricInterpretation
  TestLookupTable
  TestOverlay
  TestCurve
  TestPixelFormat
  TestPersonName
  TestImageCodec
  TestImageConverter
  TestJPEGCodec
  TestRAWCodec
  TestDICOMDIR
  TestWaveform
  TestFiducials
  TestEncapsulatedDocument
  TestSpectroscopy
  )

if(GDCM_DATA_ROOT)
  set(MSFF_TEST_SRCS
      ${MSFF_TEST_SRCS}
  TestScanner
  TestIPPSorter
  TestIPPSorter2
  TestCopyDataSet
      )
endif()

if(GDCM_USE_JPEGLS)
  set(MSFF_TEST_SRCS ${MSFF_TEST_SRCS}
    TestImageChangeTransferSyntax5
  )
endif()

if(CMAKE_HAVE_PTHREAD_H)
set(MSFF_TEST_SRCS ${MSFF_TEST_SRCS}
  TestUIDGenerator2
  )
endif()
if(GDCM_PIXEL_SPACING_DATA_ROOT)
  set(MSFF_TEST_SRCS
    ${MSFF_TEST_SRCS}
    TestImageReaderPixelSpacing
  )
endif()


# Add the include paths
INCLUDE_DIRECTORIES(
  "${GDCM_BINARY_DIR}/Source/Common"
  "${GDCM_SOURCE_DIR}/Source/Common"
  "${GDCM_SOURCE_DIR}/Testing/Source/Data"
  "${GDCM_BINARY_DIR}/Testing/Source/Data"
  "${GDCM_SOURCE_DIR}/Source/DataStructureAndEncodingDefinition"
  "${GDCM_SOURCE_DIR}/Source/DataDictionary"
  "${GDCM_SOURCE_DIR}/Source/MediaStorageAndFileFormat"
  )

CREATE_TEST_SOURCELIST(MSFFTests gdcmMSFFTests.cxx ${MSFF_TEST_SRCS})
ADD_EXECUTABLE(gdcmMSFFTests ${MSFFTests})
TARGET_LINK_LIBRARIES(gdcmMSFFTests gdcmMSFF)
if(CMAKE_HAVE_PTHREAD_H)
TARGET_LINK_LIBRARIES(gdcmMSFFTests pthread)
endif()

#Don't understand why I need that ??
set(GDCM_MSFF_TESTS "${EXECUTABLE_OUTPUT_PATH}/gdcmMSFFTests")

# Loop over files and create executables
foreach(name ${MSFF_TEST_SRCS})
  ADD_TEST(${name} ${GDCM_MSFF_TESTS} ${name})
endforeach()

# We can only run the dcmtk cross-checking test *only* after all the tests have run
# in particular once the TestWriter is done.
foreach(filename ${gdcm_data_filenames_glob})
  GET_FILENAME_COMPONENT(filename_name ${filename} NAME)
  STRING(REGEX MATCH ${filename_name} bad_dicom ${black_list_reader})
  if(NOT bad_dicom)
    if(GDCM_TEST_DCMTK)
      if(DCMTK_DCMDUMP_EXECUTABLE)
        # -M : load short tags
        # -dc: disable correction
        ADD_TEST("DCMDUMP-${filename_name}" ${DCMTK_DCMDUMP_EXECUTABLE} -M -dc
          "${GDCM_TEMP_DIRECTORY}/TestWriter/${filename_name}")
      endif()
    endif()
  endif()
endforeach()

# Repeat for dcdump
foreach(filename ${gdcm_data_filenames_glob})
  GET_FILENAME_COMPONENT(filename_name ${filename} NAME)
  STRING(REGEX MATCH ${filename_name} bad_dicom ${black_list_reader})
  if(NOT bad_dicom)
    if(GDCM_TEST_DICOM3TOOLS)
      if(DCDUMP_EXECUTABLE)
        ADD_TEST("DCDUMP-${filename_name}" "${DCDUMP_EXECUTABLE}"
          "${GDCM_TEMP_DIRECTORY}/TestWriter/${filename_name}")
      endif()
    endif()
  endif()
endforeach()

# There is a new test that compress all images using the jpeg compression alg:
# try to decompress them with dcmtk:
FILE(MAKE_DIRECTORY "${GDCM_TEMP_DIRECTORY}/TestImageChangeTransferSyntax/dcmdjpeg/")

foreach(filename ${gdcm_data_filenames_glob})
  GET_FILENAME_COMPONENT(filename_name ${filename} NAME)
  STRING(REGEX MATCH ${filename_name} bad_dicom ${black_list_reader})
  if(NOT bad_dicom)
    if(GDCM_TEST_DCMTK)
      if(DCMTK_DCMDJPEG_EXECUTABLE)
        ADD_TEST("DCMDJPEG-${filename_name}" ${DCMTK_DCMDJPEG_EXECUTABLE}
          "${GDCM_TEMP_DIRECTORY}/TestImageChangeTransferSyntax/${filename_name}"
          "${GDCM_TEMP_DIRECTORY}/TestImageChangeTransferSyntax/dcmdjpeg/${filename_name}")
        # Special handling of the DICOMDIR files:
        STRING(REGEX MATCH ${filename_name} is_dicomdir ${gdcm_data_dicomdir_filenames_glob})
        if(is_dicomdir)
          #MESSAGE("IS DICOMDIR ${filename_name}")
          SET_TESTS_PROPERTIES("DCMDJPEG-${filename_name}" PROPERTIES WILL_FAIL TRUE)
        endif()
      endif()
    endif()
  endif()
endforeach()

FILE(MAKE_DIRECTORY "${GDCM_TEMP_DIRECTORY}/TestImageChangeTransferSyntax3/dcmdrle/")

foreach(filename ${gdcm_data_filenames_glob})
  GET_FILENAME_COMPONENT(filename_name ${filename} NAME)
  STRING(REGEX MATCH ${filename_name} bad_dicom ${black_list_reader})
  if(NOT bad_dicom)
    if(GDCM_TEST_DCMTK)
      if(DCMTK_DCMDRLE_EXECUTABLE)
        ADD_TEST("DCMDRLE-${filename_name}" ${DCMTK_DCMDRLE_EXECUTABLE}
          "${GDCM_TEMP_DIRECTORY}/TestImageChangeTransferSyntax3/${filename_name}"
          "${GDCM_TEMP_DIRECTORY}/TestImageChangeTransferSyntax3/dcmdrle/${filename_name}")
        # Special handling of the DICOMDIR files:
        STRING(REGEX MATCH ${filename_name} is_dicomdir ${gdcm_data_dicomdir_filenames_glob})
        if(is_dicomdir)
          #MESSAGE("IS DICOMDIR ${filename_name}")
          SET_TESTS_PROPERTIES("DCMDRLE-${filename_name}" PROPERTIES WILL_FAIL TRUE)
        endif()
        # 
      endif()
    endif()
  endif()
endforeach()

# Need to SET_TESTS_PROPERTIES only *after* the loop is done (test need to have been declared first)
if(GDCM_TEST_DCMTK)
  if(DCMTK_DCMDJPEG_EXECUTABLE)
# No pixel data
  SET_TESTS_PROPERTIES("DCMDJPEG-ELSCINT1_PMSCT_RLE1.dcm" PROPERTIES WILL_FAIL TRUE)
# It is missing the very last pixel, so technically is illegal
  SET_TESTS_PROPERTIES("DCMDRLE-ALOKA_SSD-8-MONO2-RLE-SQ.dcm" PROPERTIES WILL_FAIL TRUE)
# No pixel data
  SET_TESTS_PROPERTIES("DCMDRLE-ELSCINT1_PMSCT_RLE1.dcm" PROPERTIES WILL_FAIL TRUE)
  endif()
endif()

