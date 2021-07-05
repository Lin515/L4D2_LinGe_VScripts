#include <sourcemod>
#include <LinGe_Function>

ConVar cv_time;	// linge_time
ConVar cv_format; // linge_time_format
#define DEFAULT_FORMAT "%Y-%m-%d %H:%M:%S"
static char g_timeFormat[50] = DEFAULT_FORMAT;	// 格式化文本

void HUD_ModuleStart()
{
	cv_time		= CreateConVar("linge_time", "", "时间字符串", FCVAR_PRINTABLEONLY);
	cv_format	= CreateConVar("linge_time_format", DEFAULT_FORMAT, "格式化字符串，请勿在不了解的情况下随意修改它。具体用法请参见 https://www.runoob.com/cprogramming/c-function-strftime.html", FCVAR_SERVER_CAN_EXECUTE);
	cv_format.AddChangeHook(FormatChanged);
	CreateTimer(1.0, Timer_UpdateTime, _, TIMER_REPEAT);
}

public void FormatChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	strcopy(g_timeFormat, sizeof(g_timeFormat), newValue);
}

public Action Timer_UpdateTime(Handle timer)
{
	static char buffer[50] = "";
	FormatTime(buffer, sizeof(buffer), g_timeFormat);
	cv_time.SetString(buffer);
}

void HUD_MenuItem(Menu menu)
{
	Ret_L4D2_RunScript("::LinGe.HUD.Config.isShowHUD", CV_BUFFER);
	if (cv_buffer.BoolValue)
		menu.AddItem("::LinGe.HUD.Cmd_hud(null,[null,\"off\"])", "关闭HUD");
	else
		menu.AddItem("::LinGe.HUD.Cmd_hud(null,[null,\"on\"])", "打开HUD");

	menu.AddItem("HUD", "设置排行");
}

// Menu
void HUD_TowMenuItem(const char[] disp, Menu menu)
{
	char display[128], code[128];
	if (strcmp(disp, "设置排行") == 0)
	{
		menu.AddItem("::LinGe.HUD.Cmd_rank(null,[null,0])", "关闭排行");
		for (int i=1; i<9; i++)
		{
			FormatEx(display, sizeof(display), "显示前%d", i);
			FormatEx(code, sizeof(display), "::LinGe.HUD.Cmd_rank(null,[null,%d])", i);
			menu.AddItem(code, display);
		}
	}
}