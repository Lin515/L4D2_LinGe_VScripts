/*  
 * Copyright (c) 2013 Rectus
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
 * \brief Spawns random items on predefined spawnpoints.
 *
 * This class can spawn items randomly selected from a predefined list onto randomly selected spawnpoints.
 *  
 * @param spawnPoints Array of vectors or VSLib entities where the items can spawn.
 * @param items Array of item entries the spawner chooses from.
 * @param flags Option flags. Currently supports RANDOM_USEPARTICLES and RANDOM_ALLOWMULTIPLEITEMS.
 * 
 */
 class ::VSLib.RandomItemSpawner
 {
	/* 
	* This is a list of the currently supported items. 
	*
	* ent: Classname of the item. The spawn list currently supports the entities specified below.
	* prob: This is the probability for the item to spawn. It's relative to the other items.
	* ammo: The ammo reserves primary weapons spawn with. Weapons spawn with double the value set. 
	* 		 Set to null on other items.
	* melee_type: Works the same way as on a weapon_melee_spawn. Set to null if not a melee weapon. 
	*/
	static _defaultItems =
	[
		//Entity:						Probability:	Ammo:			Melee type:
		{ent = "weapon_rifle"			prob = 10,		ammo = 50,	melee_type = null	},
		{ent = "weapon_shotgun_spas"	prob = 10,		ammo = 10,	melee_type = null	},
		{ent = "weapon_sniper_military"	prob = 10,		ammo = 15,	melee_type = null	},
		{ent = "weapon_rifle_ak47"		prob = 10,		ammo = 40,	melee_type = null	},
		{ent = "weapon_autoshotgun"		prob = 10,		ammo = 10,	melee_type = null	},
		{ent = "weapon_rifle_desert"	prob = 10,		ammo = 60,	melee_type = null	},
		{ent = "weapon_hunting_rifle"	prob = 15,		ammo = 15,	melee_type = null	},
		
		{ent = "weapon_rifle_m60"		prob = 2,		ammo = 50,	melee_type = null	},
		{ent = "weapon_grenade_launcher"	prob = 2,	ammo = 50,	melee_type = null	},
		
		{ent = "weapon_smg_silenced"	prob = 20,		ammo = 50,	melee_type = null	},
		{ent = "weapon_smg"				prob = 20,		ammo = 50,	melee_type = null	},
		{ent = "weapon_shotgun_chrome"	prob = 20,		ammo = 10,	melee_type = null	},
		{ent = "weapon_pumpshotgun"		prob = 20,		ammo = 10,	melee_type = null	},
		
		{ent = "weapon_pistol_magnum"	prob = 5,		ammo = null,	melee_type = null	},
		{ent = "weapon_pistol"			prob = 10,		ammo = null,	melee_type = null	},
		
		{ent = "weapon_adrenaline" 		prob = 10,		ammo = null,	melee_type = null	},	
		{ent = "weapon_pain_pills" 		prob = 20,		ammo = null,	melee_type = null	},
		{ent = "weapon_vomitjar" 		prob = 3,		ammo = null,	melee_type = null	},
		{ent = "weapon_molotov" 		prob = 10,		ammo = null,	melee_type = null	},
		{ent = "weapon_pipe_bomb" 		prob = 10,		ammo = null,	melee_type = null	},
		{ent = "weapon_first_aid_kit" 	prob = 1,		ammo = null,	melee_type = null	},
		
		
		// Note: These items don't retain their entities when spawned, and cannot be tracked.
		{ent = "weapon_melee_spawn"		prob = 10,		ammo = null,	melee_type = "any"	},
		{ent = "upgrade_spawn" 			prob = 3,		ammo = null,	melee_type = null	}, // Laser sight
		{ent = "weapon_upgradepack_explosive" 		prob = 5,		ammo = null,	melee_type = null	},
		{ent = "weapon_upgradepack_incendiary" 		prob = 7,		ammo = null,	melee_type = null	},	

	];
	_totalProbability = 0;
	_numSpawns = 0;
	_spawnPoints = [];
	_items = [];
	_useParticleEffects =  false;
	_allowMultipleItemsOnPoint = false;

	constructor(spawnPoints, items = null, flags = 0)
	{
		if(items)
			_items = items;
		else
			_items = _defaultItems;

		_useParticleEffects = (flags & RANDOM_USEPARTICLES)
		_allowMultipleItemsOnPoint = (flags & RANDOM_ALLOWMULTIPLEITEMS)

		__FindItemSpawnPoints(spawnPoints);
		__CalcTotalProbability();
	}
	
	function _typeof()
	{
		return "VSLIB_RANDOM_ITEM_SPAWNER";
	}
	
}

/**
 * Global flags.
 */
getconsttable()["RANDOM_USEPARTICLES"] 			<- 1;
getconsttable()["RANDOM_ALLOWMULTIPLEITEMS"] 	<- 2;
 
 

