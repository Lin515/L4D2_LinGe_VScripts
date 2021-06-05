/*  
 * Copyright (c) 2013 Rayman1103 and Rectus
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
* Functions that VSLib uses for Valve's response rules hookup.
*/
::VSLib.ResponseRules <-
{
	// Hacked to get followups working (sorta) by Rectus
	
	// Bindings between expresser names and their targetnames.
	ExpTargetName =
	{
		Coach 		= "!coach",
		Gambler 	= "!nick",
		Mechanic 	= "!ellis",
		Producer	= "!rochelle",
		
		NamVet		= "!bill",
		TeenGirl	= "!zoey",
		Manager		= "!louis",
		Biker		= "!francis"
	}

	// Special snowflake database for responses, since rr_QueryBestResponse doesn't work.
	FollowupDatabase = Decider()
}

// Criterion rules declared as their own variables.
// Just add any criteria that you want here.
::VSLib.ResponseRules.Criteria <-
{
	// Awards
	IsAwardReviveFriend = [ "AwardName", "ReviveFriend" ]
	IsSharingSubject = [ "AwardName", "SharingSubject" ]
	IsAwardMedic = [ "AwardName", "Medic" ]
	IsAwardProtector = [ "AwardName", "Protector" ]
	
	// Faults
	IsFaultFriendlyFire = [ "FaultName", "FriendlyFire" ]
	IsFaultBoomerBlunder = [ "FaultName", "BoomerBlunder" ]
	
	// Modes
	IsCoop = [ "GameMode", "coop" ]
	IsVersus = [ "GameMode", "versus" ]
	IsSurvival = [ "GameMode", "survival" ]
	IsScavenge = [ "GameMode", "scavenge" ]
	IsRealism = [ "GameMode", "realism" ]
	IsHoldout = [ "GameMode", "holdout" ]
	IsDash = [ "GameMode", "dash" ]
	IsShootzones = [ "GameMode", "shootzones" ]
	
	// Vocalization
	IsSpeaking = [ "Speaking", 1 ]
	IsNotSpeaking = [ "Speaking", 0 ]
	IsCoughing = [ "Coughing", 1 ]
	IsNotCoughing = [ "Coughing", 0 ]
	IsSmartLookAuto = [ "SmartLookType", "auto" ]
	IsNotSmartLookAuto = [ "SmartLookType", "manual" ]
	
	// Misc
	IsIncapacitated = [ "Incapacitated", 1 ]
	IsNotIncapacitated = [ "Incapacitated", 0 ]
	IsOnFire = [ "OnFire", 1 ]
	IsNotOnFire = [ "OnFire", 0 ]
	IsHangingFromLedge = [ "HangingFromLedge", 1 ]
	IsNotHangingFromLedge = [ "HangingFromLedge", 0 ]
	IsPounceVictim = [ "PounceVictim", 1 ]
	IsNotPounceVictim = [ "PounceVictim", 0 ]
	IsHangingFromTongue = [ "HangingFromTongue", 1 ]
	IsNotHangingFromTongue = [ "HangingFromTongue", 0 ]
	IsBeingJockeyed = [ "BeingJockeyed", 1 ]
	IsAlone = [ "NumberOfTeamAlive", 1 ]
	IsNotAlone = [ "NumberOfTeamAlive", 2, 4 ]
	IsWithThree = [ "NumberOfTeamAlive", 3, 4 ]
	IsWithTwo = [ "NumberOfTeamAlive", 2 ]
	IsWithOnlyThree = [ "NumberOfTeamAlive", 3 ]
	IsEveryoneNotAlive = [ "NumberOfTeamAlive", 0, 3 ]
	IsEveryoneAlive = [ "NumberOfTeamAlive", 4 ]
	IsOnThirdStrike = [ "OnThirdStrike", 1 ]
	
	// Locational
	IsInCheckpoint = [ "InCheckpoint", 1 ]
	IsNotInCheckpoint = [ "InCheckpoint", 0 ]
	IsInBattlefield = [ "InBattlefield", 1 ]
	NotAloneInSafeSpot = [ "NumberInSafeSpot", 2, 4 ]
	IsAllInSafeSpot = [ "NumberInSafeSpot", 4 ]
	IsInSafeSpot = [ "InSafeSpot", 1 ]
	IsNotInSafeSpot = [ "InSafeSpot", 0 ]
	IsInStartArea = [ "InStartArea", 1 ]
	IsNotInStartArea = [ "InStartArea", 0 ]
	SomeoneOutsideSafeSpot = [ "NumberOutsideSafeSpot", 1, 4 ]
	
	// Orator
	IsWhitaker = [ "Name", "orator" ]
	IsVirgil = [ "Name", "orator" ]
	IsSoldier1 = [ "Name", "orator" ]
	IsSoldier2 = [ "Name", "orator" ]
	IsArenHeli = [ "Name", "orator" ]
	
	// Survivor criteria
	IsCoach = [ "Who", "Coach" ]
	IsGambler = [ "Who", "Gambler" ]
	IsMechanic = [ "Who", "Mechanic" ]
	IsProducer = [ "Who", "Producer" ]
	IsBiker = [ "Who", "Biker" ]
	IsManager = [ "Who", "Manager" ]
	IsNamVet = [ "Who", "NamVet" ]
	IsTeenGirl = [ "Who", "TeenGirl" ]
	IsUnknown = [ "Who", "Unknown" ]
	
	IsDeadCoach = [ "DeadCharacter", "Coach" ]
	IsDeadGambler = [ "DeadCharacter", "Gambler" ]
	IsDeadMechanic = [ "DeadCharacter", "Mechanic" ]
	IsDeadProducer = [ "DeadCharacter", "Producer" ]
	IsDeadBiker = [ "DeadCharacter", "Biker" ]
	IsDeadManager = [ "DeadCharacter", "Manager" ]
	IsDeadNamVet = [ "DeadCharacter", "NamVet" ]
	IsDeadTeenGirl = [ "DeadCharacter", "TeenGirl" ]
	IsDeadUnknown = [ "DeadCharacter", "Unknown" ]
	
	IsCoachAlive = [ "IsCoachAlive", 1 ]
	IsGamblerAlive = [ "IsGamblerAlive", 1 ]
	IsMechanicAlive = [ "IsMechanicAlive", 1 ]
	IsProducerAlive = [ "IsProducerAlive", 1 ]
	IsBikerAlive = [ "IsBikerAlive", 1 ]
	IsManagerAlive = [ "IsManagerAlive", 1 ]
	IsNamVetAlive = [ "IsNamVetAlive", 1 ]
	IsTeenGirlAlive = [ "IsTeenGirlAlive", 1 ]
	
	IsCoachNotAlive = [ "IsCoachAlive", 0 ]
	IsGamblerNotAlive = [ "IsGamblerAlive", 0 ]
	IsMechanicNotAlive = [ "IsMechanicAlive", 0 ]
	IsProducerNotAlive = [ "IsProducerAlive", 0 ]
	IsBikerNotAlive = [ "IsBikerAlive", 0 ]
	IsManagerNotAlive = [ "IsManagerAlive", 0 ]
	IsNamVetNotAlive = [ "IsNamVetAlive", 0 ]
	IsTeenGirlNotAlive = [ "IsTeenGirlAlive", 0 ]
	
	FromIsCoach = [ "From", "Coach" ]
	FromIsGambler = [ "From", "Gambler" ]
	FromIsMechanic = [ "From", "Mechanic" ]
	FromIsProducer = [ "From", "Producer" ]
	FromIsBiker = [ "From", "Biker" ]
	FromIsManager = [ "From", "Manager" ]
	FromIsNamVet = [ "From", "NamVet" ]
	FromIsTeenGirl = [ "From", "TeenGirl" ]
	FromIsUnknown = [ "From", "Unknown" ]
	
	SubjectIsCoach = [ "Subject", "Coach" ]
	SubjectIsGambler = [ "Subject", "Gambler" ]
	SubjectIsMechanic = [ "Subject", "Mechanic" ]
	SubjectIsProducer = [ "Subject", "Producer" ]
	SubjectIsBiker = [ "Subject", "Biker" ]
	SubjectIsManager = [ "Subject", "Manager" ]
	SubjectIsNamVet = [ "Subject", "NamVet" ]
	SubjectIsTeenGirl = [ "Subject", "TeenGirl" ]
	SubjectIsUnknown = [ "Subject", "Unknown" ]
	
	IsGamblerNear200 = [ "DistToGambler", 0, 199 ]
	IsGamblerNear400 = [ "DistToGambler", 0, 399 ]
	IsGamblerNear800 = [ "DistToGambler", 0, 799 ]
	IsGamblerFar400 = [ "DistToGambler", 400, 999999 ]
	IsGamblerFar1000 = [ "DistToGambler", 601, 999999 ]
	IsCoachNear200 = [ "DistToCoach", 0, 199 ]
	IsCoachNear400 = [ "DistToCoach", 0, 399 ]
	IsCoachNear800 = [ "DistToCoach", 0, 799 ]
	IsCoachFar400 = [ "DistToCoach", 400, 999999 ]
	IsCoachFar1000 = [ "DistToCoach", 601, 999999 ]
	IsProducerNear200 = [ "DistToProducer", 0, 199 ]
	IsProducerNear400 = [ "DistToProducer", 0, 399 ]
	IsProducerNear800 = [ "DistToProducer", 0, 799 ]
	IsProducerFar400 = [ "DistToProducer", 400, 999999 ]
	IsProducerFar1000 = [ "DistToProducer", 601, 999999 ]
	IsMechanicNear200 = [ "DistToMechanic", 0, 199 ]
	IsMechanicNear400 = [ "DistToMechanic", 0, 399 ]
	IsMechanicNear800 = [ "DistToMechanic", 0, 799 ]
	IsMechanicFar400 = [ "DistToMechanic", 400, 999999 ]
	IsMechanicFar1000 = [ "DistToMechanic", 601, 999999 ]
	
	IsNamVetNear200 = [ "DistToNamVet", 0, 199 ]
	IsNamVetNear400 = [ "DistToNamVet", 0, 399 ]
	IsNamVetNear800 = [ "DistToNamVet", 0, 799 ]
	IsNamVetFar400 = [ "DistToNamVet", 400, 999999 ]
	IsNamVetFar1000 = [ "DistToNamVet", 601, 999999 ]
	IsBikerNear200 = [ "DistToBiker", 0, 199 ]
	IsBikerNear400 = [ "DistToBiker", 0, 399 ]
	IsBikerNear800 = [ "DistToBiker", 0, 799 ]
	IsBikerFar400 = [ "DistToBiker", 400, 999999 ]
	IsBikerFar1000 = [ "DistToBiker", 601, 999999 ]
	IsTeenGirlNear200 = [ "DistToTeenGirl", 0, 199 ]
	IsTeenGirlNear400 = [ "DistToTeenGirl", 0, 399 ]
	IsTeenGirlNear800 = [ "DistToTeenGirl", 0, 799 ]
	IsTeenGirlFar400 = [ "DistToTeenGirl", 400, 999999 ]
	IsTeenGirlFar1000 = [ "DistToTeenGirl", 601, 999999 ]
	IsManagerNear200 = [ "DistToManager", 0, 199 ]
	IsManagerNear400 = [ "DistToManager", 0, 399 ]
	IsManagerNear800 = [ "DistToManager", 0, 799 ]
	IsManagerFar400 = [ "DistToManager", 400, 999999 ]
	IsManagerFar1000 = [ "DistToManager", 601, 999999 ]
	
	PanicEventCoach = [ "WhoDidIt", "Coach" ]
	PanicEventGambler = [ "WhoDidIt", "Gambler" ]
	PanicEventMechanic = [ "WhoDidIt", "Mechanic" ]
	PanicEventProducer = [ "WhoDidIt", "Producer" ]
	PanicEventBiker = [ "WhoDidIt", "Biker" ]
	PanicEventManager = [ "WhoDidIt", "Manager" ]
	PanicEventNamVet = [ "WhoDidIt", "NamVet" ]
	PanicEventTeenGirl = [ "WhoDidIt", "TeenGirl" ]
	
	WhoPutColaCoach = [ "worldWhoPutCola", "Coach" ]
	WhoPutColaGambler = [ "worldWhoPutCola", "Gambler" ]
	WhoPutColaMechanic = [ "worldWhoPutCola", "Mechanic" ]
	WhoPutColaProducer = [ "worldWhoPutCola", "Producer" ]
	WhoPutColaBiker = [ "worldWhoPutCola", "Biker" ]
	WhoPutColaManager = [ "worldWhoPutCola", "Manager" ]
	WhoPutColaNamVet = [ "worldWhoPutCola", "NamVet" ]
	WhoPutColaTeenGirl = [ "worldWhoPutCola", "TeenGirl" ]
	
	Iswitch_aggro_onCoach = [ "witch_aggro_on", "Coach" ]
	Iswitch_aggro_onGambler = [ "witch_aggro_on", "Gambler" ]
	Iswitch_aggro_onMechanic = [ "witch_aggro_on", "Mechanic" ]
	Iswitch_aggro_onProducer = [ "witch_aggro_on", "Producer" ]
	Iswitch_aggro_onBiker = [ "witch_aggro_on", "Biker" ]
	Iswitch_aggro_onManager = [ "witch_aggro_on", "Manager" ]
	Iswitch_aggro_onNamVet = [ "witch_aggro_on", "NamVet" ]
	Iswitch_aggro_onTeenGirl = [ "witch_aggro_on", "TeenGirl" ]
	
	// Teams
	IsSurvivor = [ "Team", "Survivor" ]
	IsL4D1Survivor = [ "Team", "L4D1_Survivor" ]
	IsInfected = [ "Team", "Infected" ]
	
	// Infected types
	IsCommon = [ "Who", "Common" ]
	IsSmoker = [ "Who", "Smoker" ]
	IsSpitter = [ "Who", "Spitter" ]
	IsJockey = [ "Who", "Jockey" ]
	IsCharger = [ "Who", "Charger" ]
	IsScreamer = [ "Who", "Screamer" ]
	IsBoomer = [ "Who", "Boomer" ]
	IsWitch = [ "Who", "Witch" ]
	IsHunter = [ "Who", "Hunter" ]
	IsTank = [ "Who", "Tank" ]
	
	// Special types
	IsSpecialTypeSmoker = [ "SpecialType", "Smoker" ]
	IsSpecialTypeBoomer = [ "SpecialType", "Boomer" ]
	IsSpecialTypeHunter = [ "SpecialType", "Hunter" ]
	IsSpecialTypeTank = [ "SpecialType", "Tank" ]
	IsSpecialTypeWitch = [ "SpecialType", "Witch" ]
	IsSpecialTypeJockey = [ "SpecialType", "Jockey" ]
	IsSpecialTypeCharger = [ "SpecialType", "Charger" ]
	IsSpecialTypeSpitter = [ "SpecialType", "Spitter" ]
	IsSpecialTypeCeda = [ "SpecialType", "Ceda" ]
	IsSpecialTypeMudmen = [ "SpecialType", "Crawler" ]
	IsSpecialTypeArmored = [ "SpecialType", "riot_control" ]
	IsSpecialTypeClown = [ "SpecialType", "Clown" ]
	IsSpecialTypeRoadcrew = [ "SpecialType", "Undistractable" ]
	IsSpecialTypeJimmy = [ "SpecialType", "Jimmy" ]
	IsSpecialTypeFallen = [ "SpecialType", "Fallen" ]
	
	// Infected classes
	IsSmokerClass = [ "ZombieClass", "Smoker" ]
	IsSpitterClass = [ "ZombieClass", "Spitter" ]
	IsJockeyClass = [ "ZombieClass", "Jockey" ]
	IsBoomerClass = [ "ZombieClass", "Boomer" ]
	IsWitchClass = [ "ZombieClass", "Witch" ]
	IsHunterClass = [ "ZombieClass", "Hunter" ]
	IsTankClass = [ "ZombieClass", "Tank" ]
	IsChargerClass = [ "ZombieClass", "Charger" ]
	
	// dist_from_subject nears (use these for everything that isn't an info_remarkable
	IsSubjectDistNear50 = [ "dist_from_subject", 0, 49 ]
	IsSubjectDistNear100 = [ "dist_from_subject", 0, 99 ]
	IsSubjectDistNear150 = [ "dist_from_subject", 0, 149 ]
	IsSubjectDistNear200 = [ "dist_from_subject", 0, 199 ]
	IsSubjectDistNear250 = [ "dist_from_subject", 0, 249 ]
	IsSubjectDistNear300 = [ "dist_from_subject", 0, 299 ]
	IsSubjectDistNear350 = [ "dist_from_subject", 0, 349 ]
	IsSubjectDistNear400 = [ "dist_from_subject", 0, 399 ]
	IsSubjectDistNear500 = [ "dist_from_subject", 0, 499 ]
	IsSubjectDistNear600 = [ "dist_from_subject", 0, 599 ]
	IsSubjectDistNear700 = [ "dist_from_subject", 0, 699 ]
	IsSubjectDistNear800 = [ "dist_from_subject", 0, 799 ]
	IsSubjectDistNear900 = [ "dist_from_subject", 0, 899 ]
	IsSubjectDistNear1000 = [ "dist_from_subject", 0, 999 ]
	IsSubjectDistNear1500 = [ "dist_from_subject", 0, 1499 ]
	
	IsSubjectDistFar100 = [ "dist_from_subject", 101, 999999 ]
	IsSubjectDistFar200 = [ "dist_from_subject", 201, 999999 ]
	IsSubjectDistFar300 = [ "dist_from_subject", 301, 999999 ]
	IsSubjectDistFar400 = [ "dist_from_subject", 401, 999999 ]
	IsSubjectDistFar500 = [ "dist_from_subject", 501, 999999 ]
	IsSubjectDistFar600 = [ "dist_from_subject", 601, 999999 ]
	IsSubjectDistFar700 = [ "dist_from_subject", 701, 999999 ]
	IsSubjectDistFar800 = [ "dist_from_subject", 801, 999999 ]
	IsSubjectDistFar900 = [ "dist_from_subject", 901, 999999 ]
	IsSubjectDistFar1000 = [ "dist_from_subject", 1001, 999999 ]
	
	IssuerCloseEnough = [ "dist_from_issuer", 0, 799 ]
	IssuerClose = [ "dist_from_issuer", 0, 399 ]
	IssuerReallyClose = [ "dist_from_issuer", 0, 199 ]
	IssuerMediumClose = [ "dist_from_issuer", 0, 299 ]
	
	// Used for new nears
	IsSubjectNear50 = [ "distance", 0, 49 ]
	IsSubjectNear75 = [ "distance", 0, 74 ]
	IsSubjectNear100 = [ "distance", 0, 99 ]
	IsSubjectNear150 = [ "distance", 0, 149 ]
	IsSubjectNear200 = [ "distance", 0, 199 ]
	IsSubjectNear250 = [ "distance", 0, 249 ]
	IsSubjectNear300 = [ "distance", 0, 299 ]
	IsSubjectNear350 = [ "distance", 0, 349 ]
	IsSubjectNear400 = [ "distance", 0, 399 ]
	IsSubjectNear500 = [ "distance", 0, 499 ]
	IsSubjectNear550 = [ "distance", 0, 549 ]
	IsSubjectNear600 = [ "distance", 0, 599 ]
	IsSubjectNear700 = [ "distance", 0, 699 ]
	IsSubjectNear800 = [ "distance", 0, 799 ]
	IsSubjectNear900 = [ "distance", 0, 899 ]
	IsSubjectNear1000 = [ "distance", 0, 999 ]
	IsSubjectNear1500 = [ "distance", 0, 1499 ]
	
	IsSubjectFar100 = [ "distance", 101, 999999 ]
	IsSubjectFar200 = [ "distance", 201, 999999 ]
	IsSubjectFar300 = [ "distance", 301, 999999 ]
	IsSubjectFar400 = [ "distance", 401, 999999 ]
	IsSubjectFar500 = [ "distance", 501, 999999 ]
	IsSubjectFar600 = [ "distance", 601, 999999 ]
	IsSubjectFar700 = [ "distance", 701, 999999 ]
	IsSubjectFar800 = [ "distance", 801, 999999 ]
	IsSubjectFar900 = [ "distance", 901, 999999 ]
	IsSubjectFar1000 = [ "distance", 1001, 999999 ]
	
	// Used for random weighting for rules
	ChanceToFire1Percent = [ "randomnum", 1 ]
	ChanceToFire2Percent = [ "randomnum", 0, 2 ]
	ChanceToFire3Percent = [ "randomnum", 0, 3 ]
	ChanceToFire5Percent = [ "randomnum", 0, 5 ]
	ChanceToFire10Percent = [ "randomnum", 0, 10 ]
	ChanceToFire15Percent = [ "randomnum", 0, 15 ]
	ChanceToFire20Percent = [ "randomnum", 0, 20 ]
	ChanceToFire30Percent = [ "randomnum", 0, 30 ]
	ChanceToFire40Percent = [ "randomnum", 0, 40 ]
	ChanceToFire50Percent = [ "randomnum", 0, 50 ]
	ChanceToFire60Percent = [ "randomnum", 0, 60 ]
	ChanceToFire70Percent = [ "randomnum", 0, 70 ]
	ChanceToFire80Percent = [ "randomnum", 0, 80 ]
	ChanceToFire90Percent = [ "randomnum", 0, 90 ]
	ChanceToFire100Percent = [ "randomnum", 0, 100 ]
	
	// Map criteria
	Isc1m1_hotel = [ "Map", "c1m1_hotel" ]
	Isc1m2_streets = [ "Map", "c1m2_streets" ]
	Isc1m3_mall = [ "Map", "c1m3_mall" ]
	Isc1m4_atrium = [ "Map", "c1m4_atrium" ]
	Isc2m1_highway = [ "Map", "c2m1_highway" ]
	Isc2m2_fairgrounds = [ "Map", "c2m2_fairgrounds" ]
	Isc2m3_coaster = [ "Map", "c2m3_coaster" ]
	Isc2m4_barns = [ "Map", "c2m4_barns" ]
	Isc2m5_concert = [ "Map", "c2m5_concert" ]
	Isc3m1_plankcountry = [ "Map", "c3m1_plankcountry" ]
	Isc3m2_swamp = [ "Map", "c3m2_swamp" ]
	Isc3m3_shantytown = [ "Map", "c3m3_shantytown" ]
	Isc3m4_plantation = [ "Map", "c3m4_plantation" ]
	Isc4m1_milltown_a = [ "Map", "c4m1_milltown_a" ]
	Isc4m2_sugarmill_a = [ "Map", "c4m2_sugarmill_a" ]
	Isc4m3_sugarmill_b = [ "Map", "c4m3_sugarmill_b" ]
	Isc4m4_milltown_b = [ "Map", "c4m4_milltown_b" ]
	Isc4m5_milltown_escape = [ "Map", "c4m5_milltown_escape" ]
	Isc5m1_waterfront = [ "Map", "c5m1_waterfront" ]
	Isc5m2_park = [ "Map", "c5m2_park" ]
	Isc5m3_cemetery = [ "Map", "c5m3_cemetery" ]
	Isc5m4_quarter = [ "Map", "c5m4_quarter" ]
	Isc5m5_bridge = [ "Map", "c5m5_bridge" ]
	Isc6m1_riverbank = [ "Map", "c6m1_riverbank" ]
	Isc6m2_bedlam = [ "Map", "c6m2_bedlam" ]
	Isc6m3_port = [ "Map", "c6m3_port" ]
	Isc7m1_docks = [ "Map", "c7m1_docks" ]
	Isc7m2_barge = [ "Map", "c7m2_barge" ]
	Isc7m3_port = [ "Map", "c7m3_port" ]
	Isc8m1_apartment = [ "Map", "c8m1_apartment" ]
	Isc8m2_subway = [ "Map", "c8m2_subway" ]
	Isc8m3_sewers = [ "Map", "c8m3_sewers" ]
	Isc8m4_interior = [ "Map", "c8m4_interior" ]
	Isc8m5_rooftop = [ "Map", "c8m5_rooftop" ]
	Isc9m1_alleys = [ "Map", "c9m1_alleys" ]
	Isc9m2_lots = [ "Map", "c9m2_lots" ]
	Isc10m1_caves = [ "Map", "c10m1_caves" ]
	Isc10m2_drainage = [ "Map", "c10m2_drainage" ]
	Isc10m3_ranchhouse = [ "Map", "c10m3_ranchhouse" ]
	Isc10m4_mainstreet = [ "Map", "c10m4_mainstreet" ]
	Isc10m5_houseboat = [ "Map", "c10m5_houseboat" ]
	Isc11m1_greenhouse = [ "Map", "c11m1_greenhouse" ]
	Isc11m2_offices = [ "Map", "c11m2_offices" ]
	Isc11m3_garage = [ "Map", "c11m3_garage" ]
	Isc11m4_terminal = [ "Map", "c11m4_terminal" ]
	Isc11m5_runway = [ "Map", "c11m5_runway" ]
	Isc12m1_hilltop = [ "Map", "C12m1_hilltop" ]
	Isc12m2_traintunnel = [ "Map", "c12m2_traintunnel" ]
	Isc12m3_bridge = [ "Map", "c12m3_bridge" ]
	Isc12m4_barn = [ "Map", "c12m4_barn" ]
	Isc12m5_cornfield = [ "Map", "c12m5_cornfield" ]
	Isc13m1_alpinecreek = [ "Map", "c13m1_alpinecreek" ]
	Isc13m2_southpinestream = [ "Map", "c13m2_southpinestream" ]
	Isc13m3_memorialbridge = [ "Map", "c13m3_memorialbridge" ]
	Isc13m4_cutthroatcreek = [ "Map", "c13m4_cutthroatcreek" ]
}


