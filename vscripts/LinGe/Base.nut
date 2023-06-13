// By LinGe https://github.com/Lin515/L4D2_LinGe_VScripts
// 本系列脚本编写主要参考以下文档
// L4D2脚本函数清单：https://developer.valvesoftware.com/wiki/L4D2%E8%84%9A%E6%9C%AC%E5%87%BD%E6%95%B0%E6%B8%85%E5%8D%95
// L4D2 EMS/Appendix：HUD：https://developer.valvesoftware.com/wiki/L4D2_EMS/Appendix:_HUD
// L4D2 Events：https://wiki.alliedmods.net/Left_4_Dead_2_Events
// 以及VSLib与admin_system的脚本源码
printl("[LinGe] Base 正在载入");
::LinGe <- {};
::LinGe.Debug <- false;

::LinGe.hostport <- Convars.GetFloat("hostport").tointeger();
printl("[LinGe] 当前服务器端口 " + ::LinGe.hostport);

// ---------------------------全局函数START-------------------------------------------
// 主要用于调试
::LinGe.DebugPrintl <- function (str)
{
	if (::LinGe.Debug)
		printl(str);
}

::LinGe.DebugPrintlTable <- function (table)
{
	if (!::LinGe.Debug)
		return;
	if (typeof table != "table" && typeof table != "array")
		return;
	foreach (key, val in table)
		print(key + "=" + val + " ; ");
	print("\n");
}

// 尝试将一个字符串转换为int类型 eValue为出现异常时返回的值
::LinGe.TryStringToInt <- function (value, eValue=0)
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
::LinGe.TryStringToFloat <- function (value, eValue=0.0)
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

// 查找并移除找到的第一个元素 返回其索引，若未找到则返回null
::LinGe.RemoveInArray <- function (value, array)
{
	local idx = array.find(value);
	if (null != idx)
		array.remove(idx);
	return idx;
}

// 当前模式是否是对抗模式
::LinGe.CheckVersus <- function ()
{
	if (Director.GetGameMode() == "mutation15") // 生还者对抗
		return true;
	if ("versus" == g_BaseMode)
		return true;
	if ("scavenge" == g_BaseMode)
		return true;
	return false;
}
::LinGe.isVersus <- ::LinGe.CheckVersus();

// 设置某类下所有已生成实体的KeyValue
::LinGe.SetKeyValueByClassname <- function (className, key, value)
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

::LinGe.SteamIDCastUniqueID <- function (steamid)
{
	local uniqueID = ::VSLib.Utils.StringReplace(steamid, "STEAM_1:", "S");
	uniqueID = ::VSLib.Utils.StringReplace(uniqueID, "STEAM_0:", "S");
	uniqueID = ::VSLib.Utils.StringReplace(uniqueID, ":", "");
	return uniqueID;
}

// 获取 targetname，并确保它在本脚本系统中独一无二
::LinGe.GetEntityTargetname <- function (entity)
{
	local targetname = entity.GetName();
	if (targetname.find("LinGe_") != 0)
	{
		targetname = "LinGe_" + UniqueString();
		entity.__KeyValueFromString("targetname", targetname);
	}
	return targetname;
}

// 通过userid获得玩家实体索引
::LinGe.GetEntityIndexFromUserID <- function (userid)
{
	local entity = GetPlayerFromUserID(userid);
	if (null == entity)
		return null;
	else
		return entity.GetEntityIndex();
}

// 通过userid获得steamid
::LinGe.GetSteamIDFromUserID <- function (userid)
{
	local entity = GetPlayerFromUserID(userid);
	if (null == entity)
		return null;
	else
		return entity.GetNetworkIDString();
}

// 该userid是否为BOT所有
::LinGe.IsBotUserID <- function (userid)
{
	local entity = GetPlayerFromUserID(userid);
	if (null == entity)
		return true;
	else
		return "BOT"==entity.GetNetworkIDString();
}

::LinGe.GetReviveCount <- function (player)
{
	return NetProps.GetPropInt(player, "m_currentReviveCount");
}

// 从网络属性判断一个实体是否存活
::LinGe.IsAlive <- function (ent)
{
	return NetProps.GetPropInt(ent, "m_lifeState") == 0;
}

