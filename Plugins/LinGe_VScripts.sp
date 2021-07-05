#pragma semicolon 1
#pragma newdecls required
#include <builtinvotes>
#include <LinGe_Function>

#define CV_BUFFER "linge_vscripts_buffer"
ConVar cv_buffer;
#include "modules/HUD.sp"
#include "modules/MoreSI.sp"

public Plugin myinfo = {
	name = "LinGe VScripts 辅助插件",
	author = "LinGe",
	description = "为 LinGe VScripts 提供辅助功能",
	version = "1.0",
	url = "https://github.com/LinGe515"
};

#define STRSIZE 128
#define VOTE_TIME 20

ConVar cv_maxplayers;

bool g_isHUDLoaded = false;
bool g_isMoreSILoaded = false;

public void OnPluginStart()
{
	HUD_ModuleStart();	// HUD辅助模块 控制HUD总开关、排行显示 并提供linge_time变量
	MoreSI_ModuleStart(); // 更改多特控制模式
	// 通过控制台变量来接受脚本执行的结果 这是参考left4dhooks的脚本函数调用方式
	cv_maxplayers = FindConVar("sv_maxplayers");
	cv_buffer = CreateConVar(CV_BUFFER, "", "接受脚本函数执行结果的buffer", FCVAR_SERVER_CAN_EXECUTE);
	// cv_hud和cv_moresi两个变量主要交给脚本来控制 当对应脚本模块载入时，会将对应变量改为1
	RegConsoleCmd("sm_vshelp", Cmd_vshelp, "LinGe VScripts 脚本控制投票菜单"); // 总投票菜单控制指令
	RegConsoleCmd("sm_hudhelp", Cmd_hudhelp, "LinGe VScripts HUD 控制投票菜单"); // hudhelp
	RegConsoleCmd("sm_sihelp", Cmd_sihelp, "LinGe VScripts MoreSI 控制投票菜单"); // moresihelp

	if (null != cv_maxplayers)
		cv_maxplayers.AddChangeHook(MaxplayersChanged);
}

public void OnMapStart()
{
	g_isHUDLoaded = false;
	g_isMoreSILoaded = false;
	Ret_L4D2_RunScript("getroottable().rawin(\"LinGe\")", CV_BUFFER);
	if (cv_buffer.BoolValue)
	{
		Ret_L4D2_RunScript("::LinGe.rawin(\"HUD\")", CV_BUFFER);
		if (cv_buffer.BoolValue)
			g_isHUDLoaded = true;
		Ret_L4D2_RunScript("::LinGe.rawin(\"MoreSI\")", CV_BUFFER);
		if (cv_buffer.BoolValue)
			g_isMoreSILoaded = true;
	}
}

// 因为脚本无法自己检测到sv_maxplayers的变动，所以需要插件来辅助对内部数据进行更新
public void MaxplayersChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	Ret_L4D2_RunScript("getroottable().rawin(\"LinGe\")", CV_BUFFER);
	if (cv_buffer.BoolValue)
		L4D2_RunScript("::LinGe.Base.UpdateMaxplayers()");
}

public Action Cmd_vshelp(int client, int args)
{
	if (g_isHUDLoaded || g_isMoreSILoaded)
	{
		Menu menu = new Menu(VSHelpMenuHandler);
		if (g_isHUDLoaded)
			HUD_MenuItem(menu);
		if (g_isMoreSILoaded)
			MoreSI_MenuItem(menu);
		menu.SetTitle("功能控制");
		menu.Display(client, MENU_TIME_FOREVER);
	}
}
public Action Cmd_hudhelp(int client, int args)
{
	if (g_isHUDLoaded)
	{
		Menu menu = new Menu(VSHelpMenuHandler);
		HUD_MenuItem(menu);
		menu.SetTitle("HUD控制");
		menu.Display(client, MENU_TIME_FOREVER);
	}
}
public Action Cmd_sihelp(int client, int args)
{
	if (g_isMoreSILoaded)
	{
		Menu menu = new Menu(VSHelpMenuHandler);
		MoreSI_MenuItem(menu);
		menu.SetTitle("多特控制");
		menu.Display(client, MENU_TIME_FOREVER);
	}
}

