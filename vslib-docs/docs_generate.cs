/*! \mainpage VSLib
 *
 * \section intro_sec Introduction
 *
 * VSLib is a powerful yet elegantly simple VScript library. This is the Doxygen documentation of all the
 * various functions with explicit types defined.
 *
 * \section install_sec Installation
 *
 * Go to GitHub for installation procedure: https://github.com/L4D2Scripters/vslib
 *
 */

/**
 * \brief Main table that holds everything VSLib related.
 */
namespace VSLib
{
	/**
	 * \brief Squirrel function tag.
	 * Specifies that the object is a function.
	 */
	private class function { }
	
	/**
	 * \brief Source QAngle.
	 * Holds the XYZ angles.
	 */
	private class QAngle { }
	
	/**
	 * \brief Source Vector.
	 * Holds the XYZ position.
	 */
	private class Vector { }
	
	/**
	 * \brief A timer system to call a function after a certain amount of time.
	 *
	 *  The Timer table allows the developer to easily add synchronized callbacks.
	 *  Read a tutorial on it here: http://zombiescanfly.com/vslib/
	 */
	public class Timers
	{
		/**
		 * Creates a named timer that will be added to the timers list. If a named timer already exists,
		 * it will be replaced.
		 *
		 * @return Name of the created timer
		 */
		string AddTimerByName(string strName, double delay, bool repeat, function func, object[] paramTable = null, int flags = 0);

		/**
		 * Deletes a named timer.
		 */
		void RemoveTimerByName(string strName);

		/**
		 * Calls a function and passes the specified table to the callback after the specified delay.
		 * Returns the current timer index (which you can use to delete the timer later with Timers::RemoveTimer function).
		 */
		int AddTimer(double delay, bool repeat, function func, object[] paramTable = null, int flags = 0, object[] value = {});

		/**
		 * Removes the specified timer.
		 */
		void RemoveTimer(int idx);
	}
	
	/**
	 * \brief Spawns random items on predefined spawnpoints.
	 *
	 * See the file VSLib/RandomItemSpawner.nut to set which random items are spawned.
	 * 
	 */
	public class RandomItemSpawner
	{
		/**
		 * Spawns specified number of random items. 
		 *
		 * @return Items spawned as an array of VSLib entities.
		 */
		Entity[] SpawnRandomItems(int amount);
	}
	
	/**
	 * \brief Provides many helpful player functions.
	 *
	 * The Player class works with ::VSLib.EasyLogic.Notifications and builds on the Entity class.
	 */
	public class Player : Entity
	{
		/**
		 * Returns true if the player entity is valid or false otherwise.
		 */
		bool IsPlayerEntityValid();

		/**
		 * Gets the character name (not steam name). E.g. "Nick" or "Rochelle"
		 */
		string GetCharacterName();

		/**
		 * Gets the player's Steam ID. If you are planning on getting the SteamID to store it with FileIO.SaveTable, use GetUniqueID() instead,
		 */
		string GetSteamID();

		/**
		 * Gets the player's Unqiue ID (clean, formatted Steam ID).
		 */
		string GetUniqueID();

		/**
		 * Gets the player's name.
		 */
		string GetName();

		/**
		 * Gets the player's IP address.
		 */
		string GetIPAddress();

		/**
		 * Returns true if the player is alive.
		 */
		bool IsAlive();

		/**
		 * Returns true if the player is dead.
		 */
		bool IsDead();

		/**
		 * Returns true if the player is dying.
		 */
		bool IsDying();

		/**
		 * Returns true if the entity is incapped.
		 */
		bool IsIncapacitated();

		/**
		 * Returns true if the entity is hanging off a ledge.
		 */
		bool IsHangingFromLedge();

		/**
		 * Returns true if the entity is in ghost mode (i.e. infected ghost).
		 */
		bool IsGhost();

		/**
		 * Returns true if the entity is on fire.
		 */
		bool IsOnFire();

		/**
		 * Returns the VSLib::Entity of the player's active weapon
		 */
		Entity GetActiveWeapon();

		/**
		 * Returns true if the player is currently in the ending saferoom.
		 */
		bool IsInEndingSafeRoom();

		/**
		 * Gets the player's spawn location.
		 */
		Vector GetSpawnLocation();

		/**
		 * Returns true if the player is still around the starting area.
		 * Note that they can be outside the saferoom and still AROUND the
		 * starting area. This function will return true if they are near
		 * where they first spawned.
		 */
		bool IsNearStartingArea();

		/**
		 * Returns the player's last attacker (the last person who hurt this player).
		 * Null is returned if the "attacker" is the world or some other invalid object.
		 */
		Player GetLastAttacker();

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
		bool HasAward(int award);

		/**
		 * Returns the entity or player that last killed this player. If this player
		 * has not been killed yet or the killer is an invalid object, returns null.
		 */
		Player GetLastKilledBy();

		/**
		 * Returns the entity or player that last defibbed this player. If this player
		 * has not been defibbed or hasn't been defibbed by a valid player entity, returns null.
		 */
		Player GetLastDefibbedBy();

		/**
		 * Returns the entity or player that last shoved this player. If this player
		 * has not been shoved yet, returns null.
		 */
		Entity GetLastShovedBy();

		/**
		 * Returns the entity that this player last tried to "Use".
		 * If the player has not tried to use anything yet, returns null.
		 */
		Entity GetLastUsed();

		/**
		 * Returns the team that this player is currently on, e.g. SURVIVORS or INFECTED.
		 */
		int GetTeam();

		/**
		 * Returns the last ability that this player used.
		 * E.g. "ability_lunge" or "ability_tongue" or "ability_vomit" or "ability_charge" or "ability_spit" or "ability_ride"
		 * This function is applicable for SI only.
		 */
		string GetLastAbilityUsed();

		/**
		 * Returns the Player entity of the current attacker, or null if there is no entity
		 * attacking this player. Note that this function will only return the current hunter,
		 * smoker, charger, or jockey attacker. Boomer, tank, and spitter cannot "continuously"
		 * trap the survivor and attack, so they will not be returned. If there is no SI attacking
		 * this player, then null is returned. This function is applicable for Survivors only.
		 */
		Player GetCurrentAttacker();
			
		/**
		 * Returns true if the Survivor player is trapped by an SI attacker like smoker,
		 * hunter, charger, or jockey.
		 */
		bool IsSurvivorTrapped();


		/**
		 * Returns the type of player. E.g. Z_SPITTER, Z_TANK, Z_SURVIVOR, Z_HUNTER, Z_JOCKEY, Z_SMOKER, Z_BOOMER, Z_CHARGER, Z_COMMON, or UNKNOWN.
		 */
		int GetPlayerType();

		/**
		 * Incaps the player
		 */
		void Incapacitate();

		/**
		 * Kills the player.
		 */
		void Kill();

		/**
		 * Returns true if this player can see the inputted location in their vision.
		 * 
		 * @param targetPos   The vector location that you want to check if the player can see.
		 * @param tolerance   The tolerence of the result. 75 is the default Source field of view.
		 */
		bool CanSeeLocation(Vector targetPos, int tolerance = 50);

		/**
		 * Returns true if this player can see the inputted entity.
		 */
		bool CanSeeOtherEntity(Entity otherEntity, int tolerance = 50);

