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
 * \brief Provides many helpful entity functions.
 *
 *  The Entity class wraps many Valve functions as well as provide numerous
 *  helper functions that aid in the development of maps, mods, and mutations.
 */
class ::VSLib.Entity
{
	constructor(index)
	{
		if ("_ent" in index && "_idx" in index)
		{
			_ent = index._ent;
			_idx = index._idx;
		}
		else if ((typeof index) == "instance")
		{
			_ent = index;
			_idx = GetBaseIndex();
		}
		else if ((typeof index) == "integer")
		{
			_ent = Ent(index);
			_idx = index;
		}
		else if ((typeof index) == "string" && index.find("!") != 0)
		{
			_ent = Entities.FindByName(null, index);
			
			if (_ent == null)
				_ent = Entities.FindByClassname(null, index);
			
			if (_ent == null)
			{
				printf("VSLib Warning: Invalid targetname or classname (target not found)");
				_idx = -1;
			}
			else
				_idx = GetBaseIndex();
		}
		else
		{
			_ent = Ent(index);
			_idx = GetBaseIndex();
		}
	}
	
	
	function _typeof()
	{
		return "VSLIB_ENTITY";
	}
	
	function _cmp(other)
	{
		if ("_ent" in other && "_idx" in other)
		{
			if (_idx > other._idx)
				return 1;
			else if (_idx == other._idx)
				return 0;
			else if (_idx < other._idx)
				return -1;
		}
		else if ((typeof other) == "integer")
		{
			if (_idx > other)
				return 1;
			else if (_idx == other)
				return 0;
			else if (_idx < other)
				return -1;
		}
		else if ((typeof index) == "instance")
		{
			if (_ent > other)
				return 1;
			else if (_ent == other)
				return 0;
			else if (_ent < other)
				return -1;
		}
	}
	
	
	static _vsEntityClass = "VSLIB_ENTITY";
	_ent = null;
	_idx = null;
}

/**
 * Holds global entity data.
 *
 * \todo @TODO Perhaps move all of these into two distinct tables with KVs instead of leaving the KVs out in the EntData table
 */
if (!("EntData" in ::VSLib))
{
	::VSLib.EntData <-
	{
		// single point_hurt data
		_lastHurt = -1
		_hurtIntent = -1
		_hurtDmg = 0
		_hurtIgnore = []
		
		_objPickupTimer = {}
		_objBtnPickup = {}
		_objBtnThrow = {}
		_objOldBtnMask = {}
		_objHolding = {}
		
		_objValveTimer = {}
		_objValveHolding = {}
		_objValveThrowPower = {}
		_objValvePickupRange = {}
		_objValveThrowDmg = {}
		_objValveHoldDmg = {}
		_objEnableDmg = {}
		
		_inv = {}
		_invItems = {}
	}
}



/**
 * Global definitions and constants.
 */
getconsttable()["InvalidEntity"] <- null;

// Teams
getconsttable()["UNKNOWN"] <- 0; /**< Anything that is unknown. */
getconsttable()["SPECTATORS"] <- 1;
getconsttable()["SURVIVORS"] <- 2;
getconsttable()["INFECTED"] <- 3;
getconsttable()["L4D1_SURVIVORS"] <- 4;

// "Gender" types, to be used with GetGender()
getconsttable()["MALE"] <- 1;
getconsttable()["FEMALE"] <- 2;

// "Zombie" types, to be used with GetPlayerType()
getconsttable()["Z_INFECTED"] <- 0;
getconsttable()["Z_COMMON"] <- 0;
getconsttable()["Z_SMOKER"] <- 1;
getconsttable()["Z_BOOMER"] <- 2;
getconsttable()["Z_HUNTER"] <- 3;
getconsttable()["Z_SPITTER"] <- 4;
getconsttable()["Z_JOCKEY"] <- 5;
getconsttable()["Z_CHARGER"] <- 6;
getconsttable()["Z_WITCH"] <- 7;
getconsttable()["Z_TANK"] <- 8;
getconsttable()["Z_SURVIVOR"] <- 9;
getconsttable()["Z_MOB"] <- 10;
getconsttable()["Z_WITCH_BRIDE"] <- 11;

// "Uncommon" types, to be used with GetUncommonInfected()
getconsttable()["Z_CEDA"] <- 11;
getconsttable()["Z_MUD"] <- 12;
getconsttable()["Z_ROADCREW"] <- 13;
getconsttable()["Z_FALLEN"] <- 14;
getconsttable()["Z_RIOT"] <- 15;
getconsttable()["Z_CLOWN"] <- 16;
getconsttable()["Z_JIMMY"] <- 17;

// Survivor IDs to be used with GetSurvivorCharacter() and Utils.SpawnL4D1Survivor()
getconsttable()["NICK"] <- 0;
getconsttable()["ROCHELLE"] <- 1;
getconsttable()["COACH"] <- 2;
getconsttable()["ELLIS"] <- 3;
getconsttable()["BILL"] <- 4;
getconsttable()["ZOEY"] <- 5;
getconsttable()["FRANCIS"] <- 6;
getconsttable()["LOUIS"] <- 7;
getconsttable()["SURVIVOR"] <- 9;

// "Ammo" types, to be used with network properties
getconsttable()["AMMOTYPE_PISTOL"] <- 1;
getconsttable()["AMMOTYPE_MAGNUM"] <- 2;
getconsttable()["AMMOTYPE_ASSAULTRIFLE"] <- 3;
getconsttable()["AMMOTYPE_MINIGUN"] <- 4;
getconsttable()["AMMOTYPE_SMG"] <- 5;
getconsttable()["AMMOTYPE_M60"] <- 6;
getconsttable()["AMMOTYPE_SHOTGUN"] <- 7;
getconsttable()["AMMOTYPE_AUTOSHOTGUN"] <- 8;
getconsttable()["AMMOTYPE_HUNTINGRIFLE"] <- 9;
getconsttable()["AMMOTYPE_SNIPERRIFLE"] <- 10;
getconsttable()["AMMOTYPE_TURRET"] <- 11;
getconsttable()["AMMOTYPE_PIPEBOMB"] <- 12;
getconsttable()["AMMOTYPE_MOLOTOV"] <- 13;
getconsttable()["AMMOTYPE_VOMITJAR"] <- 14;
getconsttable()["AMMOTYPE_PAINPILLS"] <- 15;
getconsttable()["AMMOTYPE_FIRSTAID"] <- 16;
getconsttable()["AMMOTYPE_GRENADELAUNCHER"] <- 17;
getconsttable()["AMMOTYPE_ADRENALINE"] <- 18;
getconsttable()["AMMOTYPE_CHAINSAW"] <- 19;

// More button values to be used with IsPressingButton()
getconsttable()["BUTTON_ATTACK"] <- 1;
getconsttable()["BUTTON_JUMP"] <- 2;
getconsttable()["BUTTON_DUCK"] <- 4;
getconsttable()["BUTTON_FORWARD"] <- 8;
getconsttable()["BUTTON_BACK"] <- 16;
getconsttable()["BUTTON_USE"] <- 32;
getconsttable()["BUTTON_CANCEL"] <- 64;
getconsttable()["BUTTON_LEFT"] <- 128;
getconsttable()["BUTTON_RIGHT"] <- 256;
getconsttable()["BUTTON_MOVELEFT"] <- 512; // move left key (e.g. A)
getconsttable()["BUTTON_MOVERIGHT"] <- 1024; // move right key (e.g. D)
getconsttable()["BUTTON_SHOVE"] <- 2048;
getconsttable()["BUTTON_RUN"] <- 4096;
getconsttable()["BUTTON_RELOAD"] <- 8192;
getconsttable()["BUTTON_ALT1"] <- 16384;
getconsttable()["BUTTON_ALT2"] <- 32768;
getconsttable()["BUTTON_SCORE"] <- 65536;   // Used by client.dll for when scoreboard is held down
getconsttable()["BUTTON_WALK"] <- 131072; // Player is holding the walk key
getconsttable()["BUTTON_ZOOM"] <- 524288; // Zoom key
getconsttable()["BUTTON_WEAPON1"] <- 1048576; // weapon defines these bits
getconsttable()["BUTTON_WEAPON2"] <- 2097152; // weapon defines these bits
getconsttable()["BUTTON_BULLRUSH"] <- 4194304;
getconsttable()["BUTTON_GRENADE1"] <- 8388608; // grenade 1
getconsttable()["BUTTON_GRENADE2"] <- 16777216; // grenade 2
getconsttable()["BUTTON_LOOKSPIN"] <- 0x2000000; // lookspin if bound #shotgunefx

// Hitgroups to be used with m_LastHitGroup
getconsttable()["HITGROUP_GENERIC"] <- 0;
getconsttable()["HITGROUP_HEAD"] <- 1;
getconsttable()["HITGROUP_CHEST"] <- 2;
getconsttable()["HITGROUP_STOMACH"] <- 3;
getconsttable()["HITGROUP_LEFTARM"] <- 4;
getconsttable()["HITGROUP_RIGHTARM"] <- 5;
getconsttable()["HITGROUP_LEFTLEG"] <- 6;
getconsttable()["HITGROUP_RIGHTLEG"] <- 7;
getconsttable()["HITGROUP_GEAR"] <- 10; // alerts NPC, but doesn't do damage or bleed (1/100th damage)

// Damage types that can be used with Hurt(), etc
getconsttable()["DMG_GENERIC"] <- 0;
getconsttable()["DMG_CRUSH"] <- (1 << 0);
getconsttable()["DMG_BULLET"] <- (1 << 1);
getconsttable()["DMG_SLASH"] <- (1 << 2);
getconsttable()["DMG_BURN"] <- (1 << 3);
getconsttable()["DMG_VEHICLE"] <- (1 << 4);
getconsttable()["DMG_FALL"] <- (1 << 5);
getconsttable()["DMG_BLAST"] <- (1 << 6);
getconsttable()["DMG_CLUB"] <- (1 << 7);
getconsttable()["DMG_SHOCK"] <- (1 << 8);
getconsttable()["DMG_SONIC"] <- (1 << 9);
getconsttable()["DMG_ENERGYBEAM"] <- (1 << 10);
getconsttable()["DMG_PREVENT_PHYSICS_FORCE"] <- (1 << 11);
getconsttable()["DMG_NEVERGIB"] <- (1 << 12);
getconsttable()["DMG_ALWAYSGIB"] <- (1 << 13);
getconsttable()["DMG_DROWN"] <- (1 << 14);
getconsttable()["DMG_PARALYZE"] <- (1 << 15);
getconsttable()["DMG_NERVEGAS"] <- (1 << 16);
getconsttable()["DMG_POISON"] <- (1 << 17);
getconsttable()["DMG_RADIATION"] <- (1 << 18);
getconsttable()["DMG_DROWNRECOVER"] <- (1 << 19);
getconsttable()["DMG_CHOKE"] <- (1 << 20);
getconsttable()["DMG_ACID"] <- (1 << 20);
getconsttable()["DMG_MELEE"] <- (1 << 21);
getconsttable()["DMG_SLOWBURN"] <- (1 << 21);
getconsttable()["DMG_REMOVENORAGDOLL"] <- (1 << 22);
getconsttable()["DMG_PHYSGUN"] <- (1 << 23);
getconsttable()["DMG_PLASMA"] <- (1 << 24);
getconsttable()["DMG_STUMBLE"] <- (1 << 25);
getconsttable()["DMG_AIRBOAT"] <- (1 << 25);
getconsttable()["DMG_DISSOLVE"] <- (1 << 26);
getconsttable()["DMG_BLAST_SURFACE"] <- (1 << 27);
getconsttable()["DMG_DIRECT"] <- (1 << 28);
getconsttable()["DMG_BUCKSHOT"] <- (1 << 29);
getconsttable()["DMG_HEADSHOT"] <- (1 << 30);
getconsttable()["DMG_DISMEMBER"] <- (1 << 31);

// Settings for the m_takedamage network property
getconsttable()["DAMAGE_NO"] <- 0;
getconsttable()["DAMAGE_EVENTS_ONLY"] <- 1;
getconsttable()["DAMAGE_YES"] <- 2;
getconsttable()["DAMAGE_AIM"] <- 3;

// Move types to be used with network properties
getconsttable()["MOVETYPE_NONE"] <- 0;		/**< never moves */
getconsttable()["MOVETYPE_ISOMETRIC"] <- 1;		/**< For players */
getconsttable()["MOVETYPE_WALK"] <- 2;		/**< Player only - moving on the ground */
getconsttable()["MOVETYPE_STEP"] <- 3;		/**< gravity, special edge handling -- monsters use this */
getconsttable()["MOVETYPE_FLY"] <- 4;		/**< No gravity, but still collides with stuff */
getconsttable()["MOVETYPE_FLYGRAVITY"] <- 5;		/**< flies through the air + is affected by gravity */
getconsttable()["MOVETYPE_VPHYSICS"] <- 6;		/**< uses VPHYSICS for simulation */
getconsttable()["MOVETYPE_PUSH"] <- 7;		/**< no clip to world, push and crush */
getconsttable()["MOVETYPE_NOCLIP"] <- 8;		/**< No gravity, no collisions, still do velocity/avelocity */
getconsttable()["MOVETYPE_LADDER"] <- 9;		/**< Used by players only when going onto a ladder */
getconsttable()["MOVETYPE_OBSERVER"] <- 9;		/**< Observer movement, depends on player's observer mode */
getconsttable()["MOVETYPE_CUSTOM"] <- 10;		/**< Allows the entity to describe its own physics */

// Flags to be used with the m_fFlags network property values
getconsttable()["FL_ONGROUND"] <- (1 << 0);		/**< At rest / on the ground */
getconsttable()["FL_DUCKING"] <- (1 << 1);		/**< Player flag -- Player is fully crouched */
getconsttable()["FL_WATERJUMP"] <- (1 << 2);		/**< player jumping out of water */
getconsttable()["FL_ONTRAIN"] <- (1 << 3);		/**< Player is _controlling_ a train, so movement commands should be ignored on client during prediction. */
getconsttable()["FL_INRAIN"] <- (1 << 4);		/**< Indicates the entity is standing in rain */
getconsttable()["FL_FROZEN"] <- (1 << 5);		/**< Player is frozen for 3rd person camera */
getconsttable()["FL_ATCONTROLS"] <- (1 << 6);		/**< Player can't move, but keeps key inputs for controlling another entity */
getconsttable()["FL_CLIENT"] <- (1 << 7);		/**< Is a player */
getconsttable()["FL_FAKECLIENT"] <- (1 << 8);		/**< Fake client, simulated server side; don't send network messages to them */
getconsttable()["FL_INWATER"] <- (1 << 9);		/**< In water */
getconsttable()["FL_FLY"] <- (1 << 10);		/**< Changes the SV_Movestep() behavior to not need to be on ground */
getconsttable()["FL_SWIM"] <- (1 << 11);		/**< Changes the SV_Movestep() behavior to not need to be on ground (but stay in water) */
getconsttable()["FL_CONVEYOR"] <- (1 << 12);
getconsttable()["FL_NPC"] <- (1 << 13);
getconsttable()["FL_GODMODE"] <- (1 << 14);
getconsttable()["FL_NOTARGET"] <- (1 << 15);
getconsttable()["FL_AIMTARGET"] <- (1 << 16);		/**< set if the crosshair needs to aim onto the entity */
getconsttable()["FL_PARTIALGROUND"] <- (1 << 17);		/**< not all corners are valid */
getconsttable()["FL_STATICPROP"] <- (1 << 18);		/**< Eetsa static prop!		 */
getconsttable()["FL_GRAPHED"] <- (1 << 19);		/**< worldgraph has this ent listed as something that blocks a connection */
getconsttable()["FL_GRENADE"] <- (1 << 20);
getconsttable()["FL_STEPMOVEMENT"] <- (1 << 21);		/**< Changes the SV_Movestep() behavior to not do any processing */
getconsttable()["FL_DONTTOUCH"] <- (1 << 22);		/**< Doesn't generate touch functions, generates Untouch() for anything it was touching when this flag was set */
getconsttable()["FL_BASEVELOCITY"] <- (1 << 23);		/**< Base velocity has been applied this frame (used to convert base velocity into momentum) */
getconsttable()["FL_WORLDBRUSH"] <- (1 << 24);		/**< Not moveable/removeable brush entity (really part of the world, but represented as an entity for transparency or something) */
getconsttable()["FL_OBJECT"] <- (1 << 25);		/**< Terrible name. This is an object that NPCs should see. Missiles, for example. */
getconsttable()["FL_KILLME"] <- (1 << 26);		/**< This entity is marked for death -- will be freed by game DLL */
getconsttable()["FL_ONFIRE"] <- (1 << 27);		/**< You know... */
getconsttable()["FL_DISSOLVING"] <- (1 << 28);		/**< We're dissolving! */
getconsttable()["FL_TRANSRAGDOLL"] <- (1 << 29);		/**< In the process of turning into a client side ragdoll. */
getconsttable()["FL_UNBLOCKABLE_BY_PLAYER"] <- (1 << 30);		/**< pusher that can't be blocked by the player */
getconsttable()["FL_FREEZING"] <- (1 << 31);		/**< We're becoming frozen! */
getconsttable()["FL_EP2V_UNKNOWN1"] <- (1 << 31);		/**< Unknown */

