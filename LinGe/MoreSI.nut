if ( "coop" == g_BaseMode ) {
const MORESIVER = "1.4";
printl("[LinGe] 简易多特控制 v" + MORESIVER +" 正在载入");
::LinGe.MoreSI <- {};

local sitypelist = ["Boomer", "Spitter", "Smoker", "Hunter", "Charger", "Jockey"];
::LinGe.MoreSI.Config <- {
	enabled = false, // 多特控制总开关
	simin = 4, // 最小特感数量
	sibase = -1, // 基础特感数量 若设定为 < 0 则单独关闭特感数量控制
	siauto = 0, // 每1名玩家增加多少特感 在基础特感数量上增加 为0则不自动增加
	sitime = -1, // 特感刷新间隔 若设定为 < 0 则单独关闭特感刷新时间控制
	sionly = [], // 只允许生成哪些特感，若数组为空则不限制
	noci = false // 是否清除小僵尸
};
::LinGe.Config.Add("MoreSI", ::LinGe.MoreSI.Config);
::Cache.MoreSI_Cache <- ::LinGe.MoreSI.Config;
// 在配置未生效之前将 Config.enabled 临时设置为 false
local _enabled = ::LinGe.MoreSI.Config.enabled; // 此时 enabled 的值为配置文件中的值
::LinGe.MoreSI.Config.enabled = false;

// 按照Config设置特感数量和刷新时间
::LinGe.MoreSI.ExecConfig <- function ()
{
	// 判断哪些控制处于开启
	local ctrlNum = (Config.sibase >= 0);
	local ctrlTime = (Config.sitime >= 0);
	local ctrlNoci = Config.noci;
	Checksionly();
	local ctrlType = ( Config.sionly.len() > 0 );

	if (!Config.enabled)
	{
		ctrlNum = false;
		ctrlTime = false;
		ctrlType = false;
		ctrlNoci = false;
	}

	// 设置特感数量
	if (ctrlNum)
	{
		local autoNum = 0; // 额外特感数量
		if (Config.siauto > 0)
			autoNum = Config.siauto * ::GetPlayers(2).len();

		local simax = Config.sibase + autoNum;
		if (simax < Config.simin)
			simax = Config.simin;
		else if (simax > 31)
			simax = 31;

		::SessionOptions.rawset("cm_MaxSpecials", simax);
		::SessionOptions.rawset("cm_BaseSpecialLimit", ceil(::SessionOptions.cm_MaxSpecials / 5.0) ); // 平均特感数量
		::SessionOptions.rawset("cm_DominatorLimit", ::SessionOptions.cm_MaxSpecials);
	}
	else
	{
		::SessionOptions.rawdelete("cm_MaxSpecials");
		::SessionOptions.rawdelete("cm_BaseSpecialLimit");
		::SessionOptions.rawdelete("cm_DominatorLimit");
	}

	// 设置特感刷新时间
	if (ctrlTime)
	{
		::SessionOptions.rawset("cm_SpecialRespawnInterval",  Config.sitime);
	}
	else
	{
		::SessionOptions.rawdelete("cm_SpecialRespawnInterval");
	}

	// 特感种类控制
	if (ctrlType)
	{
		::SessionOptions.rawset("BoomerLimit", 0);
	 	::SessionOptions.rawset("SpitterLimit", 0);
	 	::SessionOptions.rawset("SmokerLimit", 0);
	 	::SessionOptions.rawset("HunterLimit", 0);
	 	::SessionOptions.rawset("ChargerLimit", 0);
	 	::SessionOptions.rawset("JockeyLimit", 0);

	 	local maxsi = ctrlNum ? ::SessionOptions.cm_MaxSpecials : 4;
	 	::SessionOptions.rawset("cm_BaseSpecialLimit", ceil( 1.0*maxsi / Config.sionly.len() ) ); // 平均特感数量
		::SessionOptions.rawset("cm_DominatorLimit", maxsi);
	 	foreach (val in Config.sionly)
	 		::SessionOptions.rawset(val + "Limit", ::SessionOptions.cm_BaseSpecialLimit);
	}
	else
	{
		::SessionOptions.rawdelete("BoomerLimit");
	 	::SessionOptions.rawdelete("SpitterLimit");
	 	::SessionOptions.rawdelete("SmokerLimit");
	 	::SessionOptions.rawdelete("HunterLimit");
	 	::SessionOptions.rawdelete("ChargerLimit");
	 	::SessionOptions.rawdelete("JockeyLimit");
	 	if (!ctrlNum)
	 	{
		 	::SessionOptions.rawdelete("cm_BaseSpecialLimit");
		 	::SessionOptions.rawdelete("cm_DominatorLimit");
		}
	}

	// 设置无小僵尸
	if (ctrlNoci)
	{
	 	::SessionOptions.rawset("cm_CommonLimit", 0);
	 	::VSLib.Timers.AddTimerByName("AutoKillCI", 1.0, true, Timer_AutoKillCI);
	}
	else
	{
		::SessionOptions.rawdelete("cm_CommonLimit");
		::VSLib.Timers.RemoveTimerByName("AutoKillCI");
	}
}

// 检查数组sionly值的有效性 移除无效值
::LinGe.MoreSI.Checksionly <- function()
{
	local str = "";
	local firstChar = "";
	if ("array" != typeof Config.sionly)
		Config.sionly = [];
	else
	{
		foreach (idx, val in Config.sionly)
		{
			// 如果找不到则将其进行字母转换，再进行查找
			if (null == sitypelist.find(val))
			{
				// 首字母转为大写，其它转成小写
				firstChar = val.slice(0, 1).toupper();
				str = val.slice(1).tolower();
				str = firstChar + str;

				if (null == sitypelist.find(str))
					Config.sionly.remove(idx);
				else
					Config.sionly[idx] = str;
			}
		}
	}
}

// 输出当前设置信息
::LinGe.MoreSI.ShowInfo <- function ()
{
	if (!Config.enabled)
	{
		ClientPrint(null, 3, "\x04多特控制：总开关\x03 关闭");
		return;
	}

	local text = "\x04多特控制：";
	if (Config.sibase >= 0)
		text += "特感数量为\x03 " + ::SessionOptions.cm_MaxSpecials + " \x04，";
	else
		text += "数量控制\x03 关闭 \x04，";
	if (Config.sitime >= 0)
		text += "刷新时间为\x03 " + ::SessionOptions.cm_SpecialRespawnInterval;
	else
		text += "刷新控制为\x03 关闭";
	ClientPrint(null, 3, text);

	if (Config.sionly.len() > 0 || Config.noci)
	{
		text = "\x04多特控制："
		if (Config.sionly.len() > 0)
		{
			local list = "";
			foreach (val in Config.sionly)
				list += val + " ";
			text += "限制只生成特感 \x03" + list;
		}
		else
			text += "限制特感生成 \x03关闭";
		if (Config.noci)
			text += "\x04，无小僵尸 \x03开启";
		else
			text += "\x04，无小僵尸 \x03关闭";
		ClientPrint(null, 3, text);
	}
}

::LinGe.MoreSI.cache_restore <- function (params)
{
	// 如果有有效Cache存在 则使用Cache中的配置
	if (params.isValidCache && ::Cache.rawin("MoreSI_Cache"))
	{
		_enabled = ::Cache.MoreSI_Cache.enabled;
	}
	Config.enabled = false;
}
::EventHook("cache_restore", ::LinGe.MoreSI.cache_restore, ::LinGe.MoreSI);

// 回合开始
::LinGe.MoreSI.OnGameEvent_round_start <- function (params)
{
	Config.enabled = _enabled;
	if (Config.enabled)
	{
		ExecConfig();
		ShowInfo();
	}
}
::EventHook("OnGameEvent_round_start", ::LinGe.MoreSI.OnGameEvent_round_start, ::LinGe.MoreSI);

// 玩家队伍变更 调整特感数量
::LinGe.MoreSI.OnGameEvent_player_team <- function (params)
{
	if (!params.rawin("userid"))
		return;
	// 根据生还者人数调整特感数量
	if ( Config.enabled && Config.sibase >= 0 && Config.siauto > 0 )
	{
		// 只有新加入生还者或生还者完全离开时才更新特感数量
		if ( (0 == params.oldteam && 2 == params.team)
		|| (2 == params.oldteam && 0 == params.team) )
		{
			local oldmax = ::SessionOptions.cm_MaxSpecials;
			// 延迟1.2秒再更新特感数量，避免短时间内多次数量刷新
			::VSLib.Timers.AddTimerByName("SIAUTO", 1.2, false, Delay_siauto, oldmax);
		}
	}
}
::EventHook("OnGameEvent_player_team", ::LinGe.MoreSI.OnGameEvent_player_team, ::LinGe.MoreSI);

::LinGe.MoreSI.Delay_siauto <- function (oldmax)
{
	if (Config.enabled && Config.sibase >= 0 && Config.siauto > 0)
	{
		ExecConfig();
		if (oldmax != ::SessionOptions.cm_MaxSpecials)
			ClientPrint(null, 3, "\x04多特控制：当前特感数量已修改为\x03 " + ::SessionOptions.cm_MaxSpecials);
	}
}.bindenv(::LinGe.MoreSI);

// !si 查看当前多特控制状态
::LinGe.MoreSI.Cmd_si <- function (player, args)
{
	ShowInfo();
}
::CmdAdd("si", ::LinGe.MoreSI.Cmd_si, ::LinGe.MoreSI, false);

// !sion 打开多特控制 同时可以用来一次设置多个值 sibase siauto sitime noci sionly(限制特感类型需用逗号分隔)
// 不修改的数值输入 -2
// 一次正确的用法： !sion 4 1 15 -2 Hunter,Jockey 设置sibase=4,siauto=1,sitime=15,noci不变,sionly=["Hunter", "Jockey"]
::LinGe.MoreSI.Cmd_sion <- function (player, args)
{
	local sibase = -2;
	local siauto = -2;
	local sitime = -2;
	local noci = -2;
	local sionly = -2;

	local argc = args.len();
	if (argc > 1)
	{
		sibase = TryStringToInt(args[1], -2);
		if (sibase > 31)
			sibase = 31;
		if (sibase != -2)
			Config.sibase = sibase;
	}
	if (argc > 2)
	{
		siauto = TryStringToInt(args[2], -2);
		if (siauto < 0 && siauto!=-2)
			siauto = 0;
		else if (siauto > 7)
			siauto = 7;
		if (siauto != -2)
			Config.siauto = siauto;
	}
	if (argc > 3)
	{
		sitime = TryStringToInt(args[3], -2);
		if (sitime != -2)
			Config.sitime = sitime;
	}
	if (argc > 4)
	{
		noci = args[4];
		if ("on" == noci)
			Config.noci = true;
		else if ("off" == noci)
			Config.noci = false;
		else
			noci = -2;
	}
	if (argc > 5)
	{
		sionly = split(args[5], ",");
		Config.sionly = sionly;
	}

	Config.enabled = true;
	ExecConfig();
	ShowInfo();
}
::CmdAdd("sion", ::LinGe.MoreSI.Cmd_sion, ::LinGe.MoreSI);

// !sioff 关闭多特控制
::LinGe.MoreSI.Cmd_sioff <- function (player, args)
{
	if (args.len() == 1)
	{
		if (Config.enabled)
		{
			Config.enabled = false;
			ExecConfig();
		}
		ShowInfo();
	}
}
::CmdAdd("sioff", ::LinGe.MoreSI.Cmd_sioff, ::LinGe.MoreSI);

// !sibase 设置基础特感数量
::LinGe.MoreSI.Cmd_sibase <- function (player, args)
{
	if (!Config.enabled)
	{
		ClientPrint(null, 3, "\x04多特控制：总开关\x03 关闭");
		return;
	}

	local argsLen = args.len();
	if (argsLen > 2)
		return;

	if (2 == argsLen)
	{
		local num = TryStringToInt(args[1], -1);
		if (num > 31)
		{
			ClientPrint(player, 3, "\x04多特控制：基础特感数量不能超过\x03 31");
			return;
		}
		Config.sibase = num;
		ExecConfig();
	}
	if (Config.sibase >= 0)
	{
		ClientPrint(null, 3, "\x04多特控制：基础特感数量\x03 " + Config.sibase);
		ClientPrint(null, 3, "\x04多特控制：当前特感总数为\x03 " + ::SessionOptions.cm_MaxSpecials);
	}
	else
		ClientPrint(null, 3, "\x04多特控制：数量控制\x03 关闭");
}
::CmdAdd("sibase", ::LinGe.MoreSI.Cmd_sibase, ::LinGe.MoreSI);

// !siauto 设置自动增加特感数量
::LinGe.MoreSI.Cmd_siauto <- function (player, args)
{
	if (!Config.enabled)
	{
		ClientPrint(null, 3, "\x04多特控制：总开关\x03 关闭");
		return;
	}

	local argsLen = args.len();
	if (argsLen > 2)
		return;

	if (2 == argsLen)
	{
		local num = TryStringToInt(args[1], -1);
		if (num < 0 || num > 7)
		{
			ClientPrint(player, 3, "\x04多特控制：预设自动增加特感数量只能为\x03 0~7");
			return;
		}
		Config.siauto = num;
		ExecConfig();
	}
	if (Config.siauto > 0)
	{
		ClientPrint(null, 3, "\x04多特控制：每\x03 1 \x04名生还者玩家加入将增加\x03 " + Config.siauto + " \x04个特感");
		ClientPrint(null, 3, "\x04多特控制：当前特感总数为\x03 " + ::SessionOptions.cm_MaxSpecials);
	}
	else
		ClientPrint(null, 3, "\x04多特控制：自动增加特感\x03 关闭");
}
::CmdAdd("siauto", ::LinGe.MoreSI.Cmd_siauto, ::LinGe.MoreSI);

// !sitime 设置特感刷新时间
::LinGe.MoreSI.Cmd_sitime <- function (player, args)
{
	if (!Config.enabled)
	{
		ClientPrint(null, 3, "\x04多特控制：总开关\x03 关闭");
		return;
	}

	local argsLen = args.len();
	if (argsLen > 2)
		return;

	if (2 == argsLen)
	{
		Config.sitime = TryStringToInt(args[1], -1);
		ExecConfig();
	}
	if (Config.sitime >= 0)
		ClientPrint(null, 3, "\x04多特控制：特感刷新时间为\x03 " + Config.sitime);
	else
		ClientPrint(null, 3, "\x04多特控制：特感刷新控制\x03 关闭");
}
::CmdAdd("sitime", ::LinGe.MoreSI.Cmd_sitime, ::LinGe.MoreSI);

// !sionly 限制只生成某一种特感 只能是sitypelist中的一种
// 用逗号分隔多种特感，例如 !sionly Hunter,Boomer
::LinGe.MoreSI.Cmd_sionly <- function (player, args)
{
	if (!Config.enabled)
	{
		ClientPrint(null, 3, "\x04多特控制：总开关\x03 关闭");
		return;
	}

	if (args.len() > 1)
	{
		Config.sionly = split(args[1], ",");
		ExecConfig();
	}

	if (Config.sionly.len() > 0)
	{
		local list = "";
		foreach (val in Config.sionly)
			list += val + " ";
		ClientPrint(null, 3, "\x04多特控制：限制只生成特感 \x03" + list);
//		ClientPrint(null, 3, "\x04关闭方法：!sionly\x03 任意字符");
	}
	else
	{
		ClientPrint(null, 3, "\x04多特控制：限制特感生成 \x03关闭");
//		ClientPrint(null, 3, "\x04开启方法：!sionly\x03 Boomer,Spitter,Smoker,Hunter,Charger,Jockey");
	}
}
::CmdAdd("sionly", ::LinGe.MoreSI.Cmd_sionly, ::LinGe.MoreSI);

// !noci 是否设置无小僵尸
::LinGe.MoreSI.Cmd_noci <- function (player, args)
{
	if (!Config.enabled)
	{
		ClientPrint(null, 3, "\x04多特控制：总开关\x03 关闭");
		return;
	}

	if (args.len() == 2)
	{
		if (args[1] == "on")
			Config.noci = true;
		else if (args[1] == "off")
			Config.noci = false;
		ExecConfig();
	}
	if (Config.noci)
		ClientPrint(null, 3, "\x04多特控制：无小僵尸 \x03开启");
	else
		ClientPrint(null, 3, "\x04多特控制：无小僵尸 \x03关闭");
}
::CmdAdd("noci", ::LinGe.MoreSI.Cmd_noci, ::LinGe.MoreSI);

::LinGe.MoreSI.Timer_AutoKillCI <- function (params)
{
 	if ( Director.GetCommonInfectedCount() > 0 )
 	{
 		local infected = null;
 		while ( infected = Entities.FindByClassname( infected, "infected" ) )
 		{
 			if ( infected.IsValid() )
 				infected.Kill();
 		}
 	}
}.bindenv(::LinGe.MoreSI);

}