printl("[LinGe] Server 正在载入");
::LinGe.Server <- {};

// 服务器控制 附加功能脚本
::LinGe.Server.Config <- {
};
::LinGe.Config.Add("Server", ::LinGe.Server.Config);
::LinGe.Cache.Server_Config <- ::LinGe.Server.Config;

// !update 便捷设置服务器刷新率指令
::LinGe.Server.Cmd_update <- function (player, args)
{
	if (args.len() == 1)
	{
		ClientPrint(null, 3, "\x04当前服务器刷新率为 \x03" + Convars.GetFloat("nb_update_frequency"));
	}
	else if (args.len() == 2)
	{
		local val = LinGe.TryStringToFloat(args[1], -1.0);
		if (val>=0.0 && val<=0.1)
		{
			Convars.SetValue("nb_update_frequency", val);
			ClientPrint(null, 3, "\x04服务器刷新率已设置为 \x03" + Convars.GetFloat("nb_update_frequency"));
		}
	}
}
::LinCmdAdd("update", ::LinGe.Server.Cmd_update, ::LinGe.Server);

if ("coop" == g_BaseMode) {

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
		if (!vplayer.IsAlive() || vplayer.IsDead()) // 可能不准
		{
			if (isIncapacitated)
				Say(player, "\x03我不想变成魔女，这个世界还有许多我想守护的东西", false);
			else
				Say(player, "\x03灵魂宝石会孕育出魔女的话，大家不就只有去死了吗！", false);
		}
	}
}
::LinCmdAdd("zs", ::LinGe.Server.Cmd_zs, ::LinGe.Server, false);

} // if ("coop" == g_BaseMode) {