// Entity Flags to be used with the m_iEFlags network property values
getconsttable()["EFL_KILLME"] <- (1<<0);		/**< This entity is marked for death -- This allows the game to actually delete ents at a safe time */
getconsttable()["EFL_DORMANT"] <- (1<<1);		/**< Entity is dormant, no updates to client */
getconsttable()["EFL_NOCLIP_ACTIVE"] <- (1<<2);		/**< Lets us know when the noclip command is active. */
getconsttable()["EFL_SETTING_UP_BONES"] <- (1<<3);		/**< Set while a model is setting up its bones. */
getconsttable()["EFL_KEEP_ON_RECREATE_ENTITIES"] <- (1<<4);		/**< This is a special entity that should not be deleted when we restart entities only */
getconsttable()["EFL_DIRTY_SHADOWUPDATE"] <- (1<<5);		/**< Client only- need shadow manager to update the shadow... */
getconsttable()["EFL_NOTIFY"] <- (1<<6);		/**< Another entity is watching events on this entity (used by teleport) */
getconsttable()["EFL_FORCE_CHECK_TRANSMIT"] <- (1<<7);
getconsttable()["EFL_BOT_FROZEN"] <- (1<<8);		/**< This is set on bots that are frozen. */
getconsttable()["EFL_SERVER_ONLY"] <- (1<<9);		/**< Non-networked entity. */
getconsttable()["EFL_NO_AUTO_EDICT_ATTACH"] <- (1<<10);		/**< Don't attach the edict; we're doing it explicitly */
getconsttable()["EFL_DIRTY_ABSTRANSFORM"] <- (1<<11);
getconsttable()["EFL_DIRTY_ABSVELOCITY"] <- (1<<12);
getconsttable()["EFL_DIRTY_ABSANGVELOCITY"] <- (1<<13);
getconsttable()["EFL_DIRTY_SURROUNDING_COLLISION_BOUNDS"] <- (1<<14);
getconsttable()["EFL_DIRTY_SPATIAL_PARTITION"] <- (1<<15);
getconsttable()["EFL_HAS_PLAYER_CHILD"] <- (1<<16);		/**< One of the child entities is a player. */
getconsttable()["EFL_IN_SKYBOX"] <- (1<<17);		/**< This is set if the entity detects that it's in the skybox. This forces it to pass the "in PVS" for transmission. */
getconsttable()["EFL_USE_PARTITION_WHEN_NOT_SOLID"] <- (1<<18);		/**< Entities with this flag set show up in the partition even when not solid */
getconsttable()["EFL_TOUCHING_FLUID"] <- (1<<19);		/**< Used to determine if an entity is floating */
getconsttable()["EFL_IS_BEING_LIFTED_BY_BARNACLE"] <- (1<<20);
getconsttable()["EFL_NO_ROTORWASH_PUSH"] <- (1<<21);		/**< I shouldn't be pushed by the rotorwash */
getconsttable()["EFL_NO_THINK_FUNCTION"] <- (1<<22);
getconsttable()["EFL_NO_GAME_PHYSICS_SIMULATION"] <- (1<<23);
getconsttable()["EFL_CHECK_UNTOUCH"] <- (1<<24);
getconsttable()["EFL_DONTBLOCKLOS"] <- (1<<25);		/**< I shouldn't block NPC line-of-sight */
getconsttable()["EFL_DONTWALKON"] <- (1<<26);		/**< NPC;s should not walk on this entity */
getconsttable()["EFL_NO_DISSOLVE"] <- (1<<27);		/**< These guys shouldn't dissolve */
getconsttable()["EFL_NO_MEGAPHYSCANNON_RAGDOLL"] <- (1<<28);		/**< Mega physcannon can't ragdoll these guys. */
getconsttable()["EFL_NO_WATER_VELOCITY_CHANGE"] <- (1<<29);		/**< Don't adjust this entity's velocity when transitioning into water */
getconsttable()["EFL_NO_PHYSCANNON_INTERACTION"] <- (1<<30);		/**< Physcannon can't pick these up or punt them */
getconsttable()["EFL_NO_DAMAGE_FORCES"] <- (1<<31);		/**< Doesn't accept forces from physics damage */

// RenderModes
getconsttable()["RENDER_NORMAL"] <- 0;		/**< src */
getconsttable()["RENDER_TRANSCOLOR"] <- 1;		/**< c*a+dest*(1-a) */
getconsttable()["RENDER_TRANSTEXTURE"] <- 2;		/**< src*a+dest*(1-a) */
getconsttable()["RENDER_GLOW"] <- 3;		/**< src*a+dest -- No Z buffer checks -- Fixed size in screen space */
getconsttable()["RENDER_TRANSALPHA"] <- 4;		/**< src*srca+dest*(1-srca) */
getconsttable()["RENDER_TRANSADD"] <- 5;		/**< src*a+dest */
getconsttable()["RENDER_ENVIRONMENTAL"] <- 6;		/**< not drawn, used for environmental effects */
getconsttable()["RENDER_TRANSADDFRAMEBLEND"] <- 7;		/**< use a fractional frame value to blend between animation frames */
getconsttable()["RENDER_TRANSALPHAADD"] <- 8;		/**< src + dest*(1-a) */
getconsttable()["RENDER_WORLDGLOW"] <- 9;		/**< Same as kRenderGlow but not fixed size in screen space */
getconsttable()["RENDER_NONE"] <- 10;		/**< Don't render. */

// RenderFx
getconsttable()["RENDERFX_NONE"] <- 0;
getconsttable()["RENDERFX_PULSE_SLOW"] <- 1;
getconsttable()["RENDERFX_PULSE_FAST"] <- 2;
getconsttable()["RENDERFX_PULSE_SLOW_WIDE"] <- 3;
getconsttable()["RENDERFX_PULSE_FAST_WIDE"] <- 4;
getconsttable()["RENDERFX_FADE_SLOW"] <- 5;
getconsttable()["RENDERFX_FADE_FAST"] <- 6;
getconsttable()["RENDERFX_SOLID_SLOW"] <- 7;
getconsttable()["RENDERFX_SOLID_FAST"] <- 8;
getconsttable()["RENDERFX_STROBE_SLOW"] <- 9;
getconsttable()["RENDERFX_STROBE_FAST"] <- 10;
getconsttable()["RENDERFX_STROBE_FASTER"] <- 11;
getconsttable()["RENDERFX_FLICKER_SLOW"] <- 12;
getconsttable()["RENDERFX_FLICKER_FAST"] <- 13;
getconsttable()["RENDERFX_NO_DISSIPATION"] <- 14;
getconsttable()["RENDERFX_DISTORT"] <- 15;		/**< Distort/scale/translate flicker */
getconsttable()["RENDERFX_HOLOGRAM"] <- 16;		/**< kRenderFxDistort + distance fade */
getconsttable()["RENDERFX_EXPLODE"] <- 17;		/**< Scale up really big! */
getconsttable()["RENDERFX_GLOWSHELL"] <- 18;		/**< Glowing Shell */
getconsttable()["RENDERFX_CLAMP_MIN_SCALE"] <- 19;		/**< Keep this sprite from getting very small (SPRITES only!) */
getconsttable()["RENDERFX_ENV_RAIN"] <- 20;		/**< for environmental rendermode, make rain */
getconsttable()["RENDERFX_ENV_SNOW"] <- 21;		/**<  "        "            "    , make snow */
getconsttable()["RENDERFX_SPOTLIGHT"] <- 22;		/**< TEST CODE for experimental spotlight */
getconsttable()["RENDERFX_RAGDOLL"] <- 23;		/**< HACKHACK: TEST CODE for signalling death of a ragdoll character */
getconsttable()["RENDERFX_PULSE_FAST_WIDER"] <- 24;
getconsttable()["RENDERFX_MAX"] <- 25;


// Upgrades that can be used with GiveUpgrade(), etc
getconsttable()["UPGRADE_INCENDIARY_AMMO"] <- 0;
getconsttable()["UPGRADE_EXPLOSIVE_AMMO"] <- 1;
getconsttable()["UPGRADE_LASER_SIGHT"] <- 2;

// Bash values that can be used with OnBash().
getconsttable()["ALLOW_BASH_ALL"] <- 0;
getconsttable()["ALLOW_BASH_PUSHONLY"] <- 1;
getconsttable()["ALLOW_BASH_NONE"] <- 2;

// Bot sense flags.
getconsttable()["BOT_CANT_SEE"] <- (1 << 0);
getconsttable()["BOT_CANT_HEAR"] <- (1 << 1);
getconsttable()["BOT_CANT_FEEL"] <- (1 << 2);

// Values that can be used to command bots.
getconsttable()["BOT_CMD_ATTACK"] <- 0;
getconsttable()["BOT_CMD_MOVE"] <- 1;
getconsttable()["BOT_CMD_RETREAT"] <- 2;
getconsttable()["BOT_CMD_RESET"] <- 3;

// Infected bot sense flags.
getconsttable()["INFECTED_FLAG_CANT_SEE_SURVIVORS"] <- (1 << 13);
getconsttable()["INFECTED_FLAG_CANT_HEAR_SURVIVORS"] <- (1 << 14);
getconsttable()["INFECTED_FLAG_CANT_FEEL_SURVIVORS"] <- (1 << 15);

// Trace masks for TraceLine().
getconsttable()["TRACE_MASK_ALL"] <- -1;
getconsttable()["TRACE_MASK_VISION"] <- 33579073;
getconsttable()["TRACE_MASK_VISIBLE_AND_NPCS"] <- 33579137;
getconsttable()["TRACE_MASK_PLAYER_SOLID"] <- 33636363;
getconsttable()["TRACE_MASK_NPC_SOLID"] <- 33701899;
getconsttable()["TRACE_MASK_SHOT"] <- 1174421507;


// Content flags
getconsttable()["CONTENTS_EMPTY"] <-			0;		/**< No contents. */
getconsttable()["CONTENTS_SOLID"] <-			0x1;		/**< an eye is never valid in a solid . */
getconsttable()["CONTENTS_WINDOW"] <-			0x2;		/**< translucent, but not watery (glass). */
getconsttable()["CONTENTS_AUX"] <-			0x4;
getconsttable()["CONTENTS_GRATE"] <-			0x8;		/**< alpha-tested "grate" textures.  Bullets/sight pass through, but solids don't. */
getconsttable()["CONTENTS_SLIME"] <-			0x10;
getconsttable()["CONTENTS_WATER"] <-			0x20;
getconsttable()["CONTENTS_MIST"] <-			0x40;
getconsttable()["CONTENTS_OPAQUE"] <-			0x80;		/**< things that cannot be seen through (may be non-solid though). */
getconsttable()["LAST_VISIBLE_CONTENTS"] <-	0x80;
getconsttable()["ALL_VISIBLE_CONTENTS"] <- 	(getconsttable()["LAST_VISIBLE_CONTENTS"] | (getconsttable()["LAST_VISIBLE_CONTENTS"]-1))
getconsttable()["CONTENTS_TESTFOGVOLUME"] <-	0x100;
getconsttable()["CONTENTS_UNUSED5"] <-		0x200;
getconsttable()["CONTENTS_UNUSED6"] <-		0x4000;
getconsttable()["CONTENTS_TEAM1"] <-			0x800;		/**< per team contents used to differentiate collisions. */
getconsttable()["CONTENTS_TEAM2"] <-			0x1000;		/**< between players and objects on different teams. */
getconsttable()["CONTENTS_IGNORE_NODRAW_OPAQUE"] <-	0x2000;		/**< ignore CONTENTS_OPAQUE on surfaces that have SURF_NODRAW. */
getconsttable()["CONTENTS_MOVEABLE"] <-		0x4000;		/**< hits entities which are MOVETYPE_PUSH (doors, plats, etc) */
getconsttable()["CONTENTS_AREAPORTAL"] <-		0x8000;		/**< remaining contents are non-visible, and don't eat brushes. */
getconsttable()["CONTENTS_PLAYERCLIP"] <-		0x10000;
getconsttable()["CONTENTS_MONSTERCLIP"] <-	0x20000;
getconsttable()["CONTENTS_ORIGIN"] <-			0x1000000;	/**< removed before bsping an entity. */
getconsttable()["CONTENTS_MONSTER"] <-		0x2000000;	/**< should never be on a brush, only in game. */
getconsttable()["CONTENTS_DEBRIS"] <-			0x4000000;
getconsttable()["CONTENTS_DETAIL"] <-			0x8000000;	/**< brushes to be added after vis leafs. */
getconsttable()["CONTENTS_TRANSLUCENT"] <-	0x10000000;	/**< auto set if any surface has trans. */
getconsttable()["CONTENTS_LADDER"] <-			0x20000000;
getconsttable()["CONTENTS_HITBOX"] <-			0x40000000;	/**< use accurate hitboxes on trace. */


// Many more masks
getconsttable()["MASK_WATER"] <-(getconsttable()["CONTENTS_WATER"]|getconsttable()["CONTENTS_MOVEABLE"]|getconsttable()["CONTENTS_SLIME"]) /**< water physics in these contents */
getconsttable()["MASK_OPAQUE"] <-(getconsttable()["CONTENTS_SOLID"]|getconsttable()["CONTENTS_MOVEABLE"]|getconsttable()["CONTENTS_OPAQUE"]) /**< everything that blocks line of sight for AI, lighting, etc */
getconsttable()["MASK_OPAQUE_AND_NPCS"] <-(getconsttable()["MASK_OPAQUE"]|getconsttable()["CONTENTS_MONSTER"])/**< everything that blocks line of sight for AI, lighting, etc, but with monsters added. */
getconsttable()["MASK_VISIBLE"] <-(getconsttable()["MASK_OPAQUE"]|getconsttable()["CONTENTS_IGNORE_NODRAW_OPAQUE"]) /**< everything that blocks line of sight for players */
getconsttable()["MASK_VISIBLE_AND_NPCS"] <-(getconsttable()["MASK_OPAQUE_AND_NPCS"]|getconsttable()["CONTENTS_IGNORE_NODRAW_OPAQUE"]) /**< everything that blocks line of sight for players, but with monsters added. */
getconsttable()["MASK_SHOT_HULL"] <-(getconsttable()["CONTENTS_SOLID"]|getconsttable()["CONTENTS_MOVEABLE"]|getconsttable()["CONTENTS_MONSTER"]|getconsttable()["CONTENTS_WINDOW"]|getconsttable()["CONTENTS_DEBRIS"]|getconsttable()["CONTENTS_GRATE"]) /**< non-raycasted weapons see this as solid (includes grates) */
getconsttable()["MASK_SHOT_PORTAL"] <-(getconsttable()["CONTENTS_SOLID"]|getconsttable()["CONTENTS_MOVEABLE"]|getconsttable()["CONTENTS_WINDOW"]) /**< hits solids (not grates) and passes through everything else */
getconsttable()["MASK_SOLID_BRUSHONLY"] <-(getconsttable()["CONTENTS_SOLID"]|getconsttable()["CONTENTS_MOVEABLE"]|getconsttable()["CONTENTS_WINDOW"]|getconsttable()["CONTENTS_GRATE"]) /**< everything normally solid, except monsters (world+brush only) */
getconsttable()["MASK_PLAYERSOLID_BRUSHONLY"] <-(getconsttable()["CONTENTS_SOLID"]|getconsttable()["CONTENTS_MOVEABLE"]|getconsttable()["CONTENTS_WINDOW"]|getconsttable()["CONTENTS_PLAYERCLIP"]|getconsttable()["CONTENTS_GRATE"]) /**< everything normally solid for player movement, except monsters (world+brush only) */
getconsttable()["MASK_NPCSOLID_BRUSHONLY"] <-(getconsttable()["CONTENTS_SOLID"]|getconsttable()["CONTENTS_MOVEABLE"]|getconsttable()["CONTENTS_WINDOW"]|getconsttable()["CONTENTS_MONSTERCLIP"]|getconsttable()["CONTENTS_GRATE"]) /**< everything normally solid for npc movement, except monsters (world+brush only) */
getconsttable()["MASK_NPCWORLDSTATIC"] <-(getconsttable()["CONTENTS_SOLID"]|getconsttable()["CONTENTS_WINDOW"]|getconsttable()["CONTENTS_MONSTERCLIP"]|getconsttable()["CONTENTS_GRATE"]) /**< just the world, used for route rebuilding */
getconsttable()["MASK_SPLITAREAPORTAL"] <-(getconsttable()["CONTENTS_WATER"]|getconsttable()["CONTENTS_SLIME"]) /**< These are things that can split areaportals */