		/**
		 * Returns true if this player can trace a line from the eyes to the specified location.
		 * See this page https://developer.valvesoftware.com/wiki/MASK_Types for trace mask types.
		 * Other functions in VSLib like Utils::SpawnZombieNearPlayer also use this function, so see
		 * those for examples.
		 */
		bool CanTraceToLocation(Vector finishPos, int traceMask);

		/**
		 * Sends a client command to the player entity.
		 * \todo Doesn't work, need to fix.
		 */
		void ClientCommand(string str);

		/**
		 * Changes the flashlight state.
		 */
		void SetFlashlight(bool turnFlashOn);

		/**
		 * Sets the player's health buffer.
		 */
		void SetHealthBuffer(int value);

		/**
		 * Drops a weapon from a slot.
		 *
		 * You can use global constants SLOT_PRIMARY, SLOT_SECONDARY, SLOT_THROW,
		 * SLOT_MEDKIT (also works for defibs), SLOT_PILLS (also works for adrenaline etc)
		 */
		void DropWeaponSlot(slot);

		/**
		 * Drops all held weapons
		 */
		void DropAllWeapons();

		/**
		 * Gets the player's health buffer.
		 */
		int GetHealthBuffer();

		/**
		 * Gets the player's valve inventory (molotov, weapons, pills, etc).
		 */
		object[] GetHeldItems();

		/**
		 * Gets the position where the player last died, or null if the player has not died yet
		 */
		Vector GetLastDeathLocation();

		/**
		 * Sets the player's revive count. Setting the value high enough could also make them go black and white.
		 */
		void SetReviveCount(int count);

		/**
		 * Gets the player's revive count, or null if the player does not have revive information yet
		 */
		int GetReviveCount();

		/**
		 * Revives a player (also checks if player is incapped first).
		 * Returns true if the player was revived.
		 */
		bool Revive();

		/**
		 * Defibs a dead player (also checks if player is dead first).
		 * Returns true if the player was defibbed.
		 */
		bool Defib();

		/**
		 * Gets the last player who vomited this player, or returns null if the player
		 * has not been vomited on yet OR has not been vomited on by a valid player
		 */
		Player GetLastVomitedBy();

		/**
		 * Returns true if this player was ever vomited this round
		 */
		bool WasEverVomited();

		/**
		 * Staggers this entity
		 */
		void Stagger();

		/**
		 * Staggers this entity away from another entity
		 */
		void StaggerAwayFromEntity(Entity otherEnt);

		/**
		 * Staggers this entity away from another location
		 */
		void StaggerAwayFromLocation(Vector loc);

		/**
		 * Gives the player an upgrade
		 */
		void GiveUpgrade(string upgrade);

		/**
		 * Removes the player's upgrade
		 */
		void RemoveUpgrade(string upgrade);

		/**
		 * Returns true if the player is a tank and is frustrated
		 */
		bool IsFrustrated();

		/**
		 * Gives the entity an adrenaline effect
		 */
		void GiveAdrenaline( double time );

		/**
		 * Gets the userid of the player.
		 */
		int GetUserId();

		/**
		 * Gets the survivor slot
		 */
		int GetSurvivorSlot();

		/**
		 * Extinguish a burning player (also checks if player is on fire first).
		 * Returns true if the player was extinguished.
		 */
		bool Extinguish();

		/**
		 * Gives ammo to the player.
		 */
		void GiveAmmo( int amount );

		/**
		 * Gets a valid path point within a radius.
		 */
		Vector GetNearbyLocation( double radius );

		/**
		 * Gets flow distance.
		 */
		double GetFlowDistance();

		/**
		 * Gets flow percent.
		 */
		double GetFlowPercent();

		/**
		 * Plays a sound file to the player.
		 */
		void PlaySound( string file );

		/**
		 * Stops a sound on the player.
		 */
		string StopSound( string file );


		/**
		 * Stops Amnesia/HL2 style object pickups. Currently does not work.
		 */
		void DisablePickups( );

		/**
		 * Enables Amnesia/HL2 style object pickups. Currently does not work.
		 */
		void AllowPickups( long int BTN_PICKUP, long int BTN_THROW );

		/**
		 * Drops the held HL2/Amnesia physics-based object or the valve-style object
		 */
		void DropPickup( );


		/**
		 * Picks up the given VSLib Entity object using native L4D2 function.
		 */
		void NativePickupObject( Entity otherEnt );

		/**
		 * The "give" concommand.
		 *
		 * @param str What to give the entity (for example, "health")
		 */
		void Give(string str);

		/**
		 * Removes a player's weapon.
		 */
		void Remove(string weaponName);

		/**
		 * Enables Valve-style object pickups with the USE key (E key). Similar to the Gravity Gun effect.
		 */
		void BeginValvePickupObjects( string pickupSound = "Defibrillator.Use", string throwSound = "Adrenaline.NeedleOpen" );

		/**
		 * Disables Valve-style object pickups.
		 *
		 * @see BeginValvePickupObjects
		 */
		void EndValvePickupObjects( );

		/**
		 * Sets the throwing force for Valve-style object pickups (default 100).
		 *
		 * @see BeginValvePickupObjects
		 */
		bool ValvePickupThrowPower( double power );

		/**
		 * Sets the pickup range for Valve-style object pickups (default 64).
		 *
		 * @see BeginValvePickupObjects
		 */
		bool ValvePickupPickupRange( double range );

		/**
		 * Sets the throw damage for Valve-style object pickups (default 30).
		 *
		 * @see BeginValvePickupObjects
		 */
		void SetThrowDamage( double dmg );

		/**
		 * Sets the hold damage for Valve-style object pickups (default 5).
		 *
		 * @see BeginValvePickupObjects
		 */
		void SetHoldDamage( double dmg );

		/**
		 * Enables or disables hold/throw damage calculation.
		 *
		 * @see BeginValvePickupObjects
		 */
		void SetDamageEnabled( bool isEnabled );


		/**
		 * Returns the quantity of the requested inventory item.
		 * Inventory items can be spawned with Utils::SpawnInventoryItem().
		 *
		 * @see GetInventoryTable()
		 */
		int GetInventory( string itemName );

		/**
		 * Sets the quantity of the specified inventory item.
		 *
		 * @see GetInventoryTable()
		 */
		void SetInventory( string itemName, int quantity );

		/**
		 * Returns the player's inventory table. You can use it like this:
		 * 
		 * 		local inv = player.GetInventoryTable();
		 * 		inv["itemName"] <- 25; // change quantity to 25
		 */
		object[] GetInventoryTable();
	}
	
	/**
	 * \brief Provides many helpful entity functions.
	 *
	 *  The Entity class wraps many Valve functions as well as provide numerous
	 *  helper functions that aid in the development of maps, mods, and mutations.
	 */
	public class Entity
	{
		/**
		 * Returns true if the entity is valid or false otherwise.
		 * Sometimes, just because an entity or edict exists doesn't mean that
		 * it hasn't freed up or become invalidated. Luckily, you will rarely use
		 * this function since VSLib uses it automatically.
		 */
		bool IsEntityValid();

		/**
		 * Gets the entity's real health.
		 * If the entity is valid, the entity's health is returned; otherwise, null is returned.
		 * The health includes any adrenaline or pill health.
		 */
		int GetHealth();

		/**
		 * Gets the entity's raw health.
		 * If the entity is valid, the entity's health is returned; otherwise, null is returned.
		 * Raw health does not include temporary health.
		 */
		int GetRawHealth();

