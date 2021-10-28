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
 * \brief Provides many helpful player functions.
 *
 * The Player class works with ::VSLib.EasyLogic.Notifications and builds on the Entity class.
 */
class ::VSLib.Player extends ::VSLib.Entity
{
	constructor(index)
	{
		base.constructor(index);
	}
	
	function _typeof()
	{
		return "VSLIB_PLAYER";
	}
}


// @see DropWeaponSlot
getconsttable()["SLOT_PRIMARY"] <- 0;
getconsttable()["SLOT_SECONDARY"] <- 1;
getconsttable()["SLOT_THROW"] <- 2;
getconsttable()["SLOT_MEDKIT"] <- 3;
getconsttable()["SLOT_PILLS"] <- 4;
getconsttable()["SLOT_CARRIED"] <- 5;
getconsttable()["SLOT_HELD"] <- "Held";

// Hud Element hiding flags for use with m_Local.m_iHideHUD
getconsttable()["HIDEHUD_WEAPONSELECTION"] <- (1 << 0);		// Hide ammo count & weapon selection
getconsttable()["HIDEHUD_FLASHLIGHT"] <- (1 << 1);
getconsttable()["HIDEHUD_ALL"] <- (1 << 2);
getconsttable()["HIDEHUD_HEALTH"] <- (1 << 3);				// Hide health & armor / suit battery
getconsttable()["HIDEHUD_PLAYERDEAD"] <- (1 << 4);			// Hide when local player's dead
getconsttable()["HIDEHUD_NEEDSUIT"] <- (1 << 5);			// Hide when the local player doesn't have the HEV suit
getconsttable()["HIDEHUD_MISCSTATUS"] <- (1 << 6);			// Hide miscellaneous status elements (trains, pickup history, death notices, etc)
getconsttable()["HIDEHUD_CHAT"] <- (1 << 7);				// Hide all communication elements (saytext, voice icon, etc)
getconsttable()["HIDEHUD_CROSSHAIR"] <- (1 << 8);			// Hide crosshairs
getconsttable()["HIDEHUD_VEHICLE_CROSSHAIR"] <- (1 << 9);	// Hide vehicle crosshair
getconsttable()["HIDEHUD_INVEHICLE"] <- (1 << 10);
getconsttable()["HIDEHUD_BONUS_PROGRESS"] <- (1 << 11);		// Hide bonus progress display (for bonus map challenges)

// HUD destination for ClientPrint.
getconsttable()["HUD_PRINTNOTIFY"] <- 1;
getconsttable()["HUD_PRINTCONSOLE"] <- 2;
getconsttable()["HUD_PRINTTALK"] <- 3;
getconsttable()["HUD_PRINTCENTER"] <- 4;



/**
 * Returns true if the player entity is valid or false otherwise.
 */
function VSLib::Player::IsPlayerEntityValid()
{
	if (_ent == null)
		return false;
	
	if (!("IsValid" in _ent))
		return false;
	
	if (!_ent.IsValid())
		return false;
	
	if ("IsPlayer" in _ent)
		return _ent.IsPlayer();
	
	return false;
}

/**
 * Gets the character name (not steam name). E.g. "Nick" or "Rochelle"
 */
function VSLib::Player::GetCharacterName()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return "";
	}
	
	if ( GetSurvivorCharacter() == 4 )
		return "Bill";
	else if ( GetSurvivorCharacter() == 5 )
		return "Zoey";
	else if ( GetSurvivorCharacter() == 6 )
		return "Francis";
	else if ( GetSurvivorCharacter() == 7 )
		return "Louis";
	else if ( GetSurvivorCharacter() > 7 && GetTeam() == 4 )
		return "Survivor";
	
	return g_MapScript.GetCharacterDisplayName(_ent);
}

/**
 * Gets the base character name. E.g. Bill will return "Nick" or Zoey will return "Rochelle"
 */
function VSLib::Player::GetBaseCharacterName()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return "";
	}
	
	if ( GetSurvivorCharacter() == 0 )
		return "Nick";
	else if ( GetSurvivorCharacter() == 1 )
		return "Rochelle";
	else if ( GetSurvivorCharacter() == 2 )
		return "Coach";
	else if ( GetSurvivorCharacter() == 3 )
		return "Ellis";
	
	return GetCharacterName();
}

/**
 * Returns the survivor's filter name.
 */
function VSLib::Player::GetFilterName()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return "";
	}
	
	if (GetPlayerType() != Z_SURVIVOR)
		return "";
	
	if ( GetSurvivorCharacter() == 0 )
		return "!nick";
	else if ( GetSurvivorCharacter() == 1 )
		return "!rochelle";
	else if ( GetSurvivorCharacter() == 2 )
		return "!coach";
	else if ( GetSurvivorCharacter() == 3 )
		return "!ellis";
	else if ( GetSurvivorCharacter() == 4 )
		return "!bill";
	else if ( GetSurvivorCharacter() == 5 )
		return "!zoey";
	else if ( GetSurvivorCharacter() == 6 )
		return "!francis";
	else if ( GetSurvivorCharacter() == 7 )
		return "!louis";
	
	return "";
}

/**
 * Gets the player's Steam ID.
 */
function VSLib::Player::GetSteamID()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return "";
	}
	
	return _ent.GetNetworkIDString();
}

/**
 * Gets the player's Unqiue ID (clean, formatted Steam ID).
 */
function VSLib::Player::GetUniqueID()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return "";
	}
	
	local steamid = GetSteamID();
	steamid = ::VSLib.Utils.StringReplace(steamid, "STEAM_1:", "S");
	steamid = ::VSLib.Utils.StringReplace(steamid, "STEAM_0:", "S");
	steamid = ::VSLib.Utils.StringReplace(steamid, ":", "");
	
	return steamid;
}

/**
 * Gets the player's SteamID64.
 */
function VSLib::Player::GetSteamID64()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return "";
	}
	
	local userid = "_vslUserID_" + GetUserID();
	
	if ( userid in ::VSLib.EasyLogic.UserCache && IsHuman() )
	{
		if ("_xuid" in ::VSLib.EasyLogic.UserCache[userid])
			return ::VSLib.EasyLogic.UserCache[userid]["_xuid"];
	}
	else
	{
		local id = _idx;
		if (!(id in ::VSLib.GlobalCache))
			return "";
		
		if ("_xuid" in ::VSLib.GlobalCache[id])
			return ::VSLib.GlobalCache[id]["_xuid"];
	}
	
	return "";
}

/**
 * Gets the player's IP address.
 */
function VSLib::Player::GetIPAddress()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return "";
	}
	
	local userid = "_vslUserID_" + GetUserID();
	
	if ( userid in ::VSLib.EasyLogic.UserCache && IsHuman() )
	{
		if ("_ip" in ::VSLib.EasyLogic.UserCache[userid])
			return ::VSLib.EasyLogic.UserCache[userid]["_ip"];
	}
	else
	{
		local id = _idx;
		if (!(id in ::VSLib.GlobalCache))
			return "";
		
		if ("_ip" in ::VSLib.GlobalCache[id])
			return ::VSLib.GlobalCache[id]["_ip"];
	}
	
	return "";
}

/**
 * Gets the player's name.
 */
function VSLib::Player::GetName()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return base.GetName();
	}
	
	return _ent.GetPlayerName();
}

/**
 * Returns the player's ping.
 */
function VSLib::Player::GetPing()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if ( !Entities.FindByClassname( null, "terror_player_manager" ) )
		return;
	
	return ::VSLib.Entity("terror_player_manager").GetNetPropInt( "m_iPing", _idx );
}

/**
 * Returns true if the player is the host of a listen server.
 */
function VSLib::Player::IsServerHost()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	if ( !Entities.FindByClassname( null, "terror_player_manager" ) )
		return false;
	
	return ::VSLib.Entity("terror_player_manager").GetNetPropBool( "m_listenServerHost", _idx );
}

/**
 * Returns true if the player is connected to the server.
 */
function VSLib::Player::IsConnected()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	if ( !Entities.FindByClassname( null, "terror_player_manager" ) )
		return false;
	
	return ::VSLib.Entity("terror_player_manager").GetNetPropBool( "m_bConnected", _idx );
}

/**
 * Gets the player's record Survival time.
 */
function VSLib::Player::GetSurvivalRecordTime()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	if ( !Entities.FindByClassname( null, "terror_player_manager" ) )
		return;
	
	return ::VSLib.Entity("terror_player_manager").GetNetPropFloat( "m_flSurvivalRecordTime", _idx );
}

/**
 * Gets the player's top Survival medal.
 */
function VSLib::Player::GetSurvivalTopMedal()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	if ( !Entities.FindByClassname( null, "terror_player_manager" ) )
		return;
	
	return ::VSLib.Entity("terror_player_manager").GetNetPropInt( "m_nSurvivalTopMedal", _idx );
}

/**
 * Returns true if the player is alive.
 */
function VSLib::Player::IsAlive()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	return !_ent.IsDead() && !_ent.IsDying();
}

/**
 * Returns true if the player is dead.
 */
function VSLib::Player::IsDead()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	return _ent.IsDead();
}

/**
 * Returns true if the player is dying.
 */
function VSLib::Player::IsDying()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	return _ent.IsDying();
}

/**
 * Returns true if the player is incapped.
 */
function VSLib::Player::IsIncapacitated()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	return _ent.IsIncapacitated();
}

/**
 * Returns true if the player is being culled
 */
function VSLib::Player::IsCulling()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	return GetNetPropBool( "m_isCulling" );
}

/**
 * Returns true if the player is being relocated
 */
