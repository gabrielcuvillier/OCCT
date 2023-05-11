project(TKRWMesh)

OCCT_INCLUDE_CMAKE_FILE (adm/cmake/occt_toolkit)

if (LIGHT_BUILD)
  message (STATUS "Info: [TKRWMesh] OCCT_DISABLE_CONFIGURATION_NODE_SAVE is defined")
  target_compile_definitions(TKRWMesh PRIVATE -DOCCT_DISABLE_CONFIGURATION_NODE_SAVE)
endif()
