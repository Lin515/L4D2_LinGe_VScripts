// By LinGe QQ794182250
// 本系列脚本编写主要参考以下文档
// L4D2脚本函数清单：https://developer.valvesoftware.com/wiki/L4D2%E8%84%9A%E6%9C%AC%E5%87%BD%E6%95%B0%E6%B8%85%E5%8D%95
// L4D2 EMS/Appendix：HUD：https://developer.valvesoftware.com/wiki/L4D2_EMS/Appendix:_HUD
// L4D2 Events：https://wiki.alliedmods.net/Left_4_Dead_2_Events
printl("[LinGe] 脚本功能集正在载入");

const BASEVER = "1.1";
printl("[LinGe] Base v" + BASEVER +" 正在载入");
::LinGe <- {};
::LinGe.Debug <- true;

::LinGe.hostport <- Convars.GetStr("hostport").tointeger();
printl("[LinGe] 当前服务器端口 " + ::LinGe.hostport);

// ---------------------------全局函数START-------------------------------------------
// 当前模式是否是对抗模式
::CheckVersus <- function ()
{
	if (Director.GetGameMode() == "mutation15") // 生还者对抗
		return true;
	if ("versus" == g_BaseMode)
		return true;
	if ("scavenge" == g_BaseMode)
		return true;
	return false;
}
::isVersus <- ::CheckVersus();

// 设置某类下所有已生成实体的KeyValue
::SetKeyValueByClassname <- function (className, key, value)
{
	local entity = null;
	local func = null;

	switch (typeof value)
	{
	case "integer":
		func = @(entity, key, value) entity.__KeyValueFromInt(key, value);
		break;
	case "float":
		func = @(entity, key, value) entity.__KeyValueFromFloat(key, value);
		break;
	case "string":
		func = @(entity, key, value) entity.__KeyValueFromString(key, value);
		break;
	case "Vector":
		func = @(entity, key, value) entity.__KeyValueFromVector(key, value);
		break;
	default:
		throw "Value 参数类型非法：" + typeof value;
	}

	local count = 0;
	while ( (entity = Entities.FindByClassname(entity, className)) != null)
	{
		func(entity, key, value);
		count++;
	}
	return count;
}

// 通过userid获得玩家实体索引
::GetEntityIndexFromUserID <- function (userid)
{
	local entity = GetPlayerFromUserID(userid);
	if (null == entity)
		return null;
	else
		return entity.GetEntityIndex();
}

// 通过userid获得steamid
::GetSteamIDFromUserID <- function (userid)
{
	local entity = GetPlayerFromUserID(userid);
	if (null == entity)
		return null;
	else
		return entity.GetNetworkIDString();
}

// 该userid是否为BOT所有
::IsBotUserID <- function (userid)
{
	local entity = GetPlayerFromUserID(userid);
	if (null == entity)
		return true;
	else
		return "BOT"==entity.GetNetworkIDString();
}

// 如果source中某个key在dest中也存在，则将其赋值给dest中的key
::Merge <- function (dest, source)
{
	if ("table" == typeof dest && "table" == typeof source)
	{
		foreach (key, val in source)
		{
			if (dest.rawin(key))
			{
				// 如果指定key也是table，则进行递归
				if ("table" == typeof dest[key]
				&& "table" == typeof val )
					::Merge(dest[key], val);
				else
					dest[key] = val;
			}
		}
	}
}
// ---------------------------全局函数END-------------------------------------------

// ---------------------------CONFIG-配置管理START---------------------------------------
class ::LinGe.ConfigManager
{
	filePath = null;
	table = null;

	constructor(_filePath)
	{
		filePath = _filePath;
		table = {};
	}
	// 添加表到配置管理 若表名重复则会覆盖
	function Add(tableName, _table)
	{
		table.rawset(tableName, _table.weakref());
		Load(tableName);
	}

