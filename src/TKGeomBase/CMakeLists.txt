project(TKGeomBase)

OCCT_INCLUDE_CMAKE_FILE (adm/cmake/occt_toolkit)

if (LIGHT_BUILD)
  message (STATUS "Info: [TKGeomBase] OCCT_DISABLE_FUNCTIONS_WITH_WARNINGS is defined")
  target_compile_definitions(TKGeomBase PRIVATE -DOCCT_DISABLE_FUNCTIONS_WITH_WARNINGS)
endif()
