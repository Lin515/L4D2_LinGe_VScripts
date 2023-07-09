/*
 * Copyright (c) 2013 LuKeM aka Neil - 119 and Rayman1103
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software
 * and associated documentation files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or
 * substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
 * BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

::__VSLIB_VERSION__ <- 5.0;
local __VSLIB_NOTIFY_VERSION__ = false;

/*
 * Create global namespace
 */
if (!("VSLib" in getroottable()))
{
	::VSLib <-
	{
		GlobalCache = {}
		GlobalCacheSession = {}
	}
	__VSLIB_NOTIFY_VERSION__ = true;
}

/*
 * Include sub-files
 */
IncludeScript("LinGe/VSLib/EasyLogic.nut");
IncludeScript("LinGe/VSLib/Utils.nut");
IncludeScript("LinGe/VSLib/Timer.nut");
IncludeScript("LinGe/VSLib/Entity.nut");
IncludeScript("LinGe/VSLib/Player.nut");
IncludeScript("LinGe/VSLib/FileIO.nut");
IncludeScript("LinGe/VSLib/HUD.nut");
IncludeScript("LinGe/VSLib/ResponseRules.nut");
IncludeScript("LinGe/VSLib/RandomItemSpawner.nut");

if ( __VSLIB_NOTIFY_VERSION__ )
	printf( "Loaded VSLib version %f", __VSLIB_VERSION__ );