printl("[LinGe] HUD 正在载入");
::LinGe.HUD <- {};
::LinGe.HUD.Config <- {
	HUDShow = {
		all = true,
		time = true,
		players = true,
		hostname = false,
		versusNoHUDRank = true // 对抗模式是否永远不显示击杀排行
	},
	playersStyle = {
		// 关键词：{特殊(ob,idle,vac,max),队伍(sur,spe),真人或BOT(human,bot),生存或死亡(alive,dead),运算(+,-)} 如果不包含某个关键词则不对其限定
		// ob,idle,vac,max 为特殊关键词，当包含该类关键词时其它所有关键词无效
		// 除队伍可同时包含 sur 与 spe 外，其它类型的关键词若同时出现则只有最后一个有效
		// 可以使用击杀、伤害数据关键字，会显示为所有玩家的总和
		coop = "活跃:{sur,human}  摸鱼:{ob}  空位:{vac}  存活特感:{spe,alive}  本局特感击杀:{ksi}",
		versus = "生还:{sur,human}  VS  特感:{spe,human}"
	},
	hurt = {
		HUDRank = 4, // HUD排行榜最多显示多少人
		HUDRankMode = 0, // 0:紧凑式 1:分列式:兼容多分辨率 2:分列式:不兼容多分辨率（个人不推荐）
		rankCompact = {
			title = "特感/丧尸击杀：",
			style = "[{rank}] {ksi}/{kci} <- {name}({state})",
		},
		rankColumnAlign = [
			{
				title = "特感",
				style = "{ksi}/{o_ksi}",
				width = 0.1,
			},
			{
				title = "丧尸",
				style = "{kci}/{o_kci}",
				width = 0.1,
			},
			{
				title = "血量状态",
				style = "{state}",
				width = 0.1,

			},
			{
				title = "玩家",
				style = "[{rank}] {name}",
				width = 0.7,
			},
		],
		tankHurt = {
			title = "本次击杀了共 {count} 只 Tank，伤害贡献如下",
			style = "[{rank}] {hurt} <- {name}"
		},
		teamHurtInfo = 2, // 友伤即时提示 0:关闭 1:公开处刑 2:仅攻击者和被攻击者可见
		autoPrint = 0, // 每间隔多少s在聊天窗输出一次数据统计，若为0则只在本局结束时输出，若<0则永远不输出
		chatRank = 4, // 聊天窗输出时除了最高友伤、最高被黑 剩下显示最多多少人的数据
		chatStyle2 = "特:{ksi}({si}伤害) 尸:{kci} 黑:{atk} 被黑:{vct} <- {name}",
		discardLostRound = false, // 累计数据中是否不统计败局的数据
		chatAtkMaxStyle = "队友鲨手:{name}({hurt})", // 友伤最高与受到友伤最高
		chatVctMaxStyle = "都欺负我:{name}({hurt})",
		chatTeamHurtPraise = "大家真棒，没有友伤的世界达成了~",
		HUDRankShowBot = false
	},
	textHeight2 = 0.026, // 一行文字通用高度
	position = {
		hostname_x = 0.4,
		hostname_y = 0.0,
		time_x = 0.75,
		time_y = 0.0,
		players_x = 0.0,
		players_y = 0.0,
		rank_x = 0.0,
		rank_y = 0.025
	}
};
::LinGe.Config.Add("HUD", ::LinGe.HUD.Config);
::LinGe.Cache.HUD_Config <- ::LinGe.HUD.Config;
local rankColumnAlign = clone ::LinGe.HUD.Config.hurt.rankColumnAlign; // 避免缓存还原后影响数组顺序

::LinGe.HUD.playersIndex <- []; // 排行榜玩家实体索引列表 包括生还者（含BOT）与本局从生还者进入闲置或旁观的玩家
::LinGe.HUD.hurtData <- []; // 伤害与击杀数据
::LinGe.HUD.hurtData_bak <- {}; // 以UniqueID为key保存数据，已经离开的玩家与过关时所有玩家的数据会在此保存
::LinGe.Cache.hurtData_bak <- ::LinGe.HUD.hurtData_bak;
local hurtDataTemplate = { tank=0 };
local item_key = ["ksi", "hsi", "kci", "hci", "si", "atk", "vct"];
local ex_str = "";
local all_key = clone item_key;
foreach (key in item_key)
{
	all_key.append("o_" + key);
	all_key.append("t_" + key);
	hurtDataTemplate[key] <- 0;
	hurtDataTemplate["o_" + key] <- 0;
	hurtDataTemplate["t_" + key] <- 0;
	ex_str += format("|%s|t_%s|o_%s", key, key, key);
}
local exHurtItem = regexp("{(rank|name|state" + ex_str + ")((:%)([-\\w]+))?}");
// rank为排名，name为玩家名，state为玩家当前血量与状态，若无异常状态则只显示血量
// ksi=击杀的特感数量 hsi=爆头击杀特感的数量 kci=击杀的丧尸数量 hci=爆头击杀丧尸的数量
// si=对特感伤害 atk=对别人的友伤 vct=自己受到的友伤 tank=对tank伤害
// 对特感伤害中不包含对Tank和Witch的伤害 对Tank伤害会单独列出
// 以 t_ 开头的代表整局游戏的累计数据
// 以 o_ 开头的数据总是在最开始的时候初始化为 t_ 的值，与 t_ 不同的是，它不会实时更新
// 可以指定格式化方式，设置方式参考 https://www.runoob.com/cprogramming/c-function-printf.html
// 需要注意数据类型相匹配，例如 {name:%4d} 会出错，同时也不推荐对字符串数据自定义格式化方式
// 最初是想用来设置数据对齐，不过效果太差，所以又做了分列数据的功能。自定义格式化方式的功能保留，但不推荐使用

// 预处理文本处理函数
::LinGe.HUD.Pre <- {};

local exPlayers = regexp("{([a-z\\,\\+\\-]*)}");
::LinGe.HUD.Pre.BuildFuncCode_Players <- function (result)
{
	local res = exPlayers.capture(result.format_str);

	if (res != null)
	{
		local des = split(result.format_str.slice(res[1].begin, res[1].end), ",");
		result.format_args += ",";
		local item = [];

		if (des.len() > 0)
		{
			local specialKey = 0, humanOrBot = 0, aliveOrDead = 0;
			local team = [];
			foreach (key in des)
			{
				switch (key)
				{
				case "ob":		specialKey = 1; break;
				case "idle":	specialKey = 2; break;
				case "vac":		specialKey = 3; break;
				case "max":		specialKey = 4;	break;
				case "sur":		team.append(2); break;
				case "spe":		team.append(3);	break;
				case "human":	humanOrBot = 1; break;
				case "bot":		humanOrBot = 2;	break;
				case "alive":	aliveOrDead = 1; break;
				case "dead":	aliveOrDead = 2; break;
				case "+": case "-":
					item.append({specialKey=specialKey, humanOrBot=humanOrBot, aliveOrDead=aliveOrDead, team=team, operator=key});
					specialKey = 0, humanOrBot = 0, aliveOrDead = 0;
					team = [];
					break;
				default:
				{
					local idx = all_key.find(key);
					if (idx != null)
						specialKey = key;
					else
						printl("[LinGe] HUD playersStyle 无效关键词：" + key);
					break;
				}
				}
			}
			item.append({specialKey=specialKey, humanOrBot=humanOrBot, aliveOrDead=aliveOrDead, team=team, operator=""});
		}

		foreach (val in item)
		{
			local team = "";
			if (val.team.len() > 0)
			{
				foreach (i in val.team)
				{
					team = format("%d,%s", i, team);
				}
				team = format("[%s]", team);
			}
			else
				team = "null";

			if (typeof val.specialKey == "string")
				result.format_args += format("::LinGe.HUD.SumHurtData(\"%s\")", val.specialKey);
			else
			{
				switch (val.specialKey)
				{
				case 1:	result.format_args += "::pyinfo.ob"; break;
				case 2:	result.format_args += "::LinGe.GetIdlePlayerCount()"; break;
				case 3:	result.format_args += "::pyinfo.maxplayers - (::pyinfo.survivor+::pyinfo.ob+::pyinfo.special)";	break;
				case 4:	result.format_args += "::pyinfo.maxplayers"; break;
				default:
					result.format_args += format("::LinGe.GetPlayerCount(%s,%d,%d)", team, val.humanOrBot, val.aliveOrDead);
					break;
				}
			}
			result.format_args += val.operator;
		}

		result.format_str = result.format_str.slice(0, res[0].begin) + "%d" + result.format_str.slice(res[0].end);
		BuildFuncCode_Players(result);
	}
	else
	{
		result.funcCode = format("return format(\"%s\"%s);", result.format_str, result.format_args);
	}
}

