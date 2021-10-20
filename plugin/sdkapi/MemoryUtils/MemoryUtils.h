/**
 * vim: set ts=4 sw=4 tw=99 noet :
 * =============================================================================
 * SourceMod
 * Copyright (C) 2004-2011 AlliedModders LLC.  All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 */
 // 修改自 sourcemod/core/logic/MemoryUtils.h
 // https://github.com/alliedmodders/sourcemod

#ifndef _INCLUDE_SOURCEMOD_MEMORYUTILS_H_
#define _INCLUDE_SOURCEMOD_MEMORYUTILS_H_
#include "sm_platform.h"
#include <cstdint>
#include <interface.h>

#if defined PLATFORM_LINUX
#include "sm_symtable.h"
#endif

struct VTableIndex {
	int Windows;
	int Linux;
};

// 从虚函数表获取指定的虚函数
template<typename Fn>
inline Fn GetVirtualFunction(void *base, VTableIndex index)
{
	// 将 base 对象基址直接转换为指向虚函数表的指针
	std::uintptr_t **pVTable = (std::uintptr_t **)base;
	// 从虚函数表获取对应的虚函数指针
#ifdef WIN32
	return reinterpret_cast<Fn>((*pVTable)[index.Windows]);
#elif defined _LINUX
	return reinterpret_cast<Fn>((*pVTable)[index.Linux]);
#endif
}

struct Signature {
	const char *Windows;
	const char *Linux;
};

struct DynLibInfo
{
	void *baseAddress;
	size_t memorySize;
	HMODULE handle;
};

#if defined PLATFORM_LINUX
struct LibSymbolTable
{
	SymbolTable table;
	uintptr_t lib_base;
	uint32_t last_pos;
};
#endif

class MemoryUtils
{
public:
	MemoryUtils(CreateInterfaceFn factory = nullptr);
	bool Init(CreateInterfaceFn factory);
	bool IsAvailable();
	static bool GetLibraryInfo(const void *libPtr, DynLibInfo &lib);

private:
	bool isAvailable;
	CreateInterfaceFn factory;
	DynLibInfo lib;
#ifdef PLATFORM_LINUX
	LibSymbolTable m_SymTable;
#endif

public:
	void *FindPattern(const char *pattern);
	void *ResolveSymbol(const char *symbol);

	template<typename Fn>
	inline Fn FindSignature(Signature signature)
	{
#ifdef WIN32
		return reinterpret_cast<Fn>(FindPattern(signature.Windows));
#elif defined PLATFORM_LINUX
		return reinterpret_cast<Fn>(ResolveSymbol(signature.Linux));
#endif
	}
};

#endif // _INCLUDE_SOURCEMOD_MEMORYUTILS_H_
