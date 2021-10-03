# 编译环境
L4D2 ?= ~/l4d2sv
HL2SDKL4D2 ?= ../../L4D2_Dev/hl2sdk-l4d2
HL2PUB = $(HL2SDKL4D2)/public
HL2LIB = $(HL2SDKL4D2)/lib/linux
HL2GAME = $(HL2SDKL4D2)/game
CPP = gcc-7

# 工程文件
PROJECT = LinGe_VScripts
OBJECTS	= LinGe_VScripts.cpp sdkapi/MemoryUtils/MemoryUtils.cpp sdkapi/sdkapi.cpp \
	sdkapi/signature.cpp

# 编译器选项
CFLAGS += -D_LINUX -DL4D2 -m32 \
		-Dstricmp=strcasecmp -D_stricmp=strcasecmp -D_strnicmp=strncasecmp \
		-Dstrnicmp=strncasecmp -D_snprintf=snprintf -D_vsnprintf=vsnprintf \
		-D_alloca=alloca -Dstrcmpi=strcasecmp -Wall -Wno-switch \
		-Wno-error=uninitialized -Wno-unused -Wno-error=delete-non-virtual-dtor \
		-mfpmath=sse -msse -DHAVE_STDINT_H
CPPFLAGS += -Wno-non-virtual-dtor -fno-rtti -fno-threadsafe-statics \
		-Wno-overloaded-virtual -std=c++11 -fpermissive
C_DEBUG_FLAGS = -D_DEBUG -DDEBUG -g -ggdb3
C_DEBUG_DIR = Debug
C_RELEASE_FLAGS = -DNDEBUG -O3 -funroll-loops -pipe -fno-strict-aliasing
C_RELEASE_DIR = $(PROJECT)

INCLUDE += -I. -I$(HL2PUB) -I$(HL2PUB)/tier0 -I$(HL2PUB)/tier1 -I$(HL2PUB)/tier2 \
		-I$(HL2PUB)/tier3 -I$(HL2GAME) -I$(HL2GAME)/shared -I$(HL2GAME)/server \
		-I$(HL2GAME)/client

# libtier0_srv.so 与 libvstdlib_srv.so 应使用服务器中最新版
LINK += libtier0_srv.so libvstdlib_srv.so $(HL2LIB)/tier1_i486.a \
		$(HL2LIB)/tier2_i486.a $(HL2LIB)/tier3_i486.a $(HL2LIB)/mathlib_i486.a \
		-m32 -ldl -lm -static-libgcc -static-libstdc++ -shared

release: libtier0_srv.so libvstdlib_srv.so
	$(CPP) $(INCLUDE) $(OBJECTS) $(CFLAGS) $(CPPFLAGS) $(C_RELEASE_FLAGS) $(LINK) -o $(C_RELEASE_DIR)/$(PROJECT).so
	cp $(C_RELEASE_DIR)/$(PROJECT).so $(L4D2)/left4dead2/addons/$(PROJECT)/$(PROJECT).so

debug: libtier0_srv.so libvstdlib_srv.so 
	$(CPP) $(INCLUDE) $(OBJECTS) $(CFLAGS) $(CPPFLAGS) $(C_DEBUG_FLAGS) $(LINK) -o $(C_DEBUG_DIR)/$(PROJECT).so
	cp $(C_DEBUG_DIR)/$(PROJECT).so $(L4D2)/left4dead2/addons/$(PROJECT)/$(PROJECT).so

libtier0_srv.so:
	cp $(L4D2)/bin/libtier0_srv.so libtier0_srv.so

libvstdlib_srv.so:
	cp $(L4D2)/bin/libvstdlib_srv.so libvstdlib_srv.so

clean:
	rm -rm $(C_DEBUG_DIR) $(C_RELEASE_DIR)