/**
 * Returns true if the entity is valid or false otherwise.
 * Sometimes, just because an entity or edict exists doesn't mean that
 * it hasn't freed up or become invalidated. Luckily, you will rarely use
 * this function since VSLib uses it automatically.
 */
function VSLib::Entity::IsEntityValid()
{
	if (_ent == null)
		return false;
	
	if (!("IsValid" in _ent))
		return false;
	
	return _ent.IsValid();
}

/**
 * Gets a string from the entity's network property field.
 */
function VSLib::Entity::GetNetPropString( prop, element = 0 )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return NetProps.GetPropStringArray( _ent, prop.tostring(), element.tointeger() );
}

/**
 * Gets an integer from the entity's network property field.
 */
function VSLib::Entity::GetNetPropInt( prop, element = 0 )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return NetProps.GetPropIntArray( _ent, prop.tostring(), element.tointeger() );
}

/**
 * Gets a float from the entity's network property field.
 */
function VSLib::Entity::GetNetPropFloat( prop, element = 0 )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return NetProps.GetPropFloatArray( _ent, prop.tostring(), element.tointeger() );
}

/**
 * Gets a Vector from the entity's network property field.
 */
function VSLib::Entity::GetNetPropVector( prop, element = 0 )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return NetProps.GetPropVectorArray( _ent, prop.tostring(), element.tointeger() );
}

/**
 * Gets an entity from the entity's network property field.
 */
function VSLib::Entity::GetNetPropEntity( prop, element = 0 )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local entity = NetProps.GetPropEntityArray( _ent, prop.tostring(), element.tointeger() );
	if (!entity)
		return null;
	return ::VSLib.Utils.GetEntityOrPlayer( entity );
}

/**
 * Gets a boolean from the entity's network property field.
 */
function VSLib::Entity::GetNetPropBool( prop, element = 0 )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return (NetProps.GetPropIntArray( _ent, prop.tostring(), element.tointeger() ) > 0) ? true : false;
}

/**
 * Gets an entity's network property field.
 */
function VSLib::Entity::GetNetProp( prop, element = 0 )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if (!HasNetProp( prop ))
		return null;
	
	local type = GetNetPropType( prop );
	
	if (type == "integer")
	{
		local entity = GetNetPropEntity( prop, element );
		
		if ( entity != null )
			return entity;
		else
			return GetNetPropInt( prop, element );
	}
	else if (type == "float")
		return GetNetPropFloat( prop, element );
	else if (type == "string")
		return GetNetPropString( prop, element );
	else if (type == "Vector")
		return GetNetPropVector( prop, element );
	
	return null;
}

/**
 * Sets an entity's network property field by string.
 */
function VSLib::Entity::SetNetPropString( prop, value, element = 0 )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	NetProps.SetPropStringArray( _ent, prop.tostring(), value.tostring(), element.tointeger() );
}

/**
 * Sets an entity's network property field by integer.
 */
function VSLib::Entity::SetNetPropInt( prop, value, element = 0 )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	NetProps.SetPropIntArray( _ent, prop.tostring(), value.tointeger(), element.tointeger() );
}

/**
 * Sets an entity's network property field by float.
 */
function VSLib::Entity::SetNetPropFloat( prop, value, element = 0 )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	NetProps.SetPropFloatArray( _ent, prop.tostring(), value.tofloat(), element.tointeger() );
}

/**
 * Sets an entity's network property field by Vector.
 */
function VSLib::Entity::SetNetPropVector( prop, value, element = 0 )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	NetProps.SetPropVectorArray( _ent, prop.tostring(), value, element.tointeger() );
}

/**
 * Sets an entity's network property field by entity.
 */
function VSLib::Entity::SetNetPropEntity( prop, value, element = 0 )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( typeof value == "VSLIB_ENTITY" || typeof value == "VSLIB_PLAYER" )
		value = value.GetBaseEntity();
	
	NetProps.SetPropEntityArray( _ent, prop.tostring(), value, element.tointeger() );
}

/**
 * Sets an entity's network property field.
 */
function VSLib::Entity::SetNetProp( prop, value, element = 0 )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if (typeof value == "string")
		SetNetPropString( prop, value, element );
	else if (typeof value == "integer" || typeof value == "bool")
		SetNetPropInt( prop, value, element );
	else if (typeof value == "float")
		SetNetPropFloat( prop, value, element );
	else if (typeof value == "Vector")
		SetNetPropVector( prop, value, element );
	else
		SetNetPropEntity( prop, value, element );
}

/**
 * Gets the size of the entity's network property field's array.
 */
function VSLib::Entity::GetNetPropArraySize( prop )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return NetProps.GetPropArraySize( _ent, prop.tostring() );
}

/**
 * Returns true if the network property field exists for the entity.
 */
function VSLib::Entity::HasNetProp( prop )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return NetProps.HasProp( _ent, prop.tostring() );
}

/**
 * Gets the type of the entity's network property field.
 */
function VSLib::Entity::GetNetPropType( prop )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return NetProps.GetPropType( _ent, prop.tostring() );
}

/**
 * Gets the value of the entity's response criterion as a string.
 */
function VSLib::Entity::GetResponseCriterion( criterion )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return ResponseCriteria.GetValue( _ent, criterion.tostring() );
}

/**
 * Gets a table containing all of the entity's response criteria.
 */
function VSLib::Entity::GatherResponseCriteria()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local table = {};
	ResponseCriteria.GetTable( _ent, table );
	
	return table;
}

/**
 * Returns true if the response criterion exists.
 */
function VSLib::Entity::HasResponseCriterion( criterion )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return ResponseCriteria.HasCriterion( _ent, criterion.tostring() );
}

/**
 * Gets the value of the entity's response criterion as a string.
 */
function VSLib::Entity::GetResponseCriteriaValue( criterion )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return ResponseCriteria.GetValue( _ent, criterion.tostring() );
}

/**
 * Gets a table of the entity's glow color.
 */
function VSLib::Entity::GetGlowColor()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return ::VSLib.Utils.GetColor32( GetNetPropInt( "m_Glow.m_glowColorOverride" ) );
}

/**
 * Sets the glow color for the entity.
 */
function VSLib::Entity::SetGlowColor( red, green, blue, alpha = 255 )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	SetNetProp( "m_Glow.m_glowColorOverride", ::VSLib.Utils.SetColor32( red, green, blue, alpha ) );
}

/**
 * Gets the entity's real health.
 * If the entity is valid, the entity's health is returned; otherwise, null is returned.
 * The health includes any adrenaline or pill health.
 */
function VSLib::Entity::GetHealth()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local hp = _ent.GetHealth();
	if (IsPlayer())
		hp += _ent.GetHealthBuffer();
	
	return hp;
}

/**
 * Gets the entity's raw health.
 * If the entity is valid, the entity's health is returned; otherwise, null is returned.
 * Raw health does not include temporary health.
 */
function VSLib::Entity::GetRawHealth()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return _ent.GetHealth();
}

/**
 * Gets the entity's max health.
 */
function VSLib::Entity::GetMaxHealth()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return _ent.GetMaxHealth();
}

/**
 * Gets the entity's health as a fraction.
 */
function VSLib::Entity::GetHealthFraction()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetRawHealth() / GetMaxHealth().tofloat();
}

/**
 * Hurts the entity. Internal function. There should not be any need to use this directly.
 * @see Hurt, @see HurtAround, @see HurtTime instead
 */
function VSLib::Entity::__HurtInt__(value, dmgtype, weapon, attacker, radius, _hurtIntent, _hurtIgnore)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	value = value.tointeger();
	dmgtype = dmgtype.tointeger();
	
	local spawn = { classname = "point_hurt", targetname = "vslib_tmp_" + UniqueString(), origin = GetLocation(), angles = QAngle(0,0,0), Damage = value, DamageType = dmgtype, DamageRadius = radius.tostring() };
	
	local point_hurt = g_ModeScript.CreateSingleSimpleEntityFromTable(spawn);
	
	// if the entity is not valid (e.g. entdata has reached the max), then try something else.
	if (!point_hurt)
	{
		Msg("Warning: Could not create point_hurt entity.");
		SetRawHealth(GetHealth() - value);
		return;
	}
	
	local vsHurt = ::VSLib.Entity(point_hurt);
	
	if(weapon != "")
		vsHurt.SetKeyValue("classname", weapon);
	
	if (!attacker)
		attacker = vsHurt;
	
	::VSLib.EntData._lastHurt = attacker.GetBaseEntity();
	::VSLib.EntData._hurtIntent = _hurtIntent;
	::VSLib.EntData._hurtDmg = value;
	::VSLib.EntData._hurtIgnore = _hurtIgnore;
	
	vsHurt.Input("Hurt", "", 0, attacker);
	vsHurt.SetKeyValue("classname", "point_hurt");
	
	vsHurt.Kill();
}

/**
 * Hurts the entity.
 *
 * @param value Amount of damage to inflict.
 * @param dmgtype The type of damage to inflict (e.g. DMG_GENERIC)
 * @param weapon The classname of the weapon (if set, the point hurt will "pretend" to be the weapon)
 * @param attacker If set, the damage will be done by the specified VSLib::Entity or VSLib::Player
 */
function VSLib::Entity::Hurt(value, dmgtype = 0, weapon = "", attacker = null, radius = 64.0)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	__HurtInt__(value, dmgtype, weapon, attacker, radius, _ent, []);
}

/**
 * Hurts AROUND the entity without hurting the entity itself.
 *
 * @param value Amount of damage to inflict.
 * @param dmgtype The type of damage to inflict (e.g. DMG_GENERIC)
 * @param weapon The classname of the weapon (if set, the point hurt will "pretend" to be the weapon)
 * @param attacker If set, the damage will be done by the specified VSLib::Entity or VSLib::Player
 */
function VSLib::Entity::HurtAround(value, dmgtype = 0, weapon = "", attacker = null, radius = 64.0, ignoreEntities = [])
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	ignoreEntities.push(this);
	__HurtInt__(value, dmgtype, weapon, attacker, radius, null, ignoreEntities);
}

/**
 * Damages the entity.
 */
function VSLib::Entity::Damage(value, dmgtype = 0, attacker = null)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( typeof attacker == "VSLIB_ENTITY" || typeof attacker == "VSLIB_PLAYER" )
		attacker = attacker.GetBaseEntity();
	
	_ent.TakeDamage(value, dmgtype.tointeger(), attacker);
}

/**
 * Fires a specific input
 */
function VSLib::Entity::Input(input, value = "", delay = 0, activator = null)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if (activator != null)
	{
		if ( typeof activator == "VSLIB_ENTITY" || typeof activator == "VSLIB_PLAYER" )
			activator = activator.GetBaseEntity();
		
		DoEntFire("!self", input.tostring(), value.tostring(), delay.tofloat(), activator, _ent);
	}
	else
		DoEntFire("!self", input.tostring(), value.tostring(), delay.tofloat(), null, _ent);
}

/**
 * Breaks the entity (if it is breakable)
 */
function VSLib::Entity::Break()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	Input("Break");
}

/**
 * Makes the entity become a ragdoll
 */
function VSLib::Entity::BecomeRagdoll()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local origin = GetLocation();
	local angles = GetAngles();
	
	local function VSLib_RagdollDeathModel( player )
	{
		player.GetSurvivorDeathModel().Input( "BecomeRagdoll" );
	}
	
	if ( IsSurvivor() )
	{
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
				VSLib_RagdollDeathModel( this );
			else
				::VSLib.Timers.AddTimer(0.1, false, VSLib_RagdollDeathModel, this);
		}
	}
	else if ( GetTeam() == 3 )
		Input("BecomeRagdoll");
}

/**
 * Dispatches a keyvalue to the entity
 */
function VSLib::Entity::SetKeyValue(key, value)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	if (typeof value == "string")
		return _ent.__KeyValueFromString(key.tostring(), value.tostring());
	else if (typeof value == "integer" || typeof value == "float")
		return _ent.__KeyValueFromInt(key.tostring(), value);
	else if (typeof value == "bool")
		return _ent.__KeyValueFromInt(key.tostring(), value.tointeger());
	else
		return _ent.__KeyValueFromVector(key.tostring(), value);
}

/**
 * Same as Hurt(), except it keeps hurting for the specified time.
 * It hurts at the specified interval for the specified time.
 */
function VSLib::Entity::HurtTime(value, dmgtype, interval, time, weapon = "", attacker = null, radius = 64.0)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	value = value.tointeger();
	dmgtype = dmgtype.tointeger();
	time = time.tofloat();
	interval = interval.tofloat();
	
	::VSLib.Timers.AddTimer( interval, true, @(params) params.player.Hurt(params.val, params.dmgt, params.wep, params.activator, params.rad), { player = this, val = value, dmgt = dmgtype, wep = weapon, activator = attacker, rad = radius }, TIMER_FLAG_DURATION, { duration = time } );
}

/**
 * Same as Damage(), except it keeps damaging for the specified time.
 * It damages at the specified interval for the specified time.
 */
function VSLib::Entity::DamageTime(value, dmgtype, attacker, interval, time)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	value = value.tointeger();
	dmgtype = dmgtype.tointeger();
	time = time.tofloat();
	interval = interval.tofloat();
	
	::VSLib.Timers.AddTimer( interval, true, @(params) params.player.Damage(params.val, params.dmgt), { player = this, val = value, dmgt = dmgtype, attacker = attacker }, TIMER_FLAG_DURATION, { duration = time } );
}

/**
 * Sets the entity's raw health.
 * If the entity is valid, the entity's health is set.
 * Setting raw health removes any existing temp health.
 */
function VSLib::Entity::SetRawHealth(value)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.SetHealth(value.tointeger());
}

/**
 * Sets the entity's health.
 * If the entity is valid, the entity's health is set.
 * This will also incapacitate the player if the input value is
 * less than or equal to 0.
 */
function VSLib::Entity::SetHealth(value)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	value = value.tointeger();
	
	local hp = GetHealth();
	if ( IsPlayer() )
		Input("SetHealth", value);
	else
	{
		if (value <= 0)
		{
			SetRawHealth(0);
			Hurt(1, (1 << 2));
		}
		else if (value < hp)
			Hurt(hp - value, 0);
		else
			SetRawHealth(value);
	}
}

/**
 * Sets the entity's maximum possible health without modifying the entity's current health.
 * If the entity is valid, the entity's max health is set.
 */
function VSLib::Entity::SetMaxHealth(value)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.SetMaxHealth(value.tointeger());
}

/**
 * Increases the entity's health by the value entered.
 */
function VSLib::Entity::IncreaseHealth(value)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.SetHealth(_ent.GetHealth() + value.tointeger());
}

/**
 * Decreases the entity's health by the value entered.
 */
function VSLib::Entity::DecreaseHealth(value)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.SetHealth(_ent.GetHealth() - value.tointeger());
}

/**
 * Adds health to the entity by the value entered.
 */
function VSLib::Entity::AddHealth(value)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.SetRawHealth(_ent.GetRawHealth() + value.tointeger());
}

/**
 * Removes health from the entity by the value entered.
 */
function VSLib::Entity::RemoveHealth(value)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.SetRawHealth(_ent.GetRawHealth() - value.tointeger());
}

/**
 * Gets the entity's classname.
 * If the entity is valid, the entity's class is returned; otherwise, null is returned.
 * For example, "prop_dynamic" or "weapon_rifle_ak47"
 */
function VSLib::Entity::GetClassname()
{
	if (!IsEntityValid())
		return null;
	
	return _ent.GetClassname();
}

/**
 * Sets the entity's global name.
 * If the entity is valid, the global name of the entity is set. The global name
 * of the entity corresponds to the "Global Name" field of the entity in the Property
 * Window in Hammer. Global entities may carry over onto future maps in a campaign,
 * so setting an entity's global name may be helpful in certain situations.
 */
function VSLib::Entity::SetGlobalName(name)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.__KeyValueFromString("globalname", name.tostring());
}

