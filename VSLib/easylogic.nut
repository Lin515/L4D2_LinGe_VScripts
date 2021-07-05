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
 * The EasyLogic table provides helper functions that automate laborious processes.
 *
 * \todo @TODO some of these can be moved to Utils table
 */
if (!("EasyLogic" in ::VSLib))
{
	::VSLib.EasyLogic <-
	{
		// Chat triggers
		_itChatFunction = {}
		_itChatTextIndex = {}
		_itChatCount = 0
		_triggerStart = "!"
		_triggerHide = "/"

		// Intercept chat hooks
		_interceptCount = 0
		_interceptList = {}
		OnInterceptChat = {}

		// Update() hooks
		Update = {}

		// SlowPoll hooks
		SlowPoll = {}

		// Easier chat triggers
		Triggers = {}

		// Easier damage hooks
		OnDamage = {}
		OnTakeDamage = {}

		// User defined data storage
		UserDefinedVars = {}

		// Player/Zombie/Object helpers
		Players = {}
		Zombies = {}
		Objects = {}

		// Bash hooks
		OnBash = {}

		// BotQuery hooks
		OnBotQuery = {}

		// User command hooks
		OnUserCommand = {}

		// Stores VSLib's OnGameEvent_ functions
		Events = {}

		// Hook for when the script starts
		OnScriptStart = {}
		ScriptStarted = false

		// Hooks from scriptedmode.nut
		OnGameplayStart = {}
		OnActivate = {}
		OnShutdown = {}
		OnSystemCall = {}
		OnAddCriteria = {}
		OnPrecache = {}

		// Round variables
		RoundVars =
		{
			function _newslot(key,value)
			{
				::VSLib.EasyLogic.OrigRoundVars[key] <- value;
				return value;
			}
		}

		OrigRoundVars = {}

		// Session variables that remain through map transitions
		SessionVars = {}
		SessionVarsBackup = {}

		// Create entity data cache system
		Cache = {}

		// Create user data cache system
		UserCache = {}

		// Used to determine if the next map is a continuation of the same campaign
		NextMapContinues = false

		// Holds precached sounds
		PrecachedSounds = {}

		// These are used for custom event notifications
		RoundStartPostNavFired = false
		SurvivorsSpawned = {}
		PlayerSpawnedOnce = {}

		// Used to store the rescue trigger entity
		RescueTrigger = null

		// Used to determine if rescue is incoming or leaving
		RescueVehicleIncoming = false
		RescueVehicleLeaving = false

		// Used for Player.Ragdoll()
		SurvivorRagdolls = {}

		// Used for Utils.SpawnSurvivor()
		ExtraBills = []
		ExtraBillsData = {}
		ExtraSurvivorData = {}
		L4D1Behavior = 1
		SpawnExtraSurvivor = 0
		ExtraSurvivorsSpawned = 0
		SpawnL4D1Bill = false
		SpawnL4D1Zoey = false
		SpawnL4D1Francis = false
		SpawnL4D1Louis = false
		SpawnL4D1BotBill = null
		SpawnL4D1BotZoey = null
		SpawnL4D1BotFrancis = null
		SpawnL4D1BotLouis = null

		// Used for Utils.SpawnLeaker()
		LeakerChance = 0
		SpawnLeaker = 0

		// ResponseRules hooks that get fired when loading a map for the first time
		OnProcessResponse = {}

		// Saves misc data
		MiscData =
		{
			maprestarted = 0
			maprestarts = 0
			previousmap = ""
		}
	}
}

// Game event wrapper.
// Just add any events that you want here. The actual event information follows this table.
if (!("Notifications" in ::VSLib.EasyLogic))
{
	::VSLib.EasyLogic.Notifications <-
	{
		// General events
		OnAchievementEarned = {}
		OnAchievementEvent = {}
		OnAwarded = {}
		OnInstructorDraw = {}
		OnInstructorNoDraw = {}
		OnServerHintCreated = {}
		OnServerHintStopped = {}
		OnBulletImpact = {}
		OnDoorMoving = {}
		OnDoorClosed = {}
		OnDoorOpened = {}
		OnDoorUnlocked = {}
		OnRescueVehicleIncoming = {}
		OnRescueVehicleReady = {}
		OnRescueVehicleLeaving = {}
		OnGauntletFinaleStart = {}
		OnFinaleStart = {}
		OnFinaleRadioStart = {}
		OnFinaleWin = {}
		OnEscapeStarted = {}
		OnPreRadioStart = {}
		OnGeneratorStart = {}
		OnBeginSacrificeRun = {}
		OnCompleteSacrifice = {}
		OnReloadedScriptedHud = {}
		OnRoundStartPreEntity = {}
		OnRoundStart = {}
		OnRoundBegin = {}
		OnRoundFreezeEnd = {}
		OnRoundEnd = {}
		OnMapEnd = {}
		OnNavBlocked = {}
		OnSurvivalAt30Min = {}
		OnSurvivalStart = {}
		OnVersusStart = {}
		OnScavengeStart = {}
		OnScavengeHalftime = {}
		OnScavengeOvertime = {}
		OnScavengeRoundFinished = {}
		OnScavengeTied = {}
		OnScavengeMatchFinished = {}
		OnScavengeGascanDestroyed = {}
		OnVersusMarkerReached = {}
		OnVersusMatchFinished = {}
		OnGhostSpawnTime = {}
		OnServerCvarChanged = {}
		OnServerAddBan = {}
		OnServerRemoveBan = {}
		OnServerPreShutdown = {}
		OnServerShutdown = {}
		OnTriggeredCarAlarm = {}
		OnPanicEventFinished = {}
		OnStartScoreAnimation = {}
		OnHostNameChanged = {}

		// General player events (both infected and survivors)
		OnPlayerJoined = {}
		OnPlayerConnected = {}
		OnPlayerLeft = {}
		OnDeath = {}
		OnInfectedDeath = {}
		OnZombieDeath = {}
		OnPlayerKilled = {}
		OnMeleeKill = {}
		OnEnterStartArea = {}
		OnEnterSaferoom = {}
		OnLeaveSaferoom = {}
		OnHurt = {}
		OnHurtConcise = {}
		OnFallDamage = {}
		OnPlayerActivate = {}
		OnSpawn = {}
		OnPostSpawn = {}
		OnStartSpawn = {}
		OnFirstSpawn = {}
		OnTransitioned = {}
		OnEntityShoved = {}
		OnPlayerShoved = {}
		OnEntityVisible = {}
		OnWeaponSpawnVisible = {}
		OnDeadSurvivorVisible = {}
		OnCheckpointButtonWaiting = {}
		OnCheckpointButtonUsed = {}
		OnCheckpointDoorWaiting = {}
		OnCheckpointDoorWaitingVersus = {}
		OnHitSafeRoom = {}
		OnRescueDoorOpened = {}
		OnFootLockerOpened = {}
		OnMountedGunUsed = {}
		OnMountedGunOverheated = {}
		OnUse = {}
		OnTeamChanged = {}
		OnNameChanged = {}
		OnGrabbedLedge = {}
		OnReleasedLedge = {}
		OnPourCompleted = {}
		OnPourBlocked = {}
		OnPourInterrupted = {}
		OnAFK = {}
		OnPlayerReplacedBot = {}
		OnBotReplacedPlayer = {}
		OnSay = {}
		OnVoteCastYes = {}
		OnVoteCastNo = {}
		OnRelocated = {}
		OnRespawning = {}

		// General infected events
		OnAbilityUsed = {}
		OnAbilityOutOfRange = {}
		OnPanicEvent = {}
		OnInfectedHurt = {}
		OnWitchSpawned = {}
		OnWitchStartled = {}
		OnWitchKilled = {}
		OnZombieIgnited = {}

		// Survivor events
		OnDefibBegin = {}
		OnDefibInterrupted = {}
		OnDefibSuccess = {}
		OnDefibFailed = {}
		OnScriptDefib = {} // Called when a player is revived using Defib().
		OnAdrenalineUsed = {}
		OnHealStart = {}
		OnHealEnd = {}
		OnHealInterrupted = {}
		OnHealSuccess = {}
		OnPillsUsed = {}
		OnPillsFailed = {}
		OnIncapacitated = {}
		OnIncapacitatedStart = {}
		OnJump = {}
		OnJumpApex = {}
		FirstSurvLeftStartArea = {}
		OnReviveBegin = {}
		OnReviveEnd = {}
		OnReviveSuccess = {}
		OnFriendlyFire = {}
		OnGascanDropped = {}
		OnWeaponDropped = {}
		OnWeaponGiven = {}
		OnWeaponFire = {}
		OnWeaponFireAt40 = {}
		OnWeaponFireEmpty = {}
		OnWeaponReload = {}
		OnWeaponZoom = {}
		OnItemPickup = {} // Called when a player picks up a weapon, ammo, etc (see Notifications::CanPickupObject if you want to block pickups)
		OnAmmoPickup = {}
		OnAmmoCantUse = {}
		OnPipeBombBounced = {}
		OnPipeBombDetonated = {}
		OnNonPistolFired = {}
		OnTotalAmmoBelow40 = {}
		OnExplosiveBarrelKill = {}
		OnSpawnerGaveItem = {}
		OnSurvivorCallForHelp = {}
		OnSurvivorRescueAbandoned = {}
		OnSurvivorRescued = {}
		OnUpgradeDeploying = {}
		OnUpgradeDeployed = {}
		OnUpgradeReceived = {}
		OnUpgradeAlreadyUsed = {}
		OnUpgradeFailed = {}
		OnLeaveSafeArea = {}

		// Charger events
		OnChargerCharged = {}
		OnChargerCarryVictim = {}
		OnChargerCarryVictimEnd = {}
		OnChargerImpact = {}
		OnChargerPummelBegin = {}
		OnChargerPummelEnd = {}

		// Smoker events
		OnSmokerChokeBegin = {}
		OnSmokerChokeEnd = {}
		OnSmokerChokeStopped = {}
		OnSmokerPullStopped = {}
		OnSmokerTongueReleased = {}
		OnSmokerTongueGrab = {}
		OnSmokerTongueBent = {}

		// Spitter events
		OnSpitLanded = {}
		OnEnterSpit = {}

		// Jockey
		OnJockeyRideStart = {}
		OnJockeyRideEnd = {}
		OnJockeyHeadshot = {}
		OnJockeyPunched = {}

		// Hunter
		OnHunterHeadshot = {}
		OnHunterPounceFailed = {}
		OnHunterPounceShoved = {}
		OnHunterPouncedVictim = {}
		OnHunterPounceStopped = {}
		OnHunterPunched = {}
		OnHunterReleasedVictim = {}

		// Boomer
		OnPlayerVomited = {}
		OnPlayerVomitEnd = {}
		OnFatalVomit = {}
		OnBoomerExploded = {}
		OnBoomerNear = {}

		// Tank
		OnTankFrustrated = {}
		OnTankKilled = {}
		OnTankSpawned = {}
		OnSpawnedAsTank = {}

		// Achievements
		OnPunchedClown = {}
		OnInfectedDecapitated = {}
		OnNonMeleeFired = {}
		OnMolotovThrown = {}
		OnForcedGasCanDrop = {}
		OnStrongmanBellKnockedOff = {}
		OnStashwhackerGameWon = {}
		OnChargerKilled = {}
		OnSpitterKilled = {}
		OnJockeyKilled = {}
		OnVomitBombTank = {}
		OnUpgradePackAdded = {}
		OnChargerChargeEnd = {}
		OnChairCharged = {}
		OnM60StreakEnded = {}
		OnSongPlayed = {}
		OnChristmasGiftGrab = {}
		OnGoldenCrowbarPickup = {}
		OnLeftConcertStage = {}

		// Misc
		OnDifficulty = {}
		OnDifficultyChanged = {}
		OnSurvivorsDead = {}
		OnBrokeProp = {}
		OnBrokeBreakable = {}
		OnWeaponDroppedToProp = {}
		OnPickupInvItem = {} // Called when a player tries to pickup an item spawned with Utils.SpawnInventoryItem()
		CanPickupObject = {} // Called when a player tries to pickup a game-related item (such as some prop or weapon)
		OnMapFirstStart = {}
		OnNextMap = {}
		OnSurvivorsSpawned = {}
		OnSurvivorsLeftStartArea = {}
		OnEnterRescueVehicle = {}
		OnLeaveRescueVehicle = {}

		// SourceTV events
		OnSourceTVStatus = {}
		OnSourceTVRankEntity = {}

		// Hint events from info_game_event_proxy
		OnExplainSurvivorGlowsDisabled = {}
		OnExplainItemGlowsDisabled = {}
		OnExplainRescueDisabled = {}
		OnExplainBodyshotsReduced = {}
		OnExplainWitchInstantKill = {}
		OnExplainNeedGnomeToContinue = {}
		OnExplainPills = {}
		OnExplainWeapons = {}
		OnExplainPreRadio = {}
		OnExplainRadio = {}
		OnExplainGasTruck = {}
		OnExplainPanicButton = {}
		OnExplainElevatorButton = {}
		OnExplainLiftButton = {}
		OnExplainChurchDoor = {}
		OnExplainEmergencyDoor = {}
		OnExplainCrane = {}
		OnExplainBridge = {}
		OnExplainGasCanPanic = {}
		OnExplainVanPanic = {}
		OnExplainMainstreet = {}
		OnExplainTrainLever = {}
		OnExplainDisturbance = {}
		OnExplainScavengeGoal = {}
		OnExplainScavengeLeaveArea = {}
		OnExplainPreDrawbridge = {}
		OnExplainDrawbridge = {}
		OnExplainPerimeter = {}
		OnExplainDeactivateAlarm = {}
		OnExplainImpoundLot = {}
		OnExplainDecon = {}
		OnExplainDeconWait = {}
		OnExplainMallWindow = {}
		OnExplainMallAlarm = {}
		OnExplainCoaster = {}
		OnExplainCoasterStop = {}
		OnExplainFloat = {}
		OnExplainFerryButton = {}
		OnExplainHatchButton = {}
		OnExplainShackButton = {}
		OnExplainVehicleArrival = {}
		OnExplainBurgerSign = {}
		OnExplainCarouselButton = {}
		OnExplainCarouselDestination = {}
		OnExplainStageLighting = {}
		OnExplainStageFinaleStart = {}
		OnExplainStageSurvivalStart = {}
		OnExplainStagePyrotechnics = {}
		OnExplainC3M4Radio1 = {}
		OnExplainC3M4Radio2 = {}
		OnExplainGatesAreOpen = {}
		OnExplainC2M4Ticketbooth = {}
		OnExplainC3M4Rescue = {}
		OnExplainHotelElevatorDoors = {}
		OnExplainGunShopTanker = {}
		OnExplainGunShop = {}
		OnExplainStoreAlarm = {}
		OnExplainStoreItem = {}
		OnExplainStoreItemStop = {}
		OnExplainSurvivalGeneric = {}
		OnExplainSurvivalAlarm = {}
		OnExplainSurvivalRadio = {}
		OnExplainSurvivalCarousel = {}
		OnExplainReturnItem = {}
		OnExplainSaveItems = {}
		OnExplainC4M1GetGas = {}
		OnExplainC4M3ReturnToBoat = {}
		OnExplainC1M4Finale = {}
		OnExplainC1M4ScavengeInstructions = {}
		OnExplainSewerGate = {}
		OnExplainSewerRun = {}
		OnExplainC6M3Finale = {}
		OnExplainFinaleBridgeLowering = {}
		OnExplainTrainBoss = {}
		OnExplainTrainExit = {}
		OnExplainFreighter = {}
		OnExplainHighriseFinale2 = {}
		OnExplainStartGenerator = {}
		OnExplainRestartGenerator = {}
		OnExplainBridgeButton = {}
		OnExplainDLC3Howitzer = {}
		OnExplainDLC3GeneratorButton = {}
		OnExplainDLC3LiftLever = {}
		OnExplainDLC3Barrels = {}
		OnExplainDLC3Radio = {}
		OnExplainDLC3Door = {}
		OnExplainOnslaught = {}
		OnExplainLighthouseGate = {}
		OnExplainLighthouseGenerator = {}
		OnExplainLighthouseGenButton = {}
		OnExplainLighthouseFinaleEvent = {}
		OnExplainLighthouseRestartGen = {}
		OnExplainLighthouseGas = {}
		OnExplainLighthouseFinale = {}
		OnExplainJunkyardFuel = {}
		OnExplainContainerDrop = {}
		OnExplainContainerReady = {}

		// OnScriptEvent_ functions
		OnHoldoutStart = {}
		OnResourcesChanged = {}
		OnHelicopterBegin = {}
		OnHelicopterEnd = {}
		OnCooldownBegin = {}
		OnCooldownEnd = {}

		// ResponseRules Query Events
		OnConcept = {}
	}
}

