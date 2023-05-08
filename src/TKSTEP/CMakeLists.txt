project(TKSTEP)

OCCT_INCLUDE_CMAKE_FILE (adm/cmake/occt_toolkit)

if (LIGHT_BUILD)
  message (STATUS "Info: [TKSTEP] OCCT_DISABLE_XDE_STEP_WRITER is defined")
  target_compile_definitions(TKSTEP PRIVATE -DOCCT_DISABLE_XDE_STEP_WRITER)
endif()
