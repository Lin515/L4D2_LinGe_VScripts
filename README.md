# 简介

脚本实现玩家人数统计、友伤提示、HUD（显示特感击杀、时间、服务器名等）、多特控制等等。  
显示服务器时间需要安装辅助插件，若未安装插件则将显示本回合用时。

主要适用于多人战役，服务器装了太多莫名其妙的插件的话，不保证不会出 bug。目前已知插件药抗下会比较容易出现人数统计的 bug。

脚本与插件一样都是运行在服务端的，本地客户端作为房主开房也可以用，并且作用于房间内所有玩家，而自己进入别人的房间是没有用的。

# 使用说明

## 安装脚本

以下两种方式任意选一安装即可，不需要修改脚本代码建议创意工坊订阅本脚本。

如果需要安装辅助插件，请点击右侧的发布项目下载 LinGe_VScripts.zip，然后将 addons 下的文件解压到 left4dead2/addons 目录下，再在游戏启动项中加入 -insecure，之后启动游戏即可。

### 创意工坊订阅

[点击进入创意工坊](https://steamcommunity.com/sharedfiles/filedetails/?id=2587952986)

### 脚本文件

将以下列出的所需文件复制到 left4dead2/scripts/vscripts 目录下：

LinGe 目录下一共有 4 个 .nut 脚本文件：

- Base.nut 必须安装。脚本的基础模块。  
- HUD.nut 可选安装。HUD 模块，显示击杀、时间、玩家人数等等。
- MoreSI.nut 可选安装。多特控制模块。
-  Server.nut 可选安装。一些杂项功能。

除 LinGe 目录以外，还有如下文件是必须安装的：

- director_base_addon.nut
- scriptedmode_addon.nut
- VSLib.nut 和 VSLib 文件夹

## 设置管理员

单人游戏或者本地开房，房主都可直接使用指令，其它玩家要使用指令需手动设置管理员ID。

在游戏中打开控制台输入 status 指令来获取 SteamID，类似于 STEAM_1:0:64877973。  
然后将这个 ID 写入到配置文件 left4dead2/ems/linge/admins_simple.ini 中，回合重新开始，脚本重新读取管理员列表之后即可生效。

## 指令

本系列脚本提供了一些消息指令来快速控制脚本的功能，它们用法类似于 sourcemod 插件的 sm 指令。通过发送以 ! 或 / 为前缀再加指令名的玩家消息来调用指令。

除此之外，本系列脚本的指令还可以以 . 为前缀。因为服务器安装了聊天窗静默插件后，脚本无法捕获 ! 和 / 前缀的消息，所以额外增加了一个以 . 为前缀的调用。

以下是一些正确调用指令的例子：

- !hud on  
	打开 HUD。
- /teaminfo  
	开启/关闭玩家队伍变更提示。
- .sion 4 0 15  
	 开启多特控制并按指定参数执行功能。

以上指令的更具体含义请往下看。

# 辅助插件

辅助插件为脚本提供服务器时间，以及在房间最大人数 sv_maxplayers 变更时及时触发更新。

如果没有安装辅助插件，那么 HUD 上的时间将会显示为本局回合时间。

# Base 模块

Base 是脚本的基础模块。

它主要是作为库文件用来方便其它脚本的编写，其实质性的功能只有队伍变更提示功能。

Base 模块实现如下指令：

- !save 或 !saveconfig 保存当前功能设定为默认设定

- !teaminfo 打开或关闭玩家连接、加入阵营、闲置的聊天窗提示

# HUD 模块

HUD 模块可以在所有人的屏幕上显示特感击杀排行、时间、服务器名、玩家人数。同时还有友伤提示功能。

![HUD效果图](doc/HUD效果图.png)

- 玩家数量信息  
	显示玩家数量，除上图中的 活跃：x 摸鱼：x 空位：x 这种普通风格以外，还有对抗模式风格的 生还：x vs 特感：x。  
	不过对抗模式下本HUD是默认不显示玩家数量信息的。  
	!hudstyle n 可以设置显示风格：  
	- !hudstyle 0 根据游戏模式自动调整（默认）
	- !hudstyle 1 固定为普通风格
	- !hudstyle 2 固定为对抗风格

- 击杀排行  
	可以显示 1~8 人，默认显示前3名。  
	!rank n 可设置显示前 n 名。如需关闭排行榜则使用 !rank 0。
- 时间  
	如果你安装了 LinGe_VScripts 辅助插件，那么会显示服务端系统时间，否则显示当前回合用时。
- 服务器名  
	显示 hostname 控制台变量的值。本地开房时这个值会是房主的名字。
- 友伤提示信息  
	友伤提示信息显示在聊天窗，使用 !thi n 指令可以改变友伤提示的形式。  
	- !thi 0 关闭友伤提示。
	- !thi 1 友伤提示：所有人可见，公开处刑式。
	- !thi 2 友伤提示：仅双方可见。

# MoreSI 模块

多特模块，基于脚本的多特控制，可以随时在游戏中改变特感数量，并且可以根据生还者人数自动增加减少特感。

仅限战役模式，非战役模式不会加载。

多特模块主要通过如下几个指令控制：

- !sion  
	打开多特控制。
- !sioff  
	关闭多特控制。
- !sibase x  
	设置基础特感数量为 x，若 x<0 则关闭数量控制。
- !siauto x  
	设置每 1 个生还者增加 x 个特感。  
	特感总数量 = sibase + siauto*生还者数量。
- !sitime x  
	设置特感刷新复活间隔为 x 秒，若 x<0 则关闭特感刷新控制。  
	注：它不改变出安全区后第一波进攻的时间。即便设置为 0 秒，出门也不会立即刷特。
- !noci on/off  
	打开/关闭自动清除小僵尸，默认是关闭的。
- !sionly Boomer,Spitter,Smoker,Hunter,Charger,Jockey  
	限制特感生成种类，例如设置只生成 Hunter 和 Jockey：  
	!sionly Hunter,Jockey  
	如果想要去除限制，则发送 !sionly 任意非特感名字符。
- !sion 的增强用法  
	单独发送 !sion 是打开多特控制，但不会对任何参数进行设置。  
	!sion 也是可以一次设置多个值的，其使用格式如下：  
	!sion sibase siauto sitime noci(on/off) sionly  
	假若某个参数输入为 -2，或者输入的参数非法，那么这次指令就不会改变那个参数的值。  
	例如在开启多特控制的同时，设置 sibase=8,siauto不变,sitime=15,noci=on,sionly=Hunter,Jockey ：  
	!sion 8 -2 15 on Hunter,Jockey

请注意，以上指令均不会改变已出生特感的状态。比如当前已经刷出了 16 个特感，再设置特感数量为 8，多余的特感并不会被清除。

# Server 模块

这个主要是我的服务器自用，不作太多介绍，有需要请自行查看脚本源码。

# 配置文件

配置文件会在你安装脚本后第一次进入游戏生成，配置文件目录为 left4dead2/ems/linge。

正常情况下，会有如下 3 个配置文件生成：

> config_xxx.tbl xxx 为端口号，同一台服务器上不同端口号的房间可以使用不同的配置文件  
> admins_simple.ini 管理员列表  
> playerslist.tbl 玩家列表

## config_xxx.tbl

脚本的主要配置文件，所有可配置功能的开关均在此设置。

如果你修改配置文件后脚本无法正常工作，可删除配置文件以恢复默认。

### Base

- isShowTeamChange  
	是否显示队伍变更提示。
- recordPlayerInfo  
	是否记录玩家的信息。如果开启，玩家的名字和 SteamID 会被记录到 playerslist.tbl 中。

### Admin

- enabled  
	是否启用权限管理。若关闭，则不会进行权限判断，脚本任何指令都允许所有人调用。
- adminsFile  
	管理员列表文件的所在路径，默认是 linge/admins_simple.ini。见[管理员列表](#admins_simple.ini)。  
	你可以更改为其它文件，比如使用 Admin System 的管理员文件：  
	adminsFile = "admin system/admins.txt"
- takeOverAdminSystem  
	是否接管 Admin System 的权限判断，默认开启。  
	如果你安装了 Admin System，且管理员列表并不是使用它的文件，就可以开启这个功能以让其也共享管理员列表。

### HUD

- isShowHUD  
	所有 HUD 元素显示的总开关。
- teamHurtInfo  
	友伤提示，0 关闭，1 公开处刑式，2 仅双方可见。
- rank  
	排行榜显示的玩家数量，可设置为 0~8，0 为关闭。
- style  
	玩家数量的显示风格，0 自动，1 普通风格，2 对抗风格。
- isShowTime  
	是否显示时间。
- versusNoRank  
	对抗模式下是否不显示排行榜。
- versusNoPlayerInfo  
	对抗模式下是否不显示玩家数量。
- textHeight  
	HUD 中一行文字的高度，百分比数。
- position  
	设置各 HUD 模块的显示位置，均为百分比数。
	- players_x,y 玩家数量的坐标
	- rank_x,y 排行榜的坐标
	- hostname_x,y 服务器名的坐标
	- time_x,y 时间的坐标

### MoreSI

- enabled  多特控制的总开关。

- simin 最少特感数量，多特控制开启后特感数量最低不会低于该值。

- sibase 基础特感数量，-1 为关闭数量控制。

- siauto 自增数量。

- sitime 特感复活间隔，-1 为关闭时间控制。

- noci 是否清除小僵尸。

- sionly  特感类型限制列表，一行一个特感名，需使用 " 。例如：  

	```
	sionly = [
		"Hunter"
		"Boomer"
	]
	```

### Server

自用模块，不多介绍。

## admins_simple.ini

管理员列表文件，它的文件名取决于你在 config_xxx.tbl 中的设置。

脚本进行权限判断时会在此文件中搜索玩家的 SteamID，若找到则判断为管理员。

注意：只要 SteamID 能在该文件中搜索到，那么就会判断为是管理员，即便这段 ID 在配置文件中被注释了（懒得写判断）。

你可以通过创建软链接来共享脚本与插件平台的管理员列表，创建前请先删除已有的 admins_simple.ini。

``` shell
// 在 left4dead2 目录下执行指令
// Windiws Cmd 创建软链接
mklink "ems/linge/admins_simple.ini" "addons/sourcemod/configs/admins_simple.ini"
// Linux Shell 创建软链接
ln -s "addons/sourcemod/configs/admins_simple.ini" "ems/linge/admins_simple.ini"
```

硬链接也是一样的，看自己需求而定。