/**
 * Global constants
 */
// Difficulty to be used with OnDifficulty()
getconsttable()["EASY"] <- "easy";
getconsttable()["NORMAL"] <- "normal";
getconsttable()["ADVANCED"] <- "hard";
getconsttable()["EXPERT"] <- "impossible";

// Materials to be used with OnBrokeBreakable()
getconsttable()["MAT_CEILINGTILE"] <- 0;
getconsttable()["MAT_GLASS"] <- 1;
getconsttable()["MAT_METAL"] <- 2;
getconsttable()["MAT_COMPUTER"] <- 2;
getconsttable()["MAT_FLESH"] <- 4;
getconsttable()["MAT_WOOD"] <- 8;
getconsttable()["MAT_CINDERBLOCK"] <- 64;
getconsttable()["MAT_ROCKS"] <- 64;

// Used with OnBotQuery()
getconsttable()["BOT_QUERY_NOTARGET"] <- 1;

// Miscellaneous Director constants
getconsttable()["FINALE_GAUNTLET_1"] <- 0;
getconsttable()["FINALE_HORDE_ATTACK_1"] <- 1;
getconsttable()["FINALE_HALFTIME_BOSS"] <- 2;
getconsttable()["FINALE_GAUNTLET_2"] <- 3;
getconsttable()["FINALE_HORDE_ATTACK_2"] <- 4;
getconsttable()["FINALE_FINAL_BOSS"] <- 5;
getconsttable()["FINALE_HORDE_ESCAPE"] <- 6;
getconsttable()["FINALE_CUSTOM_PANIC"] <- 7;
getconsttable()["FINALE_CUSTOM_TANK"] <- 8;
getconsttable()["FINALE_CUSTOM_SCRIPTED"] <- 9;
getconsttable()["FINALE_CUSTOM_DELAY"] <- 10;
getconsttable()["FINALE_CUSTOM_CLEAROUT"] <- 11;
getconsttable()["FINALE_GAUNTLET_START"] <- 12;
getconsttable()["FINALE_GAUNTLET_HORDE"] <- 13;
getconsttable()["FINALE_GAUNTLET_HORDE_BONUSTIME"] <- 14;
getconsttable()["FINALE_GAUNTLET_BOSS_INCOMING"] <- 15;
getconsttable()["FINALE_GAUNTLET_BOSS"] <- 16;
getconsttable()["FINALE_GAUNTLET_ESCAPE"] <- 17;

getconsttable()["SCRIPTED_SPAWN_FINALE"] <- 0;
getconsttable()["SCRIPTED_SPAWN_SURVIVORS"] <- 1;
getconsttable()["SCRIPTED_SPAWN_BATTLEFIELD"] <- 2;
getconsttable()["SCRIPTED_SPAWN_POSITIONAL"] <- 3;

getconsttable()["SPAWNDIR_N"] <- (1 << 0);
getconsttable()["SPAWNDIR_NE"] <- (1 << 1);
getconsttable()["SPAWNDIR_E"] <- (1 << 2);
getconsttable()["SPAWNDIR_SE"] <- (1 << 3);
getconsttable()["SPAWNDIR_S"] <- (1 << 4);
getconsttable()["SPAWNDIR_SW"] <- (1 << 5);
getconsttable()["SPAWNDIR_W"] <- (1 << 6);
getconsttable()["SPAWNDIR_NW"] <- (1 << 7);

getconsttable()["SPAWN_NO_PREFERENCE"] <- -1;
getconsttable()["SPAWN_ANYWHERE"] <- 0;
getconsttable()["SPAWN_FINALE"] <- 0;
getconsttable()["SPAWN_BEHIND_SURVIVORS"] <- 1;
getconsttable()["SPAWN_SURVIVORS"] <- 1;
getconsttable()["SPAWN_BATTLEFIELD"] <- 2;
getconsttable()["SPAWN_NEAR_IT_VICTIM"] <- 2;
getconsttable()["SPAWN_POSITIONAL"] <- 3;
getconsttable()["SPAWN_SPECIALS_IN_FRONT_OF_SURVIVORS"] <- 3;
getconsttable()["SPAWN_SPECIALS_ANYWHERE"] <- 4;
getconsttable()["SPAWN_FAR_AWAY_FROM_SURVIVORS"] <- 5;
getconsttable()["SPAWN_ABOVE_SURVIVORS"] <- 6;
getconsttable()["SPAWN_IN_FRONT_OF_SURVIVORS"] <- 7;
getconsttable()["SPAWN_VERSUS_FINALE_DISTANCE"] <- 8;
getconsttable()["SPAWN_LARGE_VOLUME"] <- 9;
getconsttable()["SPAWN_NEAR_POSITION"] <- 10;

// Reasons to be used with OnShutdown()
getconsttable()["SCRIPT_SHUTDOWN_MANUAL"] <- 0;
getconsttable()["SCRIPT_SHUTDOWN_ROUND_RESTART"] <- 1;
getconsttable()["SCRIPT_SHUTDOWN_TEAM_SWAP"] <- 2;
getconsttable()["SCRIPT_SHUTDOWN_LEVEL_TRANSITION"] <- 3;
getconsttable()["SCRIPT_SHUTDOWN_EXIT_GAME"] <- 4;

if ( !("MutationState" in g_ModeScript) )
{
	g_ModeScript.MutationState <- {};
	g_MapScript.MergeSessionStateTables();
	g_ModeScript.MutationState.MapName <- Director.GetMapName();
	g_ModeScript.MutationState.ModeName <- Director.GetGameMode();
}

::VSLibScriptStart <- function ()
{
	::VSLib.EasyLogic.ScriptStarted <- true;
	VSLib_ResetRoundVars();
	VSLib_ResetCache();

	RestoreTable( "_vslib_user_cache", ::VSLib.EasyLogic.UserCache );

	if (::VSLib.EasyLogic.UserCache == null)
		::VSLib.EasyLogic.UserCache <- {};

	// Restore session table
	if (::VSLib.rawin("GlobalCacheSession"))
		RestoreTable( "_vslib_global_cache_session", ::VSLib.GlobalCacheSession );

	::VSLib.GlobalCache <- ::VSLib.FileIO.LoadTable( "_vslib_global_cache" );
	if (::VSLib.GlobalCache == null)
	{
		::VSLib.GlobalCache <- {};

		// Attempt read from session
		::VSLib.GlobalCache <- ::VSLib.Utils.DeserializeIdxTable(::VSLib.GlobalCacheSession);

		if (::VSLib.GlobalCache == null)
			::VSLib.GlobalCache <- {};
	}

	RestoreTable( "_vslib_save_data", ::VSLib.EasyLogic.MiscData );
	RestoreTable( "_vslib_session_vars", ::VSLib.EasyLogic.SessionVars );
	foreach( key, val in ::VSLib.EasyLogic.SessionVars )
		::VSLib.EasyLogic.SessionVarsBackup[key] <- val;

	foreach (func in ::VSLib.EasyLogic.OnScriptStart)
		func();
}

// Make a call to MapScript and ModeScript, returns whether any calls were made
// NOTE: sadly only does no-argument calls - which makes this way less useful
g_MapScript.ScriptMode_SystemCall <- function (callname)
{
	local calls = 0;
	if ( callname in g_MapScript )   // do we allow returning False to say "dont call Mode"? ugh...
	{
		g_MapScript[callname]();
		calls++;
	}
	if ( callname in g_ModeScript )
	{
		g_ModeScript[callname]();
		calls++;
	}
	if ( callname == "Precache" )
	{
		foreach (func in ::VSLib.EasyLogic.OnPrecache)
			func();
	}
	foreach (func in ::VSLib.EasyLogic.OnSystemCall)
		func(callname);
	return calls > 0;
}

//=========================================================
// this is called from C++ when the gameplay start happens
//=========================================================
g_MapScript.ScriptMode_OnGameplayStart <- function (modename, mapname)
{
	if ( "SessionSpawns" in getroottable() )
		EntSpawn_DoTheSpawns( ::SessionSpawns );
	ScriptMode_SystemCall("OnGameplayStart");
	foreach (func in ::VSLib.EasyLogic.OnGameplayStart)
		func(modename, mapname);
	return SessionState.StartActive;
}

//=========================================================
// this is called from C++ when the mode activates
//=========================================================
g_MapScript.ScriptMode_OnActivate <- function (modename, mapname)
{
	if ( g_ModeScript == null )
	{
		// Need to reload the mode script
		// TODO: Should know exactly which script we want to load here

		g_ModeScript = getroottable().DirectorScript.MapScript.ChallengeScript;

		if ( IncludeScript( modename, g_ModeScript ) )
		{
			printl( "ScriptMode loaded " + modename + " and now Initializing" );
		}
	}

	if ( !SessionState.StartActive )
	{
		MergeSessionOptionTables();
	}

	if ( "SetupModeHUD" in g_ModeScript )
	{
		g_ModeScript.SetupModeHUD();
	}

	ScriptMode_SystemCall("OnActivate");

	foreach (slowPoll in ::VSLib.EasyLogic.SlowPoll)
		g_MapScript.ScriptedMode_AddSlowPoll( slowPoll );

	foreach (func in ::VSLib.EasyLogic.OnActivate)
		func(modename, mapname);
}

//=========================================================
// called as the mutation shuts down
//=========================================================
g_MapScript.ScriptMode_OnShutdown <- function (reason, nextmap)
{
	::VSLib.Timers.RemoveTimerByName("VSLib_LeftStartCheck");
	VSLib_ResetRoundVars();
	VSLib_ResetCache();
	VSLib_RemoveDeadTimers();

	if ( reason > 0 && reason < 4 )
	{
		if ( reason == 1 )
		{
			::VSLib.EasyLogic.MiscData.maprestarted <- 1;
			::VSLib.EasyLogic.MiscData.maprestarts++;
			SaveTable( "_vslib_session_vars", ::VSLib.EasyLogic.SessionVarsBackup );
		}
		else if ( reason == 2 )
		{
			::VSLib.EasyLogic.MiscData.maprestarted <- 1;
			::VSLib.EasyLogic.MiscData.maprestarts++;
			SaveTable( "_vslib_session_vars", ::VSLib.EasyLogic.SessionVars );
		}
		else if ( reason == 3 )
		{
			::VSLib.EasyLogic.MiscData.previousmap <- Director.GetMapName();
			::VSLib.EasyLogic.MiscData.maprestarted <- 0;
			::VSLib.EasyLogic.MiscData.maprestarts <- 0;
			if ( ::VSLib.EasyLogic.NextMapContinues )
			{
				SaveTable( "_vslib_session_vars", ::VSLib.EasyLogic.SessionVars );
				foreach (func in ::VSLib.EasyLogic.Notifications.OnNextMap)
					func(nextmap);
			}
		}
		SaveTable( "_vslib_save_data", ::VSLib.EasyLogic.MiscData );
		SaveTable( "_vslib_global_cache_session", ::VSLib.GlobalCache );
		SaveTable( "_vslib_user_cache", ::VSLib.EasyLogic.UserCache );
	}
	SessionState.ShutdownReason <- reason;
	SessionState.NextMap <- nextmap;
	ScriptMode_SystemCall( "OnShutdown" );
	foreach (slowPoll in ::VSLib.EasyLogic.SlowPoll)
		g_MapScript.ScriptedMode_RemoveSlowPoll( slowPoll );
	foreach (func in ::VSLib.EasyLogic.OnShutdown)
		func(reason, nextmap);
	g_ModeScript = null;

	// Delete ::VSLib in order to reset data upon restarts
	delete ::VSLib;
}

//=========================================================
// Called by RR system to add any global criteria to queries based on mode or map state
//=========================================================
g_MapScript.ScriptMode_AddCriteria <- function ( )
{   // @todo: is there a varargs for syscall? - if so swap this to a syscall
	local criteria = {};
	if ( "AddCriteria" in g_ModeScript)   // does this break and falsely delegate
		g_ModeScript.AddCriteria( criteria );
	if ( "AddCriteria" in g_MapScript)
		g_MapScript.AddCriteria( criteria );
	foreach (func in ::VSLib.EasyLogic.OnAddCriteria)
		func(criteria);
	return criteria;
}

/*
 * All the game events are below. Note how we wrap the events to make the
 * interface easy to use and much more organized. For example, "OnEnterSafeRoom"
 * is much easier to understand than "player_entered_checkpoint". Also, we pass
 * the major event table params as individual paramaters to the function hooks,
 * enabling the data to be used quickly and efficiently. That also removes
 * a lot of repetitive logic by organizing common tasks in ::VSLib.EasyLogic.
 *
 * \todo @TODO This stuff can get repetitive... fast. A function to group similar instructions would be nice.
 */

::VSLib.EasyLogic.Events.OnGameEvent_player_hurt <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	local _id = ents.entity.GetIndex();
	if(_id in ::VSLib.EasyLogic.Cache)
		::VSLib.EasyLogic.Cache[_id]._lastAttacker <- ents.attacker;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnHurt)
		func(ents.entity, ents.attacker, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_hurt_concise <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnHurtConcise)
		func(ents.entity, ents.attacker, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_falldamage <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local damage = ::VSLib.EasyLogic.GetEventFloat(params, "damage");
	local causer = ::VSLib.EasyLogic.GetEventPlayer(params, "causer");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnFallDamage)
		func(ents.entity, damage, causer, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_award_earned <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local subjectentid = ::VSLib.EasyLogic.GetEventInt(params, "subjectentid");
	local award = ::VSLib.EasyLogic.GetEventInt(params, "award");

	local idx = ents.entity.GetIndex();

	if(!(idx in ::VSLib.EasyLogic.Cache))
		::VSLib.EasyLogic.Cache[idx] <- {};
	if (!("Awards" in ::VSLib.EasyLogic.Cache[idx]))
		::VSLib.EasyLogic.Cache[idx].Awards <- {};
	::VSLib.EasyLogic.Cache[idx].Awards[award] <- true;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnAwarded)
		func(ents.entity, subjectentid, award, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_gameinstructor_draw <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnInstructorDraw)
		func();
}

::VSLib.EasyLogic.Events.OnGameEvent_gameinstructor_nodraw <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnInstructorNoDraw)
		func();
}

