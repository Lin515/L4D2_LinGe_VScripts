// By LinGe https://github.com/Lin515/L4D2_LinGe_VScripts
// 本系列脚本编写主要参考以下文档
// L4D2脚本函数清单：https://developer.valvesoftware.com/wiki/L4D2%E8%84%9A%E6%9C%AC%E5%87%BD%E6%95%B0%E6%B8%85%E5%8D%95
// L4D2 EMS/Appendix：HUD：https://developer.valvesoftware.com/wiki/L4D2_EMS/Appendix:_HUD
// L4D2 Events：https://wiki.alliedmods.net/Left_4_Dead_2_Events
// 以及VSLib与admin_system的脚本源码
printl("[LinGe] 脚本功能集正在载入");

const BASEVER = "1.2";
printl("[LinGe] Base v" + BASEVER +" 正在载入");
::LinGe <- {};
::LinGe.Debug <- true;

::LinGe.hostport <- Convars.GetFloat("hostport").tointeger();
printl("[LinGe] 当前服务器端口 " + ::LinGe.hostport);

// ---------------------------全局函数START-------------------------------------------
// 主要用于调试
::DebugPrintTable <- function (table)
{
	foreach (key, val in table)
		print(key + "=" + val + " ; ");
	print("\n");
}

// 尝试将一个字符串转换为int类型 eValue为出现异常时返回的值
::TryStringToInt <- function (value, eValue=0)
{
	local ret = eValue;
	try
	{
		ret = value.tointeger();
	}
	catch (e)
	{
		ret = eValue;
	}
	return ret;
}
// 尝试将一个字符串转换为float类型 eValue为出现异常时返回的值
::TryStringToFloat <- function (value, eValue=0.0)
{
	local ret = eValue;
	try
	{
		ret = value.tofloat();
	}
	catch (e)
	{
		ret = eValue;
	}
	return ret;
}

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
		throw "参数类型非法";
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

// 从网络属性判断一个实体是否存活
::IsAlive <- function (ent)
{
	return NetProps.GetPropInt(ent, "m_lifeState") == 0;
}

// 从bot生还者中获取其就位的生还者玩家实体
// 须自己先检查是否是有效生还者bot 否则可能出错
::GetHumanPlayer <- function (bot)
{
	if (IsAlive(bot))
	{
		local human = GetPlayerFromUserID(NetProps.GetPropInt(bot, "m_humanSpectatorUserID"));
		if (null != human)
		{
			if (human.IsValid())
			{
				if ( "BOT" != human.GetNetworkIDString()
				&& 1==GetPlayerTeam(human) )
					return human;
			}
		}
	}
	return null;
}

// 判断玩家是否处于闲置 参数可以是玩家实体也可以是实体索引
::IsPlayerIdle <- function (player)
{
	local entityIndex = 0;
	local _player = null;
	// 通过类名查找玩家
	if ("integer" == typeof player)
	{
		entityIndex = player;
		_player = PlayerInstanceFromIndex(entityIndex);
	}
	else if ("instance" == typeof player)
	{
		entityIndex = player.GetEntityIndex();
		_player = player;
	}
	else
		throw "参数类型非法";
	if (!_player.IsValid())
		return false;
	if (1 != GetPlayerTeam(_player))
		return false;

	local bot = null;
	while ( bot = Entities.FindByClassname(bot, "player") )
	{
		// 判断搜索到的实体有效性
		if ( bot.IsValid() )
		{
			// 判断阵营
			if ( bot.IsSurvivor()
			&& "BOT" == bot.GetNetworkIDString()
			&& IsAlive(bot) )
			{
				local human = GetHumanPlayer(bot);
				if (human != null)
				{
					if (human.GetEntityIndex() == entityIndex)
						return true;
				}
			}
		}
	}
	return false;
}

::GetPlayerTeam <- function (player)
{
	return NetProps.GetPropInt(player, "m_iTeamNum");
}

