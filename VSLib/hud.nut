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


/**
 * Wraps Valve's HUD system.
 */
if (!("HUD" in ::VSLib))
{
	::VSLib.HUD <-
	{
		_hud = { Fields = {} }
	}
}

/**
 * Text alignment enumerator
 */
::TextAlign <- {
	Left = g_ModeScript.HUD_FLAG_ALIGN_LEFT
	Center = g_ModeScript.HUD_FLAG_ALIGN_CENTER
	Right = g_ModeScript.HUD_FLAG_ALIGN_RIGHT
}

/**
 * Determine VGUI panel defaults
 * \todo @TODO Read from "hudscriptedmode.res" if possible and serialize data from that
 */
local _vguiBaseRes = { width = 640, height = 480 };
::_panelt <- {};
_panelt[g_ModeScript.HUD_RIGHT_TOP] <- { xpos = 400, ypos = 12, width = 120, height = 25  };
_panelt[g_ModeScript.HUD_RIGHT_BOT] <- { xpos = 400, ypos = 40, width = 120, height = 25  };
_panelt[g_ModeScript.HUD_MID_TOP] <- { xpos = 260, ypos = 12, width = 120, height = 25  };
_panelt[g_ModeScript.HUD_MID_BOT] <- { xpos = 260, ypos = 40, width = 120, height = 25  };
_panelt[g_ModeScript.HUD_LEFT_TOP] <- { xpos = 120, ypos = 12, width = 120, height = 25  };
_panelt[g_ModeScript.HUD_LEFT_BOT] <- { xpos = 120, ypos = 40, width = 120, height = 25  };
_panelt[g_ModeScript.HUD_TICKER] <- { xpos = 120, ypos = 70, width = 400, height = 20  };
_panelt[g_ModeScript.HUD_MID_BOX] <- { xpos = 260, ypos = 12, width = 120, height = 53  };
_panelt[g_ModeScript.HUD_FAR_LEFT] <- { xpos = 30, ypos = 12, width = 75, height = 25  };
_panelt[g_ModeScript.HUD_FAR_RIGHT] <- { xpos = 535, ypos = 12, width = 75, height = 25  };
_panelt[g_ModeScript.HUD_SCORE_TITLE] <- { xpos = 100, ypos = 140, width = 440, height = 40  };
_panelt[g_ModeScript.HUD_SCORE_1] <- { xpos = 100, ypos = 210, width = 440, height = 20  };
_panelt[g_ModeScript.HUD_SCORE_2] <- { xpos = 100, ypos = 240, width = 440, height = 20  };
_panelt[g_ModeScript.HUD_SCORE_3] <- { xpos = 100, ypos = 270, width = 440, height = 20  };
_panelt[g_ModeScript.HUD_SCORE_4] <- { xpos = 100, ypos = 300, width = 440, height = 20  };

/**
 * Store HUD variables in the global table
 */
::HUD_RIGHT_TOP <- g_ModeScript.HUD_RIGHT_TOP;
::HUD_RIGHT_BOT <- g_ModeScript.HUD_RIGHT_BOT;
::HUD_MID_TOP <- g_ModeScript.HUD_MID_TOP;
::HUD_MID_BOT <- g_ModeScript.HUD_MID_BOT;
::HUD_LEFT_TOP <- g_ModeScript.HUD_LEFT_TOP;
::HUD_LEFT_BOT <- g_ModeScript.HUD_LEFT_BOT;
::HUD_TICKER <- g_ModeScript.HUD_TICKER;
::HUD_MID_BOX <- g_ModeScript.HUD_MID_BOX;
::HUD_FAR_LEFT <- g_ModeScript.HUD_FAR_LEFT;
::HUD_FAR_RIGHT <- g_ModeScript.HUD_FAR_RIGHT;
::HUD_SCORE_TITLE <- g_ModeScript.HUD_SCORE_TITLE;
::HUD_SCORE_1 <- g_ModeScript.HUD_SCORE_1;
::HUD_SCORE_2 <- g_ModeScript.HUD_SCORE_2;
::HUD_SCORE_3 <- g_ModeScript.HUD_SCORE_3;
::HUD_SCORE_4 <- g_ModeScript.HUD_SCORE_4;

::HUD_FLAG_PRESTR <- g_ModeScript.HUD_FLAG_PRESTR;
::HUD_FLAG_POSTSTR <- g_ModeScript.HUD_FLAG_POSTSTR;
::HUD_FLAG_BEEP <- g_ModeScript.HUD_FLAG_BEEP;
::HUD_FLAG_BLINK <- g_ModeScript.HUD_FLAG_BLINK;
::HUD_FLAG_COUNTDOWN_WARN <- g_ModeScript.HUD_FLAG_COUNTDOWN_WARN;
::HUD_FLAG_NOBG <- g_ModeScript.HUD_FLAG_NOBG;
::HUD_FLAG_ALLOWNEGTIMER <- g_ModeScript.HUD_FLAG_ALLOWNEGTIMER;
::HUD_FLAG_NOTVISIBLE <- g_ModeScript.HUD_FLAG_NOTVISIBLE;
::HUD_FAR_RIGHT <- g_ModeScript.HUD_FAR_RIGHT;
::HUD_FLAG_ALIGN_LEFT <- g_ModeScript.HUD_FLAG_ALIGN_LEFT;
::HUD_FLAG_ALIGN_CENTER <- g_ModeScript.HUD_FLAG_ALIGN_CENTER;
::HUD_FLAG_ALIGN_RIGHT <- g_ModeScript.HUD_FLAG_ALIGN_RIGHT;
::HUD_FLAG_TEAM_SURVIVORS <- g_ModeScript.HUD_FLAG_TEAM_SURVIVORS;
::HUD_FLAG_TEAM_INFECTED <- g_ModeScript.HUD_FLAG_TEAM_INFECTED;
::HUD_FLAG_AS_TIME <- g_ModeScript.HUD_FLAG_AS_TIME;
::HUD_FLAG_TEAM_MASK <- g_ModeScript.HUD_FLAG_TEAM_MASK;