		/**
		 * Hurts the entity.
		 *
		 * @param value Amount of damage to inflict.
		 * @param dmgtype The type of damage to inflict (e.g. DMG_GENERIC)
		 * @param weapon The classname of the weapon (if set, the point hurt will "pretend" to be the weapon)
		 * @param attacker If set, the damage will be done by the specified VSLib::Entity or VSLib::Player
		 * @param radius The radius of damage
		 */
		void Hurt(int value, int dmgtype = 0, string weapon = "", Entity attacker = null, double radius = 64.0);

		/**
		 * Hurts AROUND the entity without hurting the entity itself.
		 *
		 * @param value Amount of damage to inflict.
		 * @param dmgtype The type of damage to inflict (e.g. DMG_GENERIC)
		 * @param weapon The classname of the weapon (if set, the point hurt will "pretend" to be the weapon)
		 * @param attacker If set, the damage will be done by the specified VSLib::Entity or VSLib::Player
		 * @param radius The radius of damage
		 * @param ignoreEntities An array of Entities to not damage
		 */
		void HurtAround(int value, int dmgtype = 0, string weapon = "", Entity attacker = null, double radius = 64.0, object[] ignoreEntities = null);
		/**
		 * Fires a specific input
		 */
		void Input(string input, string value = "", double delay = 0, Entity activator = null);

		/**
		 * Breaks the entity (if it is breakable)
		 */
		void Break();

		/**
		 * Dispatches a keyvalue to the entity
		 */
		void SetKeyValue(string key, object value);

		/**
		 * Same as Hurt(), except it keeps hurting for the specified time.
		 * It hurts at the specified interval for the specified time.
		 */
		void HurtTime(int value, int dmgtype, double interval, double time, string weapon = "", Entity attacker = null, double radius = 64.0);

		/**
		 * Sets the entity's raw health.
		 * If the entity is valid, the entity's health is set.
		 * Setting raw health removes any existing temp health.
		 */
		void SetRawHealth(int value);

		/**
		 * Sets the entity's health.
		 * If the entity is valid, the entity's health is set.
		 * This will also incapacitate the player if the input value is
		 * less than or equal to 0.
		 */
		void SetHealth(int value);

		/**
		 * Sets the entity's maximum possible health without modifying the entity's current health.
		 * If the entity is valid, the entity's max health is set.
		 */
		void SetMaxHealth(int value);

		/**
		 * Vomits on the Entity
		 */
		void Vomit();

		/**
		 * Gets the entity's classname.
		 * If the entity is valid, the entity's class is returned; otherwise, null is returned.
		 * For example, "prop_dynamic" or "weapon_rifle_ak47"
		 */
		string GetClassname();

		/**
		 * Sets the entity's global name.
		 * If the entity is valid, the global name of the entity is set. The global name
		 * of the entity corresponds to the "Global Name" field of the entity in the Property
		 * Window in Hammer. Global entities may carry over onto future maps in a campaign,
		 * so setting an entity's global name may be helpful in certain situations.
		 */
		void SetGlobalName(string name);

		/**
		 * Sets the entity's parent name.
		 * If the entity is valid, the name of the entity is set. Note that this function does
		 * NOT parent an entity; only the parent's targetname is set. This is equivalent to setting
		 * the "Parent" field in Hammer.
		 */
		void SetParentName(string name);

		/**
		 * Sets the entity's speed.
		 * If the entity is valid, the speed of the entity is set.
		 * The speed cannot be set for player entities.
		 */
		void SetSpeed(double value);

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
		void SetRenderEffects(int value);

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
		void SetRenderMode(int value);

		/**
		 * Sets the entity's next Think time.
		 * To be totally honest, I can't think of a reason for this function.
		 * Provided just for those who may need it.
		 *
		 *\todo This may or may not work, provided that the KV field is FIELD_TICK.
		 */
		void SetNextThinkTime(double value);

		/**
		 * Sets the entity's secondary effects.
		 * Depending on the value, effects like light projection (i.e. flashlight)
		 * can be enabled and disabled (for player entities). See Player class
		 * for a function already made for that purpose.
		 */
		void SetEffects(int value);

		/**
		 * Sets the entity's render color.
		 * Changes the overall color of the entity. For example, a value of (255, 0, 0, 255)
		 * will give the entity a red hue. The alpha property really doesn't affect much unless
		 * the render mode also changes. If you are looking to change the visibility, use
		 * Entity.SetVisible() instead.
		 */
		void SetColor(int red, int green, int blue, int alpha);

		/**
		 * Changes the entity's visibility.
		 * If the visible parameter is true, the entity will become visible to all players.
		 * If the visible paramater is false, the entity will become invisible to all players.
		 */
		void SetVisible(bool canSee);

		/**
		 * Sets the entity's model index.
		 * If the entity has more than one model associated with it (i.e. it has more than one
		 * model index), then you can instantly change the model index with this function. This
		 * function is useful for those who would like to have an entity have more than one model.
		 * \todo Verify that global keyfields can be modified with Valve's __KeyValueFromInt()
		 */
		void SetModelIndex(int value);

		/**
		 * Sets the entity's response context.
		 * This function deals more with AI criteria sets and dispatching responses.
		 * Practically useless for what we do, since the entity would need to be
		 * re-activated and there's no plausible way to do that via VScripts.
		 * If your mod needs to deal with m_iszResponseContext, use another scripting
		 * engine like SourceMod.
		 */
		void SetResponseContext(object value);

		/**
		 * Sets the m_target netprop of the entity.
		 * Provided for completeness, but the function doesn't seem to do much on L4D2.
		 * The prop has taken a back seat to m_iName from the looks of it.
		 */
		void SetTarget(string value);

		/**
		 * Sets the damage filter name of the entity.
		 * Provided for completeness. This function sets the m_iszDamageFilterName KV,
		 * which is later used in InputSetDamageFilter() in the c++ backend to
		 * find the name stored in m_iszDamageFilterName to set m_hDamageFilter, which is
		 * later used in PassesDamageFilter() to see if the CTakeDamageInfo object passes
		 * the damage filter. In simple terms, this function is as good as useless for us.
		 */
		void SetDamageFilter(object value);

		/**
		 * Sets the shadow cast distance.
		 * I honestly cannot think of any good use for this, unless you want to change the
		 * shadow distance over time or something. Granted, it may not even work. Provided
		 * for completeness.
		 */
		void SetShadowCastDistance(double value);

		/**
		 * Applies an absolute velocity impulse to an entity.
		 * An impulse is given to the entity. In this function, by setting a value negative
		 * to an entity's trajectory, the entity may or may not change paths depending on the
		 * scalar value of the vector. All we are doing is "pushing" an entity in the given
		 * direction. The higher the dimensional value, the stronger the "push" (to put it
		 * very simply). There are a lot of uses for this function.
		 */
		void Push(Vector vec);

		/**
		 * Applies an angular velocity impulse to an entity.
		 * Using this function, we can make physics props spin around or rotate.
		 */
		void Spin(Vector vec);

		/**
		 * Sets the entity's gravity.
		 */
		void SetGravity(double value);

		/**
		 * Sets the entity's friction.
		 */
		void SetFriction(double value);

		/**
		 * Returns the entity's current velocity vector.
		 */
		Vector GetVelocity();

		/**
		 * Sets the entity's current velocity vector.
		 * This can be used to force an entity to move in a particular direction.
		 */
		void SetVelocity(Vector vec);

		/**
		 * Sets the entity's current velocity vector KV.
		 */
		void SetVelocityKV(object vec);

