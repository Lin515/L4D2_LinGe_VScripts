// https://developer.valvesoftware.com/wiki/Env_instructor_hint:zh-cn

// 只在非对抗模式下加载此功能
if (!::LinGe.isVersus) {

printl("[LinGe] Hint 正在载入");
::LinGe.Hint <- {};

::LinGe.Hint.Config <- {
	limit = 4, // 队友状态与普通标记提示的总数量上限，若设置为<=0则彻底关闭提示系统
	offscreenShow = true, // 提示在画面之外是否也要显示
	friend = { // 队友需要帮助时出现提示 包括 倒地、挂边、黑白、被控
		duration = 15, // 提示持续时间，若<=0则彻底关闭所有队友需要帮助的提示
		dominateDelay = 0, // 被控延迟，玩家被控多少秒后才会出现提示，若设置为0则无延迟立即显示
						// 若<0，则不会自动提示玩家被控，但是玩家可以用按键自己发出呼救
	},
	pingDuration = 10, // 玩家用按键发出信号的持续时间，若<=0则禁止玩家发出信号
	deadHint = true, // 死亡时不会出现标记提示，不过会在聊天窗输出提示 若设置为 false 则关闭该提示
					// 该提示对BOT不生效
	deadChat = "再见了大家，我会想念你们的", // 若这里设置为 "" 或者 null 则以服务器式提示输出
};
::LinGe.Config.Add("Hint", ::LinGe.Hint.Config);
// ::LinGe.Cache.Hint_Config <- ::LinGe.Hint.Config;

// 生还者玩家死亡时输出提示
::LinGe.Hint.OnGameEvent_player_death <- function (params)
{
	if (!params.rawin("userid"))
		return;

    local dier = params.userid;	// 死者ID
    local dierEntity = GetPlayerFromUserID(dier);
	if (dierEntity && dierEntity.IsSurvivor())
	{
		if (this.rawin("EndHint"))
			EndHint(dierEntity);
		// 自杀时伤害类型为0
		if (params.type == 0)
			return;
		if (Config.deadHint && (!IsPlayerABot(dierEntity)||::LinGe.Debug))
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

// 当前提示列表 包含三个键
// key=level 信息提示等级，等级越高越重要
// key=ent value为env_instructor_hint实体
// key=targetname` value为目标实体名
local CurrentHint = [];
getconsttable()["HELP_ICON"] <- "icon_shield";

// 事件：玩家倒地
::LinGe.Hint.OnGameEvent_player_incapacitated <- function (params)
{
	if (!params.rawin("userid") || params.userid == 0)
		return;

	local player = GetPlayerFromUserID(params.userid);
	if (player.IsSurvivor())
	{
		EndHint(player);
		VSLib.Timers.AddTimerByName(params.userid, 0.1, false, ShowPlayerIncap, player);
	}
}
if (::LinGe.Hint.Config.friend.duration > 0)
	::LinEventHook("OnGameEvent_player_incapacitated", ::LinGe.Hint.OnGameEvent_player_incapacitated, ::LinGe.Hint);
::LinGe.Hint.ShowPlayerIncap <- function (player)
{
	if (player.IsIncapacitated())
	{
		// 倒地状态提示
		local showTo = clone ::pyinfo.survivorIdx;
		if (::LinGe.RemoveInArray(player.GetEntityIndex(), showTo) != null)
		{
			ShowHint(player.GetPlayerName() + "倒地了", 1, player,
				showTo, Config.friend.duration, HELP_ICON);
		}
	}
}.bindenv(::LinGe.Hint);

// 玩家挂边
::LinGe.Hint.OnGameEvent_player_ledge_grab <- function (params)
{
	if (!params.rawin("userid"))
		return;
	local player = GetPlayerFromUserID(params.userid);
	ShowPlayerLedge(player);
}
if (::LinGe.Hint.Config.friend.duration > 0)
	::LinEventHook("OnGameEvent_player_ledge_grab", ::LinGe.Hint.OnGameEvent_player_ledge_grab, ::LinGe.Hint);
::LinGe.Hint.ShowPlayerLedge <- function (player)
{
	local showTo = clone ::pyinfo.survivorIdx;
	if (::LinGe.RemoveInArray(player.GetEntityIndex(), showTo) != null)
	{
		ShowHint("帮助" + player.GetPlayerName(), 2, player,
			showTo, Config.friend.duration, HELP_ICON);
	}
}

// 成功救助队友 （倒地拉起、挂边拉起、治疗都会触发该事件）
::LinGe.Hint.OnGameEvent_revive_success <- function (params)
{
	if (!params.rawin("subject"))
		return;
	local player = GetPlayerFromUserID(params.subject);
	if (!player.IsSurvivor())
		return;
	EndHint(player); // 去除其身上的标志

	if (::LinGe.GetReviveCount(player) >= 2)
		ShowPlayerDying(player);
}
if (::LinGe.Hint.Config.friend.duration > 0)
	::LinEventHook("OnGameEvent_revive_success", ::LinGe.Hint.OnGameEvent_revive_success, ::LinGe.Hint);
::LinGe.Hint.ShowPlayerDying <- function (player)
{
	// 黑白状态提示
	local showTo = ::pyinfo.survivorIdx;
	if (::LinGe.RemoveInArray(player.GetEntityIndex(), showTo) != null)
	{
		ShowHint(player.GetPlayerName() + "濒死", 1, player,
			showTo, Config.friend.duration, HELP_ICON);
	}
}

// 玩家被控
::LinGe.Hint.PlayerBeDominating <- function (params)
{
	if (!params.rawin("victim"))
		return;
	local player = GetPlayerFromUserID(params.victim);
	if (Config.friend.dominateDelay > 0)
		::VSLib.Timers.AddTimerByName(::LinGe.GetEntityTargetname(player),
			Config.friend.dominateDelay, false, ShowPlayerBeDominating, player);
	else
		ShowPlayerBeDominating(player);
}
::LinGe.Hint.ShowPlayerBeDominating <- function (player)
{
	local showTo = clone ::pyinfo.survivorIdx;
	if (::LinGe.RemoveInArray(player.GetEntityIndex(), showTo) != null)
	{
		ShowHint(player.GetPlayerName() + "被控了", 3, player,
			showTo, Config.friend.duration, HELP_ICON);
	}
}

// 被控解除
::LinGe.Hint.PlayerDominateEnd <- function (params)
{
	if (!params.rawin("victim"))
		return;
	local player = GetPlayerFromUserID(params.victim);
	EndHint(player);
}

if (::LinGe.Hint.Config.friend.duration > 0 && ::LinGe.Hint.Config.friend.dominateDelay >= 0)
{
	::LinEventHook("OnGameEvent_lunge_pounce", ::LinGe.Hint.PlayerBeDominating, ::LinGe.Hint); // Hunter
	::LinEventHook("OnGameEvent_tongue_grab", ::LinGe.Hint.PlayerBeDominating, ::LinGe.Hint); // Smoker
	::LinEventHook("OnGameEvent_charger_pummel_start", ::LinGe.Hint.PlayerBeDominating, ::LinGe.Hint); // Charger
	::LinEventHook("OnGameEvent_jockey_ride", ::LinGe.Hint.PlayerBeDominating, ::LinGe.Hint); // Jockey

	::LinEventHook("OnGameEvent_pounce_stopped", ::LinGe.Hint.PlayerDominateEnd, ::LinGe.Hint);
	::LinEventHook("OnGameEvent_tongue_release", ::LinGe.Hint.PlayerDominateEnd, ::LinGe.Hint);
	::LinEventHook("OnGameEvent_charger_pummel_end", ::LinGe.Hint.PlayerDominateEnd, ::LinGe.Hint);
	::LinEventHook("OnGameEvent_jockey_ride_end", ::LinGe.Hint.PlayerDominateEnd, ::LinGe.Hint);
}

// 按键监控
::LinGe.Hint.buttonState <- {};
::LinGe.Hint.OnGameEvent_round_start <- function (params)
{
	foreach (val in ::pyinfo.survivorIdx)
	{
		local player = PlayerInstanceFromIndex(val);
		if (player.GetNetworkIDString() != "BOT")
			buttonState.rawset(val, 0);
	}
}
::LinEventHook("OnGameEvent_round_start", ::LinGe.Hint.OnGameEvent_round_start, ::LinGe.Hint);

// 玩家队伍变更，当某生还者出现队伍变更时，重置其身上的提示状态
::LinGe.Hint.OnGameEvent_player_team <- function (params)
{
	if (!params.rawin("userid"))
		return;
	local player = GetPlayerFromUserID(params.userid);

	// 如果是离开生还者队伍，则移除其身上当前的提示
	if (2 == params.oldteam)
	{
		EndHint(player);
		if (player.GetNetworkIDString() != "BOT")
			buttonState.rawdelete(player.GetEntityIndex());
	}
	else if (2 == params.team)
	{
		if (player.GetNetworkIDString() != "BOT")
			buttonState.rawset(player.GetEntityIndex(), 0);
	}
}
::LinEventHook("OnGameEvent_player_team", ::LinGe.Hint.OnGameEvent_player_team, ::LinGe.Hint);

// BOT与玩家的交换，将状态进行转移
// BOT取代玩家
::LinGe.Hint.OnGameEvent_player_bot_replace <- function (params)
{
	local bot = GetPlayerFromUserID(params.bot);
	local player = GetPlayerFromUserID(params.player);
	if (::LinGe.GetPlayerTeam(bot) == 2 && FindHintIndex(player)!=null)
	{
		::VSLib.Timers.AddTimerByName(::LinGe.GetEntityTargetname(bot),
			0.1, false, Timer_CheckPlayer, bot);
	}
}
::LinEventHook("OnGameEvent_player_bot_replace", ::LinGe.Hint.OnGameEvent_player_bot_replace, ::LinGe.Hint);

// 玩家取代BOT
::LinGe.Hint.OnGameEvent_bot_player_replace <- function (params)
{
	local bot = GetPlayerFromUserID(params.bot);
	local player = GetPlayerFromUserID(params.player);
	if (::LinGe.GetPlayerTeam(player) == 2 && FindHintIndex(bot)!=null)
	{
		::VSLib.Timers.AddTimerByName(::LinGe.GetEntityTargetname(player),
			0.1, false, Timer_CheckPlayer, player);
	}
}
::LinEventHook("OnGameEvent_bot_player_replace", ::LinGe.Hint.OnGameEvent_bot_player_replace, ::LinGe.Hint);

::LinGe.Hint.Timer_CheckPlayer <- function (player)
{
	if (!::LinGe.IsAlive(player))
		return;
	else if (player.IsIncapacitated())
		ShowPlayerIncap(player);
	else if (player.IsHangingFromLedge())
		ShowPlayerLedge(player);
	else if (player.GetSpecialInfectedDominatingMe())
		ShowPlayerBeDominating(player);
	else if (::LinGe.GetReviveCount(player) >= 2)
		ShowPlayerDying(player);
}.bindenv(::LinGe.Hint);

::LinGe.Hint.ShowHint <- function ( text, level=0, target = "", showTo = null,
	duration = 0.0, icon = "icon_tip", color = "255 255 255")
{
	if (typeof target == "instance")
		target = ::LinGe.GetEntityTargetname(target);
	EndHint(target); // 不允许同一目标上存在两个提示
	if (!AtLeastOne(level))
		return false;

	local hinttbl =
	{
		classname = "env_instructor_hint",
		hint_allow_nodraw_target = "1",
		hint_auto_start = "0",
		hint_binding = "",
		hint_caption = text.tostring(),
		hint_color = color,
		hint_forcecaption = "1",
		hint_icon_offscreen = icon,
		hint_icon_offset = "0",
		hint_icon_onscreen = icon,
		hint_instance_type = "0",
		hint_nooffscreen = Config.offscreenShow ? "0" : "1",
		hint_alphaoption = level>2 ? 1 : 0, // alphapulse 图标会变透明和可见的速度 0~3
		hint_pulseoption = level>2 ? 1 : 0, // 图标效果，图标收缩的速度 0~3
		hint_shakeoption = 0,	// shaking 图标会抖动 0~2
		hint_range = "0",
		hint_static = "0", // 跟随实体目标
		hint_target = target,
		hint_timeout = 0.0, // 持续时间，若为0则需要通过EndHint来关闭
							// 不设置其为 duration 提示的关闭统一由本脚本用EndHint来控制
		origin = Vector(0, 0, 0),
		angles = QAngle(0, 0, 0),
		targetname = "LinGe_" + UniqueString(),
	};

	local ent = g_ModeScript.CreateSingleSimpleEntityFromTable(hinttbl);
	if (!ent)
	{
		printl("[LinGe] 创建 env_instructor_hint 实体失败");
		return;
	}
	ent.ValidateScriptScope();

	if (null == showTo || showTo.len() == 0)
	{
		DoEntFire("!self", "ShowHint", "", 0, null, ent);
	}
	else
	{
		foreach (val in showTo)
		{
			DoEntFire("!self", "ShowHint", "", 0, PlayerInstanceFromIndex(val), ent);
			::LinGe.DebugPrintl("显示给 " + PlayerInstanceFromIndex(val).GetPlayerName());
		}
	}
	CurrentHint.push({ level=level, ent=ent, targetname=target });

	if (duration > 0.0 && !::LinGe.Debug)
	{
		::VSLib.Timers.AddTimerByName("EndHint_" + target,
			duration, false, EndHint, target);
	}
	return true;
}

::LinGe.Hint.FindHintIndex <- function (params)
{
	local index = null;
	if (typeof params == "instance")
		params = params.GetName();

	if (typeof params == "integer")
	{
		index = params;
		if (index < 0 || index >= CurrentHint.len())
			throw "索引越界";
	}
	else if (typeof params == "string")
	{
		if (params == "")
			return null;
		foreach (idx, val in CurrentHint)
		{
			if (val.targetname == params)
			{
				index = idx;
				break;
			}
		}
		return index;
	}
	else
		throw "不能识别的参数类型";
	return index;
}

// EndHint 去除提示
::LinGe.Hint.EndHint <- function (params)
{
	local idx = FindHintIndex(params);
	if (null == idx)
		return;
	local hint = CurrentHint[idx];
	::VSLib.Timers.RemoveTimerByName("EndHint_" + hint.targetname);
	// DoEntFire("!self", "EndHint", "", 0, null, hint.ent);
	DoEntFire("!self", "Kill", "", 0, null, hint.ent);
	CurrentHint.remove(idx);
}.bindenv(::LinGe.Hint);

// 清理一个空位出来 若空位不足，则返回 false
::LinGe.Hint.AtLeastOne <- function (level)
{
	// 如果已经没有空位，则尝试清理一个出来
	if (CurrentHint.len() >= Config.limit)
	{
		// 清理掉一个满足 <= level 的最低等级提示
		local minLevel = level + 1;
		local i = null;
		foreach (idx, val in CurrentHint)
		{
			if (val.level < minLevel)
			{
				minLevel = val.level;
				i = idx;
			}
		}
		if (i)
		{
			EndHint(i);
			return true;
		}
		else
			return false;
	}
	return true;
}

// 实现玩家使用按键发出信号
// 以下用了很多 @samisalreadytaken 的 Contextual Ping System 标记系统 MOD 里的代码
// https://steamcommunity.com/linkfilter/?url=http://github.com/samisalreadytaken
// https://github.com/samisalreadytaken/vscripts/blob/master/left4dead2/ping_system.nut
const IN_ALT2 = 0x8000;
const MAX_TRACE_LENGTH	= 56755.840862417;

local s_tr =
{
	start = null,
	end = null,
	mask = MASK_SHOT_HULL & (~CONTENTS_WINDOW),
	ignore = null,
	pos = null,
	hit = null,
	enthit = null,
	startsolid = null
}

local WeaponName = {
	weapon_first_aid_kit		= "医疗包",
	weapon_pain_pills			= "止疼药",
	weapon_adrenaline			= "肾上腺素",
	weapon_defibrillator		= "电击器",

	weapon_upgradepack_explosive	= "爆炸弹药",
	weapon_upgradepack_incendiary	= "燃烧弹药",

	weapon_pipe_bomb			= "土制炸弹",
	weapon_molotov				= "燃烧瓶",
	weapon_vomitjar				= "胆汁",

	weapon_oxygentank			= "氧气管",
	weapon_propanetank			= "煤气罐",
	weapon_fireworkcrate		= "烟花",
	weapon_gnome				= "侏儒",
	weapon_cola_bottles			= "可乐",
	weapon_gascan				= "汽油桶",

	weapon_ammo					= "弹药",
	weapon_autoshotgun			= "自动霰弹枪",
	weapon_chainsaw				= "电锯",
	weapon_grenade_launcher		= "榴弹",
	weapon_hunting_rifle		= "猎枪",
	weapon_pistol				= "手枪",
	weapon_pistol_magnum		= "马格南",
	weapon_pumpshotgun			= "霰弹枪",
	weapon_rifle				= "M16步枪",
	weapon_rifle_ak47			= "AK47步枪",
	weapon_rifle_desert			= "SCAR步枪",
	weapon_rifle_m60			= "M60机枪",
	weapon_rifle_sg552			= "SG552步枪",
	weapon_shotgun_chrome		= "霰弹枪",
	weapon_shotgun_spas			= "自动霰弹枪",
	weapon_smg					= "SMG冲锋枪",
	weapon_smg_mp5				= "MP5冲锋枪",
	weapon_smg_silenced			= "MAC冲锋枪",
	weapon_sniper_awp			= "AWP狙击枪",
	weapon_sniper_military		= "连发狙击枪",
	weapon_sniper_scout			= "SCOUT狙击枪",

	weapon_melee				= "近战武器"
}
local WeaponSpawn = {};
foreach ( k, v in WeaponName )
	WeaponSpawn[ k + "_spawn" ] <- v;

::LinGe.Hint.ButtonScanFunc <- function ()
{
	if (!("LinGe" in getroottable()))
		return;

	foreach (key, val in buttonState)
	{
		local player = PlayerInstanceFromIndex(key);
		if (!::LinGe.IsAlive(player))
			continue;
		// 判断绑定的按键是否松开
		local curPressed = player.GetButtonMask() & IN_ALT2;
		if ( curPressed != val)
		{
			buttonState[key] = curPressed;
			if (!curPressed) // 按下触发
				::LinGe.Hint.PlayerPing(player);
		};
	}
}

// 玩家使用按键发出信号
::LinGe.Hint.PlayerPing <- function (player)
{
	// 如果玩家处于不可控制的虚弱状态，则发出求救信号
	if (player.IsIncapacitated())
		ShowPlayerIncap(player);
	else if (player.IsHangingFromLedge())
		ShowPlayerLedge(player);
	else if (player.GetSpecialInfectedDominatingMe())
		ShowPlayerBeDominating(player);
	else
		PingTrace(player);
}

// 通过玩家视野进行光线追踪查找实体
::LinGe.Hint.PingTrace <- function (player, tr = s_tr )
{
	local eyePos = player.EyePosition();
	tr.start = eyePos;
	tr.end = eyePos + player.EyeAngles().Forward().Scale( MAX_TRACE_LENGTH );
	tr.ignore = player;

	TraceLine( tr );

	return PingEntity(player, tr.enthit);
}

// 标记到实体
::LinGe.Hint.PingEntity <- function (player, pEnt)
{
	local szClassname = pEnt.GetClassname();
	printl(szClassname);

	switch ( szClassname )
	{
		case "worldspawn":
			break;
		case "player":
			break;
		case "witch":
			ShowHint("小心Witch!", 1, pEnt, null, Config.pingDuration, "tip_witch");
			break;
		case "infected":
			break;
		case "prop_physics":
			break;
		case "prop_health_cabinet":
			break;
		case "prop_car_alarm":
			if (!GetNetPropInt( pEnt, "m_bDisabled" ) )
				ShowHint("注意警报!", 0, pEnt, null, Config.pingDuration, "icon_alert_red");
			break;
		case "prop_door_rotating":
			break;
		case "prop_door_rotating_checkpoint":
			break;
		case "prop_fuel_barrel":
			break;
		case "upgrade_ammo_explosive":
			ShowHint("爆炸弹药", 0, pEnt, null, Config.pingDuration, "icon_interact");
			break;
		case "upgrade_ammo_incendiary":
			ShowHint("燃烧弹药", 0, pEnt, null, Config.pingDuration, "icon_interact");
			break;
		case "upgrade_laser_sight":
			ShowHint("激光瞄准", 0, pEnt, null, Config.pingDuration, "icon_interact");
			break;
		// Partial matches and undefined entities
		default:
			// All weapons go through here
			if (szClassname.find("weapon") == 0 )
			{
				if (WeaponName.rawin(szClassname))
					ShowHint(WeaponName[szClassname], 0, pEnt, null, Config.pingDuration, "icon_interact");
				else if (WeaponSpawn.rawin(szClassname))
					ShowHint(WeaponSpawn[szClassname], 0, pEnt, null, Config.pingDuration, "icon_interact");
			}
			break;
	}
}

// 启用按键监控
if (!("_buttonScaner" in ::LinGe.Hint) && ::LinGe.Hint.Config.pingDuration > 0)
{
	::LinGe.Hint._buttonScaner <- SpawnEntityFromTable("info_target", { targetname = "LinGe_Hint_buttonScan" });
	if (::LinGe.Hint._buttonScaner != null)
	{
		::LinGe.Hint._buttonScaner.ValidateScriptScope();
		local scrScope = ::LinGe.Hint._buttonScaner.GetScriptScope();
		scrScope.buttonState <- ::LinGe.Hint.buttonState;
		scrScope["ButtonScanFunc"] <- ::LinGe.Hint.ButtonScanFunc;
		AddThinkToEnt(::LinGe.Hint._buttonScaner, "ButtonScanFunc");
	}
	else
		throw "无法创建按键监视器";
}

} // if (::LinGe.Hint.Config.limit > 0) {

} // if ( !::LinGe.isVersus ) {