::VSLib.EasyLogic.Events.OnGameEvent_instructor_server_hint_create <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventInt(params, "userid");
	if ( player != 0 )
		player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local entity = ::VSLib.EasyLogic.GetEventEntity(params, "hint_entindex");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnServerHintCreated)
		func(player, entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_instructor_server_hint_stop <- function (params)
{
	local entity = ::VSLib.EasyLogic.GetEventEntity(params, "hint_entindex");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnServerHintStopped)
		func(entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_bullet_impact <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local x = ::VSLib.EasyLogic.GetEventFloat(params, "x");
	local y = ::VSLib.EasyLogic.GetEventFloat(params, "y");
	local z = ::VSLib.EasyLogic.GetEventFloat(params, "z");
	local origin = Vector( x, y, z );

	foreach (func in ::VSLib.EasyLogic.Notifications.OnBulletImpact)
		func(ents.entity, origin, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_door_moving <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local door = ::VSLib.EasyLogic.GetEventEntity(params, "entindex");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnDoorMoving)
		func(ents.entity, door, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_door_close <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local checkpoint = ::VSLib.EasyLogic.GetEventInt(params, "checkpoint");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnDoorClosed)
		func(ents.entity, checkpoint, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_door_open <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local checkpoint = ::VSLib.EasyLogic.GetEventInt(params, "checkpoint");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnDoorOpened)
		func(ents.entity, checkpoint, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_door_unlocked <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local checkpoint = ::VSLib.EasyLogic.GetEventInt(params, "checkpoint");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnDoorUnlocked)
		func(ents.entity, checkpoint, params);
}

::VSLib_RescueCheck <- function (args)
{
	if ( args.player.GetResponseCriterion("InRescueVehicle") == "1" )
	{
		::VSLib.EasyLogic.RescueTrigger <- args.entity;
		::VSLib.EasyLogic.RescueTrigger.ConnectOutput( "OnEndTouch", VSLib_LeaveRescue );
		foreach( trigger in ::VSLib.EasyLogic.Objects.OfClassname("trigger_multiple") )
		{
			if ( trigger.GetEntityHandle() != ::VSLib.EasyLogic.RescueTrigger.GetEntityHandle() )
				trigger.DisconnectOutput( "OnStartTouch", "VSLib_RescueVehicleCheck" );
		}

		local _id = args.player.GetIndex();
		if ( !( "_inRescue" in ::VSLib.EasyLogic.Cache[_id] ) )
			::VSLib.EasyLogic.Cache[_id]._inRescue <- false;

		if ( !::VSLib.EasyLogic.Cache[_id]._inRescue )
		{
			::VSLib.EasyLogic.Cache[_id]._inRescue <- true;
			foreach (func in ::VSLib.EasyLogic.Notifications.OnEnterRescueVehicle)
				func(args.player);
		}
	}
	else
	{
		if ( args.entity.IsEntityValid() )
			args.entity.DisconnectOutput( "OnStartTouch", "VSLib_RescueVehicleCheck" );
	}
}

::VSLib_LeaveRescue <- function ()
{
	if ( !::VSLib.Entity(activator).IsSurvivor() )
		return;

	if ( !::VSLib.EasyLogic.RescueTrigger || ::VSLib.EasyLogic.RescueVehicleLeaving )
		return;
	else
	{
		local _id = ::VSLib.Player(activator).GetIndex();
		if ( ::VSLib.EasyLogic.Cache[_id]._inRescue )
		{
			::VSLib.EasyLogic.Cache[_id]._inRescue <- false;
			foreach (func in ::VSLib.EasyLogic.Notifications.OnLeaveRescueVehicle)
				func(::VSLib.Player(activator));
		}
	}
}

::VSLib_EnterRescue <- function ()
{
	if ( !::VSLib.Entity(activator).IsSurvivor() )
		return;

	if ( !::VSLib.EasyLogic.RescueTrigger )
		::VSLib.Timers.AddTimer(0.1, false, VSLib_RescueCheck, { player = ::VSLib.Player(activator), entity = ::VSLib.Entity(self) });
	else
	{
		local _id = ::VSLib.Player(activator).GetIndex();
		if ( !( "_inRescue" in ::VSLib.EasyLogic.Cache[_id] ) )
			::VSLib.EasyLogic.Cache[_id]._inRescue <- false;

		if ( !::VSLib.EasyLogic.Cache[_id]._inRescue )
		{
			::VSLib.EasyLogic.Cache[_id]._inRescue <- true;
			foreach (func in ::VSLib.EasyLogic.Notifications.OnEnterRescueVehicle)
				func(::VSLib.Player(activator));
		}
	}
}

::VSLib_ConnectRescueVehicleOutputs <- function ()
{
	if ( Director.GetMapName() == "c1m4_atrium" )
	{
		::VSLib.EasyLogic.RescueTrigger <- ::VSLib.EasyLogic.Objects.AnyOfName("trigger_escape");
		::VSLib.EasyLogic.RescueTrigger.ConnectOutput( "OnStartTouch", VSLib_EnterRescue );
		::VSLib.EasyLogic.RescueTrigger.ConnectOutput( "OnEndTouch", VSLib_LeaveRescue );
	}
	else if ( Director.GetMapName() == "c2m5_concert" )
	{
		::VSLib.EasyLogic.RescueTrigger <- ::VSLib.EasyLogic.Objects.AnyOfName("stadium_exit_right_escape_trigger");
		::VSLib.EasyLogic.RescueTrigger.ConnectOutput( "OnStartTouch", VSLib_EnterRescue );
		::VSLib.EasyLogic.RescueTrigger.ConnectOutput( "OnEndTouch", VSLib_LeaveRescue );
		::VSLib.EasyLogic.RescueTrigger <- ::VSLib.EasyLogic.Objects.AnyOfName("stadium_exit_leftt_escape_trigger");
		::VSLib.EasyLogic.RescueTrigger.ConnectOutput( "OnStartTouch", VSLib_EnterRescue );
		::VSLib.EasyLogic.RescueTrigger.ConnectOutput( "OnEndTouch", VSLib_LeaveRescue );
	}
	else if ( Director.GetMapName() == "c7m3_port" )
	{
		::VSLib.EasyLogic.RescueTrigger <- ::VSLib.EasyLogic.Objects.AnyOfName("bridge_rescue");
		::VSLib.EasyLogic.RescueTrigger.ConnectOutput( "OnStartTouch", VSLib_EnterRescue );
		::VSLib.EasyLogic.RescueTrigger.ConnectOutput( "OnEndTouch", VSLib_LeaveRescue );
	}
	else if ( Director.GetMapName() == "c10m5_houseboat" )
	{
		::VSLib.EasyLogic.RescueTrigger <- ::VSLib.EasyLogic.Objects.AnyOfName("trigger_boat");
		::VSLib.EasyLogic.RescueTrigger.ConnectOutput( "OnStartTouch", VSLib_EnterRescue );
		::VSLib.EasyLogic.RescueTrigger.ConnectOutput( "OnEndTouch", VSLib_LeaveRescue );
	}
	else
	{
		local triggers = [];
		foreach( trigger in ::VSLib.EasyLogic.Objects.OfClassname("trigger_multiple") )
		{
			if ( trigger.GetNetPropInt("m_iEntireTeam") == 2 && trigger.GetNetPropInt("m_bAllowIncapTouch") == 0 )
				triggers.append( trigger );
		}

		if ( triggers.len() == 1 )
		{
			::VSLib.EasyLogic.RescueTrigger <- triggers[0];
			::VSLib.EasyLogic.RescueTrigger.ConnectOutput( "OnStartTouch", VSLib_EnterRescue );
			::VSLib.EasyLogic.RescueTrigger.ConnectOutput( "OnEndTouch", VSLib_LeaveRescue );
		}
		else
		{
			foreach( trigger in ::VSLib.EasyLogic.Objects.OfClassname("trigger_multiple") )
				trigger.ConnectOutput( "OnStartTouch", VSLib_EnterRescue, "VSLib_RescueVehicleCheck" );
		}
	}
}

::VSLib.EasyLogic.Events.OnGameEvent_finale_vehicle_leaving <- function (params)
{
	::VSLib.EasyLogic.RescueVehicleLeaving <- true;

	local count = ::VSLib.EasyLogic.GetEventInt(params, "survivorcount");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnRescueVehicleLeaving)
		func(count, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_finale_vehicle_ready <- function (params)
{
	if ( !::VSLib.EasyLogic.RescueVehicleIncoming )
		VSLib_ConnectRescueVehicleOutputs();

	local campaign = ::VSLib.EasyLogic.GetEventString(params, "campaign");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnRescueVehicleReady)
		func(campaign, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_finale_vehicle_incoming <- function (params)
{
	::VSLib.EasyLogic.RescueVehicleIncoming <- true;

	VSLib_ConnectRescueVehicleOutputs();

	local campaign = ::VSLib.EasyLogic.GetEventString(params, "campaign");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnRescueVehicleIncoming)
		func(campaign, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_gauntlet_finale_start <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnGauntletFinaleStart)
		func();
}

::VSLib.EasyLogic.Events.OnGameEvent_finale_start <- function (params)
{
	local campaign = ::VSLib.EasyLogic.GetEventString(params, "campaign");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnFinaleStart)
		func(campaign, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_finale_radio_start <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnFinaleRadioStart)
		func(params);
}

::VSLib.EasyLogic.Events.OnGameEvent_finale_win <- function (params)
{
	local map_name = ::VSLib.EasyLogic.GetEventString(params, "map_name");
	local diff = ::VSLib.EasyLogic.GetEventInt(params, "difficulty");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnFinaleWin)
		func(map_name, diff, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_finale_escape_start <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnEscapeStarted)
		func(params);
}

::VSLib.EasyLogic.Events.OnGameEvent_started_pre_radio <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnPreRadioStart)
		func(params);
}

::VSLib.EasyLogic.Events.OnGameEvent_generator_started <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnGeneratorStart)
		func();
}

::VSLib.EasyLogic.Events.OnGameEvent_player_begin_sacrifice_run <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnBeginSacrificeRun)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_complete_sacrifice <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnCompleteSacrifice)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_achievement_earned <- function (params)
{
	local playerIndex = ::VSLib.EasyLogic.GetEventInt(params, "player");
	local achievementID = ::VSLib.EasyLogic.GetEventInt(params, "achievement");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnAchievementEarned)
		func(playerIndex, achievementID, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_achievement_event <- function (params)
{
	local achievement = ::VSLib.EasyLogic.GetEventString(params, "achievement_name");
	local cur_val = ::VSLib.EasyLogic.GetEventInt(params, "cur_val");
	local max_val = ::VSLib.EasyLogic.GetEventInt(params, "max_val");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnAchievementEvent)
		func(achievement, cur_val, max_val, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_difficulty_changed <- function (params)
{
	local diff = ::VSLib.EasyLogic.GetEventString(params, "strDifficulty").tolower();
	local oldDiff = ::VSLib.EasyLogic.GetEventInt(params, "oldDifficulty");
	local olddiff = "";

	if (oldDiff == 0)
		olddiff = "easy";
	else if (oldDiff == 1)
		olddiff = "normal";
	else if (oldDiff == 2)
		olddiff = "hard";
	else if (oldDiff == 3)
		olddiff = "impossible";

	foreach (func in ::VSLib.EasyLogic.Notifications.OnDifficultyChanged)
		func(diff, olddiff);
	foreach (func in ::VSLib.EasyLogic.Notifications.OnDifficulty)
		func(diff, olddiff);
}



::VSLib_ResetRoundVars <- function ()
{
	// reset round vars
	foreach (idx, var in ::VSLib.EasyLogic.OrigRoundVars)
		::VSLib.EasyLogic.RoundVars[idx] = var;
}

::VSLib_RemoveDeadTimers <- function ()
{
	// Clear timer cache
	if ("Timers" in ::VSLib)
	{
		if ("TimersList" in ::VSLib.Timers)
		{
			foreach (idx, timer in ::VSLib.Timers.TimersList)
			{
				if ( !(timer._flags & TIMER_FLAG_KEEPALIVE) )
					delete ::VSLib.Timers.TimersList[idx];
			}
		}
	}
}

::VSLib_ResetCache <- function ()
{
	// clear the cache
	::VSLib.EasyLogic.Cache.clear();

	// Re-create entity data cache system
	::VSLib.EasyLogic.Cache <- {};
	for (local i = -1; i < 2048; i++)
		::VSLib.EasyLogic.Cache[i] <- { Awards = {} };
}

::VSLib.EasyLogic.Events.OnGameEvent_round_start_pre_entity <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnRoundStartPreEntity)
		func();
}

::VSLib_ConceptData <- function (query)
{
	if ("VSLib" in getroottable())
	{
		foreach (func in ::VSLib.EasyLogic.Notifications.OnConcept)
			func(query);
	}

	return false;
}

::VSLib_LeftStartCheck <- function (params)
{
	foreach( survivor in ::VSLib.EasyLogic.Players.Survivors() )
	{
		if ( !survivor.IsInStartArea() )
		{
			foreach (func in ::VSLib.EasyLogic.Notifications.OnSurvivorsLeftStartArea)
				func();

			::VSLib.Timers.RemoveTimerByName("VSLib_LeftStartCheck");
			break;
		}
	}
}

::vslib_map_first_start <- function ()
{
	foreach (func in ::VSLib.EasyLogic.OnProcessResponse)
		func();
	foreach (func in ::VSLib.EasyLogic.Notifications.OnMapFirstStart)
		func();
}

::VSLib.EasyLogic.Events.OnGameEvent_round_start_post_nav <- function (params)
{
	if ( ::VSLib.EasyLogic.RoundStartPostNavFired )
		return;

	if ( !::VSLib.EasyLogic.ScriptStarted )
		VSLibScriptStart();

	::VSLib.EasyLogic.RoundStartPostNavFired <- true;

	local diff = ::VSLib.Utils.GetDifficulty();
	local olddiff = diff;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnRoundStart)
		func();

	foreach (func in ::VSLib.EasyLogic.Notifications.OnDifficulty)
		func(diff, olddiff);
}

::VSLib.EasyLogic.Events.OnGameEvent_round_start <- function (params)
{
	if ( !::VSLib.EasyLogic.ScriptStarted )
		VSLibScriptStart();

	if ( !::VSLib.Utils.HasMapRestarted() )
	{
		if (::VSLib.rawin("ResponseRules"))
		{
			local vsl_query_data =
			[
				{
					name = "VSLibConceptData",
					criteria =
					[
						[ VSLib_ConceptData ],
					],
					responses =
					[
						{
							scenename = "",
						}
					],
					group_params = ::VSLib.ResponseRules.GroupParams({ permitrepeats = true, sequential = false, norepeat = false })
				},
			]
			::VSLib.ResponseRules.ProcessRules( vsl_query_data );
		}
		vslib_map_first_start();
	}

	foreach (func in ::VSLib.EasyLogic.Notifications.OnRoundBegin)
		func(params);
}

::VSLib.EasyLogic.Events.OnGameEvent_round_freeze_end <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnRoundFreezeEnd)
		func();
}

::VSLib.EasyLogic.Events.OnGameEvent_map_transition <- function (params)
{
	::VSLib.EasyLogic.NextMapContinues <- true;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnMapEnd)
		func();
}

::VSLib.EasyLogic.Events.OnGameEvent_scriptedmode_reloadhud <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnReloadedScriptedHud)
		func();
}

::VSLib.EasyLogic.Events.OnGameEvent_survival_at_30min <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnSurvivalAt30Min)
		func();
}

::VSLib.EasyLogic.Events.OnGameEvent_survival_round_start <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnSurvivalStart)
		func();
}

::VSLib.EasyLogic.Events.OnGameEvent_versus_round_start <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnVersusStart)
		func();
}

::VSLib.EasyLogic.Events.OnGameEvent_scavenge_round_start <- function (params)
{
	local round = ::VSLib.EasyLogic.GetEventInt(params, "round");
	local firsthalf = ::VSLib.EasyLogic.GetEventInt(params, "firsthalf");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnScavengeStart)
		func(round, (firsthalf > 0) ? true : false, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_scavenge_round_halftime <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnScavengeHalftime)
		func();
}

::VSLib.EasyLogic.Events.OnGameEvent_begin_scavenge_overtime <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnScavengeOvertime)
		func();
}

::VSLib.EasyLogic.Events.OnGameEvent_scavenge_round_finished <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnScavengeRoundFinished)
		func();
}

::VSLib.EasyLogic.Events.OnGameEvent_scavenge_score_tied <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnScavengeTied)
		func();
}

::VSLib.EasyLogic.Events.OnGameEvent_scavenge_match_finished <- function (params)
{
	local winners = ::VSLib.EasyLogic.GetEventInt(params, "winners");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnScavengeMatchFinished)
		func(winners, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_scavenge_gas_can_destroyed <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnScavengeGascanDestroyed)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_versus_marker_reached <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local marker = ::VSLib.EasyLogic.GetEventInt(params, "marker");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnVersusMarkerReached)
		func(ents.entity, marker, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_versus_match_finished <- function (params)
{
	local winners = ::VSLib.EasyLogic.GetEventInt(params, "winners");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnVersusMatchFinished)
		func(winners, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_ghost_spawn_time <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local spawntime = ::VSLib.EasyLogic.GetEventInt(params, "spawntime");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnGhostSpawnTime)
		func(player, spawntime, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_mission_lost <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnSurvivorsDead)
		func();
}

::VSLib.EasyLogic.Events.OnGameEvent_round_end <- function (params)
{
	::VSLib.EasyLogic.NextMapContinues <- true;

	local winner = ::VSLib.EasyLogic.GetEventInt(params, "winner"); // team or player
	local reason = ::VSLib.EasyLogic.GetEventInt(params, "reason");
	local message = ::VSLib.EasyLogic.GetEventString(params, "message");
	local time = ::VSLib.EasyLogic.GetEventFloat(params, "time");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnRoundEnd)
		func(winner, reason, message, time, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_nav_blocked <- function (params)
{
	local area = ::VSLib.EasyLogic.GetEventInt(params, "area");
	local blocked = ::VSLib.EasyLogic.GetEventInt(params, "blocked");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnNavBlocked)
		func(area, (blocked > 0) ? true : false, params);
}