/**
 * Sets the entity's parent name.
 * If the entity is valid, the name of the entity is set. Note that this function does
 * NOT parent an entity; only the parent's targetname is set. This is equivalent to setting
 * the "Parent" field in Hammer.
 */
function VSLib::Entity::SetParentName(name)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.__KeyValueFromString("parentname", name.tostring());
}

/**
 * Sets the entity's name.
 */
function VSLib::Entity::SetName(name)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.__KeyValueFromString("targetname", name.tostring());
}

/**
 * Sets the entity's speed.
 * If the entity is valid, the speed of the entity is set.
 * The speed cannot be set for player entities.
 */
function VSLib::Entity::SetSpeed(value)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.__KeyValueFromString("speed", value.tostring());
}

/**
 * Sets the entity's render effect.
 * The entity can be given a special effect (like fading, pulsing, etc).
 * If the entity is valid, the render effect is set. Here are the possible values:
 * 	0 -> No effect
 * 	1 -> Slow pulse
 * 	2 -> Fast pulse
 * 	3 -> Slow, wide pulse
 * 	4 -> Fast, wide pulse
 * 	5 -> Slow fade
 * 	6 -> Fast fade
 * 	7 -> Slow solidify (no you can't make ice)
 * 	8 -> Fast solidify
 * 	9 -> Slow strobe
 * 	10 -> Fast strobe
 * 	11 -> Strobe even faster
 * 	12 -> Slow flicker
 * 	13 -> Fast flicker
 * 	14 -> No dissipation
 * 	15 -> Distort entity
 * 	16 -> Hologram effect
 * 	17 -> Super scale; become huge
 * 	18 -> Glowing shell
 * 	19 -> Clamp sprite (prevents sprites from getting smaller when increasing disatance)
 * 	20 -> Rain effect (for environments)
 * 	21 -> Snow effect (for environments again)
 * 	22 -> Valve's experimental spotlight effect
 * 	23 -> Ragdoll effect
 * 	24 -> Pulse faster and wider (dunno why Valve put the value all the way down here)
 */
function VSLib::Entity::SetRenderEffects(value)
{
	if (_ent == null)
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.__KeyValueFromInt("renderfx", value.tointeger());
}

/**
 * Sets the entity's render mode.
 * The render mode allows you to change how an entity should render. With specific values,
 * you can make entities invisible, change the object's buffer checks, blending, and more.
 * Here are the possible values:
 * 	0 -> Normal (no render mode modification)
 * 	1 -> Transcolor
 * 	2 -> Transtexture
 * 	3 -> Glow
 * 	4 -> Transalpha
 * 	5 -> Transadd
 * 	6 -> Environmental
 * 	7 -> Transadd Frame Blend
 * 	8 -> Transalpha add
 * 	9 -> World glow
 * 	10 -> Rend None
 */
function VSLib::Entity::SetRenderMode(value)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.__KeyValueFromInt("rendermode", value.tointeger());
}

/**
 * Sets the entity's next Think time.
 * To be totally honest, I can't think of a reason for this function.
 * Provided just for those who may need it. \todo @TODO This may or may not
 * work, provided that the KV field is FIELD_TICK.
 */
function VSLib::Entity::SetNextThinkTime(value)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.__KeyValueFromInt("nextthink", value.tointeger());
}

/**
 * Sets the entity's secondary effects.
 * Depending on the value, effects like light projection (i.e. flashlight)
 * can be enabled and disabled (for player entities). See Player class
 * for a function already made for that purpose.
 */
function VSLib::Entity::SetEffects(value)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.__KeyValueFromInt("effects", value.tointeger());
}

/**
 * Sets the entity's render color.
 * Changes the overall color of the entity. For example, a value of (255, 0, 0, 255)
 * will give the entity a red hue. The alpha property really doesn't affect much unless
 * the render mode also changes. If you are looking to change the visibility, use
 * Entity.SetVisible() instead.
 */
function VSLib::Entity::SetColor(red, green, blue, alpha)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.__KeyValueFromString("rendercolor", red + " " + green + " " + blue + " " + alpha);
}

/**
 * Changes the entity's visibility.
 * If the visible parameter is true, the entity will become visible to all players.
 * If the visible paramater is false, the entity will become invisible to all players.
 */
function VSLib::Entity::SetVisible(canSee)
{
	local visible = (canSee.tointeger() > 0) ? true : false;
	
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if (visible)
	{
		SetRenderMode(0); // Render mode: normal
		SetColor(255, 255, 255, 255); // Default hue.
	}
	else
	{
		SetRenderMode(1); // Render mode: transcolor
		SetColor(0, 0, 0, 0); // zero all values for color
	}
}

/**
 * Sets the entity's model index.
 * If the entity has more than one model associated with it (i.e. it has more than one
 * model index), then you can instantly change the model index with this function. This
 * function is useful for those who would like to have an entity have more than one model.
 * \todo @TODO verify that global keyfields can be modified with Valve's __KeyValueFromInt()
 */
function VSLib::Entity::SetModelIndex(value)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.__KeyValueFromInt("modelindex", value.tointeger());
}

/**
 * Sets the entity's model.
 */
function VSLib::Entity::SetModel(mdl)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	::VSLib.Utils.PrecacheModel(mdl);
	_ent.SetModel(mdl);
}

/**
 * Sets the entity's response context.
 * This function deals more with AI criteria sets and dispatching responses.
 * Practically useless for what we do, since the entity would need to be
 * re-activated and there's no plausible way to do that via VScripts.
 * If your mod needs to deal with m_iszResponseContext, use another scripting
 * engine like HammerCode or SourceMod.
 */
function VSLib::Entity::SetResponseContext(value)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.__KeyValueFromString("ResponseContext", value.tostring());
}

/**
 * Sets the survivor character ID
 */
function VSLib::Entity::SetSurvivorCharacter(character)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if (GetType() != Z_SURVIVOR)
		return;
	
	SetNetProp( "m_survivorCharacter", character.tointeger() );
}

/**
 * Sets the m_target netprop of the entity.
 * Provided for completeness, but the function doesn't seem to do much on L4D2.
 * The prop has taken a back seat to m_iName from the looks of it.
 */
function VSLib::Entity::SetTarget(value)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.__KeyValueFromString("target", value.tostring());
}

/**
 * Sets the damage filter name of the entity.
 * Provided for completeness. This function sets the m_iszDamageFilterName KV,
 * which is later used in InputSetDamageFilter() in the c++ backend to
 * find the name stored in m_iszDamageFilterName to set m_hDamageFilter, which is
 * later used in PassesDamageFilter() to see if the CTakeDamageInfo object passes
 * the damage filter. In simple terms, this function is as good as useless for us.
 */
function VSLib::Entity::SetDamageFilter(value)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.__KeyValueFromString("damagefilter", value.tostring());
}

/**
 * Sets the shadow cast distance.
 * I honestly cannot think of any good use for this, unless you want to change the
 * shadow distance over time or something. Granted, it may not even work. Provided
 * for completeness.
 */
function VSLib::Entity::SetShadowCastDistance(value)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.__KeyValueFromString("shadowcastdist", value.tostring());
}

/**
 * Applies an absolute velocity impulse to an entity.
 * An impulse is given to the entity. In this function, by setting a value negative
 * to an entity's trajectory, the entity may or may not change paths depending on the
 * scalar value of the vector. All we are doing is "pushing" an entity in the given
 * direction. The higher the dimensional value, the stronger the "push" (to put it
 * very simply). There are a lot of uses for this function.
 */
function VSLib::Entity::Push(vec)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.ApplyAbsVelocityImpulse(vec);
}

/**
 * Applies an angular velocity impulse to an entity.
 * Using this function, we can make physics props spin around or rotate.
 */
function VSLib::Entity::Spin(vec)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.ApplyLocalAngularVelocityImpulse(vec);
}

/**
 * Sets the entity's gravity.
 */
function VSLib::Entity::SetGravity(value)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.__KeyValueFromString("gravity", value.tostring());
}

/**
 * Sets the entity's friction.
 */
function VSLib::Entity::SetFriction(value)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.__KeyValueFromString("friction", value.tostring());
}

/**
 * Gets the entity's gravity.
 */
function VSLib::Entity::GetGravity()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetNetPropFloat( "m_flGravity" );
}

/**
 * Gets the entity's friction.
 */
function VSLib::Entity::GetFriction()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetNetPropFloat( "m_flFriction" );
}

/**
 * Overrides the entity's friction for the desired duration.
 */
function VSLib::Entity::OverrideFriction(duration, friction)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.OverrideFriction(duration, friction);
}

/**
 * Precaches a model.
 */
function VSLib::Entity::PrecacheModel(mdl)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.PrecacheModel(mdl);
}

/**
 * Precaches a scripted sound.
 */
function VSLib::Entity::PrecacheScriptSound(sound)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.PrecacheScriptSound(sound);
}

/**
 * Returns the entity's forward vector.
 */
function VSLib::Entity::GetForwardVector()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return _ent.GetForwardVector();
}

/**
 * Sets the orientation of the entity to have this forward vector.
 */
function VSLib::Entity::SetForwardVector(direction)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.SetForwardVector(direction);
}

/**
 * Returns the entity's base velocity vector.
 */
function VSLib::Entity::GetBaseVelocity()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return _ent.GetBaseVelocity();
}

/**
 * Returns the entity's angular velocity.
 */
function VSLib::Entity::GetLocalAngularVelocity()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return _ent.GetLocalAngularVelocity();
}

/**
 * Returns the entity's relative velocity vector.
 */
function VSLib::Entity::GetLocalVelocity()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return _ent.GetLocalVelocity();
}

/**
 * Returns the entity's current velocity vector.
 */
function VSLib::Entity::GetVelocity()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return _ent.GetVelocity();
}

/**
 * Sets the entity's current velocity vector.
 * This can be used to force an entity to move in a particular direction.
 */
function VSLib::Entity::SetVelocity(vec)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.SetVelocity(vec);
}

/**
 * Sets the entity's current velocity vector KV.
 */
function VSLib::Entity::SetVelocityKV(vec)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	SetKeyValue("velocity", vec);
}

/**
 * Sets the entity's current base velocity vector KV.
 */
function VSLib::Entity::SetBaseVelocity(vec)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	SetKeyValue("basevelocity", vec);
}

/**
 * Sets the entity's current angular velocity vector KV.
 */
function VSLib::Entity::SetAngularVelocity(vec)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	SetKeyValue("avelocity", vec);
}

/**
 * Sets the entity's current water level.
 */
function VSLib::Entity::SetWaterLevel(lvl)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	SetKeyValue("waterlevel", lvl.tostring());
}

/**
 * Sets the entity's spawn flags.
 */
function VSLib::Entity::SetSpawnFlags(flags)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	SetKeyValue("spawnflags", flags.tostring());
}

/**
 * Gets the entity's spawn flags.
 */
function VSLib::Entity::GetSpawnFlags()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetNetPropInt( "m_spawnflags" );
}

/**
 * Returns true if the spawn flag exists in the entity's spawn flags.
 */
function VSLib::Entity::HasSpawnFlags( flag )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local flags = GetNetPropInt( "m_spawnflags" );
	
	return flags == ( flags | flag );
}

/**
 * Adds the spawn flag to the entity's current spawn flags.
 */
function VSLib::Entity::AddSpawnFlags( flag )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local flags = GetNetPropInt( "m_spawnflags" );
	
	if ( HasSpawnFlags(flag) )
		return;
	
	SetNetProp( "m_spawnflags", ( flags | flag ) );
}

/**
 * Removes the spawn flag from the entity's current spawn flags.
 */
function VSLib::Entity::RemoveSpawnFlags( flag )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local flags = GetNetPropInt( "m_spawnflags" );
	
	if ( !HasSpawnFlags(flag) )
		return;
	
	SetNetProp( "m_spawnflags", ( flags & ~flag ) );
}

/**
 * Gets the entity's move type.
 */
function VSLib::Entity::GetMoveType()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetNetPropInt( "movetype" );
}

/**
 * Sets the entity's move type.
 */
function VSLib::Entity::SetMoveType( moveType )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return SetNetProp( "movetype", moveType.tointeger() );
}

/**
 * Gets the direction that the entity's eyes are facing.
 */
function VSLib::Entity::GetEyeAngles()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if (!("EyeAngles" in _ent))
	{
		printl("VSLib Warning: Entity " + _idx + " does not have Eye Angles.");
		return;
	}
	
	return _ent.EyeAngles();
}

/**
 * Returns the base entity (in case you need to access Valve's CBaseEntity/CBaseAnimating functions manually)
 */
function VSLib::Entity::GetBaseEntity()
{
	return _ent;
}

/**
 * Returns the initial index or name passed to the entity.
 */
function VSLib::Entity::GetIndex()
{
	return _idx;
}

/**
 * Gets the entity's modelname.
 */
function VSLib::Entity::GetModel()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return _ent.GetModelName();
}

/**
 * Gets the entity's current origin.
 */
function VSLib::Entity::GetOrigin()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return _ent.GetOrigin();
}

/**
 * Gets the entity's current location.
 */
function VSLib::Entity::GetLocation()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return _ent.GetOrigin();
}

/**
 * Sets the entity's current origin vector (i.e. teleports the entity).
 */
function VSLib::Entity::SetOrigin(vec)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.SetOrigin(vec);
}

/**
 * Sets the entity's current location vector (i.e. teleports the entity).
 */
function VSLib::Entity::SetLocation(vec)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.SetOrigin(vec);
}

/**
 * Sets the entity's current position (basically calls SetLocation() internally).
 */
function VSLib::Entity::SetPosition(x, y, z)
{
	SetLocation( Vector(x, y, z) );
}

/**
 * Gets the entity's current position (basically calls GetLocation() internally).
 */
function VSLib::Entity::GetPosition()
{
	return GetLocation();
}

/**
 * Does the same thing as SetLocation() in that it teleports the entity.
 * Internally the function just calls SetLocation(). Provided for simplicity,
 * as a lot of mappers seem to have difficulty understanding various terms.
 */
function VSLib::Entity::Teleport(vec)
{
	SetLocation(vec);
}

/**
 * Teleports the entity to another ::VSLib.Entity.
 */
function VSLib::Entity::TeleportTo(otherEntity)
{
	Teleport(otherEntity.GetLocation());
}

/**
 * Gets what team the player or entity is on.
 * Returns either UNKNOWN, INFECTED, SURVIVORS or L4D1_SURVIVORS.
 */
function VSLib::Entity::GetTeam()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetNetPropInt( "m_iTeamNum" );
}

/**
 * Sets the team the player or entity is on.
 */
function VSLib::Entity::SetTeam( team )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	SetNetProp( "m_iTeamNum", team.tointeger() );
}

/**
 * Returns the type of entity. E.g. Z_SPITTER, Z_TANK, Z_SURVIVOR, Z_HUNTER, Z_JOCKEY, Z_SMOKER, Z_BOOMER, Z_CHARGER, Z_COMMON, or Z_WITCH.
 */
function VSLib::Entity::GetType()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( _ent.GetClassname() == "infected" )
		return Z_COMMON;
	else if ( _ent.GetClassname() == "witch" )
		return Z_WITCH;
	else if ( _ent.GetClassname() == "player" )
	{
		if (!("GetZombieType" in _ent))
			return;
		
		return _ent.GetZombieType();
	}
	
	return;
}

/**
 * Returns the inventory slot the weapon uses.
 */