function VSLib::Player::IsRelocating()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	return GetNetPropBool( "m_isRelocating" );
}

/**
 * Returns true if the player is hanging off a ledge.
 */
function VSLib::Player::IsHangingFromLedge()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	return _ent.IsHangingFromLedge();
}

/**
 * Returns true if the player is being held by a Smoker tongue
 */
function VSLib::Player::IsHangingFromTongue()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	return GetNetPropBool( "m_isHangingFromTongue" );
}

/**
 * Returns true if the player is being jockeyed
 */
function VSLib::Player::IsBeingJockeyed()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	return (GetNetPropInt( "m_jockeyAttacker" ) > 0) ? true : false;
}

/**
 * Returns true if the player is a victim of a Hunter pounce
 */
function VSLib::Player::IsPounceVictim()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	return (GetNetPropInt( "m_pounceAttacker" ) > 0) ? true : false;
}

/**
 * Returns true if the player is a victim of a Smoker pull
 */
function VSLib::Player::IsTongueVictim()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	return (GetNetPropInt( "m_tongueOwner" ) > 0) ? true : false;
}

/**
 * Returns true if the player is being carried by a Charger
 */
function VSLib::Player::IsCarryVictim()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	return (GetNetPropInt( "m_carryAttacker" ) > 0) ? true : false;
}

/**
 * Returns true if the player is being pummeled by a Charger
 */
function VSLib::Player::IsPummelVictim()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	return (GetNetPropInt( "m_pummelAttacker" ) > 0) ? true : false;
}

/**
 * Returns true if the player is in ghost mode (i.e. infected ghost).
 */
function VSLib::Player::IsGhost()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	return _ent.IsGhost();
}

/**
 * Returns true if the player is calm.
 */
function VSLib::Player::IsCalm()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	return GetNetPropBool( "m_isCalm" );
}

/**
 * Returns true if the player is going to die.
 */
function VSLib::Player::IsGoingToDie()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	return GetNetPropBool( "m_isGoingToDie" );
}

/**
 * Returns true if the player is the first to enter the rescue vehicle with DirectorOptions.cm_FirstManOut = 1.
 */
function VSLib::Player::IsFirstManOut()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	return GetNetPropBool( "m_bIsFirstManOut" );
}

/**
 * Returns true if the player has visible threats.
 */
function VSLib::Player::HasVisibleThreats()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	return GetNetPropBool( "m_hasVisibleThreats" );
}

/**
 * Returns true if the survivor's glow is enabled.
 */
function VSLib::Player::IsSurvivorGlowEnabled()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	return GetNetPropBool( "m_bSurvivorGlowEnabled" );
}

/**
 * Returns true if the survivors's weapons are being hid.
 */
function VSLib::Player::IsSurvivorPositionHidingWeapons()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	return GetNetPropBool( "m_bSurvivorPositionHidingWeapons" );
}

/**
 * Returns true if the survivor is speaking.
 */
function VSLib::Player::IsSpeaking( sceneFile = "" )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	if (GetPlayerType() != Z_SURVIVOR)
		return;
	
	foreach( scene in ::VSLib.EasyLogic.Objects.OfClassname("instanced_scripted_scene") )
	{
		if ( scene.GetNetPropEntity("m_hOwner").GetEntityHandle() == _ent.GetEntityHandle() )
		{
			if ( sceneFile == "" )
				return true;
			else
			{
				if ( scene.GetNetPropString("m_iszSceneFile").find(sceneFile) != null )
					return true;
			}
		}
	}
	
	return false;
}

/**
 * Returns true if the player is in noclip mode.
 */
function VSLib::Player::IsNoclipping()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	if ( GetNetPropInt( "movetype" ) == 8 )
		return true;
	else
		return false;
}

/**
 * Returns the VSLib::Entity of the player's active weapon.
 */
function VSLib::Player::GetActiveWeapon()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return null;
	}
	
	return ::VSLib.Entity(_ent.GetActiveWeapon());
}

/**
 * Returns the VSLib::Entity of the player's last weapon.
 */
function VSLib::Player::GetLastWeapon()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return null;
	}
	
	return GetNetPropEntity( "m_hLastWeapon" );
}

/**
 * Makes the player reload their active weapon.
 */
function VSLib::Player::ReloadWeapon()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return null;
	}
	
	local weapon = _ent.GetActiveWeapon();
	if (!weapon)
		return;
	
	weapon.Reload();
}

/**
 * Returns the ability of the special infected.
 */
function VSLib::Player::GetAbility()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return null;
	}
	
	return GetNetPropEntity( "m_customAbility" );
}

/**
 * Returns the player's viewmodel.
 */
function VSLib::Player::GetViewModel()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return null;
	}
	
	return GetNetPropEntity( "m_hViewModel" );
}

/**
 * Returns the player's vocalization subject.
 */
function VSLib::Player::GetVocalizationSubject()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return null;
	}
	
	return GetNetPropEntity( "m_vocalizationSubject" );
}

/**
 * Returns the time since the player died.
 */
function VSLib::Player::GetTimeSinceDeath()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local time = GetNetPropFloat( "m_flDeathTime" );
	
	if (time <= 0.0)
		return time;
	
	return Time() - time;
}

/**
 * Returns the team the player is on.
 */
function VSLib::Player::GetVersusTeam()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	return GetNetPropInt( "m_iVersusTeam" );
}

/**
 * Gets the frustration of the human Tank.
 */
function VSLib::Player::GetFrustration()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	return GetNetPropInt( "m_frustration" );
}

/**
 * Returns the player spectating this bot.
 */
function VSLib::Player::GetHumanSpectator()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (!IsHumanSpectating())
		return null;
	
	return ::VSLib.Utils.GetPlayerFromUserID(GetNetPropInt( "m_humanSpectatorUserID" ));
}

/**
 * Returns true if a player is spectating this bot.
 */
function VSLib::Player::IsHumanSpectating()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetNetPropInt( "m_humanSpectatorUserID" ) < 1)
		return false;
	
	return true;
}

/**
 * Returns true if the player is in the starting area of the first map of a campaign.
 */
function VSLib::Player::IsInMissionStartArea()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	return GetNetPropBool( "m_isInMissionStartArea" );
}

/**
 * Returns true if the player is currently in the ending saferoom.
 */
function VSLib::Player::IsInEndingSafeRoom()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if ("_inSafeRoom" in ::VSLib.EasyLogic.Cache[_idx])
		return ::VSLib.EasyLogic.Cache[_idx]._inSafeRoom;
	
	return false;
}

/**
 * Gets the player's spawn location.
 */
function VSLib::Player::GetSpawnLocation()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if ("_startPos" in ::VSLib.EasyLogic.Cache[_idx])
		return ::VSLib.EasyLogic.Cache[_idx]._startPos;
	
	return null;
}

/**
 * Returns true if the player is still around the starting area.
 * Note that they can be outside the saferoom and still AROUND the
 * starting area. This function will return true if they are near
 * where they first spawned.
 */
function VSLib::Player::IsNearStartingArea()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local startVec = GetSpawnLocation();
	if (!startVec)
		return false;
	
	local curpos = GetLocation();
	if (!curpos)
		return false;
	
	return ::VSLib.Utils.CalculateDistance(curpos, startVec) < 600.0;
}

/**
 * Returns the player's last attacker (the last person who hurt this player).
 * Null is returned if the "attacker" is the world or some other invalid object.
 */
function VSLib::Player::GetLastAttacker()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if ("_lastAttacker" in ::VSLib.EasyLogic.Cache[_idx])
		return ::VSLib.EasyLogic.Cache[_idx]._lastAttacker;
	
	return null;
}

/**
 * Returns true if the player has earned some kind of award this round.
 * For example, award 67 is when a player protects another player. If you
 * do HasAward(67), the function will return true if and only if the player
 * has protected another player sometime that round. So, you ask, how do I
 * find out which number is what? Good question! Trial and error. Use
 * EasyLogic.Notifications.OnAwarded hook to find out what awards are
 * given when you do something in-game. Then use the number you find out
 * to do whatever it is that you need to do. You may be thinking that it
 * sounds complicated, but it's easier with VSLib than if you were to do
 * the same without it.
 */
function VSLib::Player::HasAward(award)
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local idx = GetIndex();
	if ("Awards" in ::VSLib.EasyLogic.Cache[idx])
		if (award in ::VSLib.EasyLogic.Cache[idx].Awards)
			return true;
	
	return false;
}

/**
 * Returns the entity or player that last killed this player. If this player
 * has not been killed yet or the killer is an invalid object, returns null.
 */
function VSLib::Player::GetLastKilledBy()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if ("_lastKilledBy" in ::VSLib.EasyLogic.Cache[_idx])
		return ::VSLib.EasyLogic.Cache[_idx]._lastKilledBy;
	
	return null;
}

/**
 * Returns the entity or player that last defibbed this player. If this player
 * has not been defibbed or hasn't been defibbed by a valid player entity, returns null.
 */
function VSLib::Player::GetLastDefibbedBy()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if ("_lastDefibBy" in ::VSLib.EasyLogic.Cache[_idx])
		return ::VSLib.EasyLogic.Cache[_idx]._lastDefibBy;
	
	return null;
}

/**
 * Returns the entity or player that last shoved this player. If this player
 * has not been shoved yet, returns null.
 */
function VSLib::Player::GetLastShovedBy()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if ("_lastShovedBy" in ::VSLib.EasyLogic.Cache[_idx])
		return ::VSLib.EasyLogic.Cache[_idx]._lastShovedBy;
	
	return null;
}

/**
 * Returns the entity that this player last tried to "Use".
 * If the player has not tried to use anything yet, returns null.
 */
