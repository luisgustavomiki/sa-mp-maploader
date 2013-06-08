#include <a_samp>
#include <streamer>
#include <xml>

main() {}

/*
 * MapDev Loader Script by steki 
 * 04/04/2013
 * 
 */
 #define function%0(%1) forward%0(%1); public%0(%1)
 #define MAP_LISTING_FILE "maps\\listing.xml"
 #define MAP_BASE_DIR "maps\\"

 enum ObjectPreset {
 	OBJECT_PRESET_NONE,
 	OBJECT_PRESET_BUILDING,
 	OBJECT_PRESET_INTERIOR_BASE,
 	OBJECT_PRESET_INTERIOR_OBJECT,
 }

 new XMLFile:listingFile;

stock HexToInt(string[])
{
    if (string[0] == 0)
    {
        return 0;
    }
    new i;
    new cur = 1;
    new res = 0;
    for (i = strlen(string); i > 0; i--)
    {
        if (string[i-1] < 58)
        {
            res = res + cur * (string[i - 1] - 48);
        }
        else
        {
            res = res + cur * (string[i-1] - 65 + 10);
            cur = cur * 16;
        }
    }
    return res;
}

/*
	Map Pointer Containters 
*/
 new XMLPointer:loadedMapSets[250] = {XMLPointer:-1, ...};

function Map_PushMapSet(XMLPointer:pointer) {
	for(new i = 0; i < sizeof loadedMapSets; i++) {
		if(_:loadedMapSets[i] == -1) {
			loadedMapSets[i] = pointer;
			return true;
		}
	}
	return false;
}

function Map_UnloadAll() {
	for(new i = 0; i < sizeof loadedMapSets; i++) {
		if(_:loadedMapSets[i] != -1) {
			Map_UnloadMapset(loadedMapSets[i]);
			xml_killpointer(loadedMapSets[i]);
			loadedMapSets[i] = XMLPointer:-1;
		}
	}
	return true;
}

// End Map Pointer Containers

public OnFilterScriptInit() {
	SetTimer("Map_Init", 500, false);
	return 1;
}

public OnFilterScriptExit() {
	Map_UnloadAll();
	return 1;
}

public OnPlayerConnect(playerid) {
	Map_LoadRemovedObjects(playerid);
	return 1;
}

function Map_Init() {
	Map_LoadListings();
	for(new i; i < MAX_PLAYERS; i++) {
		if(IsPlayerConnected(i))
			Map_LoadRemovedObjects(i);
	}
	return 1;
}

function Map_LoadListings() {
	listingFile = xml_open(MAP_LISTING_FILE);
	if(_:listingFile) {
		printf(" -- MapDev Loader - loading mapset listing file.");
		
		new XMLPointer:rootNode = xml_pointer(listingFile);

		if(xml_pointer_childnode(rootNode, "maplisting")) {
			new XMLPointer:mapSet = xml_clonepointer(rootNode);
			if(xml_pointer_childnode(mapSet, "mapset")) {
				do {
					new XMLPointer:attribute = xml_clonepointer(mapSet),
						name[64], path[64];

					if(xml_pointer_childattr(attribute, "name")) {
						xml_pointer_getvalue(attribute, name, 64);
					}

					if(xml_pointer_nextattr(attribute)) {
						xml_pointer_getvalue(attribute, path, 64);
					}

					Map_LoadMapset(name, path);
					xml_killpointer(attribute);
				} while(xml_pointer_nextnode(mapSet, "mapset"));
			}
			xml_killpointer(mapSet);
		} else {
			printf(" -- MapDev Loader - no mapset found.");
		}

		xml_killpointer(rootNode);
	} else {
		printf(" -- MapDev Loader - mapset listing file not found.");
		printf("\tMake sure the following path has a valid xml file: " MAP_LISTING_FILE);
	}
	return 1;
}

