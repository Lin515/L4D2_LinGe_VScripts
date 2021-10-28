printl(_version_);
printl("[vscripts] 脚本文件正在载入");

IncludeScript("VSLib");			// 必须 VSLib库
IncludeScript("LinGe/Base");	// 必须 基础库 注册事件函数，实现了玩家人数统计、命令与权限管理
// 请不要更改必须库的载入顺序，否则将无法正确载入脚本
IncludeScript("LinGe/HUD");		// 可选 HUD
IncludeScript("LinGe/MoreSI"); // 可选 简易的多特控制
IncludeScript("LinGe/Server"); // 可选 服务器控制功能