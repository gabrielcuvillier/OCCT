project(TKGeomAlgo)

OCCT_INCLUDE_CMAKE_FILE (adm/cmake/occt_toolkit)

if (LIGHT_BUILD)
  message (STATUS "Info: [TKGeomAlgo] OCCT_DISABLE_FUNCTIONS_WITH_WARNINGS is defined")
  target_compile_definitions(TKGeomAlgo PRIVATE -DOCCT_DISABLE_FUNCTIONS_WITH_WARNINGS)
endif()