function VSLib::Player::GetLastUsed()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if ("_lastUse" in ::VSLib.EasyLogic.Cache[_idx])
		return ::VSLib.Entity(::VSLib.EasyLogic.Cache[_idx]._lastUse._ent);
	
	return null;
}

/**
 * Returns the last ability that this player used.
 * E.g. "ability_lunge" or "ability_tongue" or "ability_vomit" or "ability_charge" or "ability_spit" or "ability_ride"
 * This function is applicable for SI only.
 */
function VSLib::Player::GetLastAbilityUsed()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetTeam() != INFECTED)
		return null;
	
	if ("_lastAbility" in ::VSLib.EasyLogic.Cache[_idx])
		return ::VSLib.EasyLogic.Cache[_idx]._lastAbility;
	
	return null;
}

/**
 * Returns the Player entity of the current attacker, or null if there is no entity
 * attacking this player. Note that this function will only return the current hunter,
 * smoker, charger, or jockey attacker. Boomer, tank, and spitter cannot "continuously"
 * trap the survivor and attack, so they will not be returned. If there is no SI attacking
 * this player, then null is returned. This function is applicable for Survivors only.
 */
function VSLib::Player::GetCurrentAttacker()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetTeam() != SURVIVORS)
		return null;
	
	if ("_curAttker" in ::VSLib.EasyLogic.Cache[_idx])
		return ::VSLib.EasyLogic.Cache[_idx]._curAttker;
	
	return null;
}
	
/**
 * Returns true if the Survivor player is trapped by an SI attacker like smoker,
 * hunter, charger, or jockey.
 */
function VSLib::Player::IsSurvivorTrapped()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	return GetTeam() == SURVIVORS && GetCurrentAttacker() != null;
}


/**
 * Returns the type of player. E.g. Z_SPITTER, Z_TANK, Z_SURVIVOR, Z_HUNTER, Z_JOCKEY, Z_SMOKER, Z_BOOMER, Z_CHARGER, or UNKNOWN.
 */
function VSLib::Player::GetPlayerType()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return UNKNOWN;
	}
	
	if (!("GetZombieType" in _ent))
		return UNKNOWN;
	
	return _ent.GetZombieType();
}

/**
 * Returns true if the button exists in the player's current forced buttons.
 */
function VSLib::Player::HasForcedButton( button )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local buttons = GetNetPropInt( "m_afButtonForced" );
	
	return buttons == ( buttons | button );
}

/**
 * Adds the button to the player's current forced buttons.
 */
function VSLib::Player::ForceButton( button )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local buttons = GetNetPropInt( "m_afButtonForced" );
	
	if ( HasForcedButton(button) )
		return;
	
	SetNetProp( "m_afButtonForced", ( buttons | button ) );
}

/**
 * Removes the button from the player's current forced buttons.
 */
function VSLib::Player::UnforceButton( button )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local buttons = GetNetPropInt( "m_afButtonForced" );
	
	if ( !HasForcedButton(button) )
		return;
	
	SetNetProp( "m_afButtonForced", ( buttons & ~button ) );
}

/**
 * Returns true if the button exists in the player's current disabled buttons.
 */
function VSLib::Player::HasDisabledButton( button )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local buttons = GetNetPropInt( "m_afButtonDisabled" );
	
	return buttons == ( buttons | button );
}

/**
 * Adds the button to the player's current disabled buttons.
 */
function VSLib::Player::DisableButton( button )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local buttons = GetNetPropInt( "m_afButtonDisabled" );
	
	if ( HasDisabledButton(button) )
		return;
	
	SetNetProp( "m_afButtonDisabled", ( buttons | button ) );
}

/**
 * Removes the button from the player's current disabled buttons.
 */
function VSLib::Player::EnableButton( button )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local buttons = GetNetPropInt( "m_afButtonDisabled" );
	
	if ( !HasDisabledButton(button) )
		return;
	
	SetNetProp( "m_afButtonDisabled", ( buttons & ~button ) );
}

/**
 * Incaps the player
 */
function VSLib::Player::Incapacitate( dmgtype = 0, attacker = null )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (IsIncapacitated())
		return;
	
	Damage(GetHealth(), dmgtype, attacker);
	
	if ( !IsIncapacitated() && Entities.FindByClassname( null, "worldspawn" ) )
		Damage(GetHealth(), dmgtype, ::VSLib.Entity("worldspawn"));
}

/**
 * Kills the player.
 */
function VSLib::Player::Kill( dmgtype = 0, attacker = null )
{
	if (IsPlayerEntityValid())
	{
		if ( _ent.IsSurvivor() )
			SetLastStrike();
		Damage(GetHealth(), dmgtype, attacker);
		
		if ( IsAlive() && Entities.FindByClassname( null, "worldspawn" ) )
			Damage(GetHealth(), dmgtype, ::VSLib.Entity("worldspawn"));
	}
	else
		base.Kill();
}

/**
 * Ragdolls the player
 */
function VSLib::Player::Ragdoll( allowDefib = false )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR)
		return;
	
	local origin = GetLocation();
	local angles = GetEyeAngles();
	
	local function VSLib_RemoveDeathModel( args )
	{
		args.player.GetSurvivorDeathModel().KillEntity();
		local ragdoll = ::VSLib.Utils.SpawnRagdoll( args.model, args.origin, args.angles );
		
		if ( args.allowDefib )
		{
			local deathModel = ::VSLib.Utils.CreateEntity("survivor_death_model", ragdoll.GetLocation());
			deathModel.SetNetProp("m_nCharacterType", args.player.GetSurvivorCharacter());
			ragdoll.AttachOther(deathModel, false);
			::VSLib.EasyLogic.SurvivorRagdolls.rawset(args.player.GetIndex(), {});
			::VSLib.EasyLogic.SurvivorRagdolls[args.player.GetIndex()]["Ragdoll"] <- ragdoll;
		}
	}
	
	if ( GetTeam() == 4 )
	{
		Input( "Kill" );
		::VSLib.Utils.SpawnRagdoll( GetModel(), origin, angles );
	}
	else
	{
		if ( IsAlive() )
			Kill();
		if ( GetSurvivorDeathModel() != null )
			VSLib_RemoveDeathModel( { player = this, origin = origin, angles = angles, model = GetModel(), allowDefib = allowDefib } );
		else
			::VSLib.Timers.AddTimer(0.1, false, VSLib_RemoveDeathModel, { player = this, origin = origin, angles = angles, model = GetModel(), allowDefib = allowDefib });
	}
}

/**
 * Shows the player a hint.
 */
function VSLib::Player::ShowHint( text, duration = 5, icon = "icon_tip", binding = "", color = "255 255 255", pulsating = 0, alphapulse = 0, shaking = 0 )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	duration = duration.tofloat();
	if ( binding != "" )
		icon = "use_binding";
	
	local hinttbl =
	{
		hint_allow_nodraw_target = "1",
		hint_alphaoption = alphapulse,
		hint_auto_start = "0",
		hint_binding = binding,
		hint_caption = text.tostring(),
		hint_color = color,
		hint_forcecaption = "0",
		hint_icon_offscreen = icon,
		hint_icon_offset = "0",
		hint_icon_onscreen = icon,
		hint_instance_type = "2",
		hint_nooffscreen = "0",
		hint_pulseoption = pulsating,
		hint_range = "0",
		hint_shakeoption = shaking,
		hint_static = "1",
		hint_target = "",
		hint_timeout = duration,
		targetname = "vslib_tmp_" + UniqueString(),
	};
	
	local hint = ::VSLib.Utils.CreateEntity("env_instructor_hint", Vector(0, 0, 0), QAngle(0, 0, 0), hinttbl);
	
	hint.Input("ShowHint", "", 0, this);
	
	if ( duration > 0 )
		hint.Input("Kill", "", duration);
}

/**
 * Returns true if this player can see the inputted location in their vision.
 * 
 * @param pos         The vector location that you want to check if the player can see.
 * @param tolerance   The tolerence of the result. 75 is the default Source field of view.
 */
function VSLib::Player::CanSeeLocation(targetPos, tolerance = 50)
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local clientPos = GetEyePosition();
	local clientToTargetVec = targetPos - clientPos;
	local clientAimVector = GetEyeAngles().Forward();
	
	local angToFind = acos(::VSLib.Utils.VectorDotProduct(clientAimVector, clientToTargetVec) / (clientAimVector.Length() * clientToTargetVec.Length())) * 360 / 2 / 3.14159265;
	
	if (angToFind < tolerance)
		return true;
	else
		return false;
}

/**
 * Returns true if this player can see the inputted entity.
 */
function VSLib::Player::CanSeeOtherEntity(otherEntity, tolerance = 50)
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	// First check whether the player is even looking in its direction
	if (!CanSeeLocation(otherEntity.GetLocation(), tolerance))
		return false;
	
	// Next check to make sure it's not behind a wall or something
	local m_trace = { start = GetEyePosition(), end = otherEntity.GetLocation(), ignore = _ent, mask = TRACE_MASK_SHOT };
	TraceLine(m_trace);
	
	if (!m_trace.hit || m_trace.enthit == null || m_trace.enthit == _ent)
		return false;
	
	if (m_trace.enthit.GetClassname() == "worldspawn" || !m_trace.enthit.IsValid())
		return false;
		
	if (m_trace.enthit == otherEntity.GetBaseEntity())
		return true;
	
	return false;
}

/**
 * Returns true if this player can trace a line from the eyes to the specified location.
 */
