#add_subdirectory(Cxx Python)
add_subdirectory(Cxx)

if(GDCM_WRAP_CSHARP)
  add_subdirectory(Csharp)
endif()

if(GDCM_WRAP_JAVA)
#  add_subdirectory(Java)
endif()