function VSLib::Entity::GetWeaponSlot()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( _ent.GetClassname().find("weapon_") == null )
		return;
	
	local WeaponNames =
	{
		weapon_smg = SLOT_PRIMARY,
		weapon_smg_silenced = SLOT_PRIMARY,
		weapon_smg_mp5 = SLOT_PRIMARY,
		weapon_pumpshotgun = SLOT_PRIMARY,
		weapon_shotgun_chrome = SLOT_PRIMARY,
		weapon_rifle = SLOT_PRIMARY,
		weapon_rifle_ak47 = SLOT_PRIMARY,
		weapon_rifle_desert = SLOT_PRIMARY,
		weapon_rifle_sg552 = SLOT_PRIMARY,
		weapon_rifle_m60 = SLOT_PRIMARY,
		weapon_autoshotgun = SLOT_PRIMARY,
		weapon_shotgun_spas = SLOT_PRIMARY,
		weapon_hunting_rifle = SLOT_PRIMARY,
		weapon_sniper_military = SLOT_PRIMARY,
		weapon_sniper_awp = SLOT_PRIMARY,
		weapon_sniper_scout = SLOT_PRIMARY,
		weapon_grenade_launcher = SLOT_PRIMARY,
		weapon_pistol = SLOT_SECONDARY,
		weapon_pistol_magnum = SLOT_SECONDARY,
		weapon_melee = SLOT_SECONDARY,
		weapon_chainsaw = SLOT_SECONDARY,
		weapon_pipe_bomb = SLOT_THROW,
		weapon_molotov = SLOT_THROW,
		weapon_vomitjar = SLOT_THROW,
		weapon_first_aid_kit = SLOT_MEDKIT,
		weapon_defibrillator = SLOT_MEDKIT,
		weapon_upgradepack_incendiary = SLOT_MEDKIT,
		weapon_upgradepack_explosive = SLOT_MEDKIT,
		weapon_pain_pills = SLOT_PILLS,
		weapon_adrenaline = SLOT_PILLS,
		weapon_gascan = SLOT_CARRIED,
		weapon_propanetank = SLOT_CARRIED,
		weapon_oxygentank = SLOT_CARRIED,
		weapon_gnome = SLOT_CARRIED,
		weapon_cola_bottles = SLOT_CARRIED,
		weapon_fireworkcrate = SLOT_CARRIED,
	}
	
	foreach( weapon, slot in WeaponNames )
	{
		foreach( wep in ::VSLib.EasyLogic.Objects.OfClassname(weapon) )
		{
			if ( wep.GetClassname() == _ent.GetClassname() )
				return slot;
		}
	}
	return;
}

/**
 * Returns the default ammo type the weapon uses.
 */
function VSLib::Entity::GetDefaultAmmoType()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( _ent.GetClassname().find("weapon_") == null )
		return;
	
	if ( _ent.GetClassname() == "weapon_pistol" )
		return 1;
	else if ( _ent.GetClassname() == "weapon_pistol_magnum" )
		return 2;
	else if ( _ent.GetClassname() == "weapon_rifle" || _ent.GetClassname() == "weapon_rifle_ak47" || _ent.GetClassname() == "weapon_rifle_desert" || _ent.GetClassname() == "weapon_rifle_sg552" )
		return 3;
	else if ( _ent.GetClassname() == "weapon_smg" || _ent.GetClassname() == "weapon_smg_silenced" || _ent.GetClassname() == "weapon_smg_mp5" )
		return 5;
	else if ( _ent.GetClassname() == "weapon_rifle_m60" )
		return 6;
	else if ( _ent.GetClassname() == "weapon_pumpshotgun" || _ent.GetClassname() == "weapon_shotgun_chrome" )
		return 7;
	else if ( _ent.GetClassname() == "weapon_autoshotgun" || _ent.GetClassname() == "weapon_shotgun_spas" )
		return 8;
	else if ( _ent.GetClassname() == "weapon_hunting_rifle" )
		return 9;
	else if ( _ent.GetClassname() == "weapon_sniper_military" || _ent.GetClassname() == "weapon_sniper_awp" || _ent.GetClassname() == "weapon_sniper_scout" )
		return 10;
	else if ( _ent.GetClassname() == "weapon_pipe_bomb" )
		return 12;
	else if ( _ent.GetClassname() == "weapon_molotov" )
		return 13;
	else if ( _ent.GetClassname() == "weapon_vomitjar" )
		return 14;
	else if ( _ent.GetClassname() == "weapon_pain_pills" )
		return 15;
	else if ( _ent.GetClassname() == "weapon_first_aid_kit" || _ent.GetClassname() == "weapon_defibrillator" || _ent.GetClassname() == "weapon_upgradepack_incendiary" || _ent.GetClassname() == "weapon_upgradepack_explosive" )
		return 16;
	else if ( _ent.GetClassname() == "weapon_grenade_launcher" )
		return 17;
	else if ( _ent.GetClassname() == "weapon_adrenaline" )
		return 18;
	else if ( _ent.GetClassname() == "weapon_chainsaw" )
		return 19;
	else
		return;
}

/**
 * Gets the max ammo for the weapon.
 */
function VSLib::Entity::GetMaxAmmo()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( _ent.GetClassname().find("weapon_") == null )
		return;
	
	local AmmoType = GetNetPropInt( "m_iPrimaryAmmoType" );
	
	if ( AmmoType == 1 || AmmoType == 2 )
		return Convars.GetFloat( "ammo_pistol_max" ).tointeger();
	else if ( AmmoType == 3 )
		return Convars.GetFloat( "ammo_assaultrifle_max" ).tointeger();
	else if ( AmmoType == 5 )
		return Convars.GetFloat( "ammo_smg_max" ).tointeger();
	else if ( AmmoType == 6 )
		return Convars.GetFloat( "ammo_m60_max" ).tointeger();
	else if ( AmmoType == 7 )
		return Convars.GetFloat( "ammo_shotgun_max" ).tointeger();
	else if ( AmmoType == 8 )
		return Convars.GetFloat( "ammo_autoshotgun_max" ).tointeger();
	else if ( AmmoType == 9 )
		return Convars.GetFloat( "ammo_huntingrifle_max" ).tointeger();
	else if ( AmmoType == 10 )
		return Convars.GetFloat( "ammo_sniperrifle_max" ).tointeger();
	else if ( AmmoType == 12 )
		return Convars.GetFloat( "ammo_pipebomb_max" ).tointeger();
	else if ( AmmoType == 13 )
		return Convars.GetFloat( "ammo_molotov_max" ).tointeger();
	else if ( AmmoType == 14 )
		return Convars.GetFloat( "ammo_vomitjar_max" ).tointeger();
	else if ( AmmoType == 15 )
		return Convars.GetFloat( "ammo_painpills_max" ).tointeger();
	else if ( AmmoType == 16 )
		return Convars.GetFloat( "ammo_firstaid_max" ).tointeger();
	else if ( AmmoType == 17 )
		return Convars.GetFloat( "ammo_grenadelauncher_max" ).tointeger();
	else if ( AmmoType == 18 )
		return Convars.GetFloat( "ammo_adrenaline_max" ).tointeger();
	else if ( AmmoType == 19 )
		return Convars.GetFloat( "ammo_chainsaw_max" ).tointeger();
	else
		return;
}

/**
 * Gets the ammo for the weapon.
 */
function VSLib::Entity::GetAmmo()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( _ent.GetClassname().find("weapon_") == null )
		return;
	
	local owner = GetNetPropEntity( "m_hOwner" );
	
	if ( (!owner) || (!owner.IsPlayer()) )
		return;
	
	return owner.GetNetPropInt( "m_iAmmo", GetNetPropInt( "m_iPrimaryAmmoType" ) );
}

/**
 * Sets the ammo for the weapon.
 */
function VSLib::Entity::SetAmmo( amount )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( _ent.GetClassname().find("weapon_") == null )
		return;
	
	local owner = GetNetPropEntity( "m_hOwner" );
	
	if ( (!owner) || (!owner.IsPlayer()) )
		return;
	
	owner.SetNetProp( "m_iAmmo", amount.tointeger(), GetNetPropInt( "m_iPrimaryAmmoType" ) );
}

/**
 * Gets the ammo in the clip for the weapon.
 */
function VSLib::Entity::GetClip()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("Clip1" in _ent) )
		return;
	
	return _ent.Clip1();
}

/**
 * Sets the ammo in the clip for the weapon.
 */
function VSLib::Entity::SetClip( amount )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("SetClip1" in _ent) )
		return;
	
	_ent.SetClip1( amount.tointeger() );
}

/**
 * Gets the max ammo allowed in the clip for the weapon.
 */
function VSLib::Entity::GetMaxClip()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("GetMaxClip1" in _ent) )
		return;
	
	return _ent.GetMaxClip1();
}

/**
 * Gets the default clip for the weapon.
 */
function VSLib::Entity::GetDefaultClip()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("GetDefaultClip1" in _ent) )
		return;
	
	return _ent.GetDefaultClip1();
}

/**
 * Gets the current upgrades for the weapon.
 */
function VSLib::Entity::GetUpgrades()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( _ent.GetClassname().find("weapon_") == null )
		return;
	
	return GetNetPropInt( "m_upgradeBitVec" );
}

/**
 * Sets the current upgrades for the weapon.
 */
function VSLib::Entity::SetUpgrades( upgrades )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( _ent.GetClassname().find("weapon_") == null )
		return;
	
	if ( upgrades == 1 || upgrades == 2 || upgrades == 3 || upgrades == 5 || upgrades == 6 || upgrades == 7 )
		SetNetProp( "m_nUpgradedPrimaryAmmoLoaded", GetNetPropInt( "m_iClip1" ) );
	
	SetNetProp( "m_nUpgradedPrimaryAmmoLoaded", GetNetPropInt( "m_iClip1" ) );
	SetNetProp( "m_upgradeBitVec", upgrades.tointeger() );
}

/**
 * Returns true if the upgrade exists in the weapon's current upgrades.
 */
function VSLib::Entity::HasUpgrade( upgrade )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( _ent.GetClassname().find("weapon_") == null )
		return;
	
	local upgrades = GetNetPropInt( "m_upgradeBitVec" );
	
	return upgrades == ( upgrades | upgrade );
}

/**
 * Adds the upgrade to the weapon's current upgrades.
 */
function VSLib::Entity::AddUpgrade( upgrade )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( _ent.GetClassname().find("weapon_") == null )
		return;
	
	local upgrades = GetNetPropInt( "m_upgradeBitVec" );
	
	if ( HasUpgrade(upgrade) )
		return;
	
	if ( upgrade == 1 || upgrade == 2 )
		SetNetProp( "m_nUpgradedPrimaryAmmoLoaded", GetNetPropInt( "m_iClip1" ) );
	
	SetNetProp( "m_upgradeBitVec", ( upgrades | upgrade ) );
}

/**
 * Removes the upgrade from the weapon's current upgrades.
 */
function VSLib::Entity::RemoveUpgrade( upgrade )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( _ent.GetClassname().find("weapon_") == null )
		return;
	
	local flags = GetNetPropInt( "m_upgradeBitVec" );
	
	if ( !HasUpgrade(upgrade) )
		return;
	
	if ( upgrade == 1 || upgrade == 2 )
		SetNetProp( "m_nUpgradedPrimaryAmmoLoaded", 0 );
	
	SetNetProp( "m_upgradeBitVec", ( flags & ~upgrade ) );
}

/**
 * Gets the entity's last body region that took damage.
 */
function VSLib::Entity::GetLastHitGroup()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetNetPropInt( "m_LastHitGroup" );
}

/**
 * Sets the entity's last body region that took damage.
 */
function VSLib::Entity::SetLastHitGroup( nHitGroup )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return SetNetPropInt( "m_LastHitGroup", nHitGroup );
}

/**
 * Gets the entity's flags.
 */
function VSLib::Entity::GetFlags()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetNetPropInt( "m_fFlags" );
}

/**
 * Sets the entity's flags.
 */
function VSLib::Entity::SetFlags( flags )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	SetNetProp( "m_fFlags", flags.tointeger() );
}

/**
 * Returns true if the flag exists in the entity's current flags.
 */
function VSLib::Entity::HasFlag( flag )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local flags = GetNetPropInt( "m_fFlags" );
	
	return flags == ( flags | flag );
}

/**
 * Adds the flag to the entity's current flags.
 */
function VSLib::Entity::AddFlag( flag )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local flags = GetNetPropInt( "m_fFlags" );
	
	if ( HasFlag(flag) )
		return;
	
	SetNetProp( "m_fFlags", ( flags | flag ) );
}

/**
 * Removes the flag from the entity's current flags.
 */
function VSLib::Entity::RemoveFlag( flag )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local flags = GetNetPropInt( "m_fFlags" );
	
	if ( !HasFlag(flag) )
		return;
	
	SetNetProp( "m_fFlags", ( flags & ~flag ) );
}

/**
 * Gets the entity's eflags.
 */
function VSLib::Entity::GetEFlags()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetNetPropInt( "m_iEFlags" );
}

/**
 * Sets the entity's eflags.
 */
function VSLib::Entity::SetEFlags( flags )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	SetNetProp( "m_iEFlags", flags.tointeger() );
}

/**
 * Returns true if the flag exists in the entity's current eflags.
 */
function VSLib::Entity::IsEFlagSet( flag )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local flags = GetNetPropInt( "m_iEFlags" );
	
	return flags == ( flags | flag );
}

/**
 * Adds the flag to the entity's current eflags.
 */
function VSLib::Entity::AddEFlags( flag )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local flags = GetNetPropInt( "m_iEFlags" );
	
	if ( IsEFlagSet(flag) )
		return;
	
	SetNetProp( "m_iEFlags", ( flags | flag ) );
}

/**
 * Removes the flag from the entity's current eflags.
 */
function VSLib::Entity::RemoveEFlags( flag )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local flags = GetNetPropInt( "m_iEFlags" );
	
	if ( !IsEFlagSet(flag) )
		return;
	
	SetNetProp( "m_iEFlags", ( flags & ~flag ) );
}

/**
 * Returns the gender of the entity.
 */
function VSLib::Entity::GetGender()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetNetPropInt( "m_Gender" );
}

/**
 * Returns true if the gender is a male.
 */
function VSLib::Entity::IsMale()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( GetGender() == 1 || GetGender() == 3 || GetGender() == 5 || GetGender() == 6 || GetGender() == 7 || GetGender() == 9 || GetGender() == 10 || IsUncommonInfected() )
		return true;
	else if ( GetGender() == 18 )
	{
		if ( GetModel().find("_male") != null )
			return true;
	}
	
	return false;
}

/**
 * Returns true if the gender is a female.
 */
function VSLib::Entity::IsFemale()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( GetGender() == 2 || GetGender() == 4 || GetGender() == 8 || GetGender() == 19 )
		return true;
	else if ( GetGender() == 18 )
	{
		if ( GetModel().find("_female") != null )
			return true;
	}
	
	return false;
}

/**
 * Returns the type of uncommon infected.
 */
function VSLib::Entity::GetUncommonInfected()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( _ent.GetClassname() == "infected" )
	{
		if ( IsUncommonInfected() )
			return GetGender();
		else
			return Z_COMMON;
	}
	
	return;
}

/**
 * Gets the zombie's name
 */
function VSLib::Entity::GetZombieName()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( _ent.GetClassname() == "infected" )
		return "Infected";
	else if ( _ent.GetClassname() == "witch" )
	{
		if ( IsWitchBride() )
			return "Witch Bride";
		else
			return "Witch";
	}
	else if ( _ent.GetClassname() == "player" )
	{
		if (!("GetZombieType" in _ent))
			return;
		
		if ( _ent.GetZombieType() == Z_SMOKER )
			return "Smoker";
		else if ( _ent.GetZombieType() == Z_BOOMER )
			return "Boomer";
		else if ( _ent.GetZombieType() == Z_HUNTER )
			return "Hunter";
		else if ( _ent.GetZombieType() == Z_SPITTER )
			return "Spitter";
		else if ( _ent.GetZombieType() == Z_JOCKEY )
			return "Jockey";
		else if ( _ent.GetZombieType() == Z_CHARGER )
			return "Charger";
		else if ( _ent.GetZombieType() == Z_TANK )
			return "Tank";
		else if ( _ent.GetZombieType() == Z_SURVIVOR )
			return "Survivor";
	}
	
	return;
}

/**
 * Kills common infected and witches, and removes other entities from the map.
 */
function VSLib::Entity::Kill( dmgtype = 0, attacker = null )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( _ent.GetClassname() == "infected" || _ent.GetClassname() == "witch" )
	{
		Damage(GetHealth(), dmgtype, attacker);
		
		if ( IsAlive() && Entities.FindByClassname( null, "worldspawn" ) )
			Damage(GetHealth(), dmgtype, ::VSLib.Entity("worldspawn"));
	}
	else
		Input("Kill");
}

/**
 * Alternative method to kill/remove the entity from the map.
 */
function VSLib::Entity::KillEntity()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.Kill();
}

/**
 * Returns the base angles.
 */
function VSLib::Entity::GetAngles()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return _ent.GetAngles();
}

/**
 * Sets the base angles.
 */
function VSLib::Entity::SetAngles(x, y = 0.0, z = 0.0)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( typeof x == "QAngle" )
		return _ent.SetAngles(x);
	else
		return _ent.SetAngles(QAngle(x,y,z));
}

/**
 * Sets the base angles from another entity.
 *
 * @authors shotgunefx
 */
function VSLib::Entity::SetAnglesFrom(ent)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return _ent.SetAngles(ent.GetAngles());
}

/**
 * Sets the base angles via vector.
 * @authors shotgunefx
 */
function VSLib::Entity::SetAnglesVec(vec)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return _ent.SetAngles(vec);
}