::RetryConnect <- function (params)
{
	::VSLib.EasyLogic.Events.OnGameEvent_player_connect(params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_connect <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local name = ::VSLib.EasyLogic.GetEventString(params, "name");
	local ipAddress = ::VSLib.EasyLogic.GetEventString(params, "address");
	local steamID = ::VSLib.EasyLogic.GetEventString(params, "networkid");
	local xuid = ::VSLib.EasyLogic.GetEventString(params, "xuid");

	if (ents.entity != null)
	{
		local _id = ents.entity.GetIndex();

		if (_id in ::VSLib.GlobalCache)
			delete ::VSLib.GlobalCache[_id];

		::VSLib.GlobalCache[_id] <- {};
		::VSLib.GlobalCache[_id]["_name"] <- name;
		::VSLib.GlobalCache[_id]["_ip"] <- ipAddress;
		::VSLib.GlobalCache[_id]["_steam"] <- steamID;
		::VSLib.GlobalCache[_id]["_xuid"] <- xuid;

		// Save our changes to the global cache
		::VSLib.FileIO.SaveTable( "_vslib_global_cache", ::VSLib.GlobalCache );

		if ( ents.entity.IsHuman() )
		{
			local _userid = "_vslUserID_" + ents.entity.GetUserID();

			if (_userid in ::VSLib.EasyLogic.UserCache)
				delete ::VSLib.EasyLogic.UserCache[_userid];

			::VSLib.EasyLogic.UserCache[_userid] <- {};
			::VSLib.EasyLogic.UserCache[_userid]["_name"] <- name;
			::VSLib.EasyLogic.UserCache[_userid]["_ip"] <- ipAddress;
			::VSLib.EasyLogic.UserCache[_userid]["_steam"] <- steamID;
			::VSLib.EasyLogic.UserCache[_userid]["_xuid"] <- xuid;
		}

		foreach (func in ::VSLib.EasyLogic.Notifications.OnPlayerJoined)
			func(ents.entity, name, ipAddress, steamID, params);
	}
	else
	{
		::VSLib.Timers.AddTimer(1, false, RetryConnect, params);
	}
}


::VSLib.EasyLogic.Events.OnGameEvent_player_connect_full <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnPlayerConnected)
		func(ents.entity, params);
}


::VSLib.EasyLogic.Events.OnGameEvent_player_disconnect <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local name = ::VSLib.EasyLogic.GetEventString(params, "name");
	local steamID = ::VSLib.EasyLogic.GetEventString(params, "networkid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnPlayerLeft)
		func(ents.entity, name, steamID, params);
}


::VSLib.EasyLogic.Events.OnGameEvent_player_activate <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnPlayerActivate)
		func(ents.entity, params);
}


::VSLib.EasyLogic.Events.OnGameEvent_player_changename <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local oldname = ::VSLib.EasyLogic.GetEventString(params, "oldname");
	local newname = ::VSLib.EasyLogic.GetEventString(params, "newname");

	local _id = ents.entity.GetIndex();
	if(_id in ::VSLib.EasyLogic.Cache)
		::VSLib.EasyLogic.Cache[_id]._name <- newname;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnNameChanged)
		func(ents.entity, oldname, newname, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_death <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	if (ents.entity == null) return;

	if (ents.entity.IsPlayer())
	{
		local idx = ents.entity.GetIndex();
		::VSLib.EasyLogic.Cache[idx]._lastKilledBy <- ents.attacker;
		::VSLib.EasyLogic.Cache[idx]._deathPos <- ents.entity.GetLocation();
		::VSLib.EasyLogic.Cache[idx]._isFrustrated <- false;
	}

	if ( (ents.attacker != null) && (ents.attacker.IsSurvivor()) && (ents.entity.GetTeam() == INFECTED) )
	{
		local _id = ents.attacker.GetIndex();

		if ( ents.attacker.IsIncapacitated() )
		{
			if ( !("_zombiesKilledWhileIncapacitated" in ::VSLib.EasyLogic.Cache[_id]) )
				::VSLib.EasyLogic.Cache[_id]._zombiesKilledWhileIncapacitated <- 0;

			::VSLib.EasyLogic.Cache[_id]._zombiesKilledWhileIncapacitated++;
		}

		if ( !("_zombiesKilled" in ::VSLib.EasyLogic.Cache[_id]) )
			::VSLib.EasyLogic.Cache[_id]._zombiesKilled <- 0;

		::VSLib.EasyLogic.Cache[_id]._zombiesKilled++;
	}

	foreach (func in ::VSLib.EasyLogic.Notifications.OnDeath)
		func(ents.entity, ents.attacker, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_item_pickup <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local item = ::VSLib.EasyLogic.GetEventString(params, "item");

	if ( !::VSLib.EasyLogic.ScriptStarted )
		VSLibScriptStart();

	foreach (func in ::VSLib.EasyLogic.Notifications.OnItemPickup)
		func(ents.entity, "weapon_" + item, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_ammo_pickup <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnAmmoPickup)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_ammo_pile_weapon_cant_use_ammo <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnAmmoCantUse)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_defibrillator_begin <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local reviver = ents.entity;
	local subject = ::VSLib.EasyLogic.GetEventPlayer(params, "subject");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnDefibBegin)
		func(subject, reviver, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_defibrillator_interrupted <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local reviver = ents.entity;
	local subject = ::VSLib.EasyLogic.GetEventPlayer(params, "subject");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnDefibInterrupted)
		func(subject, reviver, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_defibrillator_used <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local reviver = ents.entity;
	local subject = ::VSLib.EasyLogic.GetEventPlayer(params, "subject");

	local idx = subject.GetIndex();
	::VSLib.EasyLogic.Cache[idx]._lastDefibBy <- reviver;

	if ( idx in ::VSLib.EasyLogic.SurvivorRagdolls )
	{
		::VSLib.EasyLogic.SurvivorRagdolls[idx]["Ragdoll"].Kill();
		::VSLib.EasyLogic.SurvivorRagdolls.rawdelete(idx);
	}

	foreach (func in ::VSLib.EasyLogic.Notifications.OnDefibSuccess)
		func(subject, reviver, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_defibrillator_used_fail <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local reviver = ents.entity;
	local subject = ::VSLib.EasyLogic.GetEventPlayer(params, "subject");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnDefibFailed)
		func(subject, reviver, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_entered_checkpoint <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	if ( !::VSLib.EasyLogic.ScriptStarted )
		VSLibScriptStart();

	local _id = ents.entity.GetIndex();
	if(_id in ::VSLib.EasyLogic.Cache)
		::VSLib.EasyLogic.Cache[_id]._inSafeRoom <- true;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnEnterSaferoom)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_left_checkpoint <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	if ( !::VSLib.EasyLogic.ScriptStarted )
		VSLibScriptStart();

	local _id = ents.entity.GetIndex();
	if(_id in ::VSLib.EasyLogic.Cache)
		::VSLib.EasyLogic.Cache[_id]._inSafeRoom <- false;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnLeaveSaferoom)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_jump <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnJump)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_jump_apex <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnJumpApex)
		func(ents.entity, params);
}

::_OnPostSpawnEv <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	if (ents.entity == null || !("IsPlayerEntityValid" in ents.entity))
		return false;

	local name = ents.entity.GetCharacterName();

	if ( (name != "") && !(name in ::VSLib.EasyLogic.PlayerSpawnedOnce) )
	{
		::VSLib.EasyLogic.PlayerSpawnedOnce[name] <- true;
		foreach (func in ::VSLib.EasyLogic.Notifications.OnStartSpawn)
			func(ents.entity, params);

		if ( ents.entity.GetTeam() == SURVIVORS )
		{
			::VSLib.EasyLogic.SurvivorsSpawned[name] <- true;
			foreach (func in ::VSLib.EasyLogic.Notifications.OnSurvivorsSpawned)
				func(::VSLib.EasyLogic.SurvivorsSpawned.len());
		}
	}

	foreach (func in ::VSLib.EasyLogic.Notifications.OnPostSpawn)
		func(ents.entity, params);
}

::_L4D1SurvivorTeamSwitch <- function (player)
{
	if ( ::VSLib.EasyLogic.SpawnL4D1BotBill && player.GetSurvivorCharacter() == 4 )
	{
		player.SetNetProp("m_survivorCharacter", ::VSLib.EasyLogic.SpawnL4D1BotBill);
		::VSLib.EasyLogic.SpawnL4D1BotBill = null;
	}
	else if ( ::VSLib.EasyLogic.SpawnL4D1BotZoey && player.GetSurvivorCharacter() == 5 )
	{
		player.SetNetProp("m_survivorCharacter", ::VSLib.EasyLogic.SpawnL4D1BotZoey);
		::VSLib.EasyLogic.SpawnL4D1BotZoey = null;
	}
	else if ( ::VSLib.EasyLogic.SpawnL4D1BotFrancis && player.GetSurvivorCharacter() == 6 )
	{
		player.SetNetProp("m_survivorCharacter", ::VSLib.EasyLogic.SpawnL4D1BotFrancis);
		::VSLib.EasyLogic.SpawnL4D1BotFrancis = null;
	}
	else if ( ::VSLib.EasyLogic.SpawnL4D1BotLouis && player.GetSurvivorCharacter() == 7 )
	{
		player.SetNetProp("m_survivorCharacter", ::VSLib.EasyLogic.SpawnL4D1BotLouis);
		::VSLib.EasyLogic.SpawnL4D1BotLouis = null;
	}
	player.SetNetProp("m_iTeamNum", 2);
	Convars.SetValue("sb_l4d1_survivor_behavior", ::VSLib.EasyLogic.L4D1Behavior);
}

::_ResetExtraBills <- function (params)
{
	foreach( survivor in ::VSLib.EasyLogic.ExtraBills )
	{
		if ( ::VSLib.Utils.GetSurvivorSet() == 1 )
		{
			if ( survivor.GetIndex() in ::VSLib.EasyLogic.ExtraBillsData )
			{
				survivor.SetNetProp("m_survivorCharacter", ::VSLib.EasyLogic.ExtraBillsData[survivor.GetIndex()]["SurvivorCharacter"]);
				survivor.SetLocation(::VSLib.EasyLogic.ExtraBillsData[survivor.GetIndex()]["Origin"]);
				survivor.SetAnglesVec(::VSLib.EasyLogic.ExtraBillsData[survivor.GetIndex()]["Angles"]);
			}
		}
		else
			survivor.SetNetProp("m_survivorCharacter", 4);
	}
	::VSLib.EasyLogic.ExtraBills = [];
	::VSLib.EasyLogic.ExtraBillsData = {};
}

::_ExtraSurvivorFailsafe <- function (params)
{
	::VSLib.EasyLogic.SpawnExtraSurvivor = 0;
	::VSLib.EasyLogic.ExtraSurvivorsSpawned = 0;
	::VSLib.EasyLogic.SpawnL4D1Bill = false;
	::VSLib.EasyLogic.SpawnL4D1Zoey = false;
	::VSLib.EasyLogic.SpawnL4D1Francis = false;
	::VSLib.EasyLogic.SpawnL4D1Louis = false;
	Convars.SetValue("sb_l4d1_survivor_behavior", ::VSLib.EasyLogic.L4D1Behavior);

	if ( ::VSLib.EasyLogic.ExtraBills.len() > 0 )
	{
		foreach( survivor in ::VSLib.EasyLogic.ExtraBills )
		{
			if ( ::VSLib.Utils.GetSurvivorSet() == 1 )
			{
				if ( survivor.GetIndex() in ::VSLib.EasyLogic.ExtraBillsData )
					survivor.SetNetProp("m_survivorCharacter", ::VSLib.EasyLogic.ExtraBillsData[survivor.GetIndex()]["SurvivorCharacter"]);
				else
					survivor.SetNetProp("m_survivorCharacter", 0);
			}
			else
				survivor.SetNetProp("m_survivorCharacter", 4);
		}
		::VSLib.EasyLogic.ExtraBills = [];
		::VSLib.EasyLogic.ExtraBillsData = {};
		::VSLib.EasyLogic.ExtraSurvivorData = {};
	}
}