::HUD_SPECIAL_TIMER0 <- g_ModeScript.HUD_SPECIAL_TIMER0;
::HUD_SPECIAL_TIMER1 <- g_ModeScript.HUD_SPECIAL_TIMER1;
::HUD_SPECIAL_TIMER2 <- g_ModeScript.HUD_SPECIAL_TIMER2;
::HUD_SPECIAL_TIMER3 <- g_ModeScript.HUD_SPECIAL_TIMER3;
::HUD_SPECIAL_MAPNAME <- g_ModeScript.HUD_SPECIAL_MAPNAME;
::HUD_SPECIAL_MODENAME <- g_ModeScript.HUD_SPECIAL_MODENAME;
::HUD_SPECIAL_COOLDOWN <- g_ModeScript.HUD_SPECIAL_COOLDOWN;
::HUD_SPECIAL_ROUNDTIME <- g_ModeScript.HUD_SPECIAL_ROUNDTIME;


// Timer enums to be used with HUDManageTimers().
getconsttable()["TIMER_DISABLE"] <- 0;
getconsttable()["TIMER_COUNTUP"] <- 1;
getconsttable()["TIMER_COUNTDOWN"] <- 2;
getconsttable()["TIMER_STOP"] <- 3;
getconsttable()["TIMER_SET"] <- 4;


/**
 * \brief Binds external data in an intuitive way.
 *
 * Suppose you want to display "[some_player] killed [another_player]".
 * E.g. "Luke killed Tiger!" To do that, you can pass in the following specifier:
 *
 * 	HUD.Item someVariable ( "{1} killed {2}!", "Luke", "Tiger" );
 *
 * The {n} specifies the argument number. "Luke" is the first argument, and "Tiger"
 * is the second argument. If you wanted to change the format string to say
 * "Tiger was killed by Luke!", you simply have to change the order like so:
 *
 * 	HUD.Item someVariable ( "{2} was killed by {1}!", "Luke", "Tiger" );
 *
 * You can also get fancy by using SetValue() directly without passing in any
 * default arguments. Here's an example:
 *
 *	HUD.Item someVariable ( "{Victim} was killed by {Attacker}!" );
 *	someVariable.SetValue ( "Attacker", "Luke" );
 *	someVariable.SetValue ( "Victim", "Tiger" );
 *
 * See the API documentation for in-depth examples and how-to.
 */
class ::VSLib.HUD.Item
{
	///////////////////////////////////////////////////////////////////
	// Meta functions
	///////////////////////////////////////////////////////////////////
	
	/**
	 * Creates the HUD item with a format string set to default values.
	 */
	constructor(formatStr, ...)
	{
		_formatstr = null;
		_binddata = {};
		_cachestr = null;
		_modded = true;
		_isbound = false;
		_flags = 0;
		_dynrefcount = 0;
		_hudmode = -1;
		_width = 0.0;
		_height = 0.0;
		_xpos = 0.0;
		_ypos = 0.0;
		_blinktimer = -1;
		_visibletimer = -1;
		
		SetFormatString(formatStr);
		
		for(local i = 0; i < vargv.len(); i++)
			SetValue(i+1, vargv[i]);
	}
	
	/**
	 * Returns the HUD element type.
	 */
	function _typeof()
	{
		return "_VSLib_HUD_Item";
	}
	
	
	///////////////////////////////////////////////////////////////////
	// Class functions
	///////////////////////////////////////////////////////////////////
	
	/**
	 * Sets a new format string
	 */
	function SetFormatString(formatStr)
	{
		_formatstr = formatStr;
	}
	
	/**
	 * Sets a token's value.
	 */
	function SetValue(key, value)
	{
		// Update cache
		_modded = true;
		
		// The token var
		local token = "{" + key + "}";
		
		// The current type of the value
		local newtype = typeof value;
		
		// If this token existed beforehand, get its previous type
		local prevtype = "";
		if (token in _binddata)
			prevtype = typeof _binddata[token];
		
		// If it was a function before, and it's not anymore, down the refcount
		if (prevtype == "function" && newtype != "function")
			_dynrefcount--;
		
		// Otherwise, if it wasn't a func before, but now it is, upcount it
		else if (prevtype != "function" && newtype == "function")
			_dynrefcount++;
			
		// Set the new value
		_binddata[token] <- value;
	}
	
	/**
	 * Get a token's value.
	 */
	function GetValue(key)
	{
		local token = "{" + key + "}";
		
		if (typeof _binddata[token] != "function")
			return _binddata[token];
		else
			return _binddata[token]();
	}
	
	/**
	 * Gets the modified token string
	 */
	function GetString()
	{
		if (!_modded && _dynrefcount <= 0)
			return _cachestr;
		
		_modded = false;
		_cachestr = _formatstr;
		_cachestr = ParseString(_cachestr);
		
		return _cachestr;
	}
	
	/**
	 * Sets the HUD slot for this object. A value between 0 through 14 (inclusive) or Valve's enums.
	 */
	function AttachTo(hudtype)
	{
		Detach();
		
		///////////////////////////////////////////////////////
		// Estimate the approx. sizes and locations
		///////////////////////////////////////////////////////
		
		local basew = _vguiBaseRes.width.tofloat();
		local baseh = _vguiBaseRes.height.tofloat();
		
		_width = _panelt[hudtype].width.tofloat() / basew;
		_height = _panelt[hudtype].height.tofloat() / baseh;
		_xpos = _panelt[hudtype].xpos.tofloat() / basew;
		_ypos = _panelt[hudtype].ypos.tofloat() / baseh;
		
		::VSLib.HUD.Set(hudtype, this);
		
		ChangeHUD(_xpos, _ypos, _width, _height);
	}
	
	/**
	 * Removes the HUD panel for this object
	 */
	function Detach()
	{
		if (IsBound())
			foreach (tval in ::VSLib.HUD._hud.Fields)
				if ("_vslib_item" in tval)
					if (tval._vslib_item == this)
					{
						::VSLib.HUD.Remove(tval.slot); // do not use _hudmode directly
						break;
					}
	}
	
	/**
	 * Returns true if this item is currently bound to a slot.
	 */
	function IsBound()
	{
		return _isbound;
	}
	
	/**
	 * Gets the object's flags
	 */
	function GetFlags()
	{
		return _flags;
	}
	