/**
 * Sets the base angles via QAngle.
 * @authors shotgunefx
 */
function VSLib::Entity::SetAnglesFromQAngle(qangle)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return _ent.SetAngles(qangle);
}

/**
 * Kills/removes the entity and associated entities from the map.
 */
function VSLib::Entity::KillHierarchy()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	DoEntFire("!self", "KillHierarchy", "", 0, null, _ent);
}

/**
 * Attempts to "Use" or pick up another entity.
 */
function VSLib::Entity::Use(otherEntity)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	DoEntFire("!self", "Use", "", 0, _ent, otherEntity.GetBaseEntity());
}

/**
 * Attempts to "Use" or pick up another entity.
 */
function VSLib::Entity::UseOther(otherEntity)
{
	Use(otherEntity);
}

/**
 * Attempts to be "used" or picked up BY another entity.
 */
function VSLib::Entity::UsedByOther(otherEntity)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	DoEntFire("!self", "Use", "", 0, otherEntity.GetBaseEntity(), _ent);
}

/**
 * Set the alpha value of the entity.
 * Only seems to work for players.
 */
function VSLib::Entity::SetAlpha(value)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	DoEntFire("!self", "Alpha", value.tostring(), 0, null, _ent);
}

/**
 * Inputs a color to an entity. This is an alternative to SetColor().
 */
function VSLib::Entity::InputColor(red, green, blue)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	DoEntFire("!self", "Color", red + " " + green + " " + blue, 0, null, _ent);
}

/**
 * Parents an entity to this entity.
 * In other words, attaches an entity to this entity. Cool for attaching bumper cars
 * or other objects to players. If teleportOther is TRUE, the other entity is teleported
 * to this entity. If it is FALSE, the entity is parented without teleporting.
 *
 * @authors shotgunefx - added optional delay for teleporting
 */
function VSLib::Entity::AttachOther(otherEntity, teleportOther, delay = 0)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	teleportOther = (teleportOther.tointeger() > 0) ? true : false;
	
	if (teleportOther)
		otherEntity.SetLocation(GetLocation());
	
	DoEntFire("!self", "SetParent", "!activator", delay, _ent, otherEntity.GetBaseEntity());
}

/**
 * Attaches another entity to a specific point.
 * Call this function after AttachOther() to parent at a specific attachment point. For example,
 * if attachment equals "rhand", the object will be attached to the player's or entity's
 * right hand. "forward" to attach to head etc. Search for player or entity attachment points
 * on Google (i.e. "L4D2 survivor attachment points" or something along those lines).
 * If ShouldMaintainOffset is true, then the initial distance between the object is maintained,
 * and the angles usually point in the direction of the parent.
 *
 * @authors shotgunefx - added optional delay
 */
function VSLib::Entity::SetAttachmentPoint(otherEntity, attachment, bShouldMaintainOffset, delay = 0)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	attachment = attachment.tostring();
	bShouldMaintainOffset = (bShouldMaintainOffset.tointeger() > 0) ? true : false;
	
	if (bShouldMaintainOffset)
		DoEntFire("!self", "SetParentAttachmentMaintainOffset", attachment, delay, _ent, otherEntity.GetBaseEntity());
	else
		DoEntFire("!self", "SetParentAttachment", attachment, delay, _ent, otherEntity.GetBaseEntity());
}

/**
 * Remove the parenting.
 *
 * @authors shotgunefx - edit: added optional delay
 */
function VSLib::Entity::RemoveAttached(otherEntity, delay = 0)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	DoEntFire("!self", "ClearParent", "", delay, _ent, otherEntity.GetBaseEntity());
}

/**
 * Get move parent
 *
 * @authors shotgunefx 
 */
function VSLib::Entity::GetParent()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetMoveParent();
}

/**
 * Estimates the eye position.
 */
function VSLib::Entity::GetEyePosition()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	// If the entity has an eyeposition function, return it.
	if ("EyePosition" in _ent)
		return _ent.EyePosition();
	
	// if it's not a player, it probably doesn't have eyes...
	return GetLocation();
}

/**
 * Gets the entity that this entity is pointing at, or null if this entity is not pointing at a valid entity.
 * This is useful for things like detecting what entity a player may be looking at.
 *
 * @authors shotgunefx, added optional track mask
 */
function VSLib::Entity::GetLookingEntity(mask = 33579137)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if (!("EyeAngles" in _ent))
	{
		printl("VSLib Warning: Entity " + _idx + " does not have Eye Angles.");
		return;
	}
	
	local startPt = GetEyePosition();
	local endPt = startPt + _ent.EyeAngles().Forward().Scale(999999);
	
	local m_trace = { start = startPt, end = endPt, ignore = _ent, mask = mask };
	TraceLine(m_trace);
	
	if (!m_trace.hit || m_trace.enthit == null || m_trace.enthit == _ent)
		return null;
	
	if (m_trace.enthit.GetClassname() == "worldspawn" || !m_trace.enthit.IsValid())
		return null;
	
	return ::VSLib.Utils.GetEntityOrPlayer(m_trace.enthit);
}

/**
 * Returns the numerical index of the entity.
 */
function VSLib::Entity::GetBaseIndex()
{
	if (_ent == null)
	{
		printl("VSLib Warning: Entity is invalid.");
		return -1;
	}
	
	return _ent.GetEntityIndex();
}

/**
 * Kills the entity after the specified delay in seconds; fractions may be used if needed (e.g. 1.5 seconds).
 */
function VSLib::Entity::KillDelayed(seconds)
{
	if (_ent == null)
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	DoEntFire("!self", "Kill", "", seconds.tofloat(), null, _ent);
}

/**
 * Returns whether one ent is behind another
 * @authors shotgunefx
 */
function VSLib::Entity::IsBehind(otherEnt)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	local fwd = otherEnt.GetAngles().Forward()
	local o1 = _ent.GetOrigin();
	local o2 = otherEnt.GetLocation();
	local product = (o1["x"] - o2["x"]) * fwd["x"] + (o1["y"] - o2["y"]) * fwd["y"] + (o1["z"] - o2["z"]) * fwd["z"];
	if (product > 0.0)
		return false;
	else 
		return true;
}

/**
 * Returns whether one ent is in front of another
 * @authors shotgunefx
 */
function VSLib::Entity::IsInFront(otherEnt)
{
    return !IsBehind(otherEnt);
}

/**
 * Returns a vector position of where the entity is looking.
 */
function VSLib::Entity::GetLookingLocation()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if (!("EyeAngles" in _ent))
	{
		printl("VSLib Warning: Entity " + _idx + " does not have Eye Angles.");
		return;
	}
	
	local startPt = GetEyePosition();
	local endPt = startPt + _ent.EyeAngles().Forward().Scale(999999);
	
	local m_trace = { start = startPt, end = endPt, ignore = _ent, mask = TRACE_MASK_SHOT };
	TraceLine(m_trace);
	
	if (!m_trace.hit || m_trace.enthit == _ent)
		return null;
	
	return m_trace.pos;
}

/**
 * Ignites the entity for the specified time. Fractions can be used (e.g. 1.5 seconds).
 */
function VSLib::Entity::Ignite(time)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	time = time.tostring();
	
	HurtTime(1, 2056, 0.3, time);
	DoEntFire("!self", "IgniteLifetime", time, 0, null, _ent);
}

/**
 * Attaches a particle to this entity.
 * E.g. "gas_fireball" or "elevatorsparks". Internally spawns an
 * info_particle_system, so all effects that can be shown with that
 * entity can be shown with this function. This function will return the
 * particle system that was created, so if you need to attach it to a
 * specific attachment point or whatever, you can.
 */
function VSLib::Entity::AttachParticle(particleName, duration)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	particleName = particleName.tostring();
	duration = duration.tofloat();
	
	local particle = g_ModeScript.CreateSingleSimpleEntityFromTable({ classname = "info_particle_system", targetname = "vslib_tmp_" + UniqueString(), origin = GetLocation(), angles = QAngle(0,0,0), start_active = true, effect_name = particleName });
	
	if (!particle)
	{
		Msg("Warning: Could not create info_particle_system entity.");
		return;
	}
	
	DoEntFire("!self", "Start", "", 0, null, particle);
	
	local vsParticle = ::VSLib.Entity(particle);
	
	vsParticle.KillDelayed(duration);
	AttachOther(vsParticle, true);
	
	return vsParticle;
}

/**
 * Returns true if the entity is a player.
 */
function VSLib::Entity::IsPlayer()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	if ("IsPlayer" in _ent)
		return _ent.IsPlayer();
	
	return "player" == _ent.GetClassname().tolower();
}

/**
 * Returns true if the player is on the survivor team (Otherwise, infected).
 */
function VSLib::Entity::IsSurvivor()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	if (!IsPlayer())
		return false;
	
	return _ent.IsSurvivor();
}

/**
 * Returns true if the entity is alive.
 */
function VSLib::Entity::IsAlive()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	if ( _ent.GetClassname() == "infected" || _ent.GetClassname() == "witch" || _ent.GetClassname() == "player" )
		return GetNetPropInt( "m_lifeState" ) == 0;
	else
		return GetHealth() > 0;
}

/**
 * Returns true if the infected, witch or player is on fire.
 */
function VSLib::Entity::IsOnFire()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	if ( _ent.GetClassname() == "infected" || _ent.GetClassname() == "witch" )
		return GetNetPropBool( "m_bIsBurning" );
	else if ( _ent.GetClassname() == "player" )
		return _ent.IsOnFire();
	else
		return false;
}

/**
 * Extinguish a burning entity or player (also checks if entity is on fire first).
 * Returns true if the entity was extinguished.
 */
function VSLib::Entity::Extinguish()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	if (IsOnFire())
	{
		if ( _ent.GetClassname() == "player" )
			_ent.Extinguish();
		else
			Input( "IgniteLifetime", 0 );
		
		return true;
	}
	
	return false;
}

/**
 * Returns true if this entity is currently biled on.
 */
function VSLib::Entity::IsBiled()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	if ( _ent.GetClassname() == "infected" || _ent.GetClassname() == "witch" )
	{
		if ( GetNetPropInt( "m_Glow.m_glowColorOverride" ) == -4713783 )
			return true;
	}
	else if ( _ent.GetClassname() == "player" )
	{
		if(_idx in ::VSLib.EasyLogic.Cache)
			if ("_isBiled" in ::VSLib.EasyLogic.Cache[_idx])
				return ::VSLib.EasyLogic.Cache[_idx]._isBiled;
	}
	
	return false;
}

/**
 * Gets the survivor character ID
 */
function VSLib::Entity::GetSurvivorCharacter()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if (GetType() != Z_SURVIVOR)
		return;
	
	return GetNetPropInt( "m_survivorCharacter" );
}

/**
 * Returns the name of the entity.
 */
function VSLib::Entity::GetName()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	return _ent.GetName();
}

/**
 * Returns the global name of the entity.
 */
function VSLib::Entity::GetGlobalName()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	return GetNetPropString( "m_iGlobalname" );
}

/**
 * Returns the targetname of the entity.
 */
function VSLib::Entity::GetTargetname()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	if ( IsPlayer() && GetType() == Z_SURVIVOR && _ent.GetName() == "" )
	{
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
	}
	
	return _ent.GetName();
}

/**
 * Gets the actor name of the entity.
 */
function VSLib::Entity::GetActorName()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return "";
	}
	
	if ( _ent.GetClassname() == "infected" )
	{
		if ( IsUncommonInfected() )
		{
			if ( GetUncommonInfected() == Z_CEDA )
				return "Ceda";
			else if ( GetUncommonInfected() == Z_MUD )
				return "Crawler";
			else if ( GetUncommonInfected() == Z_ROADCREW )
				return "Undistractable";
			else if ( GetUncommonInfected() == Z_FALLEN )
				return "Fallen";
			else if ( GetUncommonInfected() == Z_RIOT )
				return "riot_control";
			else if ( GetUncommonInfected() == Z_CLOWN )
				return "Clown";
			else if ( GetUncommonInfected() == Z_JIMMY )
				return "Jimmy";
		}
		else
			return "Common";
	}
	else if ( _ent.GetClassname() == "witch" )
		return "Witch";
	else if ( _ent.GetClassname() == "player" )
	{
		if ( GetType() == Z_SURVIVOR )
		{
			if ( ::VSLib.Utils.GetSurvivorSet() == 1 )
			{
				if ( GetSurvivorCharacter() == 0 || GetSurvivorCharacter() == 4 )
					return "NamVet";
				else if ( GetSurvivorCharacter() == 1 || GetSurvivorCharacter() == 5 )
					return "TeenGirl";
				else if ( GetSurvivorCharacter() == 2 || GetSurvivorCharacter() == 7 )
					return "Manager";
				else if ( GetSurvivorCharacter() == 3 || GetSurvivorCharacter() == 6 )
					return "Biker";
				else
					return "Unknown";
			}
			else
			{
				if ( GetSurvivorCharacter() == 0 )
					return "Gambler";
				else if ( GetSurvivorCharacter() == 1 )
					return "Producer";
				else if ( GetSurvivorCharacter() == 2 )
					return "Coach";
				else if ( GetSurvivorCharacter() == 3 )
					return "Mechanic";
				else if ( GetSurvivorCharacter() == 4 )
					return "NamVet";
				else if ( GetSurvivorCharacter() == 5 )
					return "TeenGirl";
				else if ( GetSurvivorCharacter() == 6 )
					return "Biker";
				else if ( GetSurvivorCharacter() == 7 )
					return "Manager";
				else
					return "Unknown";
			}
		}
		else
		{
			return GetZombieName();
		}
	}
	
	return "";
}

/**
 * Returns entity's first move child if exists
 */
function VSLib::Entity::FirstMoveChild()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local firstMoveChild = _ent.FirstMoveChild();
	if (!firstMoveChild)
		return null;
	return ::VSLib.Utils.GetEntityOrPlayer(firstMoveChild);
}

/**
 * If in hierarchy, retrieves the entity's parent.
 */
function VSLib::Entity::GetMoveParent()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local moveParent = _ent.GetMoveParent();
	if (!moveParent)
		return null;
	return ::VSLib.Utils.GetEntityOrPlayer(moveParent);
}

/**
 * Returns next child entity
 */
function VSLib::Entity::NextMovePeer()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local nextMovePeer = _ent.NextMovePeer();
	if (!nextMovePeer)
		return null;
	return ::VSLib.Utils.GetEntityOrPlayer(nextMovePeer);
}

/**
 * If in hierarchy, walks up the hierarchy to find the root parent.
 */
function VSLib::Entity::GetRootMoveParent()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local rootMoveParent = _ent.GetRootMoveParent();
	if (!rootMoveParent)
		return null;
	return ::VSLib.Utils.GetEntityOrPlayer(rootMoveParent);
}

/**
 * Looks up a context and returns it if available. May return string, float, or null (if the context isn't found).
 */
function VSLib::Entity::GetContext(str)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return _ent.GetContext(str);
}

/**
 * Stores any key/value pair in this entity's dialog contexts. Value must be a string. Will last for duration (set 0 to mean 'forever').
 */
function VSLib::Entity::SetContext( name, value, duration )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( duration == 0 )
		duration = 999999;
	
	_ent.SetContext(name, value.tostring(), duration);
}

/**
 * Stores any key/value pair in this entity's dialog contexts. Value must be a number (int or float). Will last for duration (set 0 to mean 'forever').
 */
function VSLib::Entity::SetContextNum( name, value, duration )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( duration == 0 )
		duration = 999999;
	
	_ent.SetContextNum(name, value, duration);
}

/**
 * Returns the entity as an EHANDLE.
 */
function VSLib::Entity::GetEntityHandle()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return _ent.GetEntityHandle();
}

/**
 * Returns the distance (in units) to the ground from the entity's origin.
 */
function VSLib::Entity::GetDistanceToGround()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local startPt = GetLocation();
	local endPt = startPt + Vector(0, 0, -9999999);
	
	local m_trace = { start = startPt, end = endPt, ignore = _ent, mask = TRACE_MASK_SHOT };
	TraceLine(m_trace);
	
	if (m_trace.enthit == _ent || !m_trace.hit)
		return 0.0;
	
	return ::VSLib.Utils.CalculateDistance(startPt, m_trace.pos);
}

/**
 * Returns the position on ground below from the entity's origin.
 * @authors shotgunefx
 */
function VSLib::Entity::GetLocationBelow()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local startPt = GetLocation();
	local endPt = startPt + Vector(0, 0, -9999999);
	
	local m_trace = { start = startPt, end = endPt, ignore = _ent, mask = TRACE_MASK_SHOT };
	TraceLine(m_trace);
	
	if (!m_trace.hit)
		return;
	
	return m_trace.pos;
}

