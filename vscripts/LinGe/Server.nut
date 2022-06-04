printl("[LinGe] Server 正在载入");
::LinGe.Server <- {};

// 服务器控制 附加功能脚本
::LinGe.Server.Config <- {
	zs = {
		enabled = true,
		hint = true,
		incap = "我不想变成魔女，这个世界还有许多我想守护的东西",
		noIncap = "灵魂宝石会孕育出魔女的话，大家不就只有去死了吗！"
	}
};
::LinGe.Config.Add("Server", ::LinGe.Server.Config);
::LinGe.Cache.Server_Config <- ::LinGe.Server.Config;

if ("coop" == g_BaseMode && ::LinGe.Server.Config.zs.enabled) {

// !zs 自杀指令
::LinGe.Server.Cmd_zs <- function (player, args)
{
	if (args.len() == 1)
	{
		if (!player.IsSurvivor())
			return;

		local vplayer = ::VSLib.Player(player);
		if (!vplayer.IsPlayerEntityValid())
			return;
		if (!vplayer.IsAlive() || vplayer.IsDead())
			return;

		local isIncapacitated = vplayer.IsIncapacitated();
		vplayer.Kill();
		if (Config.zs.hint) // 如果开启了自杀后提示
		{
			if (!vplayer.IsAlive() || vplayer.IsDead()) // 可能不准
			{
				if (isIncapacitated)
				{
					Say(player, "\x03" + Config.zs.incap, false);
				}
				else
				{
					Say(player, "\x03" + Config.zs.noIncap, false);
				}
			}
		}
	}
}
::LinCmdAdd("zs", ::LinGe.Server.Cmd_zs, ::LinGe.Server, "自杀指令", false);

} // if ("coop" == g_BaseMode) {