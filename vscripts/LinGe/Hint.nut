// https://developer.valvesoftware.com/wiki/Env_instructor_hint:zh-cn
// 该功能必须开启 游戏菜单-选项-多人联机-游戏提示
// 只在非对抗模式下加载此功能
if (!::LinGe.isVersus) {

printl("[LinGe] 标记提示 正在载入");
::LinGe.Hint <- {};

::LinGe.Hint.Config <- {
	limit = 4, // 队友状态与普通标记提示的总数量上限，若设置为<=0则彻底关闭提示系统
	offscreenShow = true, // 提示在画面之外是否也要显示
	help = { // 队友需要帮助时出现提示 包括 倒地、挂边、黑白、被控
		duration = 15, // 提示持续时间，若<=0则彻底关闭所有队友需要帮助的提示
		dominateDelay = 0, // 被控延迟，玩家被控多少秒后才会出现提示，若设置为0则无延迟立即显示
						// 若<0，则不会自动提示玩家被控，但是玩家可以用按键自己发出呼救
	},
	ping = {
		duration = 8, // 玩家用按键发出信号的持续时间，若<=0则禁止玩家发出信号
		emptySpace = true, // 可以标记到什么都没有的位置
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

// 这是调试代码
// ::LinGe.Hint.Timer_CheckSee <- function (params)
// {
// 	local player = PlayerInstanceFromIndex(1);
// 	if (player && player.IsValid())
// 	{
// 		foreach (val in ::pyinfo.survivorIdx)
// 		{
// 			local bot = PlayerInstanceFromIndex(val);
// 			if (bot.GetEntityIndex() != 1)
// 			{
// 				ClientPrint(null, 3, bot.GetPlayerName() + " : "
// 					+ (player.GetOrigin() - bot.GetOrigin()).Length());
// 			}
// 		}
// 	}
// }
// ::VSLib.Timers.AddTimerByName("Timer_CheckSee", 0.1, true, ::LinGe.Hint.Timer_CheckSee);

// 特感或玩家死亡后消除其身上的提示
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
		if (this.rawin("EndHint"))
			EndHint(dierEntity);

		// 生还者玩家死亡时输出提示
		if (::LinGe.GetPlayerTeam(dierEntity) != 2)
			return;
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

local CurrentHint = [];
local CurrentHintCount = 0;
getconsttable()["LINGE_NONE_ICON"] <- "";
const HINTMODE_AUTO		= 0; // 当玩家已经注意到提示时会自动关闭
const HINTMODE_NORMAL	= 1; // 会一直持续到设定的提示时间
const HINTMODE_SCREEN	= 2; // 不管配置文件如何设定，提示都只显示在屏幕内
const HINTMODE_SIGHT	= 3; // 提示只显示在视野内（不会在屏幕外和墙体后显示）

// 事件：玩家倒地
::LinGe.Hint.OnGameEvent_player_incapacitated <- function (params)
{
	if (!params.rawin("userid") || params.userid == 0)
		return;

	local player = GetPlayerFromUserID(params.userid);
	if (player.IsSurvivor())
	{
		if (Config.help.dominateDelay >= 0 && null != player.GetSpecialInfectedDominatingMe()) // 如果处于被控状态则先不提示倒地
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
	// 倒地状态提示
	local idx = ::pyinfo.survivorIdx.find(player.GetEntityIndex());
	if (null == idx)
		return;
	local showTo = clone ::pyinfo.survivorIdx;
	showTo.remove(idx);
	ShowHint(player.GetPlayerName() + "倒地了", 1, player,
		showTo, Config.help.duration, "icon_alert", activator);
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
	// 挂边提示
	local idx = ::pyinfo.survivorIdx.find(player.GetEntityIndex());
	if (null == idx)
		return;
	local showTo = clone ::pyinfo.survivorIdx;
	showTo.remove(idx);
	ShowHint("帮助" + player.GetPlayerName(), 2, player,
		showTo, Config.help.duration, "icon_alert", activator);
}

// 成功救助队友 （倒地拉起、挂边拉起都会触发该事件）
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
	EndHint(player);
}
if (::LinGe.Hint.Config.help.duration > 0)
	::LinEventHook("OnGameEvent_heal_success", ::LinGe.Hint.OnGameEvent_heal_success, ::LinGe.Hint);

::LinGe.Hint.ShowPlayerDying <- function (player, activator=null)
{
	if (Config.help.duration <= 0)
		return;
	// 黑白状态提示
	local idx = ::pyinfo.survivorIdx.find(player.GetEntityIndex());
	if (null == idx)
		return;
	local showTo = clone ::pyinfo.survivorIdx;
	showTo.remove(idx);
	ShowHint(player.GetPlayerName() + "濒死", 1, player,
		showTo, Config.help.duration, "icon_medkit", activator, HINTMODE_NORMAL);
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
	local idx = ::pyinfo.survivorIdx.find(player.GetEntityIndex());
	if (null == idx)
		return;
	local showTo = clone ::pyinfo.survivorIdx;
	showTo.remove(idx);
	local text = "", name = player.GetPlayerName();
	switch (dominator.GetZombieType())
	{
	case 1: // Smoker
		text = name + "被捆绑Play";
		break;
	case 3: // Hunter
		text = name + "被扑倒了";
		break;
	case 5: // Jockey
		text = name + "要被玩坏了";
		break;
	case 6: // Charger
		text = name + "被牛牛顶了";
		break;
	default:
		throw "不可预见的错误";
	}
	ShowHint(text, 3, player, showTo, Config.help.duration, "icon_blank", activator);
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
		EndHint(player);
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
	if (::LinGe.GetPlayerTeam(bot) == 2 && HintIndex(player)!=null)
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
	if (::LinGe.GetPlayerTeam(player) == 2 && HintIndex(bot)!=null)
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
	hint_timeout = 0.0, // 持续时间，若为0则需要通过EndHint来关闭
						// 不设置其为 duration 提示的关闭统一由本脚本用EndHint来控制
	origin = Vector(0, 0, 0),
	angles = QAngle(0, 0, 0),
	targetname = ""
};
::LinGe.Hint.ShowHint <- function ( text, level=0, target = "", showTo = null, duration = 8.0,
	icon = "icon_tip", activator = null, hintMode=HINTMODE_AUTO, color = "255 255 255")
{
	if (typeof showTo == "array")
	{
		if (showTo.len() == 0)
			return false;
	}
	else if (null != showTo)
		throw "showTo 非法";
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

	EndHint(target); // 不允许同一目标上存在两个提示
	if (!AtLeastOne(level))
		return false;

	local _showTo = null;
	if (null != showTo)
		_showTo = SurvivorArrayIndexToEnt(showTo);
	else
		_showTo = SurvivorArrayIndexToEnt(::pyinfo.survivorIdx);

	local hinttbl = clone hintTemplateTbl;
	hinttbl.hint_target = target;
	hinttbl.hint_icon_onscreen = icon,
	hinttbl.hint_icon_offscreen = icon,
	hinttbl.hint_alphaoption = level>2 ? 1 : 0; // alphapulse 图标会变透明和可见的速度 0~3
	hinttbl.hint_pulseoption = level>2 ? 1 : 0; // 图标效果，图标收缩的速度 0~3
	hinttbl.hint_caption = text.tostring();
	hinttbl.hint_color = color;

	if (level >= 0)
		CurrentHintCount++;
	local hintEnt = {};
	if (hintMode == HINTMODE_AUTO)
	{
		foreach (val in _showTo)
		{
			hintEnt.rawset(val.GetEntityIndex(), {
				ent = null,
				time = 9999.0,
				count = 0,
			});
		}

		local hintInfo = {
			level = level,
			hintEnt = hintEnt,
			targetname = target,
			hinttbl = hinttbl,
			showTo = _showTo,
			stidx = 0,
			targetEnt = targetEnt,
			targetIsPlayer = false,
			activator = activator,
		};
		if (targetEnt.IsPlayer() || targetEnt.GetClassname() == "witch")
			hintInfo.targetIsPlayer = true;

		CurrentHint.push(hintInfo);
		::VSLib.Timers.AddTimerByName("AutoHint_" + target,
			0.1, true, Timer_AutoHint, hintInfo);
		Timer_AutoHint(hintInfo);
	}
	else
	{
		foreach (val in _showTo)
		{
			local isActivator = (activator && val == activator);
			// 设置 hint_nooffscreen 1:屏幕外不显示 0:屏幕外显示
			if (!Config.offscreenShow || hintMode == HINTMODE_SCREEN
			|| hintMode == HINTMODE_SIGHT || isActivator)
				hinttbl.hint_nooffscreen = "1";
			else
				hinttbl.hint_nooffscreen = "0";
			// 设置 hint_forcecaption 1:墙体后显示 0:墙体后不显示
			if (hintMode != HINTMODE_SIGHT)
				hinttbl.hint_forcecaption = "1";
			else
				hinttbl.hint_forcecaption = "0";
			// 设置 hint_suppress_rest 1:提示直接出现在标记点 0:提示先出现在屏幕中央
			if (isActivator)
				hinttbl.hint_suppress_rest = "1";
			else
				SetSuppressRest(hinttbl, val, targetEnt);
			local ent = QuickShowHint(hinttbl, val);
			if (ent)
				hintEnt.rawset(val.GetEntityIndex(), {ent=ent});
		}
		CurrentHint.push({ level=level, hintEnt=hintEnt, targetname=target });
	}

	if (duration <= 0.0) // 不允许设置永远存在的提示，避免实体一直不被Kill
		duration = 8.0;
	::VSLib.Timers.AddTimerByName("EndHint_" + target,
		duration, false, EndHint, target);
	return true;
}

::LinGe.Hint.Timer_AutoHint <- function (hintInfo)
{
	if (!hintInfo.targetEnt || !hintInfo.targetEnt.IsValid())
	{
		EndHint(hintInfo.targetname);
		return;
	}

	/*	tickProcessLimit 根据当前提示的数量来限制每个 Timer_AutoHint 函数每次处理最多多少个玩家的 hint
		虽然 Timer_AutoHint 里这点代码应该不至于会让服务器变卡
		但是实现这个方案肯定没有太大的坏处，在玩家人数和提示都很多时，它也只会增加一点点的功能触发延迟
		人数较少或提示较少时，这个限制其实是相当于没有的
	*/
	local tickProcessLimit = 40;
	if (CurrentHintCount > 0)
		tickProcessLimit = ceil(40 / CurrentHintCount);
	else
		printl("[LinGe] CurrentHintCount 异常");

	local hinttbl = hintInfo.hinttbl;
	local idx = 0;
	for (idx=hintInfo.stidx; idx < hintInfo.showTo.len() && idx < (hintInfo.stidx+tickProcessLimit); idx++)
	{
		local player = hintInfo.showTo[idx];
		if (player && player.IsValid())
		{
			local hintEnt = hintInfo.hintEnt[player.GetEntityIndex()];
			hintEnt.time += 0.1;
			if (hintEnt.time < 1.0) // 提示最少要存在一秒才会改变状态
				continue;

			if (player == hintInfo.activator)
			{
				// 对于主动发出该标记的人来说，提示总是一直存在
				// 但是不会在屏幕外显示，也会被墙体挡住
				if (!hintEnt.ent)
				{
					hinttbl.hint_nooffscreen = "1";
					hinttbl.hint_forcecaption = "0";
					hinttbl.hint_suppress_rest = "1";
					local ent = QuickShowHint(hinttbl, player);
					if (ent)
					{
						hintEnt.ent = ent;
						hintEnt.time = 0.0;
					}
					hintEnt.count++; // 即便创建实体失败也进行计数，避免反复创建导致游戏崩溃
				}
				continue;
			}

			local length = (player.GetOrigin() - hintInfo.targetEnt.GetOrigin()).Length();
			if (hintEnt.ent)
			{
				// 如果提示已经存在，则判断是否要隐藏
				if (hintInfo.targetIsPlayer) // 如果提示在玩家实体上
				{
					if (length >= 800.0) // 距离大于800不隐藏
						continue;
					if (!::LinGe.IsPlayerSeeHere(player, hintInfo.targetEnt, 40)) // 没看以40的角度差看向这个方向不隐藏
						continue;
					if ( !::LinGe.ChainTraceToEntity(player, hintInfo.targetEnt, MASK_SHOT_HULL,
							["player", "infected", "witch"]) ) // 无法链式追踪到实体不隐藏
						continue;
				}
				else
				{
					// 提示不在玩家实体上，即物品或其它
					if (length >= 250.0)
						continue;
					if (!::LinGe.IsPlayerNoticeEntity(player, hintInfo.targetEnt, 15,
						MASK_SHOT_HULL & (~CONTENTS_WINDOW), 15.0))
						continue;
				}
				DoEntFire("!self", "Kill", "", 0, player, hintEnt.ent);
				hintEnt.ent = null;
				hintEnt.time = 0.0;
				continue;
			}

			// 提示不存在，判断是否要显示
			if (hintInfo.targetIsPlayer)
			{
				if (hintEnt.count >= 2) // 已经提示过2次则不再显示
					continue;
				if (::LinGe.IsPlayerSeeHere(player, hintInfo.targetEnt, 40)) // 已经看向该角度时不显示
					continue;
				if (hintEnt.count > 0 && length < 800) // 已经注意到过这个提示一次，并且距离小于500时不显示
					continue;
				// 如果没有看向提示实体的角度，且没有显示过这个提示或者距离大于800，则会显示提示
			}
			else
			{
				// 物品类提示总是只显示一次
				// 但没有其它判断条件，标记刚发出的时候总是马上显示
				if (hintEnt.count >= 1)
					continue;
			}
			hinttbl.hint_nooffscreen = Config.offscreenShow ? "0" : "1";
			hinttbl.hint_forcecaption = "1";
			SetSuppressRest(hinttbl, player, hintInfo.targetEnt);
			local ent = QuickShowHint(hinttbl, player);
			if (ent)
			{
				hintEnt.ent = ent;
				hintEnt.time = 0.0;
			}
			hintEnt.count++;
		}
	}

	// 如果没处理完所有玩家的 hint，则留下个循环处理
	// 如果处理完了，就重置索引
	if (idx < hintInfo.showTo.len())
		hintInfo.stidx = idx;
	else
		hintInfo.stidx = 0;
}.bindenv(::LinGe.Hint);

::LinGe.Hint.HintIndex <- function (params)
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
	local idx = HintIndex(params);
	if (null == idx)
		return;
	::VSLib.Timers.RemoveTimerByName("EndHint_" + CurrentHint[idx].targetname);
	::VSLib.Timers.RemoveTimerByName("AutoHint_" + CurrentHint[idx].targetname);
	local hintEnt = CurrentHint[idx].hintEnt;
	foreach (val in hintEnt)
	{
		if (val.ent)
			DoEntFire("!self", "Kill", "", 0, null, val.ent);
	}
	if (CurrentHint[idx].level >= 0)
		CurrentHintCount--;
	CurrentHint.remove(idx);
}.bindenv(::LinGe.Hint);

// 保证至少一个空位。若空位不足，则清理一个同级或更低级别的信息（优先清理最低级、最早出现的提示）
// 若无可清理的空位，返回 false
::LinGe.Hint.AtLeastOne <- function (level)
{
	if (level < 0) // level < 0 表示该提示无视上限
		return true;
	if (CurrentHint.len() < Config.limit)
		return true;

	local minLevel = level + 1;
	local i = null, count = 0;
	foreach (idx, val in CurrentHint)
	{
		if (val.level >= 0)
		{
			count++;
			if (val.level < minLevel)
			{
				minLevel = val.level;
				i = idx;
			}
		}
	}
	// 如果 level >= 0 的项目小于限制数量 则可以不清理
	if (count < Config.limit)
		return true;

	if (i != null)
	{
		EndHint(i);
		return true;
	}
	else
		return false;
}

// targetEnt == null 时则不会对 hint_suppress_rest 进行设置
::LinGe.Hint.QuickShowHint <- function (tbl, player)
{
	tbl.rawset("targetname", "LinGe_" + UniqueString());
	local ent = g_ModeScript.CreateSingleSimpleEntityFromTable(tbl);
	if (!ent)
	{
		printl("[LinGe] CreateEntity 创建实体失败");
		return null;
	}
	ent.ValidateScriptScope();
	DoEntFire("!self", "ShowHint", "", 0.0, player, ent);
	return ent;
}

// 根据玩家的视角来设置 hint_suppress_rest
::LinGe.Hint.SetSuppressRest <- function (tbl, player, targetEnt)
{
	if (targetEnt && player)
	{
		if (::LinGe.IsPlayerSeeHere(player, targetEnt, 60))
			tbl.rawset("hint_suppress_rest", "1");
		else
			tbl.rawset("hint_suppress_rest", "0");
	}
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

// 按键监测
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
		local curPressed = player.GetButtonMask();
		if ((curPressed & BUTTON_ALT1) != (val & BUTTON_ALT1))
		{
			if (!(curPressed & BUTTON_ALT1)) // 松开触发
				::LinGe.Hint.PlayerPing(player);
		}
		buttonState[key] = curPressed;
	}
}

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
			if (type == 8)
				ShowHint("Tank!", 1, pEnt, null, Config.ping.duration, "icon_alert_red", player);
			else if (type > 0 && type < 8) // 除Tank外其余特感不显示图标，因为容易遮挡住特感
				ShowHint(zombieType[type-1] + "!", 1, pEnt, null, Config.ping.duration, LINGE_NONE_ICON, player);
		}
		else if (::LinGe.GetPlayerTeam(pEnt) == 2)
		{
			if (Config.help.duration <= 0 || CheckSurvivor(pEnt, player))
			{
				// 如果不允许玩家状态标记，或者队友是健康的，则单独给发出标记的玩家提示血量
				ShowHint("当前血量:" + ceil(pEnt.GetHealth() + pEnt.GetHealthBuffer()), -1,
					pEnt, [player], 2.0, LINGE_NONE_ICON, player, HINTMODE_NORMAL);
			}
		}
		break;
	case "witch":
		ShowHint("当心Witch!", 1, pEnt, null, Config.ping.duration, LINGE_NONE_ICON, player);
		break;