// Each Rule consists of the following fields in a table
// * name		: an arbitrary rule name, for your convenience in debugging.
// * criteria	: an array of criteria that must be met for the rule to be considered a match. 
//		Criteria may be static string/numeric comparisons, or functions. 
// * responses	: an array of individual Response objects, emulating their counterparts in RR1.

// --- CRITERIA
// the 'criteria' section of a rule is a simple list. Criteria fall into two broad groups:
// * STATIC criteria compare a fact (as a number) to a range on a number line, or strings to each other.
//	  So, 'foo > 4', 'foo > 0 and foo < 10', 'foo = 6', ' foo = "bar" ' are all static criteria. These are very fast to match.
// * FUNCTION criteria are arbitrary Squirrel functions returning TRUE or FALSE. They may do any work you like, but
//   incur a 3 microsecond overhead to call, in addition to the work the function itself does. 
// A rule must match all of its static criteria before the function criteria are even tested, so the more narrowly
// constrained your rule, the less of an impact the functions will have.
// Static criteria follow the form:
//   [ name, a, b ] compares the value of key 'name' to see if it is >= a and <= b. 
//   a and b may be null, in which case they represent negative and positive infinity. 
//   See below for examples.
// A function criterion takes one parameter: 'query' and should return a boolean 
// so you could define one ahead of time like
// function FooCriterion(query) {  return query.foo > g_rr.whatever.foo }
// Here's example of different kinds of criteria
// { name = "FakeRule"
//	 criteria = [
//		[ "concept", "PlayerMove" ],	// does the "concept" fact equal "PlayerMove" ?
//		[ "IsCoughing" , 0 ],			// does the "IsCoughing" fact equal zero?
//		[ "NumAllies", 1, null ],		// is "numallies" between 1 and infinity -- ie, is "NumAllies" >= 1 ?
//		[ "Ammo", 2, 8 ],				// is the "ammo" fact >=2 and <= 8?
//		FooCriterion,					// does the function FooCriterion return true when called?
//		@(query) query.blarg % 3 == 0	// anonymous function declared inline -- is fact "blarg" divisible by 3?
//	]