function VSLib::Player::CanTraceToLocation(finishPos, traceMask = MASK_NPCWORLDSTATIC)
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local begin = GetEyePosition();
	local finish = finishPos;
	
	local m_trace = { start = begin, end = finish, ignore = _ent, mask = traceMask };
	TraceLine(m_trace);
	
	if (::VSLib.Utils.AreVectorsEqual(m_trace.pos, finish))
		return true;
	
	return false;
}

/**
 * Sends a client command to the player entity.
 * \todo @TODO Doesn't work, need to fix.
 */
function VSLib::Player::ClientCommand(str)
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local cl_cmd = ::VSLib.Utils.CreateEntity( "point_clientcommand", GetLocation() );
	if (!cl_cmd)
	{
		printf("VSLib Error: Could not exec cl_cmd; entity is invalid!");
		return;
	}
	if (!cl_cmd.IsEntityValid())
	{
		printf("VSLib Error: Could not exec cl_cmd; entity is invalid!");
		return;
	}
	cl_cmd.Input("Command", str, 0, _ent);
	cl_cmd.Kill();
}

/**
 * Changes the flashlight state.
 */
function VSLib::Player::SetFlashlight(turnFlashOn)
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (turnFlashOn)
		SetEffects(4);
	else
		SetEffects(0);
}

/**
 * Sets the player's health buffer.
 */
function VSLib::Player::SetHealthBuffer(value)
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	_ent.SetHealthBuffer(value);
}

/**
 * Switches the survivor's health from permanent to temporary and vice-versa.
 */
function VSLib::Player::SwitchHealth(hpType = "")
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR || typeof hpType != "string")
		return;
	
	hpType = hpType.tolower();
	
	if ( hpType.find("perm") != null )
	{
		SetRawHealth(GetHealth());
		SetHealthBuffer(0);
	}
	else if ( hpType.find("temp") != null )
	{
		SetHealthBuffer(GetHealth());
		SetRawHealth(1);
	}
	else
	{
		if ( GetRawHealth() > 1 )
		{
			SetHealthBuffer(GetHealth());
			SetRawHealth(1);
		}
		else
		{
			SetRawHealth(GetHealth());
			SetHealthBuffer(0);
		}
	}
}

/**
 * Sets the player's friction.
 */
function VSLib::Player::SetFriction(value)
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	_ent.SetFriction(value);
}

/**
 * Sets the player's gravity.
 */
function VSLib::Player::SetGravity(value)
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	_ent.SetGravity(value);
}

/**
 * Drops a weapon from a slot.
 *
 * You can use global constants SLOT_PRIMARY, SLOT_SECONDARY, SLOT_THROW,
 * SLOT_MEDKIT (also works for defibs), SLOT_PILLS (also works for adrenaline etc)
 */
function VSLib::Player::DropWeaponSlot(slot)
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if ( slot != "Held" )
		slot = "slot" + slot;
	local t = GetHeldItems();
	
	if (t && slot in t)
		t[slot].Kill();
}

/**
 * Drops all held weapons
 */
function VSLib::Player::DropAllWeapons()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	
	local t = GetHeldItems();
	
	if (t)
		foreach (ent in t)
			ent.Kill();
}

/**
 * Gets the player's health buffer.
 */
function VSLib::Player::GetHealthBuffer()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	return _ent.GetHealthBuffer();
}

/**
 * Gets the player's valve inventory (molotov, weapons, pills, etc).
 */
function VSLib::Player::GetHeldItems()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local t = {};
	local table = {};
	GetInvTable(_ent, table);
	
	foreach( slot, item in table )
		t[slot] <- ::VSLib.Entity(item);
	
	return t;
}

/**
 * Gets the position where the player last died, or null if the player has not died yet
 */
function VSLib::Player::GetLastDeathLocation()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if ("_deathPos" in ::VSLib.EasyLogic.Cache[_idx])
		return ::VSLib.EasyLogic.Cache[_idx]._deathPos;
}

/**
 * Sets the player's revive count
 */
function VSLib::Player::SetReviveCount(count)
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	_ent.SetReviveCount(count);
}

/**
 * Gets the player's revive count
 */
function VSLib::Player::GetReviveCount()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	return GetNetPropInt( "m_currentReviveCount" );
}

/**
 * Get the amount of times the survivor has been incapacitated
 */
function VSLib::Player::GetIncapacitatedCount()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	return GetReviveCount();
}

/**
 * Returns true if the survivor is black & white
 */
function VSLib::Player::IsLastStrike()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR)
		return;
	
	return GetReviveCount() == ::VSLib.Utils.GetMaxIncapCount();
}

/**
 * Makes the player black & white.
 */
function VSLib::Player::SetLastStrike()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR)
		return;
	
	SetReviveCount(::VSLib.Utils.GetMaxIncapCount());
}

/**
 * Revives a player (also checks if player is incapped first).
 * Returns true if the player was revived.
 */
function VSLib::Player::Revive()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	if (IsIncapacitated())
	{
		_ent.ReviveFromIncap();
		return true;
	}
	
	return false;
}

/**
 * Defibs a dead player (also checks if player is dead first).
 * Returns true if the player was defibbed.
 */
function VSLib::Player::Defib()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	if (IsDead() || IsDying())
	{
		_ent.ReviveByDefib();
		
		local idx = GetIndex();
		if ( idx in ::VSLib.EasyLogic.SurvivorRagdolls )
		{
			::VSLib.EasyLogic.SurvivorRagdolls[idx]["Ragdoll"].Kill();
			::VSLib.EasyLogic.SurvivorRagdolls.rawdelete(idx);
		}
		
		foreach (func in ::VSLib.EasyLogic.Notifications.OnScriptDefib)
			func(this);
		
		return true;
	}
	
	return false;
}

/**
 * Returns true if a player is currently inside a rescue closet.
 */
function VSLib::Player::IsInCloset()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	if (GetPlayerType() != Z_SURVIVOR)
		return false;
	
	foreach( rescue in ::VSLib.EasyLogic.Objects.OfClassname("info_survivor_rescue") )
	{
		local survivor = rescue.GetNetPropEntity( "m_survivor" );
		
		if ( survivor != null )
		{
			if ( survivor.GetEntityHandle() == _ent.GetEntityHandle() )
				return true;
		}
	}
	
	return false;
}

/**
 * Rescues a player from a rescue closet.
 * Returns true if the player was successfully rescued.
 */
function VSLib::Player::Rescue()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	if (GetPlayerType() != Z_SURVIVOR)
		return false;
	
	foreach( rescue in ::VSLib.EasyLogic.Objects.OfClassname("info_survivor_rescue") )
	{
		local survivor = rescue.GetNetPropEntity( "m_survivor" );
		
		if ( survivor != null )
		{
			if ( survivor.GetEntityHandle() == _ent.GetEntityHandle() )
			{
				rescue.Input( "Rescue" );
				return true;
			}
		}
	}
	
	return false;
}


/**
 * Gets the last player who vomited this player, or returns null if the player
 * has not been vomited on yet OR has not been vomited on by a valid player
 */
function VSLib::Player::GetLastVomitedBy()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if(_idx in ::VSLib.EasyLogic.Cache)
		if ("_lastVomitedBy" in ::VSLib.EasyLogic.Cache[_idx])
			return ::VSLib.EasyLogic.Cache[_idx]._lastVomitedBy;
}

/**
 * Returns true if this player was ever vomited this round
 */
function VSLib::Player::WasEverVomited()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	if(_idx in ::VSLib.EasyLogic.Cache)
		if ("_wasVomited" in ::VSLib.EasyLogic.Cache[_idx])
			return ::VSLib.EasyLogic.Cache[_idx]._wasVomited;
	
	return false;
}

/**
 * Staggers this entity
 */
function VSLib::Player::Stagger()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	_ent.Stagger( Vector(0,0,0) );
}

/**
 * Staggers this entity away from another entity
 */
function VSLib::Player::StaggerAwayFromEntity(otherEnt)
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local loc = otherEnt.GetLocation();
	if (loc != null) _ent.Stagger( loc );
}

/**
 * Staggers this entity away from another location
 */
function VSLib::Player::StaggerAwayFromLocation(loc)
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	_ent.Stagger( loc );
}

/**
 * Gives the player an upgrade
 */
function VSLib::Player::GiveUpgrade(upgrade)
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	_ent.GiveUpgrade( upgrade ) ;
}

/**
 * Removes the player's upgrade
 */
function VSLib::Player::RemoveUpgrade(upgrade)
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	_ent.RemoveUpgrade( upgrade ) ;
}

/**
 * Returns true if the player is a tank and is frustrated
 */
function VSLib::Player::IsFrustrated()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	if (GetPlayerType() != Z_TANK)
		return false;
	
	if(_idx in ::VSLib.EasyLogic.Cache)
		if ("_isFrustrated" in ::VSLib.EasyLogic.Cache[_idx])
			return ::VSLib.EasyLogic.Cache[_idx]._isFrustrated;
}

/**
 * Returns true if the player is a female boomer
 */
function VSLib::Player::IsBoomette()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	if (GetPlayerType() != Z_BOOMER)
		return false;
	
	if ("_isBoomette" in ::VSLib.EasyLogic.Cache[_idx])
		return ::VSLib.EasyLogic.Cache[_idx]._isBoomette;
	
	return false;
}

/**
 * Returns true if the boomer is a leaker
 */
function VSLib::Player::IsLeaker()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	if (GetPlayerType() != Z_BOOMER)
		return false;
	
	if ("_isLeaker" in ::VSLib.EasyLogic.Cache[_idx])
		return ::VSLib.EasyLogic.Cache[_idx]._isLeaker;
	
	return false;
}

/**
 * Gives the entity an adrenaline effect
 */