	// 从配置管理中删除表
	function Delete(tableName)
	{
		table.rawdelete(tableName);
	}
	// 载入指定表的配置
	// 注意，配置载入只会载入已创建的key，配置文件中有但脚本代码未创建的key不会被载入
	function Load(tableName)
	{
		if (!table.rawin(tableName))
			throw "未找到表";
		local fromFile = ::VSLib.FileIO.LoadTable(filePath);
		if (null != fromFile)
		{
			if (fromFile.rawin(tableName))
				::Merge(table[tableName], fromFile[tableName]);
		}
		Save(tableName); // 保持文件配置和已载入配置的一致性
	}
	// 保存指定表的配置
	function Save(tableName)
	{
		if (table.rawin(tableName))
		{
			local fromFile = ::VSLib.FileIO.LoadTable(filePath);
			if (null == fromFile)
				fromFile = {};
			fromFile.rawset(tableName, table[tableName]);
			::VSLib.FileIO.SaveTable(filePath, fromFile);
		}
		else
			throw "未找到表";
	}

	// 载入所有表
	function LoadAll()
	{
		local fromFile = ::VSLib.FileIO.LoadTable(filePath);
		if (null != fromFile)
			::Merge(table, fromFile);
		SaveAll();
	}
	// 保存所有表
	function SaveAll()
	{
		::VSLib.FileIO.SaveTable(filePath, table);
	}
};

local FILE_CONFIG = "LinGe/Config_" + ::LinGe.hostport;
::LinGe.Config <- ::LinGe.ConfigManager(FILE_CONFIG);
// ---------------------------CONFIG-配置管理END-----------------------------------------

// -----------------------事件回调函数注册START--------------------------------------
// 集合管理事件函数，可以让多个脚本中同事件的函数调用顺序变得可控
::LinGe.Events <- {};
::LinGe.Events.trigger <- []; // 触发表
::LinGe.Events.index <- {}; // 索引表
getconsttable().ACTION_CONTINUE <- 0;
getconsttable().ACTION_RESETPARAMS <- 1;
getconsttable().ACTION_STOP <- 2;

