project(TKIGES)

OCCT_INCLUDE_CMAKE_FILE (adm/cmake/occt_toolkit)

if (LIGHT_BUILD)
  message (STATUS "Info: [TKIGES] OCCT_DISABLE_WORK_LIBRARY_SAVE_FILE is defined")
  target_compile_definitions(TKIGES PRIVATE -DOCCT_DISABLE_WORK_LIBRARY_SAVE_FILE)
endif()
