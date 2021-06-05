// HUD聊天窗指令：
// !hud ：	开关hud显示
// !rank n：	设置排行榜人数为n人，为0则不显示排行榜
// !hudstyle n ： 设置玩家显示数风格为n (0:自动 1：战役风格（活跃：x 旁观：x 空余：x） 2：对抗风格(生还：x VS 特感：x) 
printl("[LinGe] HUD 正在载入");
::LinGe.HUD <- {};

::LinGe.HUD.Config <- {
	isShowHUD = true,
	isShowTime = true,
	rank = 3,
	style = 0
};
::LinGe.Config.Add("HUD", ::LinGe.HUD.Config);

local killData = [];	// 击杀数据数组
local singlePlayer = Director.IsSinglePlayerGame();

// 服务器每1s内会多次根据HUD_table更新屏幕上的HUD
// 脚本只需将HUD_table中的数据进行更新 而无需反复执行HUDSetLayout和HUDPlace
::LinGe.HUD.HUD_table <- {
	Fields = {
		hostname = { // 服务器名
			slot = HUD_MID_TOP,
			dataval = Convars.GetStr("hostname"),
			// 无边框 中对齐
			flags = HUD_FLAG_NOBG | HUD_FLAG_ALIGN_CENTER
		},
		time = { // 显示当地时间需 LinGe_time.smx 插件支持
			slot = HUD_RIGHT_TOP,
			// 无边框 左对齐
			flags = HUD_FLAG_NOBG | HUD_FLAG_ALIGN_LEFT
		},
		players = { // 目前玩家数
			slot = HUD_LEFT_TOP,
			dataval = "",
			// 无边框 左对齐
			flags = HUD_FLAG_NOBG | HUD_FLAG_ALIGN_LEFT
		},
		rank = { // 击杀排行
			slot = HUD_FAR_LEFT,
			dataval = "",
			// 无边框 左对齐 只显示给生还者
			flags = HUD_FLAG_NOBG | HUD_FLAG_ALIGN_LEFT | HUD_FLAG_TEAM_SURVIVORS
		}
	}
};

::LinGe.HUD.Timer_UpdateTime <- function (params)
{
	if (::LinGe.HUD.Config.isShowTime)
		::LinGe.HUD.HUD_table.Fields.time.dataval = Convars.GetStr("linge_time");
}

// 事件：回合开始
::LinGe.HUD.OnGameEvent_round_start <- function (params)
{
	for (local i=0; i<=32; i++)
		killData.append( { si=0, ci=0 } ); // si=特感 ci=小丧尸
	// 如果linge_time变量不存在则显示回合时间
	if (null == Convars.GetStr("linge_time"))
	{
//		if (!("special" in HUD_table.Fields.time))
			HUD_table.Fields.time.special <- HUD_SPECIAL_ROUNDTIME;
	}
	else
	{
//		if (!("dataval" in HUD_table.Fields.time))
			HUD_table.Fields.time.dataval <- "";
		::VSLib.Timers.AddTimerByName("Timer_UpdateTime", 1.0, true, Timer_UpdateTime);
	}

	UpdateHUD();
}
::EventHook("OnGameEvent_round_start", ::LinGe.HUD.OnGameEvent_round_start, ::LinGe.HUD);

::EventHook("OnGameEvent_hostname_changed", @(params) ::LinGe.HUD.HUD_table.Fields.hostname.dataval = params.hostname);

// 玩家队伍更换事件
// team=0：玩家刚连接、和断开连接时会被分配到此队伍 不统计此队伍的人数
// team=1：旁观者 team=2：生还者 team=3：特感
::LinGe.HUD.Event_human_team <- function (params)
{
	// 如果是离开或加入生还者就将其数据清空
	local entityIndex = params.player.GetEntityIndex();
	if (params.disconnect || 3 == params.team )
	{
		killData[entityIndex].si = 0;
		killData[entityIndex].ci = 0;
	}
	UpdatePlayerHUD();
	UpdateRankHUD();
}
if (!singlePlayer)
	::EventHook("human_team", ::LinGe.HUD.Event_human_team, ::LinGe.HUD);

// 事件：玩家(特感/丧尸)死亡 统计击杀数量
// 虽然是player_death 但小丧尸和witch死亡也会触发该事件
::LinGe.HUD.OnGameEvent_player_death <- function (params)
{
    local dier = 0;	// 死者ID
    local dierEntity = null;	// 死者实体
	local attacker = 0; // 攻击者ID
	local attackerEntity = null; // 攻击者实体

    if (params.victimname == "Infected" || params.victimname == "Witch")
    {
    	// witch 和 小丧尸 不属于玩家可控制实体 无userid
    	dier = params.entityid;
    }
    else
    	dier = params.userid;

	attacker = params.attacker;
    attackerEntity = GetPlayerFromUserID(attacker);
	if ( dier && attacker && !IsPlayerABot(attackerEntity) ) // 此处可以不使用SteamID判断法
	{
		if (params.victimname == "Infected")
			killData[attackerEntity.GetEntityIndex()].ci++;
		else if (params.victimname != "")
		{	// 杀死队友或使用!zs自杀时 victimname 会为空
			killData[attackerEntity.GetEntityIndex()].si++;
		}
	}
	UpdateRankHUD();
}
::EventHook("OnGameEvent_player_death", ::LinGe.HUD.OnGameEvent_player_death, ::LinGe.HUD);

::LinGe.HUD.Cmd_hud <- function (player, msg)
{
	if (1 == msg.len())
	{
		Config.isShowHUD = !Config.isShowHUD;
		UpdateHUD();
		::LinGe.Config.Save("HUD");
	}
}
::CmdAdd("hud", ::LinGe.HUD.Cmd_hud, ::LinGe.HUD);

