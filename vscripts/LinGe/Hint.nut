// https://developer.valvesoftware.com/wiki/Env_instructor_hint:zh-cn

// 只在非对抗模式下加载此功能
if (!::LinGe.isVersus) {

printl("[LinGe] Hint 正在载入");
::LinGe.Hint <- {};

::LinGe.Hint.Config <- {
	limit = 4, // 队友状态与普通标记提示的显示数量上限，若设置为<=0则彻底关闭
	friend = { // 队友需要帮助时出现提示 包括 倒地、挂边、黑白、被控
		duration = 15, // 提示持续时间，若<=0则彻底关闭所有队友需要帮助的提示
		dominatedDelay = 0, // 队友被特感控时（不包括倒地和挂边），出现提示的延迟时间，0即立即显示，<0则关闭被控时的提示
	},
	normal = {

	},
	deadHint = true, // 死亡时不会出现标记提示，不过会在聊天窗输出提示 若设置为 false 则关闭该提示
					// 该提示对BOT不生效
	deadChat = "再见了大家，我会想念你们的", // 若这里设置为 "" 或者 null 则以服务器式提示输出
};
::LinGe.Config.Add("Hint", ::LinGe.Hint.Config);
::LinGe.Cache.Hint_Config <- ::LinGe.Hint.Config;

// 生还者玩家死亡时输出提示
if (::LinGe.Hint.Config.deadHint) {
::LinGe.Hint.OnGameEvent_player_death <- function (params)
{
	if (!params.rawin("userid"))
		return;

    local dier = params.userid;	// 死者ID
    local dierEntity = GetPlayerFromUserID(dier);
	if (dierEntity && dierEntity.IsSurvivor())
	{
		// 自杀时伤害类型为0
		if (params.type == 0)
			return;
		if (Config.deadHint && (!IsPlayerABot(dierEntity)||::LinGe.Debug))
			VSLib.Timers.AddTimerByName(dier, 0.1, false, Timer_CheckPlayerDead, dierEntity);
	}
}
::LinEventHook("OnGameEvent_player_death", ::LinGe.Hint.OnGameEvent_player_death, ::LinGe.Hint);

::LinGe.Hint.Timer_CheckPlayerDead <- function (player)
{
	if (!::LinGe.IsAlive(player))
	{
		if (null == Config.deadChat || "" == Config.deadChat)
			ClientPrint(null, 3, "\x03" + player.GetPlayerName() + "\x04 牺牲了");
		else
			Say(player, "\x03" + Config.deadChat, false);
	}
}.bindenv(::LinGe.Hint);
} // if (::LinGe.Hint.Config.deadHint) {

// 数量限制不大于0时不加载标记提示功能
if (::LinGe.Hint.Config.limit > 0) {

// 当前提示列表 包含三个键
// key=level 信息提示等级，等级越高越重要
// key=ent value为env_instructor_hint实体
// key=targetname value为目标实体名
local CurrentHint = [];
getconsttable()["HELP_ICON"] <- "icon_shield";

if (::LinGe.Hint.Config.friend.duration > 0) {
// 事件：玩家倒地
::LinGe.Hint.OnGameEvent_player_incapacitated <- function (params)
{
	if (!params.rawin("userid") || params.userid == 0)
		return;

	local player = GetPlayerFromUserID(params.userid);
	if (player.IsSurvivor())
	{
		VSLib.Timers.AddTimerByName(params.userid, 0.1, false, Timer_CheckPlayerIncap, player);
	}
}
::LinEventHook("OnGameEvent_player_incapacitated", ::LinGe.Hint.OnGameEvent_player_incapacitated, ::LinGe.Hint);

::LinGe.Hint.Timer_CheckPlayerIncap <- function (player)
{
	if (player.IsIncapacitated())
	{
		// 倒地状态提示
		local activators = clone ::pyinfo.survivorIdx;
		if (::LinGe.RemoveInArray(player.GetEntityIndex(), activators))
		{
			ShowHint("帮助" + player.GetPlayerName(), 2, ::LinGe.GetEntityTargetname(player),
			 activators, Config.friend.duration, HELP_ICON);
		}
	}
}.bindenv(::LinGe.Hint);

::LinGe.Hint.OnGameEvent_player_ledge_grab <- function (params)
{
	if (!params.rawin("userid"))
		return;
	local player = GetPlayerFromUserID(params.userid);
	if (player.IsHangingFromLedge())
	{
		// 挂边状态提示
		local activators = clone ::pyinfo.survivorIdx;
		if (::LinGe.RemoveInArray(player.GetEntityIndex(), activators))
		{
			ShowHint("帮助" + player.GetPlayerName(), 2, ::LinGe.GetEntityTargetname(player),
			 activators, Config.friend.duration, HELP_ICON);
		}
	}
}
::LinEventHook("OnGameEvent_player_ledge_grab", ::LinGe.Hint.OnGameEvent_player_ledge_grab, ::LinGe.Hint);

// 成功拉起队友
::LinGe.Hint.OnGameEvent_revive_success <- function (params)
{
	if (!params.rawin("subject"))
		return;
	local player = GetPlayerFromUserID(params.subject);
	if (!player.IsSurvivor())
		return;
	EndHint(::LinGe.GetEntityTargetname(player)); // 去除其身上的标志

	if (::LinGe.GetReviveCount(player) >= 2)
	{
		// 黑白状态提示
		local activators = clone ::pyinfo.survivorIdx;
		if (::LinGe.RemoveInArray(player.GetEntityIndex(), activators))
		{
			ShowHint("治疗" + player.GetPlayerName(), 1, ::LinGe.GetEntityTargetname(player),
			 activators, Config.friend.duration, HELP_ICON);
		}
	}
}
::LinEventHook("OnGameEvent_revive_success", ::LinGe.Hint.OnGameEvent_revive_success, ::LinGe.Hint);

} // if (::LinGe.Hint.Config.friend.duration > 0)

::LinGe.Hint.ShowHint <- function ( text, level=0, target = "", activators = null,
	duration = 0.0, icon = "icon_tip", color = "255 255 255")
{
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
		hint_nooffscreen = "0",
		hint_alphaoption = level>2 ? 1 : 0, // alphapulse 图标会变透明和可见的速度 0~3
		hint_pulseoption = level>2 ? 1 : 0, // 图标效果，图标收缩的速度 0~3
		hint_shakeoption = 0,	// shaking 图标会抖动 0~2
		hint_range = "0",
		hint_static = "0", // 跟随实体目标
		hint_target = target,
		hint_timeout = duration.tofloat(), // 持续时间，若为0则需要通过EndHint来关闭
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

	if (null == activators || activators.len() == 0)
	{
		DoEntFire("!self", "ShowHint", "", 0, null, ent);
	}
	else
	{
		foreach (val in activators)
			DoEntFire("!self", "ShowHint", "", 0, PlayerInstanceFromIndex(val), ent);
	}
	CurrentHint.push({ level=level, ent=ent, targetname=target });

	if (hinttbl.hint_timeout > 0.0)
	{
		::VSLib.Timers.AddTimerByName("EndHint_" + hinttbl.targetname,
			hinttbl.hint_timeout, false, Timer_EndHint, CurrentHint.len()-1);
	}
	return true;
}

// EndHint 去除提示
::LinGe.Hint.EndHint <- function (params)
{
	local hintIdx = null;
	if (typeof params == "integer")
	{
		hintIdx = params;
		if (hintIdx < 0 || hintIdx >= CurrentHint.len())
			throw "hintIdx 越界";
	}
	else if (typeof params == "string")
	{
		foreach (idx, val in CurrentHint)
		{
			if (val.targetname == params)
			{
				hintIdx = idx;
				break;
			}
		}
		if (null == hintIdx)
			return;
	}
	else
		throw "不能识别的参数类型";
	local hint = CurrentHint[hintIdx];
	::VSLib.Timers.RemoveTimerByName("EndHint_" + hint.ent.GetName());
	// DoEntFire("!self", "EndHint", "", 0, null, hint.ent);
	DoEntFire("!self", "Kill", "", 0, null, hint.ent);
	CurrentHint.remove(hintIdx);
}

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

} // if (::LinGe.Hint.Config.limit > 0) {

} // if ( !::LinGe.isVersus ) {