::_LeakerFailsafe <- function (params)
{
	::VSLib.EasyLogic.SpawnLeaker = 0;
	Convars.SetValue("boomer_leaker_chance", ::VSLib.EasyLogic.LeakerChance);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_spawn <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local _id = ents.entity.GetIndex();

	if ( !::VSLib.EasyLogic.ScriptStarted )
		VSLibScriptStart();

	if (!(_id in ::VSLib.EasyLogic.Cache))
		::VSLib.EasyLogic.Cache[_id] <- {};

	::VSLib.EasyLogic.Cache[_id]._startPos <- ents.entity.GetLocation();

	// Remove any bots off the global cache
	if (ents.entity.IsBot() && ents.entity.GetTeam() == INFECTED && _id in ::VSLib.GlobalCache)
		delete ::VSLib.GlobalCache[_id];

	if ("_isLeaker" in ::VSLib.EasyLogic.Cache[_id])
		delete ::VSLib.EasyLogic.Cache[_id]["_isLeaker"];
	if ("_isBoomette" in ::VSLib.EasyLogic.Cache[_id])
		delete ::VSLib.EasyLogic.Cache[_id]["_isBoomette"];

	if ( ents.entity.GetType() == Z_BOOMER )
	{
		if ( ::VSLib.EasyLogic.SpawnLeaker > 0 )
		{
			::VSLib.EasyLogic.SpawnLeaker--;
			Convars.SetValue("boomer_leaker_chance", ::VSLib.EasyLogic.LeakerChance);
			::VSLib.Timers.RemoveTimerByName("VSLibLeakerFailsafe");
		}

		local ability = ents.entity.GetNetPropEntity( "m_customAbility" );

		if ( (ability) && (ability.GetClassname() == "ability_selfdestruct") )
			::VSLib.EasyLogic.Cache[_id]._isLeaker <- true;
		if ( ents.entity.GetGender() == FEMALE )
			::VSLib.EasyLogic.Cache[_id]._isBoomette <- true;
	}

	if ( ::VSLib.EasyLogic.SpawnExtraSurvivor > 0 && ents.entity.GetSurvivorCharacter() == 4 )
	{
		::VSLib.EasyLogic.SpawnExtraSurvivor--;
		::VSLib.EasyLogic.ExtraSurvivorsSpawned++;
		if ( ::VSLib.Utils.GetSurvivorSet() == 1 )
		{
			foreach( survivor in ::VSLib.EasyLogic.ExtraBills )
			{
				survivor.SetNetProp("m_survivorCharacter", 0);
				::VSLib.EasyLogic.ExtraBillsData[survivor.GetIndex()]["Origin"] <- survivor.GetLocation();
				::VSLib.EasyLogic.ExtraBillsData[survivor.GetIndex()]["Angles"] <- survivor.GetAngles();
			}
		}
		ents.entity.SetNetProp("m_iTeamNum", 2);
		Convars.SetValue("sb_l4d1_survivor_behavior", ::VSLib.EasyLogic.L4D1Behavior);
		::VSLib.Timers.RemoveTimerByName("VSLibExtraSurvivorFailsafe");
		if ( ::VSLib.EasyLogic.ExtraSurvivorsSpawned in ::VSLib.EasyLogic.ExtraSurvivorData )
		{
			ents.entity.SetLocation(::VSLib.EasyLogic.ExtraSurvivorData[::VSLib.EasyLogic.ExtraSurvivorsSpawned]["Origin"]);
			ents.entity.SetAnglesVec(::VSLib.EasyLogic.ExtraSurvivorData[::VSLib.EasyLogic.ExtraSurvivorsSpawned]["Angles"]);
		}
		if ( ::VSLib.EasyLogic.SpawnExtraSurvivor == 0 )
		{
			::VSLib.EasyLogic.ExtraSurvivorsSpawned = 0;
			::VSLib.EasyLogic.ExtraSurvivorData = {};
		}
	}
	if ( (ents.entity.GetSurvivorCharacter() == 4 && ::VSLib.EasyLogic.SpawnL4D1Bill) || (ents.entity.GetSurvivorCharacter() == 5 && ::VSLib.EasyLogic.SpawnL4D1Zoey) || (ents.entity.GetSurvivorCharacter() == 6 && ::VSLib.EasyLogic.SpawnL4D1Francis) || (ents.entity.GetSurvivorCharacter() == 7 && ::VSLib.EasyLogic.SpawnL4D1Louis) )
	{
		if ( ents.entity.GetSurvivorCharacter() == 4 )
			::VSLib.EasyLogic.SpawnL4D1Bill = false;
		else if ( ents.entity.GetSurvivorCharacter() == 5 )
			::VSLib.EasyLogic.SpawnL4D1Zoey = false;
		else if ( ents.entity.GetSurvivorCharacter() == 6 )
			::VSLib.EasyLogic.SpawnL4D1Francis = false;
		else if ( ents.entity.GetSurvivorCharacter() == 7 )
			::VSLib.EasyLogic.SpawnL4D1Louis = false;

		::VSLib.Timers.RemoveTimerByName("VSLibExtraSurvivorFailsafe");
		::VSLib.Timers.AddTimer(0.1, false, _L4D1SurvivorTeamSwitch, ents.entity);
	}

	foreach (func in ::VSLib.EasyLogic.Notifications.OnSpawn)
		func(ents.entity, params);

	::VSLib.Timers.AddTimer(0.1, false, _OnPostSpawnEv, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_first_spawn <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local _id = ents.entity.GetIndex();

	if ( !::VSLib.EasyLogic.ScriptStarted )
		VSLibScriptStart();

	// Remove any bots off the global cache
	if (ents.entity.IsBot() && ents.entity.GetTeam() == SURVIVORS && _id in ::VSLib.GlobalCache)
		delete ::VSLib.GlobalCache[_id];

	foreach (func in ::VSLib.EasyLogic.Notifications.OnFirstSpawn)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_transitioned <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnTransitioned)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_shoved <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	local _id = ents.entity.GetIndex();
	if(_id in ::VSLib.EasyLogic.Cache)
		::VSLib.EasyLogic.Cache[_id]._lastShovedBy <- ents.attacker;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnPlayerShoved)
		func(ents.entity, ents.attacker, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_entity_shoved <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnEntityShoved)
		func(ents.entity, ents.attacker, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_waiting_checkpoint_button_used <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnCheckpointButtonWaiting)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_success_checkpoint_button_used <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnCheckpointButtonUsed)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_waiting_checkpoint_door_used <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local door = ::VSLib.EasyLogic.GetEventEntity(params, "entindex");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnCheckpointDoorWaiting)
		func(ents.entity, door, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_waiting_door_used_versus <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local door = ::VSLib.EasyLogic.GetEventEntity(params, "entindex");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnCheckpointDoorWaitingVersus)
		func(ents.entity, door, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_hit_safe_room <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnHitSafeRoom)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_rescue_door_open <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local door = ::VSLib.EasyLogic.GetEventEntity(params, "entindex");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnRescueDoorOpened)
		func(ents.entity, door, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_foot_locker_opened <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnFootLockerOpened)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_use <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local targetid = ::VSLib.EasyLogic.GetEventPlayer(params, "targetid");

	local _id = ents.entity.GetIndex();
	if(_id in ::VSLib.EasyLogic.Cache)
		::VSLib.EasyLogic.Cache[_id]._lastUse <- targetid;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnUse)
		func(ents.entity, targetid, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_team <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local oldteam = ::VSLib.EasyLogic.GetEventInt(params, "oldteam");
	local newteam = ::VSLib.EasyLogic.GetEventInt(params, "team");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnTeamChanged)
		func(ents.entity, oldteam, newteam, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_afk <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "player");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnAFK)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_bot_replace <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "player");
	local bot = ::VSLib.EasyLogic.GetEventPlayer(params, "bot");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnBotReplacedPlayer)
		func(player, bot, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_bot_player_replace <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "player");
	local bot = ::VSLib.EasyLogic.GetEventPlayer(params, "bot");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnPlayerReplacedBot)
		func(player, bot, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_ability_use <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local ability = ::VSLib.EasyLogic.GetEventString(params, "ability");

	local _id = ents.entity.GetIndex();
	if(_id in ::VSLib.EasyLogic.Cache)
		::VSLib.EasyLogic.Cache[_id]._lastAbility <- ability;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnAbilityUsed)
		func(ents.entity, ability, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_ability_out_of_range <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local ability = ::VSLib.EasyLogic.GetEventString(params, "ability");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnAbilityOutOfRange)
		func(ents.entity, ability, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_create_panic_event <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnPanicEvent)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_gascan_pour_completed <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnPourCompleted)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_gascan_pour_blocked <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnPourBlocked)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_gascan_pour_interrupted <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnPourInterrupted)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_gascan_dropped <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnGascanDropped)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_infected_hurt <- function (params)
{
	local infected = ::VSLib.EasyLogic.GetEventEntity(params, "entityid");
	local attackerid = ::VSLib.EasyLogic.GetEventInt(params, "attacker");
	local attacker = null;
	if (attackerid != 0)
		attacker = ::VSLib.EasyLogic.GetEventPlayer(params, "attacker");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnInfectedHurt)
		func(infected, attacker, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_melee_kill <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local victim = ::VSLib.EasyLogic.GetEventEntity(params, "entityid");
	local ambush = ::VSLib.EasyLogic.GetEventInt(params, "ambush");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnMeleeKill)
		func(player, victim, (ambush > 0) ? true : false, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_infected_death <- function (params)
{
	local attackerid = ::VSLib.EasyLogic.GetEventInt(params, "attacker");
	local attacker = null;
	if (attackerid != 0)
		attacker = ::VSLib.EasyLogic.GetEventPlayer(params, "attacker");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnInfectedDeath)
		func(attacker, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_zombie_death <- function (params)
{
	local victim = ::VSLib.EasyLogic.GetEventEntity(params, "victim");
	if (victim.IsPlayer())
		victim = ::VSLib.EasyLogic.GetEventPlayer(params, "victim");
	local attackerid = ::VSLib.EasyLogic.GetEventInt(params, "attacker");
	local attacker = null;
	if (attackerid != 0)
	{
		attacker = ::VSLib.EasyLogic.GetEventEntity(params, "attacker");
		if (attacker && (attacker.IsPlayer()))
			attacker = ::VSLib.EasyLogic.GetEventPlayer(params, "attacker");
	}

	foreach (func in ::VSLib.EasyLogic.Notifications.OnZombieDeath)
		func(victim, attacker, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_witch_spawn <- function (params)
{
	local witchid = ::VSLib.EasyLogic.GetEventEntity(params, "witchid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnWitchSpawned)
		func(witchid, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_witch_harasser_set <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local witchid = ::VSLib.EasyLogic.GetEventPlayer(params, "witchid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnWitchStartled)
		func(witchid, ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_witch_killed <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local witchid = ::VSLib.EasyLogic.GetEventPlayer(params, "witchid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnWitchKilled)
		func(witchid, ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_zombie_ignited <- function (params)
{
	local victim = ::VSLib.EasyLogic.GetEventEntity(params, "entityid");
	if (victim.IsPlayer())
		victim = ::VSLib.EasyLogic.GetEventPlayer(params, "entityid");
	local attackerid = ::VSLib.EasyLogic.GetEventInt(params, "userid");
	local attacker = null;
	if (attackerid != 0)
		attacker = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnZombieIgnited)
		func(victim, attacker, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_adrenaline_used <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnAdrenalineUsed)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_heal_begin <- function (params)
{
	local healer = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local healee = ::VSLib.EasyLogic.GetEventPlayer(params, "subject");

	if ( healer.GetIndex() == healee.GetIndex() )
		::VSLib.EasyLogic.Cache[healer.GetIndex()]._isHealing <- true;
	else
		::VSLib.EasyLogic.Cache[healee.GetIndex()]._isBeingHealed <- true;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnHealStart)
		func(healee, healer, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_heal_end <- function (params)
{
	local healer = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local healee = ::VSLib.EasyLogic.GetEventPlayer(params, "subject");

	::VSLib.EasyLogic.Cache[healer.GetIndex()]._isHealing <- false;

	foreach( survivor in ::VSLib.EasyLogic.Players.AllSurvivors() )
		if ("_isBeingHealed" in ::VSLib.EasyLogic.Cache[survivor.GetIndex()])
			::VSLib.EasyLogic.Cache[survivor.GetIndex()]._isBeingHealed <- false;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnHealEnd)
		func(healee, healer, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_heal_interrupted <- function (params)
{
	local healer = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local healee = ::VSLib.EasyLogic.GetEventPlayer(params, "subject");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnHealInterrupted)
		func(healee, healer, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_heal_success <- function (params)
{
	local healer = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local healee = ::VSLib.EasyLogic.GetEventPlayer(params, "subject");
	local health = ::VSLib.EasyLogic.GetEventInt(params, "health_restored");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnHealSuccess)
		func(healee, healer, health, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_pills_used <- function (params)
{
	local healee = ::VSLib.EasyLogic.GetEventPlayer(params, "subject");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnPillsUsed)
		func(healee, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_pills_used_fail <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnPillsFailed)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_incapacitated <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnIncapacitated)
		func(ents.entity, ents.attacker, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_incapacitated_start <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnIncapacitatedStart)
		func(ents.entity, ents.attacker, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_entered_start_area <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnEnterStartArea)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_left_start_area <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.FirstSurvLeftStartArea)
		func(ents.entity, params);
}



::VSLib.EasyLogic.Events.OnGameEvent_revive_begin <- function (params)
{
	local revivor = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local revivee = ::VSLib.EasyLogic.GetEventPlayer(params, "subject");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnReviveBegin)
		func(revivee, revivor, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_revive_end <- function (params)
{
	local revivor = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local revivee = ::VSLib.EasyLogic.GetEventPlayer(params, "subject");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnReviveEnd)
		func(revivee, revivor, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_revive_success <- function (params)
{
	local revivor = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local revivee = ::VSLib.EasyLogic.GetEventPlayer(params, "subject");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnReviveSuccess)
		func(revivee, revivor, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_weapon_given <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local giver = ::VSLib.EasyLogic.GetEventPlayer(params, "giver");
	local weapon = ::VSLib.EasyLogic.GetEventEntity(params, "weaponentid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnWeaponGiven)
		func(ents.entity, giver, weapon, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_weapon_drop <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local item = ::VSLib.EasyLogic.GetEventEntity(params, "propid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnWeaponDropped)
		func(ents.entity, item, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_weapon_drop_to_prop <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local weapon = ::VSLib.EasyLogic.GetEventString(params, "item");
	local item = ::VSLib.EasyLogic.GetEventEntity(params, "propid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnWeaponDroppedToProp)
		func(ents.entity, item, "weapon_" + weapon, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_weapon_fire <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local weapon = ::VSLib.EasyLogic.GetEventString(params, "weapon");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnWeaponFire)
		func(ents.entity, "weapon_" + weapon, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_weapon_fire_at_40 <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local weapon = ::VSLib.EasyLogic.GetEventString(params, "weapon");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnWeaponFireAt40)
		func(ents.entity, "weapon_" + weapon, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_weapon_fire_on_empty <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local weapon = ::VSLib.EasyLogic.GetEventString(params, "weapon");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnWeaponFireEmpty)
		func(ents.entity, "weapon_" + weapon, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_weapon_reload <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local manual = ::VSLib.EasyLogic.GetEventInt(params, "manual");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnWeaponReload)
		func(ents.entity, (manual > 0) ? true : false, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_weapon_zoom <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnWeaponZoom)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_friendly_fire <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local victim = ::VSLib.EasyLogic.GetEventPlayer(params, "victim");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnFriendlyFire)
		func(ents.entity, victim, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_charger_charge_start <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnChargerCharged)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_charger_carry_end <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local victim = ::VSLib.EasyLogic.GetEventPlayer(params, "victim");
	if (!victim) return; if (!victim.IsPlayerEntityValid()) return;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnChargerCarryVictimEnd)
		func(ents.entity, victim, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_charger_carry_start <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local victim = ::VSLib.EasyLogic.GetEventPlayer(params, "victim");
	if (!victim) return; if (!victim.IsPlayerEntityValid()) return;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnChargerCarryVictim)
		func(ents.entity, victim, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_charger_impact <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local victim = ::VSLib.EasyLogic.GetEventPlayer(params, "victim");
	if (!victim) return; if (!victim.IsPlayerEntityValid()) return;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnChargerImpact)
		func(ents.entity, victim, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_charger_pummel_start <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local victim = ::VSLib.EasyLogic.GetEventPlayer(params, "victim");
	if (!victim) return; if (!victim.IsPlayerEntityValid()) return;

	::VSLib.EasyLogic.Cache[victim.GetIndex()]._curAttker <- ents.entity;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnChargerPummelBegin)
		func(ents.entity, victim, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_charger_pummel_end <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local victim = ::VSLib.EasyLogic.GetEventPlayer(params, "victim");
	if (!victim) return; if (!victim.IsPlayerEntityValid()) return;

	::VSLib.EasyLogic.Cache[victim.GetIndex()]._curAttker <- null;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnChargerPummelEnd)
		func(ents.entity, victim, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_choke_start <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local victim = ::VSLib.EasyLogic.GetEventPlayer(params, "victim");
	if (!victim) return; if (!victim.IsPlayerEntityValid()) return;

	::VSLib.EasyLogic.Cache[victim.GetIndex()]._curAttker <- ents.entity;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnSmokerChokeBegin)
		func(ents.entity, victim, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_choke_stopped <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local victim = ::VSLib.EasyLogic.GetEventPlayer(params, "victim");
	if (!victim) return; if (!victim.IsPlayerEntityValid()) return;
	local smoker = ::VSLib.EasyLogic.GetEventPlayer(params, "smoker");

	::VSLib.EasyLogic.Cache[victim.GetIndex()]._curAttker <- null;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnSmokerChokeStopped)
		func(smoker, victim, ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_choke_end <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local victim = ::VSLib.EasyLogic.GetEventPlayer(params, "victim");
	if (!victim) return; if (!victim.IsPlayerEntityValid()) return;

	::VSLib.EasyLogic.Cache[victim.GetIndex()]._curAttker <- null;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnSmokerChokeEnd)
		func(ents.entity, victim, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_tongue_pull_stopped <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local victim = ::VSLib.EasyLogic.GetEventPlayer(params, "victim");
	local smoker = ::VSLib.EasyLogic.GetEventPlayer(params, "smoker");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnSmokerPullStopped)
		func(ents.entity, victim, smoker, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_tongue_release <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local victimid = ::VSLib.EasyLogic.GetEventInt(params, "victim");
	local victim = null;
	if ( victimid != 0 )
		victim = ::VSLib.EasyLogic.GetEventPlayer(params, "victim");
	if (!victim) return; if (!victim.IsPlayerEntityValid()) return;

	::VSLib.EasyLogic.Cache[victim.GetIndex()]._curAttker <- null;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnSmokerTongueReleased)
		func(ents.entity, victim, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_tongue_grab <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local victim = ::VSLib.EasyLogic.GetEventPlayer(params, "victim");
	if (!victim) return; if (!victim.IsPlayerEntityValid()) return;

	::VSLib.EasyLogic.Cache[victim.GetIndex()]._curAttker <- ents.entity;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnSmokerTongueGrab)
		func(ents.entity, victim, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_tongue_broke_bent <- function (params)
{
	local smoker = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnSmokerTongueBent)
		func(smoker, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_spit_burst <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local subject = ::VSLib.EasyLogic.GetEventPlayer(params, "subject");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnSpitLanded)
		func(ents.entity, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_entered_spit <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnEnterSpit)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_jockey_ride <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local victim = ::VSLib.EasyLogic.GetEventPlayer(params, "victim");
	if (!victim) return; if (!victim.IsPlayerEntityValid()) return;

	local _id = ents.entity.GetIndex();
	if(_id in ::VSLib.EasyLogic.Cache)
		::VSLib.EasyLogic.Cache[_id]._lastAbility <- "ability_ride";
	::VSLib.EasyLogic.Cache[victim.GetIndex()]._curAttker <- ents.entity;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnJockeyRideStart)
		func(ents.entity, victim, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_jockey_ride_end <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local victim = ::VSLib.EasyLogic.GetEventPlayer(params, "victim");
	if (!victim) return; if (!victim.IsPlayerEntityValid()) return;

	::VSLib.EasyLogic.Cache[victim.GetIndex()]._curAttker <- null;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnJockeyRideEnd)
		func(ents.entity, victim, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_lunge_shove <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local victim = ::VSLib.EasyLogic.GetEventPlayer(params, "victim");
	if (!victim) return; if (!victim.IsPlayerEntityValid()) return;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnHunterPounceShoved)
		func(ents.entity, victim, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_lunge_pounce <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local victim = ::VSLib.EasyLogic.GetEventPlayer(params, "victim");
	if (!victim) return; if (!victim.IsPlayerEntityValid()) return;

	::VSLib.EasyLogic.Cache[victim.GetIndex()]._curAttker <- ents.entity;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnHunterPouncedVictim)
		func(ents.entity, victim, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_jockey_punched <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local jockey = ::VSLib.EasyLogic.GetEventPlayer(params, "jockeyuserid");
	local islunging = ::VSLib.EasyLogic.GetEventInt(params, "islunging");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnJockeyPunched)
		func(player, jockey, (islunging > 0) ? true : false, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_jockey_headshot <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local jockey = ::VSLib.EasyLogic.GetEventPlayer(params, "jockeyuserid");
	local islunging = ::VSLib.EasyLogic.GetEventInt(params, "islunging");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnJockeyHeadshot)
		func(player, jockey, (islunging > 0) ? true : false, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_pounce_stopped <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local victim = ::VSLib.EasyLogic.GetEventPlayer(params, "victim");
	if (!victim) return; if (!victim.IsPlayerEntityValid()) return;

	::VSLib.EasyLogic.Cache[victim.GetIndex()]._curAttker <- null;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnHunterPounceStopped)
		func(ents.entity, victim, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_pounce_end <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local victim = ::VSLib.EasyLogic.GetEventPlayer(params, "victim");
	if (!victim) return; if (!victim.IsPlayerEntityValid()) return;

	::VSLib.EasyLogic.Cache[victim.GetIndex()]._curAttker <- null;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnHunterReleasedVictim)
		func(ents.entity, victim, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_hunter_punched <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local hunter = ::VSLib.EasyLogic.GetEventPlayer(params, "hunteruserid");
	local islunging = ::VSLib.EasyLogic.GetEventInt(params, "islunging");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnHunterPunched)
		func(player, hunter, (islunging > 0) ? true : false, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_hunter_headshot <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local hunter = ::VSLib.EasyLogic.GetEventPlayer(params, "hunteruserid");
	local islunging = ::VSLib.EasyLogic.GetEventInt(params, "islunging");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnHunterHeadshot)
		func(player, hunter, (islunging > 0) ? true : false, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_pounce_fail <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnHunterPounceFailed)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_now_it <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	local _id = ents.entity.GetIndex();
	::VSLib.EasyLogic.Cache[_id]._lastVomitedBy <- ents.attacker;
	::VSLib.EasyLogic.Cache[_id]._wasVomited <- true;
	::VSLib.EasyLogic.Cache[_id]._isBiled <- true;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnPlayerVomited)
		func(ents.entity, ents.attacker, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_no_longer_it <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	local _id = ents.entity.GetIndex();
	::VSLib.EasyLogic.Cache[_id]._isBiled <- false;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnPlayerVomitEnd)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_fatal_vomit <- function (params)
{
	local victim = ::VSLib.EasyLogic.GetEventPlayer(params, "victim");
	local boomer = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnFatalVomit)
		func(victim, boomer, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_boomer_exploded <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local splashedbile = ::VSLib.EasyLogic.GetEventInt(params, "splashedbile");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnBoomerExploded)
		func(ents.entity, ents.attacker, (splashedbile > 0) ? true : false, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_boomer_near <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local victim = ::VSLib.EasyLogic.GetEventPlayer(params, "victim");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnBoomerNear)
		func(ents.entity, victim, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_tank_frustrated <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	local _id = ents.entity.GetIndex();
	::VSLib.EasyLogic.Cache[_id]._isFrustrated <- true;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnTankFrustrated)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_tank_killed <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnTankKilled)
		func(ents.entity, ents.attacker, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_tank_spawn <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnTankSpawned)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_spawned_as_tank <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnSpawnedAsTank)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_survivor_call_for_help <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnSurvivorCallForHelp)
		func(ents.entity, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_survivor_rescue_abandoned <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnSurvivorRescueAbandoned)
		func();
}

::VSLib.EasyLogic.Events.OnGameEvent_survivor_rescued <- function (params)
{
	local rescuerid = ::VSLib.EasyLogic.GetEventInt(params, "rescuer");
	local rescuer = null;
	if (rescuerid != 0)
		rescuer = ::VSLib.EasyLogic.GetEventPlayer(params, "rescuer");
	local victim = ::VSLib.EasyLogic.GetEventPlayer(params, "victim");

	if ( victim.GetIndex() in ::VSLib.EasyLogic.SurvivorRagdolls )
	{
		::VSLib.EasyLogic.SurvivorRagdolls[victim.GetIndex()]["Ragdoll"].Kill();
		::VSLib.EasyLogic.SurvivorRagdolls.rawdelete(victim.GetIndex());
	}

	foreach (func in ::VSLib.EasyLogic.Notifications.OnSurvivorRescued)
		func(rescuer, victim, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_upgrade_pack_begin <- function (params)
{
	local deployer = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnUpgradeDeploying)
		func(deployer, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_upgrade_pack_used <- function (params)
{
	local deployer = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local upgrade = ::VSLib.EasyLogic.GetEventEntity(params, "upgradeid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnUpgradeDeployed)
		func(deployer, upgrade, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_receive_upgrade <- function (params)
{
	local receiver = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local upgrade = ::VSLib.EasyLogic.GetEventString(params, "upgrade");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnUpgradeReceived)
		func(receiver, upgrade, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_upgrade_item_already_used <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local upgrade = ::VSLib.EasyLogic.GetEventString(params, "upgradeclass");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnUpgradeAlreadyUsed)
		func(player, upgrade, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_upgrade_failed_no_primary <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local upgrade = ::VSLib.EasyLogic.GetEventString(params, "upgrade");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnUpgradeFailed)
		func(player, upgrade, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_ledge_grab <- function (params)
{
	local causer = ::VSLib.EasyLogic.GetEventPlayer(params, "causer");
	local victim = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnGrabbedLedge)
		func(causer, victim, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_ledge_release <- function (params)
{
	local victim = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnReleasedLedge)
		func(victim, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_say <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventInt(params, "userid");
	if ( player != 0 )
		player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local text = ::VSLib.EasyLogic.GetEventString(params, "text");

	// Separate the commands and arguments
	local arr = split(text, " ");

	// Build an argument array
	local args = {};
	local idx = -1;
	foreach (k, v in arr)
	{
		if (k != -1 && v != null && v != "")
		{
			args[idx] <- v;
			idx++;
		}
	}

	// Store it.
	::VSLib.EasyLogic.LastArgs <- args;

	foreach (func in ::VSLib.EasyLogic.Notifications.OnSay)
		func(player, text, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_infected_explosive_barrel_kill <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplosiveBarrelKill)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_vote_cast_yes <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "entityid");
	local team = ::VSLib.EasyLogic.GetEventInt(params, "team");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnVoteCastYes)
		func(player, team, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_vote_cast_no <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "entityid");
	local team = ::VSLib.EasyLogic.GetEventInt(params, "team");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnVoteCastNo)
		func(player, team, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_relocated <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnRelocated)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_respawning <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnRespawning)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_hostname_changed <- function (params)
{
	local hostname = ::VSLib.EasyLogic.GetEventString(params, "hostname");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnHostNameChanged)
		func(hostname, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_server_cvar <- function (params)
{
	local cvar = ::VSLib.EasyLogic.GetEventString(params, "cvarname");
	local value = ::VSLib.EasyLogic.GetEventString(params, "cvarvalue");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnServerCvarChanged)
		func(cvar, value, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_server_addban <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local name = ::VSLib.EasyLogic.GetEventString(params, "name");
	local ipAddress = ::VSLib.EasyLogic.GetEventString(params, "ip");
	local steamID = ::VSLib.EasyLogic.GetEventString(params, "networkid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnServerAddBan)
		func(ents.entity, name, ipAddress, steamID, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_server_removeban <- function (params)
{
	local ipAddress = ::VSLib.EasyLogic.GetEventString(params, "ip");
	local steamID = ::VSLib.EasyLogic.GetEventString(params, "networkid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnServerRemoveBan)
		func(ipAddress, steamID, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_server_pre_shutdown <- function (params)
{
	local reason = ::VSLib.EasyLogic.GetEventString(params, "reason");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnServerPreShutdown)
		func(reason, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_server_shutdown <- function (params)
{
	local reason = ::VSLib.EasyLogic.GetEventString(params, "reason");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnServerShutdown)
		func(reason, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_triggered_car_alarm <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnTriggeredCarAlarm)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_panic_event_finished <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnPanicEventFinished)
		func();
}

::VSLib.EasyLogic.Events.OnGameEvent_start_score_animation <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnStartScoreAnimation)
		func();
}

::VSLib.EasyLogic.Events.OnGameEvent_break_prop <- function (params)
{
	local userid = ::VSLib.EasyLogic.GetEventInt(params, "userid");
	local attacker = null;
	if ( userid != 0 )
		attacker = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local prop = ::VSLib.EasyLogic.GetEventEntity(params, "entindex");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnBrokeProp)
		func(attacker, prop, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_break_breakable <- function (params)
{
	local userid = ::VSLib.EasyLogic.GetEventInt(params, "userid");
	local attacker = null;
	if ( userid != 0 )
		attacker = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local breakable = ::VSLib.EasyLogic.GetEventEntity(params, "entindex");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnBrokeBreakable)
		func(attacker, breakable, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_entity_killed <- function (params)
{
	local attackerid = ::VSLib.EasyLogic.GetEventInt(params, "entindex_attacker");
	local attacker = null;
	if ( attackerid != 0 )
	{
		attacker = ::VSLib.EasyLogic.GetEventEntity(params, "entindex_attacker");
		if ( attacker.IsPlayer() )
			attacker = ::VSLib.EasyLogic.GetEventPlayer(params, "entindex_attacker");
	}
	local inflictorid = ::VSLib.EasyLogic.GetEventInt(params, "entindex_inflictor");
	local inflictor = null;
	if ( inflictorid != 0 )
	{
		inflictor = ::VSLib.EasyLogic.GetEventEntity(params, "entindex_inflictor");
		if ( inflictor.IsPlayer() )
			inflictor = ::VSLib.EasyLogic.GetEventPlayer(params, "entindex_inflictor");
	}
	local entity = ::VSLib.EasyLogic.GetEventEntity(params, "entindex_killed");
	local damagetype = ::VSLib.EasyLogic.GetEventInt(params, "damagebits");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnPlayerKilled)
		func(entity, attacker, inflictor, damagetype, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_entity_visible <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnEntityVisible)
		func(ents.entity, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_weapon_spawn_visible <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnWeaponSpawnVisible)
		func(ents.entity, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_dead_survivor_visible <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local subject = ::VSLib.EasyLogic.GetEventPlayer(params, "subject");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnDeadSurvivorVisible)
		func(ents.entity, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_spawner_give_item <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local spawner = ::VSLib.EasyLogic.GetEventEntity(params, "spawner");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnSpawnerGaveItem)
		func(ents.entity, spawner, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_mounted_gun_start <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);
	local subject = ::VSLib.EasyLogic.GetEventPlayer(params, "subject");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnMountedGunUsed)
		func(ents.entity, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_mounted_gun_overheated <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnMountedGunOverheated)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_grenade_bounce <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnPipeBombBounced)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_hegrenade_detonate <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnPipeBombDetonated)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_non_pistol_fired <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnNonPistolFired)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_total_ammo_below_40 <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnTotalAmmoBelow40)
		func(player, params);
}


::VSLib.EasyLogic.Events.OnGameEvent_punched_clown <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnPunchedClown)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_infected_decapitated <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local weapon = ::VSLib.EasyLogic.GetEventString(params, "weapon");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnInfectedDecapitated)
		func(player, weapon, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_non_melee_fired <- function (params)
{
	local ents = ::VSLib.EasyLogic.GetPlayersFromEvent(params);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnNonMeleeFired)
		func(ents.entity, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_molotov_thrown <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnMolotovThrown)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_gas_can_forced_drop <- function (params)
{
	local attacker = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local victim = ::VSLib.EasyLogic.GetEventPlayer(params, "victim");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnForcedGasCanDrop)
		func(attacker, victim, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_strongman_bell_knocked_off <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnStrongmanBellKnockedOff)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_stashwhacker_game_won <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnStashwhackerGameWon)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_charger_killed <- function (params)
{
	local charger = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local attackerid = ::VSLib.EasyLogic.GetEventInt(params, "attacker");
	local attacker = null;
	if (attackerid != 0)
		attacker = ::VSLib.EasyLogic.GetEventPlayer(params, "attacker");
	local melee = ::VSLib.EasyLogic.GetEventInt(params, "melee");
	local charging = ::VSLib.EasyLogic.GetEventInt(params, "charging");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnChargerKilled)
		func(charger, attacker, (melee > 0) ? true : false, (charging > 0) ? true : false, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_spitter_killed <- function (params)
{
	local spitter = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local attackerid = ::VSLib.EasyLogic.GetEventInt(params, "attacker");
	local attacker = null;
	if (attackerid != 0)
		attacker = ::VSLib.EasyLogic.GetEventPlayer(params, "attacker");
	local has_spit = ::VSLib.EasyLogic.GetEventInt(params, "has_spit");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnSpitterKilled)
		func(spitter, attacker, (has_spit > 0) ? true : false, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_jockey_killed <- function (params)
{
	local jockey = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local attackerid = ::VSLib.EasyLogic.GetEventInt(params, "attacker");
	local attacker = null;
	if (attackerid != 0)
		attacker = ::VSLib.EasyLogic.GetEventPlayer(params, "attacker");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnJockeyKilled)
		func(jockey, attacker, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_vomit_bomb_tank <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnVomitBombTank)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_upgrade_pack_added <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");
	local upgrade = ::VSLib.EasyLogic.GetEventEntity(params, "upgradeid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnUpgradePackAdded)
		func(player, upgrade, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_charger_charge_end <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnChargerChargeEnd)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_chair_charged <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnChairCharged)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_m60_streak_ended <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnM60StreakEnded)
		func();
}

::VSLib.EasyLogic.Events.OnGameEvent_song_played <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnSongPlayed)
		func();
}

::VSLib.EasyLogic.Events.OnGameEvent_christmas_gift_grab <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnChristmasGiftGrab)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_golden_crowbar_pickup <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnGoldenCrowbarPickup)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_left_concert_stage <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnLeftConcertStage)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_player_left_safe_area <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	if ( !player.IsInStartArea() )
	{
		foreach (func in ::VSLib.EasyLogic.Notifications.OnSurvivorsLeftStartArea)
			func();
	}
	else
		::VSLib.Timers.AddTimerByName("VSLib_LeftStartCheck", 0.1, true, VSLib_LeftStartCheck);

	foreach (func in ::VSLib.EasyLogic.Notifications.OnLeaveSafeArea)
		func(player, params);
}



::VSLib.EasyLogic.Events.OnGameEvent_hltv_status <- function (params)
{
	local clients = ::VSLib.EasyLogic.GetEventInt(params, "clients");
	local slots = ::VSLib.EasyLogic.GetEventInt(params, "slots");
	local proxies = ::VSLib.EasyLogic.GetEventInt(params, "proxies");
	local master = ::VSLib.EasyLogic.GetEventString(params, "master");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnSourceTVStatus)
		func(clients, slots, proxies, master, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_hltv_rank_entity <- function (params)
{
	local entity = ::VSLib.EasyLogic.GetEventEntity(params, "index");
	if ( entity.IsPlayer() )
		entity = ::VSLib.EasyLogic.GetEventPlayer(params, "index");

	local rank = ::VSLib.EasyLogic.GetEventFloat(params, "rank");
	local target = ::VSLib.EasyLogic.GetEventInt(params, "target");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnSourceTVRankEntity)
		func(entity, rank, target, params);
}




::VSLib.EasyLogic.Events.OnGameEvent_explain_survivor_glows_disabled <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainSurvivorGlowsDisabled)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_item_glows_disabled <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainItemGlowsDisabled)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_rescue_disabled <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainRescueDisabled)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_bodyshots_reduced <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainBodyshotsReduced)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_witch_instant_kill <- function (params)
{
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainWitchInstantKill)
		func(player, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_need_gnome_to_continue <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainNeedGnomeToContinue)
		func();
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_pills <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainPills)
		func(subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_weapons <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainWeapons)
		func(subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_pre_radio <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainPreRadio)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_radio <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainRadio)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_gas_truck <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainGasTruck)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_panic_button <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainPanicButton)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_elevator_button <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainElevatorButton)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_lift_button <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainLiftButton)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_church_door <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainChurchDoor)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_emergency_door <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainEmergencyDoor)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_crane <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainCrane)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_bridge <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainBridge)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_gas_can_panic <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainGasCanPanic)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_van_panic <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainVanPanic)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_mainstreet <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainMainstreet)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_train_lever <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainTrainLever)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_disturbance <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainDisturbance)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_scavenge_goal <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainScavengeGoal)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_scavenge_leave_area <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainScavengeLeaveArea)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_pre_drawbridge <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainPreDrawbridge)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_drawbridge <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainDrawbridge)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_perimeter <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainPerimeter)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_deactivate_alarm <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainDeactivateAlarm)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_impound_lot <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainImpoundLot)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_decon <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainDecon)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_decon_wait <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainDeconWait)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_mall_window <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainMallWindow)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_mall_alarm <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainMallAlarm)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_coaster <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainCoaster)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_coaster_stop <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainCoasterStop)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_float <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainFloat)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_ferry_button <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainFerryButton)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_hatch_button <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainHatchButton)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_shack_button <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainShackButton)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_vehicle_arrival <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainVehicleArrival)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_burger_sign <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainBurgerSign)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_carousel_button <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainCarouselButton)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_carousel_destination <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainCarouselDestination)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_stage_lighting <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainStageLighting)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_stage_finale_start <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainStageFinaleStart)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_stage_survival_start <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainStageSurvivalStart)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_stage_pyrotechnics <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainStagePyrotechnics)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_c3m4_radio1 <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainC3M4Radio1)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_c3m4_radio2 <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainC3M4Radio2)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_gates_are_open <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainGatesAreOpen)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_c2m4_ticketbooth <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainC2M4Ticketbooth)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_c3m4_rescue <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainC3M4Rescue)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_hotel_elevator_doors <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainHotelElevatorDoors)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_gun_shop_tanker <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainGunShopTanker)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_gun_shop <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainGunShop)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_store_alarm <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainStoreAlarm)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_store_item <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainStoreItem)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_store_item_stop <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainStoreItemStop)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_survival_generic <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainSurvivalGeneric)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_survival_alarm <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainSurvivalAlarm)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_survival_radio <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainSurvivalRadio)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_survival_carousel <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainSurvivalCarousel)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_return_item <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainReturnItem)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_save_items <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainSaveItems)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_temp_c4m1_getgas <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainC4M1GetGas)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_temp_c4m3_return_to_boat <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainC4M3ReturnToBoat)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_c1m4_finale <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainC1M4Finale)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_c1m4_scavenge_instructions <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainC1M4ScavengeInstructions)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_sewer_gate <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainSewerGate)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_sewer_run <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainSewerRun)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_c6m3_finale <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainC6M3Finale)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_finale_bridge_lowering <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainFinaleBridgeLowering)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_train_boss <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainTrainBoss)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_train_exit <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainTrainExit)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_freighter <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainFreighter)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_highrise_finale2 <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainHighriseFinale2)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_start_generator <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainStartGenerator)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_restart_generator <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainRestartGenerator)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_bridge_button <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainBridgeButton)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_DLC3howitzer <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainDLC3Howitzer)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_DLC3generator_button <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainDLC3GeneratorButton)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_DLC3lift_lever <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainDLC3LiftLever)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_DLC3barrels <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainDLC3Barrels)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_DLC3radio <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainDLC3Radio)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_DLC3door <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainDLC3Door)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_onslaught <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainOnslaught)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_lighthouse_gate <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainLighthouseGate)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_lighthouse_generator <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainLighthouseGenerator)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_lighthouse_gen_button <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainLighthouseGenButton)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_lighthouse_finale_event <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainLighthouseFinaleEvent)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_lighthouse_restart_gen <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainLighthouseRestartGen)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_lighthouse_gas <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainLighthouseGas)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_lighthouse_finale <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainLighthouseFinale)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_junkyard_fuel <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainJunkyardFuel)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_container_drop <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainContainerDrop)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnGameEvent_explain_container_ready <- function (params)
{
	local subject = ::VSLib.EasyLogic.GetEventEntity(params, "subject");
	local player = ::VSLib.EasyLogic.GetEventPlayer(params, "userid");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnExplainContainerReady)
		func(player, subject, params);
}