::LinGe.HUD.Pre.BuildFuncCode_Rank <- function (result, wrap=@(str) str)
{
	local res = exHurtItem.capture(result.format_str); // index=0 带{}的完整匹配 index=1 不带{}的分组1

	if (res != null)
	{
		result.format_args += ",";
		local key = result.format_str.slice(res[1].begin, res[1].end);
		local format_str = null;
		if (res.len() >= 5 && res[3].begin>=0 && res[3].end > res[3].begin
		&& res[3].end <= result.format_str.len())
		{
			if (result.format_str.slice(res[3].begin, res[3].end).find(":%") == 0)
				format_str = "%" + result.format_str.slice(res[4].begin, res[4].end);
			else
				format_str = null;
		}

		if (key == "rank")
		{
			if (format_str == null)
				format_str = "%d";
			result.format_args += "vargv[0]";
		}
		else if (key == "name")
		{
			if (format_str == null)
				format_str = "%s";
			result.format_args += "vargv[1].GetPlayerName()";
		}
		else if (key == "state")
		{
			if (format_str == null)
				format_str = "%s";
			result.format_args += "::LinGe.HUD.GetPlayerState(vargv[1])";
		}
		else
		{
			if (format_str == null)
				format_str = "%d";
			result.format_args += "vargv[2]." + key;
			result.key.append(key);
		}
		result.format_str = result.format_str.slice(0, res[0].begin) + wrap(format_str) + result.format_str.slice(res[0].end);
		BuildFuncCode_Rank(result, wrap);
	}
	else
	{
		result.funcCode = format("return format(\"%s\"%s);", result.format_str, result.format_args);
	}
}

local exTeamHurt = regexp("{(name|hurt)((:%)([-\\w]+))?}");
::LinGe.HUD.Pre.BuildFuncCode_TeamHurt <- function (result, wrap=@(str) str)
{
	local res = exTeamHurt.capture(result.format_str);

	if (res != null)
	{
		result.format_args += ",";
		local key = result.format_str.slice(res[1].begin, res[1].end);
		local format_str = null;
		if (res.len() >= 5 && res[3].begin>=0 && res[3].end > res[3].begin
		&& res[3].end <= result.format_str.len())
		{
			if (result.format_str.slice(res[3].begin, res[3].end).find(":%") == 0)
				format_str = "%" + result.format_str.slice(res[4].begin, res[4].end);
			else
				format_str = null;
		}

		if (key == "name")
		{
			if (format_str == null)
				format_str = "%s";
			result.format_args += "vargv[0]";
		}
		else if (key == "hurt")
		{
			if (format_str == null)
				format_str = "%d";
			result.format_args += "vargv[1]";
		}
		result.format_str = result.format_str.slice(0, res[0].begin) + wrap(format_str) + result.format_str.slice(res[0].end);
		BuildFuncCode_TeamHurt(result, wrap);
	}
	else
	{
		result.funcCode = format("return format(\"%s\"%s);", result.format_str, result.format_args);
	}
}

local exTankTitle = regexp("{(count)((:%)([-\\w]+))?}");
::LinGe.HUD.Pre.BuildFuncCode_TankTitle <- function (result, wrap=@(str) str)
{
	local res = exTankTitle.capture(result.format_str);

	if (res != null)
	{
		result.format_args += ",";
		local key = result.format_str.slice(res[1].begin, res[1].end);
		local format_str = null;
		if (res.len() >= 5 && res[3].begin>=0 && res[3].end > res[3].begin
		&& res[3].end <= result.format_str.len())
		{
			if (result.format_str.slice(res[3].begin, res[3].end).find(":%") == 0)
				format_str = "%" + result.format_str.slice(res[4].begin, res[4].end);
			else
				format_str = null;
		}

		if (key == "count")
		{
			if (format_str == null)
				format_str = "%d";
			result.format_args += "vargv[0]";
		}
		result.format_str = result.format_str.slice(0, res[0].begin) + wrap(format_str) + result.format_str.slice(res[0].end);
		BuildFuncCode_TankTitle(result, wrap);
	}
	else
	{
		result.funcCode = format("return format(\"%s\"%s);", result.format_str, result.format_args);
	}
}

local exTankHurt = regexp("{(rank|name|hurt)((:%)([-\\w]+))?}");
::LinGe.HUD.Pre.BuildFuncCode_TankHurt <- function (result, wrap=@(str) str)
{
	local res = exTankHurt.capture(result.format_str);

	if (res != null)
	{
		result.format_args += ",";
		local key = result.format_str.slice(res[1].begin, res[1].end);
		local format_str = null;
		if (res.len() >= 5 && res[3].begin>=0 && res[3].end > res[3].begin
		&& res[3].end <= result.format_str.len())
		{
			if (result.format_str.slice(res[3].begin, res[3].end).find(":%") == 0)
				format_str = "%" + result.format_str.slice(res[4].begin, res[4].end);
			else
				format_str = null;
		}

		if (key == "rank")
		{
			if (format_str == null)
				format_str = "%d";
			result.format_args += "vargv[0]";
		}
		else if (key == "name")
		{
			if (format_str == null)
				format_str = "%s";
			result.format_args += "vargv[1].GetPlayerName()";
		}
		else if (key == "hurt")
		{
			if (format_str == null)
				format_str = "%d";
			result.format_args += "vargv[2]";
		}
		result.format_str = result.format_str.slice(0, res[0].begin) + wrap(format_str) + result.format_str.slice(res[0].end);
		BuildFuncCode_TankHurt(result, wrap);
	}
	else
	{
		result.funcCode = format("return format(\"%s\"%s);", result.format_str, result.format_args);
	}
}

::LinGe.HUD.Pre.CompileFunc <- function ()
{
	local empty_table = {key=[], format_str="", format_args="", funcCode=""};
	local result;

	// 战役模式 玩家数量显示预处理
	result = clone empty_table;
	result.format_str = ::LinGe.HUD.Config.playersStyle.coop;
	BuildFuncCode_Players(result);
	::LinGe.HUD.Pre.PlayersCoop <- compilestring(result.funcCode);

	// 对抗模式 玩家数量显示预处理
	result = clone empty_table;
	result.format_str = ::LinGe.HUD.Config.playersStyle.versus;
	BuildFuncCode_Players(result);
	::LinGe.HUD.Pre.PlayersVersus <- compilestring(result.funcCode);

	// HUD排行榜紧凑模式预处理
	result = clone empty_table;
	result.format_str = ::LinGe.HUD.Config.hurt.rankCompact.style;
	BuildFuncCode_Rank(result);
	::LinGe.HUD.Pre.HUDCompactKey <- result.key; // key列表需要保存下来，用于排序
	::LinGe.HUD.Pre.HUDCompactFunc <- compilestring(result.funcCode);

	// HUD排行榜列对齐模式预处理
	::LinGe.HUD.Pre.HUDColumnKey <- [];
	::LinGe.HUD.Pre.HUDColumnFuncFull <- [];
	::LinGe.HUD.Pre.HUDColumnFunc <- [];
	::LinGe.HUD.Pre.HUDColumnNameIndex <- -1;
	foreach (val in rankColumnAlign)
	{
		result = clone empty_table;
		result.format_str = val.style;
		BuildFuncCode_Rank(result);

		HUDColumnKey.extend(result.key);
		if (val.style.find("{name}") != null)
		{
			if (HUDColumnNameIndex != -1)
				printl("[LinGe] HUD 排行榜多列数据包含玩家名，不推荐这样做。");
			HUDColumnNameIndex = HUDColumnFuncFull.len();
		}
		HUDColumnFuncFull.append(compilestring(result.funcCode));
	}

	// 聊天窗排行榜预处理
	result = clone empty_table;
	result.format_str = ::LinGe.HUD.Config.hurt.chatStyle2;
	BuildFuncCode_Rank(result, @(str) "\x03" + str + "\x04");
	::LinGe.HUD.Pre.ChatKey <- result.key;
	::LinGe.HUD.Pre.ChatFunc <- compilestring(result.funcCode);

	// 最高友伤与受到最高友伤预处理
	if (::LinGe.HUD.Config.hurt.chatAtkMaxStyle)
	{
		result = clone empty_table;
		result.format_str = ::LinGe.HUD.Config.hurt.chatAtkMaxStyle;
		BuildFuncCode_TeamHurt(result, @(str) "\x03"+str+"\x04");
		::LinGe.HUD.Pre.AtkMaxFunc <- compilestring(result.funcCode);
	}
	else
		::LinGe.HUD.Pre.AtkMaxFunc <- null;
	if (::LinGe.HUD.Config.hurt.chatVctMaxStyle)
	{
		result = clone empty_table;
		result.format_str = ::LinGe.HUD.Config.hurt.chatVctMaxStyle;
		BuildFuncCode_TeamHurt(result, @(str) "\x03"+str+"\x04");
		::LinGe.HUD.Pre.VctMaxFunc <- compilestring(result.funcCode);
	}
	else
		::LinGe.HUD.Pre.VctMaxFunc <- null;

	// Tank 伤害预处理
	result = clone empty_table;
	result.format_str = ::LinGe.HUD.Config.hurt.tankHurt.title;
	BuildFuncCode_TankTitle(result, @(str) "\x03" + str + "\x04");
	::LinGe.HUD.Pre.TankTitleFunc <- compilestring(result.funcCode);

	result = clone empty_table;
	result.format_str = ::LinGe.HUD.Config.hurt.tankHurt.style;
	BuildFuncCode_TankHurt(result, @(str) "\x03" + str + "\x04");
	::LinGe.HUD.Pre.TankHurtFunc <- compilestring(result.funcCode);
}
::LinGe.HUD.Pre.CompileFunc();