// 从bot生还者中获取其就位的生还者玩家实体
// 须自己先检查是否是有效生还者bot 否则可能出错
::LinGe.GetHumanPlayer <- function (bot)
{
	if (::LinGe.IsAlive(bot))
	{
		local human = GetPlayerFromUserID(NetProps.GetPropInt(bot, "m_humanSpectatorUserID"));
		if (null != human)
		{
			if (human.IsValid())
			{
				if ( "BOT" != human.GetNetworkIDString()
				&& 1 == ::LinGe.GetPlayerTeam(human) )
					return human;
			}
		}
	}
	return null;
}

// 判断玩家是否处于闲置 参数可以是玩家实体也可以是实体索引
::LinGe.IsPlayerIdle <- function (player)
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
	if (1 != ::LinGe.GetPlayerTeam(_player))
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
			&& ::LinGe.IsAlive(bot) )
			{
				local human = ::LinGe.GetHumanPlayer(bot);
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

// 获取所有处于闲置的玩家
::LinGe.GetIdlePlayers <- function ()
{
	local bot = null;
	local players = [];
	while ( bot = Entities.FindByClassname(bot, "player") )
	{
		if ( bot.IsValid() )
		{
			if ( bot.IsSurvivor()
			&& "BOT" == bot.GetNetworkIDString()
			&& ::LinGe.IsAlive(bot) )
			{
				local human = ::LinGe.GetHumanPlayer(bot);
				if (human != null)
				{
					players.push(human);
				}
			}
		}
	}
	return players;
}

::LinGe.GetIdlePlayerCount <- function ()
{
	local bot = null;
	local count = 0;
	while ( bot = Entities.FindByClassname(bot, "player") )
	{
		if ( bot.IsValid() )
		{
			if ( bot.IsSurvivor()
			&& "BOT" == bot.GetNetworkIDString()
			&& ::LinGe.IsAlive(bot) )
			{
				local human = ::LinGe.GetHumanPlayer(bot);
				if (human != null)
				{
					count++;
				}
			}
		}
	}
	return count;
}

::LinGe.GetMaxHealth <- function (entity)
{
	return NetProps.GetPropInt(victim, "m_iMaxHealth");
}

::LinGe.GetPlayerTeam <- function (player)
{
	return NetProps.GetPropInt(player, "m_iTeamNum");
}

// 将 Vector 转换为 QAngle
// hl2sdk-l4d2/mathlib/mathlib_base.cpp > line:506
::LinGe.QAngleFromVector <- function (forward)
{
	local tmp, yaw, pitch;

	if (forward.y == 0 && forward.x == 0)
	{
		yaw = 0;
		if (forward.z > 0)
			pitch = 270;
		else
			pitch = 90;
	}
	else
	{
		yaw = (atan2(forward.y, forward.x) * 180 / PI);
		if (yaw < 0)
			yaw += 360;

		tmp = sqrt(forward.x*forward.x + forward.y*forward.y);
		pitch = (atan2(-forward.z, tmp) * 180 / PI);
		if (pitch < 0)
			pitch += 360;
	}
	return QAngle(pitch, yaw, 0.0);
}

// 玩家是否看着实体的位置或指定位置
// VSLib/player.nut > line:1381 function VSLib::Player::CanSeeLocation
::LinGe.IsPlayerSeeHere <- function (player, location, tolerance = 50)
{
	local _location = null;
	if (typeof location == "instance")
		_location = location.GetOrigin();
	else if (typeof location == "Vector")
		_location = location;
	else
		throw "location 参数类型非法";

	local clientPos = player.EyePosition();
	local clientToTargetVec = _location - clientPos;
	local clientAimVector = player.EyeAngles().Forward();

	local angToFind = acos(
			::VSLib.Utils.VectorDotProduct(clientAimVector, clientToTargetVec)
			/ (clientAimVector.Length() * clientToTargetVec.Length())
		) * 360 / 2 / 3.14159265;

	if (angToFind < tolerance)
		return true;
	else
		return false;
}

::LinGe.TraceToLocation <- function (origin, location, mask=MASK_SHOT_HULL & (~CONTENTS_WINDOW), ignore=null)
{
	// 获取出发点
	local start = null;
	if (typeof origin == "instance")
	{
		if ("EyePosition" in origin)
			start = origin.EyePosition(); // 如果对象是有眼睛的则获取眼睛位置
		else
			start = origin.GetOrigin();
	}
	else if (typeof origin == "Vector")
		start = origin;
	else
		throw "origin 参数类型非法";

	// 获取终点
	local end = null;
	if (typeof location == "instance")
	{
		if ("EyePosition" in location)
			end = location.EyePosition();
		else
			end = location.GetOrigin();
	}
	else if (typeof location == "Vector")
		end = location;
	else
		throw "location 参数类型非法";

	local tr = {
		start = start,
		end =  end,
		ignore = (ignore ? ignore : (typeof origin == "instance" ? origin : null) ),
		mask = mask,
	};
	TraceLine(tr);
	return tr;
}

// player 是否注意着 entity
::LinGe.IsPlayerNoticeEntity <- function (player, entity, tolerance = 50, mask=MASK_SHOT_HULL & (~CONTENTS_WINDOW), radius=0.0)
{
	if (!IsPlayerSeeHere(player, entity, tolerance))
		return false;
	local tr = TraceToLocation(player, entity, mask);
	if (tr.rawin("enthit") && tr.enthit == entity)
		return true;
	if (radius <= 0.0)
		return false;
	// 如果不能看到指定实体，但指定了半径范围，则进行搜索
	local _entity = null, className = entity.GetClassname();
	while ( _entity = Entities.FindByClassnameWithin(_entity, className, tr.pos, radius) )
	{
		if (_entity == entity)
			return true;
	}
	return false;
}

// 链式射线追踪，当命中到类型为 ignoreClass 中的实体时，从其位置往前继续射线追踪
// ignoreClass 中可以有 entity 的类型，判断时总会先判断定位到的是否是 entity
// 如果最终能命中 entity，则返回 true
::LinGe.ChainTraceToEntity <- function (origin, entity, mask, ignoreClass, limit=4)
{
	local tr = {
		start = null,
		end = null,
		ignore = null,
		mask = mask,
	};

	// 获取起始点
	if (typeof origin == "instance")
	{
		if ("EyePosition" in origin)
			tr.start = origin.EyePosition();
		else
			tr.start = origin.GetOrigin();
		tr.ignore = origin;
	}
	else if (typeof origin == "Vector")
		tr.start = origin;
	else
		throw "origin 参数类型非法";

	if ("EyePosition" in entity)
		tr.end = entity.EyePosition();
	else
		tr.end = entity.GetOrigin();
	if (limit < 1)
		limit = 4; // 不允许无限制的链式探测
	local start = tr.start; // 保留最初的起点

	local count = 0;
	while (true)
	{
		count++;
		TraceLine(tr);
		if (!tr.rawin("enthit"))
			break;
		if (tr.enthit == entity)
			return true;
		if (count >= limit)
			break;
		// 如果命中位置已经比目标位置要更远离起始点，则终止
		if ((tr.pos-start).Length() > (tr.end-start).Length())
			break;
		if (ignoreClass.find(tr.enthit.GetClassname()) == null)
			break;
		tr.start = tr.pos;
		tr.ignore = tr.enthit;
	}
	return false;
}

// 获取玩家实体数组
// team 指定要获取的队伍 可以是数组或数字 若为null则忽略队伍
// humanOrBot 机器人 0:忽略是否是机器人 1:只获取玩家 2:只获取BOT
// aliveOrDead 存活 0:忽略是否存货 1:只获取存活的 2:只获取死亡的
::LinGe.GetPlayers <- function (team=null, humanOrBot=0, aliveOrDead=0)
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
			if (typeof team == "array")
			{
				if (team.find(::LinGe.GetPlayerTeam(player))==null)
					continue;
			}
			else if (typeof team == "integer" && team != ::LinGe.GetPlayerTeam(player))
				continue;
			if (humanOrBot == 1)
			{
				if ("BOT" == player.GetNetworkIDString())
					continue;
			}
			else if (humanOrBot == 2 && "BOT" != player.GetNetworkIDString())
				continue;
			if (aliveOrDead == 1)
			{
				if (!::LinGe.IsAlive(player))
					continue;
			}
			else if (aliveOrDead == 2 && ::LinGe.IsAlive(player))
				continue;
			arr.append(player);
		}
	}
	return arr;
}
::LinGe.GetPlayerCount <- function (team=null, humanOrBot=0, aliveOrDead=0)
{
	local count = 0;
	// 通过类名查找玩家
	local player = null;
	while ( player = Entities.FindByClassname(player, "player") )
	{
		// 判断搜索到的实体有效性
		if ( player.IsValid() )
		{
			// 判断阵营
			if (typeof team == "array")
			{
				if (team.find(::LinGe.GetPlayerTeam(player))==null)
					continue;
			}
			else if (typeof team == "integer" && team != ::LinGe.GetPlayerTeam(player))
				continue;
			if (humanOrBot == 1)
			{
				if ("BOT" == player.GetNetworkIDString())
					continue;
			}
			else if (humanOrBot == 2 && "BOT" != player.GetNetworkIDString())
				continue;
			if (aliveOrDead == 1)
			{
				if (!::LinGe.IsAlive(player))
					continue;
			}
			else if (aliveOrDead == 2 && ::LinGe.IsAlive(player))
				continue;
			count++;
		}
	}
	return count;
}

