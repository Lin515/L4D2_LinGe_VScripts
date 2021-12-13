// HUD聊天窗指令：
// !hud ：	开关hud显示
// !rank n：	设置排行榜人数为n人，为0则不显示排行榜
// !hudstyle n ： 设置玩家显示数风格为n (0:自动 1：战役风格（活跃：x 摸鱼：x 空余：x） 2：对抗风格(生还：x VS 特感：x)
const HUDVER = "1.7";
printl("[LinGe] HUD v" + HUDVER +" 正在载入");
::LinGe.HUD <- {};

::LinGe.HUD.Config <- {
	isShowHUD = true,
	isShowTime = true,
	versusNoPlayerInfo = false,
	versusNoRank = true, // 对抗模式是否不显示击杀排行
	teamHurtInfo = 2, // 友伤信即时提示 0:关闭 1:公开处刑 2:仅攻击者和被攻击者可见
	rank = 3, // 最多显示8人 设置为<=0则关闭排行显示
			  // 如果你想显示更多人可以自己多加几个HUD slots来分开显示
	style = 0,
	textHeight = 0.025, // 一行文字通用高度
	position = {
		hostname_x = 0.4,
		hostname_y = 0.0,
		time_x = 0.75,
		time_y = 0.0,
		players_x = 0.0,
		players_y = 0.0,
		rank_x = 0.0,
		rank_y = 0.025
	}
};
::LinGe.Config.Add("HUD", ::LinGe.HUD.Config);
::LinGe.Cache.HUD_Config <- ::LinGe.HUD.Config;

::LinGe.HUD.killData <- []; // 击杀数据数组 包括特感击杀和丧尸击杀数

const HUD_SLOT_HOSTNAME = 10;
const HUD_SLOT_TIME = 11;
const HUD_SLOT_PLAYERS = 12;
const HUD_SLOT_RANK = 1; // 第一个显示 特感/丧尸击杀： 后续显示玩家数据
// 服务器每1s内会多次根据HUD_table更新屏幕上的HUD
// 脚本只需将HUD_table中的数据进行更新 而无需反复执行HUDSetLayout和HUDPlace
::LinGe.HUD.HUD_table <- {
	Fields = {
		hostname = { // 服务器名
			slot = HUD_SLOT_HOSTNAME,
			dataval = Convars.GetStr("hostname"),
			// 无边框 中对齐
			flags = HUD_FLAG_NOBG | HUD_FLAG_ALIGN_LEFT
		},
		time = { // 显示当地时间需 LinGe_VScripts 辅助插件支持
			slot = HUD_SLOT_TIME,
			// 无边框 左对齐
			flags = HUD_FLAG_NOBG | HUD_FLAG_ALIGN_LEFT
		},
		players = { // 目前玩家数
			slot = HUD_SLOT_PLAYERS,
			dataval = "",
			// 无边框 左对齐
			flags = HUD_FLAG_NOBG | HUD_FLAG_ALIGN_LEFT
		},
		rank0 = { // rank0显示标题 特感/丧尸击杀：
			slot = HUD_SLOT_RANK,
			dataval = "特感/丧尸击杀：",
			flags = HUD_FLAG_NOBG | HUD_FLAG_ALIGN_LEFT | HUD_FLAG_TEAM_SURVIVORS
		}
	}
};
// rank1~8显示玩家击杀
for (local i=1; i<9; i++)
{
	::LinGe.HUD.HUD_table.Fields["rank" + i] <- {
		slot = HUD_SLOT_RANK + i,
		dataval = "",
		flags = HUD_FLAG_NOBG | HUD_FLAG_ALIGN_LEFT | HUD_FLAG_TEAM_SURVIVORS
	};
}