function VSLib::Player::GiveAdrenaline( time )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	_ent.UseAdrenaline( time ) ;
}

/**
 * Returns true if the survivor is currently under the effect of adrenaline
 */
function VSLib::Player::IsAdrenalineActive()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	return GetNetPropBool( "m_bAdrenalineActive" );
}

/**
 * Returns true if the player was present at the start of the survival round
 */
function VSLib::Player::WasPresentAtSurvivalStart()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	return GetNetPropBool( "m_bWasPresentAtSurvivalStart" );
}

/**
 * Returns true if the player is currently using a mounted gun
 */
function VSLib::Player::IsUsingMountedGun()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	return GetNetPropBool( "m_usingMountedGun" ) || GetNetPropBool( "m_usingMountedWeapon" );
}

/**
 * Gets the userid of the player
 */
function VSLib::Player::GetUserID()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	return _ent.GetPlayerUserId();
}

/**
 * Gets the survivor slot
 */
function VSLib::Player::GetSurvivorSlot()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	return _ent.GetSurvivorSlot();
}

/**
 * Gets the survivor_death_model associated with the survivor
 */
function VSLib::Player::GetSurvivorDeathModel()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR)
		return null;
	
	foreach( death_model in ::VSLib.EasyLogic.Objects.OfClassname("survivor_death_model") )
	{
		if ( death_model.GetNetPropInt("m_nCharacterType") == GetNetPropInt("m_survivorCharacter") )
			return death_model;
	}
	
	return null;
}

/**
 * Get the survivor's current intensity value
 */
function VSLib::Player::GetIntensity()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR)
		return;
	
	return GetNetPropInt( "m_clientIntensity" );
}

/**
 * Vomits on the player
 */
function VSLib::Player::Vomit( duration = null )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	_ent.HitWithVomit();
	if ( duration != null )
		SetNetProp( "m_itTimer.m_timestamp", Time() + duration.tofloat() );
}

/**
 * Gives ammo
 */
function VSLib::Player::GiveAmmo( amount )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	_ent.GiveAmmo(amount.tointeger());
}

/**
 * Gets the player's max primary ammo
 */
function VSLib::Player::GetMaxPrimaryAmmo()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local t = GetHeldItems();
	
	if (t && "slot0" in t)
	{
		return t["slot0"].GetMaxAmmo();
	}
}

/**
 * Gets the player's primary ammo
 */
function VSLib::Player::GetPrimaryAmmo()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local t = GetHeldItems();
	
	if (t && "slot0" in t)
	{
		return t["slot0"].GetAmmo();
	}
}

/**
 * Sets the player's primary ammo
 */
function VSLib::Player::SetPrimaryAmmo( amount )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local t = GetHeldItems();
	
	if (t && "slot0" in t)
	{
		SetNetProp( "m_iAmmo", amount.tointeger(), t["slot0"].GetNetPropInt( "m_iPrimaryAmmoType" ) );
	}
}

/**
 * Gets the player's primary ammo
 */
function VSLib::Player::GetPrimaryClip()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local t = GetHeldItems();
	
	if (t && "slot0" in t)
	{
		return t["slot0"].GetClip();
	}
}

/**
 * Sets the player's primary ammo
 */
function VSLib::Player::SetPrimaryClip( amount )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local t = GetHeldItems();
	
	if (t && "slot0" in t)
	{
		t["slot0"].SetNetProp( "m_iClip1", amount.tointeger() );
	}
}

/**
 * Gets the player's current primary upgrades
 */
function VSLib::Player::GetPrimaryUpgrades()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local t = GetHeldItems();
	
	if (t && "slot0" in t)
	{
		return t["slot0"].GetUpgrades();
	}
}

/**
 * Sets the player's current primary upgrades
 */
function VSLib::Player::SetPrimaryUpgrades( amount )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local t = GetHeldItems();
	
	if (t && "slot0" in t)
	{
		t["slot0"].SetUpgrades( amount );
	}
}

/**
 * Returns true if the upgrade exists in the player's current primary upgrades
 */
function VSLib::Player::HasPrimaryUpgrade( upgrade )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local t = GetHeldItems();
	
	if (t && "slot0" in t)
	{
		return t["slot0"].HasUpgrade( upgrade );
	}
}

/**
 * Adds the upgrade to the player's current primary upgrades
 */
function VSLib::Player::AddPrimaryUpgrade( upgrade )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local t = GetHeldItems();
	
	if (t && "slot0" in t)
	{
		t["slot0"].AddUpgrade( upgrade );
	}
}

/**
 * Removes the upgrade from the player's current primary upgrades
 */
function VSLib::Player::RemovePrimaryUpgrade( upgrade )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local t = GetHeldItems();
	
	if (t && "slot0" in t)
	{
		t["slot0"].RemoveUpgrade( upgrade );
	}
}

/**
 * Get the amount of zombies the survivor has killed
 */
function VSLib::Player::GetZombiesKilled()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR)
		return;
	
	if ( !("_zombiesKilled" in ::VSLib.EasyLogic.Cache[_idx]) )
		return 0;
	
	return ::VSLib.EasyLogic.Cache[_idx]._zombiesKilled;
}

/**
 * Get the amount of zombies the survivor has killed while being incapacitated
 */
function VSLib::Player::GetZombiesKilledWhileIncapacitated()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR)
		return;
	
	if ( !("_zombiesKilledWhileIncapacitated" in ::VSLib.EasyLogic.Cache[_idx]) )
		return 0;
	
	return ::VSLib.EasyLogic.Cache[_idx]._zombiesKilledWhileIncapacitated;
}

/**
 * Gets a valid path point within a radius
 */
function VSLib::Player::GetNearbyLocation( radius )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	return _ent.TryGetPathableLocationWithin(radius);
}

/**
 * Gets flow distance
 */
function VSLib::Player::GetFlowDistance()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	return g_MapScript.GetCurrentFlowDistanceForPlayer(_ent);
}

/**
 * Gets flow percent
 */
function VSLib::Player::GetFlowPercent()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	return g_MapScript.GetCurrentFlowPercentForPlayer(_ent);
}

/**
 * Gets the client convar as a string.
 * Only works with client convars with the FCVAR_USERINFO flag.
 */
function VSLib::Player::GetClientConvarValue( name )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	return Convars.GetClientConvarValue(name, _idx);
}

/**
 * Sets a USERINFO client ConVar for a fakeclient.
 * Only works with client convars with the FCVAR_USERINFO flag.
 */
function VSLib::Player::SetFakeClientConvarValue( name, value )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	SetFakeClientConVarValue(_ent, name, value);
}

/**
 * Gets the player's current stats.
 */