function Map_LoadMapset(name[], path[]) {
	printf(" -- MapDev Loader - loading mapset \"%s\" at \"%s\"", name, path);
	new pathFix[128];
	strcat(pathFix, MAP_BASE_DIR);
	strcat(pathFix, path);

	new XMLFile:file = xml_open(pathFix);

	if(!_:file) {
		printf(" -- MapDev Loader - mapset \"%s\" not loaded: invalid file/path", name);
		return 1;
	}
	new mapscount;
	new XMLPointer:rootNode = xml_pointer(file);
	if(xml_pointer_childnode(rootNode, "mapset")) {
		new XMLPointer:mapNode = xml_clonepointer(rootNode),
			XMLPointer:mapSetAttr = xml_clonepointer(rootNode);

		Map_PushMapSet(xml_clonepointer(rootNode));

		new mapSetName[64];
		if(xml_pointer_childattr(mapSetAttr, "name")) {
			xml_pointer_getvalue(mapSetAttr, mapSetName);
		}
		printf(" -- MapDev Loader - loading mapset \"%s\"", mapSetName);

		if(xml_pointer_childnode(mapNode, "map")) {
			do {
				mapscount++;
				new XMLPointer:mapAttr = xml_clonepointer(mapNode),
					XMLPointer:mapObject = xml_clonepointer(mapNode),
					mapName[64], mapAuthor[64], objectcount;

				if(xml_pointer_childattr(mapAttr, "name")) {
					xml_pointer_getvalue(mapAttr, mapName);
				}
				if(xml_pointer_nextattr(mapAttr, "author")) {
					xml_pointer_getvalue(mapAttr, mapAuthor);
				}

				/* Objects Loop */
				if(xml_pointer_childnode(mapObject, "object")) {
					do {
						++objectcount;
						new model = 0,
							Float:x = 0.0,
							Float:y = 0.0,
							Float:z = 0.0,
							Float:rx = 0.0,
							Float:ry = 0.0,
							Float:rz = 0.0,
							virtualworld = -1, interior = -1,
							ObjectPreset:preset, 
							Float:distance = 300.0, 
							buffer[64];

						new XMLPointer:objectAttr = xml_clonepointer(mapObject);
						if(xml_pointer_childattr(objectAttr, "model")) {
							model = xml_pointer_getvalue_int(objectAttr);
							xml_pointer_parentnode(objectAttr);
						}
						if(xml_pointer_childattr(objectAttr, "x")) {
							x = xml_pointer_getvalue_float(objectAttr);
							xml_pointer_parentnode(objectAttr);
						}
						if(xml_pointer_childattr(objectAttr, "y")) {
							y = xml_pointer_getvalue_float(objectAttr);
							xml_pointer_parentnode(objectAttr);
						}
						if(xml_pointer_childattr(objectAttr, "z")) {
							z = xml_pointer_getvalue_float(objectAttr);
							xml_pointer_parentnode(objectAttr);
						}
						if(xml_pointer_childattr(objectAttr, "rx")) {
							rx = xml_pointer_getvalue_float(objectAttr);
							xml_pointer_parentnode(objectAttr);
						}
						if(xml_pointer_childattr(objectAttr, "ry")) {
							ry = xml_pointer_getvalue_float(objectAttr);
							xml_pointer_parentnode(objectAttr);
						}
						if(xml_pointer_childattr(objectAttr, "rz")) {
							rz = xml_pointer_getvalue_float(objectAttr);
							xml_pointer_parentnode(objectAttr);
						}
						if(xml_pointer_childattr(objectAttr, "preset")) {
							xml_pointer_getvalue(objectAttr, buffer);
							if(!strcmp(buffer, "building", true)) {
								preset = OBJECT_PRESET_BUILDING;
								virtualworld = 0;
								interior = 0;
								distance = 1500.0;
								//drawdistance = 1500.0;
							}
							if(!strcmp(buffer, "ibase", true)) {
								virtualworld = -1;
								interior = 1;
								distance = 1500.0;
								preset = OBJECT_PRESET_INTERIOR_BASE;
							}
							if(!strcmp(buffer, "interior", true)) {
								virtualworld = -1;
								interior = 1;
								preset = OBJECT_PRESET_INTERIOR_OBJECT;
							}
							xml_pointer_parentnode(objectAttr);
						}
						if(xml_pointer_childattr(objectAttr, "virtualworld")) {
							virtualworld = xml_pointer_getvalue_int(objectAttr);
							xml_pointer_parentnode(objectAttr);
						}
						if(xml_pointer_childattr(objectAttr, "interior")) {
							interior = xml_pointer_getvalue_int(objectAttr);
							xml_pointer_parentnode(objectAttr);
						}
						if(xml_pointer_childattr(objectAttr, "distance")) {
							distance = xml_pointer_getvalue_float(objectAttr);
							xml_pointer_parentnode(objectAttr);
						}
						new vw[1]; vw[0] = virtualworld;
						new int[1]; int[0] = interior;
						new id = CreateDynamicObjectEx(model, x, y, z, rx, ry, rz, distance, distance, vw, int);

						if(id) {
							new tmp[11]; format(tmp, sizeof tmp, "%d", id);
							xml_pointer_appendattr(mapObject, "INTERNALid", tmp);

							new XMLPointer:materialNode = xml_clonepointer(mapObject);
							if(xml_pointer_childnode(materialNode, "material")) {
								do {
									new XMLPointer:materialAttr = xml_clonepointer(materialNode),
										index, tmodel, txdname[64], texturename[64], materialcolor;

									if(xml_pointer_childattr(materialAttr, "index")) {
										index = xml_pointer_getvalue_int(materialAttr);
										xml_pointer_parentnode(materialAttr);
									}
									if(xml_pointer_childattr(materialAttr, "model")) {
										tmodel = xml_pointer_getvalue_int(materialAttr);
										xml_pointer_parentnode(materialAttr);
									}
									if(xml_pointer_childattr(materialAttr, "txdname")) {
										xml_pointer_getvalue(materialAttr, txdname);
										xml_pointer_parentnode(materialAttr);
									}
									if(xml_pointer_childattr(materialAttr, "texturename")) {
										xml_pointer_getvalue(materialAttr, texturename);
										xml_pointer_parentnode(materialAttr);
									}
									if(xml_pointer_childattr(materialAttr, "materialcolor")) {
										new tbuffer[15];
										xml_pointer_getvalue(materialAttr, tbuffer);
										materialcolor = HexToInt(tbuffer);
										xml_pointer_parentnode(materialAttr);
									}

									SetDynamicObjectMaterial(id, index, tmodel, txdname, texturename, materialcolor);

									xml_killpointer(materialAttr);
								} while(xml_pointer_nextnode(materialNode, "material"));
							}
							xml_killpointer(materialNode);

							new XMLPointer:textNode = xml_clonepointer(mapObject);
							if(xml_pointer_childnode(textNode, "text")) {
								do {
									new XMLPointer:textAttr = xml_clonepointer(textNode),
										text[128], index, materialsize = 10, font[64], size = 24, bold = 1, color = -1, backcolor = 0, align;

									format(font, sizeof font, "Arial");
									if(xml_pointer_childattr(textAttr, "index")) {
										index = xml_pointer_getvalue_int(textAttr);
										xml_pointer_parentnode(textAttr);
									}
									if(xml_pointer_childattr(textAttr, "text")) {
										xml_pointer_getvalue(textAttr, text);
										xml_pointer_parentnode(textAttr);
									}			
									if(xml_pointer_childattr(textAttr, "materialsize")) {
										new tbuffer[64];
										xml_pointer_getvalue(textAttr, tbuffer);
										if(!strcmp(tbuffer, "32x32", true)) {
											materialsize = 10;
										}
										if(!strcmp(tbuffer, "64x32", true)) {
											materialsize = 20;
										}
										if(!strcmp(tbuffer, "64x64", true)) {
											materialsize = 30;
										}
										if(!strcmp(tbuffer, "128x32", true)) {
											materialsize = 40;
										}
										if(!strcmp(tbuffer, "128x64", true)) {
											materialsize = 50;
										}
										if(!strcmp(tbuffer, "128x128", true)) {
											materialsize = 60;
										}
										if(!strcmp(tbuffer, "256x32", true)) {
											materialsize = 70;
										}
										if(!strcmp(tbuffer, "256x64", true)) {
											materialsize = 80;
										}
										if(!strcmp(tbuffer, "256x128", true)) {
											materialsize = 90;
										}
										if(!strcmp(tbuffer, "256x256", true)) {
											materialsize = 100;
										}
										if(!strcmp(tbuffer, "512x64", true)) {
											materialsize = 110;
										}
										if(!strcmp(tbuffer, "512x128", true)) {
											materialsize = 120;
										}
										if(!strcmp(tbuffer, "512x256", true)) {
											materialsize = 130;
										}
										if(!strcmp(tbuffer, "512x512", true)) {
											materialsize = 140;
										}
										xml_pointer_parentnode(textAttr);
									}
									if(xml_pointer_childattr(textAttr, "font")) {
										xml_pointer_getvalue(textAttr, font);
										xml_pointer_parentnode(textAttr);
									}
									if(xml_pointer_childattr(textAttr, "size")) {
										size = xml_pointer_getvalue_int(textAttr);
										xml_pointer_parentnode(textAttr);
									}
									if(xml_pointer_childattr(textAttr, "bold")) {
										bold = xml_pointer_getvalue_int(textAttr);
										xml_pointer_parentnode(textAttr);
									}
									if(xml_pointer_childattr(textAttr, "color")) {
										new tbuffer[15];
										xml_pointer_getvalue(textAttr, tbuffer);
										color = HexToInt(tbuffer);
										xml_pointer_parentnode(textAttr);
									}
									if(xml_pointer_childattr(textAttr, "backcolor")) {
										new tbuffer[15];
										xml_pointer_getvalue(textAttr, tbuffer);
										backcolor = HexToInt(tbuffer);
										xml_pointer_parentnode(textAttr);
									}
									if(xml_pointer_childattr(textAttr, "align")) {
										new tbuffer[64];
										xml_pointer_getvalue(textAttr, tbuffer);
										if(!strcmp(tbuffer, "left", true)) {
											materialsize = 0;
										}
										if(!strcmp(tbuffer, "center", true)) {
											materialsize = 1;
										}
										if(!strcmp(tbuffer, "right", true)) {
											materialsize = 2;
										}
										xml_pointer_parentnode(textAttr);
									}

									SetDynamicObjectMaterialText(id, index, text, materialsize, font, size, bold, color, backcolor, align);
									//printf("%d %s %d %s %d %d %x %x %d", index, text, materialsize, font, size, bold, color, backcolor, align);
									xml_killpointer(textAttr);
								} while(xml_pointer_nextnode(textNode, "material"));
							}
							xml_killpointer(textNode);

						}
						//printf("//debug: m%d, x%f y%f z%f, vw%d int%d")

						xml_killpointer(objectAttr);
					} while(xml_pointer_nextnode(mapObject, "object"));
				}

				printf(" -- MapDev Loader - map \"%s\" by %s loaded: %d objects", mapName, mapAuthor, objectcount);
				xml_killpointer(mapAttr);
				xml_killpointer(mapObject);
			} while(xml_pointer_nextnode(mapNode, "map"));
		}
		xml_killpointer(mapNode);
		xml_killpointer(mapSetAttr);
	}
	xml_killpointer(rootNode);
	return 1;
}