		/**
		 * Sets the entity's current base velocity vector KV.
		 */
		void SetBaseVelocity(object vec);

		/**
		 * Sets the entity's current angular velocity vector KV.
		 */
		void SetAngularVelocity(object vec);

		/**
		 * Sets the entity's current water level.
		 */
		void SetWaterLevel(int lvl);

		/**
		 * Sets the entity's spawn flags.
		 */
		void SetSpawnFlags(int flags);

		/**
		 * Gets the direction that the entity's eyes are facing.
		 */
		QAngle GetEyeAngles();

		/**
		 * Returns the base entity (in case you need to access Valve's CBaseEntity/CBaseAnimating functions manually)
		 */
		object GetBaseEntity();

		/**
		 * Returns the initial index or name passed to the entity.
		 */
		int GetIndex();

		/**
		 * Gets the entity's current location.
		 */
		Vector GetLocation();

		/**
		 * Sets the entity's current location vector (i.e. teleports the entity).
		 */
		void SetLocation(vec);

		/**
		 * Sets the entity's current position (basically calls SetLocation() internally).
		 */
		void SetPosition(double x, double y, double z);

		/**
		 * Gets the entity's current position (basically calls GetLocation() internally).
		 */
		Vector GetPosition();

		/**
		 * Does the same thing as SetLocation() in that it teleports the entity.
		 * Internally the function just calls SetLocation(). Provided for simplicity,
		 * as a lot of mappers seem to have difficulty understanding various terms.
		 */
		void Teleport(Vector vec);

		/**
		 * Teleports the entity to another ::VSLib.Entity.
		 */
		void TeleportTo(Entity otherEntity);

		/**
		 * Tries to guess what team the player might be on.
		 * Returns either INFECTED or SURVIVORS.
		 */
		int GetTeam();

		/**
		 * Kills/removes the entity from the map.
		 */
		void Kill();

		/**
		 * Returns the base angles.
		 */
		QAngle GetAngles();

		/**
		 * Sets the base angles.
		 */
		void SetAngles(double x, double y, double z);

		/**
		 * Kills/removes the entity and associated/attached entities from the map.
		 */
		void KillHierarchy();

		/**
		 * Attempts to "Use" or pick up another entity.
		 */
		void Use(Entity otherEntity);

		/**
		 * Attempts to "Use" or pick up another entity.
		 */
		void UseOther(Entity otherEntity);

		/**
		 * Attempts to be "used" or picked up BY another entity.
		 */
		void UsedByOther(Entity otherEntity);

		/**
		 * Set the alpha value of the entity.
		 * Only seems to work for players.
		 */
		void SetAlpha(int value);

		/**
		 * Inputs a color to an entity. This is an alternative to SetColor().
		 */
		void InputColor(int red, int green, int blue);

		/**
		 * Parents an entity to this entity.
		 * In other words, attaches an entity to this entity. Cool for attaching bumper cars
		 * or other objects to players. If teleportOther is TRUE, the other entity is teleported
		 * to this entity. If it is FALSE, the entity is parented without teleporting.
		 */
		void AttachOther(Entity otherEntity, bool teleportOther);

		/**
		 * Attaches another entity to a specific point.
		 * Call this function after AttachOther() to parent at a specific attachment point. For example,
		 * if attachment equals "rhand", the object will be attached to the player's or entity's
		 * right hand. "forward" to attach to head etc. Search for player or entity attachment points
		 * on Google (i.e. "L4D2 survivor attachment points" or something along those lines).
		 * If ShouldMaintainOffset is true, then the initial distance between the object is maintained,
		 * and the angles usually point in the direction of the parent.
		 */
		void SetAttachmentPoint(Entity otherEntity, string attachment, bool bShouldMaintainOffset);

		/**
		 * Remove the parenting.
		 */
		void RemoveAttached(Entity otherEntity);

		/**
		 * Estimates the eye position.
		 */
		Vector GetEyePosition();

		/**
		 * Gets the entity that this entity is pointing at, or null if this entity is not pointing at a valid entity.
		 * This is useful for things like detecting what entity a player may be looking at.
		 */
		Entity GetLookingEntity();

		/**
		 * Returns the numerical index of the entity.
		 * Because Valve didn't provide a function to convert a base entity back to an index,
		 * we go the long way around by using an entity loop.
		 */
		int GetBaseIndex();

		/**
		 * Kills the entity after the specified delay in seconds; fractions may be used if needed (e.g. 1.5 seconds).
		 */
		void KillDelayed(double seconds);

		/**
		 * Returns a vector position of where the entity is looking.
		 */
		Vector GetLookingLocation();

		/**
		 * Ingites the entity for the specified time. Fractions can be used (e.g. 1.5 seconds).
		 */
		void Ignite(double time);

		/**
		 * Attaches a particle to this entity.
		 * E.g. "gas_fireball" or "elevatorsparks". Internally spawns an
		 * info_particle_system, so all effects that can be shown with that
		 * entity can be shown with this function. This function will return the
		 * particle system that was created, so if you need to attach it to a
		 * specific attachment point or whatever, you can.
		 */
		Entity AttachParticle(string particleName, double duration);

		/**
		 * Returns true if the entity is a player.
		 */
		bool IsPlayer();

		/**
		 * Returns true if the entity is alive.
		 * For players, once a player dies, it still reports alive. Use Player class for IsAlive().
		 *
		 * To convert an Entity into a player, for example:
		 *     local ent = Entity(...stuff here...);
		 *     if (ent.IsPlayer())
		 *         local player = Player(ent); // do stuff with it
		 */
		bool IsAlive();

		/**
		 * Returns the name of the entity.
		 */
		string GetName();

		/**
		 * Returns the distance (in units) to the ground from the entity's origin.
		 */
		double GetDistanceToGround();

		/**
		 * Returns true if the entity is in the air.
		 */
		bool IsEntityInAir();

		/**
		 * Returns the entity's button mask
		 */
		int GetPressedButtons();

		/**
		 * Returns if the client is pressing the specified button. For a list of buttons, see the VSLib/Entity.nut file.
		 */
		bool IsPressingButton(int btn);

		/**
		 * Returns true if this player is currently firing a weapon (either a gun, bat, etc).
		 * Note that it doesn't check if the gun has any ammo (just checks for key press).
		 */
		bool IsPressingAttack();

		/**
		 * Returns true if this player is jumping (or pressing the space bar button for example).
		 */
		bool IsPressingJump();

		/**
		 * Returns true if this player is ducking (or pressing the CTRL key for example).
		 */
		bool IsPressingDuck();

		/**
		 * Returns true if this player is pressing forward (or pressing the W key for example).
		 */
		bool IsPressingForward();

		/**
		 * Returns true if this player is pressing backward (or pressing the S key for example).
		 */
		bool IsPressingBackward();

		/**
		 * Returns true if this player is pressing the USE key (or pressing the E key for example).
		 */
		bool IsPressingUse();

		/**
		 * Returns true if this player is pressing the Left key (or pressing the A key for example).
		 */
		bool IsPressingLeft();

		/**
		 * Returns true if this player is pressing the Right key (or pressing the D key for example).
		 */
		bool IsPressingRight();

		/**
		 * Returns true if this player is pressing the shove key (or pressing right-click for example).
		 */
		bool IsPressingShove();

		/**
		 * Returns true if this player is pressing the reload key (or pressing the R key for example).
		 */
		bool IsPressingReload();

