##

if(FLAGS_ALREADY_INCLUDED)
  return()
endif()
set(FLAGS_ALREADY_INCLUDED 1)

if (EMSCRIPTEN)
  message(STATUS "Info: Building for Emscripten/WebAssembly.")
endif ()

if (MSVC AND CMAKE_CXX_COMPILER_ID MATCHES "[Cc][Ll][Aa][Nn][Gg]")
  message(WARNING "Clang with MSVC-like command-line found \(aka. \"clang-cl\"\). Prefer using Clang with GNU-like command-line, as it provide more predictable control over compiler flags")
  # Note: on MSVC Release configuration, flags translates roughly to "-O2 -fstack-protector -fexceptions -fbuiltin -ffunction-sections -finline-functions"
endif()

# force option /fp:precise for Visual Studio projects.
#
# Note that while this option is default for MSVC compiler, Visual Studio
# project can be switched later to use Intel Compiler (ICC).
# Enforcing -fp:precise ensures that in such case ICC will use correct
# option instead of its default -fp:fast which is harmful for OCCT.
if (MSVC)
  set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /fp:precise")
  set (CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}   /fp:precise")
endif()

if (MSVC)
  # suppress C26812 on VS2019/C++20 (prefer 'enum class' over 'enum')
  set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /wd\"26812\"")

  # enable structured exceptions handling (SEH)
  string (REGEX MATCH "EHsc" ISFLAG "${CMAKE_CXX_FLAGS}")
  if (ISFLAG)
    string (REGEX REPLACE "EHsc" "EHa" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
  else()
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /EHa")
  endif()
else()
  if (EMSCRIPTEN)
    # enable WebAssembly Exceptions support
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fwasm-exceptions")
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fwasm-exceptions")
    # enforce STRICT mode
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -sSTRICT=1")
    set (CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} -sSTRICT=1")
  elseif (NOT (WIN32 AND CMAKE_CXX_COMPILER_ID MATCHES "[Cc][Ll][Aa][Nn][Gg]" AND NOT MINGW))
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fexceptions")

    # On anything except Clang on Windows with MSVC, use fPIC and OCC_CONVERT_SIGNAL
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
    set (CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} -fPIC")

    add_definitions(-DOCC_CONVERT_SIGNALS)
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fstack-protector")
    set (CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} -fstack-protector")
  else()
    # Specifically on Clang on Windows with MSVC, use the experimental -fasync-exceptions to mimic MSVC /EHa behavior
    # => Not yet working (tested on Clang 16 on Windows)
    #set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fasync-exceptions")
    #set (CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}   -fasync-exceptions")

    # Workaround
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fexceptions")
    # => enable OCC_CONVERT_SIGNALS instead for now
    add_definitions(-DOCC_CONVERT_SIGNALS)
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fstack-protector")
    set (CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} -fstack-protector")
  endif()
endif()

if (MSVC OR ((NOT MINGW) AND WIN32 AND CMAKE_CXX_COMPILER_ID MATCHES "[Cc][Ll][Aa][Nn][Gg]"))
  # suppress warning on using portable non-secure functions in favor of non-portable secure ones
  add_definitions (-D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_DEPRECATE)
endif()

# remove _WINDOWS flag if it exists
string (REGEX MATCH "/D_WINDOWS" IS_WINDOWSFLAG "${CMAKE_CXX_FLAGS}")
if (IS_WINDOWSFLAG)
  message (STATUS "Info: /D_WINDOWS has been removed from CMAKE_CXX_FLAGS")
  string (REGEX REPLACE "/D_WINDOWS" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
endif()

# remove WIN32 flag if it exists
string (REGEX MATCH "/DWIN32" IS_WIN32FLAG "${CMAKE_CXX_FLAGS}")
if (IS_WIN32FLAG)
  message (STATUS "Info: /DWIN32 has been removed from CMAKE_CXX_FLAGS")
  string (REGEX REPLACE "/DWIN32" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
endif()

# remove _WINDOWS flag if it exists
string (REGEX MATCH "/D_WINDOWS" IS_WINDOWSFLAG "${CMAKE_C_FLAGS}")
if (IS_WINDOWSFLAG)
  message (STATUS "Info: /D_WINDOWS has been removed from CMAKE_C_FLAGS")
  string (REGEX REPLACE "/D_WINDOWS" "" CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
endif()

# remove WIN32 flag if it exists
string (REGEX MATCH "/DWIN32" IS_WIN32FLAG "${CMAKE_C_FLAGS}")
if (IS_WIN32FLAG)
  message (STATUS "Info: /DWIN32 has been removed from CMAKE_C_FLAGS")
  string (REGEX REPLACE "/DWIN32" "" CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
endif()

# remove DEBUG flag if it exists
string (REGEX MATCH "-DDEBUG" IS_DEBUG_CXX "${CMAKE_CXX_FLAGS_DEBUG}")
if (IS_DEBUG_CXX)
  message (STATUS "Info: -DDEBUG has been removed from CMAKE_CXX_FLAGS_DEBUG")
  string (REGEX REPLACE "-DDEBUG" "" CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")
endif()

string (REGEX MATCH "-DDEBUG" IS_DEBUG_C "${CMAKE_C_FLAGS_DEBUG}")
if (IS_DEBUG_C)
  message (STATUS "Info: -DDEBUG has been removed from CMAKE_C_FLAGS_DEBUG")
  string (REGEX REPLACE "-DDEBUG" "" CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG}")
endif()

# enable parallel compilation on MSVC 9 and above
if (MSVC AND (MSVC_VERSION GREATER 1400))
  set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP")
endif()

# generate a single response file which enlist all of the object files
if (NOT DEFINED CMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS)
  SET(CMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS 1)
endif()
if (NOT DEFINED CMAKE_CXX_USE_RESPONSE_FILE_FOR_OBJECTS)
  SET(CMAKE_CXX_USE_RESPONSE_FILE_FOR_OBJECTS 1)
endif()

# increase compiler warnings level (-W4 for MSVC, -Wextra for GCC)
if (MSVC)
  if (CMAKE_CXX_FLAGS MATCHES "/W[0-4]")
    string (REGEX REPLACE "/W[0-4]" "/W4" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
  else()
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W4")
  endif()
elseif (CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX OR (CMAKE_CXX_COMPILER_ID MATCHES "[Cc][Ll][Aa][Nn][Gg]"))
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra")
  if (CMAKE_CXX_COMPILER_ID MATCHES "[Cc][Ll][Aa][Nn][Gg]" AND NOT EMSCRIPTEN)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wshorten-64-to-32")
  endif()
  if (BUILD_SHARED_LIBS)
    if (APPLE)
      set (CMAKE_SHARED_LINKER_FLAGS "-lm ${CMAKE_SHARED_LINKER_FLAGS}")
    elseif(NOT WIN32)
      set (CMAKE_SHARED_LINKER_FLAGS "-lm ${CMAKE_SHARED_LINKER_FLAGS}")
    endif()
  endif()
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES "[Cc][Ll][Aa][Nn][Gg]")
  if (APPLE)
    # CLang can be used with both libstdc++ and libc++, however on OS X libstdc++ is outdated.
    set (CMAKE_CXX_FLAGS "-stdlib=libc++ ${CMAKE_CXX_FLAGS}")
  else()
    # Optimize size of binaries
    if (UNIX OR MINGW)
      set (CMAKE_SHARED_LINKER_FLAGS_RELEASE "-Wl,-s ${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
      set (CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL "-Wl,-s ${CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL}")
      set (CMAKE_STATIC_LINKER_FLAGS_RELEASE "-s ${CMAKE_STATIC_LINKER_FLAGS_RELEASE}")
      set (CMAKE_STATIC_LINKER_FLAGS_MINSIZEREL "-s ${CMAKE_STATIC_LINKER_FLAGS_MINSIZEREL}")
    endif()
  endif()

  #disable warning not yet managed in source code when using clang
  if  (NOT CMAKE_C_COMPILER_VERSION VERSION_LESS "14.0.0")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-unused-but-set-variable")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-unused-but-set-parameter")
  endif()
elseif(MINGW)
  add_definitions(-D_WIN32_WINNT=0x0601)
  # _WIN32_WINNT=0x0601 (use Windows 7 SDK)
  #set (CMAKE_SYSTEM_VERSION "6.1")
  # workaround bugs in mingw with vtable export
  set (CMAKE_SHARED_LINKER_FLAGS "-Wl,--export-all-symbols")

  # Optimize size of binaries
  set (CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -s")
  set (CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -s")
  set (CMAKE_CXX_FLAGS_MINSIZEREL  "${CMAKE_CXX_FLAGS_MINSIZEREL} -s")
  set (CMAKE_C_FLAGS_MINSIZEREL  "${CMAKE_C_FLAGS_MINSIZEREL} -s")
elseif (DEFINED CMAKE_COMPILER_IS_GNUCXX)
  # Optimize size of binaries
  set (CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -s")
  set (CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -s")
  set (CMAKE_CXX_FLAGS_MINSIZEREL  "${CMAKE_CXX_FLAGS_MINSIZEREL} -s")
  set (CMAKE_C_FLAGS_MINSIZEREL  "${CMAKE_C_FLAGS_MINSIZEREL} -s")
endif()

if (BUILD_RELEASE_DISABLE_EXCEPTIONS)
  set (CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -DNo_Exception")
  set (CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -DNo_Exception")
  set (CMAKE_CXX_FLAGS_MINSIZEREL  "${CMAKE_CXX_FLAGS_MINSIZEREL} -DNo_Exception")
  set (CMAKE_C_FLAGS_MINSIZEREL  "${CMAKE_C_FLAGS_MINSIZEREL} -DNo_Exception")
endif()

# Use 'Oz' optimization level (instead of Os) on Clang
if (CMAKE_CXX_COMPILER_ID MATCHES "[Cc][Ll][Aa][Nn][Gg]")
  string(REGEX MATCH "-Os" IS_Os_CXX "${CMAKE_CXX_FLAGS_MINSIZEREL}")
  if (IS_Os_CXX)
    string(REGEX REPLACE "-Os" "-Oz" CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL}")
  else ()
    set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL} -Oz")
  endif ()

  string(REGEX MATCH "-Os" IS_Os_C "${CMAKE_C_FLAGS_MINSIZEREL}")
  if (IS_Os_C)
    string(REGEX REPLACE "-Os" "-Oz" CMAKE_C_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL}")
  else ()
    set(CMAKE_C_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL} -Oz")
  endif ()
endif()

message("============== CXX Flags ===========")
message("Common CXX Flags: " ${CMAKE_CXX_FLAGS})
message("Debug CXX Flags: " ${CMAKE_CXX_FLAGS_DEBUG})
message("Release CXX Flags: " ${CMAKE_CXX_FLAGS_RELEASE})
message("MinSizeRel CXX Flags: " ${CMAKE_CXX_FLAGS_MINSIZEREL})
message("RelWithDebInfo CXX Flags: " ${CMAKE_CXX_FLAGS_RELWITHDEBINFO})
message("============== C Flags ===========")
message("Common C Flags: " ${CMAKE_C_FLAGS})
message("Debug C Flags: " ${CMAKE_C_FLAGS_DEBUG})
message("Release C Flags: " ${CMAKE_C_FLAGS_RELEASE})
message("MinSizeRel C Flags: " ${CMAKE_C_FLAGS_MINSIZEREL})
message("RelWithDebInfo C Flags: " ${CMAKE_C_FLAGS_RELWITHDEBINFO})
message("==================================")
