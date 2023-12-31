#include "Triangle3D.as";

const string groundTex_name = "marbletiles.png";
const string edgewalltex_name = "NoGoZone.png";
//const float tUnit = 0.5f; //texture unit
const float depthAmp = -10.5;
const float ChunkSize = 48.0f*16;
//const float tUnit = 0.5f; //texture unit

shared class Terrain
{	
	uint32 worldWidth = ChunkSize;
	uint32 worldHeight = 32;
	uint32 worldDepth = ChunkSize;
	uint32 worldWidthDepth = (worldWidth * worldDepth);
	uint32 worldSize = worldWidthDepth * worldHeight;

	uint32 chunksWidth = 4;
	uint32 chunksHeight = 0;
	uint32 chunksDepth = 4;	
	uint32 chunksCount = (chunksWidth * chunksDepth);

	TerrainChunk[] Chunks;		

	Terrain(Entity@ world)
	{	
		for (int chunkZ = 0; chunkZ < 1; chunkZ++)
		for (int chunkX = 0; chunkX < 1; chunkX++)
		{
			TerrainChunk chunk(world, chunkX, chunkZ, ChunkSize);
			Chunks.push_back(chunk);
		}
	}

	TerrainChunk@ getChunk(int x, int y, int z)
    {
        if(!inChunkBounds(x, z)) return null;
        int index = z*chunksWidth + x;
        TerrainChunk@ chunk = @Chunks[index];
        return @chunk;
    }

    TerrainChunk@ getChunkWorldPos(Vec3f pos)
    {
        if(!inWorldBounds(pos.x, pos.z)) return null;
    	pos.x = int(pos.x/ChunkSize); pos.z = int(pos.z/ChunkSize);
    	
        int index = pos.z * chunksWidth + pos.x;

        //print(""+index);
        TerrainChunk@ chunk = @Chunks[index];
        return @chunk;
    }   

    bool inWorldBounds(int x, int z)
    {
        if(x<0 || z<0 || x>=worldWidth || z>=worldDepth) return false;
        return true;
    }
    
    bool inChunkBounds(int x, int z)
    {
        if(x<0 || z<0 || x>=chunksWidth || z>=chunksDepth) return false;
        return true;
    }

    void clearVisibility()
    {
        for(int i = 0; i < chunksCount; i++)
        {
            Chunks[i].visible = false;
        }
    }


	void Render()
	{	
		for(uint i = 0; i < Chunks.size(); i++)
		{
			TerrainChunk@ chunk = Chunks[i];		
			//if (!chunk.visible) continue; 
			chunk.Render(); 
		}		
	}
}

shared class TerrainChunk
{	
	int ChunkX, ChunkZ, ChunkSize;
	bool visible, empty;
	BoundingShape@ box;

	Mesh@ ChunkMesh = Mesh();

	Vec3f[] Vertex_Positions;
	Vertex[] ground_Vertices;
	u16[] ground_IDs;

	Vec3f[] triangle;

	TerrainChunk(){}

	TerrainChunk(Entity@ _world, int _ChunkX, int _ChunkZ, int _ChunkSize)
	{
		triangle.set_length(3);
		empty = false;
		visible = true;

		ChunkX = _ChunkX;
		ChunkZ = _ChunkZ;
		ChunkSize = _ChunkSize;
		CreateTerrainMesh(_world);
	}

	void SetVisible()
    {
        visible = true;
    }

	void CreateTerrainMesh(Entity@ _world)
	{
		CMap@ map = getMap();

		Vertex_Positions.clear();
		ground_Vertices.clear();
		ground_IDs.clear();	
				
		const string MapName = map.getMapName();
		if(!Texture::exists(MapName)) { Texture::createFromFile(MapName, MapName); }
		ImageData@ heightmap = Texture::data(MapName);

		const float tScale = ChunkSize/256;
		uint t = 0;
		u16 StartX = (ChunkX*ChunkSize);
		u16 StartZ = (ChunkZ*ChunkSize);

		uint chunksWidth = 1;
		uint chunksDepth = 1;
		//print("sx "+StartX+ " sy "+StartZ);
		uint ChunkSizeX = Maths::Min(StartX+ChunkSize,chunksWidth)-StartX;
		uint ChunkSizeZ = Maths::Min(StartZ+ChunkSize,chunksDepth)-StartZ;
		
		ground_Vertices.set_length((ChunkSizeX+1)*(ChunkSizeZ+1));
		ground_IDs.set_length((ChunkSizeX*ChunkSizeZ*6));	

		@box = AABB(Vec3f(0, -2, 0), Vec3f((StartZ+ChunkSize), 0, (StartX+ChunkSize)));

		for (int row = 0; row <= ChunkSizeZ; row++) 
		{
			for (int col = 0; col <= ChunkSizeX; col++) 
		{
				int index = (row*(ChunkSizeX+1))+col;

				ground_Vertices[index] = (Vertex((StartX+col)*ChunkSize, 0, (StartZ+row)*ChunkSize, (StartX+col)*tScale, (StartZ+row)*tScale));		        
		    } 
		}
			
		for (int row = 0; row < ChunkSizeZ; row++) 		
		{
			for (int col = 0; col < ChunkSizeX; col++) 
			{			
	            int index = (row*(ChunkSizeX+1))+col;

	            int tl = index;
				int tr = index + 1;
				int bl = index + (ChunkSizeX+1);
				int br = index + (ChunkSizeX+1)+1;
				{
					ground_IDs[t] =   tl;
					ground_IDs[t+1] = bl;
		            ground_IDs[t+2] = tr;

		            ground_IDs[t+3] = bl;
		            ground_IDs[t+4] = br;
		            ground_IDs[t+5] = tr;		            
				}	
				t+=6;
			}
		}

		if (ground_Vertices.length() > 0)
		{
			@ChunkMesh = Mesh(_world, ground_Vertices, ground_IDs); 
        	@ChunkMesh.parent = _world;       
        	ChunkMesh.setMatFlag(SMaterial::BACK_FACE_CULLING, false);
			ChunkMesh.setMatFlag(SMaterial::GOURAUD_SHADING, true);
			ChunkMesh.setMatFlag(SMaterial::FOG_ENABLE, true);
			ChunkMesh.meshMaterial.SetTexture("marbletiles.png", 0);
        	ChunkMesh.MaterialSetDirty();
		}

		if(ground_Vertices.size() == 0)
        {
            empty = true;
        }
	}
	
	float getGroundHeight(Vec3f Pos) 
	{
    	return 7.2;
	}

	void Render()
	{
		ChunkMesh.Render();
	}
}