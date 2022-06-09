::LinGe.zs <- {};

// 服务器控制 附加功能脚本
::LinGe.zs.Config <- {
	enabled = true,
	hint = true,
	incap = "我不想变成魔女，这个世界还有许多我想守护的东西",
	noIncap = "灵魂宝石会孕育出魔女的话，大家不就只有去死了吗！"
};
::LinGe.Config.Add("zs", ::LinGe.zs.Config);
//::LinGe.Cache.zs_Config <- ::LinGe.zs.Config;

if ("coop" == g_BaseMode && ::LinGe.zs.Config.enabled) {
printl("[LinGe] 自杀指令 正在载入");
// !zs 自杀指令
::LinGe.zs.Cmd_zs <- function (player, args)
{
	if (args.len() == 1)
	{
		if (::LinGe.GetPlayerTeam(player) != 2)
			return;

		local vplayer = ::VSLib.Player(player);
		if (!vplayer.IsPlayerEntityValid())
			return;
		if (!vplayer.IsAlive() || vplayer.IsDead())
			return;

		local isIncapacitated = vplayer.IsIncapacitated();
		vplayer.Kill();
		if (Config.hint) // 如果开启了自杀后提示
		{
			if (!vplayer.IsAlive() || vplayer.IsDead()) // 可能不准
			{
				if (isIncapacitated)
				{
					Say(player, "\x03" + Config.incap, false);
				}
				else
				{
					Say(player, "\x03" + Config.noIncap, false);
				}
			}
		}
	}
}
::LinCmdAdd("zs", ::LinGe.zs.Cmd_zs, ::LinGe.zs, "自杀指令", false);

}