// --- RESPONSES 

// Emulates a single Response object from RR1, which is eg an individual 'speak' or 'sentence' etc
// A response consists of a table with these fields:
// target	: a string like "foo.vcd", 
// func		: which is a script function to call before performing Target (optional)	
//			  this function may be specified by name, or as an anonymous @ function.
// and a Params object which is a table consisting of the optional parameters below. 
//	( Omitting an entry in Params assumes a reasonable default. )
// Optional parameters:
//   nodelay = an additional delay of 0 after speaking
//   defaultdelay = an additional delay of 2.8 to 3.2 seconds after speaking
//   delay interval = an additional delay based on a random sample from the interval after speaking
//   speakonce = don't use this response more than one time (default off)
//	 noscene = For an NPC, play the sound immediately using EmitSound, don't play it through the scene system. Good for playing sounds on dying or dead NPCs.
//   odds = if this response is selected, if odds < 100, then there is a chance that nothing will be said (default 100)
//	 respeakdelay = don't use this response again for at least this long (default 0)
//   soundlevel = use this soundlevel for the speak/sentence (default SNDLVL_TALKING)
//   weight = if there are multiple responses, this is a selection weighting so that certain responses are favored over others in the group (default 1)
//   displayfirst/displaylast : this should be the first/last item selected (ignores weight)
//   then = a Then() object processed as in RR1
//	 onFinish = eventually, a script function to call when the scene finishes (currently not implemented)