		/**
		 * Returns true if this player is pressing the walk key (or pressing the shift key for example).
		 */
		bool IsPressingWalk();

		/**
		 * Returns true if this player is pressing the zoom key.
		 */
		bool IsPressingZoom();

		/**
		 * Returns the entity's owner, or null if the owner does not exist
		 */
		Entity GetOwnerEntity();

		/**
		 * Commands this Entity to move to a particular location (only applies to bots).
		 */
		void BotMoveToLocation(Vector newpos);

		/**
		 * Commands this Entity to move to another entity's location (only applies to bots).
		 */
		void BotMoveToOther(Entity otherEntity);

		/**
		 * Commands the other bot entity to move to this entity's location (only applies to bots).
		 */
		void BotMoveOtherToThis(Entity otherEntity);

		/**
		 * Commands this Entity to attack a particular entity (only applies to bots).
		 */
		void BotAttack(Entity otherEntity);

		/**
		 * Commands this Entity to retreat from a particular entity (only applies to bots).
		 */
		void BotRetreatFrom(Entity otherEntity);

		/**
		 * Returns the bot to normal after it is commanded.
		 */
		void BotReset();

		/**
		 * Returns true if the entity is a bot.
		 */
		bool IsBot();

		/**
		 * Sets the sense flags for this player.
		 */
		void SetSenseFlags(int flags);

		/**
		 * Sets if the target can see.
		 */
		void ChangeBotEyes(bool hasEyes);

		/**
		 * Gets the sense flags for this player.
		 */
		int GetSenseFlags();

		/**
		 * Returns true if the entity is a real human (non-bot).
		 */
		bool IsHuman();

		/**
		 * Adds to the entity's THINK function. You can use "this.ent" when you need to use the VSLib::Entity.
		 * 
		 * @param func A function to add to the think timer.
		 */
		void AddThinkFunction( function func );

		/**
		 * Returns the entity's script scope.
		 */
		object GetScriptScope( );

		/**
		 * Connects an output to a function
		 *
		 * @param output The output name (string)
		 * @param func Function to fire (pass in a function, not a string name)
		 */
		void ConnectOutput( string output, function func );

		/**
		 * Sets the entity's alpha
		 *
		 * @param value An integer value between 0 and 255
		 */
		void SetEntityRenderAmt( int value );

		/**
		 * Returns true if this entity can trace to another entity without hitting anything.
		 * I.e. if a line can be drawn from this entity to the other entity without any collision.
		 */
		bool CanTraceToOtherEntity(Entity otherEntity, double height = 5.0);
	}
	
	/**
	 * \brief A bunch of classes that will make designing a HUD via code so much easier.
	 */
	namespace HUD
	{
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
		public class Item
		{
			/**
			 * Sets a new format string
			 */
			void SetFormatString(string formatStr);
			
			/**
			 * Sets a token's value.
			 */
			void SetValue(string key, object value);
			
			/**
			 * Get a token's value.
			 */
			string GetValue(string key);
			
			/**
			 * Gets the modified token string
			 */
			string GetString();
			
			/**
			 * Sets the HUD slot for this object. A value between 0 through 14 (inclusive) or Valve's enums.
			 */
			void AttachTo(int hudtype);
			
			/**
			 * Removes the HUD panel for this object
			 */
			void Detach();
			
			/**
			 * Returns true if this item is currently bound to a slot.
			 */
			bool IsBound();
			
			/**
			 * Gets the object's flags
			 */
			int GetFlags();
			
			/**
			 * Sets the object's flags
			 */
			void SetFlags(int newFlags);
			
			/**
			 * Changes the alignment of the text, e.g. TextAlign.Left or TextAlign.Center or TextAlign.Right
			 */
			void SetTextPosition(int alignFlag);
			
			/**
			 * Stops blinking this object.
			 */
			void StopBlinking();
			
			/**
			 * Starts blinking this object.
			 */
			void StartBlinking();
			
			/**
			 * Returns true if blinking.
			 */
			bool IsBlinking();
			
			/**
			 * Hides this object.
			 */
			void Hide();
			
			/**
			 * Shows this object.
			 */
			void Show();
			
			/**
			 * Returns true if this object is hidden.
			 */
			bool IsHidden();
			
			/**
			 * Adds a flag.
			 */
			void AddFlag(int flag);
			
			/**
			 * Removes a flag.
			 */
			void RemoveFlag(int flag);
			
			/**
			 * Returns true if a flag is set.
			 */
			void IsFlagSet(int flag);
			
			/**
			 * Returns the slot of this object
			 */
			int GetSlot();
			
			/**
			 * Resizes the HUD object
			 */
			void Resize(float width, float height);
			
			/**
			 * Resizes the HUD object's width
			 */
			void SetWidth(float width);
			
			/**
			 * Resizes the HUD object's height
			 */
			void SetHeight(float height);
			
			/**
			 * Repositions the HUD object
			 */
			void SetPosition(float x, float y);
			
			/**
			 * Repositions the HUD object's X position
			 */
			void SetPositionX(float x);
			
			/**
			 * Repositions the HUD object's Y position
			 */
			void SetPositionY(float y);
			
			/**
			 * Repositions and resizes the HUD object natively.
			 */
			void ChangeHUD(float x, float y, float width, float height);
			
			/**
			 * Centers the HUD object in the middle of the screen without changing its Y coordinate
			 */
			void CenterHorizontal();
			
			/**
			 * Centers the HUD object in the middle of the screen without changing its X coordinate
			 */
			void CenterVertical();
			
			/**
			 * Centers the HUD object in the middle of the screen.
			 */
			void CenterScreen();
			
			/**
			 * Blinks the text for the specified time in seconds
			 */
			void BlinkTime(double seconds);
			
			/**
			 * Shows the GUI panel for the specified time before hiding it again
			 */
			void ShowTime(double seconds, bool detachAfter = false);
			
			/**
			 * Returns the current position of the object
			 *
			 * @return A table with keys: x and y
			 */
			object[] GetPosition();
			
			/**
			 * Returns the current dimensions of the object
			 *
			 * @return A table with keys: width and height
			 */
			object[] GetSize();
			
			/**
			 * Returns the center point of the HUD object. The returned
			 * table consists of an x value and a y value. For example:
			 *
			 * local test = item.GetCenterPoint();
			 * if (test.x == 0.5 && test.y == 0.2)
			 *     ... // etc
			 */
			object[] GetCenterPoint();
			
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
			void SetPositionNative(int x, int y, int resx, int resy);
			
			/**
			 * @see SetPositionNative
			 *
			 * Does practically the same thing, but this time scales for width and height
			 * proportional to a screen resolution.
			 *
			 * @param width The new width
			 * @param height The new height
			 * @param resx Your horizontal screen resolution (for example, 1024)
			 * @param resy Your vertical screen resolution (for example, 768)
			 */
			void ResizeNative(int width, int height, int resx, int resy);
			
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
			void ChangeHUDNative(int x, int y, int width, int height, int resx, int resy);
			
			/**
			 * Parses the input string.
			 */
			 string ParseString(string str);
		}
		
		
		/**
		 * \brief Countdown HUD item.
		 * This is a HUD item that acts as a countdown. When the countdown is
		 * over, it fires a function of your choice.
		 */
		public class Countdown : Item
		{
			/**
			 * Creates the HUD item with a format string.
			 *
			 * @param formatStr The format string; default will display as "00:14:23" for example
			 * @param minutesOnly If true, hours will add to the minutes; e.g. 01:05:10 will display as 00:65:10
			 */
			Countdown(string formatStr = "{hrs}:{min}:{sec}", bool minutesOnly = false);
			