const HUD_MAX_STRING_LENGTH = 127; // 一个HUD Slot最多只能显示127字节字符
const HUD_SLOT_BEGIN = 0;
const HUD_SLOT_END = 14;
const HUD_SLOT_RANK_BEGIN	= 0; // 紧凑模式下 第一个SLOT显示标题 后续显示每个玩家的数据 分列模式则各自显示不同的数据
local HUD_SLOT_RANK_END		= 0;
local HUD_RANK_COMPACT_PLAYERS	= 0; // 根据空闲slot数量，紧凑模式最多能显示28个玩家数据
const HUD_RANK_COLUMN_PLAYERS_COMPAT = 8; // 分列模式兼容模式最多能显示8个玩家的数据，7列数据
const HUD_RANK_COLUMN_PLAYERS	= 16; // 分列模式不兼容模式最多能显示16个玩家的数据，5列数据
local HUD_RANK_COLUMN_MAX		= 0;
// 服务器每1s内会多次根据HUD_table更新屏幕上的HUD
// 脚本只需将HUD_table中的数据进行更新 而无需反复执行HUDSetLayout和HUDPlace
local HUD_table_template = {
	hostname = { // 服务器名
		slot = 0,
		dataval = Convars.GetStr("hostname"),
		flags = HUD_FLAG_NOBG | HUD_FLAG_ALIGN_LEFT
	},
	time = { // 显示当地时间需 LinGe_VScripts 辅助插件支持
		slot = 0,
		// 无边框 左对齐
		flags = HUD_FLAG_NOBG | HUD_FLAG_ALIGN_LEFT
	},
	players = { // 目前玩家数
		slot = 0,
		dataval = "",
		// 无边框 左对齐
		flags = HUD_FLAG_NOBG | HUD_FLAG_ALIGN_LEFT
	}
};
for (local i=HUD_SLOT_BEGIN; i<=HUD_SLOT_END; i++)
{
	HUD_table_template["rank" + i] <- {
		slot = 0,
		dataval = "",
		flags = HUD_FLAG_NOBG | HUD_FLAG_ALIGN_LEFT
	};
}
::LinGe.HUD.HUD_table <- {Fields = clone HUD_table_template};

