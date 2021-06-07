#include <sourcemod>

public Plugin myinfo = {
	name = "报时插件",
	author = "LinGe",
	description = "根据设定自动报时，并创建一个linge_time控制台变量",
	version = "1.0",
	url = "https://github.com/LinGe515"
};

ConVar cv_time;	// linge_time 时间
ConVar cv_style; // linge_time_style 时间输出风格
ConVar cv_date; // linge_time_date 日期到 1日/2月/3年 0：无日期
ConVar cv_hms; // linge_time_hms 时间到 1时/2分/3秒	0：无时间
ConVar cv_interval; // linge_time_interval 报时间隔

char g_timeString[30] = "";	// 时间文本
char g_timeFormat[40] = "";	// 格式化文本
char g_date[2][2][20] = { {"%m-%d ", "%Y-%m-%d "}, { "%m月%d日 ", "%Y年%m月%d日 " } };
char g_hms[2][20] = { "%H:%M", "%H:%M:%S" };

Handle timer_updateTime = INVALID_HANDLE;

public void OnPluginStart()
{
	cv_time		= CreateConVar("linge_time", "", "时间字符串", FCVAR_SERVER_CAN_EXECUTE | FCVAR_PRINTABLEONLY);
	cv_style	= CreateConVar("linge_time_style", "0", "0:YYYY-MM-DD 1:YYYY年MM月DD日", FCVAR_SERVER_CAN_EXECUTE, true, 0.0, true, 1.0);
	cv_date		= CreateConVar("linge_time_date", "1", "日期到 0月/1年 -1：无日期", FCVAR_SERVER_CAN_EXECUTE, true, -1.0, true, 1.0);
	cv_hms		= CreateConVar("linge_time_hms", "1", "时间到 0分/1秒 -1：无时间", FCVAR_SERVER_CAN_EXECUTE, true, -1.0, true, 1.0);
	cv_interval	= CreateConVar("linge_time_interval", "0", "报时间隔，单位：秒，0:不报时。当unix时间戳能被报时间隔整除时，则进行报时。比如设定：60：每分整报时，300：每5分整报时，3600：每小时整报时。", FCVAR_SERVER_CAN_EXECUTE, true, 0.0, true, 3600.0);
	AutoExecConfig(true, "LinGe_time");

	cv_style.AddChangeHook(ConVarChanged);
	cv_date.AddChangeHook(ConVarChanged);
	cv_hms.AddChangeHook(ConVarChanged);
	cv_interval.AddChangeHook(ConVarChanged);
	ReStart();
}

public void ConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	ReStart();
}

public Action TimerUpdateTime(Handle timer)
{
	FormatTime(g_timeString, sizeof(g_timeString), g_timeFormat);
	cv_time.SetString(g_timeString);
	if (cv_interval.IntValue != 0)
	{
		if (0 == (GetTime() % cv_interval.IntValue))
			PrintToChatAll("\x05系统报时： %s", g_timeString);
	}
}

void ReStart()
{
	if (cv_date.IntValue > -1)
		strcopy(g_timeFormat, sizeof(g_timeFormat), g_date[cv_style.IntValue][cv_date.IntValue]);
	if (cv_hms.IntValue > -1)
		Format(g_timeFormat, sizeof(g_timeFormat), "%s%s", g_timeFormat, g_hms[cv_hms.IntValue]);

	if (cv_date.IntValue == -1 && cv_hms.IntValue == -1
		&& timer_updateTime != INVALID_HANDLE )
	{
		KillTimer(timer_updateTime);
		timer_updateTime = INVALID_HANDLE;
	}
	else if (INVALID_HANDLE == timer_updateTime)
		timer_updateTime = CreateTimer(1.0, TimerUpdateTime, _, TIMER_REPEAT);
}