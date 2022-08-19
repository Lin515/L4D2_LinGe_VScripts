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
#include "sdkapi.h"
#include "signature.h"
#include <engine/iserverplugin.h>
#include <tier1.h>
#include <tier2.h>

namespace SDKAPI {
	ICvar *iCvar = nullptr;
	IPlayerInfoManager *iPlayerInfoManager = nullptr;
	IServerGameEnts *iServerGameEnts = nullptr;
	IVEngineServer *iVEngineServer = nullptr;
	IServerTools *iServerTools = nullptr;
	IServerGameDLL *iServerGameDLL = nullptr;
	IServerPluginHelpers *iServerPluginHelpers = nullptr;
	IGameEventManager2 *iGameEventManager = nullptr;
	CGlobalVars *pGlobals = nullptr;
	FCGlobalEntityList *gEntList = nullptr;

	static MemoryUtils *mu_engine = nullptr;
	static MemoryUtils *mu_server = nullptr;

	namespace ServerSigFunc {
		FINDENTITYBYCLASSNAME CBaseEntity_FindEntityByClassname = nullptr;

		void Initialize()
		{
			CBaseEntity_FindEntityByClassname = mu_server->FindSignature<FINDENTITYBYCLASSNAME>(Sig_FindEntityByClassname);
			if (!CBaseEntity_FindEntityByClassname)
				SDKAPI_Warning("FindEntityByClassname signature not found!\n");
		}
	}

	void Initialize(CreateInterfaceFn interfaceFactory, CreateInterfaceFn gameServerFactory)
	{
		ConnectTier1Libraries(&interfaceFactory, 1);
		ConnectTier2Libraries(&interfaceFactory, 1);
		// hl2sdk-l4d2 接口
		iCvar = reinterpret_cast<ICvar *>(interfaceFactory(CVAR_INTERFACE_VERSION, nullptr));
		if (!iCvar)
			SDKAPI_Warning("ICvar interface initialize failed!\n");

		iPlayerInfoManager = reinterpret_cast<IPlayerInfoManager *>(gameServerFactory(INTERFACEVERSION_PLAYERINFOMANAGER, nullptr));
		if (!iPlayerInfoManager)
			SDKAPI_Warning("IPlayerInfoManager interface initialize failed!\n");

		iServerGameEnts = reinterpret_cast<IServerGameEnts *>(gameServerFactory(INTERFACEVERSION_SERVERGAMEENTS, nullptr));
		if (!iServerGameEnts)
			SDKAPI_Warning("IServerGameEnts interface initialize failed!\n");

		iVEngineServer = reinterpret_cast<IVEngineServer *>(interfaceFactory(INTERFACEVERSION_VENGINESERVER, nullptr));
		if (!iVEngineServer)
			SDKAPI_Warning("IVEngineServer interface initialize failed!\n");

		iServerTools = reinterpret_cast<IServerTools *>(gameServerFactory(VSERVERTOOLS_INTERFACE_VERSION, nullptr));
		if (!iServerTools)
			SDKAPI_Warning("IServerTools interface initialize failed!\n");

		iServerGameDLL = reinterpret_cast<IServerGameDLL *>(gameServerFactory(INTERFACEVERSION_SERVERGAMEDLL, nullptr));
		if (!iServerGameDLL)
			SDKAPI_Warning("IServerGameDLL interface initialize failed!\n");

		iServerPluginHelpers = reinterpret_cast<IServerPluginHelpers *>(interfaceFactory(INTERFACEVERSION_ISERVERPLUGINHELPERS, nullptr));
		if (!iServerPluginHelpers)
			SDKAPI_Warning("IServerPluginHelpers interface initialize failed!\n");

		iGameEventManager = reinterpret_cast<IGameEventManager2 *>(interfaceFactory(INTERFACEVERSION_GAMEEVENTSMANAGER2, nullptr));
		if (!iGameEventManager)
			SDKAPI_Warning("IGameEventManager2 interface initialize failed!\n");

		mu_engine = new MemoryUtils(interfaceFactory);
		if (!mu_engine->IsAvailable())
			SDKAPI_Warning("mu_engine initialize failed!\n");

		mu_server = new MemoryUtils(gameServerFactory);
		if (!mu_server->IsAvailable())
			SDKAPI_Warning("mu_server initialize failed!\n");
		else
			ServerSigFunc::Initialize();

		// 初始化 pEntList 方法参考 sourcemod/core/HalfLife2.cpp
		// Win32下是通过LevelShutdown函数地址再加上偏移量获得pEntityList(指向gEntList的指针)的地址
		// Linux下是直接通过符号查找获得gEntList的地址
		if (mu_server->IsAvailable())
		{
			void *ptr = mu_server->FindSignature<void *>(Sig_gEntList);
			if (!ptr)
				SDKAPI_Warning("gEntList signature not found!\n");
			else
			{
			#ifdef WIN32
				ptr = *(reinterpret_cast<void **>((char *)ptr + Offset_gEntList_windows));
			#endif
				gEntList = reinterpret_cast<FCGlobalEntityList *>(ptr);
			}
		}
	}

	void UnInitialize()
	{
		delete mu_server;
		delete mu_engine;
		DisconnectTier1Libraries();
		DisconnectTier2Libraries();
	}

	// 通过向实体 logic_script 发送实体输入执行 vscripts 脚本代码
	// 代码参考 Silver https://forums.alliedmods.net/showthread.php?p=2657025
	bool L4D2_RunScript(const char *_Format, ...)
	{
		// 处理 _Format
		static char buffer[8192];
		va_list arg_list;
		va_start(arg_list, _Format);
		vsnprintf(buffer, sizeof(buffer), _Format, arg_list);
		va_end(arg_list);

		static variant_t var;
		// pScriptLogic 必须每次执行时查找 因为每局游戏它应该都会变
		CBaseEntity *pScriptLogic = gEntList->FindEntityByClassname(nullptr, "logic_script");
		edict_t *edict = iServerGameEnts->BaseEntityToEdict(pScriptLogic);
		if (!edict || edict->IsFree())
		{
			pScriptLogic = reinterpret_cast<CBaseEntity *>(iServerTools->CreateEntityByName("logic_script"));
			if (!pScriptLogic)
				return false;
			iServerTools->DispatchSpawn(pScriptLogic);
		}
		castable_string_t str(buffer);
		var.SetString(str);
		return reinterpret_cast<FCBaseEntity *>(pScriptLogic)->AcceptInput("RunScriptCode", nullptr, nullptr, var, 0);
	}
} // namespace SDKAPI