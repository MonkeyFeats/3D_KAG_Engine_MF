
#include "SR3DLoaderColors.as";
#include "World.as";
#include "LoadMapUtils.as";
#include "CustomBlocks.as";

Random@ map_random = Random();

class PNGLoader
{
	SColor pixel_R = sr3d_map_colors::color_water;
	SColor pixel_RU = sr3d_map_colors::color_water;
	SColor pixel_U = sr3d_map_colors::color_water;
	SColor pixel_LU = sr3d_map_colors::color_water;
	SColor pixel_L = sr3d_map_colors::color_water;
	SColor pixel_LD = sr3d_map_colors::color_water;
	SColor pixel_D = sr3d_map_colors::color_water;
	SColor pixel_RD = sr3d_map_colors::color_water;

	PNGLoader() {}

	CFileImage@ image;
	CMap@ map;

	bool loadMap(CMap@ _map, const string& in filename)
	{
		@map = _map;
		@map_random = Random();

		if(!getNet().isServer())
		{
			SetupMap(0, 0);
			return true;
		}

		@image = CFileImage( filename );
		if(image.isLoaded())
		{
			SetupMap(image.getWidth(), image.getHeight());

			while(image.nextPixel())
			{
				const SColor pixel = image.readPixel();
				const int offset = image.getPixelOffset();
				Vec2f pixelPos = image.getPixelPosition();

				handlePixelAutoLoader( pixel, offset, pixelPos );
				//handlePixelSimpleLoader( pixel, offset );

				getNet().server_KeepConnectionsAlive();
			}
			return true;
		}
		return false;
	}

	void SetupMap( int width, int height )
	{
		map.CreateTileMap( width, height, 16.0f, "world.png" );
		map.CreateSky( sr3d_map_colors::color_water );
		map.topBorder = map.bottomBorder = map.rightBorder = map.leftBorder = false;
		SetScreenFlash(255,   0,   0,   0);

		World world;
		map.set("terrainInfo", @world);
	} 
	
