@echo off
set main=..\vscripts
set nutdir=nut_vpk
set vpk="D:\Program Files (x86)\Steam\steamapps\common\Left 4 Dead 2\bin\vpk.exe"

mkdir %nutdir%\scripts\vscripts\LinGe
mkdir %nutdir%\scripts\vscripts\VSLib

:: 复制 addoninfo.txt
copy addoninfo.txt %nutdir%\addoninfo.txt

:: 复制 nut 文件
copy %main%\LinGe %nutdir%\scripts\vscripts\LinGe
del %nutdir%\scripts\vscripts\LinGe\Server.nut
copy %main%\VSLib %nutdir%\scripts\vscripts\VSLib
copy %main%\VSLib.nut %nutdir%\scripts\vscripts\VSLib.nut
copy %main%\director_base_addon.nut %nutdir%\scripts\vscripts\director_base_addon.nut
copy %main%\scriptedmode_addon.nut %nutdir%\scripts\vscripts\scriptedmode_addon.nut

:: 打包vpk
%vpk% %nutdir%
del LinGe_VScripts.vpk
rename %nutdir%.vpk LinGe_VScripts.vpk

pause