	/**
	 * Sets the object's flags
	 */
	function SetFlags(newFlags)
	{
		_flags = newFlags;
		
		if (IsBound())
			::VSLib.HUD._hud.Fields[_hudmode].flags <- newFlags;
	}
	
	/**
	 * Changes the alignment of the text
	 */
	function SetTextPosition(alignFlag)
	{
		_flags = _flags & ~(TextAlign.Left | TextAlign.Center | TextAlign.Right);
		SetFlags(_flags | alignFlag);
	}
	
	/**
	 * Stops blinking this object.
	 */
	function StopBlinking()
	{
		::VSLib.Timers.RemoveTimer(_blinktimer);
		_blinktimer = -1;
		SetFlags(_flags & ~(g_ModeScript.HUD_FLAG_BEEP | g_ModeScript.HUD_FLAG_BLINK));
	}
	
	/**
	 * Starts blinking this object.
	 */
	function StartBlinking()
	{
		::VSLib.Timers.RemoveTimer(_blinktimer);
		_blinktimer = -1;
		SetFlags(_flags | g_ModeScript.HUD_FLAG_BEEP | g_ModeScript.HUD_FLAG_BLINK);
	}
	
	/**
	 * Returns true if blinking.
	 */
	function IsBlinking()
	{
		return IsFlagSet(g_ModeScript.HUD_FLAG_BLINK);
	}
	
	/**
	 * Hides this object.
	 */
	function Hide()
	{
		::VSLib.Timers.RemoveTimer(_visibletimer);
		_visibletimer = -1;
		AddFlag(g_ModeScript.HUD_FLAG_NOTVISIBLE);
	}
	
	/**
	 * Shows this object.
	 */
	function Show()
	{
		::VSLib.Timers.RemoveTimer(_visibletimer);
		_visibletimer = -1;
		RemoveFlag(g_ModeScript.HUD_FLAG_NOTVISIBLE);
	}
	
	/**
	 * Returns true if this object is hidden.
	 */
	function IsHidden()
	{
		return IsFlagSet(g_ModeScript.HUD_FLAG_NOTVISIBLE);
	}
	
	/**
	 * Adds a flag.
	 */
	function AddFlag(flag)
	{
		SetFlags(_flags | flag);
	}
	
	/**
	 * Removes a flag.
	 */
	function RemoveFlag(flag)
	{
		SetFlags(_flags & ~flag);
	}
	
	/**
	 * Returns true if a flag is set.
	 */
	function IsFlagSet(flag)
	{
		return (_flags & flag) > 0;
	}
	
	/**
	 * Returns the slot of this object
	 */
	function GetSlot()
	{
		return _hudmode;
	}
	
	/**
	 * Resizes the HUD object
	 */
	function Resize(width, height)
	{
		if (IsBound() && (0.0 <= height) && (height <= 1.0) && (0.0 <= width) && (width <= 1.0))
			HUDPlace(_hudmode, _xpos, _ypos, (_width = width), (_height = height));
	}
	
	/**
	 * Resizes the HUD object's width
	 */
	function SetWidth(width)
	{
		if (IsBound() && (0.0 <= width) && (width <= 1.0))
			HUDPlace(_hudmode, _xpos, _ypos, (_width = width), _height);
	}
	
	/**
	 * Resizes the HUD object's height
	 */
	function SetHeight(height)
	{
		if (IsBound() && (0.0 <= height) && (height <= 1.0))
			HUDPlace(_hudmode, _xpos, _ypos, _width, (_height = height));
	}
	
	/**
	 * Repositions the HUD object
	 */
	function SetPosition(x, y)
	{
		if (IsBound() && (0.0 <= x) && (x <= 1.0) && (0.0 <= y) && (y <= 1.0))
			HUDPlace(_hudmode, (_xpos = x), (_ypos = y), _width, _height);
	}
	
	/**
	 * Repositions the HUD object's X position
	 */
	function SetPositionX(x)
	{
		if (IsBound() && (0.0 <= x) && (x <= 1.0))
			HUDPlace(_hudmode, (_xpos = x), _ypos, _width, _height);
	}
	
	/**
	 * Repositions the HUD object's Y position
	 */
	function SetPositionY(y)
	{
		if (IsBound() && (0.0 <= y) && (y <= 1.0))
			HUDPlace(_hudmode, _xpos, (_ypos = y), _width, _height);
	}
	
	/**
	 * Repositions and resizes the HUD object
	 */
	function ChangeHUD(x, y, width, height)
	{
		if (IsBound() && (0.0 <= height) && (height <= 1.0) && (0.0 <= width) && (width <= 1.0) && (0.0 <= x) && (x <= 1.0) && (0.0 <= y) && (y <= 1.0))
			HUDPlace(_hudmode, (_xpos = x), (_ypos = y), (_width = width), (_height = height));
	}
	
	/**
	 * Centers the HUD object in the middle of the screen without changing its Y coordinate
	 */
	function CenterHorizontal()
	{
		_xpos = (1.0 - _width) / 2;
		SetPositionX(_xpos);
	}
	
	/**
	 * Centers the HUD object in the middle of the screen without changing its X coordinate
	 */
	function CenterVertical()
	{
		_ypos = (1.0 - _height) / 2;
		SetPositionY(_ypos);
	}
	
	/**
	 * Centers the HUD object in the middle of the screen.
	 */
	function CenterScreen()
	{
		_ypos = (1.0 - _height) / 2;
		_xpos = (1.0 - _width) / 2;
		SetPosition(_xpos, _ypos);
	}
	
	/**
	 * Blinks the text for the specified time in seconds
	 */
	function BlinkTime(seconds)
	{
		StartBlinking();
		_blinktimer = ::VSLib.Timers.AddTimer(seconds, 0, @(hudobj) hudobj.StopBlinking(), this);
	}
	
	/**
	 * Shows the GUI panel for the specified time before hiding it again
	 */
	function ShowTime(seconds, detachAfter = false)
	{
		Show();
		
		local function _ShowFunc(params)
		{
			if (params.detach)
				params.hudobj.Detach();
			else
				params.hudobj.Hide();
		}
		
		_visibletimer = ::VSLib.Timers.AddTimer(seconds, 0, _ShowFunc, { hudobj = this, detach = detachAfter });
	}
	