// 如果source中某个key在dest中也存在，则将其赋值给dest中的key
// 如果 reserveKey 为 true，则dest中没用该key也会被赋值
// key无视大小写
::LinGe.Merge <- function (dest, source, typeMatch=true, reserveKey=false)
{
	if ("table" == typeof dest && "table" == typeof source)
	{
		foreach (key, val in source)
		{
			local keyIsExist = true;
			if (!dest.rawin(key))
			{
				// 为什么有些保存到 Cache 会产生大小写转换？？
				// HUD.Config.hurt 保存到 Cache 恢复后，hurt 居然变成了 Hurt
				foreach (_key, _val in dest)
				{
					if (_key.tolower() == key.tolower())
					{
						source[_key] <- source[key];
						key = _key;
						break;
					}
				}
				if (!dest.rawin(key))
					keyIsExist = false;
			}
			if (!keyIsExist)
			{
				if (reserveKey)
					dest.rawset(key, val);
				continue;
			}
			local type_dest = typeof dest[key];
			local type_src = typeof val;
			// 如果指定key也是table，则进行递归
			if ("table" == type_dest && "table" == type_src)
				::LinGe.Merge(dest[key], val, typeMatch, reserveKey);
			else if (type_dest != type_src)
			{
				if (!typeMatch)
					dest[key] = val;
				else if (type_dest == "bool" && type_src == "integer") // 争对某些情况下 bool 被转换成了 integer
					dest[key] = (val!=0);
				else if (type_dest == "array" && type_src == "table") // 争对某些情况下 array 被转换成了 table 原数组的顺序可能会错乱
				{
					dest[key].clear();
					foreach (_val in val)
						dest[key].append(_val);
				}
			}
			else
				dest[key] = val;
		}
	}
}
// ---------------------------全局函数END-------------------------------------------