function VSLib::Player::GetStats()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local t = {};
	
	t["m_checkpointAwardCounts"] <- GetNetPropInt("m_checkpointAwardCounts");
	t["m_missionAwardCounts"] <- GetNetPropInt("m_missionAwardCounts");
	t["m_checkpointZombieKills"] <- GetNetPropInt("m_checkpointZombieKills");
	t["m_missionZombieKills"] <- GetNetPropInt("m_missionZombieKills");
	t["m_checkpointSurvivorDamage"] <- GetNetPropInt("m_checkpointSurvivorDamage");
	t["m_missionSurvivorDamage"] <- GetNetPropInt("m_missionSurvivorDamage");
	t["m_checkpointMedkitsUsed"] <- GetNetPropInt("m_checkpointMedkitsUsed");
	t["m_missionMedkitsUsed"] <- GetNetPropInt("m_missionMedkitsUsed");
	t["m_checkpointPillsUsed"] <- GetNetPropInt("m_checkpointPillsUsed");
	t["m_missionPillsUsed"] <- GetNetPropInt("m_missionPillsUsed");
	t["m_checkpointMolotovsUsed"] <- GetNetPropInt("m_checkpointMolotovsUsed");
	t["m_missionMolotovsUsed"] <- GetNetPropInt("m_missionMolotovsUsed");
	t["m_checkpointPipebombsUsed"] <- GetNetPropInt("m_checkpointPipebombsUsed");
	t["m_missionPipebombsUsed"] <- GetNetPropInt("m_missionPipebombsUsed");
	t["m_checkpointBoomerBilesUsed"] <- GetNetPropInt("m_checkpointBoomerBilesUsed");
	t["m_missionBoomerBilesUsed"] <- GetNetPropInt("m_missionBoomerBilesUsed");
	t["m_checkpointAdrenalinesUsed"] <- GetNetPropInt("m_checkpointAdrenalinesUsed");
	t["m_missionAdrenalinesUsed"] <- GetNetPropInt("m_missionAdrenalinesUsed");
	t["m_checkpointDefibrillatorsUsed"] <- GetNetPropInt("m_checkpointDefibrillatorsUsed");
	t["m_missionDefibrillatorsUsed"] <- GetNetPropInt("m_missionDefibrillatorsUsed");
	t["m_checkpointDamageTaken"] <- GetNetPropInt("m_checkpointDamageTaken");
	t["m_missionDamageTaken"] <- GetNetPropInt("m_missionDamageTaken");
	t["m_checkpointReviveOtherCount"] <- GetNetPropInt("m_checkpointReviveOtherCount");
	t["m_missionReviveOtherCount"] <- GetNetPropInt("m_missionReviveOtherCount");
	t["m_checkpointFirstAidShared"] <- GetNetPropInt("m_checkpointFirstAidShared");
	t["m_missionFirstAidShared"] <- GetNetPropInt("m_missionFirstAidShared");
	t["m_checkpointIncaps"] <- GetNetPropInt("m_checkpointIncaps");
	t["m_missionIncaps"] <- GetNetPropInt("m_missionIncaps");
	t["m_checkpointDamageToTank"] <- GetNetPropInt("m_checkpointDamageToTank");
	t["m_checkpointDamageToWitch"] <- GetNetPropInt("m_checkpointDamageToWitch");
	t["m_missionAccuracy"] <- GetNetPropInt("m_missionAccuracy");
	t["m_checkpointHeadshots"] <- GetNetPropInt("m_checkpointHeadshots");
	t["m_checkpointHeadshotAccuracy"] <- GetNetPropInt("m_checkpointHeadshotAccuracy");
	t["m_missionHeadshotAccuracy"] <- GetNetPropInt("m_missionHeadshotAccuracy");
	t["m_checkpointDeaths"] <- GetNetPropInt("m_checkpointDeaths");
	t["m_missionDeaths"] <- GetNetPropInt("m_missionDeaths");
	t["m_checkpointMeleeKills"] <- GetNetPropInt("m_checkpointMeleeKills");
	t["m_missionMeleeKills"] <- GetNetPropInt("m_missionMeleeKills");
	t["m_checkpointPZIncaps"] <- GetNetPropInt("m_checkpointPZIncaps");
	t["m_checkpointPZTankDamage"] <- GetNetPropInt("m_checkpointPZTankDamage");
	t["m_checkpointPZHunterDamage"] <- GetNetPropInt("m_checkpointPZHunterDamage");
	t["m_checkpointPZSmokerDamage"] <- GetNetPropInt("m_checkpointPZSmokerDamage");
	t["m_checkpointPZBoomerDamage"] <- GetNetPropInt("m_checkpointPZBoomerDamage");
	t["m_checkpointPZJockeyDamage"] <- GetNetPropInt("m_checkpointPZJockeyDamage");
	t["m_checkpointPZSpitterDamage"] <- GetNetPropInt("m_checkpointPZSpitterDamage");
	t["m_checkpointPZChargerDamage"] <- GetNetPropInt("m_checkpointPZChargerDamage");
	t["m_checkpointPZKills"] <- GetNetPropInt("m_checkpointPZKills");
	t["m_checkpointPZPounces"] <- GetNetPropInt("m_checkpointPZPounces");
	t["m_checkpointPZPushes"] <- GetNetPropInt("m_checkpointPZPushes");
	t["m_checkpointPZTankPunches"] <- GetNetPropInt("m_checkpointPZTankPunches");
	t["m_checkpointPZTankThrows"] <- GetNetPropInt("m_checkpointPZTankThrows");
	t["m_checkpointPZHung"] <- GetNetPropInt("m_checkpointPZHung");
	t["m_checkpointPZPulled"] <- GetNetPropInt("m_checkpointPZPulled");
	t["m_checkpointPZBombed"] <- GetNetPropInt("m_checkpointPZBombed");
	t["m_checkpointPZVomited"] <- GetNetPropInt("m_checkpointPZVomited");
	t["m_checkpointPZHighestDmgPounce"] <- GetNetPropInt("m_checkpointPZHighestDmgPounce");
	t["m_checkpointPZLongestSmokerGrab"] <- GetNetPropInt("m_checkpointPZLongestSmokerGrab");
	t["m_checkpointPZLongestJockeyRide"] <- GetNetPropInt("m_checkpointPZLongestJockeyRide");
	t["m_checkpointPZNumChargeVictims"] <- GetNetPropInt("m_checkpointPZNumChargeVictims");
	
	return t;
}

/**
 * Returns true if the survivor is healing
 */
function VSLib::Player::IsHealing()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR)
		return false;
	
	if ("_isHealing" in ::VSLib.EasyLogic.Cache[_idx])
		return ::VSLib.EasyLogic.Cache[_idx]._isHealing;
	
	return false;
}

/**
 * Returns true if the survivor is being healed
 */
function VSLib::Player::IsBeingHealed()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR)
		return false;
	
	if ("_isBeingHealed" in ::VSLib.EasyLogic.Cache[_idx])
		return ::VSLib.EasyLogic.Cache[_idx]._isBeingHealed;
	
	return false;
}

/**
 * Returns true if the survivor is in the rescue vehicle.
 */
function VSLib::Player::IsInRescue()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR)
		return;
	
	if ("_inRescue" in ::VSLib.EasyLogic.Cache[_idx])
		return ::VSLib.EasyLogic.Cache[_idx]._inRescue;
	
	return false;
}

/**
 * Prints a chat message as if this player typed it in chat
 */
function VSLib::Player::Say( str, teamOnly = false )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	g_MapScript.Say(_ent, str.tostring(), teamOnly);
}

/**
 * Prints a client message to this player
 */
function VSLib::Player::Print( str, destination = 3 )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	ClientPrint(_ent, destination, str.tostring());
}

/**
 * Plays a sound file to the player
 */
function VSLib::Player::PlaySound( file )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (file == "" || !file)
		return;
	
	if ( !(file in ::EasyLogic.PrecachedSounds) )
	{
		printf("VSLib: Precaching named sound: %s", file);
		_ent.PrecacheScriptSound(file);
		::EasyLogic.PrecachedSounds[file] <- 1;
	}
	
	g_MapScript.EmitSoundOnClient(file, _ent);
}


/**
 * Makes the player speak a scene
 */
function VSLib::Player::Speak( scene, delay = 0 )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	delay = delay.tofloat();
	
	local function SpeakScene( params )
	{
		local Name = params.player.GetActorName();
		local Scene = "";
		
		if ( params.scene.find("scenes") != null )
		{
			if ( params.scene.find(".vcd") != null )
				Scene = params.scene;
			else
				Scene = params.scene + ".vcd";
		}
		else
		{
			if ( params.scene.find(".vcd") != null )
				Scene = "scenes/" + Name + "/" + params.scene;
			else
				Scene = "scenes/" + Name + "/" + params.scene + ".vcd";
		}
		
		local vsl_speak =
		[
			{
				name = "VSLibScene",
				criteria =
				[
					[ "Concept", "VSLibScene" ],
					[ "Coughing", 0 ],
					[ "Who", Name ],
				],
				responses =
				[
					{
						scenename = Scene,
					}
				],
				group_params = ::VSLib.ResponseRules.GroupParams({ permitrepeats = true, sequential = false, norepeat = false })
			},
		]
		ResponseRules.ProcessRules( vsl_speak );
		QueueSpeak( params.player.GetBaseEntity(), "VSLibScene", 0.0, "" );
	}
	
	if ( delay > 0 )
		::VSLib.Timers.AddTimer(delay, false, SpeakScene { scene = scene, player = this });
	else
		SpeakScene( { scene = scene, player = this } );
}

/**
 * Gives a random melee weapon.
 */
function VSLib::Player::GiveRandomMelee( )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local melee = ::VSLib.Entity(g_ModeScript.SpawnMeleeWeapon( "any", Vector(0,0,0), QAngle(0,0,0) ));
	Use(melee);
	melee.Input("Kill");
}

/**
 * The "give" concommand.
 *
 * @param str What to give the entity (for example, "health")
 */
function VSLib::Player::Give(str, skin = 0)
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	_ent.GiveItemWithSkin(str, skin);
}

/**
 * Makes the player switch to an item/weapon.
 */
function VSLib::Player::SwitchTo(str = "")
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if ( str == "" )
		return;
	
	local wep = "";
	local slot = "";
	local t = GetHeldItems();
	
	if ( (typeof str) == "integer" )
		slot = "slot" + str.tointeger();
	else
	{
		if ( str.find("weapon_") != null )
			wep = str;
		else
			wep = "weapon_" + str;
	}
	
	if ( slot != "" )
	{
		if (t && slot in t)
			wep = t[slot].GetClassname();
	}
	
	return _ent.SwitchToItem(wep);
}

/**
 * Removes a player's weapon.
 */
function VSLib::Player::Remove(str)
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local t = GetHeldItems();
	
	if (t)
	{
		foreach (item in t)
		{
			if ( item.GetClassname() == str || item.GetClassname() == "weapon_" + str )
				item.Kill();
		}
	}
}

/**
 * Drops a player's weapon
 */
function VSLib::Player::Drop(str = "")
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local wep = "";
	local slot = "";
	local t = GetHeldItems();
	
	if ( str != "" )
	{
		if ( (typeof str) == "integer" )
			slot = "slot" + str.tointeger();
		else
		{
			if ( str.find("weapon_") != null )
				wep = str;
			else
				wep = "weapon_" + str;
		}
	}
	else
	{
		if ( GetActiveWeapon() != null )
			wep = GetActiveWeapon().GetClassname();
		else
			return;
	}
	
	if ( slot != "" )
	{
		if (t && slot in t)
			wep = t[slot].GetClassname();
	}
	
	_ent.DropItem( wep );
}

/**
 * Returns true if the player has the item.
 */
function VSLib::Player::HasItem(str)
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local t = GetHeldItems();
	
	if (t)
	{
		foreach (item in t)
		{
			if ( item.GetClassname() == str || item.GetClassname() == "weapon_" + str )
				return true;
		}
	}
	
	return false;
}

/**
 * Returns true if the player has dual pistols.
 */
function VSLib::Player::HasDualPistols()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if ( HasItem( "weapon_pistol" ) )
		return GetHeldItems()["slot1"].GetNetPropBool( "m_hasDualWeapons" );
	
	return false;
}

/**
 * Returns true if the player's primary weapon has a laser sight.
 */
function VSLib::Player::HasLaserSight()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local t = GetHeldItems();
	
	if (t && "slot0" in t)
		return (t["slot0"].GetNetPropInt( "m_upgradeBitVec" ) & 4) > 0;
	
	return false;
}