	/**
	 * Returns the current position of the object
	 *
	 * @return A table with keys: x and y
	 */
	function GetPosition()
	{
		return {x = _xpos, y = _ypos};
	}
	
	/**
	 * Returns the current dimensions of the object
	 *
	 * @return A table with keys: width and height
	 */
	function GetSize()
	{
		return {width = _width, height = _height};
	}
	
	/**
	 * Returns the center point of the HUD object
	 */
	function GetCenterPoint()
	{
		return {x = _xpos + (_width / 2), y = _ypos + (_height / 2)};
	}
	
	/**
	 * It can be difficult to think in terms of a fraction (0.0 - 1.0),
	 * so this function attempts to scale native screen resolution positions
	 * to VGUI positions. For example, if you have a 1600 x 900 res screen,
	 * and you want to move the object to x = 400 and y = 300, this function
	 * will convert these coordinates to fractions between 0.0 - 1.0.
	 * The resulting movement should be the same in all screen resolutions
	 * because the calculations are proportional.
	 *
	 * @param x The X position to move to
	 * @param y The Y position to move to
	 * @param resx Your horizontal screen resolution (for example, 1024)
	 * @param resy Your vertical screen resolution (for example, 768)
	 */
	function SetPositionNative(x, y, resx, resy)
	{
		x = x.tofloat();
		y = y.tofloat();
		resx = resx.tofloat();
		resy = resy.tofloat();
		
		local basew = _vguiBaseRes.width.tofloat();
		local baseh = _vguiBaseRes.height.tofloat();
		
		SetPosition ( (x/(resx/basew))/basew, (y/(resy/baseh))/baseh );
	}
	
	/**
	 * @see SetPositionNative
	 * Does practically the same thing, but this time scales for width and height
	 * proportional to a screen resolution.
	 *
	 * @param width The new width
	 * @param height The new height
	 * @param resx Your horizontal screen resolution (for example, 1024)
	 * @param resy Your vertical screen resolution (for example, 768)
	 */
	function ResizeNative(width, height, resx, resy)
	{
		width = width.tofloat();
		height = height.tofloat();
		resx = resx.tofloat();
		resy = resy.tofloat();
		
		local basew = _vguiBaseRes.width.tofloat();
		local baseh = _vguiBaseRes.height.tofloat();
		
		Resize ( (width/(resx/basew))/basew, (height/(resy/baseh))/baseh );
	}
	
	/**
	 * @see SetPositionNative
	 * @see ResizeNative
	 *
	 * Basically combines SetPositionNative() and ResizeNative()
	 *
	 * @param x The X position to move to
	 * @param y The Y position to move to
	 * @param width The new width
	 * @param height The new height
	 * @param resx Your horizontal screen resolution (for example, 1024)
	 * @param resy Your vertical screen resolution (for example, 768)
	 */
	function ChangeHUDNative(x, y, width, height, resx, resy)
	{
		width = width.tofloat();
		height = height.tofloat();
		resx = resx.tofloat();
		resy = resy.tofloat();
		x = x.tofloat();
		y = y.tofloat();
		
		local basew = _vguiBaseRes.width.tofloat();
		local baseh = _vguiBaseRes.height.tofloat();
		
		ChangeHUD ( (x/(resx/basew))/basew, (y/(resy/baseh))/baseh, (width/(resx/basew))/basew, (height/(resy/baseh))/baseh );
	}
	
	/**
	 * Parses the input string.
	 */
	 function ParseString(str)
	 {
		foreach (bindidx, bindval in _binddata)
			str = ::VSLib.Utils.StringReplace(str, bindidx.tostring(), (typeof bindval == "function") ? bindval().tostring() : bindval.tostring());
		return str;
	 }
	
	
	
	///////////////////////////////////////////////////////////////////
	// Class variables
	///////////////////////////////////////////////////////////////////
	_formatstr = null;
	_binddata = {};
	_cachestr = null;
	_modded = true;
	_isbound = false;
	_flags = 0;
	_dynrefcount = 0;
	_hudmode = -1;
	_width = 0.0;
	_height = 0.0;
	_xpos = 0.0;
	_ypos = 0.0;
	_blinktimer = -1;
	_visibletimer = -1;
}


/**
 * This is a HUD item that acts as a countdown. When the countdown is
 * over, it fires a function of your choice.
 */
class ::VSLib.HUD.Countdown extends ::VSLib.HUD.Item
{
	///////////////////////////////////////////////////////////////////
	// Meta functions
	///////////////////////////////////////////////////////////////////
	
	/**
	 * Creates the HUD item with a format string.
	 *
	 * @param formatStr The format string; default will display as "00:14:23" for example
	 * @param minutesOnly If true, hours will add to the minutes; e.g. 01:05:10 will display as 00:65:10
	 */
	constructor(formatStr = "{hrs}:{min}:{sec}", minutesOnly = false)
	{
		SetFormatString(formatStr);
		_minonly = minutesOnly;
	}
	
	///////////////////////////////////////////////////////////////////
	// Member functions
	///////////////////////////////////////////////////////////////////
	
	/**
	 * Starts the countdown from the specified time
	 */
	function Start(func, hours = 0, minutes = 0, seconds = 0)
	{
		hours = hours.tointeger();
		minutes = minutes.tointeger();
		seconds = seconds.tointeger();
		
		if (hours == 0 && minutes == 0 && seconds == 0)
			return;
			
		Stop();
		
		_runtime = (hours * 60 + minutes) * 60 + seconds;
		_starttime = Time();
		_ticking = true;
		_func = func;
		
		_ctimer = ::VSLib.Timers.AddTimer(1, 1, @(hudobj) hudobj.Tick(), this);
	}
	
	/**
	 * Stops and detaches the HUD object.
	 */
	function Detach()
	{
		Stop();
		base.Detach();
	}
	
	/**
	 * Stops the countdown
	 */
	function Stop()
	{
		_ticking = false;
		_func = null;
		_runtime = -1;
		_starttime = -1;
		
		StopBlinking();
		
		::VSLib.Timers.RemoveTimer(_ctimer);
		_ctimer = -1;
	}
	