/**
 * Returns true if the entity is in the air.
 */
function VSLib::Entity::IsEntityInAir()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetDistanceToGround() > 5.0;
}

/**
 * Returns the entity's button mask
 */
function VSLib::Entity::GetPressedButtons()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	return _ent.GetButtonMask();
}

/**
 * Returns if the client is pressing the specified button
 */
function VSLib::Entity::IsPressingButton(btn)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	return (_ent.GetButtonMask() & btn) > 0;
}

/**
 * Returns true if this player is currently pressing +lookspin (if bound)
 * @authors shotgunefx
 */
function VSLib::Entity::IsPressingLookspin()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	return (_ent.GetButtonMask() & 0x2000000) > 0;
}

/**
 * Returns true if this player is currently firing a weapon (either a gun, bat, etc).
 * Note that it doesn't check if the gun has any ammo (just checks for key press).
 */
function VSLib::Entity::IsPressingAttack()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	return (_ent.GetButtonMask() & (1 << 0)) > 0;
}

/**
 * Returns true if this player is jumping (or pressing the space bar button for example).
 */
function VSLib::Entity::IsPressingJump()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	return (_ent.GetButtonMask() & (1 << 1)) > 0;
}

/**
 * Returns true if this player is ducking (or pressing the CTRL key for example).
 */
function VSLib::Entity::IsPressingDuck()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	return (_ent.GetButtonMask() & (1 << 2)) > 0;
}

/**
 * Returns true if this player is pressing forward (or pressing the W key for example).
 */
function VSLib::Entity::IsPressingForward()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	return (_ent.GetButtonMask() & (1 << 3)) > 0;
}

/**
 * Returns true if this player is pressing backward (or pressing the S key for example).
 */
function VSLib::Entity::IsPressingBackward()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	return (_ent.GetButtonMask() & (1 << 4)) > 0;
}

/**
 * Returns true if this player is pressing the USE key (or pressing the E key for example).
 */
function VSLib::Entity::IsPressingUse()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	return (_ent.GetButtonMask() & (1 << 5)) > 0;
}

/**
 * Returns true if this player is pressing the Left key (or pressing the A key for example).
 */
function VSLib::Entity::IsPressingLeft()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	return (_ent.GetButtonMask() & (1 << 9)) > 0;
}

/**
 * Returns true if this player is pressing the Right key (or pressing the D key for example).
 */
function VSLib::Entity::IsPressingRight()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	return (_ent.GetButtonMask() & (1 << 10)) > 0;
}

/**
 * Returns true if this player is pressing the shove key (or pressing right-click for example).
 */
function VSLib::Entity::IsPressingShove()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	return (_ent.GetButtonMask() & (1 << 11)) > 0;
}

/**
 * Returns true if this player is pressing the reload key (or pressing the R key for example).
 */
function VSLib::Entity::IsPressingReload()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	return (_ent.GetButtonMask() & (1 << 13)) > 0;
}

/**
 * Returns true if this player is pressing the walk key (or pressing the shift key for example).
 */
function VSLib::Entity::IsPressingWalk()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	return (_ent.GetButtonMask() & (1 << 17)) > 0;
}

/**
 * Returns true if this player is pressing the zoom key.
 */
function VSLib::Entity::IsPressingZoom()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	return (_ent.GetButtonMask() & (1 << 19)) > 0;
}

/**
 * Returns the entity's owner, or null if the owner does not exist
 */
function VSLib::Entity::GetOwnerEntity()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local owner = _ent.GetOwnerEntity();
	if (!owner)
		return null;
	return ::VSLib.Utils.GetEntityOrPlayer(owner);
}

/**
 * Returns the entity's name stripped of template unique decoration.
 */
function VSLib::Entity::GetPreTemplateName()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return _ent.GetPreTemplateName();
}


/**
 * Commands this Entity to move to a particular location (only applies to bots).
 */
function VSLib::Entity::BotMoveToLocation(newpos)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Bot " + _idx + " is invalid.");
		return;
	}
	
	return CommandABot( { cmd = 1, pos = newpos, bot = _ent } );
}

/**
 * Commands this Entity to move to another entity's location (only applies to bots).
 */
function VSLib::Entity::BotMoveToOther(otherEntity)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Bot " + _idx + " is invalid.");
		return;
	}
	
	return CommandABot( { cmd = 1, pos = otherEntity.GetLocation(), bot = _ent } );
}

/**
 * Commands the other bot entity to move to this entity's location (only applies to bots).
 */
function VSLib::Entity::BotMoveOtherToThis(otherEntity)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Bot " + _idx + " is invalid.");
		return;
	}
	
	return CommandABot( { cmd = 1, pos = GetLocation(), bot = otherEntity.GetBaseEntity() } );
}

/**
 * Commands this Entity to attack a particular entity (only applies to bots).
 */
function VSLib::Entity::BotAttack(otherEntity)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Bot " + _idx + " is invalid.");
		return;
	}
	
	return CommandABot( { cmd = 0, target = otherEntity.GetBaseEntity(), bot = _ent } );
}

/**
 * Commands this Entity to retreat from a particular entity (only applies to bots).
 */
function VSLib::Entity::BotRetreatFrom(otherEntity)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Bot " + _idx + " is invalid.");
		return;
	}
	
	return CommandABot( { cmd = 2, target = otherEntity.GetBaseEntity(), bot = _ent } );
}

/**
 * Returns the bot to normal after it is commanded.
 */
function VSLib::Entity::BotReset()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Bot " + _idx + " is invalid.");
		return;
	}
	
	return CommandABot( { cmd = 3, bot = _ent } );
}

/**
 * Plays a sound file on an entity
 */
function VSLib::Entity::EmitSound( file )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
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
	
	g_MapScript.EmitSoundOn(file, _ent);
}

/**
 * Stops a sound on an entity
 */
function VSLib::Entity::StopSound( file )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	g_MapScript.StopSoundOn( file, _ent );
}

/**
 * Plays an ambient sound file on an entity
 */
function VSLib::Entity::EmitAmbientSound( file, volume = 1.0, soundlevel = 350, pitch = 100 )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if (file == "" || !file)
		return;
	
	if ( file.find(".wav") == null && file.find(".mp3") == null )
	{
		if ( !(file in ::EasyLogic.PrecachedSounds) )
		{
			printf("VSLib: Precaching named sound: %s", file);
			_ent.PrecacheScriptSound(file);
			::EasyLogic.PrecachedSounds[file] <- 1;
		}
	}
	
	EmitAmbientSoundOn(file, volume, soundlevel, pitch, _ent);
}

/**
 * Stops an ambient sound on an entity
 */
function VSLib::Entity::StopAmbientSound( file )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	StopAmbientSoundOn( file, _ent );
}

/**
 * Plays a sound file on an entity from an ambient_generic
 */
function VSLib::Entity::PlaySoundFile( file, volume = 10, pitch = 100, radius = 500, keyvalues = {} )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if (file == "" || !file || GetTargetname() == "")
		return;
	
	if ( file.find(".wav") == null && file.find(".mp3") == null )
	{
		if ( !(file in ::EasyLogic.PrecachedSounds) )
		{
			printf("VSLib: Precaching named sound: %s", file);
			_ent.PrecacheScriptSound(file);
			::EasyLogic.PrecachedSounds[file] <- 1;
		}
	}
	
	local t = { health = volume, message = file, SourceEntityName = GetTargetname(), pitch = pitch, pitchstart = pitch, radius = radius, spawnflags = "32", };
	foreach (idx, val in t)
		keyvalues[idx] <- val;
	local ent = ::VSLib.Utils.CreateEntity("ambient_generic", Vector(0,0,0), QAngle(0,0,0), keyvalues);
	ent.Input("PlaySound");
	ent.Kill();
}

/**
 * Returns true if the entity is a bot.
 */
function VSLib::Entity::IsBot()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	return IsPlayerABot(_ent);
}

/**
 * Sets the sense flags for this player.
 */
function VSLib::Entity::SetSenseFlags(flags)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if (!IsBot())
		return;
	
	_ent.SetSenseFlags(flags);
}

/**
 * Sets if the target can see.
 */
function VSLib::Entity::ChangeBotEyes(hasEyes)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if (!IsBot())
		return;
	
	if (!hasEyes)
		_ent.SetSenseFlags(_ent.GetSenseFlags() | BOT_CANT_SEE);
	else
		_ent.SetSenseFlags(_ent.GetSenseFlags() & ~BOT_CANT_SEE);
}

/**
 * Gets the sense flags for this player.
 */
function VSLib::Entity::GetSenseFlags()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return 0;
	}
	
	if (!IsBot())
		return 0;
	
	return _ent.GetSenseFlags();
}

/**
 * Returns true if the entity is a real human (non-bot).
 */
function VSLib::Entity::IsHuman()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	return !IsBot();
}

/**
 * Returns true if the witch is a bride.
 */
function VSLib::Entity::IsWitchBride()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	if ( _ent.GetClassname() == "witch" && GetGender() == 19 )
		return true;
	
	return false;
}

/**
 * Returns true if the infected is an uncommon.
 */
function VSLib::Entity::IsUncommonInfected()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	if ( GetGender() >= 11 && GetGender() <= 17 )
		return true;
	
	return false;
}

/**
 * Returns true if the entity is on the ground.
 */
function VSLib::Entity::IsOnGround()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	return HasFlag(1);
}

/**
 * Returns true if the entity is ducking.
 */
function VSLib::Entity::IsDucking()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	return HasFlag(3);
}

/**
 * Returns true if the entity is jumping.
 */
function VSLib::Entity::IsJumping()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	if (IsDucking())
		return false;
	
	return HasFlag(2);
}

/**
 * Returns true if the infected is carrying an item.
 */
function VSLib::Entity::IsCarryingItem()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	if ( _ent.GetClassname() == "infected" )
		return GetNetPropBool( "m_nFallenFlags" );
	
	return false;
}

/**
 * Adds to the entity's THINK function. You can use "this.ent" when you need to use the VSLib::Entity.
 * 
 * @param func A function to add to the think timer.
 */
function VSLib::Entity::AddThinkFunction( func )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local funcName = "_thnk_" + UniqueString();
	_ent.ValidateScriptScope();
	local scrScope = _ent.GetScriptScope();
	scrScope.ent <- this;
	scrScope[funcName] <- func;
	AddThinkToEnt(_ent, funcName);
}

/**
 * Returns the entity's script scope.
 */
function VSLib::Entity::GetScriptScope( )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.ValidateScriptScope();
	return _ent.GetScriptScope();
}

/**
 * Returns the entity's unique identifier used to refer to the entity within the scripting system.
 */
function VSLib::Entity::GetScriptID( )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return _ent.GetScriptId();
}

/**
 * Connects an output to a function
 *
 * @param output The output name (string)
 * @param func Function to fire (pass in a function, not a string name)
 * @param name Function name (pass in a string name, not a function)
 */
function VSLib::Entity::ConnectOutput( output, func, name = "" )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local oname = "";
	
	if ( name != "" )
		oname = "_vslib_out" + name;
	else
		oname = "_vslib_out" + UniqueString();
	
	GetScriptScope()[oname] <- func;
	_ent.ConnectOutput( output, oname );
}

/**
 * Removes a connected script function from an I/O event.
 *
 * @param output The output name (string)
 * @param name Function name (pass in a string name, not a function)
 */
function VSLib::Entity::DisconnectOutput( output, name )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local oname = "_vslib_out" + name;
	_ent.DisconnectOutput( output, oname );
}

/**
 * Gets the closest entity from a passed in table
 */
function VSLib::Entity::GetClosestEntityFromTable( table )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local dist = null;
	local ent = null;
	
	foreach( entity in table )
	{
		if ( entity.GetEntityHandle() != GetEntityHandle() )
		{
			if ( !dist || ::VSLib.Utils.CalculateDistance(GetLocation(), entity.GetLocation()) < dist )
			{
				dist = ::VSLib.Utils.CalculateDistance(GetLocation(), entity.GetLocation());
				ent = entity;
			}
		}
	}
	
	return ent;
}

/**
 * Gets the closest survivor
 */
function VSLib::Entity::GetClosestSurvivor()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetClosestEntityFromTable( ::VSLib.EasyLogic.Players.Survivors() );
}

/**
 * Gets the closest L4D1 survivor
 */
function VSLib::Entity::GetClosestL4D1Survivor()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetClosestEntityFromTable( ::VSLib.EasyLogic.Players.L4D1Survivors() );
}

/**
 * Gets the closest L4D1 or L4D2 survivor
 */
function VSLib::Entity::GetAnyClosestSurvivor()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetClosestEntityFromTable( ::VSLib.EasyLogic.Players.AllSurvivors() );
}

/**
 * Gets the closest human survivor
 */
function VSLib::Entity::GetClosestHumanSurvivor()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local dist = null;
	local surv = null;
	
	foreach( survivor in ::VSLib.EasyLogic.Players.AllSurvivors() )
	{
		if ( survivor.IsHuman() && survivor.GetEntityHandle() != GetEntityHandle() )
		{
			if ( !dist || ::VSLib.Utils.CalculateDistance(GetLocation(), survivor.GetLocation()) < dist )
			{
				dist = ::VSLib.Utils.CalculateDistance(GetLocation(), survivor.GetLocation());
				surv = survivor;
			}
		}
	}
	
	return surv;
}

/**
 * Get the distance to the closest survivor
 */
function VSLib::Entity::GetDistanceToClosestSurvivor()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local survivor = GetClosestSurvivor();
	
	if ( !survivor )
		return;
	
	return ::VSLib.Utils.CalculateDistance(GetLocation(), survivor.GetLocation());
}

/**
 * Get the distance to the closest L4D1 survivor
 */
function VSLib::Entity::GetDistanceToClosestL4D1Survivor()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local survivor = GetClosestL4D1Survivor();
	
	if ( !survivor )
		return;
	
	return ::VSLib.Utils.CalculateDistance(GetLocation(), survivor.GetLocation());
}

/**
 * Get the distance to the closest L4D1 or L4D2 survivor
 */
function VSLib::Entity::GetDistanceToAnyClosestSurvivor()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	local survivor = GetAnyClosestSurvivor();
	
	if ( !survivor )
		return;
	
	return ::VSLib.Utils.CalculateDistance(GetLocation(), survivor.GetLocation());
}

/**
 * Gets the closest infected
 */
function VSLib::Entity::GetClosestInfected()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetClosestEntityFromTable( ::VSLib.EasyLogic.Zombies.All() );
}

/**
 * Gets the closest special infected
 */
function VSLib::Entity::GetClosestSpecialInfected()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetClosestEntityFromTable( ::VSLib.EasyLogic.Players.Infected() );
}

/**
 * Gets the closest smoker
 */
function VSLib::Entity::GetClosestSmoker()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetClosestEntityFromTable( ::VSLib.EasyLogic.Players.OfType(Z_SMOKER) );
}

/**
 * Gets the closest boomer
 */
function VSLib::Entity::GetClosestBoomer()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetClosestEntityFromTable( ::VSLib.EasyLogic.Players.OfType(Z_BOOMER) );
}

/**
 * Gets the closest hunter
 */
function VSLib::Entity::GetClosestHunter()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetClosestEntityFromTable( ::VSLib.EasyLogic.Players.OfType(Z_HUNTER) );
}

/**
 * Gets the closest spitter
 */
function VSLib::Entity::GetClosestSpitter()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetClosestEntityFromTable( ::VSLib.EasyLogic.Players.OfType(Z_SPITTER) );
}

/**
 * Gets the closest jockey
 */
function VSLib::Entity::GetClosestJockey()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetClosestEntityFromTable( ::VSLib.EasyLogic.Players.OfType(Z_JOCKEY) );
}

/**
 * Gets the closest charger
 */
function VSLib::Entity::GetClosestCharger()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetClosestEntityFromTable( ::VSLib.EasyLogic.Players.OfType(Z_CHARGER) );
}

/**
 * Gets the closest tank
 */
function VSLib::Entity::GetClosestTank()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetClosestEntityFromTable( ::VSLib.EasyLogic.Players.OfType(Z_TANK) );
}

/**
 * Gets the closest witch
 */
function VSLib::Entity::GetClosestWitch()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetClosestEntityFromTable( ::VSLib.EasyLogic.Zombies.Witches() );
}

/**
 * Gets the closest common infected
 */
function VSLib::Entity::GetClosestCommonInfected()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetClosestEntityFromTable( ::VSLib.EasyLogic.Zombies.CommonInfected() );
}