			/**
			 * Starts the countdown from the specified time
			 */
			void Start(function func, int hours = 0, int minutes = 0, int seconds = 0);
			
			/**
			 * Stops and detaches the HUD object.
			 */
			void Detach();
			
			/**
			 * Stops the countdown
			 */
			void Stop();
			
			/**
			 * Sets a time to begin blinking
			 */
			void(int hours = 0, int minutes = 0, int seconds = 0);
			
			/**
			 * Calculates time-based mechanisms such as blinking and function calling
			 */
			void Tick();
			
			/**
			 * Returns the full formatted string
			 */
			string GetString();
			
			/**
			 * Returns the current formatted time as a string
			 */
			string GetTickString(string strFormated);
		}
		
		/**
		 * \brief Progress bar HUD item.
		 * This is a HUD item that acts as a configurable progress bar.
		 * One can easily use this HUD item to display numerical values
		 * and percentages. Example uses would be stamina/magic bars,
		 * health bars, fuel bars, and whatever else you can think of.
		 */
		class Bar : Item
		{
			/**
			 * Creates the HUD item with a format string.
			 *
			 * @param formatStr The format string; default will display as "21% [|||||||.....]" for example
			 * @param initialValue The starting value of this progress bar
			 * @param maxValue The maximum possible value of this progress bar
			 * @param fill The solid block character
			 * @param empty The open block character
			 */
			Bar(string formatStr = "{value}% [{bar}]", int initialValue = 0, int maxValue = 100, int width = 50, string fill = "|", string empty = ".");
			
			/**
			 * Sets the progress bar's value
			 */
			void SetBarValue(int value);
			
			/**
			 * Gets the progress bar's value
			 */
			int GetBarValue();
			
			/**
			 * Gets the progress bar's max value
			 */
			int GetBarMaxValue();
			
			/**
			 * Returns the full formatted progress bar with text
			 */
			string GetString();
			
			/**
			 * Changes the width (number of characters) of the progress bar
			 */
			int SetBarWidth(int width);
			
			/**
			 * Returns the bar's width
			 */
			int GetBarWidth();
			
			/**
			 * Changes the character blocks of the progress bar
			 */
			void SetBarCharacters(string fill = "|", string empty = ".");
			
			/**
			 * Changes the max value of the progress bar
			 */
			void SetBarMaxValue(int value);
		}
		
		/**
		 * \brief Navigatable menu HUD item.
		 * A very limited menu system. Panel displays for all users (due to HUD limitations) but
		 * is navigated by a single person. Right-click to fly through menu options, and left
		 * click to select a menu item. Options are key-function pairs. When the user selects
		 * an option, the menu is closed and the function associated with the option is called.
		 * See the API for example usage.
		 *
		 * \todo @TODO finish this.
		 */
		class Menu : Item
		{
			Menu(string formatStr = "[ {name} ]\n\n{title}\n\n{options}", string title = "Menu", string optionFormatStr = "{num}. {option}", string highlightStrPre = "[ ", string highlightStrPost = "  ]");
			
			/**
			 * Sets a new title
			 */
			void SetTitle(string title);
			
			/**
			 * Sets a new option format
			 */
			void SetOptionFormat(string optionFormatStr);
			
			/**
			 * Sets new highlight strings
			 */
			void SetHighlightStrings(string highlightStrPre, string highlightStrPost);
			
			/**
			 * Associates a menu item with a function
			 */
			void AddOption(string option, function func);
			
			/**
			 * Returns the full formatted menu text
			 */
			string GetString();
			
			/**
			 * Closes the menu
			 */
			void CloseMenu();
			
			/**
			 * Stops and detaches the HUD object.
			 */
			void Detach();
			
			/**
			 * Displays the menu and hands over control to a particular player entity.
			 */
			void DisplayMenu(Player player, int attachTo, bool autoDetach = false);
			
			/**
			 * Resizes this HUD item's height depending on the line height.
			 */
			void ResizeHeightByLines();
			
			/**
			 * Overrides the buttons used to detect HUD changes.
			 * You can pass in BUTTON_ATTACK and BUTTON_SHOVE for example.
			 */
			void OverrideButtons(int selectBtn, int switchBtn);
			
			/**
			 * Gathers input data and acts on it.
			 */
			void Tick();
		}
	}
	
	/**
	 * \brief File processing and serialization functions.
	 * File I/O functions simplify the saving and loading of data.
	 */
	public class FileIO
	{
		/**
		 * Recursively serializes a table and returns the string. This command ignores all functions within
		 * the table, saving only the primitive types (i.e. integers, floats, strings, etc with definite values).
		 * The indexes that you use for your table need to be programmatically "clean," meaning that the index
		 * cannot contain invalid characters like +-=!@#$%^&*() etc. Indexes that contain any kind of
		 * invalid character is completely ignored. If you are trying to store player information,
		 * use Player::GetUniqueID() instead of Player::GetSteamID() for the index ID.
		 *
		 * You probably won't need to use this function by itself. @see SaveTable()
		 */
		string SerializeTable(object[] tbl, string predicateStart = "{\n", string predicateEnd = "}\n", bool indice = true);

		/**
		 * This function will serialize and save a table to the hard disk; useful for storing stats,
		 * round times, and other important information.
		 */
		void SaveTable(string fileName, object[] table);

		/**
		 * This function will deserialize and return the compiled table.
		 * If the table does not exist, null is returned.
		 */
		object[] LoadTable(string fileName);


		/**
		 * This function will make the filename unique for each mapname.
		 */
		string MakeFileName( string mapname, string modename );

		/**
		 * This function will serialize and save a table to the hard disk from the current mapname; useful for storing stats,
		 * round times, and other important information individually for every mapname.
		 */
		void SaveTableFileName(string mapname, string modename, object[] table);

		/**
		 * This function will deserialize and return the compiled table from the current mapname.
		 * If the table does not exist, null is returned.
		 */
		object[] LoadTableFileName(string mapname, string modename);
	}
	
	/**
	 * \brief Loose collection of functions and tables that make implementing logic simple.
	 */
	namespace EasyLogic
	{
		/**
		 * \brief Retrieve entities that match required criteria.
		 */
		public static class Objects
		{
			/**
			 * Returns L4D1 survivors.
			 */
			Entity[] L4D1Survivors();

			/**
			 * Returns all entities of a specific classname.
			 *
			 * E.g. foreach ( object in Objects.OfClassname("prop_physics") ) ...
			 */
			Entity[] OfClassname(string classname);

			/**
			 * Returns all entities of a specific classname within a radius.
			 *
			 * E.g. foreach ( object in Objects.OfClassnameWithin("prop_physics", Vector(0,0,0), 10) ) ...
			 */
			Entity[] OfClassnameWithin(string classname, Vector origin, double radius);

			/**
			 * Returns a single entity of the specified classname, or null if non-existent
			 */
			Entity AnyOfClassname(string classname);

			/**
			 * Returns all entities of a specific targetname.
			 */
			Entity[] OfName(string targetname);

			/**
			 * Returns all entities of a specific targetname within a radius.
			 */
			Entity[] OfNameWithin(string targetname, Vector origin, double radius);

			/**
			 * Returns a single entity of the specified targetname, or null if non-existent
			 */
			Entity AnyOfName(string targetname);