function Map_UnloadMapset(XMLPointer:mapSet) {
	new XMLPointer:mapNode = xml_clonepointer(mapSet);
	if(xml_pointer_childnode(mapNode, "map")) {
		do {
			new
				XMLPointer:mapObject = xml_clonepointer(mapNode);

			/* Objects Loop */
			if(xml_pointer_childnode(mapObject, "object")) {
				do {
					new XMLPointer:objectAttr = xml_clonepointer(mapObject);
					if(xml_pointer_childattr(objectAttr, "INTERNALid")) {
						new object = xml_pointer_getvalue_int(objectAttr);
						DestroyDynamicObject(object);
						xml_pointer_parentnode(objectAttr);
					}
					xml_killpointer(objectAttr);
					
				} while(xml_pointer_nextnode(mapObject, "object"));
			}
			xml_killpointer(mapObject);
		} while(xml_pointer_nextnode(mapNode, "map"));
	}
	xml_killpointer(mapNode);
	return true;
}

function Map_LoadRemovedObjects(playerid) {
	for(new i = 0; i < sizeof loadedMapSets; i++) {
		if(_:loadedMapSets[i] != -1) {
			new XMLPointer:mapNode = xml_clonepointer(loadedMapSets[i]);
			if(xml_pointer_childnode(mapNode, "map")) {
				do {
					new XMLPointer:mapRemove = xml_clonepointer(mapNode);
					if(xml_pointer_childnode(mapRemove, "remove")) {
						do {
							new XMLPointer:removeAttr = xml_clonepointer(mapRemove),
								model, Float:x, Float:y, Float:z, Float:r;

							if(xml_pointer_childattr(removeAttr, "model")) {
								model = xml_pointer_getvalue_int(removeAttr);
								xml_pointer_parentnode(removeAttr);
							}
							if(xml_pointer_childattr(removeAttr, "x")) {
								x = xml_pointer_getvalue_float(removeAttr);
								xml_pointer_parentnode(removeAttr);
							}
							if(xml_pointer_childattr(removeAttr, "y")) {
								y = xml_pointer_getvalue_float(removeAttr);
								xml_pointer_parentnode(removeAttr);
							}
							if(xml_pointer_childattr(removeAttr, "z")) {
								z = xml_pointer_getvalue_float(removeAttr);
								xml_pointer_parentnode(removeAttr);
							}
							if(xml_pointer_childattr(removeAttr, "radius")) {
								r = xml_pointer_getvalue_float(removeAttr);
								xml_pointer_parentnode(removeAttr);
							}
							RemoveBuildingForPlayer(playerid, model, x, y, z, r);
							xml_killpointer(removeAttr);
						} while(xml_pointer_nextnode(mapRemove, "remove"));

					}
					xml_killpointer(mapRemove);
				} while(xml_pointer_nextnode(mapNode, "map"));
			}
			xml_killpointer(mapNode);
		}
	}
	return true;
}