::VSLib.EasyLogic.Events.OnScriptEvent_start_holdout <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnHoldoutStart)
		func(params);
}

::VSLib.EasyLogic.Events.OnScriptEvent_on_resources_changed <- function (params)
{
	local newcount = ::VSLib.EasyLogic.GetEventInt(params, "newcount");

	foreach (func in ::VSLib.EasyLogic.Notifications.OnResourcesChanged)
		func(newcount, params);
}

::VSLib.EasyLogic.Events.OnScriptEvent_on_helicopter_begin <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnHelicopterBegin)
		func(params);
}

::VSLib.EasyLogic.Events.OnScriptEvent_on_helicopter_end <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnHelicopterEnd)
		func(params);
}

::VSLib.EasyLogic.Events.OnScriptEvent_on_cooldown_begin <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnCooldownBegin)
		func(params);
}

::VSLib.EasyLogic.Events.OnScriptEvent_on_cooldown_end <- function (params)
{
	foreach (func in ::VSLib.EasyLogic.Notifications.OnCooldownEnd)
		func(params);
}

__CollectEventCallbacks(::VSLib.EasyLogic.Events, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);
__CollectEventCallbacks(::VSLib.EasyLogic.Events, "OnScriptEvent_", "ScriptEventCallbacks", RegisterScriptGameEventListener);