// 获取玩家实体数组
// team 指定要获取的队伍
// bot 是否获取bot
// alive 是否必须存活
::GetPlayers <- function (team=0, bot=true, alive=false)
{
	local arr = [];
	// 通过类名查找玩家
	local player = null;
	while ( player = Entities.FindByClassname(player, "player") )
	{
		// 判断搜索到的实体有效性
		if ( player.IsValid() )
		{
			// 判断阵营
			if (team!=0 && ::GetPlayerTeam(player)!=team)
				continue;
			if (!bot && "BOT" == player.GetNetworkIDString())
				continue;
			if (alive && !::IsAlive(player))
				continue;
			arr.append(player);
		}
	}
	return arr;
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

// -------------------------------VSLib-------------------------------------------------

// 让VSLib触发一些有用的事件
::VSLibScriptStart_VSLib <- ::VSLibScriptStart;
::VSLibScriptStart = function()
{
	if (getroottable().rawin("LinGe"))
		::EventTrigger("VSLibScriptStart_pre", null);
	::VSLibScriptStart_VSLib();
	if (getroottable().rawin("LinGe"))
		::EventTrigger("VSLibScriptStart_post", null);
}

g_MapScript.ScriptMode_OnShutdown_VSLib <- g_MapScript.ScriptMode_OnShutdown;
g_MapScript.ScriptMode_OnShutdown = function (reason, nextmap)
{
	local params = { reason=reason, nextmap=nextmap };
	if (getroottable().rawin("LinGe"))
		::EventTrigger("ScriptMode_OnShutdown_pre", params);
	delete ::LinGe;
	ScriptMode_OnShutdown_VSLib(reason, nextmap);
//	if (getroottable().rawin("LinGe"))
//		::EventTrigger("ScriptMode_OnShutdown_post", params);
}

// 让指令支持 . 前缀，AdminSystem 的指令通过 InterceptChat 被调用
// 本系列脚本的指令不通过 InterceptChat
g_ModeScript.InterceptChat_VSLib <- g_ModeScript.InterceptChat;
g_ModeScript.InterceptChat = function (_str, srcEnt)
{
	// 如果是 . 前缀的消息 则将 . 替换为 /
	local str = _str;
	local name = "", msg = "";
	if (srcEnt != null)
	{
		name = srcEnt.GetPlayerName() + ": ";
		msg = strip(str.slice(str.find(name) + name.len()));
	}
	else if ( str.find("Console: ") != null )
	{
		name = "Console: ";
		msg = strip(str.slice(str.find(name) + name.len()));
	}
	if (msg.find(".") == 0)
		str = name + "/" + msg.slice(1);
	InterceptChat_VSLib(str, srcEnt);
}


// 判断玩家是否为BOT时通过steamid进行判断
function VSLib::Entity::IsBot()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	if (IsPlayer())
		return "BOT" == GetSteamID();
	else
		return IsPlayerABot(_ent);
}

// 改良原函数，使其输出的文件带有缩进
function VSLib::FileIO::SerializeTable(object, predicateStart = "{\n", predicateEnd = "}\n", indice = true, indent=1)
{
	local indstr = "";
	for (local i=0; i<indent; i++)
		indstr += "\t";

	local baseString = predicateStart;

	foreach (idx, val in object)
	{
		local idxType = typeof idx;

		if (idxType == "instance" || idxType == "class" || idxType == "function")
			continue;

		// Check for invalid characters
		local idxStr = idx.tostring();
		local reg = regexp("^[a-zA-Z0-9_]*$");

		if (!reg.match(idxStr))
		{
			printf("VSLib Warning: Index '%s' is invalid (invalid characters found), skipping...", idxStr);
			continue;
		}

		// Check for numeric fields and prefix them so system can compile
		reg = regexp("^[0-9]+$");
		if (reg.match(idxStr))
			idxStr = "_vslInt_" + idxStr;


		local preCompileString = indstr + ((indice) ? (idxStr + " = ") : "");

		switch (typeof val)
		{
			case "table":
				baseString += preCompileString + ::VSLib.FileIO.SerializeTable(val, "{\n", "}\n", true, indent+1);
				break;

			case "string":
				baseString += preCompileString + "\"" + ::VSLib.Utils.StringReplace(::VSLib.Utils.StringReplace(val, "\"", "{VSQUOTE}"), @"\\", "{VSSLASH}") + "\"\n"; // "
				break;

			case "integer":
				baseString += preCompileString + val + "\n";
				break;

			case "float":
				baseString += preCompileString + val + "\n";
				break;

			case "array":
				baseString += preCompileString + ::VSLib.FileIO.SerializeTable(val, "[\n", "]\n", false, indent+1);
				break;

			case "bool":
				baseString += preCompileString + ((val) ? "true" : "false") + "\n";
				break;
		}
	}

	// 末尾括号的缩进与上一级同级
	indstr = "";
	for (local i=0; i<indent-1; i++)
		indstr += "\t";

	baseString += indstr + predicateEnd;

	return baseString;
}