// see the "DemonstrateScriptFollowup" concept below for details


// all of this is experimental code not relevant to the running game. 


function VSLib::ResponseRules::CharacterSpeak( speaker, query )
{
	local q = ::rr_QueryBestResponse( speaker, query_params ) // looks up the result, returns null if none found
	if(q)
		::rr_CommitAIResponse( speaker, q ) // this actually makes the character speak
}

function VSLib::ResponseRules::DemoScriptFollowupFunction( speaker, query )
{
	print( "DemoScriptFollowupFunction called with speaker = " + speaker + " query = " + query + "\n" )
	// if you wanted to submit this query to the speaker and do a response-lookup with it
	// you could do that like:
	// local response = rr_QueryBestResponse( speaker, query ) // <- send a query to this entity and look for the best matching response.
	// if ( response )							 // <- if a response was found,
	//	rr_CommitAIResponse( speaker, response ) // <- have this entity speak it.
}
 
// and then include it into the criteria lists as per the examples below. The "g_rr." part
// is a bit of temporary cruft that will go away once we resolve some questions about scope resolution
// in map .nut files.

// here's a demo of a function that reads a context out of a character, and sets it again. (you can also read context out of the query.)
function VSLib::ResponseRules::DemoWritingContextToCharacter( speaker, query )
{
	// look up a 'bananas' context in the query, add one to it, and write it to the character. write 1 if query has no bananas.
	if ( "bananas" in query )
	{
		speaker.SetContext( "bananas", (query["bananas"] + 1).tostring(), 0 )
	}
	else
	{
		speaker.SetContext( "bananas", "1", 0 )
	}
}
// just prints a table to the console
// for scoping reasons too dumb to go into, to access this you'll need
// to actually type 'g_rr.PrintTable'.