/**
 * Get the current state the infected is in
 */
function VSLib::Player::GetInfectedState()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetTeam() != INFECTED)
		return;
	
	return GetNetPropInt( "m_zombieState" );
}

/**
 * Sets the player's view angles.
 */
function VSLib::Player::SetEyeAngles( angles )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	_ent.SnapEyeAngles( angles );
}

/**
 * Returns true if falling damage is currently suppressed.
 */
function VSLib::Player::IsSuppressingFallingDamage()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	return _ent.IsSuppressingFallingDamage();
}





/**
 * Stops Amnesia/HL2 style object pickups
 */
function VSLib::Player::DisablePickups( )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (_idx in ::VSLib.EntData._objPickupTimer)
		::VSLib.Timers.RemoveTimer(::VSLib.EntData._objPickupTimer[_idx]);
}

/**
 * Enables Amnesia/HL2 style object pickups
 */
function VSLib::Player::AllowPickups( BTN_PICKUP, BTN_THROW )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	DisablePickups();
	
	::VSLib.EntData._objBtnPickup[_idx] <- BTN_PICKUP;
	::VSLib.EntData._objBtnThrow[_idx] <- BTN_THROW;
	::VSLib.EntData._objOldBtnMask[_idx] <- GetPressedButtons();
	::VSLib.EntData._objHolding[_idx] <- null;
	
	::VSLib.EntData._objPickupTimer[_idx] <- ::VSLib.Timers.AddTimer(0.1, 1, @(pEnt) pEnt.__CalcPickups(), this);
}

/**
 * Instead of using this directly, @see AllowPickups
 */
function VSLib::Player::__CalcPickups( )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	// Update global entity cache
	local buttons = GetPressedButtons();
	local OldButtons = ::VSLib.EntData._objOldBtnMask[_idx];
	local btnPickup = ::VSLib.EntData._objBtnPickup[_idx];
	local btnThrow = ::VSLib.EntData._objBtnThrow[_idx];
	local HoldingEntity = ::VSLib.EntData._objHolding[_idx];
	
	// Constants -- \todo @TODO Make these user-configurable
	const DISTANCE_TO_HOLD = 100.0
	const DISTANCE_CLOSE = 256.0;
	const OBJECT_SPEED = 25.0;
	const THROW_SPEED = 1000.0;
	
	// Are they trying to pick up an object?
	if (buttons & btnPickup && !(OldButtons & btnPickup) && HoldingEntity == null && !(buttons & btnThrow) && !IsIncapacitated() && !IsHangingFromLedge())
	{
		// Are they looking at a valid grabbable entity?
		// If so, then cache it.
		local object = GetLookingEntity();
		if (object != null)
			::VSLib.EntData._objHolding[_idx] <- object;
	}
	
	// Are they holding an object?
	else if (buttons & btnPickup && OldButtons & btnPickup && !(buttons & btnThrow) &&
			HoldingEntity != null && !IsIncapacitated() && !IsHangingFromLedge())
	{
		if (HoldingEntity.IsEntityValid())
		{	
			local eyeAngles = GetEyeAngles();
			if (eyeAngles == null) return;
			local vecDir = eyeAngles.Forward();
			
			local vecPos = GetEyePosition();
			if (vecPos == null) return;
			
			local holdPos = HoldingEntity.GetLocation();
			if (holdPos == null) return;
			
			if (::VSLib.Utils.CalculateDistance(vecPos, holdPos) < DISTANCE_CLOSE)
			{
				// update object 
				vecPos.x += vecDir.x * DISTANCE_TO_HOLD;
				vecPos.y += vecDir.y * DISTANCE_TO_HOLD;
				vecPos.z += vecDir.z * DISTANCE_TO_HOLD;
				
				local vecVel = vecPos - holdPos;
				vecVel = vecVel.Scale(OBJECT_SPEED);
				
				HoldingEntity.SetVelocity(vecVel);
			}
			else
			{
				// Entity is no longer valid
				DropPickup();
			}
		}
	}
	// Are they trying to throw the object?
	else if(buttons & btnPickup && OldButtons & btnPickup && buttons & btnThrow && HoldingEntity != null)
	{
		if (HoldingEntity.IsEntityValid())
		{
			// then throw it!
			local eyeAngles = GetEyeAngles();
			if (eyeAngles == null) return;
			local speed = eyeAngles.Forward().Scale(THROW_SPEED);
			HoldingEntity.Push(speed);
			DropPickup();
		}
	}
	// Are they letting go of an object?
	else if (!(buttons & btnPickup) && OldButtons & btnPickup && HoldingEntity != null)
	{
		if (HoldingEntity.IsEntityValid())
		{	
			// let go of the object
			DropPickup();
		}
	}
	
	// Cache old buttons
	::VSLib.EntData._objOldBtnMask[_idx] <- buttons;
}

/**
 * Drops the held HL2/Amnesia physics-based object or the valve-style object
 */
function VSLib::Player::DropPickup( )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	// Drop amnesia object
	::VSLib.EntData._objHolding[_idx] <- null;
	
	// Drop valve object
	if (_idx in ::VSLib.EntData._objValveHolding)
	{
		::VSLib.EntData._objValveHolding[_idx].ApplyAbsVelocityImpulse(::VSLib.Utils.VectorFromQAngle(GetEyeAngles(), 100));
		delete ::VSLib.EntData._objValveHolding[_idx];
	}
}


/**
 * Picks up the given VSLib Entity object
 */
function VSLib::Player::NativePickupObject( otherEnt )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	DropPickup();
	
	if (otherEnt.GetClassname() != "prop_physics")
		return;
	
	::VSLib.EntData._objValveHolding[_idx] <- otherEnt.GetBaseEntity();
	PickupObject(_ent, otherEnt.GetBaseEntity());
}

/**
 * Enables Valve-style object pickups
 * @authors Neil, Rectus
 */
function VSLib::Player::BeginValvePickupObjects( pickupSound = "Defibrillator.Use", throwSound = "Adrenaline.NeedleOpen" )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	EndValvePickupObjects();
	
	::VSLib.EntData._objEnableDmg[_idx] <- false;
	::VSLib.EntData._objValveHoldDmg[_idx] <- 5;
	::VSLib.EntData._objValveThrowDmg[_idx] <- 30;
	::VSLib.EntData._objValveThrowPower[_idx] <- 100;
	::VSLib.EntData._objValvePickupRange[_idx] <- 64;
	::VSLib.EntData._objOldBtnMask[_idx] <- GetPressedButtons();
	::VSLib.EntData._objValveTimer[_idx] <- ::VSLib.Timers.AddTimer(0.1, true, @(p) p.ent.__CalcValvePickups(p.ps, p.ts), {ent = this, ps = pickupSound, ts = throwSound});
}

/**
 * Disables Valve-style object pickups
 * @authors Rectus
 */
function VSLib::Player::EndValvePickupObjects( )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (_idx in ::VSLib.EntData._objValveTimer)
		::VSLib.Timers.RemoveTimer( ::VSLib.EntData._objValveTimer[_idx] );
}

/**
 * Sets the throwing force for Valve-style object pickups (default 100)
 * @authors Rectus
 */
function VSLib::Player::ValvePickupThrowPower( power )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	::VSLib.EntData._objValveThrowPower[_idx] <- power;
	
	return true;
}

/**
 * Sets the pickup range for Valve-style object pickups (default 64)
 * @authors Rectus
 */
function VSLib::Player::ValvePickupPickupRange( range )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	::VSLib.EntData._objValvePickupRange[_idx] <- range;
	
	return true;
}

/**
 * Sets the throw damage for Valve-style object pickups (default 30)
 */
function VSLib::Player::SetThrowDamage( dmg )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	::VSLib.EntData._objValveThrowDmg[_idx] <- dmg.tointeger();
}

/**
 * Sets the hold damage for Valve-style object pickups (default 5)
 */
function VSLib::Player::SetHoldDamage( dmg )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	::VSLib.EntData._objValveHoldDmg[_idx] <- dmg.tointeger();
}

/**
 * Enables or disables hold/throw damage calculation
 */
function VSLib::Player::SetDamageEnabled( isEnabled )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	::VSLib.EntData._objEnableDmg[_idx] <- isEnabled;
}

/**
 * Instead of using this directly, @see BeginValvePickupObjects
 * @authors Neil, Rectus
 */
