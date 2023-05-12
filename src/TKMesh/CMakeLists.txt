project(TKMesh)

OCCT_INCLUDE_CMAKE_FILE (adm/cmake/occt_toolkit)

if (LIGHT_BUILD)
  message (STATUS "Info: [TKMesh] OCCT_DISABLE_DELABELLA_MESH_ALGO is defined")
  target_compile_definitions(TKMesh PRIVATE -DOCCT_DISABLE_DELABELLA_MESH_ALGO)
endif()