//
//  END OF NOTIFICATION EVENTS.
//
//	Below are wrapper functions for notifications.
//

/**
 * Returns an integer value for the specified field, or null if it does not exist.
 */
function VSLib::EasyLogic::GetEventInt(params, field)
{
	if (field in params)
		if (params[field] != "" && params[field] != null)
			return params[field].tointeger();

	return null;
}

/**
 * Returns an Entity for the specified field (Entity index), or null if it does not exist.
 */
function VSLib::EasyLogic::GetEventEntity(params, field)
{
	if (field in params)
		if (params[field] != "" && params[field] != null)
			return ::VSLib.Entity(params[field].tointeger());

	return null;
}

/**
 * Returns a float value for the specified field, or null if it does not exist.
 */
function VSLib::EasyLogic::GetEventFloat(params, field)
{
	if (field in params)
		if (params[field] != "" && params[field] != null)
			return params[field].tofloat();

	return null;
}

/**
 * Returns a string value for the specified field, or null if it does not exist.
 */
function VSLib::EasyLogic::GetEventString(params, field)
{
	if (field in params)
		if (params[field] != "" && params[field] != null)
			return params[field].tostring();

	return null;
}

/**
 * Returns a player for the specified field, or null if it does not exist.
 */
function VSLib::EasyLogic::GetEventPlayer(params, field)
{
	if (field in params)
	{
		if (params[field] != "" && params[field] != null)
		{
			local ent = GetPlayerFromUserID(params[field]);
			if (!ent)
				ent = ::VSLib.Player(params[field].tointeger());
			else
				ent = ::VSLib.Player(ent);

			return ent;
		}
	}

	return null;
}

/**
 * This function returns the ::VSLib.Entity vars of the game event.
 * It sorts through "entity" and "userid" as well as attackers.
 * It will return a table of { entity, attacker }, and the value
 * will be null if it does not exist.
 */
function VSLib::EasyLogic::GetPlayersFromEvent(params)
{
	local ent = null;
	local atk = null;

	if ("userid" in params)
	{
		if (params["userid"] != null && params["userid"] != "")
			ent = GetPlayerFromUserID(params["userid"]);
	}
	else if ("entityid" in params)
	{
		if (params["entityid"] != null && params["entityid"] != "")
			ent = EntIndexToHScript(params["entityid"]);
	}

	if ("attacker" in params)
	{
		if (params["attacker"] != null && params["attacker"] != "")
		{
			if (params["attacker"] != 0)
				atk = GetPlayerFromUserID(params["attacker"]);
			else
			{
				if ("attackerentid" in params)
				{
					if (params["attackerentid"] != null && params["attackerentid"] != "")
						atk = EntIndexToHScript(params["attackerentid"]);
				}
			}
		}
	}
	else if ("attackerentid" in params)
	{
		if (params["attackerentid"] != null && params["attackerentid"] != "")
			atk = EntIndexToHScript(params["attackerentid"]);
	}

	if (ent)
	{
		if (ent.IsPlayer())
			ent = ::VSLib.Player(ent);
		else
			ent = ::VSLib.Entity(ent);
	}

	if (atk)
	{
		if (atk.IsPlayer())
			atk = ::VSLib.Player(atk);
		else
			atk = ::VSLib.Entity(atk);
	}

	return { entity = ent, attacker = atk };
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Below is the part of EasyLogic that incorporates SourceMod/HammerCode-like
//	chat triggers. For example, typing "!hello" into a chatbox can execute a function
//	that you want.
/////////////////////////////////////////////////////////////////////////////////////////////////////////////


/**
 * Adds a chat trigger.
 * For example, AddChatTrigger("test", someFunc) will cause someFunc() to fire when a player
 * types !test into their chatbox.
 */
function VSLib::EasyLogic::AddChatTrigger(trigger_text, func)
{
	local trigger = ::VSLib.EasyLogic._triggerStart + trigger_text;

	// do not double up on triggers
	foreach (idx, v in _itChatTextIndex)
	{
		if (v == trigger_text)
			delete _itChatTextIndex[idx];
	}

	_itChatTextIndex[_itChatCount] <- trigger;
	_itChatFunction[_itChatCount] <- func;

	_itChatCount++;
}

/**
 * Removes a chat trigger.
 */
function VSLib::EasyLogic::RemoveChatTrigger(trigger_text)
{
	local trigger = ::VSLib.EasyLogic._triggerStart + trigger_text;

	foreach (i, v in _itChatTextIndex)
	{
		if (v == trigger)
		{
			_itChatFunction[i] <- null;
			_itChatTextIndex[i] <- null;

			break;
		}
	}
}

/**
 * Changes the chat trigger starting text (e.g. the exclamation point).
 * Note that any triggers added before changing the starting text are
 * invalidated.
 */
function VSLib::EasyLogic::ChangeChatTriggerStartText(start_text)
{
	::VSLib.EasyLogic._triggerStart = start_text;
}

/**
 * Changes the chat trigger hiding text (e.g. the forward slash).
 */
function VSLib::EasyLogic::ChangeChatTriggerStartText(hide_text)
{
	::VSLib.EasyLogic._triggerHide = hide_text;
}

/**
 * Adds an InterceptChat() callback (in case you don't want to use the chat trigger feature).
 */
function VSLib::EasyLogic::AddInterceptChat(func)
{
	foreach (v in _interceptList)
	{
		if (v == func)
			return;
	}

	_interceptList[_interceptCount] <- func;
	_interceptCount++;
}

/**
 * Removes an InterceptChat() callback.
 */
function VSLib::EasyLogic::RemoveInterceptChat(func)
{
	foreach(i, v in _interceptList)
	{
		if (v == func)
		{
			_interceptList[i] <- null;
			break;
		}
	}
}

/**
 * Valve forward: Used by EasyLogic to implement chat triggers
 */
if (!("InterceptChat" in getroottable()))
{
	::InterceptChat <- function (str, srcEnt)
	{
		local hideText = false;

		if (srcEnt != null)
		{
			// Strip the name from the chat text
			local name = srcEnt.GetPlayerName() + ": ";
			local text = strip(str.slice(str.find(name) + name.len()));

			local startTrigger = ( text.find(::VSLib.EasyLogic._triggerStart) == 0 );
			local hideTrigger = ( text.find(::VSLib.EasyLogic._triggerHide) == 0 );
			if (startTrigger || hideTrigger)
			{
				// Separate the commands and arguments
				local arr = split(text, " ");

				// Identify the command
				local cmd = arr[0];

				// Build an argument array
				local args = {};
				local idx = 0;
				foreach (k, v in arr)
				{
					if (k != 0 && v != null && v != "")
					{
						args[idx] <- v;
						idx++;
					}
				}

				// Store it.
				::VSLib.EasyLogic.LastArgs <- args;

				local player = ::VSLib.Player(srcEnt);

				// Execute the permanent triggers
				local baseCmd = "";
				if (startTrigger)
					baseCmd = split(cmd, ::VSLib.EasyLogic._triggerStart);
				else if (hideTrigger)
					baseCmd = split(cmd, ::VSLib.EasyLogic._triggerHide);
				if (0 in baseCmd)
				{
					if (baseCmd[0] in ::VSLib.EasyLogic.Triggers)
					{
						::VSLib.EasyLogic.Triggers[baseCmd[0]](player, args, text);
						if (hideTrigger)
							hideText = true;
					}
					else if (baseCmd[0].tolower() in ::VSLib.EasyLogic.Triggers)
					{
						::VSLib.EasyLogic.Triggers[baseCmd[0].tolower()](player, args, text);
						if (hideTrigger)
							hideText = true;
					}
				}

				// Execute the removable trigger (if it is a trigger).
				foreach (i, trigger in ::VSLib.EasyLogic._itChatTextIndex)
				{
					if (trigger == cmd || trigger.tolower() == cmd.tolower())
					{
						::VSLib.EasyLogic._itChatFunction[i](player, args, text);
						if (hideTrigger)
							hideText = true;
						break;
					}
				}
			}
		}

		local player = null;
		local text = "";

		if (srcEnt != null)
		{
			local name = srcEnt.GetPlayerName() + ": ";
			text = strip(str.slice(str.find(name) + name.len()));
			player = ::VSLib.Player(srcEnt);
		}
		else
		{
			if ( str.find("Console:") != null )
			{
				local name = "Console: ";
				text = strip(str.slice(str.find(name) + name.len()));
			}
			else
				text = str;
		}

		// Fire any intercept hooks
		foreach(v in ::VSLib.EasyLogic._interceptList)
		{
			if (v != null)
				v(str, srcEnt);
		}
		foreach(v in ::VSLib.EasyLogic.OnInterceptChat)
		{
			if (v != null)
			{
				if (v(text, player) == false)
					return false;
			}
		}

		if ( "ModeInterceptChat" in g_ModeScript )
		{
			if ( ModeInterceptChat(str, player) == false )
				return false;
		}
		if ( "MapInterceptChat" in g_ModeScript )
		{
			if ( MapInterceptChat(str, player) == false )
				return false;
		}

		if ( hideText )
			return false;
	}
}

if ( ("InterceptChat" in g_ModeScript) && (g_ModeScript.InterceptChat != getroottable().InterceptChat) )
{
	g_ModeScript.ModeInterceptChat <- g_ModeScript.InterceptChat;
	g_ModeScript.InterceptChat <- getroottable().InterceptChat;
}
else if ( ("InterceptChat" in g_MapScript) && (g_MapScript.InterceptChat != getroottable().InterceptChat) )
{
	g_ModeScript.MapInterceptChat <- g_MapScript.InterceptChat;
	g_ModeScript.InterceptChat <- getroottable().InterceptChat;
}
else
{
	g_ModeScript.InterceptChat <- getroottable().InterceptChat;
}

/**
 * Retrieves an argument or returns null if the argument is not specified.
 * Note that you can reference the arguments array directly if you need to.
 */
function VSLib::EasyLogic::GetArgument(idx)
{
	if (!(idx-1 in ::VSLib.EasyLogic.LastArgs))
		return null;

	return ::VSLib.EasyLogic.LastArgs[idx-1];
}



//
//	Below is the UserConsoleCommand() function.
//



/**
 * Lets you send commands by using scripted_user_func in console
 */
if (!("UserConsoleCommand" in getroottable()))
{
	::UserConsoleCommand <- function (playerScript, arg)
	{
		// Separate the commands and arguments
		local arr = split(arg, ",");

		// Build an argument array
		local args = {};
		local idx = -1;
		foreach (k, v in arr)
		{
			if (k != -1 && v != null && v != "")
			{
				args[idx] <- v;
				idx++;
			}
		}

		// Store it.
		::VSLib.EasyLogic.LastArgs <- args;

		local argArray = clone args;
		argArray.rawdelete(-1);

		local player = ::VSLib.Player(playerScript);

		foreach(v in ::VSLib.EasyLogic.OnUserCommand)
		{
			if (v != null)
				v(player, argArray, arg);
		}

		if ( "ModeUserConsoleCommand" in g_ModeScript )
			ModeUserConsoleCommand(playerScript, arg);
		if ( "MapUserConsoleCommand" in g_ModeScript )
			MapUserConsoleCommand(playerScript, arg);
	}
}

if ( ("UserConsoleCommand" in g_ModeScript) && (g_ModeScript.UserConsoleCommand != getroottable().UserConsoleCommand) )
{
	g_ModeScript.ModeUserConsoleCommand <- g_ModeScript.UserConsoleCommand;
	g_ModeScript.UserConsoleCommand <- getroottable().UserConsoleCommand;
}
else if ( ("UserConsoleCommand" in g_MapScript) && (g_MapScript.UserConsoleCommand != getroottable().UserConsoleCommand) )
{
	g_ModeScript.MapUserConsoleCommand <- g_MapScript.UserConsoleCommand;
	g_ModeScript.UserConsoleCommand <- getroottable().UserConsoleCommand;
}
else
{
	g_ModeScript.UserConsoleCommand <- getroottable().UserConsoleCommand;
}




//////////////////////////////////////////////////////////////////////////////////////////
// Player helpers
//////////////////////////////////////////////////////////////////////////////////////////


/**
 * Returns a table of all bots.
 */
function VSLib::EasyLogic::Players::Bots()
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByClassname(ent, "player"))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Player(ent);
			if (libObj.IsBot())
				t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns a table of all survivor bots.
 */