local isExistTime = false;
// 按照Config配置更新HUD属性信息
::LinGe.HUD.ApplyConfigHUD <- function ()
{
	if (!Config.HUDShow.all)
	{
		::VSLib.Timers.RemoveTimerByName("Timer_HUD");
		HUDSetLayout( ::VSLib.HUD._hud );
		return;
	}
	local height = Config.textHeight2;

	HUD_table.Fields = clone HUD_table_template;
	HUD_SLOT_RANK_END = HUD_SLOT_END;
	if (Config.HUDShow.time)
	{
		HUD_table.Fields.time.slot = HUD_SLOT_RANK_END;
		HUDPlace(HUD_SLOT_RANK_END, Config.position.time_x, Config.position.time_y, 1.0, height); // 设置时间显示位置
		HUD_SLOT_RANK_END--;
		if (isExistTime)
			HUD_table.Fields.time.dataval <- "";
		else
			HUD_table.Fields.time.special <- HUD_SPECIAL_ROUNDTIME;
	}
	else
	{
		HUD_table.Fields.rawdelete("time");
	}

	if (Config.HUDShow.players)
	{
		HUD_table.Fields.players.slot = HUD_SLOT_RANK_END;
		HUDPlace(HUD_SLOT_RANK_END, Config.position.players_x, Config.position.players_y, 1.0, height); // 设置玩家数量信息显示位置
		HUD_SLOT_RANK_END--;
	}
	else
	{
		HUD_table.Fields.rawdelete("players");
	}

	if (Config.HUDShow.hostname)
	{
		HUD_table.Fields.hostname.slot = HUD_SLOT_RANK_END;
		HUDPlace(HUD_SLOT_RANK_END, Config.position.hostname_x, Config.position.hostname_y, 1.0, height); // 设置服务器名显示位置
		HUD_SLOT_RANK_END--;
	}
	else
	{
		HUD_table.Fields.rawdelete("hostname");
	}

	HUD_RANK_COMPACT_PLAYERS = 2 * (HUD_SLOT_RANK_END - HUD_SLOT_RANK_BEGIN);

	// 编号与隐藏多余的rank项
	local i = 0;
	for (i=HUD_SLOT_RANK_BEGIN; i<=HUD_SLOT_RANK_END; i++)
	{
		HUD_table.Fields["rank" + i].slot = i;
	}
	for (; i<=HUD_SLOT_END; i++)
	{
		HUD_table.Fields.rawdelete("rank" + i);
	}

	switch (Config.hurt.HUDRankMode)
	{
	case 0:
		// 紧凑模式
		local slot_end = HUD_SLOT_RANK_BEGIN;
		HUD_table.Fields["rank" + HUD_SLOT_RANK_BEGIN].dataval = Config.hurt.rankCompact.title;

		// 当一行只显示一个玩家数据slot不够用时，一行显示两个玩家的数据
		if (Config.hurt.HUDRank > HUD_RANK_COMPACT_PLAYERS / 2)
		{
			HUDPlace(HUD_SLOT_RANK_BEGIN, Config.position.rank_x, Config.position.rank_y, 1.0, height);
			for (i=HUD_SLOT_RANK_BEGIN+1; i<=HUD_SLOT_RANK_END; i++)
				HUDPlace(i, Config.position.rank_x, Config.position.rank_y + height*((i-HUD_SLOT_RANK_BEGIN)*2 - 1), 1.0, height*2);
			slot_end += (Config.hurt.HUDRank + 1) / 2;
		}
		else
		{
			for (i=HUD_SLOT_RANK_BEGIN; i<=HUD_SLOT_RANK_END; i++)
				HUDPlace(i, Config.position.rank_x, Config.position.rank_y + height*(i-HUD_SLOT_RANK_BEGIN), 1.0, height);
			slot_end += Config.hurt.HUDRank;
		}

		if (slot_end > HUD_SLOT_RANK_END)
			slot_end = HUD_SLOT_RANK_END;
		else if (slot_end <= HUD_SLOT_RANK_BEGIN)
			slot_end = -1;

		for (i=HUD_SLOT_RANK_BEGIN; i<=slot_end; i++) // 将需要显示的 slot 取消隐藏
			HUD_table.Fields["rank"+i].flags = HUD_table.Fields["rank"+i].flags & (~HUD_FLAG_NOTVISIBLE);
		// 隐藏多余的 slot
		while (i <= HUD_SLOT_RANK_END)
		{
			HUD_table.Fields["rank"+i].flags = HUD_table.Fields["rank"+i].flags | HUD_FLAG_NOTVISIBLE;
			i++;
		}
		break;
	case 1:
		// 分列模式 兼容
		for (i=HUD_SLOT_RANK_BEGIN; i<=HUD_SLOT_RANK_END; i++)
		{
			HUD_table.Fields["rank"+i].dataval = "";
			HUD_table.Fields["rank"+i].flags = HUD_table.Fields["rank"+i].flags & (~HUD_FLAG_NOTVISIBLE);
		}

		// 将 slot 摆放至指定位置
		local pos_x = Config.position.rank_x;
		if (Config.hurt.HUDRank > HUD_RANK_COLUMN_PLAYERS_COMPAT / 2)
		{
			HUD_RANK_COLUMN_MAX = (HUD_SLOT_RANK_END - HUD_SLOT_RANK_BEGIN) / 2;
			if (Pre.HUDColumnFuncFull.len() > HUD_RANK_COLUMN_MAX)
				Pre.HUDColumnFunc = Pre.HUDColumnFuncFull.slice(0, HUD_RANK_COLUMN_MAX);
			else
				Pre.HUDColumnFunc = Pre.HUDColumnFuncFull;

			for (i=0; i<Pre.HUDColumnFunc.len(); i++)
			{
				local width = rankColumnAlign[i].width;
				if (i > 0)
					pos_x += rankColumnAlign[i-1].width;
				HUDPlace(HUD_SLOT_RANK_BEGIN + i, pos_x,
					Config.position.rank_y,	width, height * 5);
				HUDPlace(HUD_SLOT_RANK_BEGIN + HUD_RANK_COLUMN_MAX + i, pos_x,
					Config.position.rank_y + height * 5, width, height * 4);
			}
		}
		else
		{
			HUD_RANK_COLUMN_MAX = HUD_SLOT_RANK_END - HUD_SLOT_RANK_BEGIN;
			if (Pre.HUDColumnFuncFull.len() > HUD_RANK_COLUMN_MAX)
				Pre.HUDColumnFunc = Pre.HUDColumnFuncFull.slice(0, HUD_RANK_COLUMN_MAX);
			else
				Pre.HUDColumnFunc = Pre.HUDColumnFuncFull;
			for (i=0; i<Pre.HUDColumnFunc.len(); i++)
			{
				local width = rankColumnAlign[i].width;
				if (i > 0)
					pos_x += rankColumnAlign[i-1].width;
				HUDPlace(HUD_SLOT_RANK_BEGIN + i, pos_x,
					Config.position.rank_y,	width, height * 5);
			}
		}
		break;
	default:
		// 分列模式 非兼容
		for (i=HUD_SLOT_RANK_BEGIN; i<=HUD_SLOT_RANK_END; i++)
		{
			HUD_table.Fields["rank"+i].dataval = "";
			HUD_table.Fields["rank"+i].flags = HUD_table.Fields["rank"+i].flags & (~HUD_FLAG_NOTVISIBLE);
		}

		// 将 slot 摆放至指定位置
		local pos_x = Config.position.rank_x;
		if (Config.hurt.HUDRank > HUD_RANK_COLUMN_PLAYERS/2)
		{
			HUD_RANK_COLUMN_MAX = (HUD_SLOT_RANK_END - HUD_SLOT_RANK_BEGIN - 1) / 2;
			if (Pre.HUDColumnFuncFull.len() > HUD_RANK_COLUMN_MAX)
				Pre.HUDColumnFunc = Pre.HUDColumnFuncFull.slice(0, HUD_RANK_COLUMN_MAX);
			else
				Pre.HUDColumnFunc = Pre.HUDColumnFuncFull;

			for (i=0; i<Pre.HUDColumnFunc.len(); i++)
			{
				local width = rankColumnAlign[i].width;
				if (i > 0)
					pos_x += rankColumnAlign[i-1].width;
				if (i == Pre.HUDColumnNameIndex)
				{
					HUDPlace(HUD_SLOT_RANK_BEGIN + i, pos_x,
						Config.position.rank_y,	width, height * 5);
					HUDPlace(HUD_SLOT_RANK_END, pos_x,
						Config.position.rank_y + height * 5, width, height * 4);
					HUDPlace(HUD_SLOT_RANK_BEGIN + HUD_RANK_COLUMN_MAX + i, pos_x,
						Config.position.rank_y + height * (5 + 4), width, height * 4);
					HUDPlace(HUD_SLOT_RANK_END - 1, pos_x,
						Config.position.rank_y + height * (5 + 4 + 4), width, height * 4);
				}
				else
				{
					HUDPlace(HUD_SLOT_RANK_BEGIN + i, pos_x,
						Config.position.rank_y,	width, height * 9);
					HUDPlace(HUD_SLOT_RANK_BEGIN + HUD_RANK_COLUMN_MAX + i, pos_x,
						Config.position.rank_y + height * 9, width, height * 8);
				}
			}
		}
		else
		{
			HUD_RANK_COLUMN_MAX = HUD_SLOT_RANK_END - HUD_SLOT_RANK_BEGIN;
			if (Pre.HUDColumnFuncFull.len() > HUD_RANK_COLUMN_MAX)
				Pre.HUDColumnFunc = Pre.HUDColumnFuncFull.slice(0, HUD_RANK_COLUMN_MAX);
			else
				Pre.HUDColumnFunc = Pre.HUDColumnFuncFull;
			for (i=0; i<Pre.HUDColumnFunc.len(); i++)
			{
				local width = rankColumnAlign[i].width;
				if (i > 0)
					pos_x += rankColumnAlign[i-1].width;
				if (i == Pre.HUDColumnNameIndex)
				{
					HUDPlace(HUD_SLOT_RANK_BEGIN + i, pos_x,
						Config.position.rank_y,	width, height * 5);
					HUDPlace(HUD_SLOT_RANK_END, pos_x,
						Config.position.rank_y + height * 5, width, height * 4);
				}
				else
				{
					HUDPlace(HUD_SLOT_RANK_BEGIN + i, pos_x,
						Config.position.rank_y,	width, height * 9);
				}
			}
		}
		break;
	}

	if (::LinGe.isVersus && Config.HUDShow.versusNoHUDRank)
	{
		for (i=HUD_SLOT_RANK_BEGIN; i<=HUD_SLOT_RANK_END; i++)
			HUD_table.Fields["rank"+i].flags = HUD_table.Fields["rank"+i].flags | HUD_FLAG_NOTVISIBLE;
	}

	Timer_HUD();
	::VSLib.Timers.AddTimer(1.5, false, Timer_DelayHUD);
	::VSLib.Timers.AddTimerByName("Timer_HUD", 1.0, true, Timer_HUD);
}

::LinGe.HUD.Timer_DelayHUD <- function (params=null)
{
	if (Config.hurt.HUDRank > 0)
	{
		// 不在 Timer_HUD 里更新排行榜，避免同一Tick内处理太多数据导致游戏卡顿
		UpdateRankHUD();
		::VSLib.Timers.AddTimerByName("Timer_UpdateRankHUD", 1.0, true, UpdateRankHUD);
	}
	else
	{
		::VSLib.Timers.RemoveTimerByName("Timer_UpdateRankHUD");
	}
	HUDSetLayout(HUD_table);
}.bindenv(::LinGe.HUD);

::LinGe.HUD.Timer_HUD <- function (params=null)
{
	if (isExistTime && HUD_table.Fields.rawin("time"))
		HUD_table.Fields.time.dataval = Convars.GetStr("linge_time");
	if (HUD_table.Fields.rawin("players"))
	{
		if (::LinGe.isVersus)
			HUD_table.Fields.players.dataval = Pre.PlayersVersus();
		else
			HUD_table.Fields.players.dataval = Pre.PlayersCoop();
	}
}.bindenv(::LinGe.HUD);

// 将玩家的伤害数据从 hurtData 备份到 hurtData_bak
::LinGe.HUD.BackupAllHurtData <- function ()
{
	for (local i=1; i<=32; i++)
	{
		local player = PlayerInstanceFromIndex(i);
		if (player && player.IsValid()
		&& player.GetNetworkIDString() != "BOT"
		&& 3 != ::LinGe.GetPlayerTeam(player))
		{
			local id = ::LinGe.SteamIDCastUniqueID(player.GetNetworkIDString());
			if (id != "S00")
				hurtData_bak.rawset(id, clone hurtData[i]);
		}
	}
}

::LinGe.HUD.GetPlayerBakHurtData <- function (player)
{
	if (typeof player != "instance")
		throw "player 类型非法";
	if (!player.IsValid())
		return null;
	if (player.GetNetworkIDString() == "BOT")
		return null;
	local id = ::LinGe.SteamIDCastUniqueID(player.GetNetworkIDString());
	if (!hurtData_bak.rawin(id))
		return null;
	return hurtData_bak[id];
}