// 按照Config配置更新HUD属性信息
::LinGe.HUD.UpdateHUD <- function ()
{
	local i = 0;
	if (Config.isShowHUD)
	{
		HUDSetLayout(HUD_table);
		// HUDPlace(slot, x, y, width, height)
		local height = Config.textHeight;
		HUDPlace(HUD_SLOT_HOSTNAME, Config.position.hostname_x, Config.position.hostname_y, 1.0, height); // 设置服务器名显示位置
		HUDPlace(HUD_SLOT_TIME, Config.position.time_x, Config.position.time_y, 1.0, height); // 设置时间显示位置
		HUDPlace(HUD_SLOT_PLAYERS, Config.position.players_x, Config.position.players_y, 1.0, height); // 设置玩家数量信息显示位置
		// 设置排行榜显示位置 rank0显示标题 特感/丧尸击杀 rank1~8分别显示前8名玩家击杀数据
		for (i=0; i<9; i++)
			HUDPlace(HUD_SLOT_RANK+i, Config.position.rank_x, Config.position.rank_y+height*i, 1.0, height);
	}
	else
		HUDSetLayout( ::VSLib.HUD._hud );

	if (Config.isShowTime)
		HUD_table.Fields.time.flags = HUD_table.Fields.time.flags & (~HUD_FLAG_NOTVISIBLE);
	else
		HUD_table.Fields.time.flags = HUD_table.Fields.time.flags | HUD_FLAG_NOTVISIBLE;

	if (::LinGe.isVersus && Config.versusNoPlayerInfo)
		HUD_table.Fields.players.flags = HUD_table.Fields.players.flags | HUD_FLAG_NOTVISIBLE;
	else
		HUD_table.Fields.players.flags = HUD_table.Fields.players.flags & (~HUD_FLAG_NOTVISIBLE);

	if (::LinGe.isVersus && Config.versusNoRank)
	{
		for (i=0; i<9; i++)
			HUD_table.Fields["rank"+i].flags = HUD_table.Fields["rank"+i].flags | HUD_FLAG_NOTVISIBLE;
	}
	else
	{
		if (Config.rank > 8)
			Config.rank = 8;
		else if (0 == Config.rank)
			Config.rank = -1;
		for (i=0; i<=Config.rank; i++)
			HUD_table.Fields["rank"+i].flags = HUD_table.Fields["rank"+i].flags & (~HUD_FLAG_NOTVISIBLE);
		while (i < 9)
		{
			HUD_table.Fields["rank"+i].flags = HUD_table.Fields["rank"+i].flags | HUD_FLAG_NOTVISIBLE;
			i++;
		}
	}

	UpdatePlayerHUD();
	UpdateRankHUD();
}

::LinGe.HUD.Timer_UpdateTime <- function (params)
{
	if (Config.isShowTime)
		HUD_table.Fields.time.dataval = Convars.GetStr("linge_time");
}.bindenv(::LinGe.HUD);