	void handlePixelAutoLoader( SColor pixel, int offset, Vec2f pixelPos)
	{	
		if ( image !is null && image.isLoaded() )
		{
			image.setPixelPosition( pixelPos + Vec2f(1, 0) );
			if (image.canRead())
				pixel_R = image.readPixel();
			
			image.setPixelPosition( pixelPos + Vec2f(1, -1) );
			if (image.canRead())
				pixel_RU = image.readPixel();
			
			image.setPixelPosition( pixelPos + Vec2f(0, -1) );
			if (image.canRead())
				pixel_U = image.readPixel();
			
			image.setPixelPosition( pixelPos + Vec2f(-1, -1) );
			if (image.canRead())
				pixel_LU = image.readPixel();
			
			image.setPixelPosition( pixelPos + Vec2f(-1, 0) );
			if (image.canRead())
				pixel_L = image.readPixel();
			
			image.setPixelPosition( pixelPos + Vec2f(-1, 1) );
			if (image.canRead())
				pixel_LD = image.readPixel();
			
			image.setPixelPosition( pixelPos + Vec2f(0, 1) );
			if (image.canRead())
				pixel_D = image.readPixel();
			
			image.setPixelPosition( pixelPos + Vec2f(1, 1) );
			if (image.canRead())
				pixel_RD = image.readPixel();
				
			image.setPixelOffset(offset);
		}

		switch (pixel.color)
		{	
			
			case sr3d_map_colors::color_main_spawn:
			{
				AddMarker( map, offset, "spawn" );
				PlaceMostLikelyTile(map, offset);
				break;
			}
			case sr3d_map_colors::color_palmtree: 
			{
				map.SetTile(offset, CMap::sand );
				
				CBlob@ palmtreeBlob = spawnBlob( map, "palmtree", offset, 10, false);	
				palmtreeBlob.setPosition( palmtreeBlob.getPosition() );
				palmtreeBlob.AddScript("Palmtree.as"); 
				break;
			}				

			case sr3d_map_colors::color_water_1:
			{
				map.SetTile(offset, CMap::water_1 ); break;
			}
			case sr3d_map_colors::color_water_2:
			{
				map.SetTile(offset, CMap::water_2 ); break;
			}			
			case sr3d_map_colors::color_water_3:
			{
				map.SetTile(offset, CMap::water_3 ); break;
			}
			case sr3d_map_colors::color_water_4:
			{
				map.SetTile(offset, CMap::water_4 ); break;
			}
			case sr3d_map_colors::color_water_5:
			{
				map.SetTile(offset, CMap::water_5 ); break;
			}
			case sr3d_map_colors::color_water_6:
			{
				map.SetTile(offset, CMap::water_6 ); break;
			}
			case sr3d_map_colors::color_water_7:
			{
				map.SetTile(offset, CMap::water_7 ); break;
			}
			case sr3d_map_colors::color_water_8:
			{
				map.SetTile(offset, CMap::water_8 ); break;
			}
			case sr3d_map_colors::color_water_9:
			{
				map.SetTile(offset, CMap::water_9 ); break;
			}
			case sr3d_map_colors::color_water_10:
			{
				map.SetTile(offset, CMap::water_10 ); break;
			}
			case sr3d_map_colors::color_water_11:
			{
				map.SetTile(offset, CMap::water_11 ); break;
			}
			case sr3d_map_colors::color_water_12:
			{
				map.SetTile(offset, CMap::water_12 ); break;
			}
			case sr3d_map_colors::color_water_13:
			{
				map.SetTile(offset, CMap::water_13 ); break;
			}
			case sr3d_map_colors::color_water_14:
			{
				map.SetTile(offset, CMap::water_14 ); break;
			}
			case sr3d_map_colors::color_water_15:
			{
				map.SetTile(offset, CMap::water_15 ); break;
			}
			case sr3d_map_colors::color_water_16:
			{
				map.SetTile(offset, CMap::water_16 ); break;
			}
			case sr3d_map_colors::color_water_17:
			{
				map.SetTile(offset, CMap::water_17 ); break;
			}
			case sr3d_map_colors::color_water_18:
			{
				map.SetTile(offset, CMap::water_18 ); break;
			}
			case sr3d_map_colors::color_water_19:
			{
				map.SetTile(offset, CMap::water_19 ); break;
			}
			case sr3d_map_colors::color_water_20:
			{
				map.SetTile(offset, CMap::water_20 ); break;
			}
			case sr3d_map_colors::color_water_21:
			{
				map.SetTile(offset, CMap::water_21 ); break;
			}
			case sr3d_map_colors::color_water_22:
			{
				map.SetTile(offset, CMap::water_22 ); break;
			}
			case sr3d_map_colors::color_water:
			{
				map.SetTile(offset, CMap::water ); break;
			}

			case sr3d_map_colors::color_sand:
			{
				map.SetTile(offset, CMap::sand); break;
			}
			case sr3d_map_colors::color_grass:
			{			
				map.SetTile(offset, CMap::grass); break;
			}	

			case sr3d_map_colors::color_rock: 
			{
				//ROCK SURROUNDED BY SAND
				//completely surrrounded island
				if ( pixel_R == sr3d_map_colors::color_sand && pixel_U == sr3d_map_colors::color_sand && pixel_L == sr3d_map_colors::color_sand && pixel_D == sr3d_map_colors::color_sand )
				{	
					map.SetTile(offset, CMap::rock_sand_border_island1 );
				}		
					
				//four way crossing
				else if ( pixel_RU == sr3d_map_colors::color_sand && pixel_LU == sr3d_map_colors::color_sand && pixel_LD == sr3d_map_colors::color_sand && pixel_RD == sr3d_map_colors::color_sand && pixel_R != sr3d_map_colors::color_sand && pixel_U != sr3d_map_colors::color_sand && pixel_L != sr3d_map_colors::color_sand && pixel_D != sr3d_map_colors::color_sand )
				{	
					map.SetTile(offset, CMap::rock_sand_border_cross1 );
				}		
			
				//peninsula shorelines
				else if ( pixel_R == sr3d_map_colors::color_sand && pixel_U == sr3d_map_colors::color_sand && pixel_D == sr3d_map_colors::color_sand )
				{	
					map.SetTile(offset, CMap::rock_sand_border_peninsula_R1 );
				}	
				else if ( pixel_R == sr3d_map_colors::color_sand && pixel_U == sr3d_map_colors::color_sand && pixel_L == sr3d_map_colors::color_sand )
				{	
					map.SetTile(offset, CMap::rock_sand_border_peninsula_U1 );
				}	
				else if ( pixel_U == sr3d_map_colors::color_sand && pixel_L == sr3d_map_colors::color_sand && pixel_D == sr3d_map_colors::color_sand )
				{				
					map.SetTile(offset, CMap::rock_sand_border_peninsula_L1 );
				}
				else if ( pixel_L == sr3d_map_colors::color_sand && pixel_D == sr3d_map_colors::color_sand && pixel_R == sr3d_map_colors::color_sand )
				{				
					map.SetTile(offset, CMap::rock_sand_border_peninsula_D1 );
				}	
					
				//three way T crossings	
				else if ( pixel_RU == sr3d_map_colors::color_sand && pixel_LU == sr3d_map_colors::color_sand && pixel_D == sr3d_map_colors::color_sand && pixel_R != sr3d_map_colors::color_sand && pixel_U != sr3d_map_colors::color_sand && pixel_L != sr3d_map_colors::color_sand )
				{				
					map.SetTile(offset, CMap::rock_sand_border_T_D1 );
				}
				else if ( pixel_RU == sr3d_map_colors::color_sand && pixel_L == sr3d_map_colors::color_sand && pixel_RD == sr3d_map_colors::color_sand && pixel_R != sr3d_map_colors::color_sand && pixel_U != sr3d_map_colors::color_sand && pixel_D != sr3d_map_colors::color_sand )
				{				
					map.SetTile(offset, CMap::rock_sand_border_T_L1 );
				}	
				else if ( pixel_U == sr3d_map_colors::color_sand && pixel_RD == sr3d_map_colors::color_sand && pixel_LD == sr3d_map_colors::color_sand && pixel_R != sr3d_map_colors::color_sand && pixel_L != sr3d_map_colors::color_sand && pixel_D != sr3d_map_colors::color_sand )
				{				
					map.SetTile(offset, CMap::rock_sand_border_T_U1 );
				}
				else if ( pixel_R == sr3d_map_colors::color_sand && pixel_LU == sr3d_map_colors::color_sand && pixel_LD == sr3d_map_colors::color_sand && pixel_U != sr3d_map_colors::color_sand && pixel_L != sr3d_map_colors::color_sand && pixel_D != sr3d_map_colors::color_sand )
				{				
					map.SetTile(offset, CMap::rock_sand_border_T_R1 );
				}
					
				//left handed panhandle
				else if ( pixel_R == sr3d_map_colors::color_sand && pixel_LU == sr3d_map_colors::color_sand && pixel_U != sr3d_map_colors::color_sand && pixel_L != sr3d_map_colors::color_sand && pixel_LD != sr3d_map_colors::color_sand && pixel_D != sr3d_map_colors::color_sand )
				{				
					map.SetTile(offset, CMap::rock_sand_border_panhandleL_R1 );
				}	
				else if ( pixel_U == sr3d_map_colors::color_sand && pixel_LD == sr3d_map_colors::color_sand && pixel_R != sr3d_map_colors::color_sand && pixel_L != sr3d_map_colors::color_sand && pixel_D != sr3d_map_colors::color_sand && pixel_RD != sr3d_map_colors::color_sand )
				{				
					map.SetTile(offset, CMap::rock_sand_border_panhandleL_U1 );
				}
				else if ( pixel_L == sr3d_map_colors::color_sand && pixel_RD == sr3d_map_colors::color_sand 
							&& pixel_R != sr3d_map_colors::color_sand && pixel_RU != sr3d_map_colors::color_sand && pixel_U != sr3d_map_colors::color_sand && pixel_D != sr3d_map_colors::color_sand )
				{				
					map.SetTile(offset, CMap::rock_sand_border_panhandleL_L1 );
				}
				else if ( pixel_RU == sr3d_map_colors::color_sand && pixel_D == sr3d_map_colors::color_sand
							&& pixel_R != sr3d_map_colors::color_sand && pixel_U != sr3d_map_colors::color_sand && pixel_LU != sr3d_map_colors::color_sand && pixel_L != sr3d_map_colors::color_sand )
				{				
					map.SetTile(offset, CMap::rock_sand_border_panhandleL_D1 );
				}
					
				//right handed panhandle
				else if ( pixel_R == sr3d_map_colors::color_sand && pixel_LD == sr3d_map_colors::color_sand 
							&& pixel_U != sr3d_map_colors::color_sand && pixel_LU != sr3d_map_colors::color_sand && pixel_L != sr3d_map_colors::color_sand && pixel_D != sr3d_map_colors::color_sand )
				{				
					map.SetTile(offset, CMap::rock_sand_border_panhandleR_R1 );
				}
				else if ( pixel_U == sr3d_map_colors::color_sand && pixel_RD == sr3d_map_colors::color_sand
							&& pixel_R != sr3d_map_colors::color_sand && pixel_L != sr3d_map_colors::color_sand && pixel_LD != sr3d_map_colors::color_sand && pixel_D != sr3d_map_colors::color_sand )
				{				
					map.SetTile(offset, CMap::rock_sand_border_panhandleR_U1 );
				}
				else if ( pixel_RU == sr3d_map_colors::color_sand && pixel_L == sr3d_map_colors::color_sand
							&& pixel_R != sr3d_map_colors::color_sand && pixel_U != sr3d_map_colors::color_sand && pixel_D != sr3d_map_colors::color_sand && pixel_RD != sr3d_map_colors::color_sand )
				{				
					map.SetTile(offset, CMap::rock_sand_border_panhandleR_L1 );
				}
				else if ( pixel_LU == sr3d_map_colors::color_sand && pixel_D == sr3d_map_colors::color_sand 
							&& pixel_R != sr3d_map_colors::color_sand && pixel_RU != sr3d_map_colors::color_sand && pixel_U != sr3d_map_colors::color_sand && pixel_L != sr3d_map_colors::color_sand )
				{				
					map.SetTile(offset, CMap::rock_sand_border_panhandleR_D1 );
				}
					
				//splitting strips
				else if ( pixel_RU == sr3d_map_colors::color_sand && pixel_LU == sr3d_map_colors::color_sand && pixel_RD == sr3d_map_colors::color_sand
							&& pixel_R != sr3d_map_colors::color_sand && pixel_U != sr3d_map_colors::color_sand && pixel_L != sr3d_map_colors::color_sand && pixel_LD != sr3d_map_colors::color_sand && pixel_D != sr3d_map_colors::color_sand )
				{				
					map.SetTile(offset, CMap::rock_sand_border_split_RU1 );
				}
				else if ( pixel_RU == sr3d_map_colors::color_sand && pixel_LU == sr3d_map_colors::color_sand && pixel_LD == sr3d_map_colors::color_sand 
							&& pixel_R != sr3d_map_colors::color_sand && pixel_U != sr3d_map_colors::color_sand && pixel_L != sr3d_map_colors::color_sand && pixel_D != sr3d_map_colors::color_sand && pixel_RD != sr3d_map_colors::color_sand )
				{				
					map.SetTile(offset, CMap::rock_sand_border_split_LU1 );
				}
				else if ( pixel_LU == sr3d_map_colors::color_sand && pixel_LD == sr3d_map_colors::color_sand && pixel_RD == sr3d_map_colors::color_sand 
							&& pixel_R != sr3d_map_colors::color_sand && pixel_RU != sr3d_map_colors::color_sand && pixel_U != sr3d_map_colors::color_sand && pixel_L != sr3d_map_colors::color_sand && pixel_D != sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_split_LD1 );
				}
				else if ( pixel_RU == sr3d_map_colors::color_sand && pixel_LD == sr3d_map_colors::color_sand && pixel_RD == sr3d_map_colors::color_sand 
							&& pixel_R != sr3d_map_colors::color_sand && pixel_U != sr3d_map_colors::color_sand && pixel_LU != sr3d_map_colors::color_sand && pixel_L != sr3d_map_colors::color_sand && pixel_D != sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_split_RD1 );
				}
					
				//choke points
				else if ( pixel_RU == sr3d_map_colors::color_sand && pixel_RD == sr3d_map_colors::color_sand && pixel_R != sr3d_map_colors::color_sand && pixel_U != sr3d_map_colors::color_sand && pixel_LU != sr3d_map_colors::color_sand && pixel_L != sr3d_map_colors::color_sand && pixel_LD != sr3d_map_colors::color_sand && pixel_D != sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_choke_R1 );
				}
				else if ( pixel_RU == sr3d_map_colors::color_sand && pixel_LU == sr3d_map_colors::color_sand && pixel_R != sr3d_map_colors::color_sand && pixel_U != sr3d_map_colors::color_sand && pixel_L != sr3d_map_colors::color_sand && pixel_LD != sr3d_map_colors::color_sand && pixel_D != sr3d_map_colors::color_sand && pixel_RD != sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_choke_U1 );
				}
				else if ( pixel_LU == sr3d_map_colors::color_sand && pixel_LD == sr3d_map_colors::color_sand && pixel_R != sr3d_map_colors::color_sand && pixel_RU != sr3d_map_colors::color_sand && pixel_U != sr3d_map_colors::color_sand && pixel_L != sr3d_map_colors::color_sand && pixel_D != sr3d_map_colors::color_sand && pixel_RD != sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_choke_L1 );
				}
				else if ( pixel_LD == sr3d_map_colors::color_sand && pixel_RD == sr3d_map_colors::color_sand && pixel_R != sr3d_map_colors::color_sand && pixel_RU != sr3d_map_colors::color_sand && pixel_U != sr3d_map_colors::color_sand && pixel_LU != sr3d_map_colors::color_sand && pixel_L != sr3d_map_colors::color_sand && pixel_D != sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_choke_D1 );
				}
					
				//strip shorelines
				else if (pixel_U == sr3d_map_colors::color_sand && pixel_D == sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_strip_H1 );
				}
				else if ( pixel_R == sr3d_map_colors::color_sand && pixel_L == sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_strip_V1 );	
				}

				//bend shorelines
				else if ( pixel_L == sr3d_map_colors::color_sand && pixel_LU == sr3d_map_colors::color_sand && pixel_U == sr3d_map_colors::color_sand && pixel_RD == sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_bend_LU1 );
				}
				else if ( pixel_R == sr3d_map_colors::color_sand && pixel_RU == sr3d_map_colors::color_sand && pixel_U == sr3d_map_colors::color_sand && pixel_LD == sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_bend_RU1 );
				}
				else if ( pixel_R == sr3d_map_colors::color_sand && pixel_RD == sr3d_map_colors::color_sand && pixel_D == sr3d_map_colors::color_sand && pixel_LU == sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_bend_RD1 );		
				}
				else if ( pixel_L == sr3d_map_colors::color_sand && pixel_LD == sr3d_map_colors::color_sand && pixel_D == sr3d_map_colors::color_sand && pixel_RU == sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_bend_LD1 );
				}

				//diagonal choke points
				else if ( pixel_RU == sr3d_map_colors::color_sand && pixel_LD == sr3d_map_colors::color_sand
							&& pixel_R != sr3d_map_colors::color_sand && pixel_U != sr3d_map_colors::color_sand && pixel_LU != sr3d_map_colors::color_sand && pixel_L != sr3d_map_colors::color_sand && pixel_D != sr3d_map_colors::color_sand && pixel_RD != sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_diagonal_R1 );	
				}
				else if ( pixel_LU == sr3d_map_colors::color_sand && pixel_RD == sr3d_map_colors::color_sand
							&& pixel_R != sr3d_map_colors::color_sand && pixel_RU != sr3d_map_colors::color_sand && pixel_U != sr3d_map_colors::color_sand && pixel_L != sr3d_map_colors::color_sand && pixel_LD != sr3d_map_colors::color_sand && pixel_D != sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_diagonal_L1 );			
				}

				//straight edge shorelines
				else if ( pixel_R == sr3d_map_colors::color_sand 
							&& pixel_U != sr3d_map_colors::color_sand && pixel_LU != sr3d_map_colors::color_sand && pixel_L != sr3d_map_colors::color_sand && pixel_LD != sr3d_map_colors::color_sand && pixel_D != sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_straight_R1 );	
				}
				else if ( pixel_U == sr3d_map_colors::color_sand
							&& pixel_R != sr3d_map_colors::color_sand && pixel_L != sr3d_map_colors::color_sand && pixel_LD != sr3d_map_colors::color_sand && pixel_D != sr3d_map_colors::color_sand && pixel_RD != sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_straight_U1 );	
				}
				else if ( pixel_L == sr3d_map_colors::color_sand
							&& pixel_R != sr3d_map_colors::color_sand && pixel_RU != sr3d_map_colors::color_sand && pixel_U != sr3d_map_colors::color_sand && pixel_D != sr3d_map_colors::color_sand && pixel_RD != sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_straight_L1 );	
				}
				else if ( pixel_D == sr3d_map_colors::color_sand
							&& pixel_R != sr3d_map_colors::color_sand && pixel_RU != sr3d_map_colors::color_sand && pixel_U != sr3d_map_colors::color_sand && pixel_LU != sr3d_map_colors::color_sand && pixel_L != sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_straight_D1 );	
				}
					
				//convex shorelines
				else if ( pixel_L == sr3d_map_colors::color_sand && pixel_U == sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_convex_LU1 );
				}
				else if ( pixel_R == sr3d_map_colors::color_sand && pixel_U == sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_convex_RU1 );
				}
				else if ( pixel_R == sr3d_map_colors::color_sand && pixel_D == sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_convex_RD1 );
				}
				else if ( pixel_L == sr3d_map_colors::color_sand && pixel_D == sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_convex_LD1 );
				}
					
				//concave shorelines		
				else if ( pixel_RU == sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_concave_RU1 );	
				}
				else if ( pixel_LU == sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_concave_LU1 );	
				}
				else if ( pixel_LD == sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_concave_LD1 );	
				}
				else if ( pixel_RD == sr3d_map_colors::color_sand )
				{
					map.SetTile(offset, CMap::rock_sand_border_concave_RD1 );		
				}
					
				//ROCK SURROUNDED BY SHOAL
				//completely surrrounded island
				else if ( pixel_R == sr3d_map_colors::color_shoal && pixel_U == sr3d_map_colors::color_shoal && pixel_L == sr3d_map_colors::color_shoal && pixel_D == sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_island1 );
					
				//four way crossing
				else if ( pixel_RU == sr3d_map_colors::color_shoal && pixel_LU == sr3d_map_colors::color_shoal && pixel_LD == sr3d_map_colors::color_shoal && pixel_RD == sr3d_map_colors::color_shoal
							&& pixel_R != sr3d_map_colors::color_shoal && pixel_U != sr3d_map_colors::color_shoal && pixel_L != sr3d_map_colors::color_shoal && pixel_D != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_cross1 );		
			
				//peninsula shorelines
				else if ( pixel_R == sr3d_map_colors::color_shoal && pixel_U == sr3d_map_colors::color_shoal && pixel_D == sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_peninsula_R1 );
				else if ( pixel_R == sr3d_map_colors::color_shoal && pixel_U == sr3d_map_colors::color_shoal && pixel_L == sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_peninsula_U1 );
				else if ( pixel_U == sr3d_map_colors::color_shoal && pixel_L == sr3d_map_colors::color_shoal && pixel_D == sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_peninsula_L1 );
				else if ( pixel_L == sr3d_map_colors::color_shoal && pixel_D == sr3d_map_colors::color_shoal && pixel_R == sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_peninsula_D1 );
					
				//three way T crossings
				else if ( pixel_R == sr3d_map_colors::color_shoal && pixel_LU == sr3d_map_colors::color_shoal && pixel_LD == sr3d_map_colors::color_shoal
							&& pixel_U != sr3d_map_colors::color_shoal && pixel_L != sr3d_map_colors::color_shoal && pixel_D != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_T_R1 );
				else if ( pixel_U == sr3d_map_colors::color_shoal && pixel_RD == sr3d_map_colors::color_shoal && pixel_LD == sr3d_map_colors::color_shoal
							&& pixel_R != sr3d_map_colors::color_shoal && pixel_L != sr3d_map_colors::color_shoal && pixel_D != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_T_U1 );
				else if ( pixel_RU == sr3d_map_colors::color_shoal && pixel_L == sr3d_map_colors::color_shoal && pixel_RD == sr3d_map_colors::color_shoal
							&& pixel_R != sr3d_map_colors::color_shoal && pixel_U != sr3d_map_colors::color_shoal && pixel_D != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_T_L1 );
				else if ( pixel_RU == sr3d_map_colors::color_shoal && pixel_LU == sr3d_map_colors::color_shoal && pixel_D == sr3d_map_colors::color_shoal
							&& pixel_R != sr3d_map_colors::color_shoal && pixel_U != sr3d_map_colors::color_shoal && pixel_L != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_T_D1 );
					
				//left handed panhandle
				else if ( pixel_R == sr3d_map_colors::color_shoal && pixel_LU == sr3d_map_colors::color_shoal
							&& pixel_U != sr3d_map_colors::color_shoal && pixel_L != sr3d_map_colors::color_shoal && pixel_LD != sr3d_map_colors::color_shoal && pixel_D != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_panhandleL_R1 );
				else if ( pixel_U == sr3d_map_colors::color_shoal && pixel_LD == sr3d_map_colors::color_shoal 
							&& pixel_R != sr3d_map_colors::color_shoal && pixel_L != sr3d_map_colors::color_shoal && pixel_D != sr3d_map_colors::color_shoal && pixel_RD != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_panhandleL_U1 );
				else if ( pixel_L == sr3d_map_colors::color_shoal && pixel_RD == sr3d_map_colors::color_shoal 
							&& pixel_R != sr3d_map_colors::color_shoal && pixel_RU != sr3d_map_colors::color_shoal && pixel_U != sr3d_map_colors::color_shoal && pixel_D != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_panhandleL_L1 );
				else if ( pixel_RU == sr3d_map_colors::color_shoal && pixel_D == sr3d_map_colors::color_shoal
							&& pixel_R != sr3d_map_colors::color_shoal && pixel_U != sr3d_map_colors::color_shoal && pixel_LU != sr3d_map_colors::color_shoal && pixel_L != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_panhandleL_D1 );
					
				//right handed panhandle
				else if ( pixel_R == sr3d_map_colors::color_shoal && pixel_LD == sr3d_map_colors::color_shoal 
							&& pixel_U != sr3d_map_colors::color_shoal && pixel_LU != sr3d_map_colors::color_shoal && pixel_L != sr3d_map_colors::color_shoal && pixel_D != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_panhandleR_R1 );
				else if ( pixel_U == sr3d_map_colors::color_shoal && pixel_RD == sr3d_map_colors::color_shoal
							&& pixel_R != sr3d_map_colors::color_shoal && pixel_L != sr3d_map_colors::color_shoal && pixel_LD != sr3d_map_colors::color_shoal && pixel_D != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_panhandleR_U1 );
				else if ( pixel_RU == sr3d_map_colors::color_shoal && pixel_L == sr3d_map_colors::color_shoal
							&& pixel_R != sr3d_map_colors::color_shoal && pixel_U != sr3d_map_colors::color_shoal && pixel_D != sr3d_map_colors::color_shoal && pixel_RD != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_panhandleR_L1 );
				else if ( pixel_LU == sr3d_map_colors::color_shoal && pixel_D == sr3d_map_colors::color_shoal 
							&& pixel_R != sr3d_map_colors::color_shoal && pixel_RU != sr3d_map_colors::color_shoal && pixel_U != sr3d_map_colors::color_shoal && pixel_L != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_panhandleR_D1 );
					
				//splitting strips
				else if ( pixel_RU == sr3d_map_colors::color_shoal && pixel_LU == sr3d_map_colors::color_shoal && pixel_RD == sr3d_map_colors::color_shoal
							&& pixel_R != sr3d_map_colors::color_shoal && pixel_U != sr3d_map_colors::color_shoal && pixel_L != sr3d_map_colors::color_shoal && pixel_LD != sr3d_map_colors::color_shoal && pixel_D != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_split_RU1 );
				else if ( pixel_RU == sr3d_map_colors::color_shoal && pixel_LU == sr3d_map_colors::color_shoal && pixel_LD == sr3d_map_colors::color_shoal 
							&& pixel_R != sr3d_map_colors::color_shoal && pixel_U != sr3d_map_colors::color_shoal && pixel_L != sr3d_map_colors::color_shoal && pixel_D != sr3d_map_colors::color_shoal && pixel_RD != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_split_LU1 );
				else if ( pixel_LU == sr3d_map_colors::color_shoal && pixel_LD == sr3d_map_colors::color_shoal && pixel_RD == sr3d_map_colors::color_shoal 
							&& pixel_R != sr3d_map_colors::color_shoal && pixel_RU != sr3d_map_colors::color_shoal && pixel_U != sr3d_map_colors::color_shoal && pixel_L != sr3d_map_colors::color_shoal && pixel_D != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_split_LD1 );
				else if ( pixel_RU == sr3d_map_colors::color_shoal && pixel_LD == sr3d_map_colors::color_shoal && pixel_RD == sr3d_map_colors::color_shoal 
							&& pixel_R != sr3d_map_colors::color_shoal && pixel_U != sr3d_map_colors::color_shoal && pixel_LU != sr3d_map_colors::color_shoal && pixel_L != sr3d_map_colors::color_shoal && pixel_D != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_split_RD1 );
					
				//choke points
				else if ( pixel_RU == sr3d_map_colors::color_shoal && pixel_RD == sr3d_map_colors::color_shoal 
							&& pixel_R != sr3d_map_colors::color_shoal && pixel_U != sr3d_map_colors::color_shoal && pixel_LU != sr3d_map_colors::color_shoal && pixel_L != sr3d_map_colors::color_shoal && pixel_LD != sr3d_map_colors::color_shoal && pixel_D != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_choke_R1 );
				else if ( pixel_RU == sr3d_map_colors::color_shoal && pixel_LU == sr3d_map_colors::color_shoal 
							&& pixel_R != sr3d_map_colors::color_shoal && pixel_U != sr3d_map_colors::color_shoal && pixel_L != sr3d_map_colors::color_shoal && pixel_LD != sr3d_map_colors::color_shoal && pixel_D != sr3d_map_colors::color_shoal && pixel_RD != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_choke_U1 );
				else if ( pixel_LU == sr3d_map_colors::color_shoal && pixel_LD == sr3d_map_colors::color_shoal 
							&& pixel_R != sr3d_map_colors::color_shoal && pixel_RU != sr3d_map_colors::color_shoal && pixel_U != sr3d_map_colors::color_shoal && pixel_L != sr3d_map_colors::color_shoal && pixel_D != sr3d_map_colors::color_shoal && pixel_RD != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_choke_L1 );
				else if ( pixel_LD == sr3d_map_colors::color_shoal && pixel_RD == sr3d_map_colors::color_shoal 
							&& pixel_R != sr3d_map_colors::color_shoal && pixel_RU != sr3d_map_colors::color_shoal && pixel_U != sr3d_map_colors::color_shoal && pixel_LU != sr3d_map_colors::color_shoal && pixel_L != sr3d_map_colors::color_shoal && pixel_D != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_choke_D1 );
					
				//strip shorelines
				else if (pixel_U == sr3d_map_colors::color_shoal && pixel_D == sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_strip_H1 );
				else if ( pixel_R == sr3d_map_colors::color_shoal && pixel_L == sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_strip_V1 );	

				//bend shorelines
				else if ( pixel_R == sr3d_map_colors::color_shoal && pixel_RU == sr3d_map_colors::color_shoal && pixel_U == sr3d_map_colors::color_shoal && pixel_LD == sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_bend_RU1 );
				else if ( pixel_L == sr3d_map_colors::color_shoal && pixel_LU == sr3d_map_colors::color_shoal && pixel_U == sr3d_map_colors::color_shoal && pixel_RD == sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_bend_LU1 );
				else if ( pixel_L == sr3d_map_colors::color_shoal && pixel_LD == sr3d_map_colors::color_shoal && pixel_D == sr3d_map_colors::color_shoal && pixel_RU == sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_bend_LD1 );
				else if ( pixel_R == sr3d_map_colors::color_shoal && pixel_RD == sr3d_map_colors::color_shoal && pixel_D == sr3d_map_colors::color_shoal && pixel_LU == sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_bend_RD1 );		

				//diagonal choke points
				else if ( pixel_RU == sr3d_map_colors::color_shoal && pixel_LD == sr3d_map_colors::color_shoal
							&& pixel_R != sr3d_map_colors::color_shoal && pixel_U != sr3d_map_colors::color_shoal && pixel_LU != sr3d_map_colors::color_shoal && pixel_L != sr3d_map_colors::color_shoal && pixel_D != sr3d_map_colors::color_shoal && pixel_RD != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_diagonal_R1 );	
				else if ( pixel_LU == sr3d_map_colors::color_shoal && pixel_RD == sr3d_map_colors::color_shoal
							&& pixel_R != sr3d_map_colors::color_shoal && pixel_RU != sr3d_map_colors::color_shoal && pixel_U != sr3d_map_colors::color_shoal && pixel_L != sr3d_map_colors::color_shoal && pixel_LD != sr3d_map_colors::color_shoal && pixel_D != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_diagonal_L1 );				

				//straight edge shorelines
				else if ( pixel_R == sr3d_map_colors::color_shoal 
							&& pixel_U != sr3d_map_colors::color_shoal && pixel_LU != sr3d_map_colors::color_shoal && pixel_L != sr3d_map_colors::color_shoal && pixel_LD != sr3d_map_colors::color_shoal && pixel_D != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_straight_R1 );	
				else if ( pixel_U == sr3d_map_colors::color_shoal
							&& pixel_R != sr3d_map_colors::color_shoal && pixel_L != sr3d_map_colors::color_shoal && pixel_LD != sr3d_map_colors::color_shoal && pixel_D != sr3d_map_colors::color_shoal && pixel_RD != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_straight_U1 );	
				else if ( pixel_L == sr3d_map_colors::color_shoal
							&& pixel_R != sr3d_map_colors::color_shoal && pixel_RU != sr3d_map_colors::color_shoal && pixel_U != sr3d_map_colors::color_shoal && pixel_D != sr3d_map_colors::color_shoal && pixel_RD != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_straight_L1 );	
				else if ( pixel_D == sr3d_map_colors::color_shoal
							&& pixel_R != sr3d_map_colors::color_shoal && pixel_RU != sr3d_map_colors::color_shoal && pixel_U != sr3d_map_colors::color_shoal && pixel_LU != sr3d_map_colors::color_shoal && pixel_L != sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_straight_D1 );	
					
				//convex shorelines
				else if ( pixel_R == sr3d_map_colors::color_shoal && pixel_U == sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_convex_RU1 );
				else if ( pixel_L == sr3d_map_colors::color_shoal && pixel_U == sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_convex_LU1 );
				else if ( pixel_L == sr3d_map_colors::color_shoal && pixel_D == sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_convex_LD1 );
				else if ( pixel_R == sr3d_map_colors::color_shoal && pixel_D == sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_convex_RD1 );
					
				//concave shorelines		
				else if ( pixel_RU == sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_concave_RU1 );	
				else if ( pixel_LU == sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_concave_LU1 );	
				else if ( pixel_LD == sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_concave_LD1 );	
				else if ( pixel_RD == sr3d_map_colors::color_shoal )
					map.SetTile(offset, CMap::rock_shoal_border_concave_RD1 );
			
				//ROCK SURROUNDED BY WATER
				//completely surrrounded island
				else if ( pixel_R == sr3d_map_colors::color_water && pixel_U == sr3d_map_colors::color_water && pixel_L == sr3d_map_colors::color_water && pixel_D == sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_island1 );
					
				//four way crossing
				else if ( pixel_RU == sr3d_map_colors::color_water && pixel_LU == sr3d_map_colors::color_water && pixel_LD == sr3d_map_colors::color_water && pixel_RD == sr3d_map_colors::color_water
							&& pixel_R != sr3d_map_colors::color_water && pixel_U != sr3d_map_colors::color_water && pixel_L != sr3d_map_colors::color_water && pixel_D != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_cross1 );		
			
				//peninsula shorelines
				else if ( pixel_R == sr3d_map_colors::color_water && pixel_U == sr3d_map_colors::color_water && pixel_D == sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_peninsula_R1 );
				else if ( pixel_R == sr3d_map_colors::color_water && pixel_U == sr3d_map_colors::color_water && pixel_L == sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_peninsula_U1 );
				else if ( pixel_U == sr3d_map_colors::color_water && pixel_L == sr3d_map_colors::color_water && pixel_D == sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_peninsula_L1 );
				else if ( pixel_L == sr3d_map_colors::color_water && pixel_D == sr3d_map_colors::color_water && pixel_R == sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_peninsula_D1 );
					
				//three way T crossings
				else if ( pixel_R == sr3d_map_colors::color_water && pixel_LU == sr3d_map_colors::color_water && pixel_LD == sr3d_map_colors::color_water
							&& pixel_U != sr3d_map_colors::color_water && pixel_L != sr3d_map_colors::color_water && pixel_D != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_T_R1 );
				else if ( pixel_U == sr3d_map_colors::color_water && pixel_RD == sr3d_map_colors::color_water && pixel_LD == sr3d_map_colors::color_water
							&& pixel_R != sr3d_map_colors::color_water && pixel_L != sr3d_map_colors::color_water && pixel_D != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_T_U1 );
				else if ( pixel_RU == sr3d_map_colors::color_water && pixel_L == sr3d_map_colors::color_water && pixel_RD == sr3d_map_colors::color_water
							&& pixel_R != sr3d_map_colors::color_water && pixel_U != sr3d_map_colors::color_water && pixel_D != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_T_L1 );
				else if ( pixel_RU == sr3d_map_colors::color_water && pixel_LU == sr3d_map_colors::color_water && pixel_D == sr3d_map_colors::color_water
							&& pixel_R != sr3d_map_colors::color_water && pixel_U != sr3d_map_colors::color_water && pixel_L != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_T_D1 );
					
				//left handed panhandle
				else if ( pixel_R == sr3d_map_colors::color_water && pixel_LU == sr3d_map_colors::color_water
							&& pixel_U != sr3d_map_colors::color_water && pixel_L != sr3d_map_colors::color_water && pixel_LD != sr3d_map_colors::color_water && pixel_D != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_panhandleL_R1 );
				else if ( pixel_U == sr3d_map_colors::color_water && pixel_LD == sr3d_map_colors::color_water 
							&& pixel_R != sr3d_map_colors::color_water && pixel_L != sr3d_map_colors::color_water && pixel_D != sr3d_map_colors::color_water && pixel_RD != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_panhandleL_U1 );
				else if ( pixel_L == sr3d_map_colors::color_water && pixel_RD == sr3d_map_colors::color_water 
							&& pixel_R != sr3d_map_colors::color_water && pixel_RU != sr3d_map_colors::color_water && pixel_U != sr3d_map_colors::color_water && pixel_D != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_panhandleL_L1 );
				else if ( pixel_RU == sr3d_map_colors::color_water && pixel_D == sr3d_map_colors::color_water
							&& pixel_R != sr3d_map_colors::color_water && pixel_U != sr3d_map_colors::color_water && pixel_LU != sr3d_map_colors::color_water && pixel_L != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_panhandleL_D1 );
					
				//right handed panhandle
				else if ( pixel_R == sr3d_map_colors::color_water && pixel_LD == sr3d_map_colors::color_water 
							&& pixel_U != sr3d_map_colors::color_water && pixel_LU != sr3d_map_colors::color_water && pixel_L != sr3d_map_colors::color_water && pixel_D != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_panhandleR_R1 );
				else if ( pixel_U == sr3d_map_colors::color_water && pixel_RD == sr3d_map_colors::color_water
							&& pixel_R != sr3d_map_colors::color_water && pixel_L != sr3d_map_colors::color_water && pixel_LD != sr3d_map_colors::color_water && pixel_D != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_panhandleR_U1 );
				else if ( pixel_RU == sr3d_map_colors::color_water && pixel_L == sr3d_map_colors::color_water
							&& pixel_R != sr3d_map_colors::color_water && pixel_U != sr3d_map_colors::color_water && pixel_D != sr3d_map_colors::color_water && pixel_RD != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_panhandleR_L1 );
				else if ( pixel_LU == sr3d_map_colors::color_water && pixel_D == sr3d_map_colors::color_water 
							&& pixel_R != sr3d_map_colors::color_water && pixel_RU != sr3d_map_colors::color_water && pixel_U != sr3d_map_colors::color_water && pixel_L != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_panhandleR_D1 );
					
				//splitting strips
				else if ( pixel_RU == sr3d_map_colors::color_water && pixel_LU == sr3d_map_colors::color_water && pixel_RD == sr3d_map_colors::color_water
							&& pixel_R != sr3d_map_colors::color_water && pixel_U != sr3d_map_colors::color_water && pixel_L != sr3d_map_colors::color_water && pixel_LD != sr3d_map_colors::color_water && pixel_D != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_split_RU1 );
				else if ( pixel_RU == sr3d_map_colors::color_water && pixel_LU == sr3d_map_colors::color_water && pixel_LD == sr3d_map_colors::color_water 
							&& pixel_R != sr3d_map_colors::color_water && pixel_U != sr3d_map_colors::color_water && pixel_L != sr3d_map_colors::color_water && pixel_D != sr3d_map_colors::color_water && pixel_RD != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_split_LU1 );
				else if ( pixel_LU == sr3d_map_colors::color_water && pixel_LD == sr3d_map_colors::color_water && pixel_RD == sr3d_map_colors::color_water 
							&& pixel_R != sr3d_map_colors::color_water && pixel_RU != sr3d_map_colors::color_water && pixel_U != sr3d_map_colors::color_water && pixel_L != sr3d_map_colors::color_water && pixel_D != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_split_LD1 );
				else if ( pixel_RU == sr3d_map_colors::color_water && pixel_LD == sr3d_map_colors::color_water && pixel_RD == sr3d_map_colors::color_water 
							&& pixel_R != sr3d_map_colors::color_water && pixel_U != sr3d_map_colors::color_water && pixel_LU != sr3d_map_colors::color_water && pixel_L != sr3d_map_colors::color_water && pixel_D != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_split_RD1 );
					
				//choke points
				else if ( pixel_RU == sr3d_map_colors::color_water && pixel_RD == sr3d_map_colors::color_water 
							&& pixel_R != sr3d_map_colors::color_water && pixel_U != sr3d_map_colors::color_water && pixel_LU != sr3d_map_colors::color_water && pixel_L != sr3d_map_colors::color_water && pixel_LD != sr3d_map_colors::color_water && pixel_D != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_choke_R1 );
				else if ( pixel_RU == sr3d_map_colors::color_water && pixel_LU == sr3d_map_colors::color_water 
							&& pixel_R != sr3d_map_colors::color_water && pixel_U != sr3d_map_colors::color_water && pixel_L != sr3d_map_colors::color_water && pixel_LD != sr3d_map_colors::color_water && pixel_D != sr3d_map_colors::color_water && pixel_RD != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_choke_U1 );
				else if ( pixel_LU == sr3d_map_colors::color_water && pixel_LD == sr3d_map_colors::color_water 
							&& pixel_R != sr3d_map_colors::color_water && pixel_RU != sr3d_map_colors::color_water && pixel_U != sr3d_map_colors::color_water && pixel_L != sr3d_map_colors::color_water && pixel_D != sr3d_map_colors::color_water && pixel_RD != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_choke_L1 );
				else if ( pixel_LD == sr3d_map_colors::color_water && pixel_RD == sr3d_map_colors::color_water 
							&& pixel_R != sr3d_map_colors::color_water && pixel_RU != sr3d_map_colors::color_water && pixel_U != sr3d_map_colors::color_water && pixel_LU != sr3d_map_colors::color_water && pixel_L != sr3d_map_colors::color_water && pixel_D != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_choke_D1 );
					
				//strip shorelines
				else if (pixel_U == sr3d_map_colors::color_water && pixel_D == sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_strip_H1 );
				else if ( pixel_R == sr3d_map_colors::color_water && pixel_L == sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_strip_V1 );	

				//bend shorelines
				else if ( pixel_R == sr3d_map_colors::color_water && pixel_RU == sr3d_map_colors::color_water && pixel_U == sr3d_map_colors::color_water && pixel_LD == sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_bend_RU1 );
				else if ( pixel_L == sr3d_map_colors::color_water && pixel_LU == sr3d_map_colors::color_water && pixel_U == sr3d_map_colors::color_water && pixel_RD == sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_bend_LU1 );
				else if ( pixel_L == sr3d_map_colors::color_water && pixel_LD == sr3d_map_colors::color_water && pixel_D == sr3d_map_colors::color_water && pixel_RU == sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_bend_LD1 );
				else if ( pixel_R == sr3d_map_colors::color_water && pixel_RD == sr3d_map_colors::color_water && pixel_D == sr3d_map_colors::color_water && pixel_LU == sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_bend_RD1 );		

				//diagonal choke points
				else if ( pixel_RU == sr3d_map_colors::color_water && pixel_LD == sr3d_map_colors::color_water
							&& pixel_R != sr3d_map_colors::color_water && pixel_U != sr3d_map_colors::color_water && pixel_LU != sr3d_map_colors::color_water && pixel_L != sr3d_map_colors::color_water && pixel_D != sr3d_map_colors::color_water && pixel_RD != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_diagonal_R1 );	
				else if ( pixel_LU == sr3d_map_colors::color_water && pixel_RD == sr3d_map_colors::color_water
							&& pixel_R != sr3d_map_colors::color_water && pixel_RU != sr3d_map_colors::color_water && pixel_U != sr3d_map_colors::color_water && pixel_L != sr3d_map_colors::color_water && pixel_LD != sr3d_map_colors::color_water && pixel_D != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_diagonal_L1 );				

				//straight edge shorelines
				else if ( pixel_R == sr3d_map_colors::color_water 
							&& pixel_U != sr3d_map_colors::color_water && pixel_LU != sr3d_map_colors::color_water && pixel_L != sr3d_map_colors::color_water && pixel_LD != sr3d_map_colors::color_water && pixel_D != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_straight_R1 );	
				else if ( pixel_U == sr3d_map_colors::color_water
							&& pixel_R != sr3d_map_colors::color_water && pixel_L != sr3d_map_colors::color_water && pixel_LD != sr3d_map_colors::color_water && pixel_D != sr3d_map_colors::color_water && pixel_RD != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_straight_U1 );	
				else if ( pixel_L == sr3d_map_colors::color_water
							&& pixel_R != sr3d_map_colors::color_water && pixel_RU != sr3d_map_colors::color_water && pixel_U != sr3d_map_colors::color_water && pixel_D != sr3d_map_colors::color_water && pixel_RD != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_straight_L1 );	
				else if ( pixel_D == sr3d_map_colors::color_water
							&& pixel_R != sr3d_map_colors::color_water && pixel_RU != sr3d_map_colors::color_water && pixel_U != sr3d_map_colors::color_water && pixel_LU != sr3d_map_colors::color_water && pixel_L != sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_straight_D1 );	
					
				//convex shorelines
				else if ( pixel_R == sr3d_map_colors::color_water && pixel_U == sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_convex_RU1 );
				else if ( pixel_L == sr3d_map_colors::color_water && pixel_U == sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_convex_LU1 );
				else if ( pixel_L == sr3d_map_colors::color_water && pixel_D == sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_convex_LD1 );
				else if ( pixel_R == sr3d_map_colors::color_water && pixel_D == sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_convex_RD1 );
					
				//concave shorelines		
				else if ( pixel_RU == sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_concave_RU1 );	
				else if ( pixel_LU == sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_concave_LU1 );	
				else if ( pixel_LD == sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_concave_LD1 );	
				else if ( pixel_RD == sr3d_map_colors::color_water )
					map.SetTile(offset, CMap::rock_shore_concave_RD1 );
					
				else {	 map.SetTile(offset, CMap::rock); }
				break;
			}

		}
		map.RemoveTileFlag( offset, Tile::SOLID | Tile::COLLISION);
		map.AddTileFlag( offset, Tile::BACKGROUND | Tile::LIGHT_PASSES);
	}
}