	/**
	 * Sets a time to begin blinking
	 */
	function BlinkAt(hours = 0, minutes = 0, seconds = 0)
	{
		hours = hours.tointeger();
		minutes = minutes.tointeger();
		seconds = seconds.tointeger();
		
		if (hours == 0 && minutes == 0 && seconds == 0)
			return;
		
		_blinkat = (hours * 60 + minutes) * 60 + seconds;
	}
	
	/**
	 * Calculates time-based mechanisms such as blinking and function calling
	 */
	function Tick()
	{
		local seconds = ceil(_runtime - (Time() - _starttime));
		
		if (seconds == 0)
			if (_func != null)
				_func();
		
		// Accommodate for anim time
		if (_blinkat >= 0 && _blinkat + 1 == seconds)
			StartBlinking();
	}
	
	/**
	 * Returns the full formatted string
	 */
	function GetString()
	{
		return GetTickString(base.GetString());
	}
	
	/**
	 * Returns the current formatted time as a string
	 */
	function GetTickString(strFormated)
	{
		local temp = strFormated;
		
		if (!_ticking)
		{
			temp = ::VSLib.Utils.StringReplace(temp, "{hrs}", "--");
			temp = ::VSLib.Utils.StringReplace(temp, "{min}", "--");
			temp = ::VSLib.Utils.StringReplace(temp, "{sec}", "--");
			return temp;
		}
		
		// Constants
		const SECONDS_IN_HOUR = 3600;
		const SECONDS_IN_MINUTE = 60;
		
		// Modulated values
		local bh = 0;
		local bm = 0;
		local bs = 0;
		
		// Determine the number of seconds left since the start time
		local seconds = ceil(_runtime - (Time() - _starttime));
		if (seconds < 0) seconds = 0;

		// Hours
		if (seconds >= SECONDS_IN_HOUR)
		{
		   bh = ceil(seconds / SECONDS_IN_HOUR);
		   seconds = seconds % SECONDS_IN_HOUR;
		}
		
		// Minutes
		if (seconds >= SECONDS_IN_MINUTE)
		{
		   bm = ceil(seconds / SECONDS_IN_MINUTE);
		   seconds = seconds % SECONDS_IN_MINUTE;
		}

		// Seconds
		bs = seconds;
		
		// Do not count hours if minutes only
		if (_minonly)
		{
			bm += bh * 60;
			bh = 0;
		}
		
		//
		// Build the return string
		// \todo @TODO Use Utils.GetTimeTable() above and use format() to format the 0's below instead of doing it manually
		//
		local modtable = [{id = "{hrs}", val = bh }, { id = "{min}", val = bm }, { id = "{sec}", val = bs }];
		foreach (row in modtable)
		{
			if (row.val == 0)
				temp = ::VSLib.Utils.StringReplace(temp, row.id, "00");
			else if (row.val < 10)
				temp = ::VSLib.Utils.StringReplace(temp, row.id, "0" + row.val);
			else
				temp = ::VSLib.Utils.StringReplace(temp, row.id, row.val.tostring());
		}
		
		return temp;
	}
	 
	
	///////////////////////////////////////////////////////////////////
	// Member variables
	///////////////////////////////////////////////////////////////////
	
	_minonly = false; // Minutes only?
	_ticking = false; // Is the countdown currently running?
	_runtime = -1; // The total time to run
	_func = null; // Func to call when countdown is over
	_starttime = -1; // The starting time
	_ctimer = -1; // The running timer
	_blinkat = 5;
}

/**
 * This is a HUD item that acts as a configurable progress bar.
 * One can easily use this HUD item to display numerical values
 * and percentages. Example uses would be stamina/magic bars,
 * health bars, fuel bars, and whatever else you can think of.
 */
class ::VSLib.HUD.Bar extends ::VSLib.HUD.Item
{
	///////////////////////////////////////////////////////////////////
	// Meta functions
	///////////////////////////////////////////////////////////////////
	
	/**
	 * Creates the HUD item with a format string.
	 *
	 * @param formatStr The format string; default will display as "21% [|||||||.....]" for example
	 * @param initialValue The starting value of this progress bar
	 * @param maxValue The maximum possible value of this progress bar
	 * @param fill The solid block character
	 * @param empty The open block character
	 */
	constructor(formatStr = "{value}% [{bar}]", initialValue = 0, maxValue = 100, width = 50, fill = "|", empty = ".")
	{
		SetFormatString(formatStr);
		_fill = fill;
		_empty = empty;
		SetBarValue(initialValue);
		SetBarMaxValue(maxValue);
		_barwidth = width.tointeger();
	}
	
	
	///////////////////////////////////////////////////////////////////
	// Member functions
	///////////////////////////////////////////////////////////////////
	
	/**
	 * Sets the progress bar's value
	 */
	function SetBarValue(value)
	{
		SetValue("value", value);
	}
	
	/**
	 * Gets the progress bar's value
	 */
	function GetBarValue()
	{
		return GetValue("value");
	}
	
	/**
	 * Gets the progress bar's max value
	 */
	function GetBarMaxValue()
	{
		return GetValue("max");
	}
	
	/**
	 * Returns the full formatted progress bar with text
	 */
	function GetString()
	{
		return ::VSLib.Utils.StringReplace(base.GetString(), "{bar}", ::VSLib.Utils.BuildProgressBar(_barwidth, GetValue("value"), GetValue("max"), _fill, _empty));
	}
	
	/**
	 * Changes the width (number of characters) of the progress bar
	 */
	function SetBarWidth(width)
	{
		_barwidth = width.tointeger();
	}
	
	/**
	 * Returns the bar's width
	 */
	function GetBarWidth()
	{
		return _barwidth;
	}
	
	/**
	 * Changes the character blocks of the progress bar
	 */
	function SetBarCharacters(fill = "|", empty = ".")
	{
		_fill = fill;
		_empty = empty;
	}
	
	/**
	 * Changes the max value of the progress bar
	 */
	function SetBarMaxValue(value)
	{
		SetValue("max", value);
	}
	
	
	///////////////////////////////////////////////////////////////////
	// Member variables
	///////////////////////////////////////////////////////////////////
	
	_fill = null;
	_empty = null;
	_barwidth = 50;
}


