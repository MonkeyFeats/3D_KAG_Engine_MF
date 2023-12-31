#include "BasicTerrainGen.as"
#include "OceanWater.as"
#include "Mesh.as"

//find a better name for this..
//this is just holding the static scenery/world stuff

shared class Floor : PhysicalEntity
{
	Floor()
    {    	
        Name = "Floor";
        this.setStatic(true);
		@rigidbody = RigidBody(this);
    	@shape = AABB(this, Vec3f(0,-5,0), Vec3f(500,0,500), Vec3f());
    	CreateworldFloor();
    }

    void CreateworldFloor()
	{		
		Vertex[] floor_Vertices;
		floor_Vertices.push_back(Vertex(0,   0, 500, 16,0,		SColor(255, 255,255,255)));
		floor_Vertices.push_back(Vertex(500, 0, 500, 16,16,		SColor(255, 255,255,255)));
		floor_Vertices.push_back(Vertex(500, 0, 0,	 0,16,		SColor(255, 255,255,255)));
		floor_Vertices.push_back(Vertex(0,   0, 0,	 0,0,		SColor(255, 255,255,255)));

		@mesh = Mesh(this, floor_Vertices, Square_IDs());      
        mesh.setMatFlag(SMaterial::BACK_FACE_CULLING, false);
		mesh.setMatFlag(SMaterial::GOURAUD_SHADING, true);
		mesh.setMatFlag(SMaterial::FOG_ENABLE, true);
		mesh.meshMaterial.SetTexture("marbletiles.png", 0);
        mesh.MaterialSetDirty();
	}
};

shared class World : Entity
{	
	Mesh@ SkyMesh;
	Mesh@ EdgeWallMesh;
	OceanWater@ Ocean = OceanWater();
	//Terrain@ terrain = Terrain(this);
	Floor@ floor = Floor();

	World(){}
	World()
	{	
		this.static = true;
		floor.setStatic(true);
		@SkyMesh = Mesh(this, "SkyBox.obj", "SkyBox.png");
		CreateworldEdgeWalls();

	}

	void CreateworldEdgeWalls()
	{		
		Vertex[] edgewall_Vertices;
		edgewall_Vertices.push_back(Vertex(0,-0,   500,	2,0,		SColor(150, 255,255,255)));
		edgewall_Vertices.push_back(Vertex(0, 500, 500,	2,2,		SColor(150, 255,255,255)));
		edgewall_Vertices.push_back(Vertex(0, 500, 0,	0,2,		SColor(150, 255,255,255)));
		edgewall_Vertices.push_back(Vertex(0,-0,   0,	0,0,		SColor(150, 255,255,255)));

		@EdgeWallMesh = Mesh (this, edgewall_Vertices, Square_IDs(), "NoGoZone.png", SMaterial::TRANSPARENT_ALPHA_CHANNEL);
		EdgeWallMesh.setMatFlag(SMaterial::BACK_FACE_CULLING, false);	
		EdgeWallMesh.MaterialSetDirty();	
	}

	void Render()
	{
	    Ocean.Update(); //move to tick update maybe

		SkyMesh.Render();
		Ocean.Render();
		//terrain.Render();
		EdgeWallMesh.Render();
		floor.Render();
	}
};