void SaveMap(CMap@ map, const string &in fileName)
{
	const u32 width = map.tilemapwidth;
	const u32 height = map.tilemapheight;
	const u32 space = width * height;

	CFileImage image(width, height, true);
	image.setFilename(fileName, IMAGE_FILENAME_BASE_MAPS);

	// image starts at -1, 0
	image.nextPixel();

	// iterate through tiles
	for(uint i = 0; i < space; i++)
	{
		SColor color = getColorFromTileType(map.getTile(i).type);
		image.setPixelAndAdvance(color);
	}

	image.Save();
}

SColor getColorFromTileType(TileType tile)
{
	if(tile >= TILE_LUT.length)
	{
		return sr3d_map_colors::color_water;
	}
	return TILE_LUT[tile];
}

const SColor[] TILE_LUT = {

		sr3d_map_colors::color_sand,
		sr3d_map_colors::color_grass,

		sr3d_map_colors::color_water_1,
		sr3d_map_colors::color_water_2,
		sr3d_map_colors::color_water_3,
		sr3d_map_colors::color_water_4,
		sr3d_map_colors::color_water_5,
		sr3d_map_colors::color_water_6,
		sr3d_map_colors::color_water_7,
		sr3d_map_colors::color_water_8,
		sr3d_map_colors::color_water_9,	
		sr3d_map_colors::color_water_10,
		sr3d_map_colors::color_water_11,
		sr3d_map_colors::color_water_12,
		sr3d_map_colors::color_water_13,
		sr3d_map_colors::color_water_14,
		sr3d_map_colors::color_water_15,
		sr3d_map_colors::color_water_16,
		sr3d_map_colors::color_water_17,
		sr3d_map_colors::color_water_18,
		sr3d_map_colors::color_water_19,
		sr3d_map_colors::color_water_20,
		sr3d_map_colors::color_water_21,
		sr3d_map_colors::color_water_22,
		sr3d_map_colors::color_water,

		sr3d_map_colors::color_rock,
		sr3d_map_colors::color_rock_shore_convex_RU1,
		sr3d_map_colors::color_rock_shore_convex_LU1,
		sr3d_map_colors::color_rock_shore_convex_LD1,
		sr3d_map_colors::color_rock_shore_convex_RD1,
		sr3d_map_colors::color_rock_shore_straight_R1,
		sr3d_map_colors::color_rock_shore_straight_U1,
		sr3d_map_colors::color_rock_shore_straight_L1,
		sr3d_map_colors::color_rock_shore_straight_D1,
		sr3d_map_colors::color_rock_shore_concave_RU1,
		sr3d_map_colors::color_rock_shore_concave_LU1,
		sr3d_map_colors::color_rock_shore_concave_LD1,
		sr3d_map_colors::color_rock_shore_concave_RD1,
		sr3d_map_colors::color_rock_shore_peninsula_R1,
		sr3d_map_colors::color_rock_shore_peninsula_U1,
		sr3d_map_colors::color_rock_shore_peninsula_L1,
		sr3d_map_colors::color_rock_shore_peninsula_D1,
		sr3d_map_colors::color_rock_shore_strip_H1,
		sr3d_map_colors::color_rock_shore_strip_V1,
		sr3d_map_colors::color_rock_shore_island1,
		sr3d_map_colors::color_rock_shore_cross1,
		sr3d_map_colors::color_rock_shore_bend_RU1,
		sr3d_map_colors::color_rock_shore_bend_LU1,
		sr3d_map_colors::color_rock_shore_bend_LD1,
		sr3d_map_colors::color_rock_shore_bend_RD1,
		sr3d_map_colors::color_rock_shore_T_R1,
		sr3d_map_colors::color_rock_shore_T_U1,
		sr3d_map_colors::color_rock_shore_T_L1,
		sr3d_map_colors::color_rock_shore_T_D1,
		sr3d_map_colors::color_rock_shore_choke_R1,
		sr3d_map_colors::color_rock_shore_choke_U1,
		sr3d_map_colors::color_rock_shore_choke_L1,
		sr3d_map_colors::color_rock_shore_choke_D1,
		sr3d_map_colors::color_rock_shore_split_RU1,
		sr3d_map_colors::color_rock_shore_split_LU1,
		sr3d_map_colors::color_rock_shore_split_LD1,
		sr3d_map_colors::color_rock_shore_split_RD1,
		sr3d_map_colors::color_rock_shore_panhandleL_R1,
		sr3d_map_colors::color_rock_shore_panhandleL_U1,
		sr3d_map_colors::color_rock_shore_panhandleL_L1,
		sr3d_map_colors::color_rock_shore_panhandleL_D1,
		sr3d_map_colors::color_rock_shore_panhandleR_R1,
		sr3d_map_colors::color_rock_shore_panhandleR_U1,
		sr3d_map_colors::color_rock_shore_panhandleR_L1,
		sr3d_map_colors::color_rock_shore_panhandleR_D1,
		sr3d_map_colors::color_rock_shore_diagonal_R1,
		sr3d_map_colors::color_rock_shore_diagonal_L1,
		sr3d_map_colors::color_rock_sand_border_convex_RU1,
		sr3d_map_colors::color_rock_sand_border_convex_LU1,
		sr3d_map_colors::color_rock_sand_border_convex_LD1,
		sr3d_map_colors::color_rock_sand_border_convex_RD1,
		sr3d_map_colors::color_rock_sand_border_straight_R1,
		sr3d_map_colors::color_rock_sand_border_straight_U1,
		sr3d_map_colors::color_rock_sand_border_straight_L1,
		sr3d_map_colors::color_rock_sand_border_straight_D1,
		sr3d_map_colors::color_rock_sand_border_concave_RU1,
		sr3d_map_colors::color_rock_sand_border_concave_LU1,
		sr3d_map_colors::color_rock_sand_border_concave_LD1,
		sr3d_map_colors::color_rock_sand_border_concave_RD1,
		sr3d_map_colors::color_rock_sand_border_peninsula_R1,
		sr3d_map_colors::color_rock_sand_border_peninsula_U1,
		sr3d_map_colors::color_rock_sand_border_peninsula_L1,
		sr3d_map_colors::color_rock_sand_border_peninsula_D1,
		sr3d_map_colors::color_rock_sand_border_strip_H1,
		sr3d_map_colors::color_rock_sand_border_strip_V1,
		sr3d_map_colors::color_rock_sand_border_island1,
		sr3d_map_colors::color_rock_sand_border_cross1,
		sr3d_map_colors::color_rock_sand_border_bend_RU1,
		sr3d_map_colors::color_rock_sand_border_bend_LU1,
		sr3d_map_colors::color_rock_sand_border_bend_LD1,
		sr3d_map_colors::color_rock_sand_border_bend_RD1,
		sr3d_map_colors::color_rock_sand_border_T_R1,
		sr3d_map_colors::color_rock_sand_border_T_U1,
		sr3d_map_colors::color_rock_sand_border_T_L1,
		sr3d_map_colors::color_rock_sand_border_T_D1,
		sr3d_map_colors::color_rock_sand_border_choke_R1,
		sr3d_map_colors::color_rock_sand_border_choke_U1,
		sr3d_map_colors::color_rock_sand_border_choke_L1,
		sr3d_map_colors::color_rock_sand_border_choke_D1,
		sr3d_map_colors::color_rock_sand_border_split_RU1,
		sr3d_map_colors::color_rock_sand_border_split_LU1,
		sr3d_map_colors::color_rock_sand_border_split_LD1,
		sr3d_map_colors::color_rock_sand_border_split_RD1,
		sr3d_map_colors::color_rock_sand_border_panhandleL_R1,
		sr3d_map_colors::color_rock_sand_border_panhandleL_U1,
		sr3d_map_colors::color_rock_sand_border_panhandleL_L1,
		sr3d_map_colors::color_rock_sand_border_panhandleL_D1,
		sr3d_map_colors::color_rock_sand_border_panhandleR_R1,
		sr3d_map_colors::color_rock_sand_border_panhandleR_U1,
		sr3d_map_colors::color_rock_sand_border_panhandleR_L1,
		sr3d_map_colors::color_rock_sand_border_panhandleR_D1,
		sr3d_map_colors::color_rock_sand_border_diagonal_R1,
		sr3d_map_colors::color_rock_sand_border_diagonal_L1,
		sr3d_map_colors::color_rock_shoal_border_convex_RU1,
		sr3d_map_colors::color_rock_shoal_border_convex_LU1,
		sr3d_map_colors::color_rock_shoal_border_convex_LD1,
		sr3d_map_colors::color_rock_shoal_border_convex_RD1,
		sr3d_map_colors::color_rock_shoal_border_straight_R1,
		sr3d_map_colors::color_rock_shoal_border_straight_U1,
		sr3d_map_colors::color_rock_shoal_border_straight_L1,
		sr3d_map_colors::color_rock_shoal_border_straight_D1,
		sr3d_map_colors::color_rock_shoal_border_concave_RU1,
		sr3d_map_colors::color_rock_shoal_border_concave_LU1,
		sr3d_map_colors::color_rock_shoal_border_concave_LD1,
		sr3d_map_colors::color_rock_shoal_border_concave_RD1,
		sr3d_map_colors::color_rock_shoal_border_peninsula_R1,
		sr3d_map_colors::color_rock_shoal_border_peninsula_U1,
		sr3d_map_colors::color_rock_shoal_border_peninsula_L1,
		sr3d_map_colors::color_rock_shoal_border_peninsula_D1,
		sr3d_map_colors::color_rock_shoal_border_strip_H1,
		sr3d_map_colors::color_rock_shoal_border_strip_V1,
		sr3d_map_colors::color_rock_shoal_border_island1,
		sr3d_map_colors::color_rock_shoal_border_cross1,
		sr3d_map_colors::color_rock_shoal_border_bend_RU1,
		sr3d_map_colors::color_rock_shoal_border_bend_LU1,
		sr3d_map_colors::color_rock_shoal_border_bend_LD1,
		sr3d_map_colors::color_rock_shoal_border_bend_RD1,
		sr3d_map_colors::color_rock_shoal_border_T_R1,
		sr3d_map_colors::color_rock_shoal_border_T_U1,
		sr3d_map_colors::color_rock_shoal_border_T_L1,
		sr3d_map_colors::color_rock_shoal_border_T_D1,
		sr3d_map_colors::color_rock_shoal_border_choke_R1,
		sr3d_map_colors::color_rock_shoal_border_choke_U1,
		sr3d_map_colors::color_rock_shoal_border_choke_L1,
		sr3d_map_colors::color_rock_shoal_border_choke_D1,
		sr3d_map_colors::color_rock_shoal_border_split_RU1,
		sr3d_map_colors::color_rock_shoal_border_split_LU1,
		sr3d_map_colors::color_rock_shoal_border_split_LD1,
		sr3d_map_colors::color_rock_shoal_border_split_RD1,
		sr3d_map_colors::color_rock_shoal_border_panhandleL_R1,
		sr3d_map_colors::color_rock_shoal_border_panhandleL_U1,
		sr3d_map_colors::color_rock_shoal_border_panhandleL_L1,
		sr3d_map_colors::color_rock_shoal_border_panhandleL_D1,
		sr3d_map_colors::color_rock_shoal_border_panhandleR_R1,
		sr3d_map_colors::color_rock_shoal_border_panhandleR_U1,
		sr3d_map_colors::color_rock_shoal_border_panhandleR_L1,
		sr3d_map_colors::color_rock_shoal_border_panhandleR_D1,
		sr3d_map_colors::color_rock_shoal_border_diagonal_R1,
		sr3d_map_colors::color_rock_shoal_border_diagonal_L1

};