			/**
			 * Returns all entities of a particular model.
			 */
			Entity[] OfModel(string model);

			/**
			 * Returns a single entity of the specified model, or null if non-existent
			 */
			Entity AnyOfModel(string model);

			/**
			 * Returns all entities around a radius.
			 *
			 * E.g. foreach ( object in Objects.AroundRadius(pos, radius) ) ...
			 */
			Entity[] AroundRadius(Vector pos, double radius);

			/**
			 * Returns all infected/survivors (including commons) around specified position and radius.
			 * If you need to find infected/survivors around a PLAYER instead, just pass in the player's
			 * position with player.GetLocation()
			 */
			Entity[] AliveAroundRadius(Vector pos, double radius);
		}
		
		/**
		 * \brief Return player entities that match required criteria.
		 */
		public static class Players
		{
			/**
			 * Returns a table of all bots.
			 */
			Player[] Bots();

			/**
			 * Returns a table of all players.
			 */
			Player[] All();

			/**
			 * Returns a table of all special infected.
			 */
			Player[] Infected();

			/**
			 * Returns a table of all common infected.
			 */
			Entity[] CommonInfected();

			/**
			 * Returns a table of all survivors.
			 */
			Player[] Survivors();

			/**
			 * Returns a table of all alive survivors.
			 */
			Player[] AliveSurvivors();

			/**
			 * Returns one valid survivor, or null if none exist
			 */
			Player AnySurvivor();

			/**
			 * Returns one valid alive survivor, or null if none exist
			 */
			Player AnyAliveSurvivor();

			/**
			 * Returns one RANDOM valid alive survivor, or null if none exist
			 */
			Player RandomAliveSurvivor();

			/**
			 * Returns one valid alive survivor with the highest flow distance, or null if none exist
			 */
			Player SurvivorWithHighestFlow();

			/**
			 * Returns a table of all human players.
			 */
			Player[] Humans();

			/**
			 * Returns a table of all infected of a specific type.
			 */
			Player[] OfType(int playerType);
		}
	}

	/**
	 * \brief Many, many helpful misc functions.
	 */
	public static class Utils
	{
		/**
		 * Replaces parts of a string with another string. The "original" param can be anything, but internally uses RegEx.
		 *
		 * @param str The full string
		 * @param original The string to replace
		 * @param replacement The string to replace "original" with
		 * 
		 * @return The modified string
		 */
		string StringReplace(string str, string original, string replacement);

		/**
		 * Searches in the Vars and RoundVars tables if not found in the root table.
		 */
		object SearchMainTables(string idx);

		/**
		 * Combines all elements of an array into one string
		 */
		string CombineArray(object[] args, string delimiter = " ");

		/**
		 * Returns a progress bar as a string.
		 *
		 * For example:  30%  ||||||--------------
		 *
		 *
		 * @param width The length (number of chars) that this progress bar should have
		 * @param count The current value
		 * @param goal The maximum value possible
		 * @param fill What character to fill in for a completed block
		 * @param empty What character to fill in for an incomplete block
		 *
		 * @return A formatted progress bar as string
		 */
		string BuildProgressBar(int width, int count, int goal, string fill = "|", string empty = ".");

		/**
		 * Add printf helper to global table. Works just like C++ printf().
		 *
		 * Supports up to 12 inputs.
		 */
		void printf(string str, params string[] values);


		/**
		 * Wraps Say() to make it easier to read. This will Say to all into chatbox. Similar to C++ printf().
		 */
		void SayToAll(string str, params string[] values);

		/**
		 * Wraps Say() to make it easier to read. This will Say to the player's current team only (incl. the player). Similar to C++ printf().
		 */
		void SayToTeam(Player player, string str, params string[] values);


		/**
		 * Says some text into chatbox after a delay. Similar to C++ printf().
		 */
		void SayToAllDel(string str, params string[] values);


		/**
		 * Says some text into chatbox after a delay to the player's team. Similar to C++ printf().
		 */
		void SayToTeamDel(Player player, string str, params string[] values);

		/**
		 * Spawns a new entity and returns it as VSLib::Entity.
		 *
		 * @param _classname The classname of the entity
		 * @param pos Where to spawn it (a Vector object)
		 * @param ang Angles it should spawn with
		 * @param keyvalues Other keyvalues you may want it to have
		 * @return A VSLib entity object
		 */
		Entity CreateEntity(string _classname, Vector pos = Vector(0,0,0), QAngle ang = QAngle(0,0,0), object[] keyvalues = null);

		/**
		 * Spawns the requested L4D1 Survivor at the location you want.
		 *
		 * \todo Possibly add a way to determine if a requested survivor should glow or not.
		 */
		void SpawnL4D1Survivor(int survivor = 4, Vector pos = Vector(0,0,0), QAngle ang = QAngle(0,0,0));

		/**
		 * Spawns the requested zombie via the Director at the specified location.
		 */
		void SpawnZombie(Vector pos, string zombieType = "default", bool attackOnSpawn = true);

		/**
		 * Spawns the requested zombie near a player and also
		 * checks to make sure that the spawn point is not visible to
		 * any survivor. Attempts to locate a position 50 times.
		 * If it can't find a suitable spawn location, it'll return false.
		 * Keep in mind that the closer the min and max distances are to each
		 * other, the lesser the chance that a suitable spawn will be found.
		 * For a good spawn chance, keep the min and max dist far apart.
		 * If by chance the survivors are looking everywhere at once,
		 * the infected prob won't spawn!
		 */
		bool SpawnZombieNearPlayer( Player player, int zombieNum, double maxDist = 128.0, double minDist = 32.0, bool checkVisibility = true, bool useAltSpawn = false );

		/**
		 * Spawns the requested commentary zombie at the location you want.
		 */
		void SpawnCommentaryZombie(string zombieModel = "common_male_tshirt_cargos", Vector pos = Vector(0,0,0), QAngle ang = QAngle(0,0,0));


		/**
		 * Calculates the distance between two vectors.
		 */
		double CalculateDistance(Vector vec1, Vector vec2);

		/**
		 * Calculates the dot product of two vectors.
		 */
		double VectorDotProduct(Vector a, Vector b);

		/**
		 * Calculates the cross product of two vectors.
		 */
		Vector VectorCrossProduct(Vector a, Vector b);


		/**
		 * Converts QAngles into vectors, with an optional vector length.
		 */
		Vector VectorFromQAngle(QAngle angles, double radius = 1.0);


		/**
		 * Calculates the distance between two entities.
		 */
		double GetDistBetweenEntities(Entity ent1, Entity ent2);

		/**
		 * Draws a debug line from one location to another (can only be seen by host)
		 */
		void DrawLine(Vector pos1, Vector pos2, double time = 10.0, int red = 255, int green = 0, int blue = 0);

		/**
		 * Slows down time.
		 */
		void SlowTime(double desiredTimeScale = 0.2, double re_Acceleration = 2.0, double minBlendRate = 1.0, double blendDeltaMultiplier = 2.0, bool allowResumeTime = true);

		/**
		 * Resumes time that is slowed by SlowTime().
		 *
		 * @see SlowTime
		 */
		void ResumeTime();

		/**
		 * Plays a sound to all clients
		 */
		void PlaySoundToAll(string sound);

		/**
		 * Stops a sound on all clients
		 */
		void StopSoundOnAll(string sound);


		/**
		 * Returns the victim of the attacker player or null if there is no victim
		 */
		Player GetVictimOfAttacker( Player attacker );

