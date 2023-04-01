// 特感击杀回复血量
::LinGe.RewardHP <- {};

::LinGe.RewardHP.Config <- {
	mode = 0, // 0:关闭 1:回复实血 2:回复虚血 3:回复虚血，条件不满足则回复实血
	limit = 100, // 奖励血量上限
	permanent = { // 实血回复量
		special = 2,// 击杀一只普通特感（非Tank和Witch）回复多少实血
		witch = 10, // 击杀一只Witch回复多少实血
		common = 0,// 击杀一只丧尸回复多少实血
	},
	temporary = { // 虚血回复量
		special = 4,// 击杀一只普通特感（非Tank和Witch）回复多少虚血
		witch = 20, // 击杀一只Witch回复多少虚血
		common = 0,// 击杀一只丧尸回复多少虚血
	}
};
::LinGe.Config.Add("RewardHP", ::LinGe.RewardHP.Config);
::LinGe.Cache.RewardHP_Config <- ::LinGe.RewardHP.Config;

// 仅在非对抗类模式生效
if (!::LinGe.isVersus) {
printl("[LinGe] 击杀回复血量 正在载入");

::LinGe.RewardHP.OnGameEvent_player_death <- function (params)
{
	if (Config.mode < 1 || Config.mode > 3)
		return;

	local victim = null;
	if (params.victimname == "Infected" || params.victimname == "Witch")
	{
		victim = Ent(params.entityid);
		if (!victim || !victim.IsValid())
			return;
	}
	else
	{
		if (params.victimname == "Tank")
			return;
		victim = GetPlayerFromUserID(params.userid);
		if (!victim || !victim.IsValid() || ::LinGe.GetPlayerTeam(victim) != 3)
			return;
	}

	local attacker = GetPlayerFromUserID(params.attacker);
	if (!attacker || !attacker.IsValid() || ::LinGe.GetPlayerTeam(attacker) != 2
	|| attacker.IsIncapacitated())
		return;

	local hp = attacker.GetHealth();
	local hpbuffer = attacker.GetHealthBuffer();
	if (hp >= Config.limit)
		return;

	local reward_perm = 0, reward_temp = 0;
	switch (params.victimname)
	{
	case "Infected":
		reward_perm = Config.permanent.common;
		reward_temp = Config.temporary.common;
		break;
	case "Witch":
		reward_perm = Config.permanent.witch;
		reward_temp = Config.temporary.witch;
		break;
	default:
		reward_perm = Config.permanent.special;
		reward_temp = Config.temporary.special;
		break;
	}

	// 判断回复虚血条件是否满足（模式不为1 且 虚血回复量>0 且 回复后总血量<=上限）
	// 满足则回复虚血，否则回复实血
	if (Config.mode != 1 && reward_temp > 0 && hp + hpbuffer + reward_temp <= Config.limit)
	{
		attacker.SetHealthBuffer(hpbuffer + reward_temp);
	}
	else if (reward_perm > 0)
	{
		// 回复实血，但实血量不会超过上限
		if (hp + reward_perm > Config.limit)
		{
			attacker.SetHealth(Config.limit);
		}
		else
		{
			attacker.SetHealth(hp + reward_perm);
		}
		// 如果奖励后总血量超过上限，则扣除多余的虚血，但扣除量不会超过本次奖励的实血量
		// 相当于虚血转换为实血
		local excess = attacker.GetHealth() + hpbuffer - Config.limit;
		if (excess > 0)
		{
			local diff = attacker.GetHealth() - hp;
			if (excess > diff)
				excess = diff;
			attacker.SetHealthBuffer(hpbuffer - excess);
		}
	}
}
::LinEventHook("OnGameEvent_player_death", ::LinGe.RewardHP.OnGameEvent_player_death, ::LinGe.RewardHP);

::LinGe.RewardHP.Cmd_rhp <- function (player, args)
{
	if (2 == args.len())
	{
		local mode = ::LinGe.TryStringToInt(args[1], 0);
		Config.mode = mode;
	}
	switch (Config.mode)
	{
	case 1:
		ClientPrint(null, 3, "\x04击杀回血当前模式 \x03回复实血");
		break;
	case 2:
		ClientPrint(null, 3, "\x04击杀回血当前模式 \x03回复虚血");
		break;
	case 3:
		ClientPrint(null, 3, "\x04击杀回血当前模式 \x03回复虚血，满血后回复实血");
		break;
	default:
		ClientPrint(null, 3, "\x04击杀回血当前模式 \x03关闭");
		break;
	}
	ClientPrint(player, 3, "\x04!rhp 0:关闭 1:回复实血 2:回复虚血 3:回复虚血，条件不满足则回复实血");
}
::LinCmdAdd("rhp", ::LinGe.RewardHP.Cmd_rhp, ::LinGe.RewardHP, "0:关闭 1:回复实血 2:回复虚血 3:回复虚血，条件不满足则回复实血");

} // if (!::LinGe.isVersus)