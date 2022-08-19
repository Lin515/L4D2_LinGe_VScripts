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
#include <eiface.h>
#include <igameevents.h>
#include <game/server/iplayerinfo.h>
#include <toolframework/itoolentity.h>
#include <variant_t.h>
#include <string_t.h>
#include "MemoryUtils/MemoryUtils.h"
#include "signature.h"

#ifdef _LINUX
#define __thiscall
#endif

#define SDKAPI_Msg(format, ...)		Msg("SDKAPI: " format, ## __VA_ARGS__)
#define SDKAPI_Warning(format, ...)	Warning("SDKAPI: " format, ## __VA_ARGS__)
#define SDKAPI_Error(format, ...)	Error("SDKAPI: " format, ## __VA_ARGS__)

namespace SDKAPI {
	// 伪 SDK 类前置声明
	class FCGlobalEntityList;
	class FCBaseEntity;

	// SDK API 接口
	extern ICvar *iCvar;
	extern IPlayerInfoManager *iPlayerInfoManager;
	extern IServerGameEnts *iServerGameEnts;
	extern IVEngineServer *iVEngineServer;
	extern IServerTools *iServerTools;
	extern IServerGameDLL *iServerGameDLL;
	extern IServerPluginHelpers *iServerPluginHelpers;
	extern IGameEventManager2 *iGameEventManager;
	extern CGlobalVars *pGlobals;
	extern FCGlobalEntityList *gEntList;

	namespace ServerSigFunc {
		typedef CBaseEntity *(__thiscall *FINDENTITYBYCLASSNAME)(void *, CBaseEntity *, const char *);
		extern FINDENTITYBYCLASSNAME CBaseEntity_FindEntityByClassname;
	}

	// 全局函数
	void Initialize(CreateInterfaceFn interfaceFactory, CreateInterfaceFn gameServerFactory);
	void UnInitialize();

	// 通过向实体 logic_script 发送实体输入执行 vscripts 脚本代码
	bool L4D2_RunScript(const char *_Format, ...);

	inline int IndexOfEdict(const edict_t *pEdict)
	{
		return (int)(pEdict - pGlobals->pEdicts);
	}
	inline edict_t *PEntityOfEntIndex(int iEntIndex)
	{
		if (iEntIndex >= 0 && iEntIndex < pGlobals->maxEntities)
		{
			return (edict_t *)(pGlobals->pEdicts + iEntIndex);
		}
		return nullptr;
	}

	// 通过UserID获取到实体
	inline edict_t *GetEntityFromUserID(int userid)
	{
		for (int i=0; i<pGlobals->maxEntities; i++)
		{
			edict_t *pEntity = PEntityOfEntIndex(i);
			if (iVEngineServer->GetPlayerUserId(pEntity) == userid)
				return pEntity;
		}
		return nullptr;
	}

	// 伪SDK类，用于方便调用一些函数
	class FCGlobalEntityList
	{
	public:
		inline CBaseEntity *FindEntityByClassname(CBaseEntity *pStartEntity, const char *szName)
		{
			if (ServerSigFunc::CBaseEntity_FindEntityByClassname)
				return ServerSigFunc::CBaseEntity_FindEntityByClassname(this, pStartEntity, szName);
			else
			{
				SDKAPI_Error("FindEntityByClassname function pointer is nullptr!");
				return nullptr;
			}
		}
	};

	class FCBaseEntity
	{
	public:
		typedef bool(__thiscall *ACCEPTINPUT)(void *, const char *, CBaseEntity *, CBaseEntity *, variant_t, int);

	public:
		inline bool AcceptInput(const char *szInputName, CBaseEntity *pActivator, CBaseEntity *pCaller, variant_t Value, int outputID=0)
		{
			return GetVirtualFunction<ACCEPTINPUT>(this, VTI_AcceptInput)
				(this, szInputName, pActivator, pCaller, Value, outputID);
		}
	};
}
