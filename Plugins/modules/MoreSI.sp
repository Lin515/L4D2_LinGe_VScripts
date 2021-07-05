#include <sourcemod>
#include <LinGe_Function>

#define SI_CONFIG_FILE "data/MoreSI.txt"
KeyValues SI_Config;

void MoreSI_ModuleStart()
{
	SI_Config = new KeyValues("SI_Config");
	char filePath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, filePath, sizeof(filePath), SI_CONFIG_FILE);
	if (FileExists(filePath))
	{
		if (!SI_Config.ImportFromFile(filePath))
			SetFailState("导入 %s 失败！", filePath);
	}
	else
		CreateConfig(filePath);
}


#define SINUM	"特感数量"
#define SITIME	"特感复活"
#define SIONLY	"特感类型"
void MoreSI_MenuItem(Menu menu)
{
	Ret_L4D2_RunScript("::LinGe.MoreSI.Config.enabled", CV_BUFFER);
	if (cv_buffer.BoolValue)
		menu.AddItem("::LinGe.MoreSI.Cmd_sioff(null,[null])", "关闭特感控制");
	Ret_L4D2_RunScript("::LinGe.MoreSI.Config.noci", CV_BUFFER);
	if (cv_buffer.BoolValue)
		menu.AddItem("::LinGe.MoreSI.Cmd_noci(null,[null,\"off\"])", "关闭无小僵尸");
	else
		menu.AddItem("::LinGe.MoreSI.Cmd_sion(null,[null,-2,-2,-2,\"on\"])", "开启无小僵尸");
	menu.AddItem("MoreSI", SINUM);
	menu.AddItem("MoreSI", SITIME);
	menu.AddItem("MoreSI", SIONLY);
}

// Menu
void MoreSI_TowMenuItem(const char[] disp, Menu menu)
{
	char display[128], code[128];
	if (strcmp(disp, SINUM) == 0)
	{
		Ret_L4D2_RunScript("::LinGe.MoreSI.Config.sibase>=0", CV_BUFFER);
		if (cv_buffer.BoolValue)
			menu.AddItem("::LinGe.MoreSI.Cmd_sibase(null,[null,-1])", "关闭数量控制");
		SI_Config.Rewind();
		if (SI_Config.GotoFirstSubKey())
		{
			do
			{
				SI_Config.GetString("display", display, sizeof(display), "_NULL_");
				SI_Config.GetString("code", code, sizeof(code), "_NULL_");
				if (strcmp(display, "_NULL_") != 0
				&& strcmp(code, "_NULL_") != 0)
					menu.AddItem(code, display);
			}
			while (SI_Config.GotoNextKey());
		}
	}
	else if (strcmp(disp, SITIME) == 0)
	{
		Ret_L4D2_RunScript("::LinGe.MoreSI.Config.sitime>=0", CV_BUFFER);
		if (cv_buffer.BoolValue)
			menu.AddItem("::LinGe.MoreSI.Cmd_sitime(null,[null,-1])", "关闭复活控制");
		for (int i=0; i<26; i++)
		{
			FormatEx(display, sizeof(display), "%d 秒", i);
			FormatEx(code, sizeof(display), "::LinGe.MoreSI.Cmd_sion(null,[null,-2,-2,%d])", i);
			menu.AddItem(code, display);
		}
	}
	else if (strcmp(disp, SIONLY) == 0)
	{
		Ret_L4D2_RunScript("::LinGe.MoreSI.Config.sionly.len()>0", CV_BUFFER);
		if (cv_buffer.BoolValue)
			menu.AddItem("::LinGe.MoreSI.Cmd_sionly(null,[null,0])", "取消特感限制");
		menu.AddItem("::LinGe.MoreSI.Cmd_sion(null,[null,-2,-2,-2,-2,\"Boomer\"])", "只生成Boomer");
		menu.AddItem("::LinGe.MoreSI.Cmd_sion(null,[null,-2,-2,-2,-2,\"Spitter\"])", "只生成Spitter");
		menu.AddItem("::LinGe.MoreSI.Cmd_sion(null,[null,-2,-2,-2,-2,\"Smoker\"])", "只生成Smoker");
		menu.AddItem("::LinGe.MoreSI.Cmd_sion(null,[null,-2,-2,-2,-2,\"Hunter\"])", "只生成Hunter");
		menu.AddItem("::LinGe.MoreSI.Cmd_sion(null,[null,-2,-2,-2,-2,\"Charger\"])", "只生成Charger");
		menu.AddItem("::LinGe.MoreSI.Cmd_sion(null,[null,-2,-2,-2,-2,\"Jockey\"])", "只生成Jockey");
	}
}