// -------------------------------VSLib 改写-------------------------------------------------
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

// ---------------------------CONFIG-配置管理---------------------------------------
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
	function Add(tableName, _table, reserveKey=false)
	{
		table.rawset(tableName, _table.weakref());
		Load(tableName, reserveKey);
	}

	// 从配置管理中删除表
	function Delete(tableName)
	{
		table.rawdelete(tableName);
	}
	// 载入指定表的配置
	// reserveKey为false时，配置载入只会载入已创建的key，配置文件中有但脚本代码未创建的key不会被载入
	// 反之则配置文件中的key会被保留
	function Load(tableName, reserveKey=false)
	{
		if (!table.rawin(tableName))
			throw "未找到表";
		local fromFile = null;
		try {
			fromFile = ::VSLib.FileIO.LoadTable(filePath);
		} catch (e)	{
			printl("[LinGe] 服务器配置文件损坏，将自动还原为默认设置");
			fromFile = null;
		}
		if (null != fromFile && fromFile.rawin(tableName))
		{
			::LinGe.Merge(table[tableName], fromFile[tableName], true, reserveKey);
		}
		Save(tableName); // 保持文件配置和已载入配置的一致性
	}
	// 保存指定表的配置
	function Save(tableName)
	{
		if (table.rawin(tableName))
		{
			local fromFile = null;
			try {
				fromFile = ::VSLib.FileIO.LoadTable(filePath);
			} catch (e) {
				fromFile = null;
			}
			if (null == fromFile)
				fromFile = {};
			fromFile.rawset(tableName, table[tableName]);
			::VSLib.FileIO.SaveTable(filePath, fromFile);
		}
		else
			throw "未找到表";
	}

	// 载入所有表
	function LoadAll(reserveKey=false)
	{
		local fromFile = ::VSLib.FileIO.LoadTable(filePath);
		if (null != fromFile)
			::LinGe.Merge(table, fromFile, true, reserveKey);
		SaveAll();
	}
	// 保存所有表
	function SaveAll()
	{
		local fromFile = ::VSLib.FileIO.LoadTable(filePath);
		foreach (k, v in table)
			fromFile.rawset(k, v);
		::VSLib.FileIO.SaveTable(filePath, fromFile);
	}
};