/**
 * A very limited menu system. Panel displays for all users (due to HUD limitations) but
 * is navigated by a single person. Right-click to fly through menu options, and left
 * click to select a menu item. Options are key-function pairs. When the user selects
 * an option, the menu is closed and the function associated with the option is called.
 * See the API for example usage.
 *
 * \todo @TODO finish this.
 *
 * @authors shotgunefx
 # added GetSelection()
 * modified DisplayMenu() to retain it's size when redisplayed, added sticky parameter , also added optional resize
 * added ScrollBack() method, unbound unless a button is specified
 * added SetSticky() method to retain selections
 * modified OverrideButtons to take an option third parameter to scroll back (scrollBackBtn), if specified, menu selection won't wrap
 * modified Tick() to support scrollback if specified
 */
class ::VSLib.HUD.Menu extends ::VSLib.HUD.Item
{
	///////////////////////////////////////////////////////////////////
	// Meta stuff
	///////////////////////////////////////////////////////////////////
	
	constructor(formatStr = "[ {name} ]\n\n{title}\n\n{options}", title = "Menu", optionFormatStr = "{num}. {option}", highlightStrPre = "[ ", highlightStrPost = "  ]", sticky = false)
	{
		SetFormatString(formatStr);
		_oformat = optionFormatStr;
		_hpre = highlightStrPre;
		_hpost = highlightStrPost;
		_title = title;
		_options = {};
		_numop = 0;
		_curSel = 0;
		_player = null;
		_sticky = false; // #shotgunefx
		
		::VSLib.Timers.RemoveTimer(_optimer);
		_optimer = -1;
	}
	
	
	///////////////////////////////////////////////////////////////////
	// Member functions
	///////////////////////////////////////////////////////////////////
	/**
	* SetSticky()
	*/
	function SetSticky(sticky)
	{
		_sticky = sticky
	}    /**
	* GetSelection()
	*/
	function GetSelection()
	{
		return _options[_curSel].text
	}
	/**
	 * Sets a new title
	 */
	function SetTitle(title)
	{
		_title = title;
	}
	
	/**
	 * Sets a new option format
	 */
	function SetOptionFormat(optionFormatStr)
	{
		_oformat = optionFormatStr;
	}
	
	/**
	 * Sets new highlight strings
	 */
	function SetHighlightStrings(highlightStrPre, highlightStrPost)
	{
		_hpre = highlightStrPre;
		_hpost = highlightStrPost;
	}
	
	/**
	 * Associates a menu item with a function
	 */
	function AddOption(option, func)
	{
		_options[++_numop] <- { text = option.tostring(), callback = func };
	}
	
	/**
	 * Returns the full formatted menu text
	 */
	function GetString()
	{
		if (_player == null || _numop <= 0)
			return "";
		
		// Build the options list
		local optionsList = "";
		foreach (idx, row in _options)
		{
			local disp = "";
			if (idx == _curSel)
				disp += _hpre;
			disp += _oformat;
			disp = ::VSLib.Utils.StringReplace(disp, "{num}", idx.tostring());
			disp = ::VSLib.Utils.StringReplace(disp, "{option}", row.text);
			disp = ParseString(disp);
			if (idx == _curSel)
				disp += _hpost;
			optionsList += disp + "\n";
		}
		
		// Build return string
		local temp = base.GetString();
		temp = ::VSLib.Utils.StringReplace(temp, "{name}", _player.GetName());
		temp = ::VSLib.Utils.StringReplace(temp, "{title}", _title);
		temp = ::VSLib.Utils.StringReplace(temp, "{options}", optionsList);
		
		return temp;
	}
	
	/**
	 * Closes the menu
	 */
	function CloseMenu()
	{
		::VSLib.Timers.RemoveTimer(_optimer);
		_optimer = -1;
		
		if (!_sticky) // #shotgunefx
			_curSel = 0;
		
		Hide();
	}
	
	/**
	 * Stops and detaches the HUD object.
	 */
	function Detach()
	{
		CloseMenu();
		base.Detach();
	}
	
	/**
	 * Displays the menu and hands over control to a particular player entity.
	 */
	function DisplayMenu(player, attachTo, autoDetach = false,  resize = true)
	{
		if (typeof player != "VSLIB_PLAYER")
			throw "Menu could not be displayed: a non-Player entity was passed; only VSLib.Player entities are supported.";
		
		if (_numop <= 0)
			printf("Warning: Menu will not display-- there are no menu options to display!");
		
		CloseMenu(); // close old menu and hide it
		
		_player = player;
		
		if (_width !=0 && _height !=0) // retain menu sizes when reattaching #shotgunefx
		{
			AttachTo(attachTo,false);
		}
		else
		{
			AttachTo(attachTo);
			if (resize)
				ChangeHUDNative(50, 40, 150, 300, 640, 480);
		}
		
		ResizeHeightByLines();
		SetTextPosition(TextAlign.Left);
		CenterVertical();
		
		_selectBtn = BUTTON_ATTACK;
		_switchBtn = BUTTON_SHOVE;
		
		if (!_sticky || _curSel == 0)
			_curSel++;
		
		_autoDetach = autoDetach;
		
		if (!_manual) // #shotgunefx - don't add timer if this will be driven manually, only used by subclasses
			_optimer = ::VSLib.Timers.AddTimer(0.2, 1, @(hudobj) hudobj.Tick(), this);
		
		Show(); // show the menu
	}
	
	/**
	 * Resizes this HUD item's height depending on the line height.
	 */
	function ResizeHeightByLines()
	{
		local lines = split(GetString(), "\n").len() + 1;
		local baseh = _vguiBaseRes.height.tofloat();
		
		SetHeight( ((22 * lines)/(480/baseh))/baseh );
	}
	
	/**
	 * Overrides the buttons used to detect HUD changes.
	 * You can pass in BUTTON_ATTACK and BUTTON_SHOVE for example.
	 */
	function OverrideButtons(selectBtn, switchBtn, scrollBackBtn = false)
	{
		_selectBtn = selectBtn;
		_switchBtn = switchBtn;
		
		if (scrollBackBtn) /*shotgunefx*/
		{
			_scrollbackbtn = scrollBackBtn
		}
	}
	
