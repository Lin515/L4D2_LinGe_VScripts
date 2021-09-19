#include <stdio.h>
#include <time.h>
#include <cstdint>
#include "LinGe_VScripts.h"
#include "MemoryUtils/MemoryUtils.h"
#include "signature.h"
#include <variant_t.h>
#include <string_t.h>

LinGe_VScripts g_plugin;
EXPOSE_SINGLE_INTERFACE_GLOBALVAR(LinGe_VScripts, IServerPluginCallbacks, INTERFACEVERSION_ISERVERPLUGINCALLBACKS, g_plugin);

// Interface
ICvar *g_pCvar = nullptr;
IPlayerInfoManager *g_pPlayerInfoManager = nullptr;
IServerGameEnts *g_pServerGameEnts = nullptr;
IVEngineServer *g_pVEngineServer = nullptr;
IServerTools *g_pServerTools = nullptr;
IServerGameDLL *g_pServerGameDLL = nullptr;
CGlobalVars *g_pGlobals = nullptr;

// ConVar
ConVar *cv_pSvMaxplayers = nullptr;
ConVar cv_time("linge_time", "", FCVAR_PRINTABLEONLY, "服务器系统时间，每秒更新一次");
ConVar cv_format("linge_time_format", "%Y-%m-%d %H:%M:%S", FCVAR_SERVER_CAN_EXECUTE, "linge_time 格式化字符串，如需修改请参见此文:https://www.runoob.com/cprogramming/c-function-strftime.html", false, 0.0, false, 0.0, OnFormatCvarChanged);
char g_sTimeFormat[50] = "%Y-%m-%d %H:%M:%S";

MemoryUtils mu_engine;
MemoryUtils mu_server;
void *g_pEntList = nullptr;

FINDENTITYBYCLASSNAME FindEntityByClassname = nullptr;

LinGe_VScripts::LinGe_VScripts() :
	m_iMaxClients(0),
	m_bIsFristStart(true)
{
}
LinGe_VScripts::~LinGe_VScripts() {}

bool LinGe_VScripts::Load(CreateInterfaceFn interfaceFactory, CreateInterfaceFn gameServerFactory)
{
	ConnectTier1Libraries(&interfaceFactory, 1);

	// hl2sdk-l4d2 接口
	g_pCvar = reinterpret_cast<ICvar *>(interfaceFactory(CVAR_INTERFACE_VERSION, nullptr));
	g_pPlayerInfoManager = reinterpret_cast<IPlayerInfoManager *>(gameServerFactory(INTERFACEVERSION_PLAYERINFOMANAGER, nullptr));
	g_pServerGameEnts = reinterpret_cast<IServerGameEnts *>(gameServerFactory(INTERFACEVERSION_SERVERGAMEENTS, nullptr));
	g_pVEngineServer = reinterpret_cast<IVEngineServer *>(interfaceFactory(INTERFACEVERSION_VENGINESERVER, nullptr));
	g_pServerTools = reinterpret_cast<IServerTools *>(gameServerFactory(VSERVERTOOLS_INTERFACE_VERSION, nullptr));
	g_pServerGameDLL = reinterpret_cast<IServerGameDLL *>(gameServerFactory(INTERFACEVERSION_SERVERGAMEDLL, nullptr));
	if (!g_pCvar)
		_Error("ICvar interface initialization failed.");
	if (!g_pPlayerInfoManager)
		_Error("IPlayerInfoManager interface initialization failed.");
	if (!g_pServerGameEnts)
		_Error("IServerGameEnts interface initialization failed.");
	if (!g_pVEngineServer)
		_Error("IVEngineServer interface initialization failed.");
	if (!g_pServerTools)
		_Error("IServerTools interface initialization failed.");
	g_pGlobals = g_pPlayerInfoManager->GetGlobalVars();

	if (!mu_engine.Init(interfaceFactory))
		_Error("CSigScan engine initialization failed.");
	if (!mu_server.Init(gameServerFactory))
		_Error("CSigScan server initialization failed.");

	// 初始化 FindEntityByClassname
	FindEntityByClassname = reinterpret_cast<FINDENTITYBYCLASSNAME>(mu_server.FindSignature(Sig_FindEntityByClassname));
	if (!FindEntityByClassname)
		_Error("FindEntityByClassname signature not found.");

	// 初始化 g_pEntList 获取方法参考 sourcemod/core/HalfLife2.cpp
	// Win32下是通过LevelShutdown函数地址再加上偏移量获得g_pEntityList(指向g_pEntList的指针)的地址
	// Linux下是直接通过符号查找获得g_pEntList的地址
#ifdef WIN32
	void *LevelShutdown = nullptr;
	LevelShutdown = mu_server.FindSignature(Sig_LevelShutdown);
	if (!LevelShutdown)
		_Error("LevelShutdown signature not found.");
	g_pEntList = *reinterpret_cast<void **>((char *)LevelShutdown + Offset_gEntList_windows);
#else
	g_pEntList = mu_server.FindSignature(Sig_gEntList);
	if (!g_pEntList)
		_Error("gEntList signature not found.");
#endif

	ConVar_Register();
	_Msg("Loaded.\n");
	return true;
}
void LinGe_VScripts::Unload(void)
{
	ConVar_Unregister();
	DisconnectTier1Libraries();
}