local FILE_CONFIG = "LinGe/Config_" + ::LinGe.hostport;
::LinGe.Config <- ::LinGe.ConfigManager(FILE_CONFIG);
// ---------------------------CONFIG-配置管理END-----------------------------------------

// -----------------------事件回调函数注册START--------------------------------------
//	集合管理事件函数，可以让多个脚本中同事件的函数调用顺序变得可控

::LinGe.Events <- {};
::LinGe.Events.trigger <- {}; // 触发表
::ACTION_CONTINUE <- 0;
::ACTION_RESETPARAMS <- 1;
::ACTION_STOP <- 2;

::LinGe.Events.TriggerFunc <- function (params)
{
	local action = ACTION_CONTINUE;
	local _params = null==params ? null : clone params;
	local len = callback.len();
	local val = null;
	::LinGe.DebugPrintlTable(params);
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
}
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
		trigger[event][event] <- TriggerFunc.bindenv(trigger[event]);
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

::LinEventHook <- ::LinGe.Events.EventHook.weakref();
::LinEventUnHook <- ::LinGe.Events.EventUnHook.weakref();
::LinEventIndex <- ::LinGe.Events.EventIndex.weakref();
::LinEventTrigger <- ::LinGe.Events.EventTrigger.weakref();

// 只有具有FCVAR_NOTIFY flags的变量才会触发该事件
//::LinGe.Events.OnGameEvent_server_cvar <- function (params)
//{
//	EventTrigger("cvar_" + params.cvarname, params);
//}
//::LinEventHook("OnGameEvent_server_cvar", ::LinGe.Events.OnGameEvent_server_cvar, ::LinGe.Events);
// --------------------------事件回调函数注册END----------------------------------------

