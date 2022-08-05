/**
 * SDKAPI
 * Copyright (C) 2021 LinGe All rights reserved.
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
 */
#pragma once
#include "MemoryUtils/MemoryUtils.h"

constexpr Signature Sig_gEntList = {
	"\xE8\x2A\x2A\x2A\x2A\xE8\x2A\x2A\x2A\x2A\xB9\x2A\x2A\x2A\x2A\xE8\x2A\x2A\x2A\x2A\xE8",
	// 此 Windows 平台签名为 LevelShutdown 函数的签名，用于定位 pEntityList
	"@gEntList"
};
#define Offset_gEntList_windows 11 // Offset into LevelShutdown

// CGlobalEntityList::FindEntityByClassname
constexpr Signature Sig_FindEntityByClassname = {
	"\x55\x8B\xEC\x53\x56\x8B\xF1\x8B\x4D\x08\x57\x85\xC9\x74\x2A\x8B\x01\x8B\x50\x08\xFF\xD2\x8B\x00\x25\xFF\x0F\x00\x00\x40\x03\xC0\x8B\x3C\xC6\xEB\x2A\x8B\x2A\x2A\x2A\x2A\x2A\x85\xFF\x74\x2A\x8B\x5D\x0C\x8B\x37\x85\xF6\x75\x2A\x68\x2A\x2A\x2A\x2A\xFF\x2A\x2A\x2A\x2A\x2A\x83\xC4\x04\xEB\x2A\x39",
	"@_ZN17CGlobalEntityList21FindEntityByClassnameEP11CBaseEntityPKc"
};

// CBaseEntity::AcceptInput 虚函数表索引
constexpr VTableIndex VTI_AcceptInput = { 44, 45 };