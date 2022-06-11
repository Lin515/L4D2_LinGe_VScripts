@echo off
set main=..\vscripts
set all=LinGe_VScripts
set Base=Base
set HUD=HUD
set MoreSI=MoreSI
set Hint=Hint
set zs=zs
set vpk="D:\Program Files (x86)\Steam\steamapps\common\Left 4 Dead 2\bin\vpk.exe"

:: 全套
rd /s /q %all%
mkdir %all%\scripts\vscripts\LinGe
mkdir %all%\scripts\vscripts\VSLib
copy %all%-addoninfo.txt %all%\addoninfo.txt
copy %all%-addoninfo.jpg %all%\addoninfo.jpg
copy %main%\LinGe %all%\scripts\vscripts\LinGe
copy %main%\VSLib %all%\scripts\vscripts\VSLib
copy %main%\VSLib.nut %all%\scripts\vscripts\VSLib.nut
copy %main%\director_base_addon.nut %all%\scripts\vscripts\director_base_addon.nut
copy %main%\scriptedmode_addon.nut %all%\scripts\vscripts\scriptedmode_addon.nut
%vpk% %all%

::Base
rd /s /q %Base%
mkdir %Base%\scripts\vscripts\LinGe
mkdir %Base%\scripts\vscripts\VSLib
copy %Base%-addoninfo.txt %Base%\addoninfo.txt
copy %Base%-addoninfo.jpg %Base%\addoninfo.jpg
copy %main%\LinGe\Base.nut %Base%\scripts\vscripts\LinGe\Base.nut
copy %main%\VSLib %Base%\scripts\vscripts\VSLib
copy %main%\VSLib.nut %Base%\scripts\vscripts\VSLib.nut
copy %main%\director_base_addon.nut %Base%\scripts\vscripts\director_base_addon.nut
copy %main%\scriptedmode_addon.nut %Base%\scripts\vscripts\scriptedmode_addon.nut
%vpk% %Base%

::HUD
rd /s /q %HUD%
mkdir %HUD%\scripts\vscripts\LinGe
copy %HUD%-addoninfo.txt %HUD%\addoninfo.txt
copy %HUD%-addoninfo.jpg %HUD%\addoninfo.jpg
copy %main%\LinGe\HUD.nut %HUD%\scripts\vscripts\LinGe\HUD.nut
%vpk% %HUD%

::MoreSI
rd /s /q %MoreSI%
mkdir %MoreSI%\scripts\vscripts\LinGe
copy %MoreSI%-addoninfo.txt %MoreSI%\addoninfo.txt
copy %MoreSI%-addoninfo.jpg %MoreSI%\addoninfo.jpg
copy %main%\LinGe\MoreSI.nut %MoreSI%\scripts\vscripts\LinGe\MoreSI.nut
%vpk% %MoreSI%

::Hint
rd /s /q %Hint%
mkdir %Hint%\scripts\vscripts\LinGe
copy %Hint%-addoninfo.txt %Hint%\addoninfo.txt
copy %Hint%-addoninfo.jpg %Hint%\addoninfo.jpg
copy %main%\LinGe\Hint.nut %Hint%\scripts\vscripts\LinGe\Hint.nut
%vpk% %Hint%

::zs
rd /s /q %zs%
mkdir %zs%\scripts\vscripts\LinGe
copy %zs%-addoninfo.txt %zs%\addoninfo.txt
copy %zs%-addoninfo.jpg %zs%\addoninfo.jpg
copy %main%\LinGe\zs.nut %zs%\scripts\vscripts\LinGe\zs.nut
%vpk% %zs%

pause