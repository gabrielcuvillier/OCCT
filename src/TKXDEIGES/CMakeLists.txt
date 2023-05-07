project(TKXDEIGES)

OCCT_INCLUDE_CMAKE_FILE (adm/cmake/occt_toolkit)

if (LIGHT_BUILD)
  message (STATUS "Info: [TKXDEIGES] OCCT_DISABLE_XDE_IGES_WRITER is defined")
  target_compile_definitions(TKXDEIGES PRIVATE -DOCCT_DISABLE_XDE_IGES_WRITER)
endif()
