project(TKXDECascade)

OCCT_INCLUDE_CMAKE_FILE (adm/cmake/occt_toolkit)
if(LIGHT_BUILD)
  message (STATUS "Info: [TKXDECascade] OCCT_ONLY_BINXCAF_DRIVER_IN_XDE is defined")
  target_compile_definitions(TKXDECascade PRIVATE -DOCCT_ONLY_BINXCAF_DRIVER_IN_XDE)

  message (STATUS "Info: [TKXDECascade] OCCT_DISABLE_CONFIGURATION_NODE_SAVE is defined")
  target_compile_definitions(TKXDECascade PRIVATE -DOCCT_DISABLE_CONFIGURATION_NODE_SAVE)
endif()
