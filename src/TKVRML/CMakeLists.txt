project(TKVRML)

OCCT_INCLUDE_CMAKE_FILE (adm/cmake/occt_toolkit)

if (LIGHT_BUILD)
  message (STATUS "Info: [TKVRML] OCCT_DISABLE_VRML1_EXPORT is defined")
  target_compile_definitions(TKVRML PRIVATE -DOCCT_DISABLE_VRML1_EXPORT)

  message (STATUS "Info: [TKVRML] OCCT_DISABLE_VRML_IMPORT is defined")
  target_compile_definitions(TKVRML PRIVATE -DOCCT_DISABLE_VRML_IMPORT)
endif()
