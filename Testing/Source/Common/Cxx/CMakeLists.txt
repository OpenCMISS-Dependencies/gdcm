# Define the tests for Common
# Common
set(Common_TEST_SRCS
  TestVersion
  TestDummyValueGenerator
  TestASN1
  TestTesting
  TestSwapper
  TestByteSwap
  TestString
  TestString2
  TestTerminal
  TestFilenameGenerator
  TestObject
  TestSmartPointer
  TestSwapCode
  TestSystem
  TestTrace
  TestTypes
  TestUnpacker12Bits
  TestBase64
  )

if(GDCM_DATA_ROOT)
set(Common_TEST_SRCS
  ${Common_TEST_SRCS}
  TestDirectory
  TestFilename
  TestMD5
  TestSHA1
  )
endif()

# Add the include paths
INCLUDE_DIRECTORIES(
  "${GDCM_BINARY_DIR}/Source/Common"
  "${GDCM_SOURCE_DIR}/Source/Common"
  "${GDCM_SOURCE_DIR}/Source/DataStructureAndEncodingDefinition"
  )

CREATE_TEST_SOURCELIST(CommonTests gdcmCommonTests.cxx ${Common_TEST_SRCS})
ADD_EXECUTABLE(gdcmCommonTests ${CommonTests})
TARGET_LINK_LIBRARIES(gdcmCommonTests gdcmCommon)

#Don't understand why I need that ??
set(GDCM_Common_TESTS "${EXECUTABLE_OUTPUT_PATH}/gdcmCommonTests")

# Loop over files and create executables
foreach(name ${Common_TEST_SRCS})
if(CMAKE_CROSSCOMPILING) 
  ADD_TEST(${name} ${TARGET_SYSTEM_EMULATOR} ${GDCM_Common_TESTS}${CMAKE_EXECUTABLE_SUFFIX} ${name})
else() 
  ADD_TEST(${name} ${GDCM_Common_TESTS} ${name})
endif() 
endforeach()


