#pragma once
#include <engine/iserverplugin.h>
#include <game/server/iplayerinfo.h>
#include <toolframework/itoolentity.h>
#include <eiface.h>
#include <tier1.h>
#define PLNAME	"LinGe_VScripts"
#define PLVER	"v2.0"

#define _Msg(format, ...)		Msg(PLNAME " Msg : " format, ## __VA_ARGS__)
#define _Warning(format, ...)	Warning(PLNAME " Warning : " format, ## __VA_ARGS__)
#define _Error(format, ...)		Error(PLNAME " Error : " format, ## __VA_ARGS__)

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
	int m_iMaxClients;

protected:
	bool m_bIsFristStart;
};

// 通过向实体 logic_script 发送实体输入执行 vscripts 脚本代码
bool L4D2_RunScript(const char *sCode);
// sv_maxplayers 发生改变
void OnSvMaxplayersChanged(IConVar *var, const char *pOldValue, float flOldValue);
// 插件控制台变量发生改变
void OnFormatCvarChanged(IConVar *var, const char *pOldValue, float flOldValue);