::LinGe.HUD.On_cache_restore <- function (params)
{
	// 将HurtData_bak中的非累计数据置为0
	foreach (id, d in hurtData_bak)
	{
		if (!d.rawin("hsi")) // Cache 还原后，小写h总是会被改写为大写H，大坑
			d.hsi <- 0;
		if (!d.rawin("hci"))
			d.hci <- 0;
		foreach (key in item_key)
			d[key] = 0;
		d.tank = 0;
	}

	// 初始化 hurtData
	for (local i=0; i<=32; i++)
	{
		local d = clone hurtDataTemplate;
		hurtData.append(d);

		local player = PlayerInstanceFromIndex(i);
		if (player && player.IsValid() && 3 != ::LinGe.GetPlayerTeam(player)
		&& params.isValidCache)
		{
			local last_data = GetPlayerBakHurtData(player);
			if (last_data)
			{
				foreach (key in item_key)
				{
					d["t_" + key] = last_data["t_" + key];
					d["o_" + key] = d["t_" + key];
				}
			}
		}
	}

	// 将 rankColumnAlign 还原为配置文件内容
	// 因为保存到 Cache 时，array会变成table，顺序会被打乱
	// 所以需要将其直接还原为配置文件内容，以避免在 !save 时保存成乱序的排行榜配置
	Config.hurt.rankColumnAlign = clone rankColumnAlign;
}
::LinEventHook("cache_restore", ::LinGe.HUD.On_cache_restore, ::LinGe.HUD);

// 回合失败
::LinGe.HUD.SaveHurt_RoundLost <- function (params)
{
	// 如果不统计回合失败时的累计数据，则需将 t_ 数据还原为 o_
	BackupAllHurtData();
	if (Config.hurt.discardLostRound)
	{
		foreach (id, d in hurtData_bak)
		{
			foreach (key in item_key)
				d["t_" + key] = d["o_" + key];
		}
	}
}
::LinEventHook("OnGameEvent_round_end", ::LinGe.HUD.SaveHurt_RoundLost, ::LinGe.HUD);

// 成功过关
::LinGe.HUD.SaveHurt_RoundWin <- function (params)
{
	BackupAllHurtData();
}
::LinEventHook("OnGameEvent_map_transition", ::LinGe.HUD.SaveHurt_RoundWin, ::LinGe.HUD);

// 事件：回合开始
::LinGe.HUD.OnGameEvent_round_start <- function (params)
{
	// 如果linge_time变量不存在则显示回合时间
	if (null == Convars.GetStr("linge_time"))
	{
		isExistTime = false;
	}
	else
	{
		isExistTime = true;
	}

	playersIndex = clone ::pyinfo.survivorIdx;

	ApplyAutoHurtPrint();
	ApplyConfigHUD();
}
::LinEventHook("OnGameEvent_round_start", ::LinGe.HUD.OnGameEvent_round_start, ::LinGe.HUD);

// 玩家队伍更换事件
// team=0：玩家刚连接、和断开连接时会被分配到此队伍 不统计此队伍的人数
// team=1：旁观者 team=2：生还者 team=3：特感
::LinGe.HUD.OnGameEvent_player_team <- function (params)
{
	if (!params.rawin("userid"))
		return;

	local player = GetPlayerFromUserID(params.userid);
	local entityIndex = player.GetEntityIndex();
	local steamid = player.GetNetworkIDString();
	local isHuman = steamid != "BOT";
	local uniqueID = ::LinGe.SteamIDCastUniqueID(steamid);
	local idx = playersIndex.find(entityIndex);

	if (isHuman)
	{
		UpdateRankHUD();
	}

	if ( (params.disconnect || 3 == params.team) && null != idx )
	{
		playersIndex.remove(idx);
		if (isHuman && uniqueID != "S00")
		{
			hurtData_bak.rawset(uniqueID, clone hurtData[entityIndex]);
			hurtData[entityIndex] = clone hurtDataTemplate;
		}
	}
	else if (2 == params.team && null == idx)
	{
		playersIndex.append(entityIndex);
		if (isHuman && hurtData_bak.rawin(uniqueID))
		{
			hurtData[entityIndex] = clone hurtData_bak[uniqueID];
		}
	}
}
::LinEventHook("OnGameEvent_player_team", ::LinGe.HUD.OnGameEvent_player_team, ::LinGe.HUD);

// 事件：玩家受伤 友伤信息提示、伤害数据统计
// 对witch伤害和对小僵尸伤害不会触发这个事件
// witch伤害不记录，tank伤害单独记录
::LinGe.HUD.tempTeamHurt <- {}; // 友伤临时数据记录
::LinGe.HUD.OnGameEvent_player_hurt <- function (params)
{
	if (!params.rawin("dmg_health"))
		return;
	if (params.dmg_health < 1)
		return;

	if (0 == params.type) // 伤害类型为0
		return;
	local attacker = GetPlayerFromUserID(params.attacker); // 获得攻击者实体
	if (null == attacker) // 攻击者无效
		return;
	if (!attacker.IsSurvivor()) // 攻击者不是生还者
		return;

	// 获取被攻击者实体
	local victim = GetPlayerFromUserID(params.userid);
	local vctHp = victim.GetHealth();
	local dmg = params.dmg_health;
	// 如果被攻击者是生还者则统计友伤数据
	if (victim.IsSurvivor())
	{
		if (victim.IsDying() || victim.IsDead())
			return;
		else if (vctHp < 0) // 致死伤害事件发生时，victim.IsDead()还不会为真，但血量会<0
		{
			// 如果是本次伤害致其死亡，则 生命值 + 伤害值 > 0
			if (vctHp + dmg <= 0)
				return;
		}
		else if (victim.IsIncapacitated())
		{
			// 如果是本次伤害致其倒地，则其当前血量+伤害量=300
			// 如果不是，则说明攻击时已经倒地，则不统计本次友伤
			if (vctHp + dmg != 300)
				return;
		}

		// 若不是对自己造成的伤害，则计入累计统计
		if (attacker != victim)
		{
			hurtData[attacker.GetEntityIndex()].atk += dmg;
			hurtData[attacker.GetEntityIndex()].t_atk += dmg;
			hurtData[victim.GetEntityIndex()].vct += dmg;
			hurtData[victim.GetEntityIndex()].t_vct += dmg;
		}

		// 若开启了友伤提示，则计入临时数据统计
		if (Config.hurt.teamHurtInfo >= 1 && Config.hurt.teamHurtInfo <= 2)
		{
			local key = params.attacker + "_" + params.userid;
			if (!tempTeamHurt.rawin(key))
			{
				tempTeamHurt[key] <- { dmg=0, attacker=attacker, atkName=attacker.GetPlayerName(),
					victim=victim, vctName=victim.GetPlayerName(), isDead=false, isIncap=false };
			}
			tempTeamHurt[key].dmg += dmg;
			// 友伤发生后，0.5秒内同一人若未再对同一人造成友伤，则输出其造成的伤害
			VSLib.Timers.AddTimerByName(key, 0.5, false, Timer_PrintTeamHurt, key);
		}
	}
	else // 不是生还者团队则统计对特感的伤害数据
	{
		// 如果是Tank 则将数据记录到临时Tank伤害数据记录
		if (8 == victim.GetZombieType())
		{
			if (5000 == dmg) // 击杀Tank时会产生5000伤害事件，不知道为什么设计了这样的机制
				return;
			hurtData[attacker.GetEntityIndex()].tank += dmg;
		}
		else // 不是生还者且不是Tank，则为普通特感(此事件下不可能为witch)
		{
			if (vctHp < 0)
				dmg += vctHp; // 修正溢出伤害
			hurtData[attacker.GetEntityIndex()].si += dmg;
			hurtData[attacker.GetEntityIndex()].t_si += dmg;
		}
	}
}
::LinEventHook("OnGameEvent_player_hurt", ::LinGe.HUD.OnGameEvent_player_hurt, ::LinGe.HUD);
/*	Tank的击杀伤害与致队友倒地时的伤害存在溢出
	没能发现太好修正方法，因为当上述两种情况发生时
	已经无法获得其最后一刻的真实血量
	除非时刻记录Tank和队友的血量，然后以此为准编写一套逻辑
	但这样实在太浪费资源，且容易出现BUG
*/