/**
 * Gets the closest uncommon infected
 */
function VSLib::Entity::GetClosestUncommonInfected()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetClosestEntityFromTable( ::VSLib.EasyLogic.Zombies.UncommonInfected() );
}

/**
 * Get the speed the entity is moving
 */
function VSLib::Entity::GetMovementSpeed()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	return GetNetPropFloat( "m_flGroundSpeed" );
}


/**
 * Sets the entity's alpha
 *
 * @param value An integer value between 0 and 255
 */
function VSLib::Entity::SetEntityRenderAmt( value )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	_ent.__KeyValueFromInt("renderamt", value.tointeger());
}


/**
 * Returns true if this entity can trace to another entity without hitting anything.
 * I.e. if a line can be drawn from this entity to the other entity without any collision.
 */
function VSLib::Entity::CanTraceToOtherEntity(otherEntity, height = 5)
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	local begin = GetLocation() + Vector(0, 0, height);
	local finish = otherEntity.GetLocation() + Vector(0, 0, height);
	
	// add 5 to z-axis so it doesn't collide with level ground
	local m_trace = { start = begin, end = finish, ignore = _ent, mask = TRACE_MASK_SHOT };
	TraceLine(m_trace);
	
	if (!m_trace.hit || m_trace.enthit == null || m_trace.enthit == _ent)
		return false;
	
	if (m_trace.enthit.GetClassname() == "worldspawn" || !m_trace.enthit.IsValid())
		return false;
	
	if (m_trace.enthit == otherEntity.GetBaseEntity() || ::VSLib.Utils.AreVectorsEqual(m_trace.pos, finish))
		return true;
	
	return false;
}


//
//  CBaseAnimating class functions
//


/**
 * Get the named attachement id.
 */
function VSLib::Entity::LookupAttachment( name )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("LookupAttachment" in _ent) )
		return;
	
	return _ent.LookupAttachment( name );
}

/**
 * Get the attachement id's origin vector.
 */
function VSLib::Entity::GetAttachmentOrigin( id )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("GetAttachmentOrigin" in _ent) )
		return;
	
	return _ent.GetAttachmentOrigin( id );
}

/**
 * Get the attachement id's angles.
 */
function VSLib::Entity::GetAttachmentAngles( id )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("GetAttachmentAngles" in _ent) )
		return;
	
	return _ent.GetAttachmentAngles( id );
}

/**
 * Ask whether the main sequence is done playing.
 */
function VSLib::Entity::IsSequenceFinished()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("IsSequenceFinished" in _ent) )
		return;
	
	return _ent.IsSequenceFinished();
}

/**
 * Sets a bodygroup.
 */
function VSLib::Entity::SetBodygroup( group, value )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("SetBodygroup" in _ent) )
		return;
	
	_ent.SetBodygroup( group, value );
}

/**
 * Get the named attachment's parent bone index.
 */
function VSLib::Entity::GetAttachmentBone( id )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("GetAttachmentBone" in _ent) )
		return;
	
	return _ent.GetAttachmentBone( id );
}

/**
 * Get the bone id's origin vector.
 */
function VSLib::Entity::GetBoneOrigin( id )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("GetBoneOrigin" in _ent) )
		return;
	
	return _ent.GetBoneOrigin( id );
}

/**
 * Get the bone id's angles as a p,y,r vector.
 */
function VSLib::Entity::GetBoneAngles( id )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("GetBoneAngles" in _ent) )
		return;
	
	return _ent.GetBoneAngles( id );
}

/**
 * Get the named activity index.
 */
function VSLib::Entity::LookupActivity( name )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("LookupActivity" in _ent) )
		return;
	
	return _ent.LookupActivity( name );
}

/**
 * Get the named bone index.
 */
function VSLib::Entity::LookupBone( name )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("LookupBone" in _ent) )
		return;
	
	return _ent.LookupBone( name );
}

/**
 * Looks up a sequence by sequence name or activity name.
 */
function VSLib::Entity::LookupSequence( name )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("LookupSequence" in _ent) )
		return;
	
	return _ent.LookupSequence( name );
}

/**
 * Set a sequence by id.
 */
function VSLib::Entity::SetSequence( id )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("SetSequence" in _ent) )
		return;
	
	_ent.SetSequence( id );
}

/**
 * Reset a sequence by id. If the id is different than the current sequence, switch to the new sequence.
 */
function VSLib::Entity::ResetSequence( id )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("ResetSequence" in _ent) )
		return;
	
	_ent.ResetSequence( id );
}

/**
 * Get the current sequence id.
 */
function VSLib::Entity::GetSequence()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("GetSequence" in _ent) )
		return;
	
	return _ent.GetSequence();
}

/**
 * Get the activity name for a sequence by id.
 */
function VSLib::Entity::GetSequenceActivityName( id )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("GetSequenceActivityName" in _ent) )
		return;
	
	return _ent.GetSequenceActivityName( id );
}

/**
 * Get a sequence name by id.
 */
function VSLib::Entity::GetSequenceName( id )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("GetSequenceName" in _ent) )
		return;
	
	return _ent.GetSequenceName( id );
}

/**
 * Get a sequence duration by id.
 */
function VSLib::Entity::GetSequenceDuration( id )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("GetSequenceDuration" in _ent) )
		return;
	
	return _ent.GetSequenceDuration( id );
}

/**
 * Get a bodygroup by id.
 */
function VSLib::Entity::GetBodygroup( id )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("GetBodygroup" in _ent) )
		return;
	
	return _ent.GetBodygroup( id );
}

/**
 * Get the bodygroup id's name.
 */
function VSLib::Entity::GetBodygroupName( id )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("GetBodygroupName" in _ent) )
		return;
	
	return _ent.GetBodygroupName( id );
}

/**
 * Find a bodygroup id by name.
 */
function VSLib::Entity::FindBodygroupByName( name )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("FindBodygroupByName" in _ent) )
		return;
	
	return _ent.FindBodygroupByName( name );
}

/**
 * Get name by group and part.
 */
function VSLib::Entity::GetBodygroupPartName( group, part )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("GetBodygroupPartName" in _ent) )
		return;
	
	return _ent.GetBodygroupPartName( group, part );
}

/**
 * Gets the entity's model scale.
 */
function VSLib::Entity::GetModelScale()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("GetModelScale" in _ent) )
		return GetNetPropFloat( "m_flModelScale" );
	
	return _ent.GetModelScale();
}

/**
 * Changes a model's scale over time.
 */
function VSLib::Entity::SetModelScale( scale, changeDuration = 0.0 )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("SetModelScale" in _ent) )
	{
		SetNetProp( "m_flModelScale", scale.tofloat() );
		return;
	}
	
	_ent.SetModelScale( id, changeDuration );
}

/**
 * Sets a pose parameter value.
 */
function VSLib::Entity::SetPoseParameter( id, value )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("SetPoseParameter" in _ent) )
		return;
	
	return _ent.SetPoseParameter( id, value );
}


//
//  CBaseFlex class functions
//


/**
 * Returns the instance of the oldest active scene entity (if any).
 */
function VSLib::Entity::GetCurrentScene()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return null;
	}
	
	if ( !("GetCurrentScene" in _ent) )
		return null;
	
	local instancedScene = _ent.GetCurrentScene();
	if (!instancedScene)
		return null;
	
	return ::VSLib.Entity(instancedScene);
}

/**
 * Returns the instance of the scene entity at the specified index.
 */
function VSLib::Entity::GetSceneByIndex( index )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return null;
	}
	
	if ( !("GetSceneByIndex" in _ent) )
		return null;
	
	local instancedScene = _ent.GetSceneByIndex( index );
	if (!instancedScene)
		return null;
	
	return ::VSLib.Entity(instancedScene);
}

/**
 * Force the entity to play the specified .vcd file.
 */
function VSLib::Entity::PlayScene( sceneName, postDelay = 0.0 )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("PlayScene" in _ent) )
		return;
	
	return _ent.PlayScene( sceneName, postDelay );
}


//
//  CTerrorWeapon class functions
//


/**
 * Gets the weapon's ammo in clip1.
 */
function VSLib::Entity::Clip1()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("Clip1" in _ent) )
		return;
	
	return _ent.Clip1();
}

/**
 * Gets the weapon's ammo in clip2.
 */
function VSLib::Entity::Clip2()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("Clip2" in _ent) )
		return;
	
	return _ent.Clip2();
}

/**
 * Gets the weapon's default ammo for clip1.
 */
function VSLib::Entity::GetDefaultClip1()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("GetDefaultClip1" in _ent) )
		return;
	
	return _ent.GetDefaultClip1();
}

/**
 * Gets the weapon's default ammo for clip2.
 */
function VSLib::Entity::GetDefaultClip2()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("GetDefaultClip2" in _ent) )
		return;
	
	return _ent.GetDefaultClip2();
}

/**
 * Gets the weapon's maximum ammo for clip1.
 */
function VSLib::Entity::GetMaxClip1()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("GetMaxClip1" in _ent) )
		return;
	
	return _ent.GetMaxClip1();
}

/**
 * Gets the weapon's maximum ammo for clip2.
 */
function VSLib::Entity::GetMaxClip2()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("GetMaxClip2" in _ent) )
		return;
	
	return _ent.GetMaxClip2();
}

/**
 * Sets the weapon's ammo for clip1.
 */
function VSLib::Entity::SetClip1( amount )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("SetClip1" in _ent) )
		return;
	
	_ent.SetClip1( amount );
}

/**
 * Sets the weapon's ammo for clip2.
 */
function VSLib::Entity::SetClip2( amount )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("SetClip2" in _ent) )
		return;
	
	_ent.SetClip2( amount );
}

/**
 * Gives the weapon default ammo.
 */
function VSLib::Entity::GiveDefaultAmmo()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("GiveDefaultAmmo" in _ent) )
		return;
	
	_ent.GiveDefaultAmmo();
}

/**
 * Force the weapon to reload.
 */
function VSLib::Entity::Reload()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("Reload" in _ent) )
		return;
	
	_ent.Reload();
}


//
//  CBaseTrigger class functions
//


/**
 * Disable the trigger.
 */
function VSLib::Entity::Disable()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("Disable" in _ent) )
		return;
	
	_ent.Disable();
}

/**
 * Enable the trigger.
 */
function VSLib::Entity::Enable()
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return;
	}
	
	if ( !("Enable" in _ent) )
		return;
	
	_ent.Enable();
}

/**
 * Checks whether the passed entity is touching the trigger.
 */
function VSLib::Entity::IsTouching( entity )
{
	if (!IsEntityValid())
	{
		printl("VSLib Warning: Entity " + _idx + " is invalid.");
		return false;
	}
	
	if ( !("IsTouching" in _ent) )
		return false;
	
	if ( typeof entity == "VSLIB_ENTITY" || typeof entity == "VSLIB_PLAYER" )
		entity = entity.GetBaseEntity();
	
	return _ent.IsTouching( entity );
}



/**
 * Processes damage data associated with ::VSLib.
 */
if (!("AllowTakeDamage" in getroottable()))
{
	::AllowTakeDamage <- function (damageTable)
	{
		// Process triggered hurts
		if (damageTable.Attacker == ::VSLib.EntData._lastHurt)
		{
			foreach (hEnt in ::VSLib.EntData._hurtIgnore)
				if (hEnt.GetIndex() == damageTable.Victim.GetEntityIndex())
					return false;
			
			if (!::VSLib.EntData._hurtIntent || damageTable.Victim == ::VSLib.EntData._hurtIntent)
			{
				damageTable.DamageDone = ::VSLib.EntData._hurtDmg;
				return true;
			}
			
			return false;
		}
		
		// Process hooks
		if ("EasyLogic" in ::VSLib)
		{
			if (damageTable.Victim != null)
			{
				local name = damageTable.Victim.GetClassname();
				if (name in ::VSLib.EasyLogic.OnDamage)
				{
					local victim = ::VSLib.Utils.GetEntityOrPlayer(damageTable.Victim);
					local attacker = ::VSLib.Utils.GetEntityOrPlayer(damageTable.Attacker);
					
					local damagesave = damageTable.DamageDone;
					damageTable.DamageDone = ::VSLib.EasyLogic.OnDamage[name](victim, attacker, damageTable.DamageDone, damageTable);
					
					if (damageTable.DamageDone == null)
						damageTable.DamageDone = damagesave;
					else if (damageTable.DamageDone <= 0)
						return false;
					
					return true;
				}
			}
			
			foreach (func in ::VSLib.EasyLogic.OnTakeDamage)
			{
				if (func(damageTable) == false)
					return false;
			}
		}
		
		if ( "ModeAllowTakeDamage" in g_ModeScript )
			return ModeAllowTakeDamage(damageTable);
		if ( "MapAllowTakeDamage" in g_ModeScript )
			return MapAllowTakeDamage(damageTable);
		
		return true;
	}
}

if ( ("AllowTakeDamage" in g_ModeScript) && (g_ModeScript.AllowTakeDamage != getroottable().AllowTakeDamage) )
{
	g_ModeScript.ModeAllowTakeDamage <- g_ModeScript.AllowTakeDamage;
	g_ModeScript.AllowTakeDamage <- getroottable().AllowTakeDamage;
}
if ( ("AllowTakeDamage" in g_MapScript) && (g_MapScript.AllowTakeDamage != getroottable().AllowTakeDamage) )
{
	g_ModeScript.MapAllowTakeDamage <- g_MapScript.AllowTakeDamage;
	g_ModeScript.AllowTakeDamage <- getroottable().AllowTakeDamage;
}
else
{
	g_ModeScript.AllowTakeDamage <- getroottable().AllowTakeDamage;
}



/**
 * Associates the AllowBash() function with ::VSLib.
 */
if (!("AllowBash" in getroottable()))
{
	::AllowBash <- function (basher, bashee)
	{
		local attacker = ::VSLib.Utils.GetEntityOrPlayer(basher);
		local victim = ::VSLib.Utils.GetEntityOrPlayer(bashee);
		
		foreach(func in ::VSLib.EasyLogic.OnBash)
		{
			if (func != null)
			{
				local res = func(attacker, victim);
				
				if (res != null)
				switch ( res )
				{
					case ALLOW_BASH_NONE:
						return ALLOW_BASH_NONE;
					case ALLOW_BASH_PUSHONLY:
						return ALLOW_BASH_PUSHONLY;
				}
			}
		}
		
		if ( "ModeAllowBash" in g_ModeScript )
			return ModeAllowBash(basher, bashee);
		if ( "MapAllowBash" in g_ModeScript )
			return MapAllowBash(basher, bashee);
		
		return ALLOW_BASH_ALL;
	}
}

if ( ("AllowBash" in g_ModeScript) && (g_ModeScript.AllowBash != getroottable().AllowBash) )
{
	g_ModeScript.ModeAllowBash <- g_ModeScript.AllowBash;
	g_ModeScript.AllowBash <- getroottable().AllowBash;
}
else if ( ("AllowBash" in g_MapScript) && (g_MapScript.AllowBash != getroottable().AllowBash) )
{
	g_ModeScript.MapAllowBash <- g_MapScript.AllowBash;
	g_ModeScript.AllowBash <- getroottable().AllowBash;
}
else
{
	g_ModeScript.AllowBash <- getroottable().AllowBash;
}



/**
 * Processes BotQuery() with ::VSLib.
 */
if (!("BotQuery" in getroottable()))
{
	::BotQuery <- function (queryflag, entity, defaultvalue)
	{
		foreach (func in ::VSLib.EasyLogic.OnBotQuery)
			func(queryflag, entity, defaultvalue);
		
		if ( "ModeBotQuery" in g_ModeScript )
			return ModeBotQuery(queryflag, entity, defaultvalue);
		if ( "MapBotQuery" in g_ModeScript )
			return MapBotQuery(queryflag, entity, defaultvalue);
		
		return defaultvalue;
	}
}

if ( ("BotQuery" in g_ModeScript) && (g_ModeScript.BotQuery != getroottable().BotQuery) )
{
	g_ModeScript.ModeBotQuery <- g_ModeScript.BotQuery;
	g_ModeScript.BotQuery <- getroottable().BotQuery;
}
else if ( ("BotQuery" in g_MapScript) && (g_MapScript.BotQuery != getroottable().BotQuery) )
{
	g_ModeScript.MapBotQuery <- g_MapScript.BotQuery;
	g_ModeScript.BotQuery <- getroottable().BotQuery;
}
else
{
	g_ModeScript.BotQuery <- getroottable().BotQuery;
}




// Add a weak reference to the global table.
::Entity <- ::VSLib.Entity.weakref();