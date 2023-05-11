project(TKSTL)

OCCT_INCLUDE_CMAKE_FILE (adm/cmake/occt_toolkit)

if (LIGHT_BUILD)
  message (STATUS "Info: [TKSTL] OCCT_DISABLE_CONFIGURATION_NODE_SAVE is defined")
  target_compile_definitions(TKSTL PRIVATE -DOCCT_DISABLE_CONFIGURATION_NODE_SAVE)
endif()
