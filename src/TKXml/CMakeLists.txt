project(TKXml)

OCCT_INCLUDE_CMAKE_FILE (adm/cmake/occt_toolkit)

if (LIGHT_BUILD)
  message (STATUS "Info: [TKXml] OCCT_DISABLE_STORAGE_MIGRATION is defined")
  target_compile_definitions(TKXml PRIVATE -DOCCT_DISABLE_STORAGE_MIGRATION)
endif()
