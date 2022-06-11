/**
 * LinGe_VScripts
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
#include <stdio.h>
#include <time.h>
#include <cstdint>
#include "LinGe_VScripts.h"
#include "sdkapi/sdkapi.h"

LinGe_VScripts plugin;
EXPOSE_SINGLE_INTERFACE_GLOBALVAR(LinGe_VScripts, IServerPluginCallbacks, INTERFACEVERSION_ISERVERPLUGINCALLBACKS, plugin);

// ConVar
ConVar cv_vscriptReturn("linge_vscript_return", "", FCVAR_HIDDEN|FCVAR_SPONLY, "Return VScript values.");
ConVar cv_lookPing("linge_look_ping", "1", FCVAR_NOTIFY, "PlayerPing is executed when the 'vocalize smartlook' command is issued.", true, 0.0, true, 1.0, LinGe_VScripts::OnLookPingChanged);
ConVar cv_time("linge_time", "", FCVAR_PRINTABLEONLY|FCVAR_SPONLY, "Server system time.");
ConVar cv_format("linge_time_format", "%Y-%m-%d %H:%M:%S", FCVAR_NONE, "linge_time format string, see also:https://www.runoob.com/cprogramming/c-function-strftime.html", false, 0.0, false, 0.0, LinGe_VScripts::OnTimeFormatChanged);
char g_sTimeFormat[50] = "%Y-%m-%d %H:%M:%S";
bool g_bLookPing = true;

LinGe_VScripts::LinGe_VScripts() : m_iClientCommandIndex(0), m_bPlayerPingLoaded(false)
{
}
LinGe_VScripts::~LinGe_VScripts() {}

bool LinGe_VScripts::Load(CreateInterfaceFn interfaceFactory, CreateInterfaceFn gameServerFactory)
{
	SDKAPI::Initialize(interfaceFactory, gameServerFactory);

	ConVar_Register();

	PL_Msg("Loaded.\n");
	return true;
}
void LinGe_VScripts::Unload(void)
{
	SDKAPI::iGameEventManager->RemoveListener(this);

	ConVar_Unregister();
	SDKAPI::UnInitialize();
}

const char *LinGe_VScripts::GetPluginDescription(void) {
	return PLNAME " " PLVER " By LinGe";
}

void LinGe_VScripts::GameFrame(bool simulating)
{
	// 每 1s 更新一次 linge_time
	static time_t oldTime = 0, nowTime = 0;
	static char buffer[50];
	time(&nowTime);
	if (nowTime - oldTime >= 1)
	{
		if (strftime(buffer, sizeof(buffer), g_sTimeFormat, localtime(&nowTime)))
			cv_time.SetValue(buffer);
		else
			cv_time.SetValue("ERROR");
		oldTime = nowTime;
	}
}

void LinGe_VScripts::LevelInit(char const *pMapName) {
	SDKAPI::iGameEventManager->AddListener(this, "round_start", true);
}
void LinGe_VScripts::LevelShutdown(void) {
	SDKAPI::iGameEventManager->RemoveListener(this);
}

void LinGe_VScripts::FireGameEvent(IGameEvent * event)
{
	const char *name = event->GetName();
	if (Q_stricmp(name, "round_start") == 0)
	{
		// 验证根表下是否存在 LinPlayerPing
		SDKAPI::L4D2_RunScript("Convars.SetValue(\"linge_vscript_return\", getroottable().rawin(\"LinPlayerPing\"));");
		if (cv_vscriptReturn.GetBool())
		{
			m_bPlayerPingLoaded = true;
			PL_DevMsg("LinPlayerPing found.\n");
		}
		else
		{
			m_bPlayerPingLoaded = false;
			PL_DevMsg("LinPlayerPing not found.\n");
		}
	}
}

void LinGe_VScripts::ServerActivate(edict_t *pEdictList, int edictCount, int clientMax) {}

// 监测 vocalize smartlook
PLUGIN_RESULT LinGe_VScripts::ClientCommand(edict_t *pEntity, const CCommand &args)
{
	if ( !pEntity || pEntity->IsFree() )
		return PLUGIN_CONTINUE;
	if (m_bPlayerPingLoaded && g_bLookPing)
	{
		if ( Q_stricmp(args[0], "vocalize") == 0
		&& Q_stricmp(args[1], "smartlook") == 0
		&& (args.ArgC() == 2 || Q_stricmp(args[2], "auto") != 0))
		// 游戏自动让人物发出该指令时，第三个参数会为 auto
		{
			IPlayerInfo *player = SDKAPI::iPlayerInfoManager->GetPlayerInfo(pEntity);
			if (player->IsPlayer() && player->GetTeamIndex() == 2
			&& !player->IsFakeClient() && !player->IsDead())
			{
				PL_DevMsg("%s PlayerPing\n", player->GetName());
				SDKAPI::L4D2_RunScript("::LinPlayerPing(%d);", player->GetUserID());
			}
		}
	}

	return PLUGIN_CONTINUE;
}

// 插件控制台变量发生改变
void LinGe_VScripts::OnLookPingChanged(IConVar *var, const char *pOldValue, float flOldValue)
{
	g_bLookPing = cv_lookPing.GetBool();
}
void LinGe_VScripts::OnTimeFormatChanged(IConVar *var, const char *pOldValue, float flOldValue)
{
	strncpy(g_sTimeFormat, cv_format.GetString(), sizeof(g_sTimeFormat) - 1);
	g_sTimeFormat[sizeof(g_sTimeFormat) - 1] = '\0';
}

void LinGe_VScripts::Pause(void) {}
void LinGe_VScripts::UnPause(void) {}
void LinGe_VScripts::ClientActive(edict_t *pEntity) {}
void LinGe_VScripts::ClientDisconnect(edict_t *pEntity) {}
void LinGe_VScripts::OnQueryCvarValueFinished(QueryCvarCookie_t iCookie, edict_t *pPlayerEntity,
	EQueryCvarValueStatus eStatus, const char *pCvarName, const char *pCvarValue) {}
void LinGe_VScripts::ClientPutInServer(edict_t *pEntity, const char *playername) {}
void LinGe_VScripts::SetCommandClient(int index) {
	m_iClientCommandIndex = index;
}
void LinGe_VScripts::ClientSettingsChanged(edict_t *pEdict) {}
PLUGIN_RESULT LinGe_VScripts::ClientConnect(bool *bAllowConnect, edict_t *pEntity, const char *pszName, const char *pszAddress, char *reject, int maxrejectlen) {
	return PLUGIN_CONTINUE;
}
PLUGIN_RESULT LinGe_VScripts::NetworkIDValidated(const char *pszUserName, const char *pszNetworkID) {
	return PLUGIN_CONTINUE;
}
void LinGe_VScripts::OnEdictAllocated(edict_t *edict) {}
void LinGe_VScripts::OnEdictFreed(const edict_t *edict) {}