// 提示一次友伤伤害并删除累积数据
::LinGe.HUD.Timer_PrintTeamHurt <- function (key)
{
	local info = tempTeamHurt[key];
	local atkName = info.atkName;
	local vctName = info.vctName;
	local text = "";

	if (Config.hurt.teamHurtInfo == 1)
	{
		if (info.attacker == info.victim)
			vctName = "他自己";
		text = "\x03" + atkName
			+ "\x04 对 \x03" + vctName
			+ "\x04 造成了 \x03" + info.dmg + "\x04 点伤害";
		if (info.isDead)
		{
			if (info.attacker == info.victim)
				text += "，并且死亡";
			else
				text += "，并且杀死了对方";
		}
		else if (info.isIncap)
		{
			if (info.attacker == info.victim)
				text += "，并且倒地";
			else
				text += "，并且击倒了对方";
		}
		ClientPrint(null, 3, text);
	}
	else if (Config.hurt.teamHurtInfo == 2)
	{
		if (info.attacker == info.victim)
		{
			if (info.attacker.IsValid())
			{
				text = "\x04你对 \x03自己\x04 造成了 \x03" + info.dmg + "\x04 点伤害";
				if (info.isDead)
					text += "，并且死亡";
				else if (info.isIncap)
					text += "，并且倒地";
				ClientPrint(info.attacker, 3, text);
			}
		}
		else
		{
			if (info.attacker.IsValid())
			{
				text = "\x04你对 \x03" + vctName
					+ "\x04 造成了 \x03" + info.dmg + "\x04 点伤害";
				if (info.isDead)
					text += "，并且杀死了他";
				else if (info.isIncap)
					text += "，并且击倒了他";
				ClientPrint(info.attacker, 3, text);
			}

			if (info.victim.IsValid())
			{
				text = "\x03" + atkName
				+ "\x04 对你造成了 \x03" + info.dmg + "\x04 点伤害";
				if (info.isDead)
					text += "，并且杀死了你";
				else if (info.isIncap)
					text += "，并且打倒了你";
				ClientPrint(info.victim, 3, text);
			}
		}
	}
	tempTeamHurt.rawdelete(key);
}.bindenv(LinGe.HUD);

// 事件：玩家(特感/丧尸)死亡 统计击杀数量
// 虽然是player_death 但小丧尸和witch死亡也会触发该事件
::LinGe.HUD.OnGameEvent_player_death <- function (params)
{
	local dier = 0;	// 死者ID
	local dierEntity = null;	// 死者实体
	local attacker = 0; // 攻击者ID
	local attackerEntity = null; // 攻击者实体

	if (params.victimname == "Infected" || params.victimname == "Witch")
	{
		// witch 和 小丧尸 不属于玩家可控制实体 无userid
		dier = params.entityid;
	}
	else
		dier = params.userid;
	if (dier == 0)
		return;

	attacker = params.attacker;
	dierEntity = GetPlayerFromUserID(dier);
	attackerEntity = GetPlayerFromUserID(attacker);

	if (dierEntity && dierEntity.IsSurvivor())
	{
		// 自杀时伤害类型为0
		if (params.type == 0)
			return;

		// 如果是友伤致其死亡
		if (attackerEntity && attackerEntity.IsSurvivor())
		{
			local key = params.attacker + "_" + dier;
			if (tempTeamHurt.rawin(key))
				tempTeamHurt[key].isDead = true;
		}
	}
	else
	{
		if (attackerEntity && attackerEntity.IsSurvivor())
		{
			if (params.victimname == "Infected")
			{
				hurtData[attackerEntity.GetEntityIndex()].kci++;
				hurtData[attackerEntity.GetEntityIndex()].t_kci++;
				if (params.headshot)
				{
					hurtData[attackerEntity.GetEntityIndex()].hci++;
					hurtData[attackerEntity.GetEntityIndex()].t_hci++;
				}
			}
			else
			{
				hurtData[attackerEntity.GetEntityIndex()].ksi++;
				hurtData[attackerEntity.GetEntityIndex()].t_ksi++;
				if (params.headshot)
				{
					hurtData[attackerEntity.GetEntityIndex()].hsi++;
					hurtData[attackerEntity.GetEntityIndex()].t_hsi++;
				}
			}
			// UpdateRankHUD();
		}
	}
}
::LinEventHook("OnGameEvent_player_death", ::LinGe.HUD.OnGameEvent_player_death, ::LinGe.HUD);

// 事件：玩家倒地
::LinGe.HUD.OnGameEvent_player_incapacitated <- function (params)
{
	if (!params.rawin("userid") || params.userid == 0)
		return;

	local player = GetPlayerFromUserID(params.userid);
	local attackerEntity = null;
	if (params.rawin("attacker")) // 如果是小丧尸或Witch等使玩家倒地，则无attacker
		attackerEntity = GetPlayerFromUserID(params.attacker);
	if (player.IsSurvivor())
	{
		// 如果是友伤致其倒地
		if (attackerEntity && attackerEntity.IsSurvivor())
		{
			local key = params.attacker + "_" + params.userid;
			if (tempTeamHurt.rawin(key))
				tempTeamHurt[key].isIncap = true;
		}
	}
}
::LinEventHook("OnGameEvent_player_incapacitated", ::LinGe.HUD.OnGameEvent_player_incapacitated, ::LinGe.HUD);

::LinGe.HUD.OnGameEvent_hostname_changed <- function (params)
{
	local hostname = Convars.GetStr("hostname");
	if (hostname && typeof hostname == "string")
	{
		if (HUD_table.Fields.rawin("hostname"))
			HUD_table.Fields.hostname.dataval = hostname;
		HUD_table_template.hostname.dataval = hostname;
	}
}
::LinEventHook("OnGameEvent_hostname_changed", ::LinGe.HUD.OnGameEvent_hostname_changed, ::LinGe.HUD);

::LinGe.HUD.Cmd_thi <- function (player, args)
{
	if (2 == args.len())
	{
		local style = LinGe.TryStringToInt(args[1], 0);
		Config.hurt.teamHurtInfo = style;
	}
	switch (Config.hurt.teamHurtInfo)
	{
	case 1:
		ClientPrint(null, 3, "\x04服务器已开启友伤提示 \x03公开处刑");
		break;
	case 2:
		ClientPrint(null, 3, "\x04服务器已开启友伤提示 \x03仅双方可见");
		break;
	default:
		ClientPrint(null, 3, "\x04服务器已关闭友伤提示");
		break;
	}
	ClientPrint(player, 3, "\x04!thi 0:关闭友伤提示 1:公开处刑 2:仅双方可见");
}
::LinCmdAdd("thi", ::LinGe.HUD.Cmd_thi, ::LinGe.HUD, "0:关闭友伤提示 1:公开处刑 2:仅双方可见");

::LinGe.HUD.Cmd_hurtdata <- function (player, args)
{
	local len = args.len();
	if (1 == len)
		PrintChatRank();
	else if (3 == len)
	{
		if (!::LinGe.Admin.IsAdmin(player))
		{
			ClientPrint(player, 3, "\x04权限不足！");
		}
		else if ("auto" == args[1])
		{
			local time = ::LinGe.TryStringToFloat(args[2]);
			Config.hurt.autoPrint = time;
			ApplyAutoHurtPrint();
			if (time > 0)
				ClientPrint(player, 3, "\x04已设置每 \x03" + time + "\x04 秒播报一次聊天窗排行榜");
			else if (0 == time)
				ClientPrint(player, 3, "\x04已关闭定时聊天窗排行榜播报，回合结束时仍会播报");
			else
				ClientPrint(player, 3, "\x04已彻底关闭聊天窗排行榜播报");
		}
		else if ("player" == args[1])
		{
			local player = ::LinGe.TryStringToInt(args[2]);
			Config.hurt.chatRank = player;
			if (player > 0)
				ClientPrint(player, 3, "\x04聊天窗排行榜将显示最多 \x03" + player + "\x04 人");
			else
				ClientPrint(player, 3, "\x04已彻底关闭聊天窗排行榜与TANK伤害统计播报");
		}
	}
}
::LinCmdAdd("hurtdata", ::LinGe.HUD.Cmd_hurtdata, ::LinGe.HUD, "", false);
::LinCmdAdd("hurt", ::LinGe.HUD.Cmd_hurtdata, ::LinGe.HUD, "", false);
::LinCmdAdd("hd", ::LinGe.HUD.Cmd_hurtdata, ::LinGe.HUD, "输出一次聊天窗排行榜或者调整自动播报配置", false);

local reHudCmd = regexp("^(all|time|players|hostname)$");
::LinGe.HUD.Cmd_hud <- function (player, args)
{
	if (1 == args.len())
	{
		Config.HUDShow.all = !Config.HUDShow.all;
		ApplyConfigHUD();
		return;
	}
	else if (2 == args.len())
	{
		if (args[1] == "rank")
		{
			ClientPrint(player, 3, "\x04!hud rank n 设置排行榜最大显示人数为n");
			return;
		}
		else if (reHudCmd.search(args[1]))
		{
			Config.HUDShow[args[1]] = !Config.HUDShow[args[1]];
			ApplyConfigHUD();
			return;
		}
	}
	else if (3 == args.len() && args[1] == "rank")
	{
		Config.hurt.HUDRank = ::LinGe.TryStringToInt(args[2]);
		ApplyConfigHUD();
		return;
	}
	ClientPrint(player, 3, "\x04!hud time/players/hostname/rank 控制HUD元素的显示");
}
::LinCmdAdd("hud", ::LinGe.HUD.Cmd_hud, ::LinGe.HUD, "time/players/hostname/rank 控制HUD元素的显示");

