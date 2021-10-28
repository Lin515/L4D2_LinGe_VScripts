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
* File I/O functions that simplify the saving and loading of data.
*/
::VSLib.FileIO <- {};


/**
 * Recursively serializes a table and returns the string. This command ignores all functions within
 * the table, saving only the primitive types (i.e. integers, floats, strings, etc with definite values).
 * The indexes that you use for your table need to be programmatically "clean," meaning that the index
 * cannot contain invalid characters like +-=!@#$%^&*() etc. Indexes that contain any kind of
 * invalid character is completely ignored. If you are trying to store player information,
 * use Player::GetUniqueID() instead of Player::GetSteamID() for the index ID.
 *
 * You probably won't need to use this function by itself. @see VSLib::FileIO::SaveTable()
 */
function VSLib::FileIO::SerializeTable(object, predicateStart = "{\n", predicateEnd = "}\n", indice = true)
{
	local baseString = predicateStart;
	
	foreach (idx, val in object)
	{
		local idxType = typeof idx;
		
		if (idxType == "instance" || idxType == "class" || idxType == "function")
			continue;
		
		// Check for invalid characters
		local idxStr = idx.tostring();
		local reg = regexp("^[a-zA-Z0-9_]*$");
		
		if (!reg.match(idxStr))
		{
			printf("VSLib Warning: Index '%s' is invalid (invalid characters found), skipping...", idxStr);
			continue;
		}
		
		// Check for numeric fields and prefix them so system can compile
		reg = regexp("^[0-9]+$");
		if (reg.match(idxStr))
			idxStr = "_vslInt_" + idxStr;
		
		
		local preCompileString = ((indice) ? (idxStr + " = ") : "");
		
		switch (typeof val)
		{
			case "table":
				baseString += preCompileString + ::VSLib.FileIO.SerializeTable(val);
				break;
			
			case "string":
				baseString += preCompileString + "\"" + ::VSLib.Utils.StringReplace(::VSLib.Utils.StringReplace(val, "\"", "{VSQUOTE}"), @"\\", "{VSSLASH}") + "\"\n"; // "
				break;
			
			case "integer":
				baseString += preCompileString + val + "\n";
				break;
			
			case "float":
				baseString += preCompileString + val + "\n";
				break;
			
			case "array":
				baseString += preCompileString + ::VSLib.FileIO.SerializeTable(val, "[\n", "]\n", false);
				break;
				
			case "bool":
				baseString += preCompileString + ((val) ? "true" : "false") + "\n";
				break;
		}
	}
	
	baseString += predicateEnd;
	
	return baseString;
}

/**
 * This function will serialize and save a table to the hard disk; useful for storing stats,
 * round times, and other important information.
 */
function VSLib::FileIO::SaveTable(fileName, table)
{
	fileName += ".tbl";
	return StringToFile(fileName, ::VSLib.FileIO.SerializeTable(table));
}

/**
 * This function will clean table input.
 */
function VSLib::FileIO::DeserializeReviseTable(t)
{
	foreach (idx, val in t)
	{
		if (typeof val == "string")
			t[idx] = ::VSLib.Utils.StringReplace(::VSLib.Utils.StringReplace(val, "{VSQUOTE}", "\""), "{VSSLASH}", @"\"); // "
		else if (typeof val == "table")
			t[idx] = DeserializeReviseTable(val);
	}
	
	return t;
}

/**
 * This function will deserialize and return the compiled table.
 * If the table does not exist, null is returned.
 */
function VSLib::FileIO::LoadTable(fileName)
{
	local contents = FileToString(fileName + ".tbl");
	
	if (!contents)
		return null;
	
	local t = compilestring( "return " + contents )();
	
	foreach (idx, val in t)
	{
		local idxStr = idx.tostring();
		
		if (idxStr.find("_vslInt_") != null)
		{
			idxStr = Utils.StringReplace(idxStr, "_vslInt_", "");
			t[idxStr.tointeger()] <- val;
			delete t[idx];
		}
	}
	
	t = DeserializeReviseTable(t);
	
	return t;
}


/**
 * This function will make the filename unique for each mapname.
 * @authors Rayman1103
 */
function VSLib::FileIO::MakeFileName( mapname, modename )
{
	return "VSLib_" + mapname + "_" + modename;
}

/**
 * This function will serialize and save a table to the hard disk from the current mapname; useful for storing stats,
 * round times, and other important information individually for every mapname.
 * @authors Rayman1103
 */
function VSLib::FileIO::SaveTableFileName(mapname, modename, table)
{
	return ::VSLib.FileIO.SaveTable(::VSLib.FileIO.MakeFileName( mapname, modename ), table);
}

/**
 * This function will deserialize and return the compiled table from the current mapname.
 * If the table does not exist, null is returned.
 * @authors Rayman1103
 */
function VSLib::FileIO::LoadTableFileName(mapname, modename)
{
	return ::VSLib.FileIO.LoadTable(::VSLib.FileIO.MakeFileName( mapname, modename ));
}



// Add a weak reference to the global table.
::FileIO <- ::VSLib.FileIO.weakref();