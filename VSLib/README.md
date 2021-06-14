VSLib这个5.0版本我是从AdminSystem里提取到的，一直没找到VSLib的发布页。  

easylogic.nut文件我修改了一些小地方，消除一些在终局时的报错，以及在::VSLibScriptStart和g_MapScript.ScriptMode_OnShutdown增加了一点代码让它去触发一些我需要的事件。  
easylogic - 副本.nut 是它的原版。

如果你只需要用到这个VSLib库而不需要用到我的脚本，你可以选择用它的原版。或者直接使用我修改后的easylogic.nut，也不会有问题。