/*function VSLib::ResponseRules::PrintTable( t )
{
	foreach(k,v in t)
	{
		printl( k + " : " + v )
	}
}*/

//this is an example set of functions that checks to see if a player just received an award protecting a player.  if they did - don't have the protected player play any friendly fire lines.
function VSLib::ResponseRules::SetAwardSpeech(speaker, query)
{
	local ProtectedDude = rr_GetResponseTargets()[ query.subject ]
	ProtectedDude.SetContext( "AwardSpeech", query.who, 10 )
}


function VSLib::ResponseRules::SubjectAward( query )
{
	if ( "AwardSpeech" in query && "subject" in query )
	{
		if ( query["AwardSpeech"] == query["subject"] )
		{
			return true
		}
		else
		{
			return false
		}
	}
	else
	{
		return false
	}
}




// The different kinds of available response
// must exactly match ResponseType_t in code.
enum ResponseKind
{
	none,		// invalid type
	speak,		// it's an entry in sounds.txt
	sentence,	// it's a sentence name from sentences.txt
	scene,		// it's a .vcd file
	response,	// it's a reference to another response group by name
	print,		// print the text in developer 2 (for placeholder responses)
	script		// a script function
}


// Emulates a single Response object from RR1, which is eg an individual 'speak' or 'sentence' etc
// A response consists of a Kind (see ResponseKind above), 
// a Target which is a string like "foo.vcd", 
// a Func (option), which is a script function to call before performing Target
// and a Params object which is a table consisting of the optional parameters below. 
//	( Omitting an entry in Params assumes a reasonable default. )
// Optional parameters:
//   nodelay = an additional delay of 0 after speaking
//   defaultdelay = an additional delay of 2.8 to 3.2 seconds after speaking
//   delay interval = an additional delay based on a random sample from the interval after speaking
//   speakonce = don't use this response more than one time (default off)
//	 noscene = For an NPC, play the sound immediately using EmitSound, don't play it through the scene system. Good for playing sounds on dying or dead NPCs.
//   odds = if this response is selected, if odds < 100, then there is a chance that nothing will be said (default 100)
//	 respeakdelay = don't use this response again for at least this long (default 0)
//   soundlevel = use this soundlevel for the speak/sentence (default SNDLVL_TALKING)
//   weight = if there are multiple responses, this is a selection weighting so that certain responses are favored over others in the group (default 1)
//   displayfirst/displaylast : this should be the first/last item selected (ignores weight)
//   then = a Then() object processed as in RR1
//	 onFinish = eventually, a script function to call when the scene finishes (currently not implemented)
class ::VSLib.ResponseRules.ResponseSingle
{
	// constructor
	constructor( _kind, _target, _rule, _func = null, _params = {} )
	{
		kind = _kind
		target = _target
		rule = _rule
		params = _params
		func = _func
		
		// assert valid types
		assert( typeof( kind ) == "integer" )
		assert( typeof( params ) == "table" )
	}
	function Describe()
	{
		print("Response:\n")
		print("\tkind " + kind)
		print("\n\ttarget " + target + "\n" )
		foreach ( k,v in params )
			print("\t" + k + " : " + v + "\n")
	}
	// properties
	kind = null; // one of the ResponseKind enumerations
	target = null; // will be a string or a function
	func = null;
	params = null; // will be a table
	rule = null; // reference back to the rule to which I belong
	
	cpp_visitor = null; // a field for the C++ code to store whatever opaque info it needs in this object.
	
	function _tostring()
	{
		return "ResponseSingle: " + target
	}
}


// Emulates a defined response group from RR1, which consists of several optional
// you pass in a table of configuration variables affecting how entries in the responses array are selected:
// [permitrepeats]   ; optional parameter, by default we visit all responses in group before repeating any
// [sequential]	  ; optional parameter, by default we randomly choose responses, but with this we walk through the list starting at the first and going to the last
// [norepeat]		  ; Once we've run through all of the entries, disable the response group
// [matchonce]	; once this rule matches (at all), disable it.
// so you would call this like
//	RGroupParams( {sequential=true, norepeat=true} )
class ::VSLib.ResponseRules.GroupParams
{
	// constructor
	constructor( parms = {} )
	{
		if ( "permitrepeats" in parms && parms.permitrepeats )
			permitrepeats = true
		if ( "sequential" in parms && parms.sequential )
			sequential = true
		if ( "norepeat" in parms && parms.norepeat )
			norepeat = true
		if ( "matchonce" in parms && parms.matchonce )
			matchonce = true
	}
	// properties
	permitrepeats = false;
	sequential = false;
	norepeat = false;
	matchonce = false;
}	


// A followup event like the old response Then.
// All followups need to expose a function and a 'delay' parameter.
// The callable gets the following parameters:
//	( speaker [ehandle] (actually a script handle), query [as table] )
// Build like so:
//  RThen(	"coach",  // target
//			"TLK_FOLLOWUP_WHATEVER", // concept
//			{ foo = 1, bar = "flarb" }, // contexts to add to the followup  (may be null instead)
//			1.5 // delay
//			)
class ::VSLib.ResponseRules.Then
{
	constructor( _target, _concept, _contexts, _delay )
	{
		// type checking
		assert( typeof(_target) == "string" )
		target = _target
		assert( typeof(_concept) == "string" )
		delay = _delay.tofloat()
		
		// in rr2 "concept" is just another fact in the query
		if ( _contexts == null )
		{
			_contexts = {}
		}
		else if ( typeof(_contexts) != "table" )
		{
			throw("Then() error: _contexts parameter isn't a table or null")
		}
		addcontexts = clone _contexts
		
		addcontexts.concept <- _concept
		func = execute.bindenv(this)
	}
	