// 事件：回合开始
::LinGe.HUD.OnGameEvent_round_start <- function (params)
{
	// 初始化数组
	for (local i=0; i<=32; i++)
	{
		killData.append( { si=0, ci=0 } ); // si=特感 ci=小丧尸
	}

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
::LinEventHook("OnGameEvent_round_start", ::LinGe.HUD.OnGameEvent_round_start, ::LinGe.HUD);

// 玩家队伍更换事件
// team=0：玩家刚连接、和断开连接时会被分配到此队伍 不统计此队伍的人数
// team=1：旁观者 team=2：生还者 team=3：特感
::LinGe.HUD.human_team <- function (params)
{
	// 如果是离开或加入特感方就将其数据清空
	local entityIndex = params.entityIndex;
	if (params.disconnect || 3 == params.team )
	{
		killData[entityIndex].si = 0;
		killData[entityIndex].ci = 0;
	}
	UpdatePlayerHUD();
	UpdateRankHUD();
}
::LinEventHook("human_team", ::LinGe.HUD.human_team, ::LinGe.HUD);

// 事件：玩家受伤 友伤信息提示
// 对witch伤害和对小僵尸伤害不会触发这个事件
::LinGe.HUD.tempTeamHurt <- {}; // 友伤临时数据记录
::LinGe.HUD.OnGameEvent_player_hurt <- function (params)
{
	if (Config.teamHurtInfo == 0)
		return;
	if (!params.rawin("dmg_health"))
		return;
	if (params.dmg_health < 1)
		return;

	// 伤害类型为0
	if (0 == params.type)
		return;
	// 获得攻击者实体
    local attacker = GetPlayerFromUserID(params.attacker);
    // 攻击者无效
    if (null == attacker)
    	return;
    // 攻击者不是生还者
	if (!attacker.IsSurvivor())
		return;
	// 攻击者是BOT
	if ("BOT" == attacker.GetNetworkIDString())
		return;

	// 获取被攻击者实体
    local victim = GetPlayerFromUserID(params.userid);
    // 如果被攻击者是生还者则统计友伤数据
	if (victim.IsSurvivor() && Config.teamHurtInfo > 0)
	{
		// 如果不想显示对BOT的友伤可以将下面两行取消注释
	//	if ("BOT" == victim.GetNetworkIDString())
	//		return;
		// 如果被攻击者处于已死亡等状态
	    if ( victim.IsDead() || victim.IsDying() )
	    	return;
	    else if ( victim.IsIncapacitated() )
	    {
	    	// 如果已倒地，判断是否是本次伤害致其倒地
	    	// 如果不是，其当前血量+本次伤害量!=300
	    	if (victim.GetHealth() + params.dmg_health != 300)
	    		return;
	    }

		local key = params.attacker + "_" + params.userid;
		if (!tempTeamHurt.rawin(key))
		{
			tempTeamHurt[key] <- { dmg=0, attacker=attacker, victim=victim };
		}
		tempTeamHurt[key].dmg += params.dmg_health;
		// 友伤发生后，0.5秒内同一人若未再对同一人造成友伤，则输出其造成的伤害
		VSLib.Timers.AddTimerByName(key, 0.5, false, Timer_PrintHurt, key);
	}
}
::LinEventHook("OnGameEvent_player_hurt", ::LinGe.HUD.OnGameEvent_player_hurt, ::LinGe.HUD);

// 提示一次友伤伤害并删除累积数据
::LinGe.HUD.Timer_PrintHurt <- function (key)
{
	local info = tempTeamHurt[key];
	local atkName = info.attacker.GetPlayerName();
	local vctName = info.victim.GetPlayerName();
	local text = "";
	if (Config.teamHurtInfo == 1)
	{
		if (info.attacker == info.victim)
			vctName = "他自己";
		text = "\x03" + atkName
			+ "\x04 对 \x03" + vctName
			+ "\x04 造成了 \x03" + info.dmg + "\x04 点伤害";
		ClientPrint(null, 3, text);
	}
	else if (Config.teamHurtInfo == 2)
	{
		if (info.attacker == info.victim)
		{
			text = "\x04你对 \x03自己\x04 造成了 \x03" + info.dmg + "\x04 点伤害";
			ClientPrint(info.attacker, 3, text);
		}
		else
		{
			text = "\x04你对 \x03" + vctName
				+ "\x04 造成了 \x03" + info.dmg + "\x04 点伤害";
			ClientPrint(info.attacker, 3, text);
			text = "\x03" + atkName
				+ "\x04 对你造成了 \x03" + info.dmg + "\x04 点伤害";
			ClientPrint(info.victim, 3, text);
		}
	}
	tempTeamHurt.rawdelete(key);
}.bindenv(LinGe.HUD);

// 事件：玩家(特感/丧尸)死亡 统计击杀数量
// 虽然是player_death 但小丧尸和witch死亡也会触发该事件
::LinGe.HUD.OnGameEvent_player_death <- function (params)
{
//	::LinGe.DebugPrintTable(params);
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
	if (dier && attacker) // userid 必须 > 0
	{
	    attackerEntity = GetPlayerFromUserID(attacker);
		if ( attackerEntity.IsSurvivor()
		&& !IsPlayerABot(attackerEntity) ) // 此处可以不使用SteamID判断法
		{
			if (params.victimname == "Infected")
				killData[attackerEntity.GetEntityIndex()].ci++;
			else if (params.victimname != "")
			{	// 杀死队友或使用!zs自杀时 victimname 会为空
				killData[attackerEntity.GetEntityIndex()].si++;
			}
		}
	}
	UpdateRankHUD();
}
::LinEventHook("OnGameEvent_player_death", ::LinGe.HUD.OnGameEvent_player_death, ::LinGe.HUD);

::LinGe.HUD.maxplayers_changed <- function (params)
{
	UpdatePlayerHUD();
}
::LinEventHook("maxplayers_changed", ::LinGe.HUD.maxplayers_changed, ::LinGe.HUD);

::LinGe.HUD.OnGameEvent_hostname_changed <- function (params)
{
	HUD_table.Fields.hostname.dataval = params.hostname;
}
::LinEventHook("OnGameEvent_hostname_changed", ::LinGe.HUD.OnGameEvent_hostname_changed, ::LinGe.HUD);

::LinGe.HUD.Cmd_thi <- function (player, args)
{
	if (2 == args.len())
	{
		local style = LinGe.TryStringToInt(args[1], -1);
		if (style < 0 || style > 2)
		{
			ClientPrint(player, 3, "\x04!thi 0:关闭友伤提示 1:公开处刑 2:仅双方可见");
			return;
		}
		else
			Config.teamHurtInfo = style;
		switch (Config.teamHurtInfo)
		{
		case 0:
			ClientPrint(null, 3, "\x04服务器已关闭友伤提示");
			break;
		case 1:
			ClientPrint(null, 3, "\x04服务器已开启友伤提示 \x03公开处刑");
			break;
		case 2:
			ClientPrint(null, 3, "\x04服务器已开启友伤提示 \x03仅双方可见");
			break;
		default:
			throw "未知异常情况";
		}
	}
	else
		ClientPrint(player, 3, "\x04!thi 0:关闭友伤提示 1:公开处刑 2:仅双方可见");
}
::LinCmdAdd("thi", ::LinGe.HUD.Cmd_thi, ::LinGe.HUD);

::LinGe.HUD.Cmd_hud <- function (player, args)
{
	if (1 == args.len())
	{
		Config.isShowHUD = !Config.isShowHUD;
		UpdateHUD();
	}
	else if (2 == args.len())
	{
		if ("on" == args[1])
		{
			Config.isShowHUD = true;
			UpdateHUD();
		}
		else if ("off" == args[1])
		{
			Config.isShowHUD = false;
			UpdateHUD();
		}
	}
}
::LinCmdAdd("hud", ::LinGe.HUD.Cmd_hud, ::LinGe.HUD);

::LinGe.HUD.Cmd_hudstyle <- function (player, args)
{
	if (2 == args.len())
	{
		Config.style = LinGe.TryStringToInt(args[1]);
		UpdatePlayerHUD();
	}
}
::LinCmdAdd("hudstyle", ::LinGe.HUD.Cmd_hudstyle, ::LinGe.HUD);

::LinGe.HUD.Cmd_rank <- function (player, args)
{
	if (2 == args.len())
	{
		Config.rank = LinGe.TryStringToInt(args[1]);
		UpdateHUD();
	}
}
::LinCmdAdd("rank", ::LinGe.HUD.Cmd_rank, ::LinGe.HUD);

// 更新玩家信息HUD
::LinGe.HUD.UpdatePlayerHUD <- function ()
{
	local playerText = "";
	local style = Config.style;
	if (0 == style)
	{
		if (::LinGe.isVersus)
			style = 2;
		else
			style = 1;
	}

	switch (style)
	{
	case 1:
		playerText = "活跃：" + (::pyinfo.survivor + ::pyinfo.special);
		playerText += " 摸鱼：" + ::pyinfo.ob;
		playerText += " 空位：" + ( ::pyinfo.maxplayers - (::pyinfo.survivor+::pyinfo.ob+::pyinfo.special) );
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


::LinGe.HUD.UpdateRankHUD <- function ()
{
	if (::LinGe.isVersus && Config.versusNoRank)
		return;

	local rank = 0; // 玩家排名
	local name = ""; // 玩家名字
	// 如果不想改变 ::pyinfo.survivorIdx 的顺序 这里应使用 clone 克隆数组
	local survivorIdx = ::pyinfo.survivorIdx;
	local len = survivorIdx.len();

	// 将生还者实体索引数组按特感击杀数量由大到小进行排序
	// 如果特感击杀数量相等，则按丧尸击杀数
	// survivorIdx.sort(KillDataCompare); // 社区玩家更新了什么j8，搞得sort函数都不能用了，一用就闪退 2021-12-13
	BubbleSort(survivorIdx);
	for (local i=0; i<Config.rank; i++)
	{
		rank = i + 1;
		if (rank > len)
			HUD_table.Fields["rank" + rank].dataval = "";
		else
		{
			name = PlayerInstanceFromIndex(survivorIdx[i]).GetPlayerName();
			HUD_table.Fields["rank" + rank].dataval =
				"[" + rank + "] " + killData[survivorIdx[i]].si
				+ "/"+ killData[survivorIdx[i]].ci + " <- " + name;
		}
	}
}

// 比较击杀数 降序排序
::LinGe.HUD.KillDataCompare <- function (idx1, idx2)
{
	if (killData[idx1].si > killData[idx2].si)
		return -1;
	else if ( (killData[idx1].si == killData[idx2].si)
		&& (killData[idx1].ci > killData[idx2].ci) )
		return -1;
	else if ( (killData[idx1].si == killData[idx2].si)
		&& (killData[idx1].ci == killData[idx2].ci) )
		return 0;
	else
		return 1;
}.bindenv(::LinGe.HUD);

// 比较击杀数 降序排序 冒泡排序
::LinGe.HUD.BubbleSort <- function (survivorIdx)
{
	local temp;
	local len = survivorIdx.len();
	for (local i=0; i<len-1; i++)
	{
		for (local j=0; j<len-1-i; j++)
		{
			if (KillDataCompare(survivorIdx[j], survivorIdx[j+1]) == 1)
			{
				temp = survivorIdx[j];
				survivorIdx[j] = survivorIdx[j+1];
				survivorIdx[j+1] = temp;
			}
		}
	}
}