	/**
	 * Gathers input data and acts on it.
	 */
	function Tick()
	{
		if (_player.IsPressingButton(_switchBtn))
		{
			Utils.PlaySoundToAll("Menu.Scroll");
			if ((++_curSel) > _numop)
				_curSel = 1;
		}
		else if (_player.IsPressingButton(_selectBtn))
		{
			Utils.PlaySoundToAll("Menu.Select");
			
			local t = { p = _player, idx = _curSel, val = _options[_curSel].text, callb = _options[_curSel].callback };
			::VSLib.Timers.AddTimer(0.1, 0, @(tbl) tbl.callb(tbl.p, tbl.idx, tbl.val), t);
			CloseMenu();
			
			if (_autoDetach)
				Detach();
		}
		else if (_scrollbackbtn && _player.IsPressingButton(_scrollbackbtn) ) /*#shotgunefx*/
		{
			Utils.PlaySoundToAll("Menu.Scroll");
			if ((--_curSel) <= 0)
				_curSel = _numop;
		}
	}
	
	
	///////////////////////////////////////////////////////////////////
	// Member variables
	///////////////////////////////////////////////////////////////////
	
	_oformat = null; // Option string format
	_hpre = null; // Selection identifier pre
	_hpost = null; // Selection identifier post
	_options = {}; // Options table
	_numop = 0; // Number of options currently
	_curSel = 0; // Current id selected
	_player = null; // Player who is controlling the menu
	_optimer = -1; // Timer responsible for updating player input
	_title = null; // What to call the menu
	_autoDetach = false; // Whether or not to auto-detach
	_selectBtn = null;
	_switchBtn = null;
	_scrollbackbtn = null; // #shotgunefx
	_sticky = false;
	_manual = false; // to support manual subclasses
}

/**
 * A scrollable menu. Will display displayNum items at a time.
 * @authors shotgunefx
*/
class ::VSLib.HUD.MenuScrollable extends ::VSLib.HUD.Menu
{
	///////////////////////////////////////////////////////////////////
	// Meta stuff
	///////////////////////////////////////////////////////////////////
	
	constructor(formatStr = "[ {name} ]\n{title}\n{options}", title = "Menu", optionFormatStr = "{num}. {option}", highlightStrPre = "[ ", highlightStrPost = "  ]", displayNum = 4, scrollUpStr = "/\\", scrollDownStr = "\\/")
	{
		SetFormatString(formatStr);
		_oformat = optionFormatStr;
		_hpre = highlightStrPre;
		_hpost = highlightStrPost;
		_title = title;
		_options = {};
		_numop = 0;
		_curSel = 0;
		_player = null;
		::VSLib.Timers.RemoveTimer(_optimer);
		_optimer = -1;
		_displaystart = 1       // @shotgunefx
		_displaynum = displayNum;
		_scrollupstr = scrollUpStr;
		_scrolldownstr = scrollDownStr;
	}
	
	
	function GetString()
	{
		if (_player == null || _numop <= 0)
			return "";
		
		// Build the options list,
		local optionsList = _displaystart > 1 ? _scrollupstr+" (" : "("; // can we scroll up?
		
		local pos_str = ""
		local length = _displaystart + _displaynum  -1;
		if (length <= _options.len() ) // Can we scroll down?
			pos_str = _scrolldownstr;
		else
			length = _options.len()+1;
		
		// add num display
		optionsList += _displaystart+" - "+(length-1)+") of "+_options.len()+"\n";
		
		for(local idx = _displaystart; idx < length; idx++)
		{
			local row = _options[idx];
			local disp = "";
			if (idx == _curSel)
				disp += _hpre;
			
			disp += _oformat;
			disp = ::VSLib.Utils.StringReplace(disp, "{num}", idx.tostring());
			disp = ::VSLib.Utils.StringReplace(disp, "{option}", row.text);
			disp = ParseString(disp);
			if (idx == _curSel)
				disp += _hpost;
			
			optionsList += disp + "\n";
		}
		optionsList += pos_str;
		
		// Build return string
		/* Can't call base.GetString here, as {options} will already be consumed */
		if (_modded || _dynrefcount > 0)
		{
			_modded = false;
			_cachestr = _formatstr;
			_cachestr = ParseString(_cachestr);
		}
		
		local temp =  _cachestr;
		temp = ::VSLib.Utils.StringReplace(temp, "{name}", _player.GetName());
		temp = ::VSLib.Utils.StringReplace(temp, "{title}", _title);
		temp = ::VSLib.Utils.StringReplace(temp, "{options}", optionsList);
		return temp;
	}
	/**
	 * Set number of displayed items
	 */
	function SetDisplayCount(displaycount)
	{
		_displaynum = displaycount+1;
	}
	
	
	/**
	 * Scroll menu down
	 */
	function Scroll()
	{
		Utils.PlaySoundToAll("Menu.Scroll");
		
		if ((++_curSel) > _numop)
		{
			if (_scrollbackbtn)
			{ /*If we have a scroll back button, don't loop, otherwise loop back to 1*/
				_curSel = _numop;
			}
			else
			{
				_curSel = 1;
				_displaystart = 1;
			}
		}
		// does window need to scroll?
		if (_curSel >= _displaystart + _displaynum  -1)
		{
			_displaystart+=1;
			if ( _displaystart + _displaynum > _options.len() + 2 )  // clamp it to end
			{
				_displaystart = _options.len() - _displaynum;
			}
		}
	}
	
	/**
	 * Scroll menu up
	 */
	function ScrollBack()
	{
		Utils.PlaySoundToAll("Menu.Scroll");
		if ((--_curSel) <= 0)
			_curSel = 1;
		
		if (_curSel < _displaystart )
			_displaystart = _curSel;
	}
	
	/**
	 * Gathers input data and acts on it.
	 */
	function Tick()
	{
		if (_player.IsPressingButton(_switchBtn))
		{
			Scroll();
		}
		else if (_player.IsPressingButton(_selectBtn))
		{
			Utils.PlaySoundToAll("Menu.Select");
			
			local t = { p = _player, idx = _curSel, val = _options[_curSel].text, callb = _options[_curSel].callback };
			::VSLib.Timers.AddTimer(0.1, 0, @(tbl) tbl.callb(tbl.p, tbl.idx, tbl.val), t);
			CloseMenu();
			
			if (_autoDetach)
				Detach();
		}
		else if (_scrollbackbtn && _player.IsPressingButton(_scrollbackbtn) ) /*#shotgunefx*/
		{
			ScrollBack();
		}
	}    
	