// -------------------------------VSLib-------------------------------------------------

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
//	集合管理事件函数，可以让多个脚本中同事件的函数调用顺序变得可控

::LinGe.Events <- {};
::LinGe.Events.trigger <- {}; // 触发表
getconsttable().ACTION_CONTINUE <- 0;
getconsttable().ACTION_RESETPARAMS <- 1;
getconsttable().ACTION_STOP <- 2;

// 绑定函数到事件 允许同一事件重复绑定同一函数
// event 为事件名 若以 OnGameEvent_ 开头则视为游戏事件
// callOf为函数执行时所在表，为null则不指定表
// last为真即插入到回调函数列表的最后，为否则插入到最前，越靠前的函数调用得越早
// 成功绑定则返回该事件当前绑定的函数数量
// func若为null则表明本次EventHook只是注册一下事件
::LinGe.Events.EventHook <- function (event, func=null, callOf=null, last=true)
{
	// 若该事件未注册则进行注册
	if (event == "callback")
		throw "事件名不能为 callback";

	if (!trigger.rawin(event))
	{
		trigger.rawset(event, { callback=[] });
		trigger[event][event] <- function (params)
		{
			local action = ACTION_CONTINUE;
			local _params = null==params ? null : clone params;
			local len = callback.len();
			local val = null;
			for (local i=0; i<len; i++)
			{
				val = callback[i];
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
					case null: // 若没有使用return返回数值 则为null
						break;
					case ACTION_CONTINUE:
						break;
					case ACTION_RESETPARAMS:
						_params = null==params ? null : clone params;
						break;
					case ACTION_STOP:
						return;
					default:
						throw "事件函数返回了非法的ACTION";
					}
				}
			}
		}.bindenv(trigger[event]);
		// trigger触发表中每个元素的key=事件名（用于查找），而每个元素的值都是一个table
		// 这个table中有一个事件函数，以事件名命名（用于注册与调用），以及一个key为callback的回调函数数组
		// 事件函数的所完成的就是依次调用同table下callback中所有函数
		// 没有把所有事件函数放在同一table下是为了让每个事件函数能快速找到自己的callback

		// 自动注册OnGameEvent_开头的游戏事件
		if (event.find("OnGameEvent_") == 0)
			__CollectEventCallbacks(trigger[event], "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);
	}

	local callback = trigger[event].callback;
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
		trigger[event].callback.remove(idx);
	return idx;
}.bindenv(::LinGe.Events);