::LinGe.HUD.Cmd_hudstyle <- function (player, msg)
{
	if (2 == msg.len())
	{
		Config.style = msg[1].tointeger();
		UpdatePlayerHUD();
		::LinGe.Config.Save("HUD");
	}
}
::CmdAdd("hudstyle", ::LinGe.HUD.Cmd_hudstyle, ::LinGe.HUD);

::LinGe.HUD.Cmd_rank <- function (player, msg)
{
	if (2 == msg.len())
	{
		Config.rank = msg[1].tointeger();
		UpdateHUD();
		::LinGe.Config.Save("HUD");
	}
}
::CmdAdd("rank", ::LinGe.HUD.Cmd_rank, ::LinGe.HUD);

local emptyHud = { Fields = {} };
::LinGe.HUD.UpdateHUD <- function ()
{
	if (Config.isShowHUD)
	{
		HUDSetLayout(HUD_table);
		// HUDPlace(slot, x, y, width, height) x、y为浮点数，以百分比来指定在屏幕上的位置 一般一行文字的height为0.025
		HUDPlace(HUD_MID_TOP, 0.0, 0.0, 1.0, 0.025);
		HUDPlace(HUD_RIGHT_TOP, 0.65, 0.0, 1.0, 0.025);
		HUDPlace(HUD_LEFT_TOP, 0.17, 0.0, 1.0, 0.025);
	}
	else
		HUDSetLayout(emptyHud);

	if (Config.isShowTime)
		HUD_table.Fields.time.flags = HUD_table.Fields.time.flags & (~HUD_FLAG_NOTVISIBLE);
	else
		HUD_table.Fields.time.flags = HUD_table.Fields.time.flags | HUD_FLAG_NOTVISIBLE;

	if (singlePlayer)
		HUD_table.Fields.players.flags = HUD_table.Fields.players.flags | HUD_FLAG_NOTVISIBLE;

	if (Config.rank > 0)
	{
		if (singlePlayer)
			HUDPlace(HUD_FAR_LEFT, 0.15, 0.0, 1.0, 0.025);
		else
			HUDPlace(HUD_FAR_LEFT, 0.0, 0.0, 1.0, 0.025*(Config.rank+1));
		HUD_table.Fields.rank.flags = HUD_table.Fields.rank.flags & (~HUD_FLAG_NOTVISIBLE);
	}
	else
		HUD_table.Fields.rank.flags = HUD_table.Fields.rank.flags | HUD_FLAG_NOTVISIBLE;

	UpdatePlayerHUD();
	UpdateRankHUD();
}

// 更新玩家信息HUD
::LinGe.HUD.UpdatePlayerHUD <- function ()
{
	local playerText = "";
	local style = Config.style;
	if (0 == style)
	{
		if ("versus" == g_BaseMode)
			style = 2;
		else
			style = 1;
	}

	switch (style)
	{
	case 1:
		playerText = "活跃：" + (::pyinfo.survivor + ::pyinfo.special);
		playerText += " 旁观：" + ::pyinfo.ob;
		playerText += " 空位：" + ( ::pyinfo.maxplayers.tointeger() - (::pyinfo.survivor+::pyinfo.ob+::pyinfo.special) );
		break;
	default:
		playerText = "生还：" + ::pyinfo.survivor + " VS 特感：" + ::pyinfo.special;
		break;
//	default:
//		playerText = "当前玩家：" + (::pyinfo.survivor + ::pyinfo.ob + ::pyinfo.special);
//		playerText += "/" + ::pyinfo.maxplayers;
//		break;
	}

	HUD_table.Fields.players.dataval = playerText;
}

// 更新击杀排行HUD
if (singlePlayer) {
// 单人模式
::LinGe.HUD.UpdateRankHUD <- function ()
{
	HUD_table.Fields.rank.dataval = "击杀特感："	+ killData[1].si
		+ " 击杀丧尸："+ killData[1].ci;
}

} else {
// 非单人模式
::LinGe.HUD.UpdateRankHUD <- function ()
{
	local rank = 0; // 玩家排名
	local name = ""; // 玩家名字
	local text = "特感/丧尸击杀：";
	// 如果不想改变 ::pyinfo.survivorIdx 的顺序 这里应使用 clone 克隆数组
	local survivorIdx = ::pyinfo.survivorIdx;
	local len = survivorIdx.len();

	// 将生还者实体索引数组按特感击杀数量由大到小进行排序
	// 如果特感击杀数量相等，则按丧尸击杀数
	survivorIdx.sort(KillDataCompare);
	for (local i=0; i<Config.rank; i++)
	{
		if (i >= len)
			text += "\n";
		else
		{
			rank = i + 1;
			name = PlayerInstanceFromIndex(survivorIdx[i]).GetPlayerName();
			text += "\n[" + rank + "] " + killData[survivorIdx[i]].si
				+ "/"+ killData[survivorIdx[i]].ci + " <- " + name;
		}
	}
	HUD_table.Fields.rank.dataval = text;
}

// 比较击杀数 降序排序
::LinGe.HUD.KillDataCompare <- function (survivorIdx1, survivorIdx2)
{
	if (killData[survivorIdx1].si > killData[survivorIdx2].si)
		return -1;
	else if ( (killData[survivorIdx1].si == killData[survivorIdx2].si)
		&& (killData[survivorIdx1].ci > killData[survivorIdx2].ci) )
		return -1;
	else if ( (killData[survivorIdx1].si == killData[survivorIdx2].si)
		&& (killData[survivorIdx1].ci == killData[survivorIdx2].ci) )
		return 0;
	else
		return 1;
}.bindenv(::LinGe.HUD);

}