/**
 * Extracts spawnpoint locations and amount from an array of vectors or entities.
 */
function VSLib::RandomItemSpawner::__FindItemSpawnPoints(spawns)
{
	local spawnPoints = [];
	local numSpawns = 0;

	foreach(object in spawns)
	{
		switch(typeof object)
		{
			case "Vector":
				spawnPoints.push(Vector(0,0,0) + object);
				numSpawns++;
				break;
				
			case "VSLIB_ENTITY":
			case "VSLIB_PLAYER":
				spawnPoints.push(object.GetLocation());
				numSpawns++;
				break;
				
			default:
				printl("VSLib Warning: Random item spawner: Invalid spawnpoint! " + object);
		}
	}
	
	if(numSpawns  <= 0)
		printl("VSLib Error: Random item spawner: No item spawns found!");
	else
		printl("VSLib: Random item spawner: Found " + numSpawns 
		+ " item spawns.");
	
	_spawnPoints = spawnPoints;
	_numSpawns = numSpawns;
}

/**
 * Calculates the combined spawn probability of all items.
 */
function VSLib::RandomItemSpawner::__CalcTotalProbability()
{
	local totalProb = 0;
	foreach(item in _items)
		totalProb += item.prob;
		
	_totalProbability = totalProb;
}

/**
 * Spawns specified number of random items. 
 *
 * @return Items spawned as an array of VSLib entities.
 */
function VSLib::RandomItemSpawner::SpawnRandomItems(amount)
{
	local spawnedItems = [];
	local spawnSet = clone _spawnPoints;
	local entity = null;
	
	for(local i = 0; i < amount; i++)
	{
		if(spawnSet.len() < 1)
		{
			printl("VSLib Warning: Random item spawner: Ran out of spawn points!");
			return spawnedItems;
		}
	
		local probCount = RandomInt(1, _totalProbability);
		local spawnIndex = RandomInt(0, spawnSet.len() -1);
		
		foreach(item in _items)
		{
			if((probCount -= item.prob) <= 0)
			{
				if(entity = __SpawnSingleItem(g_ModeScript.DuplicateTable(item), spawnSet[spawnIndex]))
					spawnedItems.push(entity);
					
				break;
			}
		}
		if(!_allowMultipleItemsOnPoint)
			spawnSet.remove(spawnIndex);
	}
	
	return spawnedItems;
}


/**
 * Generates an entity table and spawns an item of the specified type.
 */ 
function VSLib::RandomItemSpawner::__SpawnSingleItem(item, origin)
{
	local entTable = {};
	
	if(item.ammo != null) // Gun
		entTable =
		{
			targetname	= "random_spawned_item"
			classname	= item.ent
			ammo		= item.ammo
			origin		= origin
			angles		= Vector(0, RandomFloat(0, 360), (RandomInt(0,1) * 180 - 90))
			solid		= "6" // Vphysics
		}
	else if(item.melee_type != null) // Melee weapon
		entTable =
		{
			targetname	= "random_spawned_nontrackable"
			classname	= item.ent
			origin		= origin
			angles		= Vector(0, RandomFloat(0, 360), (RandomInt(0,1) * 180 - 90))
			solid		= "6" // Vphysics
			melee_weapon	= item.melee_type
			spawnflags	= 3
		}
	else if(item.ent == "upgrade_spawn") // Laser upgrade
	{
		entTable =
		{
			targetname	= "random_spawned_nontrackable"
			classname	= item.ent
			origin		= origin
			angles		= Vector(0, RandomFloat(0, 360), 0)
			solid		= "6" // Vphysics
			laser_sight = 1
			upgradepack_incendiary = 0
			upgradepack_explosive = 0
		}
	}
	else if((item.ent == "weapon_upgradepack_explosive") || (item.ent == "weapon_upgradepack_incendiary"))
	{
		entTable =
		{
			targetname	= "random_spawned_nontrackable"
			classname	= item.ent
			origin		= origin
			angles		= Vector(0, RandomFloat(0, 360), 0)
			solid		= "6" // Vphysics
		}
	}	
	else // Any other item
		entTable =
		{
			targetname	= "random_spawned_item"
			classname	= item.ent
			origin		= origin
			angles		= Vector(0, RandomFloat(0, 360), 0)
			solid		= "6" // Vphysics
		}
	
	local itemEntity = g_ModeScript.CreateSingleSimpleEntityFromTable(entTable);
	
	if(itemEntity)
	{
		if(_useParticleEffects)
			g_ModeScript.CreateParticleSystemAt(itemEntity, Vector(0,0,-8), "mini_fireworks");
		
		if(entTable.targetname == "random_spawned_item")
			return ::VSLib.Entity(itemEntity);
	}
	return null;
}