// 查找函数在指定事件的函数表的索引
// 事件未注册返回-1 未找到函数返回-2
::LinGe.Events.EventIndex <- function (event, func, callOf=null, reverse=true)
{
	if (trigger.rawin(event))
	{
		local callback = trigger[event].callback;
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

::LinGe.Events.EventTrigger <- function (event, params=null, delay=0.0)
{
	if (trigger.rawin(event))
	{
		if (delay > 0.0)
			::VSLib.Timers.AddTimer(delay, false,
				@(params) ::LinGe.Events.trigger[event][event](params), params);
		else
			trigger[event][event](params);
	}
}.bindenv(::LinGe.Events);

::EventHook <- ::LinGe.Events.EventHook.weakref();
::EventUnHook <- ::LinGe.Events.EventUnHook.weakref();
::EventIndex <- ::LinGe.Events.EventIndex.weakref();
::EventTrigger <- ::LinGe.Events.EventTrigger.weakref();

// 只有具有FCVAR_NOTIFY flags的变量才会触发该事件
//::LinGe.Events.OnGameEvent_server_cvar <- function (params)
//{
//	EventTrigger("cvar_" + params.cvarname, params);
//}
//::EventHook("OnGameEvent_server_cvar", ::LinGe.Events.OnGameEvent_server_cvar, ::LinGe.Events);
// --------------------------事件回调函数注册END----------------------------------------

// ------------------------------Admin---START--------------------------------------
::LinGe.Admin <- {};
::LinGe.Admin.Config <- {
	enabled = true,
	takeOverAdminSystem = true, // 是否接管adminsystem的权限判断
	adminsFile = "linge/admins_simple.ini"
};
::LinGe.Config.Add("Admin", ::LinGe.Admin.Config);

::LinGe.Admin.cmdTable <- {}; // 指令表
// 读取管理员列表，若文件不存在则创建
::LinGe.Admin.adminslist <- FileToString(::LinGe.Admin.Config.adminsFile);
if (null == ::LinGe.Admin.adminslist)
{
	::LinGe.Admin.adminslist = "STEAM_1:0:64877973 // Homura Chan";
	StringToFile(::LinGe.Admin.Config.adminsFile, ::LinGe.Admin.adminslist);
	::LinGe.Admin.adminslist = FileToString(::LinGe.Admin.Config.adminsFile);
	if (null == ::LinGe.Admin.adminslist)
		printl("[LinGe] " + adminsFile + " 文件读取失败，无法获取管理员列表");
}

/*	添加指令 若同名指令会覆盖旧指令
	string	指令名
	func	指令回调函数
	callOf	回调函数执行所在的表
	isAdminCmd 是否是管理员指令
*/
::LinGe.Admin.CmdAdd <- function (command, func, callOf=null, isAdminCmd=true)
{
	local _callOf = (callOf==null) ? null : callOf.weakref();
	local table = { func=func.weakref(), callOf=_callOf, isAdminCmd=isAdminCmd };
	cmdTable.rawset(command, table);
}.bindenv(::LinGe.Admin);

// 删除指令 成功删除返回其值 否则返回null
::LinGe.Admin.CmdDelete <- function (command)
{
	return cmdTable.rawdelete(command);
}.bindenv(::LinGe.Admin);
::CmdAdd <- ::LinGe.Admin.CmdAdd.weakref();
::CmdDelete <- ::LinGe.Admin.CmdDelete.weakref();

// 消息指令触发 通过 InterceptChat
/*
::LinGe.Admin.InterceptChat <- function (str, srcEnt)
{
	if (null == srcEnt || !srcEnt.IsValid())
		return;
	// 去掉消息的前缀
	local name = srcEnt.GetPlayerName() + ": ";
	local args = strip(str.slice(str.find(name) + name.len()));
	// 按空格分割消息为参数列表
	args = split(args, " ");
	if (args[0].len() < 2)
		return;

	local firstChar = args[0].slice(0, 1); // 取第一个字符
	// 判断前缀有效性
	if (firstChar != "!"
	&& firstChar != "/"
	&& firstChar != "." )
		return;

	args[0] = args[0].slice(1); // 设置 args 第一个元素为指令名
	if (!cmdTable.rawin(args[0])) // 如果未找到指令则置为小写再进行一次查找
		args[0] = args[0].tolower();
	if (cmdTable.rawin(args[0]))
		CmdExec(args[0], srcEnt, args);
}.bindenv(::LinGe.Admin);
::VSLib.EasyLogic.AddInterceptChat(::LinGe.Admin.InterceptChat.weakref());
*/
// 消息指令触发 通过 player_say
::LinGe.Admin.OnGameEvent_player_say <- function (params)
{
	local args = split(params.text, " ");
	if (args[0].len() < 2)
		return;
	local player = GetPlayerFromUserID(params.userid);
	if (null == player || !player.IsValid())
		return;
	local firstChar = args[0].slice(0, 1); // 取第一个字符
	// 判断前缀有效性
	if (firstChar != "!"
	&& firstChar != "/"
	&& firstChar != "." )
		return;

	args[0] = args[0].slice(1); // 设置 args 第一个元素为指令名
	if (!cmdTable.rawin(args[0]))
		args[0] = args[0].tolower();
	if (cmdTable.rawin(args[0]))
		CmdExec(args[0], player, args);
}
::EventHook("OnGameEvent_player_say", ::LinGe.Admin.OnGameEvent_player_say, ::LinGe.Admin);

// scripted_user_func 指令触发
::LinGe.Admin.OnUserCommand <- function (vplayer, args, text)
{
	local _args = split(text, ",");
	local cmdstr = _args[0];
	local cmdTable = ::LinGe.Admin.cmdTable;
	if (!cmdTable.rawin(cmdstr))
		cmdstr = cmdstr.tolower();
	if (cmdTable.rawin(cmdstr))
		::LinGe.Admin.CmdExec(cmdstr, vplayer._ent, _args);
}
::EasyLogic.OnUserCommand.LinGeCommands <- ::LinGe.Admin.OnUserCommand.weakref();

// 指令调用执行
::LinGe.Admin.CmdExec <- function (command, player, args)
{
	local cmd = cmdTable[command];
	if (cmd.isAdminCmd && !IsAdmin(player))
	{	// 如果是管理员指令而用户身份不是管理员，则发送权限不足提示
		ClientPrint(player, 3, "\x04此条指令仅管理员可用！");
		return;
	}

	if (cmd.callOf != null)
		cmd.func.call(cmd.callOf, player, args);
	else
		cmd.func(player, args);
}

// 判断该玩家是否是管理员
::LinGe.Admin.IsAdmin <- function (player)
{
	// 未启用权限管理则所有人视作管理员
	if (!Config.enabled)
		return true;
	// 如果是单人游戏则直接返回true
	if (Director.IsSinglePlayerGame())
		return true;
	// 获取steam id
	local steamID = null;
	local vplayer = player;
	if (typeof vplayer != "VSLIB_PLAYER")
		vplayer = ::VSLib.Player(player);
	if ( vplayer.IsServerHost() )
		return true;
	steamID = vplayer.GetSteamID();
	if (null == steamID)
		return false;

	// 通过steamID判断是否是管理员
	if (null != adminslist)
	{
		if (null == adminslist.find(steamID))
			return false;
		else
			return true;
	}
	else
		return false;
}.bindenv(::LinGe.Admin);

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

::LinGe.Admin.Cmd_setvalue <- function (player, args)
{
	if (args.len() == 3)
		Convars.SetValue(args[1], args[2]);
}
::CmdAdd("setvalue", ::LinGe.Admin.Cmd_setvalue, ::LinGe.Admin);

::LinGe.Admin.Cmd_getvalue <- function (player, args)
{
	if (args.len() == 2)
		ClientPrint(player, 3, Convars.GetStr(args[1]));
}
::CmdAdd("getvalue", ::LinGe.Admin.Cmd_getvalue, ::LinGe.Admin);
//----------------------------Admin-----END---------------------------------

//------------------------------Cache---------------------------------------
::LinGe.Cache <- { isValidCache=false }; // isValidCache指定是否是有效Cache 数据无效时不恢复
::Cache <- ::LinGe.Cache.weakref();

::LinGe.VSLibScriptStart_post <- function (params)
{
	CacheRestore();
}
::EventHook("VSLibScriptStart_post", ::LinGe.VSLibScriptStart_post, ::LinGe);

::LinGe.ScriptMode_OnShutdown_pre <- function (params)
{
	CacheSave();
}
::EventHook("ScriptMode_OnShutdown_pre", ::LinGe.ScriptMode_OnShutdown_pre, ::LinGe);

::LinGe.CacheRestore <- function ()
{
	local temp = {};
	local _params = { isValidCache=false };
	RestoreTable("LinGe_Cache", temp);
	if (temp.rawin("isValidCache"))
	{
		if (temp.isValidCache)
		{
			::Merge(Cache, temp);
			Cache.rawset("isValidCache", false); // 开局时保存一个Cache 并且设置为无效
			SaveTable("LinGe_Cache", Cache);
			_params.isValidCache = true;
		}
	}
	Cache.rawset("isValidCache", _params.isValidCache);
	::EventTrigger("cache_restore", _params);
}

::LinGe.CacheSave <- function ()
{
	Cache.rawset("isValidCache", true);
	SaveTable("LinGe_Cache", Cache);
	::EventTrigger("cache_save");
}


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

::LinGe.Base.GetHumans <- function ()
{
	return ::pyinfo.ob + ::pyinfo.survivor + ::pyinfo.special;
}

// 事件：回合开始
::LinGe.Base.OnGameEvent_round_start <- function (params)
{
	// 当前关卡重开的话，脚本会被重新加载，玩家数据会被清空
	// 而重开情况下玩家的队伍不会发生改变，不会触发事件
	// 所以需要开局时搜索玩家
	InitPyinfo();
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
	local steamid = player.GetNetworkIDString();
	// 使用插件等方式加入bot时，params.isbot不准确
	// 应获取其SteamID进行判断
	if ("BOT" == steamid)
		return;

	// 触发真实玩家变更事件
	local _params = clone params;
	_params.player <- player;
	_params.steamid <- steamid;
	// 使用插件等方式改变阵营的时候，可能导致 params.name 为空
	// 通过GetPlayerName重新获取会比较稳定
	_params.name <- player.GetPlayerName();
	_params.entityIndex <- player.GetEntityIndex();
	::EventTrigger("human_team", _params, 0.1); // 延时0.1s触发
}
::EventHook("OnGameEvent_player_team", ::LinGe.Base.OnGameEvent_player_team, ::LinGe.Base);

::LinGe.Base.human_team <- function (params)
{
	UpdateMaxplayers();

	local text = "\x03" + params.name + "\x04 ";
	switch (params.oldteam)
	{
	case 0: break;
	case 1:	::pyinfo.ob--; break;
	case 2:	::pyinfo.survivor--; break;
	case 3:	::pyinfo.special--; break;
	default: throw "未知情况发生";
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
		case 1:
			::pyinfo.ob++;
			if (IsPlayerIdle(params.entityIndex))
				text += "已闲置";
			else
				text += "加入了旁观者";
			break;
		case 2: ::pyinfo.survivor++; text += "加入了生还者"; break;
		case 3: ::pyinfo.special++; text += "加入了感染者"; break;
		default: throw "意外情况";
		}
	}

	local idx = ::pyinfo.survivorIdx.find(params.entityIndex);
	// 如果是离开或者加入特感就将其从生还者实体索引数组删除
	// 如果是加入生还者就将其索引加入
	if ( (params.disconnect || 3 == params.team)
	&& null != idx )
		::pyinfo.survivorIdx.remove(idx);
	else if ( (2 == params.team)
	&& null == idx)
		::pyinfo.survivorIdx.append(params.entityIndex);

	if (Config.isShowTeamChange)
		ClientPrint(null, 3, text);

	// 对抗模式下经常出现队伍人数错误 不知道是否是药抗插件的问题
	if (::LinGe.Debug && ::isVersus)
	{
		printl(params.name + ": " + params.oldteam + " -> " + params.team);
		printl("now:ob=" + ::pyinfo.ob + ", survivor=" + ::pyinfo.survivor + ", special=" + ::pyinfo.special);
	}
}
::EventHook("human_team", LinGe.Base.human_team, LinGe.Base);

::LinGe.Base.Cmd_teaminfo <- function (player, args)
{
	if (1 == args.len())
	{
		Config.isShowTeamChange = !Config.isShowTeamChange;
		local text = Config.isShowTeamChange ? "开启" : "关闭";
		ClientPrint(null, 3, "\x04服务器已" + text + "队伍更换提示");
	}
}
::CmdAdd("teaminfo", ::LinGe.Base.Cmd_teaminfo, ::LinGe.Base);

// 搜索玩家
::LinGe.Base.InitPyinfo <- function ()
{
	UpdateMaxplayers();

	local player = null; // 玩家实例
	local table = ::pyinfo;
	// 通过类名查找玩家
	while ( player = Entities.FindByClassname(player, "player") )
	{
		// 判断搜索到的实体有效性
		if ( player.IsValid() )
		{
			// 判断阵营
			if ("BOT" == player.GetNetworkIDString())
				continue;
			switch (GetPlayerTeam(player))
			{
			case 1:
				table.ob++;
				break;
			case 2:
				table.survivor++;
				table.survivorIdx.append(player.GetEntityIndex());
				break;
			case 3:
				table.special++;
				break;
			}
		}
	}
}

::LinGe.Base.UpdateMaxplayers <- function ()
{
	if (isExistMaxplayers)
	{
		local old = ::pyinfo.maxplayers;
		::pyinfo.maxplayers = Convars.GetFloat("sv_maxplayers");
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
		if (old != ::pyinfo.maxplayers)
			::EventTrigger("maxplayers_changed");
	}
}
//----------------------------Base-----END---------------------------------