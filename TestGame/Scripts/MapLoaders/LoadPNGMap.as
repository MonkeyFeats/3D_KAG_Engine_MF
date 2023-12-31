//#include "Create3DWorld.as";

//The engine requires the CMap/TileMap references to not be null
bool LoadMap(CMap@ map, const string&in fileName)
{
	if(!isServer())
	{ map.CreateTileMap(16, 16, 8.0f, "Sprites/world.png"); return true; }

	map.CreateTileMap(16, 16, 8.0f, "Sprites/world.png");
	map.topBorder = map.bottomBorder = map.rightBorder = map.leftBorder = false;

	return true;
}