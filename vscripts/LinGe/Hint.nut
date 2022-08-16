// https://developer.valvesoftware.com/wiki/Env_instructor_hint:zh-cn
// 该功能必须开启 游戏菜单-选项-多人联机-游戏提示
// 只在非对抗模式下加载此功能
if (!::LinGe.isVersus) {

printl("[LinGe] 标记提示 正在载入");
::LinGe.Hint <- {};

::LinGe.Hint.Config <- {
	limit = 4, // 玩家屏幕上能同时显示的提示数量上限
	offscreenShow = true, // 提示在画面之外是否也要显示
	help = { // 队友需要帮助时出现提示 包括 倒地、挂边、黑白、被控
		duration = 15, // 提示持续时间，若<=0则彻底关闭所有队友需要帮助的提示
		dominateDelay = 0, // 被控延迟，玩家被控多少秒后才会出现提示，若设置为0则无延迟立即显示
						// 若<0，则不会自动提示玩家被控，但是玩家可以用按键自己发出呼救
		smoker = "被捆绑Play",
		hunter = "被扑倒了",
		charger = "被牛牛顶了",
		jockey = "要被玩坏了",
		ledge = "笨比地挂边了",
		dying = "濒死",
		incap = "倒地了",
	},
	ping = {
		duration = 12, // 玩家用按键发出信号的持续时间，若<=0则禁止玩家发出信号
		emptySpace = true, // 可以标记到什么都没有的位置
		weaponMessage = true, // 标记到物资时在聊天窗发出提示消息
	},
	deadHint = true, // 死亡时不会出现标记提示，不过会在聊天窗输出提示 若设置为 false 则关闭该提示
					// 该提示对BOT不生效
	deadChat = "再见了大家，我会想念你们的", // 若这里设置为 "" 或者 null 则以服务器式提示输出
};
::LinGe.Config.Add("Hint", ::LinGe.Hint.Config);
// ::LinGe.Cache.Hint_Config <- ::LinGe.Hint.Config;
if (::LinGe.Hint.Config.limit > 8)
{
	::LinGe.Hint.Config.limit = 8;
	printl("[LinGe] LinGe.Hint.Config.limit 超过上限值，自动置为 8");
}

::LinGe.Hint.OnGameEvent_player_death <- function (params)
{
    local dier = 0;	// 死者ID
	local dierEntity = null;
	if (params.victimname == "Witch")
	{
		dier = params.entityid;
		dierEntity = Ent(dier);
	}
	else if (params.victimname == "Infected")
		return;
	else
	{
		dier = params.userid;
		dierEntity = GetPlayerFromUserID(dier);
	}
	if (dier == 0)
		return;

	if (dierEntity)
	{
		if (this.rawin("RemoveHint"))
			RemoveHint(dierEntity);
		if (!Config.deadHint)
			return;

		// 生还者玩家死亡时输出提示
		if (::LinGe.GetPlayerTeam(dierEntity) != 2)
			return;
		// 自杀时伤害类型为0
		if (params.type == 0)
			return;
		if (!IsPlayerABot(dierEntity))
		{
			if (null == Config.deadChat || "" == Config.deadChat)
				ClientPrint(null, 3, "\x03" + dierEntity.GetPlayerName() + "\x04 牺牲了");
			else
				Say(dierEntity, "\x03" + Config.deadChat, false);
		}
	}
}
::LinEventHook("OnGameEvent_player_death", ::LinGe.Hint.OnGameEvent_player_death, ::LinGe.Hint);

// 数量限制不大于0时不加载标记提示功能
if (::LinGe.Hint.Config.limit > 0) {

enum HINTMODE {
	DOMINATE = 0, // 适用队友被控
	REVIVE, // 适用于队友倒地、挂边
	DYING, // 适用于队友黑白
	SPECIAL, // 适用于显示在特感上的标记
	WEAPON, // 适用于物资
	NORMAL, // 提示总是持续到设定时间才会关闭
	SCREEN, // 不管配置文件如何设定，提示都只在屏幕内显示
	SIGHT, // 提示只显示在视野内（不会在屏幕外和墙体后显示）
	RUN, // 适用于路线标记
	SELFSHOW, // 只显示给自己的提示
	__MAX__
};
getconsttable()["LINGE_NONE_ICON"] <- "";

local humanPlayer = [];
local playerHint = {};
local buttonState = {};
local hintEvent = {};

::LinGe.Hint.OnGameEvent_round_start <- function (params)
{
	// 给玩家添加按键监控与提示事件记录
	foreach (val in ::pyinfo.survivorIdx)
	{
		local player = PlayerInstanceFromIndex(val);
		if (player.GetNetworkIDString() != "BOT")
		{
			humanPlayer.append(val);
			SetPlayerHint(val);
			buttonState.rawset(val, 0);
		}
	}
}
::LinEventHook("OnGameEvent_round_start", ::LinGe.Hint.OnGameEvent_round_start, ::LinGe.Hint);

// 玩家队伍变更，当某生还者出现队伍变更时，重置其身上的提示状态
::LinGe.Hint.OnGameEvent_player_team <- function (params)
{
	if (!params.rawin("userid"))
		return;
	local player = GetPlayerFromUserID(params.userid);

	RemoveHint(player); // 不论如何，发生队伍变更都应移除其身上的提示
	local index = player.GetEntityIndex();
	if (2 == params.oldteam)
	{
		if (player.GetNetworkIDString() != "BOT")
		{
			::LinGe.RemoveInArray(index, humanPlayer);
			foreach (hintEnt in playerHint[index].entTbl)
				DoEntFire("!self", "Kill", "", 0, null, hintEnt);
			playerHint.rawdelete(index);
			buttonState.rawdelete(index);
		}
	}
	else if (2 == params.team)
	{
		if (player.GetNetworkIDString() != "BOT")
		{
			humanPlayer.append(index);
			SetPlayerHint(index);
			buttonState.rawset(index, 0);
		}
	}
}
::LinEventHook("OnGameEvent_player_team", ::LinGe.Hint.OnGameEvent_player_team, ::LinGe.Hint);

::LinGe.Hint.SetPlayerHint <- function (player)
{
	local index = 0;
	if (typeof player == "instance")
		index = player.GetEntityIndex();
	else if (typeof player == "integer")
		index = player;
	else
		throw "player 参数类型非法";

	playerHint.rawset(index, { entTbl={}, countTbl={}, lastChanged={} });
	local countTbl = playerHint[index].countTbl;
	local lastChanged = playerHint[index].lastChanged;
	foreach (targetname, eventInfo in hintEvent)
	{
		countTbl.rawset(targetname, 0);
		lastChanged.rawset(targetname, -9999);
	}
}
local timeout = 0;
if (::LinGe.Hint.Config.help.duration > ::LinGe.Hint.Config.ping.duration)
	timeout = ::LinGe.Hint.Config.help.duration;
else
	timeout = ::LinGe.Hint.Config.ping.duration;
local hintTemplateTbl = {
	classname = "env_instructor_hint",
	hint_allow_nodraw_target = "1",
	hint_auto_start = "0",
	hint_binding = "",
	hint_caption = "",
	hint_color = "255 255 255",
	hint_forcecaption = "1",
	hint_suppress_rest = "0",
	hint_nooffscreen = "0",
	hint_icon_offscreen = "",
	hint_icon_offset = "0",
	hint_icon_onscreen = "",
	hint_instance_type = "0",
	hint_alphaoption = 0, // alphapulse 图标会变透明和可见的速度 0~3
	hint_pulseoption = 0, // 图标效果，图标收缩的速度 0~3
	hint_shakeoption = 0,	// shaking 图标会抖动 0~2
	hint_range = "0",
	hint_static = "0", // 跟随实体目标
	hint_target = "",
	hint_timeout = timeout, // 避免BUG情况下提示一直不关闭
	origin = Vector(0, 0, 0),
	angles = QAngle(0, 0, 0),
	targetname = ""
};

// 添加提示事件
::LinGe.Hint.AddHint <- function (target, icon, text, level, duration, hintMode, activator = null)
{
	local targetEnt = null;
	if (typeof target == "instance")
	{
		targetEnt = target;
		target = ::LinGe.GetEntityTargetname(target);
	}
	else if (typeof target == "string")
	{
		targetEnt = Entities.FindByName(null, target);
	}
	else
		throw "target 参数类型非法";

	if (!targetEnt || !targetEnt.IsValid())
		throw "targetEnt 无效";

	if (hintMode < 0 || hintMode >= HINTMODE.__MAX__)
		throw "hintMode 参数非法";

	local hintTbl = clone hintTemplateTbl;
	hintTbl.hint_target = target;
	hintTbl.hint_icon_onscreen = icon,
	hintTbl.hint_icon_offscreen = icon,
	hintTbl.hint_caption = text.tostring();
	hintTbl.hint_alphaoption = level > 2 ? 1 : 0;
	hintTbl.hint_pulseoption = level > 2 ? 1 : 0;

	if (hintMode == HINTMODE.SELFSHOW)
	{
		if (!activator || !activator.IsValid())
			throw "activator 无效";
		hintTbl.hint_nooffscreen = "1";
		hintTbl.hint_forcecaption = "0";
		hintTbl.hint_suppress_rest = "1";
		local ent = QuickShowHint(hintTbl, activator);
		if (ent)
		{
			::VSLib.Timers.AddTimerByName("KillHint_" + hintTbl.targetname,	duration,
				false, @(ent) DoEntFire("!self", "Kill", "", 0.0, null, ent), ent);
		}
	}
	else
	{
		RemoveHint(target);
		if (!AtLeastOne(level))
			return;
		local eventInfo = {
			startTime = Time(),
			level = level,
			hintMode = hintMode,
			hintTbl = hintTbl,
			targetEnt = targetEnt,
			activator = activator
		};
		hintEvent.rawset(target, eventInfo);
		foreach (tbl in playerHint)
		{
			tbl.countTbl.rawset(target, 0);
			tbl.lastChanged.rawset(target, -9999);
		}

		if (duration <= 0.0) // 不允许设置永远存在的提示，避免实体一直不被Kill
			duration = 8.0;
		::VSLib.Timers.AddTimerByName("RemoveHint_" + target,
			duration, false, RemoveHint, target);
		Timer_PlayerHint();
	}
}

// RemoveHint 去除提示
::LinGe.Hint.RemoveHint <- function (params)
{
	local targetname = null;
	if (typeof params == "instance")
		targetname = params.GetName();
	else if (typeof params == "string")
		targetname = params;
	else
		throw "参数非法";

	if (targetname == "" || !hintEvent.rawin(targetname))
		return;
	::VSLib.Timers.RemoveTimerByName("RemoveHint_" + targetname);
	foreach (tbl in playerHint)
	{
		if (tbl.entTbl.rawin(targetname))
		{
			DoEntFire("!self", "Kill", "", 0, null, tbl.entTbl[targetname]);
			tbl.entTbl.rawdelete(targetname);
		}
		tbl.countTbl.rawdelete(targetname);
		tbl.lastChanged.rawdelete(targetname);
	}
	hintEvent.rawdelete(targetname);
}.bindenv(::LinGe.Hint);

// 保证至少一个空位。若空位不足，则清理一个最低级别的信息
// 若无可清理的空位，返回 false
local eventLimit = ::LinGe.Hint.Config.limit * 3;
::LinGe.Hint.AtLeastOne <- function (level)
{
	if (level < 0) // level < 0 表示该提示无视上限
		return true;
	if (hintEvent.len() < eventLimit)
		return true;

	local minLevel = level;
	local name = null, count = 0;
	foreach (targetname, eventInfo in hintEvent)
	{
		if (eventInfo.level >= 0)
		{
			count++;
			if (eventInfo.level < minLevel)
			{
				minLevel = eventInfo.level;
				name = targetname;
			}
		}
	}
	// 如果 level >= 0 的项目小于限制数量 则可以不清理
	if (count < eventLimit)
		return true;

	if (name != null)
	{
		RemoveHint(name);
		return true;
	}
	else
		return false;
}

local humanIndex = 0;
::LinGe.Hint.Timer_PlayerHint <- function (params=null)
{
	local idx=0;
	for (idx=humanIndex; idx<humanPlayer.len() && idx<humanIndex+4; idx++)
	{
		local playerIndex = humanPlayer[idx];
		local player = PlayerInstanceFromIndex(playerIndex);
		if (!::LinGe.IsAlive(player))
			continue;

		local countTbl = playerHint[playerIndex].countTbl;
		local entTbl = playerHint[playerIndex].entTbl;
		local lastChanged = playerHint[playerIndex].lastChanged;

		// 检查每个提示事件，是否应显示在该玩家的屏幕上
		foreach (targetname, count in countTbl)
		{
			local eventInfo = hintEvent[targetname];
			// 如果对象实体是无效的则移除
			if (!eventInfo.targetEnt || !eventInfo.targetEnt.IsValid())
			{
				RemoveHint(targetname);
				continue;
			}

			local hintMode = eventInfo.hintMode;
			if (hintMode == HINTMODE.WEAPON
			&& eventInfo.targetEnt.GetMoveParent() != null)
			{
				// 如果是物资标记，该物资若为有主，则移除该标记
				RemoveHint(targetname);
				continue;
			}

			local hintTbl = eventInfo.hintTbl;
			// 对于主动发出标记的人来说，这个标记总是显示2s后自动消失
			// 不会透过墙体显示，也不会在屏幕外显示，且总是不占用显示位
			if (eventInfo.activator == player)
			{
				if (countTbl[targetname] == 0)
				{
					hintTbl.hint_nooffscreen = "1";
					hintTbl.hint_forcecaption = "0";
					hintTbl.hint_suppress_rest = "1";
					PlayerHint_Show(targetname, player);
				}
				else
				{
					if (entTbl.rawin(targetname) && (Time() - lastChanged[targetname]) > 2)
					{
						PlayerHint_Kill(targetname, player);
					}
				}
				continue;
			}

			if (entTbl.rawin(targetname))
			{
				// 对于第一次出现的不紧急的信息，4秒后玩家不看向这个方向时就将其隐藏
				if (eventInfo.level < 2 && count == 1)
				{
					if (Time() - lastChanged[targetname] > 4
					&& !::LinGe.IsPlayerSeeHere(player, eventInfo.targetEnt, 60))
					{
						PlayerHint_Kill(targetname, player);
						continue;
					}
				}
				switch (hintMode)
				{
				case HINTMODE.REVIVE:
					local owner = NetProps.GetPropEntity(eventInfo.targetEnt, "m_reviveOwner");
					// 如果玩家受到救助了，则隐藏
					if (owner && owner.IsValid())
					{
						PlayerHint_Kill(targetname, player);
						continue;
					}
					// 未受到救助，则按玩家被控处理
				case HINTMODE.SPECIAL:
				case HINTMODE.DOMINATE:
					if (!::LinGe.IsPlayerSeeHere(player, eventInfo.targetEnt, 40))
						continue;
					if (!::LinGe.ChainTraceToEntity(player, eventInfo.targetEnt, MASK_SHOT_HULL,
							["player", "infected", "witch"]) )
						continue;
					// 以40的角度差看向这个方向，且能链式追踪到实体（能够看到而无墙体遮挡物），则隐藏
					PlayerHint_Kill(targetname, player);
					continue;
				case HINTMODE.DYING:
					local owner = NetProps.GetPropEntity(eventInfo.targetEnt, "m_useActionOwner");
					if (!owner || !owner.IsValid() || !owner.IsSurvivor())
						continue;
					local weapon = owner.GetActiveWeapon();
					if (!weapon || !weapon.IsValid() || weapon.GetClassname() != "weapon_first_aid_kit")
						continue;
					// 正在受到治疗则隐藏
					PlayerHint_Kill(targetname, player);
					continue;
				case HINTMODE.WEAPON:
					if ((player.GetOrigin()-eventInfo.targetEnt.GetOrigin()).Length() >= 250.0)
						continue;
					if (!::LinGe.IsPlayerNoticeEntity(player, eventInfo.targetEnt, 15,
						MASK_SHOT_HULL & (~CONTENTS_WINDOW), 15.0))
						continue;
					PlayerHint_Kill(targetname, player);
					continue;
				case HINTMODE.RUN:
					if (Time() - lastChanged[targetname] < 3)
						continue;
					if ((player.GetOrigin()-eventInfo.targetEnt.GetOrigin()).Length() >= 250.0)
						continue;
					PlayerHint_Kill(targetname, player);
					continue;
				default: // 其它事件均不进行动态关闭
					continue;
				}
			}
			else
			{
				switch (hintMode)
				{
				case HINTMODE.SPECIAL:
					if (count >= 1)
						continue;
					if (::LinGe.IsPlayerSeeHere(player, eventInfo.targetEnt, 40)
					&& ::LinGe.ChainTraceToEntity(player, eventInfo.targetEnt, MASK_SHOT_HULL,
						["player", "infected", "witch"]))
					{
						count = 1; // 如果已经能看到这个特感了，那么就视作已经出现过一次提示
						continue;
					}
					break;
				case HINTMODE.DYING:
					if (player == eventInfo.targetEnt) // 不会显示给自己
						continue;
					if (Time() - lastChanged[targetname] < 2)
						continue;
					// 如果没受到治疗则显示
					local owner = NetProps.GetPropEntity(eventInfo.targetEnt, "m_useActionOwner");
					if (!owner || !owner.IsValid() || !owner.IsSurvivor())
						break;
					local weapon = owner.GetActiveWeapon();
					if (!weapon || !weapon.IsValid() || weapon.GetClassname() != "weapon_first_aid_kit")
						break;
					continue;
				case HINTMODE.REVIVE:
					if (Time() - lastChanged[targetname] < 2)
						continue;
					// 玩家已经受到救助了则不显示
					local owner = NetProps.GetPropEntity(eventInfo.targetEnt, "m_reviveOwner");
					if (owner && owner.IsValid())
						continue;
					// 如果还没有受到救助，则继续按玩家被控处理
				case HINTMODE.DOMINATE:
					if (player == eventInfo.targetEnt) // 不会显示给自己
						continue;
					if (count >= 2) // 已经提示过2次则不再显示
						continue;
					if (::LinGe.IsPlayerSeeHere(player, eventInfo.targetEnt, 40)) // 已经看向该角度时不显示
						continue;
					if (count > 0 && (player.GetOrigin()-eventInfo.targetEnt.GetOrigin()).Length() < 500) // 已经注意到过这个提示一次，并且距离小于500时不显示
						continue;
					break;
				case HINTMODE.WEAPON:
					if (count >= 2)
						continue;
					break;
				case HINTMODE.RUN:
					if (count >= 2)
						continue;
					break;
				default:
					break;
				}
				// 对于此前提示过的非紧急提示，只在玩家再次看向这个方向时再提示
				local isInScreen = false;
				if (eventInfo.level < 2 && count > 0)
				{
					if (::LinGe.IsPlayerSeeHere(player, eventInfo.targetEnt, 50))
						isInScreen = true;
					else
						continue;
				}

				if (!AtLeastOne_Player(eventInfo.level, player))
					continue;

				if (isInScreen || hintMode == HINTMODE.SCREEN
				|| hintMode == HINTMODE.SIGHT || !Config.offscreenShow)
					hintTbl.hint_nooffscreen = "1";
				else
					hintTbl.hint_nooffscreen = "0";
				if (hintMode == HINTMODE.SIGHT)
					hintTbl.hint_forcecaption = "0";
				else
					hintTbl.hint_forcecaption = "1";
				if (isInScreen)
					hintTbl.hint_suppress_rest = "1";
				else
					SetSuppressRest(hintTbl, player, eventInfo.targetEnt);
				PlayerHint_Show(targetname, player);
			}
		}
	}

	humanIndex = idx < humanPlayer.len() ? idx : 0;
}.bindenv(::LinGe.Hint);
::VSLib.Timers.AddTimerByName("Timer_PlayerHint", 0.1, true, ::LinGe.Hint.Timer_PlayerHint);

// 保留最少一个空位，针对单个玩家的
::LinGe.Hint.AtLeastOne_Player <- function (level, player)
{
	if (level < 0) // level < 0 表示该提示无视上限
		return true;
	local entTbl = playerHint[player.GetEntityIndex()].entTbl;
	local lastChanged = playerHint[player.GetEntityIndex()].lastChanged;
	if (entTbl.len() < Config.limit)
		return true;

	local minLevel = level;
	local name = null, count = 0;
	foreach (targetname, ent in entTbl)
	{
		if (hintEvent[targetname].activator == player)
			continue;
		local eventLevel = hintEvent[targetname].level;
		if (eventLevel >= 0)
		{
			count++;
			if (eventLevel < minLevel)
			{
				minLevel = eventLevel;
				name = targetname;
			}
		}
	}
	if (count < Config.limit)
		return true;

	if (name != null)
	{
		PlayerHint_Kill(name, player);
		return true;
	}
	else
		return false;
}

::LinGe.Hint.QuickShowHint <- function (tbl, player)
{
	tbl.rawset("targetname", "LinGe_" + UniqueString());
	local ent = g_ModeScript.CreateSingleSimpleEntityFromTable(tbl);
	if (!ent)
	{
		printl("[LinGe] QuickShowHint 创建实体失败");
		return null;
	}
	ent.ValidateScriptScope();
	DoEntFire("!self", "ShowHint", "", 0.0, player, ent);
	return ent;
}


::LinGe.Hint.PlayerHint_Show <- function (targetname, player)
{
	local tbl = playerHint[player.GetEntityIndex()];
	local ent = QuickShowHint(hintEvent[targetname].hintTbl, player);
	if (ent)
		tbl.entTbl.rawset(targetname, ent);
	tbl.countTbl[targetname]++;
	tbl.lastChanged.rawset(targetname, Time());
}

::LinGe.Hint.PlayerHint_Kill <- function (targetname, player)
{
	local tbl = playerHint[player.GetEntityIndex()];
	if (tbl.entTbl.rawin(targetname))
		DoEntFire("!self", "Kill", "", 0.0, null, tbl.entTbl[targetname]);
	tbl.entTbl.rawdelete(targetname);
	tbl.lastChanged.rawset(targetname, Time());
}

// 根据玩家的视角来设置 hint_suppress_rest
::LinGe.Hint.SetSuppressRest <- function (tbl, player, targetEnt)
{
	if (::LinGe.IsPlayerSeeHere(player, targetEnt, 50))
		tbl.rawset("hint_suppress_rest", "1");
	else
		tbl.rawset("hint_suppress_rest", "0");
}

::LinGe.Hint.SurvivorArrayIndexToEnt <- function (array)
{
	local newArray = [];
	foreach (val in array)
	{
		local player = null;
		if (typeof val == "integer")
			player = PlayerInstanceFromIndex(val);
		else if (typeof val == "instance")
			player = val;
		if (!IsPlayerABot(player))
			newArray.append(player);
	}
	return newArray;
}


// 事件：玩家倒地
::LinGe.Hint.OnGameEvent_player_incapacitated <- function (params)
{
	if (!params.rawin("userid") || params.userid == 0)
		return;

	local player = GetPlayerFromUserID(params.userid);
	if (player.IsSurvivor())
	{
		if (Config.help.dominateDelay >= 0 && null != player.GetSpecialInfectedDominatingMe()) // 如果可能已经有被控提示存在则先不提示倒地
			return;
		// 摔死时会有短暂的倒地 所以延迟0.1s再判断是否处于倒地
		VSLib.Timers.AddTimerByName(params.userid, 0.1, false, ShowPlayerIncap, player);
	}
}
if (::LinGe.Hint.Config.help.duration > 0)
	::LinEventHook("OnGameEvent_player_incapacitated", ::LinGe.Hint.OnGameEvent_player_incapacitated, ::LinGe.Hint);
::LinGe.Hint.ShowPlayerIncap <- function (player, activator=null)
{
	if (Config.help.duration <= 0)
		return;
	if (!player.IsValid() || !player.IsIncapacitated())
		return;
	AddHint(player, "icon_alert", player.GetPlayerName() + Config.help.incap, 1,
		Config.help.duration, HINTMODE.REVIVE, activator);
}.bindenv(::LinGe.Hint);

// 玩家挂边
::LinGe.Hint.OnGameEvent_player_ledge_grab <- function (params)
{
	if (!params.rawin("userid"))
		return;
	local player = GetPlayerFromUserID(params.userid);
	ShowPlayerLedge(player);
}
if (::LinGe.Hint.Config.help.duration > 0)
	::LinEventHook("OnGameEvent_player_ledge_grab", ::LinGe.Hint.OnGameEvent_player_ledge_grab, ::LinGe.Hint);
::LinGe.Hint.ShowPlayerLedge <- function (player, activator=null)
{
	if (Config.help.duration <= 0)
		return;
	AddHint(player, "icon_alert", player.GetPlayerName() + Config.help.ledge, 2,
		Config.help.duration, HINTMODE.REVIVE, activator);
}

// 成功救助队友 （倒地拉起、挂边拉起都会触发该事件）
::LinGe.Hint.OnGameEvent_revive_success <- function (params)
{
	if (!params.rawin("subject"))
		return;
	local player = GetPlayerFromUserID(params.subject);
	if (!player.IsSurvivor())
		return;
	RemoveHint(player); // 去除其身上的标志

	if (::LinGe.GetReviveCount(player) >= 2)
		ShowPlayerDying(player);
}
if (::LinGe.Hint.Config.help.duration > 0)
	::LinEventHook("OnGameEvent_revive_success", ::LinGe.Hint.OnGameEvent_revive_success, ::LinGe.Hint);

// 成功完成治疗
::LinGe.Hint.OnGameEvent_heal_success <- function (params)
{
	if (!params.rawin("subject"))
		return;
	local player = GetPlayerFromUserID(params.subject);
	if (!player.IsSurvivor())
		return;
	RemoveHint(player);
}
if (::LinGe.Hint.Config.help.duration > 0)
	::LinEventHook("OnGameEvent_heal_success", ::LinGe.Hint.OnGameEvent_heal_success, ::LinGe.Hint);

::LinGe.Hint.ShowPlayerDying <- function (player, activator=null)
{
	if (Config.help.duration <= 0)
		return;
	AddHint(player, "icon_medkit", player.GetPlayerName() + Config.help.dying, 1,
		Config.help.duration, HINTMODE.DYING, activator);
}

// 玩家被控
::LinGe.Hint.PlayerBeDominating <- function (params)
{
	if (!params.rawin("victim") || !params.rawin("userid"))
		return;
	local player = GetPlayerFromUserID(params.victim);
	if (Config.help.dominateDelay > 0)
		::VSLib.Timers.AddTimerByName("BeDominating_" + ::LinGe.GetEntityTargetname(player),
			Config.help.dominateDelay, false, ShowPlayerBeDominating, player);
	else
		ShowPlayerBeDominating(player);
}
if (::LinGe.Hint.Config.help.duration > 0 && ::LinGe.Hint.Config.help.dominateDelay >= 0)
{
	::LinEventHook("OnGameEvent_lunge_pounce", ::LinGe.Hint.PlayerBeDominating, ::LinGe.Hint); // Hunter
	::LinEventHook("OnGameEvent_tongue_grab", ::LinGe.Hint.PlayerBeDominating, ::LinGe.Hint); // Smoker
	::LinEventHook("OnGameEvent_charger_pummel_start", ::LinGe.Hint.PlayerBeDominating, ::LinGe.Hint); // Charger
	::LinEventHook("OnGameEvent_jockey_ride", ::LinGe.Hint.PlayerBeDominating, ::LinGe.Hint); // Jockey
}

::LinGe.Hint.ShowPlayerBeDominating <- function (player, activator=null)
{
	if (Config.help.duration <= 0)
		return;
	if (!player.IsValid() || ::LinGe.GetPlayerTeam(player) != 2)
		return;
	local dominator = player.GetSpecialInfectedDominatingMe();
	if (!dominator || !dominator.IsValid())
		return;
	local text = player.GetPlayerName();
	switch (dominator.GetZombieType())
	{
	case 1: // Smoker
		text += Config.help.smoker;
		break;
	case 3: // Hunter
		text += Config.help.hunter;
		break;
	case 5: // Jockey
		text += Config.help.jockey;
		break;
	case 6: // Charger
		text += Config.help.charger;
		break;
	default:
		throw "不可预见的错误";
	}
	AddHint(player, "icon_blank", text, 3, Config.help.duration, HINTMODE.DOMINATE, activator);
}.bindenv(::LinGe.Hint);

// 被控解除
::LinGe.Hint.PlayerDominateEnd <- function (params)
{
	if (!params.rawin("victim") || params.victim == 0)
		return;
	local player = GetPlayerFromUserID(params.victim);
	if (::LinGe.IsAlive(player) && player.IsIncapacitated())
		ShowPlayerIncap(player);
	else
		RemoveHint(player);
}
if (::LinGe.Hint.Config.help.duration > 0)
{
	::LinEventHook("OnGameEvent_pounce_stopped", ::LinGe.Hint.PlayerDominateEnd, ::LinGe.Hint);
	::LinEventHook("OnGameEvent_tongue_release", ::LinGe.Hint.PlayerDominateEnd, ::LinGe.Hint);
	::LinEventHook("OnGameEvent_charger_pummel_end", ::LinGe.Hint.PlayerDominateEnd, ::LinGe.Hint);
	::LinEventHook("OnGameEvent_jockey_ride_end", ::LinGe.Hint.PlayerDominateEnd, ::LinGe.Hint);
}

// BOT与玩家的交换，将状态进行转移
// BOT取代玩家
::LinGe.Hint.OnGameEvent_player_bot_replace <- function (params)
{
	local bot = GetPlayerFromUserID(params.bot);
	local player = GetPlayerFromUserID(params.player);
	if (::LinGe.GetPlayerTeam(bot) == 2)
	{
		::VSLib.Timers.AddTimerByName(::LinGe.GetEntityTargetname(bot),
			0.1, false, CheckSurvivor, bot);
	}
}
if (::LinGe.Hint.Config.help.duration > 0)
	::LinEventHook("OnGameEvent_player_bot_replace", ::LinGe.Hint.OnGameEvent_player_bot_replace, ::LinGe.Hint);

// 玩家取代BOT
::LinGe.Hint.OnGameEvent_bot_player_replace <- function (params)
{
	local bot = GetPlayerFromUserID(params.bot);
	local player = GetPlayerFromUserID(params.player);
	if (::LinGe.GetPlayerTeam(player) == 2)
	{
		::VSLib.Timers.AddTimerByName(::LinGe.GetEntityTargetname(player),
			0.1, false, CheckSurvivor, player);
	}
}
if (::LinGe.Hint.Config.help.duration > 0)
	::LinEventHook("OnGameEvent_bot_player_replace", ::LinGe.Hint.OnGameEvent_bot_player_replace, ::LinGe.Hint);

// 检查并在生还者身上出现状态提示，若其状态一切正常则返回true
::LinGe.Hint.CheckSurvivor <- function (player, activator=null)
{
	if (!player.IsValid() || ::LinGe.GetPlayerTeam(player) != 2
	|| !::LinGe.IsAlive(player))
		return false;

	if (player.GetSpecialInfectedDominatingMe())
		ShowPlayerBeDominating(player, activator);
	else if (player.IsIncapacitated())
		ShowPlayerIncap(player, activator);
	else if (player.IsHangingFromLedge())
		ShowPlayerLedge(player, activator);
	else if (::LinGe.GetReviveCount(player) >= 2)
		ShowPlayerDying(player, activator);
	else
		return true;
	return false;
}.bindenv(::LinGe.Hint);


// 实现玩家使用按键发出信号
// 以下用了很多 @samisalreadytaken 的 Contextual Ping System 标记系统 MOD 里的代码
// https://steamcommunity.com/sharedfiles/filedetails/?id=2638628508
// https://github.com/samisalreadytaken/vscripts/blob/master/left4dead2/ping_system.nut
// 所有可拾取/使用的物品名称 不一定只是武器
local weaponName = {
	oxygentank			= "氧气罐",
	propanetank			= "煤气罐",
	fireworkcrate		= "烟花",
	gnome				= "侏儒",
	cola_bottles		= "可乐",
	gascan				= "汽油桶",

	first_aid_kit		= "医疗包",
	pain_pills			= "止疼药",
	adrenaline			= "肾上腺素",
	defibrillator		= "电击器",

	upgradepack_explosive	= "高爆弹药包",
	upgradepack_incendiary	= "燃烧弹药包",
	laser_sight = "激光瞄准",

	pipe_bomb			= "土制炸弹",
	molotov				= "燃烧瓶",
	vomitjar			= "胆汁",

	ammo				= "弹药",
	melee				= "近战武器",
	baseball_bat		= "棒球棒",
	fireaxe				= "斧头",
	crowbar				= "撬棍",
	cricket_bat			= "板球拍",
	electric_guitar		= "电吉他",
	frying_pan			= "平底锅",
	golfclub			= "高尔夫球棒",
	katana				= "武士刀",
	knife				= "小刀",
	machete				= "砍刀",
	pitchfork			= "干草叉",
	shovel				= "铲子",
	tonfa				= "警棍",
	riotshield			= "防爆盾",
	chainsaw			= "电锯",

	pistol				= "手枪",
	pistol_magnum		= "马格南",
	shotgun_chrome		= "霰弹枪",
	pumpshotgun			= "霰弹枪",
	autoshotgun			= "自动霰弹枪",
	shotgun_spas		= "自动霰弹枪",
	grenade_launcher	= "榴弹",
	smg					= "SMG冲锋枪",
	smg_mp5				= "MP5冲锋枪",
	smg_silenced		= "MAC冲锋枪",
	rifle				= "M16步枪",
	rifle_ak47			= "AK47步枪",
	rifle_desert		= "SCAR步枪",
	rifle_sg552			= "SG552步枪",
	rifle_m60			= "M60机枪",
	sniper_scout		= "SCOUT狙击枪",
	sniper_awp			= "AWP狙击枪",
	hunting_rifle		= "猎枪",
	sniper_military		= "连发狙击枪",
};

local weaponIcon = { // 特定物品可以显示特定图标
	oxygentank			= "icon_interact",
	propanetank			= "icon_interact",
	fireworkcrate		= "icon_interact",
	gnome				= "icon_interact",
	cola_bottles		= "icon_cola_bottles",
	gascan				= "icon_gas_can",

	first_aid_kit		= "icon_equip_medkit",
	pain_pills			= "icon_equip_pills",
	adrenaline			= "icon_equip_adrenaline",
	defibrillator		= "icon_defibrillator",

	// upgradepack_explosive	= "linge_upgradepack_explosive",
	// upgradepack_incendiary	= "linge_upgradepack_incendiary",
	upgradepack_explosive	= "icon_interact",
	upgradepack_incendiary	= "icon_interact",
	laser_sight			= "icon_laser_sight",

	pipe_bomb			= "icon_equip_pipebomb",
	molotov				= "icon_equip_molotov",
	// vomitjar			= "linge_equip_vomitjar",
	vomitjar			= "icon_interact",

	ammo				= "icon_equip_ammopack",
	melee				= "icon_interact",
	baseball_bat		= "icon_baseball_bat",
	fireaxe				= "icon_fireaxe",
	crowbar				= "icon_crowbar",
	cricket_bat			= "icon_cricket_bat",
	electric_guitar		= "icon_guitar",
	frying_pan			= "icon_frying_pan",
	golfclub			= "icon_interact",
	katana				= "icon_katana",
	knife				= "icon_knife",
	machete				= "icon_machete",
	pitchfork			= "icon_interact",
	shovel				= "icon_interact",
	tonfa				= "icon_tonfa",
	riotshield			= "icon_interact",
	chainsaw			= "icon_chainsaw",

	// 还有一个双枪的标志 icon_equip_dualpistols 不过懒得写这个判断了
	pistol				= "icon_equip_pistol",
	pistol_magnum		= "icon_pistol",
	shotgun_chrome		= "icon_equip_chromeshotgun",
	pumpshotgun			= "icon_equip_pumpshotgun",
	autoshotgun			= "icon_equip_autoshotgun",
	shotgun_spas		= "icon_equip_spasshotgun",
	grenade_launcher	= "icon_equip_grenadelauncher",
	smg					= "icon_equip_uzi",
	// smg_mp5				= "linge_smg_mp5",
	smg_mp5				= "icon_interact",
	smg_silenced		= "icon_equip_silencedsmg",
	rifle				= "icon_equip_machinegun",
	// rifle_ak47			= "linge_rifle_ak47",
	rifle_ak47			= "icon_interact",
	// rifle_desert		= "icon_equip_desertrifle",
	rifle_desert		= "icon_interact",
	// rifle_sg552			= "linge_rifle_sg552",
	rifle_sg552			= "icon_interact",
	rifle_m60			= "icon_interact",
	// sniper_scout		= "linge_sniper_scout",
	// sniper_awp			= "linge_sniper_awp",
	sniper_scout		= "icon_interact",
	sniper_awp			= "icon_interact",
	hunting_rifle		= "icon_equip_rifle",
	sniper_military		= "icon_equip_militarysniper",
};

local weaponModelPath = {
	oxygentank			= "models/props_equipment/oxygentank01.mdl",
	propanetank			= "models/props_junk/propanecanister001a.mdl",
	cola_bottles		= "models/w_models/weapons/w_cola.mdl",
	gnome				= "models/props_junk/gnome.mdl",
	fireworkcrate		= "models/props_junk/explosive_box001.mdl",
	gascan				= "models/props_junk/gascan001a.mdl",

	first_aid_kit	= "models/w_models/weapons/w_eq_Medkit.mdl",
	pain_pills		= "models/w_models/weapons/w_eq_painpills.mdl",
	adrenaline		= "models/w_models/weapons/w_eq_adrenaline.mdl",
	defibrillator	= "models/w_models/weapons/w_eq_defibrillator.mdl",

	upgradepack_explosive	= "models/w_models/weapons/w_eq_explosive_ammopack.mdl",
	upgradepack_incendiary	= "models/w_models/weapons/w_eq_incendiary_ammopack.mdl",

	molotov		= "models/w_models/weapons/w_eq_molotov.mdl",
	pipe_bomb	= "models/w_models/weapons/w_eq_pipebomb.mdl",
	vomitjar	= "models/w_models/weapons/w_eq_bile_flask.mdl",

	// ammo				= "models/props/terror/ammo_stack.mdl",
	// ammo				= "models/props_unique/spawn_apartment/coffeeammo.mdl",
	baseball_bat		= "models/weapons/melee/w_bat.mdl",
	fireaxe				= "models/weapons/melee/w_fireaxe.mdl",
	crowbar				= "models/weapons/melee/w_crowbar.mdl",
	cricket_bat			= "models/weapons/melee/w_cricket_bat.mdl",
	electric_guitar		= "models/weapons/melee/w_electric_guitar.mdl",
	frying_pan			= "models/weapons/melee/w_frying_pan.mdl",
	golfclub			= "models/weapons/melee/w_golfclub.mdl",
	katana				= "models/weapons/melee/w_katana.mdl",
	knife				= "models/w_models/weapons/w_knife_t.mdl",
	machete				= "models/weapons/melee/w_machete.mdl",
	pitchfork			= "models/weapons/melee/w_pitchfork.mdl",
	shovel				= "models/weapons/melee/w_shovel.mdl",
	tonfa				= "models/weapons/melee/w_tonfa.mdl",
	riotshield			= "models/weapons/melee/w_riotshield.mdl",
	chainsaw			= "models/w_models/weapons/w_chainsaw.mdl",

	pistol				= "models/w_models/weapons/w_pistol_B.mdl",
	pistol_magnum		= "models/w_models/weapons/w_desert_eagle.mdl",
	shotgun_chrome		= "models/w_models/weapons/w_pumpshotgun_A.mdl",
	pumpshotgun			= "models/w_models/weapons/w_shotgun.mdl",
	autoshotgun			= "models/w_models/weapons/w_autoshot_m4super.mdl",
	shotgun_spas		= "models/w_models/weapons/w_shotgun_spas.mdl",
	grenade_launcher	= "models/w_models/weapons/w_grenade_launcher.mdl",
	smg					= "models/w_models/weapons/w_smg_uzi.mdl",
	smg_mp5				= "models/w_models/weapons/w_smg_mp5.mdl",
	smg_silenced		= "models/w_models/weapons/w_smg_a.mdl",
	rifle				= "models/w_models/weapons/w_rifle_m16a2.mdl",
	rifle_ak47			= "models/w_models/weapons/w_rifle_ak47.mdl",
	rifle_desert		= "models/w_models/weapons/w_desert_rifle.mdl",
	rifle_sg552			= "models/w_models/weapons/w_rifle_sg552.mdl",
	rifle_m60			= "models/w_models/weapons/w_m60.mdl",
	sniper_scout		= "models/w_models/weapons/w_sniper_scout.mdl",
	sniper_awp			= "models/w_models/weapons/w_sniper_awp.mdl",
	hunting_rifle		= "models/w_models/weapons/w_sniper_mini14.mdl",
	sniper_military		= "models/w_models/weapons/w_sniper_military.mdl",
};

local weaponEntity = {};
local weaponSpawn = {};
local weaponModel = {};
foreach ( k, v in weaponName )
	weaponEntity[ "weapon_" + k ] <- k; // 会有不少不存在的实体名 不过无所谓
foreach ( k, v in weaponName )
	weaponSpawn[ "weapon_" + k + "_spawn" ] <- k;
foreach ( k, v in weaponModelPath )
	weaponModel[v] <- k;

local zombieType = ["Smoker", "Boomer", "Hunter", "Spitter",
	"Jockey", "Charger", "Witch", "Tank"];

const MAX_COORD_FLOAT	= 16384.0;
const MAX_TRACE_LENGTH	= 56755.840862417;

// 玩家使用按键发出信号
::LinGe.Hint.PlayerPing <- function (player)
{
	if (Config.ping.duration <= 0)
		return;
	if (typeof player == "integer")
		player = GetPlayerFromUserID(player);
	if (typeof player != "instance")
		throw "player 无效";
	if (Config.help.duration > 0)
	{
		if (player.GetSpecialInfectedDominatingMe())
		{
			ShowPlayerBeDominating(player);
			ClientPrint(player, 3, "\x05已发出被控求救信号");
		}
		// 如果玩家处于虚弱状态，则发出求救信号
		else if (player.IsIncapacitated())
		{
			ShowPlayerIncap(player);
			ClientPrint(player, 3, "\x05已发出倒地求救信号");
		}
		else if (player.IsHangingFromLedge())
		{
			ShowPlayerLedge(player);
			ClientPrint(player, 3, "\x05已发出挂边求救信号");
		}
		else
			PingTrace(player);
	}
	// else
	// 	PingTrace(player);
}.bindenv(::LinGe.Hint);
if (::LinGe.Hint.Config.ping.duration > 0)
	::LinPlayerPing <- ::LinGe.Hint.PlayerPing.weakref(); // 这是留给插件调用的
else
	getroottable().rawdelete("LinPlayerPing");

// 通过玩家视野进行光线追踪查找实体
::LinGe.Hint.PingTrace <- function (player)
{
	local eyePos = player.EyePosition();
	local tr = {
		start = eyePos,
		end = eyePos + player.EyeAngles().Forward().Scale( MAX_TRACE_LENGTH ),
		ignore = player,
		mask = MASK_SHOT_HULL & (~CONTENTS_WINDOW),
	};

	TraceLine(tr);
	PingEntity(player, tr.enthit, tr.pos);
}

// 标记到实体
::LinGe.Hint.PingEntity <- function (player, pEnt, vecPingPos = null)
{
	local szClassname = pEnt.GetClassname();

	switch ( szClassname )
	{
	case "player":
		if (::LinGe.GetPlayerTeam(pEnt) == 3) // 如果是特感
		{
			local type = pEnt.GetZombieType();
			AddHint(pEnt, "icon_alert_red", zombieType[type-1] + "!", 1, Config.ping.duration, HINTMODE.SPECIAL, player);
		}
		else if (::LinGe.GetPlayerTeam(pEnt) == 2)
		{
			if (Config.help.duration <= 0 || CheckSurvivor(pEnt, player))
			{
				// 如果不允许玩家状态标记，或者队友是健康的，则单独给发出标记的玩家提示血量
				AddHint(pEnt, LINGE_NONE_ICON, "当前血量:" + ceil(pEnt.GetHealth() + pEnt.GetHealthBuffer()), -1,
					2.0, HINTMODE.SELFSHOW, player);
			}
		}
		break;
	case "witch":
		AddHint(pEnt, "icon_alert_red", "当心Witch!", 1, Config.ping.duration, HINTMODE.SPECIAL, player);
		break;
// case "infected": // 小僵尸
// 		break;
	// case "prop_dynamic":
	// 	ShowRunHint(vecPingPos, player);
	// 	break;
	case "prop_health_cabinet": // 医疗箱
		if ( NetProps.GetPropInt( pEnt, "m_isUsed" ) == 1 )
		{
			// 如果医疗箱已经打开了则追踪里面的物体
			local tr = {
				start = vecPingPos,
				end = vecPingPos + player.EyeAngles().Forward().Scale( MAX_COORD_FLOAT ),
				ignore = pEnt,
				mask = MASK_SHOT_HULL & (~CONTENTS_WINDOW),
			};
			TraceLine(tr);

			if ( tr.enthit.GetEntityIndex() != 0 )
			{
				PingEntity( player, tr.enthit, tr.pos);
				return;
			}
		}
		AddHint(pEnt, "icon_interact", "医疗箱", 0,
			Config.ping.duration, HINTMODE.WEAPON, player);
		if (Config.ping.weaponMessage)
			ClientPrint(null, 3, "\x05" + player.GetPlayerName() + " \x04标记了 \x03医疗箱");
		break;
	case "prop_car_alarm":
		if (!NetProps.GetPropInt( pEnt, "m_bDisabled" ) )
			AddHint(pEnt, "icon_alert_red", "注意警报!", 0, Config.ping.duration, HINTMODE.SIGHT, player);
		else
			AddHint(pEnt, "icon_tip", "警报不会触发", -1, 2, HINTMODE.SELFSHOW, player);
		break;
	case "prop_door_rotating":
		AddHint(pEnt, "icon_door", "走这里吧", 0, Config.ping.duration, HINTMODE.RUN, player);
		break;
	case "prop_door_rotating_checkpoint":
		AddHint(pEnt, "icon_door", "安全屋", 0, Config.ping.duration, HINTMODE.RUN, player);
		break;
	// case "prop_fuel_barrel":
	// 	break;
	case "upgrade_ammo_explosive":
		AddHint(pEnt, "icon_explosive_ammo", "高爆弹药", 0, Config.ping.duration, HINTMODE.WEAPON, player);
		if (Config.ping.weaponMessage)
			ClientPrint(null, 3, "\x05" + player.GetPlayerName() + " \x04标记了 \x03高爆弹药");
		break;
	case "upgrade_ammo_incendiary":
		AddHint(pEnt, "icon_incendiary_ammo", "燃烧弹药", 0, Config.ping.duration, HINTMODE.WEAPON, player);
		if (Config.ping.weaponMessage)
			ClientPrint(null, 3, "\x05" + player.GetPlayerName() + " \x04标记了 \x03燃烧弹药");
		break;
	case "upgrade_laser_sight":
		AddHint(pEnt, "icon_laser_sight", "激光瞄准", 0, Config.ping.duration, HINTMODE.WEAPON, player);
		if (Config.ping.weaponMessage)
			ClientPrint(null, 3, "\x05" + player.GetPlayerName() + " \x04标记了 \x03激光瞄准");
		break;
	case "prop_physics":
		local model = pEnt.GetModelName();
		if (weaponModel.rawin(model))
		{
			local icon = weaponIcon[weaponModel[model]], text = weaponName[weaponModel[model]];
			AddHint(pEnt, icon, text, 0, Config.ping.duration, HINTMODE.WEAPON, player);
			if (Config.ping.weaponMessage)
				ClientPrint(null, 3, "\x05" + player.GetPlayerName() + " \x04标记了 \x03" + text);
		}
		else
			ShowRunHint(vecPingPos, player);
		break;
	// case "worldspawn":
	// 	break;
	default:
		if (szClassname.find("weapon") == 0 )
		{
			local model = pEnt.GetModelName();
			local icon = null, text = null;
			if (weaponModel.rawin(model))
			{
				icon = weaponIcon[weaponModel[model]];
				text = weaponName[weaponModel[model]];
			}
			else if (weaponEntity.rawin(szClassname))
			{
				icon = weaponIcon[weaponEntity[szClassname]];
				text = weaponName[weaponEntity[szClassname]];
			}
			else if (weaponSpawn.rawin(szClassname))
			{
				icon = weaponIcon[weaponSpawn[szClassname]];
				text = weaponName[weaponSpawn[szClassname]];
			}
			AddHint(pEnt, icon, text, 0, Config.ping.duration, HINTMODE.WEAPON, player);
			if (Config.ping.weaponMessage)
				ClientPrint(null, 3, "\x05" + player.GetPlayerName() + " \x04标记了 \x03" + text);
		}
		else
		{
			// 有些实体模型比较小，准星没对准很容易标记不到
			local weapon = null;
			while ( weapon = Entities.FindByClassnameWithin(weapon, "weapon_*", vecPingPos, 15.0) )
			{
				if ( weapon.IsValid() && weapon.GetMoveParent() == null) // 查找到的实体必须是有效且无主的
				{
					PingEntity(player, weapon, weapon.GetLocalOrigin());
					return;
				}
			}
			// 如果查找不到就标记普通路径点
			if (Config.ping.emptySpace)
				ShowRunHint(vecPingPos, player);
		}
		break;
	}
}

// 通用路径标记
local infoTargetEnt = null;
::LinGe.Hint.ShowRunHint <- function (pos, activator)
{
	if (null == infoTargetEnt)
	{
		infoTargetEnt = SpawnEntityFromTable("info_target_instructor_hint",
			{ targetname = "LinGe_Hint_infoTarget" } );
	}
	if (null == infoTargetEnt)
	{
		printl("[LinGe] 无法创建 info_target_instructor_hint");
		return false;
	}

	infoTargetEnt.SetLocalOrigin(pos);
	AddHint(infoTargetEnt, "icon_run", "这里!", -1, Config.ping.duration, HINTMODE.RUN, activator);
	return true;
}


// 按键监测
local ButtonScanFunc = function ()
{
	if (!("LinGe" in getroottable()))
		return;

	foreach (key, val in buttonState)
	{
		local player = PlayerInstanceFromIndex(key);
		if (!::LinGe.IsAlive(player))
			continue;
		// 判断绑定的按键是否松开
		local curPressed = player.GetButtonMask();
		if ((curPressed & BUTTON_ALT1) != (val & BUTTON_ALT1))
		{
			if (!(curPressed & BUTTON_ALT1)) // 松开触发
				::LinGe.Hint.PlayerPing(player);
		}
		buttonState[key] = curPressed;
	}
}
// 启用按键监控
if (!::LinGe.Hint.rawin("_buttonScaner") && ::LinGe.Hint.Config.ping.duration > 0)
{
	::LinGe.Hint._buttonScaner <- SpawnEntityFromTable("info_target", { targetname = "LinGe_Hint_buttonScan" });
	if (::LinGe.Hint._buttonScaner != null)
	{
		::LinGe.Hint._buttonScaner.ValidateScriptScope();
		local scrScope = ::LinGe.Hint._buttonScaner.GetScriptScope();
		scrScope.buttonState <- buttonState;
		scrScope.ButtonScanFunc <- ButtonScanFunc;
		AddThinkToEnt(::LinGe.Hint._buttonScaner, "ButtonScanFunc");
		// printl("[LinGe] 按键监视器已创建");
	}
	else
		throw "无法创建按键监视器";
}

} // if (::LinGe.Hint.Config.limit > 0) {

} // if ( !::LinGe.isVersus ) {