@echo off
set main=..\plugin\
set output=plugin
set _7z="D:\Program Files\7-Zip\7z.exe"
set linux_user=arch

rd /s /q %output%
mkdir %output%\addons\LinGe_VScripts

:: 复制插件文件
copy %main%\LinGe_VScripts.vdf %output%\addons\LinGe_VScripts.vdf
copy %main%\%USER%-build\Release\LinGe_VScripts.dll %output%\addons\LinGe_VScripts\LinGe_VScripts.dll
copy %main%\%linux_user%-build\Release\LinGe_VScripts.so %output%\addons\LinGe_VScripts\LinGe_VScripts.so

:: 打包 zip
cd %output%
%_7z% a -tzip LinGe_VScripts.zip addons

pause