// case "infected": // 小僵尸
// 		break;
	case "prop_physics":
		local model = pEnt.GetModelName();
		if (weaponModel.rawin(model))
			ShowHint(weaponName[weaponModel[model]], 0, pEnt, null,
				Config.ping.duration, weaponIcon[weaponModel[model]], player);
		else
			ShowRunHint(vecPingPos, player);
		break;
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
		ShowHint("医疗箱", 0, pEnt, null, Config.ping.duration, "icon_interact", player);
		break;
	case "prop_car_alarm":
		if (!NetProps.GetPropInt( pEnt, "m_bDisabled" ) )
			ShowHint("注意警报!", 0, pEnt, null, Config.ping.duration, "icon_alert_red", player, HINTMODE_SIGHT);
		else
			ShowHint("警报不会触发", -1, pEnt, [player], 2, "icon_tip", player, HINTMODE_NORMAL);
		break;
	case "prop_door_rotating":
		ShowHint("走这里吧", 0, pEnt, null, Config.ping.duration, "icon_door", player, HINTMODE_NORMAL);
		break;
	case "prop_door_rotating_checkpoint":
		ShowHint("安全屋", 0, pEnt, null, Config.ping.duration, "icon_door", player, HINTMODE_NORMAL);
		break;
	// case "prop_fuel_barrel":
	// 	break;
	case "upgrade_ammo_explosive":
		ShowHint("高爆弹药", 0, pEnt, null, Config.ping.duration, "icon_explosive_ammo", player);
		break;
	case "upgrade_ammo_incendiary":
		ShowHint("燃烧弹药", 0, pEnt, null, Config.ping.duration, "icon_incendiary_ammo", player);
		break;
	case "upgrade_laser_sight":
		ShowHint("激光瞄准", 0, pEnt, null, Config.ping.duration, "icon_laser_sight", player);
		break;
	// case "worldspawn":
	// 	break;
	// Partial matches and undefined entities
	default:
		// All weapons go through here
		if (szClassname.find("weapon") == 0 )
		{
			local model = pEnt.GetModelName();
			if (weaponModel.rawin(model))
				ShowHint(weaponName[weaponModel[model]], 0, pEnt, null,
					Config.ping.duration, weaponIcon[weaponModel[model]], player);
			else if (weaponEntity.rawin(szClassname))
				ShowHint(weaponName[weaponEntity[szClassname]], 0, pEnt, null,
					Config.ping.duration, weaponIcon[weaponEntity[szClassname]], player);
			else if (weaponSpawn.rawin(szClassname))
				ShowHint(weaponName[weaponSpawn[szClassname]], 0, pEnt, null,
					Config.ping.duration, weaponIcon[weaponSpawn[szClassname]], player);
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
	ShowHint("这里!", -1, infoTargetEnt, null, Config.ping.duration, "icon_run", activator, HINTMODE_NORMAL);
	return true;
}

// 启用按键监控
if (!::LinGe.Hint.rawin("_buttonScaner") && ::LinGe.Hint.Config.ping.duration > 0)
{
	::LinGe.Hint._buttonScaner <- SpawnEntityFromTable("info_target", { targetname = "LinGe_Hint_buttonScan" });
	if (::LinGe.Hint._buttonScaner != null)
	{
		::LinGe.Hint._buttonScaner.ValidateScriptScope();
		local scrScope = ::LinGe.Hint._buttonScaner.GetScriptScope();
		scrScope.buttonState <- ::LinGe.Hint.buttonState;
		scrScope["ButtonScanFunc"] <- ::LinGe.Hint.ButtonScanFunc;
		AddThinkToEnt(::LinGe.Hint._buttonScaner, "ButtonScanFunc");
		// printl("[LinGe] 按键监视器已创建");
	}
	else
		throw "无法创建按键监视器";
}

} // if (::LinGe.Hint.Config.limit > 0) {

} // if ( !::LinGe.isVersus ) {