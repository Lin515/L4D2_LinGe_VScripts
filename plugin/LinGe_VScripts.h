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
#pragma once
#include <engine/iserverplugin.h>
#include <tier1.h>
#define PLNAME	"LinGe_VScripts"
#define PLVER	"v2.0"

#define _Msg(format, ...)		Msg(PLNAME " Msg: " format, ## __VA_ARGS__)
#define _Warning(format, ...)	Warning(PLNAME " Warning: " format, ## __VA_ARGS__)
#define _Error(format, ...)		Error(PLNAME " Error: " format, ## __VA_ARGS__)

class LinGe_VScripts : public IServerPluginCallbacks
{
public:
	LinGe_VScripts();
	~LinGe_VScripts();

	// IServerPluginCallbacks methods
	virtual bool			Load(CreateInterfaceFn interfaceFactory, CreateInterfaceFn gameServerFactory);
	virtual void			Unload(void);
	virtual void			Pause(void);
	virtual void			UnPause(void);
	virtual const char *GetPluginDescription(void);
	virtual void			LevelInit(char const *pMapName);
	virtual void			ServerActivate(edict_t *pEdictList, int edictCount, int clientMax);
	virtual void			GameFrame(bool simulating);
	virtual void			LevelShutdown(void);
	virtual void			ClientActive(edict_t *pEntity);
	virtual void			ClientDisconnect(edict_t *pEntity);
	virtual void			ClientPutInServer(edict_t *pEntity, char const *playername);
	virtual void			SetCommandClient(int index);
	virtual void			ClientSettingsChanged(edict_t *pEdict);
	virtual PLUGIN_RESULT	ClientConnect(bool *bAllowConnect, edict_t *pEntity, const char *pszName, const char *pszAddress, char *reject, int maxrejectlen);
	virtual PLUGIN_RESULT	ClientCommand(edict_t *pEntity, const CCommand &args);
	virtual PLUGIN_RESULT	NetworkIDValidated(const char *pszUserName, const char *pszNetworkID);
	virtual void			OnQueryCvarValueFinished(QueryCvarCookie_t iCookie, edict_t *pPlayerEntity, EQueryCvarValueStatus eStatus, const char *pCvarName, const char *pCvarValue);

	// added with version 3 of the interface.
	virtual void			OnEdictAllocated(edict_t *edict);
	virtual void			OnEdictFreed(const edict_t *edict);

public:
	static int GetFnChangeCallbackOffset(ConVar *var, FnChangeCallback_t callback);
	static void OnSvMaxplayersChanged(IConVar *var, const char *pOldValue, float flOldValue);
	static void OnTimeFormatChanged(IConVar *var, const char *pOldValue, float flOldValue);

public:
	static int iFnChangeCallbackOffset;
	static FnChangeCallback_t SvMaxplayersCallback;

	int m_iMaxClients;

protected:
	bool m_bIsFristStart;
};

extern ConVar *cv_pSvMaxplayers;
extern ConVar cv_time;
extern ConVar cv_format;
