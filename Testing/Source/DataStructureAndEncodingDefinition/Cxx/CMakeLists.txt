# Define the tests for Data Structure and Encoding Definitions
# DSED
set(DSED_TEST_SRCS
	TestAttribute
  TestCodeString
	TestAttribute1
	TestAttribute7
  #TestReadPatientName
  TestLO
  TestCSAElement
  #TestByteBuffer
  #TestByteValue
  TestPreamble
  TestLCNumeric
  TestReader
  TestWriter
  TestWriter2
  TestCSAHeader
  TestByteSwapFilter
  TestBasicOffsetTable
  TestComposite
  #TestDataElement
  TestDataSet
  TestVRDS
  TestVRLT
  TestVRUI
  TestElement
  #TestExplicitDataElement
  TestFileMetaInformation
  TestFile
  TestFileSet
  TestFragment
  #TestImplicitDataElement
  TestItem
  #TestParser
  TestSequenceOfFragments
  TestSequenceOfItems
  TestTag
  TestPrivateTag
  TestTransferSyntax
  TestMediaStorage
  TestVL
  TestVM
  TestVR
  #TestValue
  #TestTorture
  TestElement2
  TestElement4
  TestElement5
  )

if(GDCM_DATA_ROOT)
set(DSED_TEST_SRCS
  ${DSED_TEST_SRCS}
  TestReader2
	TestAttribute8
  )
endif()

CHECK_INCLUDE_FILE("fcntl.h"      CMAKE_HAVE_FCNTL_H)
CHECK_INCLUDE_FILE("sched.h"      CMAKE_HAVE_SHED_H)
CHECK_INCLUDE_FILE("sys/mman.h"   CMAKE_HAVE_SYS_MMAN_H)

# Need mmap
if(CMAKE_HAVE_SYS_MMAN_H)
  set(DSED_TEST_SRCS ${DSED_TEST_SRCS}
    TestReader3
  )
endif()

OPTION(SHARED_PTR "shared_ptr" OFF)
MARK_AS_ADVANCED(SHARED_PTR)
if(SHARED_PTR)
  set(DSED_TEST_SRCS
    ${DSED_TEST_SRCS}
    TestCopyValue
    )
endif()

# Add the include paths
INCLUDE_DIRECTORIES(
  "${GDCM_BINARY_DIR}/Source/Common"
  "${GDCM_SOURCE_DIR}/Source/Common"
  "${GDCM_SOURCE_DIR}/Source/DataDictionary"
  "${GDCM_SOURCE_DIR}/Source/DataStructureAndEncodingDefinition"
  "${GDCM_BINARY_DIR}/Utilities/zlib"
  "${GDCM_SOURCE_DIR}/Utilities"
  )

CREATE_TEST_SOURCELIST(DSEDTests gdcmDSEDTests.cxx ${DSED_TEST_SRCS})
ADD_EXECUTABLE(gdcmDSEDTests ${DSEDTests})
TARGET_LINK_LIBRARIES(gdcmDSEDTests gdcmDSED)
if(CMAKE_COMPILER_IS_GNUCXX AND MINGW)
  SET_TARGET_PROPERTIES( gdcmDSEDTests PROPERTIES LINK_FLAGS "-Wl,--allow-multiple-definition")
endif()

#Don't understand why I need that ??
set(GDCM_DSED_TESTS "${EXECUTABLE_OUTPUT_PATH}/gdcmDSEDTests")

# Loop over files and create executables
foreach(name ${DSED_TEST_SRCS})
  ADD_TEST(${name} ${GDCM_DSED_TESTS} ${name})
endforeach()

# FIXME
#ADD_EXECUTABLE(TestAttribute2 TestAttribute2.cxx)
#ADD_EXECUTABLE(TestAttribute3 TestAttribute3.cxx)
#ADD_EXECUTABLE(TestAttribute4 TestAttribute4.cxx)
#ADD_EXECUTABLE(TestAttribute5 TestAttribute5.cxx)

