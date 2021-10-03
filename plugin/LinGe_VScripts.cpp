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
#include <stdio.h>
#include <time.h>
#include <cstdint>
#include "LinGe_VScripts.h"
#include "sdkapi/sdkapi.h"

LinGe_VScripts plugin;
EXPOSE_SINGLE_INTERFACE_GLOBALVAR(LinGe_VScripts, IServerPluginCallbacks, INTERFACEVERSION_ISERVERPLUGINCALLBACKS, plugin);

// ConVar
ConVar *cv_pSvMaxplayers = nullptr;
ConVar cv_time("linge_time", "", FCVAR_PRINTABLEONLY, "Server system time.");
ConVar cv_format("linge_time_format", "%Y-%m-%d %H:%M:%S", FCVAR_SERVER_CAN_EXECUTE, "linge_time format string, see also:https://www.runoob.com/cprogramming/c-function-strftime.html", false, 0.0, false, 0.0, LinGe_VScripts::OnTimeFormatChanged);
char g_sTimeFormat[50] = "%Y-%m-%d %H:%M:%S";

LinGe_VScripts::LinGe_VScripts() :
	m_iMaxClients(0),
	m_bIsFristStart(true)
{
}
LinGe_VScripts::~LinGe_VScripts() {}

bool LinGe_VScripts::Load(CreateInterfaceFn interfaceFactory, CreateInterfaceFn gameServerFactory)
{
	SDKAPI::Initialize(interfaceFactory, gameServerFactory);

	ConVar_Register();

	_Msg("Loaded.\n");
	return true;
}
void LinGe_VScripts::Unload(void)
{
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

void LinGe_VScripts::ServerActivate(edict_t *pEdictList, int edictCount, int clientMax)
{
	m_iMaxClients = clientMax;
	// sv_maxplayers 参数是 l4dtoolz 插件创建的，其通过 metamod 加载
	// 本插件一定比 l4dtoolz 先载入，所以不能在插件载入时就去获取 sv_maxplayers
	if (m_bIsFristStart)
	{
		iFnChangeCallbackOffset = GetFnChangeCallbackOffset(&cv_format, LinGe_VScripts::OnTimeFormatChanged);
		// 如果不能找到偏移地址，则不应安装自己的callback，否则将导致l4dtoolz功能失效
		if (iFnChangeCallbackOffset > -1)
		{
			DevMsg("ConVar::m_fnChangeCallback Offset %d\n", iFnChangeCallbackOffset);
			cv_pSvMaxplayers = SDKAPI::iCvar->FindVar("sv_maxplayers");
			if (cv_pSvMaxplayers)
			{
				// 保存原有callback，然后安装自己的callback
				SvMaxplayersCallback = *reinterpret_cast<FnChangeCallback_t *>
					(reinterpret_cast<char *>(cv_pSvMaxplayers) + iFnChangeCallbackOffset);
				cv_pSvMaxplayers->InstallChangeCallback(LinGe_VScripts::OnSvMaxplayersChanged);
			}
		}
		m_bIsFristStart = false;
	}
}

/* 提供一个ConVar与其已安装的callback地址 以查找其成员变量 m_fnChangeCallback 的偏移量
*  因为 m_fnChangeCallback 是私有成员，且类没有提供获取该成员值的函数，所以只能通过偏门获取了
*/
int LinGe_VScripts::iFnChangeCallbackOffset = -1;
int LinGe_VScripts::GetFnChangeCallbackOffset(ConVar *var, FnChangeCallback_t callback)
{
	char *ptr1 = reinterpret_cast<char *>(var);
	FnChangeCallback_t *ptr2 = nullptr;

	// 在对象基址+200以内查找，查找范围不宜过大
	// 在我写这个函数时，Windows上查找到的偏移地址为68
	for (int i = 0; i < 200; i++)
	{
		ptr2 = reinterpret_cast<FnChangeCallback_t *>(ptr1++);
		if (*ptr2 == callback)
			return i;
	}
	return -1;
}

// sv_maxplayers 发生改变
FnChangeCallback_t LinGe_VScripts::SvMaxplayersCallback = nullptr;
void LinGe_VScripts::OnSvMaxplayersChanged(IConVar *var, const char *pOldValue, float flOldValue)
{
	SvMaxplayersCallback(var, pOldValue, flOldValue);
	if (!SDKAPI::L4D2_RunScript("::LinGe.Base.UpdateMaxplayers()"))
		_Warning("L4D2_RunScript ::LinGe.Base.UpdateMaxplayers() Failed\n");
}

// 插件控制台变量发生改变
void LinGe_VScripts::OnTimeFormatChanged(IConVar *var, const char *pOldValue, float flOldValue)
{
	strncpy(g_sTimeFormat, cv_format.GetString(), sizeof(g_sTimeFormat) - 1);
	g_sTimeFormat[sizeof(g_sTimeFormat) - 1] = '\0';
}

PLUGIN_RESULT LinGe_VScripts::ClientCommand(edict_t *pEntity, const CCommand &args) {
	return PLUGIN_CONTINUE;
}
void LinGe_VScripts::LevelInit(char const *pMapName) {}
void LinGe_VScripts::LevelShutdown(void) {}
void LinGe_VScripts::Pause(void) {}
void LinGe_VScripts::UnPause(void) {}
void LinGe_VScripts::ClientActive(edict_t *pEntity) {}
void LinGe_VScripts::ClientDisconnect(edict_t *pEntity) {}
void LinGe_VScripts::OnQueryCvarValueFinished(QueryCvarCookie_t iCookie, edict_t *pPlayerEntity,
	EQueryCvarValueStatus eStatus, const char *pCvarName, const char *pCvarValue) {}
void LinGe_VScripts::ClientPutInServer(edict_t *pEntity, const char *playername) {}
void LinGe_VScripts::SetCommandClient(int index) {}
void LinGe_VScripts::ClientSettingsChanged(edict_t *pEdict) {}
PLUGIN_RESULT LinGe_VScripts::ClientConnect(bool *bAllowConnect, edict_t *pEntity, const char *pszName, const char *pszAddress, char *reject, int maxrejectlen) {
	return PLUGIN_CONTINUE;
}
PLUGIN_RESULT LinGe_VScripts::NetworkIDValidated(const char *pszUserName, const char *pszNetworkID) {
	return PLUGIN_CONTINUE;
}
void LinGe_VScripts::OnEdictAllocated(edict_t *edict) {}
void LinGe_VScripts::OnEdictFreed(const edict_t *edict) {}