::LinGe.HUD.Cmd_rank <- function (player, args)
{
	if (2 == args.len())
	{
		Config.hurt.HUDRank = ::LinGe.TryStringToInt(args[1]);
		ApplyConfigHUD();
		return;
	}
	ClientPrint(player, 3, "\x04!rank n 设置排行榜最大显示人数为n");
}
::LinCmdAdd("rank", ::LinGe.HUD.Cmd_rank, ::LinGe.HUD);

::LinGe.HUD.GetPlayerState <- function (player)
{
	if (::LinGe.GetPlayerTeam(player) == 1)
		return "摸鱼";
	else if (!::LinGe.IsAlive(player))
		return "死亡";
	else
	{
		local hp = player.GetHealth() + player.GetHealthBuffer().tointeger();
		local text = format("%d", hp);
		if (player.GetSpecialInfectedDominatingMe())
			text += ",被控";
		else if (player.IsHangingFromLedge())
			text += ",挂边";
		else if (player.IsIncapacitated())
			text += ",倒地";
		else if (::LinGe.GetReviveCount(player) >= 2)
			text += ",濒死";
		return text;
	}
}

::LinGe.HUD.UpdateRankHUD <- function (params=null)
{
	if (Config.hurt.HUDRank < 1)
		return;
	if (::LinGe.isVersus && Config.HUDShow.versusNoHUDRank)
		return;

	local len = playersIndex.len();
	// 将生还者实体索引数组按特感击杀数量由大到小进行排序
	// 如果特感击杀数量相等，则按丧尸击杀数
	switch (Config.hurt.HUDRankMode)
	{
	case 0:
		local max_rank = Config.hurt.HUDRank > HUD_RANK_COMPACT_PLAYERS ? HUD_RANK_COMPACT_PLAYERS : Config.hurt.HUDRank;
		hurtDataSort(playersIndex, Pre.HUDCompactKey);
		local rank = 1;
		if (max_rank > HUD_RANK_COMPACT_PLAYERS/2)
		{
			for (local i=0; i < len && rank <= max_rank; i++)
			{
				local player = PlayerInstanceFromIndex(playersIndex[i]);
				if (!IsPlayerABot(player) || Config.hurt.HUDRankShowBot)
				{
					local text = Pre.HUDCompactFunc(rank, player, hurtData[playersIndex[i]]);
					if (rank % 2 == 1)
						HUD_table.Fields["rank" + (HUD_SLOT_RANK_BEGIN + (rank+1)/2)].dataval = text + "\n";
					else
						HUD_table.Fields["rank" + (HUD_SLOT_RANK_BEGIN + (rank+1)/2)].dataval += text;
					rank++;
				}
			}
			// 当前排行榜显示的人数小于最大显示人数时，清除可能存在的多余的行
			if (rank % 2 == 0)
				rank++;
			while (rank <= max_rank)
			{
				HUD_table.Fields["rank" + (HUD_SLOT_RANK_BEGIN + (rank+1)/2)].dataval = "\n";
				rank+=2;
			}
		}
		else
		{
			for (local i=0; i < len && rank <= max_rank; i++)
			{
				local player = PlayerInstanceFromIndex(playersIndex[i]);
				if (!IsPlayerABot(player) || Config.hurt.HUDRankShowBot)
				{
					local text = Pre.HUDCompactFunc(rank, player, hurtData[playersIndex[i]]);
					HUD_table.Fields["rank" + (HUD_SLOT_RANK_BEGIN + rank)].dataval = text;
					rank++;
				}
			}
			// 当前排行榜显示的人数小于最大显示人数时，清除可能存在的多余的行
			while (rank <= max_rank)
			{
				HUD_table.Fields["rank" + (HUD_SLOT_RANK_BEGIN + rank)].dataval = "";
				rank++;
			}
		}
		break;
	case 1:
		local max_rank = Config.hurt.HUDRank > HUD_RANK_COLUMN_PLAYERS_COMPAT ? HUD_RANK_COLUMN_PLAYERS_COMPAT : Config.hurt.HUDRank;
		hurtDataSort(playersIndex, Pre.HUDColumnKey);

		// 重新设置每列的内容
		if (max_rank > HUD_RANK_COLUMN_PLAYERS_COMPAT/2)
		{
			for (local i=0; i<Pre.HUDColumnFunc.len(); i++)
			{
				HUD_table.Fields["rank" + (HUD_SLOT_RANK_BEGIN + i)].dataval =
					rankColumnAlign[i].title;
				HUD_table.Fields["rank" + (HUD_SLOT_RANK_BEGIN + HUD_RANK_COLUMN_MAX + i)].dataval = "";
			}
		}
		else
		{
			for (local i=0; i<Pre.HUDColumnFunc.len(); i++)
			{
				HUD_table.Fields["rank" + (HUD_SLOT_RANK_BEGIN + i)].dataval =
					rankColumnAlign[i].title;
			}
		}

		local rank = 1;
		local begin = HUD_SLOT_RANK_BEGIN;
		local nl_normal = "\n";
		local player = null;
		for (local i=0; i<len && rank <= max_rank; i++)
		{
			player = PlayerInstanceFromIndex(playersIndex[i]);
			if (!IsPlayerABot(player) || Config.hurt.HUDRankShowBot)
			{
				nl_normal = "\n";
				if (rank == 5)
				{
					begin = HUD_SLOT_RANK_BEGIN + HUD_RANK_COLUMN_MAX;
					nl_normal = "";
				}
				foreach (index, func in Pre.HUDColumnFunc)
				{
					HUD_table.Fields["rank" + (begin + index)].dataval += nl_normal +
						func(rank, player, hurtData[playersIndex[i]]);
				}
				rank++;
			}
		}

		// 使用换行符填充剩余的行，使文字行数对齐
		while (rank <= 4)
		{
			foreach (index, func in Pre.HUDColumnFunc)
			{
				HUD_table.Fields["rank" + (HUD_SLOT_RANK_BEGIN + index)].dataval += "\n";
			}
			rank++;
		}
		// 如果rank==5，则下半段的slot都是空白，无需处理
		if (rank > 5)
		{
			while (rank <= 8)
			{
				foreach (index, func in Pre.HUDColumnFunc)
				{
					HUD_table.Fields["rank" + (HUD_SLOT_RANK_BEGIN + HUD_RANK_COLUMN_MAX + index)].dataval += "\n";
				}
				rank++;
			}
		}
		break;
	default:
		local max_rank = Config.hurt.HUDRank > HUD_RANK_COLUMN_PLAYERS ? HUD_RANK_COLUMN_PLAYERS : Config.hurt.HUDRank;
		hurtDataSort(playersIndex, Pre.HUDColumnKey);

		if (max_rank > HUD_RANK_COLUMN_PLAYERS/2)
		{
			// 重新设置每列的内容
			HUD_table.Fields["rank" + HUD_SLOT_RANK_END].dataval = "";
			HUD_table.Fields["rank" + (HUD_SLOT_RANK_END - 1)].dataval = "";
			for (local i=0; i<Pre.HUDColumnFunc.len(); i++)
			{
				HUD_table.Fields["rank" + (HUD_SLOT_RANK_BEGIN + i)].dataval =
					rankColumnAlign[i].title;
				HUD_table.Fields["rank" + (HUD_SLOT_RANK_BEGIN + HUD_RANK_COLUMN_MAX + i)].dataval = "";
			}
		}
		else
		{
			HUD_table.Fields["rank"+HUD_SLOT_RANK_END].dataval = "";
			for (local i=0; i<Pre.HUDColumnFunc.len(); i++)
			{
				HUD_table.Fields["rank" + (HUD_SLOT_RANK_BEGIN + i)].dataval =
					rankColumnAlign[i].title;
			}
		}

		// 列模式下，排行榜1~4、5、6~8、9、10~12、13、14~16名次均需要进行不同的处理
		local rank = 1;
		local begin = HUD_SLOT_RANK_BEGIN;
		local name_slot2 = HUD_table.Fields["rank" + HUD_SLOT_RANK_END];
		local nl_normal = "\n", nl_name = "\n";
		local player = null;

		for (local i=0; i<len && rank <= max_rank; i++)
		{
			player = PlayerInstanceFromIndex(playersIndex[i]);
			if (!IsPlayerABot(player) || Config.hurt.HUDRankShowBot)
			{
				nl_normal = nl_name = "\n";
				switch (rank)
				{
				case 9:
					begin = HUD_SLOT_RANK_BEGIN + HUD_RANK_COLUMN_MAX;
					name_slot2 = HUD_table.Fields["rank" + (HUD_SLOT_RANK_END - 1)];
					nl_normal = "";
					nl_name = "";
				case 1: case 2: case 3: case 4:
				case 10:case 11:case 12:
					foreach (index, func in Pre.HUDColumnFunc)
					{
						HUD_table.Fields["rank" + (begin + index)].dataval += nl_normal +
							func(rank, player, hurtData[playersIndex[i]]);
					}
					break;
				case 5: case 13:
					nl_name = "";
				case 6: case 7: case 8:
				case 14:case 15:case 16:
					foreach (index, func in Pre.HUDColumnFunc)
					{
						if (index == Pre.HUDColumnNameIndex)
						{
							name_slot2.dataval += nl_name +
								func(rank, player, hurtData[playersIndex[i]]);
						}
						else
						{
							HUD_table.Fields["rank" + (begin + index)].dataval += nl_normal +
								func(rank, player, hurtData[playersIndex[i]]);
						}
					}
					break;
				}
				rank++;
			}
		}

		// 使用换行符填充剩余的行，使文字行数对齐
		while (rank <= 8)
		{
			foreach (index, func in Pre.HUDColumnFunc)
			{
				if (index == Pre.HUDColumnNameIndex && rank > 4)
				{
					HUD_table.Fields["rank" + HUD_SLOT_RANK_END].dataval += "\n";
				}
				else
				{
					HUD_table.Fields["rank" + (HUD_SLOT_RANK_BEGIN + index)].dataval += "\n";
				}
			}
			rank++;
		}
		// 如果rank==9，则下半段的slot都是空白，无需处理
		if (rank > 9)
		{
			while (rank <= 16)
			{
				foreach (index, func in Pre.HUDColumnFunc)
				{
					if (index == Pre.HUDColumnNameIndex && rank > 12)
					{
						HUD_table.Fields["rank" + (HUD_SLOT_RANK_END - 1)].dataval += "\n";
					}
					else
					{
						HUD_table.Fields["rank" + (HUD_SLOT_RANK_BEGIN + HUD_RANK_COLUMN_MAX + index)].dataval += "\n";
					}
				}
				rank++;
			}
		}
		break;
	}
}.bindenv(::LinGe.HUD);

