if ( "coop"==g_BaseMode && "versus"!=Director.GetGameMode() ) {

printl("[LinGe] 简易多特控制 正在载入");
::LinGe.MoreSI <- {};

local sitypelist = ["Boomer", "Spitter", "Smoker", "Hunter", "Charger", "Jockey"];
::LinGe.MoreSI.Config <- {
	enabled = false, // 多特控制总开关
	simin = 4, // 最小特感数量
	sibase = 8, // 基础特感数量 若设定为 < 0 则单独关闭特感数量控制
	siauto = 0, // 每1名玩家增加多少特感 在基础特感数量上增加 为0则不自动增加
	sitime = 15, // 特感刷新间隔 若设定为 < 0 则单独关闭特感刷新时间控制
	sionly = [], // 只允许生成哪些特感，若数组为空则不限制
	noci = false // 是否允许普通感染者存在
};
::LinGe.Config.Add("MoreSI", ::LinGe.MoreSI.Config);

// 按照Config设置特感数量和刷新时间
::LinGe.MoreSI.ExecConfig <- function ()
{
	local ctrlNum = (Config.sibase >= 0);
	local ctrlTime = (Config.sitime >= 0);
	local ctrlNoci = Config.noci;
	// 检查数组sionly值的有效性 移除无效值
	if ("array" != typeof Config.sionly)
		Config.sionly = [];
	else
	{
		foreach (idx, val in Config.sionly)
		{
			if (null == sitypelist.find(val))
				Config.sionly.remove(idx);
		}
	}
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
			autoNum = Config.siauto * (::pyinfo.survivor + ::pyinfo.ob);

		local simax = Config.sibase + autoNum;
		if (simax < Config.simin)
			simax = Config.simin;
		else if (simax > 31)
			simax = 31;

		::SessionOptions.rawset("cm_MaxSpecials", simax);
		::SessionOptions.rawset("cm_BaseSpecialLimit", (::SessionOptions.cm_MaxSpecials / 5).tointeger() ); // 平均特感数量
		if (::SessionOptions.cm_MaxSpecials%5 != 0)
			::SessionOptions.cm_BaseSpecialLimit += 1;
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
	 	::SessionOptions.rawset("cm_BaseSpecialLimit", (maxsi / Config.sionly.len()).tointeger() ); // 平均特感数量
		if (maxsi % Config.sionly.len() != 0)
			::SessionOptions.cm_BaseSpecialLimit += 1;
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

	// 设置无普通感染者
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

// 输出当前设置信息
::LinGe.MoreSI.ShowInfo <- function ()
{
	if (Config.enabled)
	{
//		ClientPrint(null, 3, "\x04多特控制：当前状态\x03 开启");
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
		if (Config.sionly.len() > 0)
		{
			local list = "";
			foreach (val in Config.sionly)
				list += val + " ";
			ClientPrint(null, 3, "\x04多特控制：限制只生成特感 \x03" + list);
		}
		if (Config.noci)
			ClientPrint(null, 3, "\x04多特控制：无普通感染者 \x03开启");
	}
	else
		ClientPrint(null, 3, "\x04多特控制：当前状态\x03 关闭");
}

// 回合开始
::LinGe.MoreSI.OnGameEvent_round_start <- function (params)
{
	if (Config.enabled)
		ExecConfig();
	ShowInfo();
}
::EventHook("OnGameEvent_round_start", ::LinGe.MoreSI.OnGameEvent_round_start, ::LinGe.MoreSI);

// 玩家队伍变更 调整特感数量
::LinGe.MoreSI.Event_human_team <- function (params)
{
	if ( Config.enabled && Config.sibase >= 0 && Config.siauto > 0 )
	{
		local old = ::SessionOptions.cm_MaxSpecials;
		ExecConfig();
		if (old != ::SessionOptions.cm_MaxSpecials)
			ClientPrint(null, 3, "\x04多特控制：当前特感数量已修改为\x03 " + ::SessionOptions.cm_MaxSpecials);
	}
}
::EventHook("human_team", ::LinGe.MoreSI.Event_human_team, ::LinGe.MoreSI);

// !si 查看当前多特控制状态
::LinGe.MoreSI.Cmd_si <- function (player, msg)
{
	if (msg.len() == 1)
		ShowInfo();
}
::CmdAdd("si", ::LinGe.MoreSI.Cmd_si, ::LinGe.MoreSI);

// !sion 打开多特控制
::LinGe.MoreSI.Cmd_sion <- function (player, msg)
{
	if (msg.len() == 1)
	{
		// 如果未开启则开启
		if (!Config.enabled)
		{
			Config.enabled = true;
			ExecConfig();
			::LinGe.Config.Save("MoreSI");
		}
		ShowInfo();
	}
}
::CmdAdd("sion", ::LinGe.MoreSI.Cmd_sion, ::LinGe.MoreSI);

// !sioff 关闭多特控制
::LinGe.MoreSI.Cmd_sioff <- function (player, msg)
{
	if (msg.len() == 1)
	{
		if (Config.enabled)
		{
			Config.enabled = false;
			ExecConfig();
			::LinGe.Config.Save("MoreSI");
		}
		ShowInfo();
	}
}
::CmdAdd("sioff", ::LinGe.MoreSI.Cmd_sioff, ::LinGe.MoreSI);

// !sibase 设置基础特感数量
::LinGe.MoreSI.Cmd_sibase <- function (player, msg)
{
	local msgLen = msg.len();
	if (msgLen > 2)
		return;

	if (2 == msgLen)
	{
		local num = msg[1].tointeger();
		if (num > 31)
		{
			ClientPrint(player, 3, "\x04多特控制：基础特感数量不能超过\x03 31");
			return;
		}
		Config.sibase = num;
		::LinGe.Config.Save("MoreSI");
		if (Config.enabled)
			ExecConfig();
	}
	if (Config.sibase >= 0)
	{
		ClientPrint(null, 3, "\x04多特控制：基础特感数量\x03 " + Config.sibase);
		if (Config.enabled)
			ClientPrint(null, 3, "\x04多特控制：当前特感总数为\x03 " + ::SessionOptions.cm_MaxSpecials);
	}
	else
		ClientPrint(null, 3, "\x04多特控制：数量控制\x03 关闭");
}
::CmdAdd("sibase", ::LinGe.MoreSI.Cmd_sibase, ::LinGe.MoreSI);

// !siauto 设置自动增加特感数量
::LinGe.MoreSI.Cmd_siauto <- function (player, msg)
{
	local msgLen = msg.len();
	if (msgLen > 2)
		return;

	if (2 == msgLen)
	{
		local num = msg[1].tointeger();
		if (num < 0 || num > 7)
		{
			ClientPrint(player, 3, "\x04多特控制：预设自动增加特感数量只能为\x03 0~7");
			return;
		}
		Config.siauto = num;
		::LinGe.Config.Save("MoreSI");
		if (Config.enabled)
			ExecConfig();
	}
	if (Config.siauto > 0)
	{
		ClientPrint(null, 3, "\x04多特控制：每\x03 1 \x04名生还者玩家加入将增加\x03 " + Config.siauto + " \x04个特感");
		if (Config.enabled)
			ClientPrint(null, 3, "\x04多特控制：当前特感总数为\x03 " + ::SessionOptions.cm_MaxSpecials);
	}
	else
		ClientPrint(null, 3, "\x04多特控制：自动增加特感\x03 关闭");
}
::CmdAdd("siauto", ::LinGe.MoreSI.Cmd_siauto, ::LinGe.MoreSI);

// !sitime 设置特感刷新时间
::LinGe.MoreSI.Cmd_sitime <- function (player, msg)
{
	local msgLen = msg.len();
	if (msgLen > 2)
		return;

	if (2 == msgLen)
	{
		Config.sitime = msg[1].tointeger();
		::LinGe.Config.Save("MoreSI");
		if (Config.enabled)
			ExecConfig();
	}
	if (Config.sitime >= 0)
		ClientPrint(null, 3, "\x04多特控制：特感刷新时间为\x03 " + Config.sitime);
	else
		ClientPrint(null, 3, "\x04多特控制：特感刷新控制\x03 关闭");
}
::CmdAdd("sitime", ::LinGe.MoreSI.Cmd_sitime, ::LinGe.MoreSI);

// !sionly 限制只生成某一种特感 只能是sitypelist中的一种
::LinGe.MoreSI.Cmd_sionly <- function (player, msg)
{
	if (msg.len() > 1)
	{
		local arr = clone msg;
		arr.remove(0);
		Config.sionly = arr;
		if (Config.enabled)
			ExecConfig();
		::LinGe.Config.Save("MoreSI");
	}

	if (Config.sionly.len() > 0)
	{
		local list = "";
		foreach (val in Config.sionly)
			list += val + " ";
		ClientPrint(null, 3, "\x04多特控制：限制只生成特感 \x03" + list);
	}
	else
		ClientPrint(null, 3, "\x04多特控制：限制特感生成 \x03关闭");
}
::CmdAdd("sionly", ::LinGe.MoreSI.Cmd_sionly, ::LinGe.MoreSI);

// !noci 是否设置无普通感染者
::LinGe.MoreSI.Cmd_noci <- function (player, msg)
{
	if (msg.len() != 1)
		return;

	Config.noci = !Config.noci;
	::LinGe.Config.Save("MoreSI");
	if (Config.enabled)
		ExecConfig();

	ClientPrint(null, 3, "\x04多特控制：无普通感染者 \x03" + (Config.noci?"开启":"关闭"));
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