function VSLib::Player::__CalcValvePickups( pickupSound, throwSound )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return false;
	}
	
	local curinv = GetHeldItems();
	
	if (_idx in ::VSLib.EntData._objValveHolding && (!("Held" in curinv) || ::VSLib.EntData._objValveHolding[_idx] != curinv["Held"]))
	{
		if (::VSLib.EntData._objEnableDmg[_idx])
			::VSLib.Timers.RemoveTimerByName("vPickup" + _idx);
		
		delete ::VSLib.EntData._objValveHolding[_idx];
		
		return;
	}
	
	local oldbuttons = ::VSLib.EntData._objOldBtnMask[_idx];
	
	local function _calcThrowDmg(params)
	{
		params.ent.HurtAround(params.dmg, 1, "", null, 64.0, [params.ignore]);
	}
	
	if (IsPressingUse() && !(oldbuttons & (1 << 5)))
	{
		local traceTable =
		{
			start = GetEyePosition()
			end = GetEyePosition() + ::VSLib.Utils.VectorFromQAngle(GetEyeAngles(), ::VSLib.EntData._objValvePickupRange[_idx])
			ignore = _ent
			mask = TRACE_MASK_SHOT 
		}

		local result = TraceLine(traceTable);
		
		if (result && "enthit" in traceTable && traceTable.enthit.GetClassname() == "prop_physics")
		{
			::VSLib.EntData._objValveHolding[_idx] <- traceTable.enthit;
			PickupObject(_ent, traceTable.enthit);
			PlaySound(pickupSound);
			
			if (::VSLib.EntData._objEnableDmg[_idx])
				::VSLib.Timers.AddTimerByName( "vPickup" + _idx, 0.1, true, _calcThrowDmg, { ent = ::VSLib.Entity(::VSLib.EntData._objValveHolding[_idx]), ignore = this, dmg = ::VSLib.EntData._objValveHoldDmg[_idx] } );
		}
	}
	else if (IsPressingAttack() && _idx in ::VSLib.EntData._objValveHolding)
	{
		try
		{
			::VSLib.EntData._objValveHolding[_idx].ApplyAbsVelocityImpulse(::VSLib.Utils.VectorFromQAngle(GetEyeAngles(), ::VSLib.EntData._objValveThrowPower[_idx]));
			
			if (::VSLib.EntData._objEnableDmg[_idx])
				::VSLib.Timers.AddTimerByName( "vPickup" + _idx, 0.1, true, _calcThrowDmg, { ent = ::VSLib.Entity(::VSLib.EntData._objValveHolding[_idx]), ignore = this, dmg = ::VSLib.EntData._objValveThrowDmg[_idx] }, TIMER_FLAG_COUNTDOWN, { count = 12 } );
			
			delete ::VSLib.EntData._objValveHolding[_idx];
			PlaySound(throwSound);
		}
		catch (id)
		{
			printl("Impulse failed! " + id);
		}
	
	}
	
	::VSLib.EntData._objOldBtnMask[_idx] <- GetPressedButtons();
}


/**
 * Returns the quantity of the requested inventory item.
 * Inventory items can be spawned with Utils::SpawnInventoryItem().
 */
function VSLib::Player::GetInventory( itemName )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return 0;
	}
	
	if (!(_idx in ::VSLib.EntData._inv))
		return 0;
	
	if (!(itemName in ::VSLib.EntData._inv[_idx]))
		return 0;
	
	return ::VSLib.EntData._inv[_idx][itemName];
}

/**
 * Sets the quantity of the specified inventory item.
 */
function VSLib::Player::SetInventory( itemName, quantity )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (!(_idx in ::VSLib.EntData._inv))
		::VSLib.EntData._inv[_idx] <- {};
	
	::VSLib.EntData._inv[_idx][itemName] <- quantity;
}

/**
 * Returns the player's inventory table. You can use it like this:
 * 
 * 		local inv = player.GetInventoryTable();
 * 		inv["itemName"] <- 25; // change quantity to 25
 */
function VSLib::Player::GetInventoryTable( )
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return 0;
	}
	
	if (!(_idx in ::VSLib.EntData._inv))
		::VSLib.EntData._inv[_idx] <- {};
	
	return ::VSLib.EntData._inv[_idx];
}


/**
 * Returns true if survivor is in safe spot
 */
function VSLib::Player::IsInSafeSpot()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR)
		return;
	
	return (ResponseCriteria.GetValue( _ent, "insafespot" ).tointeger() > 0) ? true : false;
}

/**
 * Returns true if survivor is in start area
 */
function VSLib::Player::IsInStartArea()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR)
		return;
	
	return (ResponseCriteria.GetValue( _ent, "instartarea" ).tointeger() > 0) ? true : false;
}

/**
 * Returns true if survivor is in checkpoint
 */
function VSLib::Player::IsInCheckpoint()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR)
		return;
	
	return (ResponseCriteria.GetValue( _ent, "incheckpoint" ).tointeger() > 0) ? true : false;
}

/**
 * Returns true if survivor is in battlefield
 */
function VSLib::Player::IsInBattlefield()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR)
		return;
	
	return (ResponseCriteria.GetValue( _ent, "inbattlefield" ).tointeger() > 0) ? true : false;
}

/**
 * Returns true if player is in combat
 */
function VSLib::Player::IsInCombat()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	return (ResponseCriteria.GetValue( _ent, "incombat" ).tointeger() > 0) ? true : false;
}

/**
 * Returns true if survivor is in combat music
 */
function VSLib::Player::IsInCombatMusic()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR)
		return;
	
	return (ResponseCriteria.GetValue( _ent, "InCombatMusic" ).tointeger() > 0) ? true : false;
}

/**
 * Returns true if survivor is coughing
 */
function VSLib::Player::IsCoughing()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR)
		return;
	
	return (ResponseCriteria.GetValue( _ent, "coughing" ).tointeger() > 0) ? true : false;
}

/**
 * Returns true if survivor is sneaking
 */
function VSLib::Player::IsSneaking()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR)
		return;
	
	return (ResponseCriteria.GetValue( _ent, "Sneaking" ).tointeger() > 0) ? true : false;
}

/**
 * Get the survivor average intensity time
 */
function VSLib::Player::GetTimeAveragedIntensity()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR)
		return;
	
	return ResponseCriteria.GetValue( _ent, "TimeAveragedIntensity" ).tofloat();
}

/**
 * Get the time since the survivor was last in combat
 */
function VSLib::Player::GetTimeSinceCombat()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	return ResponseCriteria.GetValue( _ent, "timesincecombat" ).tofloat();
}

/**
 * Gets the survivor bot's closest visible friend
 */
function VSLib::Player::BotGetClosestVisibleFriend()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR || IsHuman())
		return;
	
	local survivor = ResponseCriteria.GetValue( _ent, "BotClosestVisibleFriend" );
	
	if ( !survivor )
		return;
	
	return ::VSLib.Player(::VSLib.ResponseRules.ExpTargetName[survivor]);
}

/**
 * Gets the survivor bot's closest friend who's in combat
 */
function VSLib::Player::BotGetClosestInCombatFriend()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR || IsHuman())
		return;
	
	local survivor = ResponseCriteria.GetValue( _ent, "BotClosestInCombatFriend" );
	
	if ( !survivor )
		return;
	
	return ::VSLib.Player(::VSLib.ResponseRules.ExpTargetName[survivor]);
}

/**
 * Gets the survivor bot's team leader
 */
function VSLib::Player::BotGetTeamLeader()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR || IsHuman())
		return null;
	
	local survivor = ResponseCriteria.GetValue( _ent, "BotTeamLeader" );
	
	if ( !survivor )
		return;
	
	return ::VSLib.Player(::VSLib.ResponseRules.ExpTargetName[survivor]);
}

/**
 * Returns true if survivor bot is in a narrow corridor
 */
function VSLib::Player::BotIsInNarrowCorridor()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR || IsHuman())
		return;
	
	return (ResponseCriteria.GetValue( _ent, "BotIsInNarrowCorridor" ).tointeger() > 0) ? true : false;
}

/**
 * Returns true if survivor bot is near a checkpoint
 */
function VSLib::Player::BotIsNearCheckpoint()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR || IsHuman())
		return;
	
	return (ResponseCriteria.GetValue( _ent, "BotIsNearCheckpoint" ).tointeger() > 0) ? true : false;
}

/**
 * Get the amount of visible friends the survivor bot sees
 */
function VSLib::Player::BotGetNearbyVisibleFriendCount()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR || IsHuman())
		return;
	
	return ResponseCriteria.GetValue( _ent, "BotNearbyVisibleFriendCount" ).tointeger();
}

/**
 * Get the amount of time since any friend was last seen by the survivor bot
 */
function VSLib::Player::BotGetTimeSinceAnyFriendVisible()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR || IsHuman())
		return;
	
	return ResponseCriteria.GetValue( _ent, "BotTimeSinceAnyFriendVisible" ).tofloat();
}

/**
 * Returns true if the survivor bot is available
 */
function VSLib::Player::BotIsAvailable()
{
	if (!IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	if (GetPlayerType() != Z_SURVIVOR || IsHuman())
		return;
	
	return (ResponseCriteria.GetValue( _ent, "botisavailable" ).tointeger() > 0) ? true : false;
}





// Allows pickups
if (!("CanPickupObject" in getroottable()))
{
	::CanPickupObject <- function (object)
	{
		local vsent = ::VSLib.Entity(object);
		local classname = object.GetClassname();
		
		foreach (func in ::VSLib.EasyLogic.Notifications.CanPickupObject)
			if (func(vsent, classname))
				return true;
		
		foreach (obj in ::VSLib.EntData._objValveHolding)
			if (obj == object)
				return true;
		
		local canPickup = false;
		if ( "PickupObject" in g_MapScript )
			canPickup = g_MapScript.PickupObject( object );
		
		if ( "ModeCanPickupObject" in g_ModeScript )
			return ModeCanPickupObject(object);
		if ( "MapCanPickupObject" in g_ModeScript )
			return MapCanPickupObject(object);
		
		return canPickup;
	}
}

if ( ("CanPickupObject" in g_ModeScript) && (g_ModeScript.CanPickupObject != getroottable().CanPickupObject) )
{
	g_ModeScript.ModeCanPickupObject <- g_ModeScript.CanPickupObject;
	g_ModeScript.CanPickupObject <- getroottable().CanPickupObject;
}
else if ( ("CanPickupObject" in g_MapScript) && (g_MapScript.CanPickupObject != getroottable().CanPickupObject) )
{
	g_ModeScript.MapCanPickupObject <- g_MapScript.CanPickupObject;
	g_ModeScript.CanPickupObject <- getroottable().CanPickupObject;
}
else
{
	g_ModeScript.CanPickupObject <- getroottable().CanPickupObject;
}




// Add a weakref
::Player <- ::VSLib.Player.weakref();