	///////////////////////////////////////////////////////////////////
	// Member variables
	///////////////////////////////////////////////////////////////////
	_displaystart = 1;
	_displaynum = 4;
	_scrollupstr = "";
	_scrolldownstr = "";
}    

/**
 * A manually advanced menu system to be driven externally ie: game_ui. 
 * @authors shotgunefx
 */
class ::VSLib.HUD.MenuScrollableManual extends ::VSLib.HUD.MenuScrollable
{
	constructor(formatStr = "[ {name} ]\n{title}\n{options}", title = "Menu", optionFormatStr = "{num}. {option}", highlightStrPre = "[ ", highlightStrPost = "  ]", displayNum = 4, scrollUpStr = "/\\", scrollDownStr = "\\/")
	{
		SetFormatString(formatStr);
		_oformat = optionFormatStr;
		_hpre = highlightStrPre;
		_hpost = highlightStrPost;
		_title = title;
		_options = {};
		_numop = 0;
		_curSel = 0;
		_player = null;
		::VSLib.Timers.RemoveTimer(_optimer);
		_optimer = -1;
		_displaystart = 1       // @shotgunefx
		_displaynum = displayNum;
		_scrollupstr = scrollUpStr;
		_scrolldownstr = scrollDownStr;
		_manual = true
	}
	
	
	/**
	 * Select menu item
	 */
	
	function Select()
	{
			Utils.PlaySoundToAll("Menu.Select");
			local t = { p = _player, idx = _curSel, val = _options[_curSel].text, callb = _options[_curSel].callback };
			::VSLib.Timers.AddTimer(0.1, 0, @(tbl) tbl.callb(tbl.p, tbl.idx, tbl.val), t);
			CloseMenu();
			if (_autoDetach)
				Detach();
	}

	/**
	 * Scroll menu down
	
	function Scroll()
	{
		Utils.PlaySoundToAll("Menu.Scroll");


		if ((++_curSel) > _numop)
		{
			_curSel = _numop; // don't autowrap in manually driven menu
		}
		// does window need to scroll?
		if (_curSel >= _displaystart + _displaynum  -1)
			_displaystart+=1
	}
	*/
}

/**
 * Displays a real-time clock.
 *
 * \todo @TODO L4D2 doesn't have the squirrel date() function. Once it's added, this will work.
 */
class ::VSLib.HUD.Clock extends ::VSLib.HUD.Item
{
	///////////////////////////////////////////////////////////////////
	// Meta functions
	///////////////////////////////////////////////////////////////////
	
	constructor(formatStr = "{hour}:{min}:{sec} {am_pm}", is12HourFormat = true, isLocalTime = true)
	{
		SetFormatString(formatStr);
		
		if (isLocalTime)
			_tformat = "l";
		else
			_tformat = "u";
		
		_12hr = is12HourFormat;
	}
	
	
	///////////////////////////////////////////////////////////////////
	// Member functions
	///////////////////////////////////////////////////////////////////
	
	/**
	 * Sets the 12 hr format
	 */
	function Set12HourFormat(is12HourFormat)
	{
		_12hr = is12HourFormat;
	}
	
	/**
	 * Gets if the clock follows a 12 hr format
	 */
	function Is12HourFormat()
	{
		return _12hr;
	}
	
	/**
	 * Sets local or UTC time. Set true for local time, false for UTC
	 */
	function SetTimeFormat(isLocalTime)
	{
		if (isLocalTime)
			_tformat = "l";
		else
			_tformat = "u";
	}
	
	/**
	 * Gets the current time format ("l" for local time, "u" for UTC time)
	 */
	function GetTimeFormat()
	{
		return _tformat;
	}
	
	/**
	 * Returns the formatted text
	 */
	function GetString()
	{
		local d = date(time(), _tformat);
		
		if (_12hr)
		{
			if (d.hour >= 12)
			{
				d.suffix <- "PM";
				d.hour -= 12;
			}
			else
				d.suffix <- "AM";
				
			if (d.hour == 0)
				d.hour = 12;
		}
		else
			d.suffix <- "";
		
		local temp = base.GetString();
		temp = ::VSLib.Utils.StringReplace(temp, "{am_pm}", d.suffix);
		foreach (idx, val in d)
			temp = ::VSLib.Utils.StringReplace(temp, "{" + idx + "}", val);
		
		return temp;
	}
	
	
	///////////////////////////////////////////////////////////////////
	// Vars
	///////////////////////////////////////////////////////////////////
	
	_tformat = null;
	_12hr = false;
}




/**
 * Binds a HUD item to a Valve panel
 */
function VSLib::HUD::Set(hudtype, item)
{
	VSLib.HUD.Remove(hudtype);
	item._isbound = true;
	item._hudmode = hudtype;
	::VSLib.HUD._hud.Fields[hudtype] <- { slot = hudtype, flags = item.GetFlags(), datafunc = @() item.GetString(), _vslib_item = item.weakref() }
}

/**
 * Removes any HUD item bound to a slot
 */
function VSLib::HUD::Remove(hudtype)
{
	foreach (idx, row in ::VSLib.HUD._hud.Fields)
	{
		if (row.slot == hudtype)
		{
			if ("_vslib_item" in row)
			{
				row._vslib_item._isbound = false;
				row._vslib_item._hudmode = -1;
			}
			
			delete ::VSLib.HUD._hud.Fields[idx];
		}
	}
}

/**
 * Returns the item that is currently bound
 */
function VSLib::HUD::Get(hudtype)
{
	if (hudtype in ::VSLib.HUD._hud.Fields)
		if ("_vslib_item" in ::VSLib.HUD._hud.Fields[hudtype])
			return ::VSLib.HUD._hud.Fields[hudtype]._vslib_item;
	return null;
}

/**
 * Returns the HUD layout table
 */
function VSLib::HUD::GetLayout()
{
	return ::VSLib.HUD._hud.weakref();
}


// Load the HUD table
HUDSetLayout( ::VSLib.HUD._hud );


// Add a weak reference to the global table.
::HUD <- ::VSLib.HUD.weakref();