// 创建多特控制配置文件
void CreateConfig(const char[] filePath)
{
	// 直接调用Cmd_sion 部分参数直接输入null即可
	// 也可以伪装成正常的指令调用 例如 ::LinGe.MoreSI.Cmd_sion(\"server\", [\"sion\",\"0\",\"1\",\"-1\"])
	SI_Config.JumpToKey("1", true); // Key 名随意设置 只要不重复即可
	SI_Config.SetString("display", "固定8特");
	SI_Config.SetString("code", "::LinGe.MoreSI.Cmd_sion(null,[null,8,0])");
	SI_Config.Rewind();

	SI_Config.JumpToKey("2", true);
	SI_Config.SetString("display", "固定12特");
	SI_Config.SetString("code", "::LinGe.MoreSI.Cmd_sion(null,[null,12,0])");
	SI_Config.Rewind();

	SI_Config.JumpToKey("3", true);
	SI_Config.SetString("display", "固定16特");
	SI_Config.SetString("code", "::LinGe.MoreSI.Cmd_sion(null,[null,16,0])");
	SI_Config.Rewind();

	SI_Config.JumpToKey("4", true);
	SI_Config.SetString("display", "固定20特");
	SI_Config.SetString("code", "::LinGe.MoreSI.Cmd_sion(null,[null,20,0])");
	SI_Config.Rewind();

	SI_Config.JumpToKey("5", true);
	SI_Config.SetString("display", "固定24特");
	SI_Config.SetString("code", "::LinGe.MoreSI.Cmd_sion(null,[null,24,0])");
	SI_Config.Rewind();

	SI_Config.JumpToKey("6", true);
	SI_Config.SetString("display", "1生还1特");
	SI_Config.SetString("code", "::LinGe.MoreSI.Cmd_sion(null,[null,0,1])");
	SI_Config.Rewind();

	SI_Config.JumpToKey("7", true);
	SI_Config.SetString("display", "1生还2特");
	SI_Config.SetString("code", "::LinGe.MoreSI.Cmd_sion(null,[null,0,2])");
	SI_Config.Rewind();

	SI_Config.JumpToKey("8", true);
	SI_Config.SetString("display", "1生还3特");
	SI_Config.SetString("code", "::LinGe.MoreSI.Cmd_sion(null,[null,0,3])");
	SI_Config.Rewind();

	SI_Config.JumpToKey("9", true);
	SI_Config.SetString("display", "4特1自增");
	SI_Config.SetString("code", "::LinGe.MoreSI.Cmd_sion(null,[null,4,1])");
	SI_Config.Rewind();

	SI_Config.JumpToKey("10", true);
	SI_Config.SetString("display", "4特2自增");
	SI_Config.SetString("code", "::LinGe.MoreSI.Cmd_sion(null,[null,4,2])");
	SI_Config.Rewind();

	SI_Config.JumpToKey("11", true);
	SI_Config.SetString("display", "8特1自增");
	SI_Config.SetString("code", "::LinGe.MoreSI.Cmd_sion(null,[null,8,1])");
	SI_Config.Rewind();

	SI_Config.JumpToKey("12", true);
	SI_Config.SetString("display", "8特2自增");
	SI_Config.SetString("code", "::LinGe.MoreSI.Cmd_sion(null,[null,8,2])");
	SI_Config.Rewind();

	SI_Config.ExportToFile(filePath);
}