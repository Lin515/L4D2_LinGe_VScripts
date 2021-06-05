///////////////////////////////////////////////////////////////////////////////
// Scriptedmode.nut 
//  this holds the "control logic" for all scriptmodes, and loads up the Mode 
//  and Map specific subscripts thus it has various initialization, 
//  default/override table merging, and a "root" manager class
///////////////////////////////////////////////////////////////////////////////

LinGe_ScriptMode_Init <- ScriptMode_Init;
//=========================================================
// called from C++ when you try and kick off a mode to 
// decide whether scriptmode wants to handle it
//=========================================================
function ScriptMode_Init( modename, mapname )
{
	local bScriptedModeValid = LinGe_ScriptMode_Init( modename, mapname );
	
	//Include server.nut for LinGe Scripts
	IncludeScript("server");
	
	if ( !bScriptedModeValid )
	{
		printl( "Enabled ScriptMode for " + modename + " and now Initializing" );
		
		IncludeScript( mapname + "_" + modename, g_MapScript );

		// Add to the spawn array
		MergeSessionSpawnTables();
		MergeSessionStateTables();

		SessionState.MapName <- mapname;
		SessionState.ModeName <- modename;

		// If not specified, start active by default
		if ( !( "StartActive" in SessionState ) )
		{
			SessionState.StartActive <- true;
		}

		if ( SessionState.StartActive )
		{
			MergeSessionOptionTables();
		}
		
		// Sanitize the map
		if ( "SanitizeTable" in this )
		{
			SanitizeMap( SanitizeTable );
		}
		
		if ( "SessionSpawns" in getroottable() )
		{
			EntSpawn_DoIncludes( ::SessionSpawns );
		}

		// include all helper stuff before building the help
		IncludeScript( "sm_stages", g_MapScript );

		// check for any scripthelp_<funcname> strings and create help entries for them
		AddToScriptHelp( getroottable() );
		AddToScriptHelp( g_MapScript );
		AddToScriptHelp( g_ModeScript );
		
		// go ahead and call all the precache elements - the MapSpawn table ones then any explicit OnPrecache's
		ScriptedPrecache();
		ScriptMode_SystemCall("Precache");
	}
	
	return true;
}