	function execute( speaker, query )
	{
		if ( target.tolower() == "namvet" )
			target = "NamVet"
		else if ( target.tolower() == "teengirl" )
			target = "TeenGirl"
		else
		{
			local firstletter = target.slice(0,1)
			target = firstletter.toupper() + target.slice(1)
		}
		
		// debug prints...
		if ( Convars.GetFloat( "rr_debugresponses" ) > 0 )
		{
			print( "Then followup called:\n\ttarget: " )
			printl(target)
		
			if ( Convars.GetFloat( "rr_debugresponses" ) >= 2 )
			{
				print( "\taddcontexts: {")
				foreach (k,v in addcontexts)
				{
					print("\n\t")
					print(k)
					print(" : ")
					print(v)
				}
				print( "\n}\n\tspeaker: ")
				print( speaker )
			}
			print( "\t(end followup)\n")
		}
		
		// merge addcontexts into query
		foreach (k,v in addcontexts)
		{
			query[k] <- v
		}
		
		if ( target.tolower() == "all" )
		{
			local expressers = ::rr_GetResponseTargets()
			// attempt dispatch to all listeners
			foreach (name, recipient in expressers)
			{
				DoEntFire("!self", "SpeakResponseConcept", query.concept, 0, null, recipient)
				/*local q = ::VSLib.ResponseRules.FollowupDatabase.FindBestMatch( query )
				//local q = rr_QueryBestResponse( recipient, query )
				if ( q )
				{
					printl("q found")
					EntFire(::VSLib.Player(recipient).GetTargetname(), "SpeakResponseConcept", query.concept, 0)
					//rr_CommitAIResponse( recipient, q )
				}*/
			}
		}
		else if ( target.tolower() == "any" )
		{
			if ( Entities.FindByClassname( null, "info_director" ) )
			{
				EntFire("info_director", "FireConceptToAny", query.concept, 0)
			}
			else
			{
				::VSLib.Utils.CreateEntity("info_director")
				EntFire("info_director", "FireConceptToAny", query.concept, 0)
				EntFire("info_director", "Kill")
			}
			/*local expressers = ::rr_GetResponseTargets()
			// test the query against each listener and only play the best match
			local results = []
			foreach (name, recipient in expressers)
			{
				local q = ::VSLib.ResponseRules.FollowupDatabase.FindBestMatch( query )
				//local q = rr_QueryBestResponse( recipient, query )
				if ( q )
				{
					results.push( [recipient, q] )
				}
			}
			if ( results.len() > 0 )
			{
				// find the highest-scoring entry and play that
				local idx = 1
				local best = 0
				while ( idx < results.len() ) 
				{
					if ( results[idx][1].params.weight > results[best][1].params.weight )
					{
						best = idx
					}
					idx++
					//if ( results[i][1].score > results[best][1].score )
					//{
					//	best = idx
					//}
				}
				DoEntFire("!self", "SpeakResponseConcept", query.concept, 0, results[best][0], null)
				//rr_CommitAIResponse( results[best][0], results[best][1] )
			}*/
		}
		else if ( target.tolower() == "self" )
		{
			DoEntFire("!self", "SpeakResponseConcept", query.concept, 0, null, speaker)
			/*local q = ::VSLib.ResponseRules.FollowupDatabase.FindBestMatch( query )
			//local q = rr_QueryBestResponse( speaker, query )
			if ( q )
				EntFire(::VSLib.Player(speaker).GetTargetname(), "SpeakResponseConcept", query.concept, 0)
				//rr_CommitAIResponse( speaker, q )*/
		}
		else if ( target.tolower() == "subject" )
		{
			local expressers = ::rr_GetResponseTargets()
			if ( query.subject in expressers )
				DoEntFire("!self", "SpeakResponseConcept", query.concept, delay, null, expressers[query.subject])
		}
		else if ( target.tolower() == "from" )
		{
			local expressers = ::rr_GetResponseTargets()
			if ( query.from in expressers )
				DoEntFire("!self", "SpeakResponseConcept", query.concept, delay, null, expressers[query.from])
		}
		else if ( target.tolower() == "orator" )
		{
			if ( Entities.FindByClassname( null, "func_orator" ) )
				EntFire("func_orator", "SpeakResponseConcept", query.concept, 0)
		}
		else
		{
			local expressers = ::rr_GetResponseTargets()
			if ( target in expressers )
			{
				DoEntFire("!self", "SpeakResponseConcept", query.concept, delay, null, expressers[target])
				/*local q = rr_QueryBestResponse( expressers[target], query )
				if ( q )
				{
					rr_CommitAIResponse( expressers[target], q )
				}*/
			}
			else
			{
				printl("RRscript warning: couldn't find target " + target )
			}
		}
	}

	// properties
	target = null; // this will be one of "any", "all", "coach", etc. I think in the future this wants to be a function?
	addcontexts = null; // a table of {k1:v1, k2:v2} additional facts that will be added to the following query. concept is always present here, from the constructor.
	delay = null; // delay as passed to the code followup class
	func = null; // what gets called when the followup triggers
	
	function _tostring()
	{
		return "Then: " + target
	}
}

// Given a single array representing a criterion,
// return a proper criterion object following these rules
// [a, b, c] becomes a static criterion for key a >= b && <= c
//           use Null for b or c to mean infinity, so that
//           [a, Null, c] means just a <= c (and a >= -infinity )
// [a, b]    if a is a function, becomes a functor criterion where b is called on fact a
//           otherwise becomes [a, b, b] meaning "a is equal to b"
// [a]       if a is a function, becomes a functor criterion like (Null, a)  (eg the function is always called and gets a null fact)
//           otherwise becomes [a, Null, Null], meaning "true if A exists in the query"
// functor criteria must always be functions taking (val, query) where val is the value of a fact (may be Null) and 'query' is a table
function VSLib::ResponseRules::ProcessCriterion( crit )
{
	if ( typeof(crit) == "function" )
	{
		return ::VSLib.ResponseRules.CriterionFunc( null )
	}
	else if ( typeof(crit) == "array" )
	{
		switch( crit.len() )
		{
			case 1:
				if (typeof(crit[0])=="function")
				{
					return ::VSLib.ResponseRules.CriterionFunc( null, crit[0] )
				}
				else
				{
					assert( typeof(crit[0]) == "string" )
					return ::VSLib.ResponseRules.Criterion( crit[0], null, null )
				}
				break
			case 2:
				assert( typeof(crit[0]) == "string" )
				if (typeof(crit[1])=="function")
				{
					return ::VSLib.ResponseRules.CriterionFunc( crit[0], crit[1] )
				}
				else
				{
					return ::VSLib.ResponseRules.Criterion( crit[0], crit[1], crit[1] )
				}
				break
			case 3:
				assert( typeof(crit[0]) == "string" )
				if (crit[1] == null)
				{
					crit[1] = 0
				}
				if (crit[2] == null)
				{
					crit[2] = 999999
				}
				return ::VSLib.ResponseRules.Criterion( crit[0], crit[1], crit[2] )
				break
			default:
				throw ( "Invalid criterion: " + crit )
		}
	}
	else
	{
		throw( "Invalid type for criterion: " + typeof(crit) )
	}
}


function VSLib::ResponseRules::ThenDelay( speaker, query, target, concept, contexts, delay )
{
	if ( target.tolower() == "namvet" )
		target = "NamVet"
	else if ( target.tolower() == "teengirl" )
		target = "TeenGirl"
	else
	{
		local firstletter = target.slice(0,1)
		target = firstletter.toupper() + target.slice(1)
	}
	
	if ( target.tolower() == "all" )
	{
		local expressers = ::rr_GetResponseTargets()
		foreach (name, recipient in expressers)
		{
			DoEntFire("!self", "SpeakResponseConcept", concept, delay, null, recipient)
		}
	}
	else if ( target.tolower() == "any" )
	{
		if ( Entities.FindByClassname( null, "info_director" ) )
		{
			EntFire("info_director", "FireConceptToAny", concept, delay)
		}
		else
		{
			::VSLib.Utils.CreateEntity("info_director")
			EntFire("info_director", "FireConceptToAny", concept, delay)
			EntFire("info_director", "Kill")
		}
	}
	else if ( target.tolower() == "self" )
	{
		DoEntFire("!self", "SpeakResponseConcept", concept, delay, null, speaker)
	}
	else if ( target.tolower() == "subject" )
	{
		local expressers = ::rr_GetResponseTargets()
		if ( query.subject in expressers )
			DoEntFire("!self", "SpeakResponseConcept", concept, delay, null, expressers[query.subject])
	}
	else if ( target.tolower() == "from" )
	{
		local expressers = ::rr_GetResponseTargets()
		if ( query.from in expressers )
			DoEntFire("!self", "SpeakResponseConcept", concept, delay, null, expressers[query.from])
	}
	else if ( target.tolower() == "orator" )
	{
		if ( Entities.FindByClassname( null, "func_orator" ) )
			EntFire("func_orator", "SpeakResponseConcept", concept, delay)
	}
	else
	{
		local expressers = ::rr_GetResponseTargets()
		if ( target in expressers )
		{
			DoEntFire("!self", "SpeakResponseConcept", concept, delay, null, expressers[target])
		}
	}
}

