cmake_minimum_required(VERSION 3.5)

project(LinGe_VScripts LANGUAGES CXX)

set(L4D2BIN ~/l4d2sv/bin) # 仅Linux下需要用到
set(HL2SDKL4D2 ../../L4D2_Dev/hl2sdk-l4d2)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(HL2PUB ${HL2SDKL4D2}/public)
set(HL2GAME ${HL2SDKL4D2}/game)

if(WIN32)
    link_directories(${HL2SDKL4D2}/lib/public)
    set(LINK_LIBRARY
        tier0
        vstdlib
        tier1
        tier2
        tier3
        mathlib
        legacy_stdio_definitions # vc++2015及以上需链接此库
    )
    add_compile_options(/source-charset:windows-1250)
    add_compile_options(/execution-charset:utf-8)
    add_compile_options(/MP)
    # 静态链接到CRT库
    string(REPLACE "/MD" "/MT" 	CMAKE_CXX_FLAGS_DEBUG ${CMAKE_CXX_FLAGS_DEBUG})
    string(REPLACE "/MD" "/MT" 	CMAKE_CXX_FLAGS_RELEASE ${CMAKE_CXX_FLAGS_RELEASE})
    string(REPLACE "/MD" "/MT" 	CMAKE_CXX_FLAGS_MINSIZEREL ${CMAKE_CXX_FLAGS_MINSIZEREL})
    string(REPLACE "/MD" "/MT" 	CMAKE_CXX_FLAGS_RELWITHDEBINFO ${CMAKE_CXX_FLAGS_RELWITHDEBINFO})
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /NODEFAULTLIB:libc")
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /NODEFAULTLIB:libcd")
    # set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /NODEFAULTLIB:libcmt") # 如果动态链接到CRT库，需要忽略libcmt
elseif(UNIX)
    link_directories(${L4D2BIN}) # 不要设置到 ${HL2SDKL4D2}/lib/linux .so需使用服务器最新
    get_filename_component(ABSLIB ${HL2SDKL4D2}/lib/linux ABSOLUTE)
    set(LINK_LIBRARY
        libtier0_srv.so
        libvstdlib_srv.so
        ${ABSLIB}/tier1_i486.a
        ${ABSLIB}/tier2_i486.a
        ${ABSLIB}/tier3_i486.a
        ${ABSLIB}/mathlib_i486.a
    )
    set(CMAKE_CXX_FLAGS	"${CMAKE_CXX_FLAGS} -D_LINUX -DL4D2 -m32 \
        -Dstricmp=strcasecmp -D_stricmp=strcasecmp -D_strnicmp=strncasecmp \
        -Dstrnicmp=strncasecmp -D_snprintf=snprintf -D_vsnprintf=vsnprintf \
        -D_alloca=alloca -Dstrcmpi=strcasecmp -DHAVE_STDINT_H -Wall -Wno-switch \
        -Wno-error=uninitialized -Wno-unused -Wno-error=delete-non-virtual-dtor \
        -Wno-class-memaccess -Wno-packed-not-aligned -mfpmath=sse -msse \
        -Wno-non-virtual-dtor -fno-rtti -fno-threadsafe-statics \
        -Wno-overloaded-virtual -fpermissive \
        -ldl -lm -static-libgcc -static-libstdc++"
    )
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -funroll-loops -pipe -fno-strict-aliasing")
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_BUILD_TYPE}")
endif()

# 创建库
add_library(LinGe_VScripts SHARED)

if(UNIX)
    set_target_properties(LinGe_VScripts PROPERTIES PREFIX "") # 去掉输出文件名的lib前缀
endif()

target_sources(LinGe_VScripts PRIVATE
    LinGe_VScripts.cpp
    sdkapi/MemoryUtils/MemoryUtils.cpp
    sdkapi/sdkapi.cpp
)

target_include_directories(LinGe_VScripts PRIVATE
    ${HL2PUB}
    ${HL2PUB}/tier0
    ${HL2PUB}/tier1
    ${HL2PUB}/tier2
    ${HL2PUB}/tier3
    ${HL2GAME}/shared
    ${HL2GAME}/server
    ${HL2GAME}/client
    ${HL2SDKL4D2}/common
)

target_link_libraries(LinGe_VScripts PRIVATE ${LINK_LIBRARY})