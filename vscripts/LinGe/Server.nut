const SERVERVER = "1.3";
printl("[LinGe] Server v" + SERVERVER +" 正在载入");
::LinGe.Server <- {};

// 服务器控制 附加功能脚本
::LinGe.Server.Config <- {
	tankUpdateFrequency = -1, // Tank生成时是否自动调整刷新率 为-1则不调整 对抗模式不生效
	tankMinInterpRatio = -1, // Tank生成时是否强制调整lerp 为-1则不调整 （刷新率开启时此参数才有效）
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

local nowTank = 0;
local oldUpdateFrequency = Convars.GetFloat("nb_update_frequency");
local oldMinInterpRatio = Convars.GetFloat("sv_client_min_interp_ratio").tointeger();
::LinGe.Server.OnGameEvent_tank_spawn <- function (params)
{
	nowTank++;
	//if (SearchForTank() == 1)
	if (nowTank == 1)
	{
		::VSLib.Timers.AddTimerByName("Timer_TankActivation", 1.0, true, Timer_TankActivation);
	}
}
::LinGe.Server.OnGameEvent_tank_killed <- function (params)
{
	nowTank--;
	//if (Config.tankUpdateFrequency >= 0 && SearchForTank() == 0)
	if (nowTank == 0)
	{
		// 无Tank时去除定时器 还原设置
		::VSLib.Timers.RemoveTimerByName("Timer_TankActivation");
		if (Convars.GetFloat("nb_update_frequency") != oldUpdateFrequency )
			Convars.SetValue("nb_update_frequency", oldUpdateFrequency);
		if (Config.tankMinInterpRatio > -1
		&& Convars.GetFloat("sv_client_min_interp_ratio").tointeger() != oldMinInterpRatio )
			Convars.SetValue("sv_client_min_interp_ratio", oldMinInterpRatio);
	}
}
if (::LinGe.Server.Config.tankUpdateFrequency >= 0)
{
	::LinEventHook("OnGameEvent_tank_spawn", ::LinGe.Server.OnGameEvent_tank_spawn, ::LinGe.Server);
	::LinEventHook("OnGameEvent_tank_killed", ::LinGe.Server.OnGameEvent_tank_killed, ::LinGe.Server);
}

// 当前是否有Tank被激活仇恨
::LinGe.Server.Timer_TankActivation <- function (params)
{
	if (Director.IsTankInPlay())
	{
		if (Convars.GetFloat("nb_update_frequency") != Config.tankUpdateFrequency )
			Convars.SetValue("nb_update_frequency", Config.tankUpdateFrequency);
		if ( Config.tankMinInterpRatio > -1
		&& Convars.GetFloat("sv_client_min_interp_ratio").tointeger() != Config.tankMinInterpRatio )
			Convars.SetValue("sv_client_min_interp_ratio", Config.tankMinInterpRatio);
	}
	else
	{
		if (Convars.GetFloat("nb_update_frequency") != oldUpdateFrequency )
			Convars.SetValue("nb_update_frequency", oldUpdateFrequency);
		if (Config.tankMinInterpRatio > -1
		&& Convars.GetFloat("sv_client_min_interp_ratio").tointeger() != oldMinInterpRatio )
			Convars.SetValue("sv_client_min_interp_ratio", oldMinInterpRatio);
	}
}.bindenv(::LinGe.Server);

// -----------------------功能函数START------------------------------------------

// 查找存活tank数量
::LinGe.Server.SearchForTank <- function()
{
	local player = null; // 玩家实例
	local num = 0;

	while ( (player = Entities.FindByClassname(player, "player")) != null )
	{
		// 判断搜索到的实体有效性
		if ( player.IsValid() )
		{
			// 判断阵营和存活
			if (8==player.GetZombieType()&& !player.IsDead())
				num++;
		}
	}
	return num;
}

} // if ("coop" == g_BaseMode) {