function VSLib::ResponseRules::PlaySoundFile( args )
{
	::VSLib.Entity(args.speaker.GetEntityIndex()).EmitAmbientSound( args.soundfile, args.volume, 350, 100 )
	if ( args.func )
		args.func( args.speaker, args.query )
	if ( args.applycontext )
		::VSLib.ResponseRules.ApplyContext( args.speaker, args.query, args.applycontext, args.applycontexttoworld, null )
	if ( args.then != null )
		::VSLib.ResponseRules.ThenDelay( args.speaker, args.query, args.then.target, args.then.concept, args.then.contexts, args.then.delay )
}

function VSLib::ResponseRules::EmitSound( args )
{
	EmitSoundOn( args.soundname, args.speaker )
	if ( args.func )
		args.func( args.speaker, args.query )
	if ( args.applycontext )
		::VSLib.ResponseRules.ApplyContext( args.speaker, args.query, args.applycontext, args.applycontexttoworld, null )
	if ( args.then != null )
		::VSLib.ResponseRules.ThenDelay( args.speaker, args.query, args.then.target, args.then.concept, args.then.contexts, args.then.delay )
}

function VSLib::ResponseRules::SceneDelay( args )
{
	::VSLib.Player(args.speaker.GetEntityIndex()).Speak( args.scenename )
	if ( args.func )
		args.func( args.speaker, args.query )
	if ( args.applycontext )
		::VSLib.ResponseRules.ApplyContext( args.speaker, args.query, args.applycontext, args.applycontexttoworld, null )
	if ( args.then != null )
		::VSLib.ResponseRules.ThenDelay( args.speaker, args.query, args.then.target, args.then.concept, args.then.contexts, args.then.delay )
}

function VSLib::ResponseRules::ApplyContext( speaker, query, contextData, contexttoworld, func )
{
	if ( typeof contextData == "table" )
	{
		if ( ( "context" in contextData ) && ( typeof contextData.context != "table" ) )
		{
			if ( contexttoworld )
			{
				::VSLib.Entity("worldspawn").SetContext( contextData.context, contextData.value.tostring(), contextData.duration )
			}
			else
			{
				local duration = contextData.duration
				if ( duration == 0 )
					duration = -1
				speaker.SetContext( contextData.context, contextData.value.tostring(), duration )
			}
		}
		else
		{
			foreach( contexts in contextData )
			{
				if ( contexttoworld )
				{
					::VSLib.Entity("worldspawn").SetContext( contexts.context, contexts.value.tostring(), contexts.duration )
				}
				else
				{
					local duration = contexts.duration
					if ( duration == 0 )
						duration = -1
					speaker.SetContext( contexts.context, contexts.value.tostring(), duration )
				}
			}
		}
	}
	if ( func )
		func( speaker, query )
}

// Given a single array representing the responses,
// do the ugly work to normalize them into ResponseSingle objects.
// right now the decision of type is made by whether there is a func param or a scenename param.
function VSLib::ResponseRules::ProcessResponse( resp )
{
	local delay = 0.0
	local func = null
	local scene = null
	local then = null
	local applycontext = null
	local applycontexttoworld = false
	
	if ( "delay" in resp )
	{
		delay = resp.delay
	}
	if ( "then" in resp )
	{
		then = resp.then
	}
	if ( "applycontext" in resp )
	{
		applycontext = resp.applycontext
	}
	if ( "applycontexttoworld" in resp )
	{
		applycontexttoworld = resp.applycontexttoworld
	}
	if ( "func" in resp )
	{
		func = resp.func
		
		// we still need to store the 'resp' table as a strong reference in the ResponseSingle object
		// so that it doesn't get garbage-collected. .bindenv only stores weak references to objects
		// so you can't count on it to actually hang onto the closure table.
	}
	if ( "scenename" in resp )
	{
		local Func = func
		if ( delay > 0.0 )
			func = @( speaker, query ) ::VSLib.Timers.AddTimer(delay, false, ::VSLib.ResponseRules.SceneDelay, { speaker = speaker, query = query, scenename = resp.scenename, applycontext = applycontext, applycontexttoworld = applycontexttoworld, func = Func, then = then })
		else
		{
			scene = resp.scenename
			
			if ( applycontext )
				func = @( speaker, query ) ::VSLib.ResponseRules.ApplyContext( speaker, query, applycontext, applycontexttoworld, Func )
		}
	}
	if ( "soundname" in resp )
	{
		local Func = func
		if ( delay > 0.0 )
			func = @( speaker, query ) ::VSLib.Timers.AddTimer(delay, false, ::VSLib.ResponseRules.EmitSound, { speaker = speaker, query = query, soundname = resp.soundname, applycontext = applycontext, applycontexttoworld = applycontexttoworld, func = Func, then = then })
		else
			func = @( speaker, query ) ::VSLib.ResponseRules.EmitSound( { speaker = speaker, query = query, soundname = resp.soundname, applycontext = applycontext, applycontexttoworld = applycontexttoworld, func = Func, then = then })
	}
	if ( "soundfile" in resp )
	{
		local volume = 10
		if ( "volume" in resp )
			volume = resp.volume
		
		local Func = func
		if ( delay > 0.0 )
			func = @( speaker, query ) ::VSLib.Timers.AddTimer(delay, false, ::VSLib.ResponseRules.PlaySoundFile, { speaker = speaker, query = query, soundfile = resp.soundfile, applycontext = applycontext, applycontexttoworld = applycontexttoworld, volume = volume, func = Func, then = then })
		else
			func = @( speaker, query ) ::VSLib.ResponseRules.PlaySoundFile( { speaker = speaker, query = query, soundfile = resp.soundfile, applycontext = applycontext, applycontexttoworld = applycontexttoworld, volume = volume, func = Func, then = then })
	}
	
	local kind = ResponseKind.none
	if ( scene )
	{
		kind = ResponseKind.scene
	}
	else if ( func )
	{
		kind = ResponseKind.script
	}
	else
	{
		print("Unable to parse response: \n")
		resp.Describe()
		return null
	}
	
	return ::VSLib.ResponseRules.ResponseSingle( kind, scene, null, func, resp )
}

function VSLib::ResponseRules::ProcessRules( rulesarray )
{
	local debug_rules_arr = []
	foreach( rule in rulesarray )
	{
		// need to bind the rr_ProcessCriterion function in a closure containing this environment,
		// otherwise for whatever reason it won't be able to find the Criterion and CriterionFunctor
		// classes in its scope.
		local coderule = ::VSLib.ResponseRules.Rule( rule.name, 
			rule.criteria.map( ::VSLib.ResponseRules.ProcessCriterion.bindenv( this ) ),
			rule.responses.map( ::VSLib.ResponseRules.ProcessResponse.bindenv( this ) ),
			rule.group_params )
		// fix up 'rule' in each response
		foreach ( r in coderule.responses )
		{
			r.rule = coderule
		}

		if( !::VSLib.ResponseRules.FollowupDatabase.AddRule( coderule ) )
		{
			throw "Failed to add rule to followup database: " + rule
		}

		if( !rr_AddDecisionRule( coderule ) )
		{
			throw "Failed to add rule to decision database: " + rule
		}
		// print("-- ADDED RULE--\n")
		// coderule.Describe()
		debug_rules_arr.push(coderule)
	}
}

// Each individual rule has:
// a name 
// criteria
// responses
//	if the response has a 'func' parameter, it is interpreted to be a script function that gets called with the following two parameters:
//	* query - the entire fact array passed to the matching system
//	* speaker - the 'speaker' param as an entity
//  in addition, it gets a bound environment so that every key in the response table gets seen as a local variable in the function.
// an optional 'group_params'  which emulates the norepeat/sequential/permitrepeats behavior from rr1.
//	it is an RGroupParams object, see above.
// if a response is a function, it gets called with parameters (speaker, query)