const char *LinGe_VScripts::GetPluginDescription(void) {
	return PLNAME " " PLVER " By LinGe";
}

void LinGe_VScripts::ServerActivate(edict_t *pEdictList, int edictCount, int clientMax)
{
	// sv_maxplayers 参数是 l4dtoolz 插件创建的，其通过 metamod 加载
	// 本插件一定比 l4dtoolz 先载入，所以不能在插件载入时就去获取 sv_maxplayers
	m_iMaxClients = clientMax;
	if (m_bIsFristStart)
	{
		cv_pSvMaxplayers = g_pCvar->FindVar("sv_maxplayers");
		if (nullptr != cv_pSvMaxplayers)
		{
			cv_pSvMaxplayers->InstallChangeCallback(OnSvMaxplayersChanged);
		}
		m_bIsFristStart = false;
	}
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

// 不需要用的
void LinGe_VScripts::Pause(void) {}
void LinGe_VScripts::UnPause(void) {}
void LinGe_VScripts::LevelInit(char const *pMapName) {}
void LinGe_VScripts::LevelShutdown(void) {}
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
PLUGIN_RESULT LinGe_VScripts::ClientCommand(edict_t *pEntity, const CCommand &args) {
	return PLUGIN_CONTINUE;
}
PLUGIN_RESULT LinGe_VScripts::NetworkIDValidated(const char *pszUserName, const char *pszNetworkID) {
	return PLUGIN_CONTINUE;
}
void LinGe_VScripts::OnEdictAllocated(edict_t *edict) {}
void LinGe_VScripts::OnEdictFreed(const edict_t *edict) {}

// 通过向实体 logic_script 发送实体输入执行 vscripts 脚本代码
// 代码参考 Silver https://forums.alliedmods.net/showthread.php?p=2657025
// 控制台指令script具有相同的功能 不过script是cheats指令
// 并且据Silvers所说script指令似乎存在内存泄漏 所以通过实体来执行代码更优一点
bool L4D2_RunScript(const char *sCode)
{
	static variant_t var;
	void *pScriptLogic = FindEntityByClassname(g_pEntList, nullptr, "logic_script");
	edict_t *edict = g_pServerGameEnts->BaseEntityToEdict((CBaseEntity *)pScriptLogic);
	if (!edict || edict->IsFree())
	{
		pScriptLogic = g_pServerTools->CreateEntityByName("logic_script");
		if (!pScriptLogic)
		{
			_Warning("Could not create entity 'logic_script'.\n");
			return false;
		}
		g_pServerTools->DispatchSpawn(pScriptLogic);
	}
	ACCEPTINPUT AcceptInput = reinterpret_cast<ACCEPTINPUT>(GetVirtualFunction(pScriptLogic, VTI_AcceptInput));
	castable_string_t str(sCode);
	var.SetString(str);
	return AcceptInput(pScriptLogic, "RunScriptCode", nullptr, nullptr, var, 0);
}

// sv_maxplayers 发生改变
void OnSvMaxplayersChanged(IConVar *var, const char *pOldValue, float flOldValue)
{
	if (!L4D2_RunScript("::LinGe.Base.UpdateMaxplayers()"))
		_Warning("L4D2_RunScript ::LinGe.Base.UpdateMaxplayers() Failed\n");
}

// 插件控制台变量发生改变
void OnFormatCvarChanged(IConVar *var, const char *pOldValue, float flOldValue)
{
	strncpy(g_sTimeFormat, cv_format.GetString(), sizeof(g_sTimeFormat));
}