function VSLib::EasyLogic::Players::SurvivorBots()
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByClassname(ent, "player"))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Player(ent);
			if (libObj.IsBot() && libObj.GetTeam() == SURVIVORS)
				t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns a table of all alive survivor bots.
 */
function VSLib::EasyLogic::Players::AliveSurvivorBots()
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByClassname(ent, "player"))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Player(ent);
			if (libObj.IsBot() && libObj.GetTeam() == SURVIVORS && libObj.IsAlive())
				t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns a table of all incapacitated survivor bots.
 */
function VSLib::EasyLogic::Players::IncapacitatedSurvivorBots()
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByClassname(ent, "player"))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Player(ent);
			if (libObj.IsBot() && libObj.GetTeam() == SURVIVORS && libObj.IsIncapacitated())
				t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns a table of all dead survivor bots.
 */
function VSLib::EasyLogic::Players::DeadSurvivorBots()
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByClassname(ent, "player"))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Player(ent);
			if (libObj.IsBot() && libObj.GetTeam() == SURVIVORS && !libObj.IsAlive())
				t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns a table of all infected bots.
 */
function VSLib::EasyLogic::Players::InfectedBots()
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByClassname(ent, "player"))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Player(ent);
			if (libObj.IsBot() && libObj.GetTeam() == INFECTED)
				t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns a table of all players.
 */
function VSLib::EasyLogic::Players::All()
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByClassname(ent, "player"))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Player(ent);
			t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns a table of all spectators.
 */
function VSLib::EasyLogic::Players::Spectators()
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByClassname(ent, "player"))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Player(ent);
			if (libObj.GetTeam() == SPECTATORS)
				t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns a table of all special infected.
 */
function VSLib::EasyLogic::Players::Infected()
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByClassname(ent, "player"))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Player(ent);
			if (libObj.GetTeam() == INFECTED)
				t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns a table of all playable survivors.
 */
function VSLib::EasyLogic::Players::Survivors()
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByClassname(ent, "player"))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Player(ent);
			if (libObj.GetTeam() == SURVIVORS)
				t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns a table of all alive survivors.
 */
function VSLib::EasyLogic::Players::AliveSurvivors()
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByClassname(ent, "player"))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Player(ent);
			if (libObj.GetTeam() == SURVIVORS && libObj.IsAlive())
				t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns a table of all incapacitated survivors.
 */
function VSLib::EasyLogic::Players::IncapacitatedSurvivors()
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByClassname(ent, "player"))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Player(ent);
			if (libObj.GetTeam() == SURVIVORS && libObj.IsIncapacitated())
				t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns a table of all dead survivors.
 */
function VSLib::EasyLogic::Players::DeadSurvivors()
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByClassname(ent, "player"))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Player(ent);
			if (libObj.GetTeam() == SURVIVORS && !libObj.IsAlive())
				t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns one valid survivor, or null if none exist
 */
function VSLib::EasyLogic::Players::AnySurvivor()
{
	local ent = null;
	while (ent = Entities.FindByClassname(ent, "player"))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Player(ent);
			if (libObj.GetTeam() == SURVIVORS)
				return libObj;
		}
	}

	return null;
}

/**
 * Returns one valid alive survivor, or null if none exist
 */
function VSLib::EasyLogic::Players::AnyAliveSurvivor()
{
	local ent = null;
	while (ent = Entities.FindByClassname(ent, "player"))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Player(ent);
			if (libObj.GetTeam() == SURVIVORS && libObj.IsAlive())
				return libObj;
		}
	}

	return null;
}

/**
 * Returns one valid incapacitated survivor, or null if none exist
 */
function VSLib::EasyLogic::Players::AnyIncapacitatedSurvivor()
{
	local ent = null;
	while (ent = Entities.FindByClassname(ent, "player"))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Player(ent);
			if (libObj.GetTeam() == SURVIVORS && libObj.IsIncapacitated())
				return libObj;
		}
	}

	return null;
}

/**
 * Returns one valid alive survivor, or null if none exist
 */
function VSLib::EasyLogic::Players::AnyDeadSurvivor()
{
	local ent = null;
	while (ent = Entities.FindByClassname(ent, "player"))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Player(ent);
			if (libObj.GetTeam() == SURVIVORS && !libObj.IsAlive())
				return libObj;
		}
	}

	return null;
}

/**
 * Returns one RANDOM valid alive survivor, or null if none exist
 */
function VSLib::EasyLogic::Players::RandomAliveSurvivor()
{
	return ::VSLib.Utils.GetRandValueFromArray(Players.AliveSurvivors());
}

/**
 * Returns one RANDOM valid incapacitated survivor, or null if none exist
 */
function VSLib::EasyLogic::Players::RandomIncapacitatedSurvivor()
{
	return ::VSLib.Utils.GetRandValueFromArray(Players.IncapacitatedSurvivors());
}

/**
 * Returns one RANDOM valid dead survivor, or null if none exist
 */
function VSLib::EasyLogic::Players::RandomDeadSurvivor()
{
	return ::VSLib.Utils.GetRandValueFromArray(Players.DeadSurvivors());
}

/**
 * Returns one valid alive survivor with the highest flow distance, or null if none exist
 */
function VSLib::EasyLogic::Players::SurvivorWithHighestFlow()
{
	local player = null;
	local flow = -1;
	local ent = null;
	while (ent = Entities.FindByClassname(ent, "player"))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Player(ent);
			if (libObj.GetTeam() == SURVIVORS && libObj.IsAlive())
			{
				local dist = libObj.GetFlowDistance();
				if (dist > flow)
				{
					player = libObj;
					flow = dist;
				}
			}
		}
	}

	return player;
}

/**
 * Returns a table of all human players.
 */
function VSLib::EasyLogic::Players::Humans()
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByClassname(ent, "player"))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Player(ent);
			if (!libObj.IsBot())
				t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns a table of all infected of a specific type.
 */
function VSLib::EasyLogic::Players::OfType(playerType)
{
	playerType = playerType.tointeger();
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByClassname(ent, "player"))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Player(ent);
			if (libObj.GetPlayerType() == playerType)
				t[++i] <- libObj;
		}
	}

	return t;
}


/**
 * Returns a table of all L4D1 and L4D2 survivors.
 */
function VSLib::EasyLogic::Players::AllSurvivors()
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByClassname(ent, "player"))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Player(ent);
			if (libObj.IsSurvivor())
				t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns a table of L4D1 survivors.
 */
function VSLib::EasyLogic::Players::L4D1Survivors()
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByClassname(ent, "player"))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Player(ent);
			if (libObj.GetTeam() == L4D1_SURVIVORS)
				t[++i] <- libObj;
		}
	}

	return t;
}


/**
 * Returns a table of all common infected.
 */
function VSLib::EasyLogic::Zombies::CommonInfected()
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByClassname(ent, "infected"))
	{
		if (ent.IsValid())
			t[++i] <- ::VSLib.Entity(ent);
	}

	return t;
}

/**
 * Returns a table of all uncommon infected.
 */
function VSLib::EasyLogic::Zombies::UncommonInfected()
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByClassname(ent, "infected"))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Entity(ent);
			if (libObj.IsUncommonInfected())
				t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns a table of all common infected of a specific gender.
 */
function VSLib::EasyLogic::Zombies::OfGender(gender)
{
	gender = gender.tointeger();
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByClassname(ent, "infected"))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Entity(ent);
			if (libObj.GetGender() == gender)
				t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns a table of all witches.
 */
function VSLib::EasyLogic::Zombies::Witches()
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByClassname(ent, "witch"))
	{
		if (ent.IsValid())
			t[++i] <- ::VSLib.Entity(ent);
	}

	return t;
}

/**
 * Returns a table of all infected.
 */
function VSLib::EasyLogic::Zombies::All()
{
	local t = {};
	local i = -1;

	foreach( ent in ::VSLib.EasyLogic.Players.Infected() )
		t[i++] <- ent;
	foreach( ent in ::VSLib.EasyLogic.Zombies.CommonInfected() )
		t[i++] <- ent;
	foreach( ent in ::VSLib.EasyLogic.Zombies.Witches() )
		t[i++] <- ent;

	return t;
}


/**
 * Returns all entities of a specific classname.
 *
 * E.g. foreach ( object in Objects.OfClassname("prop_physics") ) ...
 */
function VSLib::EasyLogic::Objects::OfClassname(classname)
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByClassname(ent, classname))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Utils.GetEntityOrPlayer(ent);
			t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns all entities of a specific classname nearest to the specified point.
 */
function VSLib::EasyLogic::Objects::OfClassnameNearest(classname, origin, radius)
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByClassnameNearest(classname, origin, radius))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Utils.GetEntityOrPlayer(ent);
			t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns all entities of a specific classname within a radius.
 *
 * E.g. foreach ( object in Objects.OfClassnameWithin("prop_physics", Vector(0,0,0), 10) ) ...
 */
function VSLib::EasyLogic::Objects::OfClassnameWithin(classname, origin, radius)
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByClassnameWithin(ent, classname, origin, radius))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Utils.GetEntityOrPlayer(ent);
			t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns a single entity of the specified classname, or null if non-existent
 */
function VSLib::EasyLogic::Objects::AnyOfClassname(classname)
{
	local ent = null;
	while (ent = Entities.FindByClassname(ent, classname))
	{
		if (ent.IsValid())
		{
			return ::VSLib.Utils.GetEntityOrPlayer(ent);
		}
	}

	return null;
}

/**
 * Returns all entities of a specific targetname.
 */
function VSLib::EasyLogic::Objects::OfName(targetname)
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByName(ent, targetname))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Utils.GetEntityOrPlayer(ent);
			t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns all entities of a specific targetname nearest to a point.
 */
function VSLib::EasyLogic::Objects::OfNameNearest(targetname, origin, radius)
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByNameNearest(targetname, origin, radius))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Utils.GetEntityOrPlayer(ent);
			t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns all entities of a specific targetname within a radius.
 */
function VSLib::EasyLogic::Objects::OfNameWithin(targetname, origin, radius)
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByNameWithin(ent, targetname, origin, radius))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Utils.GetEntityOrPlayer(ent);
			t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns a single entity of the specified targetname, or null if non-existent
 */
function VSLib::EasyLogic::Objects::AnyOfName(targetname)
{
	local ent = null;
	while (ent = Entities.FindByName(ent, targetname))
	{
		if (ent.IsValid())
		{
			return ::VSLib.Utils.GetEntityOrPlayer(ent);
		}
	}

	return null;
}

/**
 * Returns all entities of a particular model.
 */
function VSLib::EasyLogic::Objects::OfModel(model)
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByModel(ent, model))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Utils.GetEntityOrPlayer(ent);
			t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns all entities of a particular model nearest to a point.
 */
function VSLib::EasyLogic::Objects::OfModelNearest(model, origin, radius)
{
	local t = {};
	local ent = null;
	local mdl = null;
	local i = -1;
	while (mdl = Entities.FindByModel(mdl, model))
	{
		if (mdl.IsValid())
		{
			while ( ent = Entities.FindByClassnameNearest(ent, mdl.GetClassname(), origin, radius) )
			{
				if ( ent.GetEntityHandle() == mdl.GetEntityHandle() )
				{
					local libObj = ::VSLib.Utils.GetEntityOrPlayer(ent);
					t[++i] <- libObj;
				}
			}
		}
	}

	return t;
}

/**
 * Returns all entities of a particular model within a radius.
 */
function VSLib::EasyLogic::Objects::OfModelWithin(model, origin, radius)
{
	local t = {};
	local ent = null;
	local mdl = null;
	local i = -1;
	while (mdl = Entities.FindByModel(mdl, model))
	{
		if (mdl.IsValid())
		{
			while ( ent = Entities.FindByClassnameWithin(ent, mdl.GetClassname(), origin, radius) )
			{
				if ( ent.GetEntityHandle() == mdl.GetEntityHandle() )
				{
					local libObj = ::VSLib.Utils.GetEntityOrPlayer(ent);
					t[++i] <- libObj;
				}
			}
		}
	}

	return t;
}

/**
 * Returns a single entity of the specified model, or null if non-existent
 */
function VSLib::EasyLogic::Objects::AnyOfModel(model)
{
	local ent = null;
	while (ent = Entities.FindByModel(ent, model))
	{
		if (ent.IsValid())
		{
			return ::VSLib.Utils.GetEntityOrPlayer(ent);
		}
	}

	return null;
}

/**
 * Returns all entities by its target.
 */
function VSLib::EasyLogic::Objects::OfTarget(target)
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindByTarget(ent, target))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Utils.GetEntityOrPlayer(ent);
			t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns all entities around a radius.
 *
 * E.g. foreach ( object in Objects.AroundRadius(pos, radius) ) ...
 */
function VSLib::EasyLogic::Objects::AroundRadius(pos, radius)
{
	local t = {};
	local ent = null;
	local i = -1;
	while (ent = Entities.FindInSphere(ent, pos, radius))
	{
		if (ent.IsValid())
		{
			local libObj = ::VSLib.Utils.GetEntityOrPlayer(ent);
			t[++i] <- libObj;
		}
	}

	return t;
}

/**
 * Returns all infected/survivors (including commons) around specified position and radius.
 * If you need to find infected/survivors around a PLAYER instead, just pass in the player's
 * position with player.GetLocation()
 */
function VSLib::EasyLogic::Objects::AliveAroundRadius(pos, radius)
{
	local t = AroundRadius(pos, radius);

	foreach (idx, ent in t)
		if (ent.GetClassname() != "player" && ent.GetClassname() != "infected")
			delete t[idx];
		else if (::VSLib.Player(ent).IsDead()) // tag on a branched if statement
			delete t[idx];

	return t;
}

/**
 * Returns a table of all mounted guns and miniguns.
 */
function VSLib::EasyLogic::Objects::MountedGuns()
{
	local t = {};
	local i = -1;

	foreach( ent in ::VSLib.EasyLogic.Objects.OfClassname("prop_minigun") )
		t[i++] <- ent;
	foreach( ent in ::VSLib.EasyLogic.Objects.OfClassname("prop_minigun_l4d1") )
		t[i++] <- ent;
	foreach( ent in ::VSLib.EasyLogic.Objects.OfClassname("prop_mounted_machine_gun") )
		t[i++] <- ent;

	return t;
}

/**
 * Returns a table of all entities.
 */
function VSLib::EasyLogic::Objects::All()
{
	local t = {};
	local i = -1;

	foreach( ent in ::VSLib.EasyLogic.Objects.OfClassname("*") )
		t[i++] <- ent;

	return t;
}








////////////////////////////////////////////////////////////////////////////////////////////////////////
// Update Hooks
////////////////////////////////////////////////////////////////////////////////////////////////////////

if (!("Update" in getroottable()))
{
	::Update <- function ()
	{
		foreach (update in ::VSLib.EasyLogic.Update)
			update();

		if ( "ModeUpdate" in g_ModeScript )
			ModeUpdate();
	}
}

if ( ("Update" in g_ModeScript) && (g_ModeScript.Update != getroottable().Update) )
{
	g_ModeScript.ModeUpdate <- g_ModeScript.Update;
	g_ModeScript.Update <- getroottable().Update;
}
else
{
	g_ModeScript.Update <- getroottable().Update;
}






// Lastly, we reference EasyLogic in the global table.
::EasyLogic <- ::VSLib.EasyLogic.weakref();
::GetArgument <- ::VSLib.EasyLogic.GetArgument.weakref();
::Vars <- ::VSLib.EasyLogic.UserDefinedVars.weakref();
::RoundVars <- ::VSLib.EasyLogic.RoundVars.weakref();
::SessionVars <- ::VSLib.EasyLogic.SessionVars.weakref();
::Notifications <- ::VSLib.EasyLogic.Notifications.weakref();
::ChatTriggers <- ::VSLib.EasyLogic.Triggers.weakref();
::Players <- ::VSLib.EasyLogic.Players.weakref();
::Zombies <- ::VSLib.EasyLogic.Zombies.weakref();
::Objects <- ::VSLib.EasyLogic.Objects.weakref();



// Set the delegates
foreach (row in ::VSLib.EasyLogic.Notifications)
	row.setdelegate(::g_MapScript);
foreach (row in ::VSLib.EasyLogic)
	if ("setdelegate" in row)
		row.setdelegate(::g_MapScript);