// fake rule table to test my parsing 
// g_ignoredecisionrules <- [
// {
// 	name = "CoachSeeSmoker",
// 	criteria = [
// 		[ "concept", "onSeeEnemy" ], // arrays of two entries are considered to be fact = value
// 		[ "speaker", "coach" ],
// 		[ "numAllies", 1, 4 ],	// arrays of three entries are considered to be fact >= x && fact <= y
// 		[ "enemyType", "smoker" ],
// 		[ @(query) (query.GameTime) < 30 ] // arrays of one entry are expected to be functions
// 	],
// 	responses = [
// 		{ scenename = "coach_see_smoker_1.vcd", // if a 'scenename' key is present, this is expected to be a 'scene' response
// 		  soundlevel = 80,
// 		  onFinish = @(query, speaker) speaker.smokersSeen += 1 // expected to be a function
// 		} , {
// 		  func = ZombieFreakout // if a 'func' key is present, this is expected to be a 'do function' response 
// 		} , {
// 		  func = @(query,speaker) speaker.PointAt( query.enemy ) // anonymous functions are ok too
// 		} , {
// 		  scenename = "coach_see_smoker_2.vcd",
// 		  sndlevel = 90,
// 		  onFinish = @(speaker, query) speaker.smokersSeen += 1
// 		}
// 	],
// 	group_params = RGroupParams({ permitrepeats = false, sequential = true, norepeat = false })
// },
// { // another rule to test that I don't inadvertently write state shared between rules
// 	name = "Dummy", 
// 	criteria = [
// 		[ "concept", "dummy" ], // arrays of two entries are considered to be fact = value
// 		[ "speaker", "zombie" ]
// 	],
// 	responses = [
// 		{ scenename = "zombie.vcd", // if a 'scenename' key is present, this is expected to be a 'scene' response
// 		  sndlevel = 80,
// 		  onFinish = @(speaker, query) speaker.smokersSeen += 1 // expected to be a function
// 		} 
// 	],
// 	group_params = RGroupParams( ) // default 
// }
// ]




function VSLib::ResponseRules::DebugPrint( string )
{
	printl( "RR_TESTBED: " + string )
}

function VSLib::ResponseRules::PrintTable( tabl, prefix = "\t" )
{
	foreach ( k,v in tabl )
		print(prefix + k + " : " + v + "\n")
}


// Define an individual "static" criterion, varying between a bottom and top integral value
class ::VSLib.ResponseRules.Criterion
{
	//constructor
	constructor( k, b, t )
	{
		key = k
		bottom = b
		top = t
	}
	
	//member function
	function Describe()
	{
		printl( "Criterion " + key + " " + bottom + ".." + top )
	}
	
	//property
	key = null;
	bottom = null;
	top = null;
}

// Define a functor criterion, where the comparator is a function returning a bool
class ::VSLib.ResponseRules.CriterionFunc
{
	//constructor
	constructor( k, f )
	{
		key = k
		func = f
	}
	
	//member function
	function Describe()
	{
		printl( "Criterion functor " + key + " -> " + func )
	}
	
	//property
	key = null;
	func = null;
}

// Multiple lines
// response <responsegroupname>
// {
//		[permitrepeats]   ; optional parameter, by default we visit all responses in group before repeating any
//		[sequential]	  ; optional parameter, by default we randomly choose responses, but with this we walk through the list starting at the first and going to the last
//		[norepeat]		  ; Once we've run through all of the entries, disable the response group
//		responsetype1 parameters1 [nodelay | defaultdelay | delay interval ] [speakonce] [odds nnn] [respeakdelay interval] [soundelvel "SNDLVL_xxx"] [displayfirst] [ displaylast ] weight nnn
//		responsetype2 parameters2 [nodelay | defaultdelay | delay interval ] [speakonce] [odds nnn] [respeakdelay interval] [soundelvel "SNDLVL_xxx"] [displayfirst] [ displaylast ] weight nnn
//		etc.
// }


// Represents an individual rule as sent from script to C++
// TODO: handle ApplyContextToWorld
class ::VSLib.ResponseRules.Rule
{
	constructor( name, crits, _responses, _group_params )
	{
		rulename = name
		criteria = crits
		responses = _responses
		group_params = _group_params
		
		// type-check
		assert( responses.len() > 0 )
		
		// make a shallow copy of selection_state to avoid overwriting shared state
		// (otherwise changes made in one instance will affect all others)
		selection_state = clone selection_state
		
		
		// make an array of one 'false' per response (eg no response has played yet)
		selection_state.playedresponses <- responses.map( @(x) false )
	}
	
	function Describe( verbose = true )
	{
		printl( rulename + "\n" + criteria.len() + " crits, " + responses.len() + " responses" )
		if ( verbose )
		{
			foreach (crit in criteria)
			{
				crit.Describe()
			}
			foreach (resp in responses)
			{
				resp.Describe()
			}
			printl("selection_state:")
			foreach ( k,v in selection_state )
				print("\t" + k + " : " + v + "\n")
			print("\n")
		}
	}
		
	// for some reason can't resolve this from file scope?
	function ChooseRandomFromArray( arr )
	{
		local l = arr.len()
		if ( l > 0 )
		{
			return arr[RandomInt( 0, l - 1 ) ]
		}
		else
			return null
	}
	
	// When a rule matches, call this to pick a response.
	// TODO: test
	function SelectResponse()
	{
		if ( Convars.GetFloat("rr_debugresponses") > 0 )
		{
			print("Matched rule: " )
			Describe( false )
		}
		if ( group_params.permitrepeats )
		{
			// just randomly pick a response
			local R = ChooseRandomFromArray( responses )
			
			if ( Convars.GetFloat("rr_debugresponses") > 0 )
			{
				print("Matched " )
				R.Describe()
			}
			
			return R
		}
		// else...
		// get a list of response *indexes* that haven't played yet
		local unplayed_resps = []
		foreach (idx,val in selection_state.playedresponses)
		{
			if ( !val ) // if not been played...
			{
				unplayed_resps.push( idx )
			}
		}
		
		if ( unplayed_resps.len() == 0 ) // out of unplayed responses, what do we do?
		{
			if (group_params.norepeat)
			{
				Disable()
				return // do nothing
			}
			else //reset
			{
				selection_state.playedresponses = responses.map( @(x) false )
			}
		}
		
		// okay, now pick a response
		if ( group_params.sequential )
		{
			local retval = selection_state.nextseq
			selection_state.nextseq = (selection_state.nextseq + 1) % responses.len() // advance sequential counter
			assert( selection_state.playedresponses[retval] == false )
			// mark this response as played
			selection_state.playedresponses[retval] = true
			local R = responses[retval]
			
			if ( Convars.GetFloat("rr_debugresponses") > 0 )
			{
				print("Matched " )
				R.Describe()
			}
			return R
		}
		else
		{
			// choose randomly from available unplayed responses
			local retval = ChooseRandomFromArray( unplayed_resps )
			selection_state.playedresponses[retval] = true
			local R = responses[retval]
			
			if ( Convars.GetFloat("rr_debugresponses") > 0 )
			{
				print("Matched " )
				R.Describe()
			}
			return R
		}
	}
	
	// tell the response engine to disable me
	function Disable()
	{
		printl( "TODO: rule " + rulename + " wants to disable itself." )
	}
	
	// properties
	rulename = null;
	criteria = [];
	responses = [];
	group_params = null;
	
	// handles the 'response group' state which is
	// used to pick the next response in sequence, etc
	selection_state =
	{
		nextseq = 0, // next response to play if 'sequential' is true
		playedresponses = [], // an array containing one bool per response -- indicating whether it's played or not, to handle 'permitrepeats'
	}
}




// Add a weak reference to the global table.
::ResponseRules <- ::VSLib.ResponseRules.weakref();
::Criterion <- ::VSLib.ResponseRules.Criteria.weakref();