// 绑定函数到事件 允许同一事件重复绑定同一函数
// callOf为函数执行时所在表，为null则不指定表
// last为真即插入到回调函数列表的最后，为否则插入到最前，越靠前的函数调用得越早
// 成功绑定则返回该事件当前绑定的函数数量
// func若为null则表明本次EventHook只是注册一下事件
::LinGe.Events.EventHook <- function (event, func=null, callOf=null, last=true)
{
	// 若该事件未注册则进行注册
	if (event == "callback")
		throw "非法事件";

	if (!(event in index))
	{
		local table = { callback=[] };
		table[event] <- function (params)
		{
			local action = ACTION_CONTINUE;
			local _params = null==params ? null : clone params;
			foreach (val in callback)
			{
				if (null == val.func)
					continue;
				else
				{
					if (val.callOf != null)
						action = val.func.call(val.callOf, _params);
					else
						action = val.func(_params);
					switch (action)
					{
					case null:
						break;
					case ACTION_CONTINUE:
						break;
					case ACTION_RESETPARAMS:
						_params = null==params ? null : clone params;
						break;
					case ACTION_STOP:
						return;
					default:
						throw "未知ACTION";
					}
				}
			}
		};
		trigger.append(table);
		index[event] <- trigger.len()-1;
		if (event.find("OnGameEvent_") == 0)
			__CollectEventCallbacks(trigger[index[event]], "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);
	}

	local callback = trigger[index[event]].callback;
	if (null != func)
	{
		local _callOf = (callOf==null) ? null : callOf.weakref();
		if (last)
			callback.append( { func=func.weakref(), callOf=_callOf } );
		else
			callback.insert(0, { func=func.weakref(), callOf=_callOf } );
	}
	return callback.len();
}.bindenv(::LinGe.Events);
// 根据给定函数进行解绑 默认为逆向解绑，即解绑匹配项中最靠后的
// 事件未注册返回-1 未找到函数返回-2 成功解绑则返回其索引值
::LinGe.Events.EventUnHook <- function (event, func, callOf=null, reverse=true)
{
	local idx = EventIndex(event, func, callOf, reverse);
	if (idx >= 0)
		trigger[index[event]].callback.remove(idx);
	return idx;
}.bindenv(::LinGe.Events);

// 查找函数在指定事件的函数表的索引
// 事件未注册返回-1 未找到函数返回-2
::LinGe.Events.EventIndex <- function (event, func, callOf=null, reverse=true)
{
	if (event in index)
	{
		local callback = trigger[index[event]].callback;
		local len = callback.len();
		local i = 0;
		if (reverse)
		{
			for (i=len-1; i>-1; i--)
			{
				if (func == callback[i].func
				&& callOf == callback[i].callOf )
					break;
			}
		}
		else
		{
			for (i=0; i<len; i++)
			{
				if (func == callback[i].func
				&& callOf == callback[i].callOf )
					break;
			}
		}
		if (-1 == i || i == len)
			return -2;
		else
			return i;
	}
	else
		return -1;
}.bindenv(::LinGe.Events);

// delay为否则立即触发
::LinGe.Events.EventTrigger <- function (event, params=null, delay=false)
{
	if (event in index)
	{
		if (delay)
			::VSLib.Timers.AddTimer(0.1, false, (@(params) trigger[index[event]][event](params)).bindenv(::LinGe.Events), params);
		else
			trigger[index[event]][event](params);
	}
}.bindenv(::LinGe.Events);

::EventHook <- ::LinGe.Events.EventHook.weakref();
::EventUnHook <- ::LinGe.Events.EventUnHook.weakref();
::EventIndex <- ::LinGe.Events.EventIndex.weakref();
::EventTrigger <- ::LinGe.Events.EventTrigger.weakref();
// --------------------------事件回调函数注册END----------------------------------------

// ------------------------------Admin---START--------------------------------------
::LinGe.Admin <- {};
::LinGe.Admin.Config <- {
	enabled = true,
	takeOverAdminSystem = true, // 是否接管adminsystem的权限判断
	adminsFile = "linge/admins_simple.ini",
	list = [ { id="STEAM_1:0:64877973", name="Homura Chan" } ]
};
::LinGe.Admin.ConfigManager <- ::LinGe.ConfigManager("LinGe/Admin");
::LinGe.Admin.ConfigManager.Add("Admin", ::LinGe.Admin.Config);
::LinGe.Admin.cmdTable <- {}; // 指令表
// 如果你在 ems/linge 目录下创建了 sourcemod 管理员配置文件admins_simple.ini的链接
// 那么本系列脚本就会以该文件为准来判断是否为管理员
// 注意：只要steamid能在该文件中搜索到，那么就会判断为是管理员，即便这段ID在配置文件中被注释了（因为懒）
// 你也可以把这个文件改成别的文件 例如使用admin system的管理员列表：adminsFile = "admin system/admins.txt"
// 链接创建方法 请在left4dead2目录下运行以下命令：
// Windows	mklink /H "ems/linge/admins_simple.ini" "addons/sourcemod/configs/admins_simple.ini"
// Linux 	ln "addons/sourcemod/configs/admins_simple.ini" "ems/linge/admins_simple.ini"
::LinGe.Admin.adminsFile <- FileToString(::LinGe.Admin.Config.adminsFile);
if (::LinGe.Admin.adminsFile != null)
	printl("[LinGe] 将在 " + ::LinGe.Admin.Config.adminsFile + " 中搜索管理员ID");

// 添加指令 参数：指令，回调函数，函数执行表，是否是管理员指令
// 若已有相同指令存在会覆盖旧指令
::LinGe.Admin.CmdAdd <- function (string, func, callOf=null, isAdminCmd=true)
{
	local table = { func=func, callOf=callOf, isAdminCmd=isAdminCmd };
	::LinGe.Admin.cmdTable.rawset(string, table);
}.bindenv(::LinGe.Admin);

// 删除指令 成功删除返回其值 否则返回null
::LinGe.Admin.CmdDelete <- function (string)
{
	return ::LinGe.Admin.cmdTable.rawdelete(string);
}.bindenv(::LinGe.Admin);
::CmdAdd <- ::LinGe.Admin.CmdAdd.weakref();
::CmdDelete <- ::LinGe.Admin.CmdDelete.weakref();

// 事件：回合开始 如果启用了AdminSystem则覆盖其管理员判断指令
::LinGe.Admin.OnGameEvent_round_start <- function (params)
{
	if ("AdminSystem" in getroottable() && Config.takeOverAdminSystem)
	{
		::AdminSystem.IsAdmin = ::LinGe.Admin.IsAdmin;
		::AdminSystem.IsPrivileged = ::LinGe.Admin.IsAdmin;
	}
}
::EventHook("OnGameEvent_round_start", ::LinGe.Admin.OnGameEvent_round_start, ::LinGe.Admin);

// 事件：玩家发送消息 提取调用指令函数
::LinGe.Admin.OnGameEvent_player_say <- function (params)
{
	local msg = split(params.text, " ");
	if (msg[0].len() < 2)
		return;

	local firstChar = msg[0].slice(0, 1); // 取第一个字符
	local cmdstr = msg[0].slice(1);
	if (firstChar != "!"
	&& firstChar != "/"
	&& firstChar != "." )
		return;

	if (cmdTable.rawin(cmdstr))
	{
		local cmd = cmdTable[cmdstr];
		local player = GetPlayerFromUserID(params.userid);
		if (cmd.isAdminCmd && !IsAdmin(params))
		{	// 如果是管理员指令而用户身份不是管理员，则发送权限不足提示
			ClientPrint(player, 3, "\x04此条指令仅管理员可用！");
		}
		else
		{
			msg[0] = cmdstr;
			if (cmd.callOf != null)
				cmd.func.call(cmd.callOf, player, msg);
			else
				cmd.func(player, msg);
		}
	}
}
::EventHook("OnGameEvent_player_say", ::LinGe.Admin.OnGameEvent_player_say, ::LinGe.Admin);

// 传入一个带有userid或者networkid的table
// 函数将根据这两个值的其中一个来判断是否是管理员
::LinGe.Admin.IsAdmin <- function (params)
{
	// 未启用权限管理则所有人视作管理员
	if (!::LinGe.Admin.Config.enabled)
		return true;
	// 如果是单人游戏则直接返回true
	if (Director.IsSinglePlayerGame())
		return true;

	// 获取steam id
	local steamID = null;
	// 如果是被AdminSystem调用的 传入的参数会是VSLib的Player类实例
	if (typeof params == "VSLIB_PLAYER")
	{
		if ( params.IsServerHost() )
			return true;
		steamID = params.GetSteamID();
	}
	else
	{
		if (params.rawin("networkid"))
			steamID = params.networkid;
		else if (params.rawin("userid"))
			steamID = GetSteamIDFromUserID(params.userid);
	}
	if (null == steamID)
		return false;

	// 通过steamID判断是否是管理员
	if (null != ::LinGe.Admin.adminsFile)
	{
		if (null == ::LinGe.Admin.adminsFile.find(steamID))
			return false;
		else
			return true;
	}
	else
	{
		foreach (val in ::LinGe.Admin.Config.list)
		{
			if (val.id == steamID)
				return true;
		}
		return false;
	}
}

::LinGe.Admin.Cmd_setvalue <- function (player, msg)
{
	if (msg.len() == 3)
		Convars.SetValue(msg[1], msg[2]);
}
::CmdAdd("setvalue", ::LinGe.Admin.Cmd_setvalue, ::LinGe.Admin);

::LinGe.Admin.Cmd_getvalue <- function (player, msg)
{
	if (msg.len() == 2)
		ClientPrint(player, 3, Convars.GetStr(msg[1]));
}
::CmdAdd("getvalue", ::LinGe.Admin.Cmd_getvalue, ::LinGe.Admin);
//----------------------------Admin-----END---------------------------------

//------------------------------Cache---------------------------------------
::LinGe.Cache <- { isValidCache=false }; // isValidCache指定是否是有效Cache 数据无效时不恢复 使用changelevel换图会导致这个数据无效
::Cache <- ::LinGe.Cache.weakref();

// 这两个事件由VSLib/easylogic.nut触发
::LinGe.CacheRestore <- function (params)
{
	local temp = {};
	local isValidCache = false;
	RestoreTable("LinGe_Cache", temp);
	if (temp.rawin("isValidCache"))
	{
		if (temp.isValidCache)
		{
			::Merge(Cache, temp);
			Cache.isValidCache = false;
			SaveTable("LinGe_Cache", Cache);
			isValidCache = true;
		}
	}
	local _params = { isValidCache=isValidCache };
	::EventTrigger("LinGe_CacheRestore", _params);
}
::LinGe.CacheSave <- function (params)
{
	Cache.rawset("isValidCache", true);
	SaveTable("LinGe_Cache", Cache);
	delete ::LinGe;
}
::EventHook("VSLibScriptStart", ::LinGe.CacheRestore, ::LinGe);
::EventHook("ScriptMode_OnShutdown", ::LinGe.CacheSave, ::LinGe);

//----------------------------Base-----START--------------------------------
::LinGe.Base <- {};
::LinGe.Base.Config <- {
	isShowTeamChange = true,
	recordPlayerInfo = false
};
::LinGe.Config.Add("Base", ::LinGe.Base.Config);
::Cache.Base_Config <- ::LinGe.Base.Config;
local isExistMaxplayers = true;

// 已知玩家列表 存储加入过服务器玩家的SteamID与名字
const FILE_KNOWNPLAYERS = "LinGe/playerslist";
::LinGe.Base.known <- { list = [] };
::LinGe.Base.knownManager <- ::LinGe.ConfigManager(FILE_KNOWNPLAYERS);
::LinGe.Base.knownManager.Add("known", ::LinGe.Base.known);

// 玩家信息
::LinGe.Base.info <- {
	maxplayers = 0, // 最大玩家数量
	survivor = 0, // 生还者玩家数量
	special = 0, // 特感玩家数量
	ob = 0, // 旁观者玩家数量
	survivorIdx = [] // 生还者玩家实体索引（实际上还包括了旁观者的）
};
::pyinfo <- ::LinGe.Base.info.weakref();

::LinGe.Base.IsNoHuman <- function ()
{
	if (survivor>0 || special>0 || ob>0)
		return false;
	else
		return true;
}

::LinGe.Base.GetHumans <- function ()
{
	return ::pyinfo.ob + ::pyinfo.survivor + ::pyinfo.special;
}

// 事件：回合开始
::LinGe.Base.OnGameEvent_round_start <- function (params)
{
	UpdateMaxplayers();
	// 当前关卡重开的话，脚本会被重新加载，玩家数据会被清空
	// 而重开情况下玩家的队伍不会发生改变，不会触发事件
	// 所以需要开局时搜索玩家
	::Merge(::pyinfo, SearchForPlayers());
}
::EventHook("OnGameEvent_round_start", ::LinGe.Base.OnGameEvent_round_start, ::LinGe.Base);

// 玩家连接事件 参数列表：
// xuid			如果是BOT就为0，是玩家会是一串数字
// address		地址，如果是BOT则为none，是本地房主则为loopback
// networkid	steamID，如果是BOT则为 "BOT"
// index		不明
// userid		userid
// name			玩家名（Linux上是Name，Windows上是name，十分奇怪）
// bot			是否为BOT
// splitscreenplayer 不明
::LinGe.Base.OnGameEvent_player_connect <- function (params)
{
	if (!params.rawin("networkid"))
		return;
	if ("BOT" == params.networkid)
		return;
	local playerName = null;
	if (params.rawin("Name")) // Win平台和Linux平台的name参数似乎首字母大小写有差异
		playerName = params.Name;
	else if (params.rawin("name"))
		playerName = params.name;
	else
		return;

	if (Config.isShowTeamChange)
		ClientPrint(null, 3, "\x03"+ playerName + "\x04 正在连接");

	// 判断是否加入过服务器 未加入过则将其信息存入knownPlayers
	if (Config.recordPlayerInfo)
	{
		local isExist = false;
		foreach (idx, val in known.list)
		{
			if (val.id == params.networkid)
			{
				if (val.name == playerName)
					isExist = true;
				else
					knownPlayers.remove[idx]; // 如果id存在但玩家名变化了则删除重新更新
				break;
			}
		}
		if (!isExist)
		{
			known.list.append( { id=params.networkid, name=playerName } );
			knownManager.Save("known");
		}
	}
}
::EventHook("OnGameEvent_player_connect", ::LinGe.Base.OnGameEvent_player_connect, ::LinGe.Base);

// 玩家队伍更换事件
// team=0：玩家刚连接、和断开连接时会被分配到此队伍 不统计此队伍的人数
// team=1：旁观者 team=2：生还者 team=3：特感
::LinGe.Base.OnGameEvent_player_team <- function (params)
{
	if (!params.rawin("userid"))
		return;

	local player = GetPlayerFromUserID(params.userid);
	local entityIndex = player.GetEntityIndex();
	// 使用插件等方式加入bot时，params.isbot不准确
	// 应获取其SteamID进行判断
	if ("BOT" == player.GetNetworkIDString())
		return;
	if (params.oldteam == params.team)
		throw "异常：oldteam与team相等";

	UpdateMaxplayers();

	// 使用插件等方式改变阵营的时候，可能导致参数 params.name 为空
	// 通过GetPlayerName获取会比较稳定
	local text = "\x03" + player.GetPlayerName() + "\x04 ";
	switch (params.oldteam)
	{
	case 0: break;
	case 1:	::pyinfo.ob--; break;
	case 2:	::pyinfo.survivor--; break;
	case 3:	::pyinfo.special--; break;
	default: throw "未知异常发生";
	}
	if (params.disconnect)
	{
		if (0 == params.team)
			text += "已离开";
		else
			throw "断开连接 team != 0";
	}
	else
	{
		switch (params.team)
		{
		case 1: ::pyinfo.ob++; text += "加入了旁观者"; break;
		case 2: ::pyinfo.survivor++; text += "加入了生还者"; break;
		case 3: ::pyinfo.special++; text += "加入了感染者"; break;
		default: throw "意外情况";
		}
	}

	local idx = ::pyinfo.survivorIdx.find(entityIndex);
	// 如果是离开或者加入特感就将其从生还者实体索引数组删除
	// 如果是加入生还者或旁观者就将其索引加入
	if ( (params.disconnect || 3 == params.team)
	&& null != idx )
		::pyinfo.survivorIdx.remove(idx);
	else if ( (1 == params.team || 2 == params.team)
	&& null == idx)
		::pyinfo.survivorIdx.append(entityIndex);

	if (Config.isShowTeamChange)
		ClientPrint(null, 3, text);

	// 对抗模式下经常出现队伍人数错误 不知道是否是药抗插件的问题
	if (::LinGe.Debug)
	{
		printl(player.GetPlayerName() + ": " + params.oldteam + " -> " + params.team);
		printl("now:ob=" + ::pyinfo.ob + ", survivor=" + ::pyinfo.survivor + ", special=" + ::pyinfo.special);
	}

	// 触发真实玩家变更事件
	local _params = clone params;
	_params.player <- player;
	::EventTrigger("human_team", _params, false);
}
::EventHook("human_team");
::EventHook("OnGameEvent_player_team", ::LinGe.Base.OnGameEvent_player_team, ::LinGe.Base);

::LinGe.Base.Cmd_teaminfo <- function (player, msg)
{
	if (1 == msg.len())
	{
		Config.isShowTeamChange = !Config.isShowTeamChange;
		local text = Config.isShowTeamChange ? "开启" : "关闭";
		ClientPrint(null, 3, "服务器已" + text + "队伍更换提示");
	}
}
::CmdAdd("teaminfo", ::LinGe.Base.Cmd_teaminfo, ::LinGe.Base);

// 搜索玩家
::LinGe.Base.SearchForPlayers <- function ()
{
	local player = null; // 玩家实例
	local entityIndex = 0;	// 实体索引
	local table = {
		survivor = 0, // 生还玩家数量
		ob = 0, // 旁观者玩家数量
		special = 0, // 特感玩家数量
		survivorIdx = [] // 生还者实体索引数组
	};

	// 通过类名查找玩家
	while ( (player = Entities.FindByClassname(player, "player")) != null )
	{
		// 判断搜索到的实体有效性
		if ( player.IsValid() )
		{
			// 判断阵营
			entityIndex = player.GetEntityIndex();
			if ("BOT" == player.GetNetworkIDString())
				continue;
			else if (player.IsSurvivor())
			{
				table.survivor++;
				table.survivorIdx.append(entityIndex);
			}
			else if (9 == player.GetZombieType())
			{
				table.ob++;
				table.survivorIdx.append(entityIndex);
			}
			else
				table.special++;
		}
	}
	return table;
}

::LinGe.Base.UpdateMaxplayers <- function ()
{
	if (isExistMaxplayers)
	{
		::pyinfo.maxplayers = Convars.GetStr("sv_maxplayers");
		if (null == ::pyinfo.maxplayers)
			isExistMaxplayers = false;
		else
			::pyinfo.maxplayers = ::pyinfo.maxplayers.tointeger();

		if (::pyinfo.maxplayers < 0 || (!isExistMaxplayers))
		{
			if (::isVersus)
				::pyinfo.maxplayers = 8;
			else
				::pyinfo.maxplayers = 4;
		}
	}
}
//----------------------------Base-----END---------------------------------