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

#define SDKAPI_Msg(format, ...)		Msg("SDKAPI Msg: " format, ## __VA_ARGS__)
#define SDKAPI_Warning(format, ...)	Warning("SDKAPI Warning: " format, ## __VA_ARGS__)
#define SDKAPI_Error(format, ...)	Error("SDKAPI Error: " format, ## __VA_ARGS__)

namespace SDKAPI {
	class FCGlobalEntityList;

	// Interface
	extern ICvar *iCvar;
	extern IPlayerInfoManager *iPlayerInfoManager;
	extern IServerGameEnts *iServerGameEnts;
	extern IVEngineServer *iVEngineServer;
	extern IServerTools *iServerTools;
	extern IServerGameDLL *iServerGameDLL;
	extern IServerPluginHelpers *iServerPluginHelpers;
	extern IGameEventManager2 *iGameEventManager;

	extern MemoryUtils *mu_engine;
	extern MemoryUtils *mu_server;

	extern FCGlobalEntityList *gEntList;

	void Initialize(CreateInterfaceFn interfaceFactory, CreateInterfaceFn gameServerFactory);
	void UnInitialize();

	// 通过向实体 logic_script 发送实体输入执行 vscripts 脚本代码
	bool L4D2_RunScript(const char *sCode);

	// 签名函数
	namespace ServerSigFunc {
		typedef CBaseEntity *(__thiscall *FINDENTITYBYCLASSNAME)(void *, CBaseEntity *, const char *);
		extern FINDENTITYBYCLASSNAME CBaseEntity_FindEntityByClassname;

		void Initialize();
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
				throw "FindEntityByClassname function pointer is nullptr!";
		}
	};

	class FCBaseEntity
	{
	public:
		typedef bool(__thiscall *ACCEPTINPUT)(void *, const char *, CBaseEntity *, CBaseEntity *, variant_t, int);

	public:
		inline bool AcceptInput(const char *szInputName, CBaseEntity *pActivator, CBaseEntity *pCaller, variant_t Value, int outputID)
		{
			return GetVirtualFunction<ACCEPTINPUT>(this, VTI_AcceptInput)
				(this, szInputName, pActivator, pCaller, Value, outputID);
		}
	};
}
