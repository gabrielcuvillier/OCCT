project(TKBinL)

OCCT_INCLUDE_CMAKE_FILE (adm/cmake/occt_toolkit)

if (LIGHT_BUILD)
  message (STATUS "Info: [TKBinL] OCCT_DISABLE_STORAGE_MIGRATION is defined")
  target_compile_definitions(TKBinL PRIVATE -DOCCT_DISABLE_STORAGE_MIGRATION)
endif()