// ------------------------------Admin---START--------------------------------------
::LinGe.Admin <- {};
::LinGe.Admin.Config <- {
	enabled = false,
	takeOverAdminSystem = false, // 是否接管adminsystem的权限判断
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
::LinGe.Admin.CmdAdd <- function (command, func, callOf=null, remarks="", isAdminCmd=true, ignoreCase=true)
{
	local _callOf = (callOf==null) ? null : callOf.weakref();
	local table = { func=func.weakref(), callOf=_callOf, remarks=remarks, isAdminCmd=isAdminCmd, ignoreCase=ignoreCase };
	cmdTable.rawset(command.tolower(), table);
}.bindenv(::LinGe.Admin);

// 删除指令 成功删除返回其值 否则返回null
::LinGe.Admin.CmdDelete <- function (command)
{
	return cmdTable.rawdelete(command.tolower());
}.bindenv(::LinGe.Admin);
::LinCmdAdd <- ::LinGe.Admin.CmdAdd.weakref();
::LinCmdDelete <- ::LinGe.Admin.CmdDelete.weakref();

// 消息指令触发 通过 player_say
::LinGe.Admin.OnGameEvent_player_say <- function (params)
{
	local args = split(params.text, " ");
	local cmd = args[0];
	if (cmd.len() < 2)
		return;
	local player = GetPlayerFromUserID(params.userid);
	if (null == player || !player.IsValid())
		return;
	local firstChar = cmd.slice(0, 1); // 取第一个字符
	// 判断前缀有效性
	if (firstChar != "!"
	&& firstChar != "/"
	&& firstChar != "." )
		return;

	local text = params.text.slice(1);
	args = split(text, " ");
	cmd = args[0].tolower(); // 设置 args 第一个元素为指令名
	if (cmdTable.rawin(cmd))
	{
		if (cmdTable[cmd].ignoreCase)
			CmdExec(cmd, player, split(text.tolower(), " "));
		else
			CmdExec(cmd, player, args);
	}
}
::LinEventHook("OnGameEvent_player_say", ::LinGe.Admin.OnGameEvent_player_say, ::LinGe.Admin);

// scripted_user_func 指令触发
::LinGe.Admin.OnUserCommand <- function (vplayer, args, text)
{
	local _args = split(text, ",");
	local cmdstr = _args[0].tolower();
	local cmdTable = ::LinGe.Admin.cmdTable;
	if (cmdTable.rawin(cmdstr))
	{
		if (cmdTable[cmdstr].ignoreCase)
			::LinGe.Admin.CmdExec(cmdstr, vplayer._ent, split(text.tolower(), ","));
		else
			::LinGe.Admin.CmdExec(cmdstr, vplayer._ent, _args);
	}
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
::LinEventHook("OnGameEvent_round_start", ::LinGe.Admin.OnGameEvent_round_start, ::LinGe.Admin);

::LinGe.Admin.Cmd_setvalue <- function (player, args)
{
	if (args.len() == 3)
		Convars.SetValue(args[1], args[2]);
}
::LinCmdAdd("setvalue", ::LinGe.Admin.Cmd_setvalue, ::LinGe.Admin);

::LinGe.Admin.Cmd_getvalue <- function (player, args)
{
	if (args.len() == 2)
		ClientPrint(player, 3, Convars.GetStr(args[1]));
}
::LinCmdAdd("getvalue", ::LinGe.Admin.Cmd_getvalue, ::LinGe.Admin);

::LinGe.Admin.Cmd_saveconfig <- function (player, args)
{
	if (args.len() == 1)
	{
		::LinGe.Config.SaveAll();
		ClientPrint(player, 3, "\x04已保存当前功能设定为默认设定\n");
		ClientPrint(player, 3, "\x04配置文件: \x05 left4dead2/ems/" + FILE_CONFIG + ".tbl");
	}
	else if (args.len() == 2)
	{
		foreach (name, tbl in ::LinGe.Config.table)
		{
			if (name.tolower() == args[1])
			{
				::LinGe.Config.Save(name);
				ClientPrint(player, 3, "\x04已保存当前功能设定为默认设定: \x05" + name);
				ClientPrint(player, 3, "\x04配置文件: \x05 left4dead2/ems/" + FILE_CONFIG + ".tbl");
				return;
			}
		}
		ClientPrint(player, 3, "\x04未找到 \x05" + args[1]);
	}
}
::LinCmdAdd("saveconfig", ::LinGe.Admin.Cmd_saveconfig, ::LinGe.Admin);
::LinCmdAdd("save", ::LinGe.Admin.Cmd_saveconfig, ::LinGe.Admin, "保存配置到配置文件");

::LinGe.Admin.Cmd_lshelp <- function (player, args)
{
	foreach (key, val in cmdTable)
	{
		if (val.remarks != "")
			ClientPrint(player, 3, format("\x05!%s \x03%s", key, val.remarks));
	}
}
::LinCmdAdd("lshelp", ::LinGe.Admin.Cmd_lshelp, ::LinGe.Admin, "", false);

::LinGe.Admin.Cmd_config <- function (player, args)
{
	if (args.len() == 2)
	{
		local func = compilestring("return ::LinGe.Config.table." + args[1]);
		try {
			ClientPrint(player, 3, "\x04" + args[1] + " = \x05" + func());
		} catch (e) {
			ClientPrint(player, 3, "\x04读取配置失败： \x05" + args[1]);
		}
	}
	else if (args.len() >= 3)
	{
		try {
			local type = compilestring("return typeof ::LinGe.Config.table." + args[1])();
			switch (type)
			{
			case "bool":
			case "integer":
			case "float":
				compilestring("::LinGe.Config.table." + args[1] + " = " + args[2])();
				break;
			case "string":
			{
				local str = "";
				for (local i=2; i<args.len(); i++)
				{
					if (i != 2)
						str += " ";
					str += args[i];
				}
				compilestring("::LinGe.Config.table." + args[1] + " = \"" + str + "\"")();
				break;
			}
			default:
				ClientPrint(player, 3, "\x04不支持设置该类数据： \x05" + type);
				return;
			}
		} catch (e) {
			ClientPrint(player, 3, "\x04设置配置失败： \x05" + args[1]);
			return;
		}
		ClientPrint(player, 3, "\x04配置修改成功");
	}
	else
	{
		ClientPrint(player, 3, "\x05!config [配置项目] [修改值]");
		ClientPrint(player, 3, "\x05例：!config HUD.textHeight2 0.03 不过针对不同的配置项目，修改后可能不能立即产生效果");
	}
}
::LinCmdAdd("config", ::LinGe.Admin.Cmd_config, ::LinGe.Admin, "", true, false);

// 开启Debug模式
::LinGe.Admin.Cmd_lsdebug <- function (player, args)
{
	if (args.len() == 2)
	{
		if (args[1] == "on")
		{
			::LinGe.Debug = true;
			Convars.SetValue("display_game_events", 1);
			Convars.SetValue("ent_messages_draw", 1);
		}
		else if (args[1] == "off")
		{
			::LinGe.Debug = false;
			Convars.SetValue("display_game_events", 0);
			Convars.SetValue("ent_messages_draw", 0);
		}
	}
}
::LinCmdAdd("lsdebug", ::LinGe.Admin.Cmd_lsdebug, ::LinGe.Admin);
//----------------------------Admin-----END---------------------------------

//------------------------------LinGe.Cache---------------------------------------
::LinGe.Cache <- { isValidCache=false }; // isValidCache指定是否是有效Cache 数据无效时不恢复

::LinGe.OnGameEvent_round_start_post_nav <- function (params)
{
	CacheRestore();
	// 以下事件应插入到最后
	::LinEventHook("OnGameEvent_round_end", ::LinGe.OnGameEvent_round_end, ::LinGe);
	::LinEventHook("OnGameEvent_map_transition", ::LinGe.OnGameEvent_round_end, ::LinGe);
}
// 如果后续插入了排序在本事件之前的回调，那么该回调中不应访问cache
::LinEventHook("OnGameEvent_round_start_post_nav", ::LinGe.OnGameEvent_round_start_post_nav, ::LinGe, false);

::LinGe.OnGameEvent_round_end <- function (params)
{
	CacheSave();
}

::LinGe.CacheRestore <- function ()
{
	local temp = {};
	local _params = { isValidCache=false };
	RestoreTable("LinGe_Cache", temp);
	if (temp.rawin("isValidCache"))
	{
		if (temp.isValidCache)
		{
			::LinGe.Merge(Cache, temp, true, true);
			Cache.rawset("isValidCache", false); // 开局时保存一个Cache 并且设置为无效
			SaveTable("LinGe_Cache", Cache);
			_params.isValidCache = true;
		}
	}
	Cache.rawset("isValidCache", _params.isValidCache);
	::LinEventTrigger("cache_restore", _params);
}

::LinGe.CacheSave <- function ()
{
	Cache.rawset("isValidCache", true);
	SaveTable("LinGe_Cache", Cache);
	::LinEventTrigger("cache_save");
}


//----------------------------Base-----START--------------------------------
::LinGe.Base <- {};
::LinGe.Base.Config <- {
	isShowTeamChange = false,
	recordPlayerInfo = false
};
::LinGe.Config.Add("Base", ::LinGe.Base.Config);
::LinGe.Cache.Base_Config <- ::LinGe.Base.Config;

// 已知玩家列表 存储加入过服务器玩家的SteamID与名字
const FILE_KNOWNPLAYERS = "LinGe/playerslist";
::LinGe.Base.known <- { };
::LinGe.Base.knownManager <- ::LinGe.ConfigManager(FILE_KNOWNPLAYERS);
::LinGe.Base.knownManager.Add("playerslist", ::LinGe.Base.known, true);

// 玩家信息
::LinGe.Base.info <- {
	maxplayers = 0, // 最大玩家数量
	survivor = 0, // 生还者玩家数量
	special = 0, // 特感玩家数量
	ob = 0, // 旁观者玩家数量
	survivorIdx = [] // 生还者实体索引
};
::pyinfo <- ::LinGe.Base.info.weakref();

::LinGe.Base.GetHumans <- function ()
{
	return ::pyinfo.ob + ::pyinfo.survivor + ::pyinfo.special;
}

local isExistMaxplayers = true;
// 事件：回合开始
::LinGe.Base.OnGameEvent_round_start <- function (params)
{
	// 当前关卡重开的话，脚本会被重新加载，玩家数据会被清空
	// 而重开情况下玩家的队伍不会发生改变，不会触发事件
	// 所以需要开局时搜索玩家
	InitPyinfo();

	if (Convars.GetFloat("sv_maxplayers") != null)
		::VSLib.Timers.AddTimer(1.0, true, ::LinGe.Base.UpdateMaxplayers);
	else
		isExistMaxplayers = false;
}
::LinEventHook("OnGameEvent_round_start", ::LinGe.Base.OnGameEvent_round_start, ::LinGe.Base);

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

	if (Config.recordPlayerInfo)
	{
		local uniqueID = ::LinGe.SteamIDCastUniqueID(params.networkid);
		if (uniqueID != "S00")
		{
			known.rawset(uniqueID, { SteamID=params.networkid, Name=playerName });
			knownManager.Save("playerslist");
		}
	}
}
::LinEventHook("OnGameEvent_player_connect", ::LinGe.Base.OnGameEvent_player_connect, ::LinGe.Base);

// 玩家队伍更换事件
// team=0：玩家刚连接、和断开连接时会被分配到此队伍 不统计此队伍的人数
// team=1：旁观者 team=2：生还者 team=3：特感
::LinGe.Base.OnGameEvent_player_team <- function (_params)
{
	if (!_params.rawin("userid"))
		return;

	local params = clone _params;
	params.player <- GetPlayerFromUserID(params.userid);
	params.steamid <- params.player.GetNetworkIDString();
	// 使用插件等方式改变阵营的时候，可能导致 params.name 为空
	// 通过GetPlayerName重新获取会比较稳定
	params.name <- params.player.GetPlayerName();
	params.entityIndex <- params.player.GetEntityIndex();

	local idx = ::pyinfo.survivorIdx.find(params.entityIndex);
	if ( 2 == params.oldteam && null != idx )
		::pyinfo.survivorIdx.remove(idx);
	else if (2 == params.team && null == idx)
		::pyinfo.survivorIdx.append(params.entityIndex);

	// 当不是BOT时，对当前玩家人数进行更新
	// 使用插件等方式加入bot时，params.isbot不准确 应获取其SteamID进行判断
	if ("BOT" != params.steamid)
	{
		// 更新玩家最大人数
		UpdateMaxplayers();
		// 更新玩家数据信息
		switch (params.oldteam)
		{
		case 0:
			break;
		case 1:
			::pyinfo.ob--;
			break;
		case 2:
			::pyinfo.survivor--;
			break;
		case 3:
			::pyinfo.special--;
			break;
		default:
			throw "未知情况发生";
		}
		switch (params.team)
		{
		case 0:
			break;
		case 1:
			::pyinfo.ob++;
			break;
		case 2:
			::pyinfo.survivor++;
			break;
		case 3:
			::pyinfo.special++;
			break;
		default:
			throw "未知情况发生";
		}
		// 触发真实玩家变更事件
		::LinEventTrigger("human_team_nodelay", params);
		::LinEventTrigger("human_team", params, 0.1); // 延时0.1s触发
	}
}
::LinEventHook("OnGameEvent_player_team", ::LinGe.Base.OnGameEvent_player_team, ::LinGe.Base);

// 玩家队伍变更提示
::LinGe.Base.human_team <- function (params)
{
	if (!Config.isShowTeamChange)
		return;

	local text = "\x03" + params.name + "\x04 ";
	switch (params.team)
	{
	case 0:
		text += "已离开";
		break;
	case 1:
		if (params.oldteam == 2 && ::LinGe.IsPlayerIdle(params.entityIndex))
			text += "已闲置";
		else
			text += "进入旁观";
		break;
	case 2:
		text += "加入了生还者";
		break;
	case 3:
		text += "加入了感染者";
		break;
	}
	ClientPrint(null, 3, text);
}
::LinEventHook("human_team", LinGe.Base.human_team, LinGe.Base);

::LinGe.Base.Cmd_teaminfo <- function (player, args)
{
	if (1 == args.len())
	{
		Config.isShowTeamChange = !Config.isShowTeamChange;
		local text = Config.isShowTeamChange ? "开启" : "关闭";
		ClientPrint(player, 3, "\x04服务器已" + text + "队伍更换提示");
	}
}
::LinCmdAdd("teaminfo", ::LinGe.Base.Cmd_teaminfo, ::LinGe.Base, "开启或关闭玩家队伍更换提示");

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
			local team = ::LinGe.GetPlayerTeam(player);
			if (2 == team)
				table.survivorIdx.append(player.GetEntityIndex());
			if ("BOT" != player.GetNetworkIDString())
			{
				// 如果不是BOT，则还需对玩家人数进行修正
				switch (team)
				{
				case 1:
					table.ob++;
					break;
				case 2:
					table.survivor++;
					break;
				case 3:
					table.special++;
					break;
				}
			}
		}
	}
}

::LinGe.Base.UpdateMaxplayers <- function (params=null)
{
	local old = ::pyinfo.maxplayers;
	local new = null;
	if (isExistMaxplayers)
	{
		new = Convars.GetFloat("sv_maxplayers");
	}

	if (new == null || new < 0)
	{
		if (::LinGe.isVersus)
			::pyinfo.maxplayers = 8;
		else
			::pyinfo.maxplayers = 4;
	}
	else
		::pyinfo.maxplayers = new.tointeger();
	if (old != ::pyinfo.maxplayers)
	{
		::LinEventTrigger("maxplayers_changed");
	}
}
//----------------------------Base-----END---------------------------------