public int VSHelpMenuHandler(Menu menu, MenuAction action, int client, int selected)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char modules[STRSIZE], disp[STRSIZE];
			Menu towMenu = new Menu(VSHelpTwoMenuHandler);
			menu.GetItem(selected, modules, sizeof(modules), _, disp, sizeof(disp));
			towMenu.SetTitle(disp);
			towMenu.ExitBackButton = true;
			if (strcmp(modules, "MoreSI") == 0)
			{
				MoreSI_TowMenuItem(disp, towMenu);
				towMenu.Display(client, MENU_TIME_FOREVER);
			}
			else if (strcmp(modules, "HUD") == 0)
			{
				HUD_TowMenuItem(disp, towMenu);
				towMenu.Display(client, MENU_TIME_FOREVER);
			}
			else
			{
				StartVote(client, disp, modules);
				delete towMenu;
			}
		}
		case MenuAction_End:
			delete menu;
	}
	return 0;
}

public int VSHelpTwoMenuHandler(Menu menu, MenuAction action, int client, int selected)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char code[STRSIZE], title[STRSIZE], disp[STRSIZE];
			menu.GetItem(selected, code, sizeof(code), _, disp, sizeof(disp));
			menu.GetTitle(title, sizeof(title));
			char codeName[STRSIZE];
			FormatEx(codeName, sizeof(codeName), "%s[%s]", title, disp);
			StartVote(client, codeName, code);
		}
		case MenuAction_Cancel:
		{
			if( selected == MenuCancel_ExitBack )
				ClientCommand(client, "sm_vshelp");
		}
		case MenuAction_End:
			delete menu;
	}
	return 0;
}

// 发起投票
Handle g_voteExt;
char g_disp[STRSIZE], g_code[STRSIZE];
void StartVote(int client, const char[] disp, const char[] code)
{
	if (GetClientTeam(client) == 1)
	{
		PrintToChat(client, "\x04旁观者不能发起投票");
		return;
	}
	if (!IsNewBuiltinVoteAllowed())
	{
		PrintToChat(client, "\x04暂时还不能发起新投票");
		return;
	}

	strcopy(g_disp, sizeof(g_disp), disp);
	strcopy(g_code, sizeof(g_code), code);

	int[] clients = new int[MaxClients];
	int count = 0;
	for (int i=1; i<=MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i) || (GetClientTeam(i) == 1))
			continue;
		clients[count++] = i;
	}

	// 开始发起投票
	char sBuffer[STRSIZE];
	FormatEx(sBuffer, sizeof(sBuffer), "是否同意执行 %s ?", g_disp);
	g_voteExt = CreateBuiltinVote(Vote_ActionHandler_Ext, BuiltinVoteType_Custom_YesNo, BuiltinVoteAction_VoteEnd | BuiltinVoteAction_End);
	SetBuiltinVoteArgument(g_voteExt, sBuffer);
	SetBuiltinVoteInitiator(g_voteExt, client);
	DisplayBuiltinVote(g_voteExt, clients, count, VOTE_TIME);
}

public int Vote_ActionHandler_Ext(Handle vote, BuiltinVoteAction action, int param1, int param2)
{
	char sBuffer[STRSIZE];
	FormatEx(sBuffer, sizeof(sBuffer), "执行 %s ...", g_disp);
	switch (action)
	{
		// 已完成投票
		case BuiltinVoteAction_VoteEnd:
		{
			if (param1 == BUILTINVOTES_VOTE_YES)
			{
				DisplayBuiltinVotePass(vote, sBuffer);
				// 延时3秒再发起换图指令，因为投票通过的显示具有延迟
				CreateTimer(3.0, Delay_ExecCode);
			}
			else if (param1 == BUILTINVOTES_VOTE_NO)
			{
				DisplayBuiltinVoteFail(vote, BuiltinVoteFail_Loses);
			}
			else
			{
				// Should never happen, but is here as a diagnostic
				DisplayBuiltinVoteFail(vote, BuiltinVoteFail_Generic);
				LogMessage("Vote failure. winner = %d", param1);
			}
		}
		// 投票动作结束
		case BuiltinVoteAction_End:
		{
			g_voteExt = INVALID_HANDLE;
			CloseHandle(vote);
		}
	}
}
public Action Delay_ExecCode(Handle timer)
{
	L4D2_RunScript(g_code);
}