		/**
		 * Returns a pseudorandom number from min to max
		 */
		int GetRandNumber( int min, int max );

		/**
		 * Forces a panic event
		 */
		void ForcePanicEvent( );


		/**
		 * Returns a table with the hours, minutes, and seconds provided the total seconds (e.g. Time())
		 *
		 * Example:
		 *     local t = GetTimeTable ( Time() );
		 *     printf("Hours: %i, Minutes: %i, Seconds: %i", t.hours, t.minutes, t.seconds);
		 */
		object[] GetTimeTable( double time );

		/**
		 * Broadcasts a command to all clients.
		 * Currently doesn't work for other clients, only works for the host.
		 */
		void BroadcastClientCommand(string command);

		/**
		 * Precaches a model
		 */
		void PrecacheModel( string mdl );

		/**
		 * Precaches the CS:S weapons, making them usable
		 */
		void PrecacheCSSWeapons( );

		/**
		 * Spawns a dynamic model at the specified location
		 */
		Entity SpawnDynamicProp( string mdl, Vector pos, QAngle ang = QAngle(0,0,0), object[] keyvalues = null );

		/**
		 * Spawns a physics model at the specified location
		 */
		Entity SpawnPhysicsProp( string mdl, Vector pos, QAngle ang = QAngle(0,0,0), object[] keyvalues = null );

		/**
		 * Spawns a ragdoll model at the specified location
		 */
		Entity SpawnRagdoll( string mdl, Vector pos, QAngle ang = QAngle(0,0,0), object[] keyvalues = null );

		/**
		 * Spawns a commentary dummy model at the specified location
		 */
		Entity SpawnCommentaryDummy( string mdl = "models/survivors/survivor_gambler.mdl", string weps = "weapon_pistol", string anim = "Idle_Calm_Pistol", Vector pos = Vector(0,0,0), QAngle ang = QAngle(0,0,0), object[] keyvalues = null );

		/**
		 * Spawns a minigun at the specified location
		 */
		Entity SpawnMinigun( Vector pos, QAngle ang = QAngle(0,0,0), object[] keyvalues = null );

		/**
		 * Spawns a L4D1 minigun at the specified location
		 */
		Entity SpawnL4D1Minigun( Vector pos, QAngle ang = QAngle(0,0,0), object[] keyvalues = null );

		/**
		 * Spawns the requested weapon at the specified location
		 */
		Entity SpawnWeapon( string weaponName, int Count = 4, Vector pos = Vector(0,0,0), QAngle ang = QAngle(0,0,90), object[] keyvalues = null );

		/**
		 * Spawns an ammo pile at the specified location
		 */
		Entity SpawnAmmo( string mdl = "models/props/terror/ammo_stack.mdl", Vector pos = Vector(0,0,0), QAngle ang = QAngle(0,0,0), object[] keyvalues = null );

		/**
		 * Spawns a fuel barrel at the specified location
		 */
		Entity SpawnFuelBarrel( Vector pos, QAngle ang = QAngle(0,0,0), object[] keyvalues = null );

		/**
		 * Spawns a door at the specified location
		 */
		Entity SpawnDoor( string mdl = "models/props_downtown/door_interior_112_01.mdl", Vector pos = Vector(0,0,0), QAngle ang = QAngle(0,0,0), object[] keyvalues = null );

		/**
		 * Kills the given entity. Useful to use with timers.
		 */
		void RemoveEntity( Entity ent );

		/**
		 * Returns a Vector position that is between the min and max radius, or null if not found.
		 */
		Vector GetNearbyLocationRadius( Player player, double minDist, double maxDist );

		/**
		 * Spawns an inventory item that can be picked up by players. Returns the spawned item.
		 *
		 * @see Player::GetInventory()
		 */
		Entity SpawnInventoryItem( string itemName, string mdl, Vector pos );

		/**
		 * Creates a hint on the specified entity, optionally "parenting" the hint.
		 *
		 * \todo @TODO See why normal SetParent doesn't work, needed to "parent" manually
		 *
		 * @param entity The VSLib Entity or Player to set a hint to
		 * @param hinttext The hint to display
		 * @param icon The icon to show, see a list of icons here: https://developer.valvesoftware.com/wiki/Env_instructor_hint#Icons
		 * @param range The maximum range to display this icon. Enter 0 for infinite range
		 * @param parentEnt Set to true to make the hint "follow" the entity
		 * @param duration How long to show the hint. Enter 0 for infinite time.
		 *
		 * @return The actual hint object's VSLib::Entity
		 */
		Entity SetEntityHint( Entity entity, string hinttext, string icon = "icon_info", double range = 0.0, bool parentEnt = false, double duration = 0.0, bool noOffScreen = 1 );

		/**
		 * Manually compares two vectors and returns true if they are equal.
		 * Fix for vector instance overloaded == not firing properly
		 */
		bool AreVectorsEqual(Vector vec1, Vector vec2);

		/**
		 * Shakes the screen with the specified amplitude at the specified location. If the location specified is
		 * null, then the map is shaken globally. Returns the env_shake entity. Note that the returned entity is
		 * automatically killed after its use is done.
		 */
		void ShakeScreen(Vector pos = null, double _amplitude = 2, double _duration = 5.0, double _frequency = 35, double _radius = 500);

		/**
		 * Fades player's screen with the specified color, alpha, etc. Returns the env_fade entity. Note that the entity is
		 * automatically killed after its use is done.
		 */
		void FadeScreen(Player player, int red = 0, int green = 0, int blue = 0, int alpha = 255, double _duration = 5.0, double _holdtime = 5.0, bool modulate = false, bool fadeFrom = false);

		/**
		 * Returns true if the specified classname is a valid melee weapon.
		 */
		bool IsValidMeleeWeapon(string classname);

		/**
		 * Returns true if the specified classname is a valid fire weapon (does not include melee weapons).
		 */
		bool IsValidFireWeapon(string weapon);

		/**
		 * Returns true if the specified classname is a valid weapon (includes melee and fire weapons).
		 */
		bool IsValidWeapon(string classname);

		/**
		 * Gets a random value from an array
		 */
		object GetRandValueFromArray(object[] arr);

		/**
		 * Removes all held weapons from the map.
		 */
		void SanitizeHeldWeapons();

		/**
		 * Removes all held primary weapons from the map.
		 */
		void SanitizeHeldPrimary();

		/**
		 * Removes all held secondary weapons from the map.
		 */
		void SanitizeHeldSecondary();

		/**
		 * Removes all held items from the map.
		 */
		void SanitizeHeldItems();

		/**
		 * Removes all held meds from the map.
		 */
		void SanitizeHeldMeds();

		/**
		 * Removes all unheld weapons from the map.
		 */
		void SanitizeUnheldWeapons();

		/**
		 * Removes all unheld primary weapons from the map.
		 */
		void SanitizeUnheldPrimary();

		/**
		 * Removes all unheld secondary weapons from the map.
		 */
		void SanitizeUnheldSecondary();

		/**
		 * Removes all unheld items from the map.
		 */
		void SanitizeUnheldItems();

		/**
		 * Removes all unheld meds from the map.
		 */
		void SanitizeUnheldMeds();

		/**
		 * Removes all miniguns from the map.
		 */
		void SanitizeMiniguns();

		/**
		 * Kills common spawn locations.
		 */
		void KillZombieSpawns();

		/**
		 * Disables car alarms.
		 */
		void DisableCarAlarms();
	}
}