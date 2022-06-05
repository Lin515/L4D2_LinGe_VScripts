printl("[LinGe] HUD 正在载入");
::LinGe.HUD <- {};

::LinGe.HUD.Config <- {
	HUDShow = {
		all = true,
		time = true,
		players = true,
		hostname = true,
		playersStyle = 0,
	},
	hurt = {
		versusNoHUDRank = true, // 对抗模式是否不显示HUD击杀排行
		HUDRank = 3, // HUD排行榜最多显示多少人，范围0~8 设置为0则关闭排行显示
		rankTitle = "特感/丧尸击杀：",
		rankStyle = "{ksi}/{kci}",
		teamHurtInfo = 2, // 友伤即时提示 0:关闭 1:公开处刑 2:仅攻击者和被攻击者可见
		autoPrint = 0, // 每间隔多少s在聊天窗输出一次数据统计，若为0则只在本局结束时输出，若<0则永远不输出
		chatRank = 4, // 聊天窗输出时除了最高友伤、最高被黑 剩下显示最多多少人的数据
		chatStyle = "特:{ksi}({si}伤害) 尸:{kci} 黑:{atk} 被黑:{vct}"
	},
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

::LinGe.HUD.hurtData <- []; // 伤害与击杀数据

// 预处理文本处理函数
::LinGe.HUD.Pre <- {};
::LinGe.HUD.Pre.ex <- regexp("{(ksi|kci|si|atk|vct)}");
::LinGe.HUD.Pre.GetKeyAndReplace <- function (oldStr, tr)
{
	local ret = { key=[], str=oldStr};
	local res = ex.capture(oldStr); // index=0 带{}的完整匹配 index=1 不带{}的分组1
	if (res != null)
	{
		ret = GetKeyAndReplace(oldStr.slice(0, res[0].begin) + tr + oldStr.slice(res[0].end), tr);
		ret.key.insert(0, oldStr.slice(res[1].begin, res[1].end));
	}
	return ret;
}

::LinGe.HUD.Pre.BuildFuncStr <- function (formatAndKey)
{
	local funcStr = "return format(\"" + formatAndKey.str + "\"";
	foreach (val in formatAndKey.key)
		funcStr += ", hurtData[vargv[0]]." + val;
	funcStr += ");";
	return funcStr;
}

::LinGe.HUD.Pre.CompileFunc <- function ()
{
	// 预处理HUD排行榜相关
	local result = GetKeyAndReplace(::LinGe.HUD.Config.hurt.rankStyle, "%d");
	::LinGe.HUD.Pre.HUDKey <- result.key; // key列表需要保存下来，用于排序
	::LinGe.HUD.Pre.HUDFunc <- compilestring(BuildFuncStr(result)).bindenv(::LinGe.HUD);
	// 预处理聊天窗排行榜相关
	result = GetKeyAndReplace(::LinGe.HUD.Config.hurt.chatStyle, "\\x03%d\\x04");
	::LinGe.HUD.Pre.ChatKey <- result.key;
	::LinGe.HUD.Pre.ChatFunc <- compilestring(BuildFuncStr(result)).bindenv(::LinGe.HUD);
}
::LinGe.HUD.Pre.CompileFunc();

const HUD_SLOT_HOSTNAME = 10;
const HUD_SLOT_TIME = 11;
const HUD_SLOT_PLAYERS = 12;
const HUD_SLOT_RANK = 1; // 第一个显示标题 后续显示玩家数据
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
		rank0 = { // rank0显示标题
			slot = HUD_SLOT_RANK,
			dataval = ::LinGe.HUD.Config.hurt.rankTitle,
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
::LinGe.HUD.ApplyConfigHUD <- function ()
{
	local i = 0;
	if (Config.HUDShow.all)
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

	if (Config.HUDShow.time)
		HUD_table.Fields.time.flags = HUD_table.Fields.time.flags & (~HUD_FLAG_NOTVISIBLE);
	else
		HUD_table.Fields.time.flags = HUD_table.Fields.time.flags | HUD_FLAG_NOTVISIBLE;

	if (Config.HUDShow.players)
		HUD_table.Fields.players.flags = HUD_table.Fields.players.flags & (~HUD_FLAG_NOTVISIBLE);
	else
		HUD_table.Fields.players.flags = HUD_table.Fields.players.flags | HUD_FLAG_NOTVISIBLE;

	if (Config.HUDShow.hostname)
		HUD_table.Fields.hostname.flags = HUD_table.Fields.hostname.flags & (~HUD_FLAG_NOTVISIBLE);
	else
		HUD_table.Fields.hostname.flags = HUD_table.Fields.hostname.flags | HUD_FLAG_NOTVISIBLE;

	if (::LinGe.isVersus && Config.hurt.versusNoHUDRank)
	{
		for (i=0; i<9; i++)
			HUD_table.Fields["rank"+i].flags = HUD_table.Fields["rank"+i].flags | HUD_FLAG_NOTVISIBLE;
	}
	else
	{
		if (Config.hurt.HUDRank > 8)
			Config.hurt.HUDRank = 8;
		else if (Config.hurt.HUDRank <= 0)
			Config.hurt.HUDRank = -1;
		if (Config.hurt.HUDRank > 0)
			::VSLib.Timers.AddTimerByName("UpdateRankHUD", 1.0, true, ::LinGe.HUD.UpdateRankHUD);
		else
			::VSLib.Timers.RemoveTimerByName("UpdateRankHUD");

		for (i=0; i<=Config.hurt.HUDRank; i++) // 去掉所有排行榜数据HUD的隐藏属性
			HUD_table.Fields["rank"+i].flags = HUD_table.Fields["rank"+i].flags & (~HUD_FLAG_NOTVISIBLE);
		// 隐藏 rank>Config.hurt.HUDRank 的HUD
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
	HUD_table.Fields.time.dataval = Convars.GetStr("linge_time");
}.bindenv(::LinGe.HUD);

// 事件：回合开始
::LinGe.HUD.OnGameEvent_round_start <- function (params)
{
	// 初始化数组
	for (local i=0; i<=32; i++)
	{
		// ksi=击杀的特感数量 kci=击杀的小丧失数量
		// si=对特感伤害 atk=对别人的友伤 vct=自己受到的友伤
		hurtData.append( { ksi=0, kci=0, si=0, atk=0, vct=0, tank=0 } );
		// 对特感数据默认不统计对特感的火烧伤害与对Tank的伤害 对Tank伤害会单独列出
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

	ApplyAutoHurtPrint();
	ApplyConfigHUD();
}
::LinEventHook("OnGameEvent_round_start", ::LinGe.HUD.OnGameEvent_round_start, ::LinGe.HUD);

// 玩家队伍更换事件
// team=0：玩家刚连接、和断开连接时会被分配到此队伍 不统计此队伍的人数
// team=1：旁观者 team=2：生还者 team=3：特感
::LinGe.HUD.human_team <- function (params)
{
	// 如果是离开或加入特感方就将其数据清空
	local entityIndex = params.entityIndex;
	if (params.disconnect || 3 == params.team)
	{
		hurtData[entityIndex].ksi = 0;
		hurtData[entityIndex].kci = 0;
		hurtData[entityIndex].si = 0;
		hurtData[entityIndex].atk = 0;
		hurtData[entityIndex].vct = 0;
		hurtData[entityIndex].tank = 0;
	}
	UpdatePlayerHUD();
	UpdateRankHUD();
}
::LinEventHook("human_team", ::LinGe.HUD.human_team, ::LinGe.HUD);

// 事件：玩家受伤 友伤信息提示、伤害数据统计
// 对witch伤害和对小僵尸伤害不会触发这个事件
// witch伤害不记录，tank伤害单独记录
::LinGe.HUD.tempTeamHurt <- {}; // 友伤临时数据记录
::LinGe.HUD.OnGameEvent_player_hurt <- function (params)
{
	if (!params.rawin("dmg_health"))
		return;
	if (params.dmg_health < 1)
		return;

	if (0 == params.type) // 伤害类型为0
		return;
    local attacker = GetPlayerFromUserID(params.attacker); // 获得攻击者实体
    if (null == attacker) // 攻击者无效
    	return;
	if (!attacker.IsSurvivor()) // 攻击者不是生还者
		return;

	// 获取被攻击者实体
    local victim = GetPlayerFromUserID(params.userid);
	local vctHp = victim.GetHealth();
	local dmg = params.dmg_health;
    // 如果被攻击者是生还者则统计友伤数据
	if (victim.IsSurvivor())
	{
		if (victim.IsDying() || victim.IsDead())
			return;
	    else if (vctHp < 0) // 致死伤害事件发生时，victim.IsDead()还不会为真，但血量会<0
	    {
			// 如果是本次伤害致其死亡，则 生命值 + 伤害值 > 0
			if (vctHp + dmg <= 0)
				return;
		}
	    else if (victim.IsIncapacitated())
	    {
	    	// 如果是本次伤害致其倒地，则其当前血量+伤害量=300
			// 如果不是，则说明攻击时已经倒地，则不统计本次友伤
	    	if (vctHp + dmg != 300)
				return;
	    }

		// 若不是对自己造成的伤害，则计入累计统计
		if (attacker != victim)
		{
			hurtData[attacker.GetEntityIndex()].atk += dmg;
			hurtData[victim.GetEntityIndex()].vct += dmg;
		}

		// 若开启了友伤提示，则计入临时数据统计
		if (Config.hurt.teamHurtInfo > 0)
		{
			local key = params.attacker + "_" + params.userid;
			if (!tempTeamHurt.rawin(key))
			{
				tempTeamHurt[key] <- { dmg=0, attacker=attacker, victim=victim, isDead=false, isIncap=false };
			}
			tempTeamHurt[key].dmg += dmg;
			// 友伤发生后，0.5秒内同一人若未再对同一人造成友伤，则输出其造成的伤害
			VSLib.Timers.AddTimerByName(key, 0.5, false, Timer_PrintTeamHurt, key);
		}
	}
	else // 不是生还者团队则统计对特感的伤害数据
	{
		// 如果是Tank 则将数据记录到临时Tank伤害数据记录
		if (8 == victim.GetZombieType())
		{
			if (5000 == dmg) // 击杀Tank时会产生5000伤害事件，不知道为什么设计了这样的机制
				return;
			hurtData[attacker.GetEntityIndex()].tank += dmg;
		}
		else // 不是生还者且不是Tank，则为普通特感(此事件下不可能为witch)
		{
			if (vctHp < 0)
				dmg += vctHp; // 修正溢出伤害
			hurtData[attacker.GetEntityIndex()].si += dmg;
		}
	}
}
::LinEventHook("OnGameEvent_player_hurt", ::LinGe.HUD.OnGameEvent_player_hurt, ::LinGe.HUD);
/*	Tank的击杀伤害与致队友倒地时的伤害存在溢出
	没能发现太好修正方法，因为当上述两种情况发生时
	已经无法获得其最后一刻的真实血量
	除非时刻记录Tank和队友的血量，然后以此为准编写一套逻辑
	但这样实在太浪费资源，且容易出现BUG
*/

// 提示一次友伤伤害并删除累积数据
::LinGe.HUD.Timer_PrintTeamHurt <- function (key)
{
	local info = tempTeamHurt[key];
	local atkName = info.attacker.GetPlayerName();
	local vctName = info.victim.GetPlayerName();
	local text = "";

	if (Config.hurt.teamHurtInfo == 1)
	{
		if (info.attacker == info.victim)
			vctName = "他自己";
		text = "\x03" + atkName
			+ "\x04 对 \x03" + vctName
			+ "\x04 造成了 \x03" + info.dmg + "\x04 点伤害";
		if (info.isDead)
		{
			if (info.attacker == info.victim)
				text += "，并且死亡";
			else
				text += "，并且杀死了对方";
		}
		else if (info.isIncap)
		{
			if (info.attacker == info.victim)
				text += "，并且倒地";
			else
				text += "，并且击倒了对方";
		}
		ClientPrint(null, 3, text);
	}
	else if (Config.hurt.teamHurtInfo == 2)
	{
		if (info.attacker == info.victim)
		{
			text = "\x04你对 \x03自己\x04 造成了 \x03" + info.dmg + "\x04 点伤害";
			if (info.isDead)
				text += "，并且死亡";
			else if (info.isIncap)
				text += "，并且倒地";
			ClientPrint(info.attacker, 3, text);
		}
		else
		{
			text = "\x04你对 \x03" + vctName
				+ "\x04 造成了 \x03" + info.dmg + "\x04 点伤害";
			if (info.isDead)
				text += "，并且杀死了他";
			else if (info.isIncap)
				text += "，并且击倒了他";
			ClientPrint(info.attacker, 3, text);
			text = "\x03" + atkName
				+ "\x04 对你造成了 \x03" + info.dmg + "\x04 点伤害";
			if (info.isDead)
				text += "，并且杀死了你";
			else if (info.isIncap)
				text += "，并且打倒了你";
			ClientPrint(info.victim, 3, text);
		}
	}
	tempTeamHurt.rawdelete(key);
}.bindenv(LinGe.HUD);

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
	if (dier == 0)
		return;

	attacker = params.attacker;
	dierEntity = GetPlayerFromUserID(dier);
	attackerEntity = GetPlayerFromUserID(attacker);

	if (dierEntity && dierEntity.IsSurvivor())
	{
		// 自杀时伤害类型为0
		if (params.type == 0)
			return;

		// 如果是友伤致其死亡
		if (attackerEntity && attackerEntity.IsSurvivor())
		{
			local key = params.attacker + "_" + dier;
			if (tempTeamHurt.rawin(key))
				tempTeamHurt[key].isDead = true;
		}
	}
	else
	{
		if (attackerEntity && attackerEntity.IsSurvivor())
		{
			if (params.victimname == "Infected")
				hurtData[attackerEntity.GetEntityIndex()].kci++;
			else
				hurtData[attackerEntity.GetEntityIndex()].ksi++;
			// UpdateRankHUD();
		}
	}
}
::LinEventHook("OnGameEvent_player_death", ::LinGe.HUD.OnGameEvent_player_death, ::LinGe.HUD);

// 事件：玩家倒地
::LinGe.HUD.OnGameEvent_player_incapacitated <- function (params)
{
	if (!params.rawin("userid") || params.userid == 0)
		return;

	local player = GetPlayerFromUserID(params.userid);
	local attackerEntity = null;
	if (params.rawin("attacker")) // 如果是小丧尸或Witch等使玩家倒地，则无attacker
		attackerEntity = GetPlayerFromUserID(params.attacker);
	if (player.IsSurvivor())
	{
		// 如果是友伤致其倒地
		if (attackerEntity && attackerEntity.IsSurvivor())
		{
			local key = params.attacker + "_" + params.userid;
			if (tempTeamHurt.rawin(key))
				tempTeamHurt[key].isIncap = true;
		}
	}
}
::LinEventHook("OnGameEvent_player_incapacitated", ::LinGe.HUD.OnGameEvent_player_incapacitated, ::LinGe.HUD);

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
			Config.hurt.teamHurtInfo = style;
		switch (Config.hurt.teamHurtInfo)
		{
		case 0:
			ClientPrint(player, 3, "\x04服务器已关闭友伤提示");
			break;
		case 1:
			ClientPrint(player, 3, "\x04服务器已开启友伤提示 \x03公开处刑");
			break;
		case 2:
			ClientPrint(player, 3, "\x04服务器已开启友伤提示 \x03仅双方可见");
			break;
		default:
			throw "未知异常情况";
		}
	}
	else
		ClientPrint(player, 3, "\x04!thi 0:关闭友伤提示 1:公开处刑 2:仅双方可见");
}
::LinCmdAdd("thi", ::LinGe.HUD.Cmd_thi, ::LinGe.HUD, "0:关闭友伤提示 1:公开处刑 2:仅双方可见");

::LinGe.HUD.Cmd_hurtdata <- function (player, args)
{
	local len = args.len();
	if (1 == len)
		PrintChatRank();
	else if (3 == len)
	{
		if (!::LinGe.Admin.IsAdmin(player))
		{
			ClientPrint(player, 3, "\x04权限不足！");
		}
		else if ("auto" == args[1])
		{
			local time = ::LinGe.TryStringToFloat(args[2]);
			Config.hurt.autoPrint = time;
			ApplyAutoHurtPrint();
			if (time > 0)
				ClientPrint(player, 3, "\x04已设置每 \x03" + time + "\x04 秒播报一次聊天窗排行榜");
			else if (0 == time)
				ClientPrint(player, 3, "\x04已关闭定时聊天窗排行榜播报，回合结束时仍会播报");
			else
				ClientPrint(player, 3, "\x04已彻底关闭聊天窗排行榜播报");
		}
		else if ("player" == args[1])
		{
			local player = ::LinGe.TryStringToInt(args[2]);
			Config.hurt.chatRank = player;
			if (player > 0)
				ClientPrint(player, 3, "\x04聊天窗排行榜将显示最多 \x03" + player + "\x04 人");
			else
				ClientPrint(player, 3, "\x04已彻底关闭聊天窗排行榜与TANK伤害统计播报");
		}
	}
}
::LinCmdAdd("hurtdata", ::LinGe.HUD.Cmd_hurtdata, ::LinGe.HUD, "", false);
::LinCmdAdd("hurt", ::LinGe.HUD.Cmd_hurtdata, ::LinGe.HUD, "", false);
::LinCmdAdd("hd", ::LinGe.HUD.Cmd_hurtdata, ::LinGe.HUD, "输出一次聊天窗排行榜或者调整自动播报配置", false);

local reHudCmd = regexp("^(all|time|players|hostname)$");
::LinGe.HUD.Cmd_hud <- function (player, args)
{
	if (1 == args.len())
	{
		Config.HUDShow.all = !Config.HUDShow.all;
		ApplyConfigHUD();
		return;
	}
	else if (2 == args.len())
	{
		if (args[1] == "rank")
		{
			ClientPrint(player, 3, "\x04!hud rank n 设置排行榜最大显示人数为n");
			return;
		}
		else if (reHudCmd.search(args[1]))
		{
			Config.HUDShow[args[1]] = !Config.HUDShow[args[1]];
			ApplyConfigHUD();
			return;
		}
	}
	else if (3 == args.len())
	{
		Config.hurt.HUDRank = ::LinGe.TryStringToInt(args[2]);
		ApplyConfigHUD();
		return;
	}
	ClientPrint(player, 3, "\x04!hud time/players/hostname/rank 控制HUD元素的显示");
}
::LinCmdAdd("hud", ::LinGe.HUD.Cmd_hud, ::LinGe.HUD, "time/players/hostname/rank 控制HUD元素的显示");

::LinGe.HUD.Cmd_rank <- function (player, args)
{
	if (2 == args.len())
	{
		Config.hurt.HUDRank = ::LinGe.TryStringToInt(args[1]);
		ApplyConfigHUD();
		return;
	}
	ClientPrint(player, 3, "\x04!rank n 设置排行榜最大显示人数为n");
}
::LinCmdAdd("rank", ::LinGe.HUD.Cmd_rank, ::LinGe.HUD);

// 更新玩家信息HUD
::LinGe.HUD.UpdatePlayerHUD <- function ()
{
	local playerText = "";
	local style = Config.HUDShow.playersStyle;
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

::LinGe.HUD.UpdateRankHUD <- function (params=null)
{
	if (Config.hurt.HUDRank < 1)
		return;
	if (::LinGe.isVersus && Config.hurt.versusNoHUDRank)
		return;

	// 如果不想改变 ::pyinfo.survivorIdx 的顺序 这里应使用 clone 克隆数组
	local survivorIdx = ::pyinfo.survivorIdx;
	local len = survivorIdx.len();

	// 将生还者实体索引数组按特感击杀数量由大到小进行排序
	// 如果特感击杀数量相等，则按丧尸击杀数
	hurtDataSort(survivorIdx, Pre.HUDKey);
	local rank = 1, name = "";
	for (local i=0; i<len && rank<=Config.hurt.HUDRank; i++)
	{
		local player = PlayerInstanceFromIndex(survivorIdx[i]);
		if (!IsPlayerABot(player) || ::LinGe.Debug) // HUD排行榜正常情况下不显示BOT数据
		{
			name = player.GetPlayerName();
			HUD_table.Fields["rank" + rank].dataval = format("[%d] %s <- %s",
				rank, Pre.HUDFunc(survivorIdx[i]), name);
			rank++;
		}
	}
	// 清空可能存在的多余的显示
	for (local i=rank+1; i<=Config.hurt.HUDRank; i++)
		HUD_table.Fields["rank" + i].dataval = "";
}.bindenv(::LinGe.HUD);

// Tank 事件控制
// 在Tank全部死亡时输出并清空本次克局伤害统计
local nowTank = 0;
local killTank = 0;
::LinGe.HUD.OnGameEvent_tank_spawn <- function (params)
{
	nowTank++;
}
::LinGe.HUD.OnGameEvent_tank_killed <- function (params)
{
	nowTank--;
	killTank++;
	if (nowTank == 0)
	{
		PrintTankHurtData();
		killTank = 0;
		for (local i=1; i<=32; i++)
			hurtData[i].tank = 0;
	}
}
::LinEventHook("OnGameEvent_tank_spawn", ::LinGe.HUD.OnGameEvent_tank_spawn, ::LinGe.HUD);
::LinEventHook("OnGameEvent_tank_killed", ::LinGe.HUD.OnGameEvent_tank_killed, ::LinGe.HUD);

::LinGe.HUD.PrintTankHurtData <- function ()
{
	local player = Config.hurt.chatRank;
	local idx = clone ::pyinfo.survivorIdx;
	local name = "", len = idx.len();

	if (player > 0 && len > 0)
	{
		hurtDataSort(idx, ["tank"]);
		// 如果第一位的伤害也为0，则本次未对该Tank造成伤害，则不输出Tank伤害统计
		// 终局时无线刷Tank 经常会出现这种0伤害的情况
		if (hurtData[idx[0]].tank == 0)
			return;
		ClientPrint(null, 3, "\x04本次击杀了共\x03 " + killTank +"\x04 只Tank，伤害贡献如下");
		for (local i=0; i<player && i<len; i++)
		{
			name = PlayerInstanceFromIndex(idx[i]).GetPlayerName();
			ClientPrint(null, 3, format("\x04[%d] \x03%-4d\x04 <- \x03%s",
				i+1, hurtData[idx[i]].tank, name));
		}
	}
}

// 根据当前的 Config.hurt.autoPrint 设置定时输出Timer
::LinGe.HUD.ApplyAutoHurtPrint <- function ()
{
	if (Config.hurt.autoPrint <= 0)
		::VSLib.Timers.RemoveTimerByName("Timer_AutoPrintHurt");
	else
		::VSLib.Timers.AddTimerByName("Timer_AutoPrintHurt", Config.hurt.autoPrint, true, PrintChatRank);

	::LinEventUnHook("OnGameEvent_round_end", ::LinGe.HUD.PrintChatRank);
	::LinEventUnHook("OnGameEvent_map_transition", ::LinGe.HUD.PrintChatRank);
	if (Config.hurt.autoPrint >= 0)
	{
		// 回合结束时输出本局伤害统计
		::LinEventHook("OnGameEvent_round_end", ::LinGe.HUD.PrintChatRank);
		::LinEventHook("OnGameEvent_map_transition", ::LinGe.HUD.PrintChatRank);
	}
}

// 向聊天窗公布当前的伤害数据统计
// params是预留参数位置 为方便关联事件和定时器
::LinGe.HUD.PrintChatRank <- function (params=0)
{
	local player = Config.hurt.chatRank;
	local survivorIdx = clone ::pyinfo.survivorIdx;
	local name = "", len = survivorIdx.len();
	if (len > 0)
	{
		local atkMax = { name="", hurt=0 };
		local vctMax = clone atkMax;
		// 遍历找出黑枪最多和被黑最多
		for (local i=0; i<len; i++)
		{
			local temp = hurtData[survivorIdx[i]];
			if (temp.atk > atkMax.hurt)
			{
				atkMax.hurt = temp.atk;
				atkMax.name = PlayerInstanceFromIndex(survivorIdx[i]).GetPlayerName();
			}
			if (temp.vct > vctMax.hurt)
			{
				vctMax.hurt = temp.vct;
				vctMax.name = PlayerInstanceFromIndex(survivorIdx[i]).GetPlayerName();
			}
		}
		if (player > 0)
		{
			hurtDataSort(survivorIdx, Pre.ChatKey);
			// 按照对特感伤害，依次输出伤害数据
			for (local i=0; i<player && i<len; i++)
			{
				name = PlayerInstanceFromIndex(survivorIdx[i]).GetPlayerName();
				ClientPrint(null, 3, format("\x04%s <- \x03%s"
					, Pre.ChatFunc(survivorIdx[i]), name));
			}
		}

		// 显示最高黑枪和最高被黑
		if (0 == atkMax.hurt && 0 == vctMax.hurt)
			ClientPrint(null, 3, "\x05大家真棒，没有友伤的世界达成了~");
		else if (0 == atkMax.hurt && 0 < vctMax.hurt)
		{
			ClientPrint(null, 3,
				format("\x04可怜的 \x03%s\x04 被跑掉的黑心人欺负了 \x03%d \x04血",
					vctMax.name, vctMax.hurt));
		}
		else if (0 < atkMax.hurt && 0 == vctMax.hurt)
		{
			ClientPrint(null, 3,
				format("\x04大魔王 \x03%s\x04 打出了 \x03%d\x04 的友伤，把人都打跑了呢",
					atkMax.name, atkMax.hurt));
		}
		else
		{
			ClientPrint(null, 3,
				format("\x04队友鲨手:\x03%s\x04(\x03%d\x04) 都欺负我:\x03%s\x04(\x03%d\x04)",
					atkMax.name, atkMax.hurt, vctMax.name, vctMax.hurt));
		}
	}
}.bindenv(::LinGe.HUD);

// 冒泡排序 默认降序排序
::LinGe.HUD.hurtDataSort <- function (survivorIdx, key, desc=true)
{
	local temp;
	local len = survivorIdx.len();
	local result = desc ? 1 : -1;
	for (local i=0; i<len-1; i++)
	{
		for (local j=0; j<len-1-i; j++)
		{
			if (hurtDataCompare(survivorIdx[j], survivorIdx[j+1], key, 0) == result)
			{
				temp = survivorIdx[j];
				survivorIdx[j] = survivorIdx[j+1];
				survivorIdx[j+1] = temp;
			}
		}
	}
}

::LinGe.HUD.hurtDataCompare <- function (idx1, idx2, key, keyIdx)
{
	if (hurtData[idx1][key[keyIdx]] > hurtData[idx2][key[keyIdx]])
		return -1;
	else if (hurtData[idx1][key[keyIdx]] == hurtData[idx2][key[keyIdx]])
	{
		if (keyIdx+1 < key.len()) // 如果还有可比较的值就继续比较
			return hurtDataCompare(idx1, idx2, key, keyIdx+1);
		else
			return 0;
	}
	else
		return 1;
}