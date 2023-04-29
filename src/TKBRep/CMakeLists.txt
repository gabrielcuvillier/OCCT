project(TKBRep)

OCCT_INCLUDE_CMAKE_FILE (adm/cmake/occt_toolkit)

if (LIGHT_BUILD)
  message (STATUS "Info: [TKBRep] OCCT_BREPTOOL_CURVE_ON_PLANE_SIMPLIFICATION is defined")
  target_compile_definitions(TKGeomBase PRIVATE -DOCCT_BREPTOOL_CURVE_ON_PLANE_SIMPLIFICATION)
endif()