// Tank 事件控制
// 在Tank全部死亡时输出并清空本次克局伤害统计
local nowTank = 0;
local killTank = 0;
::LinGe.HUD.OnGameEvent_tank_spawn <- function (params)
{
	nowTank++;
}
::LinGe.HUD.OnGameEvent_tank_killed <- function (params)
{
	nowTank--;
	killTank++;
	if (nowTank == 0)
	{
		PrintTankHurtData();
		killTank = 0;
		for (local i=1; i<=32; i++)
			hurtData[i].tank = 0;
	}
}
::LinEventHook("OnGameEvent_tank_spawn", ::LinGe.HUD.OnGameEvent_tank_spawn, ::LinGe.HUD);
::LinEventHook("OnGameEvent_tank_killed", ::LinGe.HUD.OnGameEvent_tank_killed, ::LinGe.HUD);

::LinGe.HUD.PrintTankHurtData <- function ()
{
	local maxRank = Config.hurt.chatRank;
	local idx = clone playersIndex;
	local len = idx.len();

	if (maxRank > 0 && len > 0)
	{
		hurtDataSort(idx, ["tank"]);
		// 如果第一位的伤害也为0，则本次未对该Tank造成伤害，则不输出Tank伤害统计
		// 终局时无线刷Tank 经常会出现这种0伤害的情况
		if (hurtData[idx[0]].tank == 0)
			return;
		ClientPrint(null, 3, "\x04" + Pre.TankTitleFunc(killTank));
		for (local i=0; i<maxRank && i<len; i++)
		{
			local player = PlayerInstanceFromIndex(idx[i]);
			ClientPrint(null, 3, "\x04" + Pre.TankHurtFunc(i+1, player, hurtData[idx[i]].tank));
		}
	}
}

// 根据当前的 Config.hurt.autoPrint 设置定时输出Timer
::LinGe.HUD.ApplyAutoHurtPrint <- function ()
{
	if (Config.hurt.autoPrint <= 0)
		::VSLib.Timers.RemoveTimerByName("Timer_AutoPrintHurt");
	else
		::VSLib.Timers.AddTimerByName("Timer_AutoPrintHurt", Config.hurt.autoPrint, true, PrintChatRank);

	::LinEventUnHook("OnGameEvent_round_end", ::LinGe.HUD.PrintChatRank);
	::LinEventUnHook("OnGameEvent_map_transition", ::LinGe.HUD.PrintChatRank);
	if (Config.hurt.autoPrint >= 0)
	{
		// 回合结束时输出本局伤害统计
		::LinEventHook("OnGameEvent_round_end", ::LinGe.HUD.PrintChatRank);
		::LinEventHook("OnGameEvent_map_transition", ::LinGe.HUD.PrintChatRank);
	}
}

// 向聊天窗公布当前的伤害数据统计
// params是预留参数位置 为方便关联事件和定时器
::LinGe.HUD.PrintChatRank <- function (params=0)
{
	local maxRank = Config.hurt.chatRank;
	local survivorIdx = clone playersIndex;
	local name = "", len = survivorIdx.len();
	if (len > 0)
	{
		local atkMax = { name="", hurt=0 };
		local vctMax = clone atkMax;
		// 遍历找出黑枪最多和被黑最多
		for (local i=0; i<len; i++)
		{
			local temp = hurtData[survivorIdx[i]];
			if (temp.atk > atkMax.hurt)
			{
				atkMax.hurt = temp.atk;
				atkMax.name = PlayerInstanceFromIndex(survivorIdx[i]).GetPlayerName();
			}
			if (temp.vct > vctMax.hurt)
			{
				vctMax.hurt = temp.vct;
				vctMax.name = PlayerInstanceFromIndex(survivorIdx[i]).GetPlayerName();
			}
		}
		if (maxRank > 0)
		{
			hurtDataSort(survivorIdx, Pre.ChatKey);
			for (local i=0; i<maxRank && i<len; i++)
			{
				local player = PlayerInstanceFromIndex(survivorIdx[i]);
				ClientPrint(null, 3, "\x04" +
					Pre.ChatFunc(i+1, player, hurtData[survivorIdx[i]]));
			}
		}

		// 显示最高黑枪和最高被黑
		if (0 == atkMax.hurt && 0 == vctMax.hurt && Config.hurt.chatTeamHurtPraise)
		{
			ClientPrint(null, 3, "\x05" + Config.hurt.chatTeamHurtPraise);
		}
		else
		{
			local text = "\x04";
			if (atkMax.hurt > 0 && Pre.AtkMaxFunc)
				text += Pre.AtkMaxFunc(atkMax.name, atkMax.hurt) + " ";
			if (vctMax.hurt > 0 && Pre.VctMaxFunc)
				text += Pre.VctMaxFunc(vctMax.name, vctMax.hurt);
			if (text != "\x04")
				ClientPrint(null, 3, text);
		}
	}
}.bindenv(::LinGe.HUD);

::LinGe.HUD.SumHurtData <- function (key)
{
	local result = 0;
	foreach (playerIndex in playersIndex)
	{
		result += hurtData[playerIndex][key];
	}
	return result;
}

// 冒泡排序 默认降序排序
::LinGe.HUD.hurtDataSort <- function (survivorIdx, key, desc=true)
{
	local temp;
	local len = survivorIdx.len();
	local result = desc ? 1 : -1;
	for (local i=0; i<len-1; i++)
	{
		for (local j=0; j<len-1-i; j++)
		{
			if (hurtDataCompare(survivorIdx[j], survivorIdx[j+1], key, 0) == result)
			{
				temp = survivorIdx[j];
				survivorIdx[j] = survivorIdx[j+1];
				survivorIdx[j+1] = temp;
			}
		}
	}
}

::LinGe.HUD.hurtDataCompare <- function (idx1, idx2, key, keyIdx)
{
	if (hurtData[idx1][key[keyIdx]] > hurtData[idx2][key[keyIdx]])
		return -1;
	else if (hurtData[idx1][key[keyIdx]] == hurtData[idx2][key[keyIdx]])
	{
		if (keyIdx+1 < key.len()) // 如果还有可比较的值就继续比较
			return hurtDataCompare(idx1, idx2, key, keyIdx+1);
		else
			return 0;
	}
	else
		return 1;
}