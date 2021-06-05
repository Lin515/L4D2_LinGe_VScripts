printl("[LinGe] Server 正在载入");
const EnabledMultiple = 0; // 停用自动多倍物资，该功能已改用多人控制插件完成

// 服务器控制 附加功能脚本
::LinGe.Server <- {};
::LinGe.Server.Config <- {
	autoMultiple = true, // 是否启用自动多倍物资
	autoMultipleDivisor = 4,
	tankUpdateFrequency = -1, // Tank生成时是否自动调整刷新率 为-1则不调整 对抗模式不生效
	tankMinInterpRatio = -1, // Tank生成时是否强制调整lerp 为-1则不调整 （刷新率开启时此参数才有效）
	supply = { // 哪些物资启用多倍
		weapon_first_aid_kit_spawn = true, // 医疗包
		weapon_pain_pills_spawn = false, // 药丸
		weapon_adrenaline_spawn = false, // 肾上腺素
		weapon_melee_spawn = false // 近战武器
	}
};
::LinGe.Config.Add("Server", ::LinGe.Server.Config);

// !zs 自杀指令
::LinGe.Server.Cmd_zs <- function (player, msg)
{
	if (msg.len() == 1)
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
::CmdAdd("zs", ::LinGe.Server.Cmd_zs, ::LinGe.Server, false);

// !update 便捷设置服务器刷新率指令
::LinGe.Server.Cmd_update <- function (player, msg)
{
	if (msg.len() == 1)
	{
		ClientPrint(null, 3, "\x04当前服务器刷新率为 \x03" + Convars.GetStr("nb_update_frequency"));
	}
	else if (msg.len() == 2)
	{
		if (msg[1].tofloat()>=0.0 && msg[1].tofloat()<=0.1)
		{
			Convars.SetValue("nb_update_frequency", msg[1].tofloat());
			ClientPrint(null, 3, "\x04服务器刷新率已设置为 \x03" + Convars.GetStr("nb_update_frequency"));
		}
	}
}
::CmdAdd("update", ::LinGe.Server.Cmd_update, ::LinGe.Server);

if ("coop" == g_BaseMode) {

::LinGe.Server.Cmd_mmn <- function (player, msg)
{
	if (msg.len() == 1)
	{
		Config.autoMultiple = !Config.autoMultiple;
		if (Config.autoMultiple)
		{
			ClientPrint(null, 3, "\x04自动多倍物资补给\x03 已开启");
			SetMultiple();
		}
		else
		{
			ClientPrint(null, 3, "\x04自动多倍物资补给\x03 已关闭");
			SetMultiple(1);
		}
		::LinGe.Config.Save("Server");
	}
}
if (EnabledMultiple)
	::CmdAdd("mmn", ::LinGe.Server.Cmd_mmn, ::LinGe.Server);

::LinGe.Server.OnGameEvent_round_start <- function (params)
{
	if (Config.tankUpdateFrequency >= 0)
	{
		EventHook("OnGameEvent_tank_spawn", ::LinGe.Server.OnGameEvent_tank_spawn, ::LinGe.Server);
		EventHook("OnGameEvent_tank_killed", ::LinGe.Server.OnGameEvent_tank_killed, ::LinGe.Server);
	}
}
::EventHook("OnGameEvent_round_start", ::LinGe.Server.OnGameEvent_round_start, ::LinGe.Server, false);

local nowTank = 0;
local oldUpdateFrequency = Convars.GetStr("nb_update_frequency").tofloat();
local oldMinInterpRatio = Convars.GetStr("sv_client_min_interp_ratio").tointeger();
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
		if (Convars.GetStr("nb_update_frequency").tofloat() != oldUpdateFrequency )
			Convars.SetValue("nb_update_frequency", oldUpdateFrequency);
		if (Config.tankMinInterpRatio > -1
		&& Convars.GetStr("sv_client_min_interp_ratio").tointeger() != oldMinInterpRatio )
			Convars.SetValue("sv_client_min_interp_ratio", oldMinInterpRatio);
	}
}

// 玩家队伍变换时自动设置物资倍数
::LinGe.Server.Event_human_team <- function (params)
{
	if (EnabledMultiple)
	{
		if (Config.autoMultiple)
			SetMultiple();
	}
}
::EventHook("human_team", ::LinGe.Server.Event_human_team, ::LinGe.Server);

// 当前是否有Tank被激活仇恨
::LinGe.Server.Timer_TankActivation <- function (params)
{
	if (Director.IsTankInPlay())
	{
		if (Convars.GetStr("nb_update_frequency").tofloat() != Config.tankUpdateFrequency )
			Convars.SetValue("nb_update_frequency", Config.tankUpdateFrequency);
		if ( Config.tankMinInterpRatio > -1
		&& Convars.GetStr("sv_client_min_interp_ratio").tointeger() != Config.tankMinInterpRatio )
			Convars.SetValue("sv_client_min_interp_ratio", Config.tankMinInterpRatio);
	}
	else
	{
		if (Convars.GetStr("nb_update_frequency").tofloat() != oldUpdateFrequency )
			Convars.SetValue("nb_update_frequency", oldUpdateFrequency);
		if (Config.tankMinInterpRatio > -1
		&& Convars.GetStr("sv_client_min_interp_ratio").tointeger() != oldMinInterpRatio )
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

::LinGe.Server.nowMultiple <- 1; // 当前物资倍数
// 设置物资补给倍数 若不传参数 则根据人数自动设置
::LinGe.Server.SetMultiple <- function (num=null)
{
	if (null == num)
	{
		local playerNum = ::pyinfo.survivor + ::pyinfo.ob;
		num = (playerNum / Config.autoMultipleDivisor).tointeger();
		if (playerNum%Config.autoMultipleDivisor != 0 || 0==num)
			num += 1;
	}
	else if (typeof num != "integer")
		throw "num 参数类型非法";

	if (nowMultiple != num)
	{
		foreach (key, val in Config.supply)
		{
			if (val)
				::SetKeyValueByClassname(key, "count", num);
		}
		nowMultiple = num;

		ClientPrint(null, 3, "\x04物资补给倍数已修改为\x03 " + nowMultiple);
	}
}

} // if ("coop" == g_BaseMode) {