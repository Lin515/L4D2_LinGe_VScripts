#pragma once
#include "MemoryUtils/MemoryUtils.h"
// 本文件中大量函数签名与偏移地址来自 sourcemod

#ifdef _LINUX
#define __thiscall
#endif
typedef CBaseEntity *(__thiscall *FINDENTITYBYCLASSNAME)(void *, void *, const char *);
typedef bool(__thiscall *ACCEPTINPUT)(void *, const char *, void *, void *, variant_t, int);

// LevelShutdown 用于定位 gEntList
Signature Sig_LevelShutdown = {
	"\xE8\x2A\x2A\x2A\x2A\xE8\x2A\x2A\x2A\x2A\xB9\x2A\x2A\x2A\x2A\xE8\x2A\x2A\x2A\x2A\xE8",
	nullptr
};
#define Offset_gEntList_windows 11 // Offset into LevelShutdown
Signature Sig_gEntList = {
	nullptr,
	"gEntList"
};

// CGlobalEntityList::FindEntityByClassname
Signature Sig_FindEntityByClassname = {
	"\x55\x8B\xEC\x53\x56\x8B\xF1\x8B\x4D\x08\x57\x85\xC9\x74\x2A\x8B\x01\x8B\x50\x08\xFF\xD2\x8B\x00\x25\xFF\x0F\x00\x00\x40\x03\xC0\x8B\x3C\xC6\xEB\x2A\x8B\x2A\x2A\x2A\x2A\x2A\x85\xFF\x74\x2A\x8B\x5D\x0C\x8B\x37\x85\xF6\x75\x2A\x68\x2A\x2A\x2A\x2A\xFF\x2A\x2A\x2A\x2A\x2A\x83\xC4\x04\xEB\x2A\x39",
	"_ZN17CGlobalEntityList21FindEntityByClassnameEP11CBaseEntityPKc"
};

// CBaseEntity::AcceptInput 虚函数表索引
VTableIndex VTI_AcceptInput = {44, 45};
