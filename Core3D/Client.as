
//#define CLIENT_ONLY

#include "PhysicalEntity.as"
#include "Camera3D.as"
#include "OcTree.as"
#include "World.as"
#include "Bullet.as"

const string sync_id = "mapvote: sync";

World@ world; //needs a better place

void onInit(CRules@ this)
{
	this.addCommandID(sync_id);
	this.addCommandID("addBlob");
	this.addCommandID("CreatePhysicalEntity");
	Render::addScript(Render::layer_objects, "Client.as", "threedee", 0.0f);
	CHUD@ hud = getHUD();
	hud.HideCursor();
}

void onTick(CRules@ this)
{
	engine.Update();
	float time = getGameTime();
	if (time == 60)
 	{
 		CBitStream params;
		this.SendCommand(this.getCommandID("addBlob"), params); 		
 	} 	
}

void threedee(int id)
{
	CRules@ rules = getRules();

	rules.set_f32("interFrameTime", Maths::Clamp01(rules.get_f32("interFrameTime")+getRenderApproximateCorrectionFactor()));
	rules.add_f32("interGameTime", getRenderApproximateCorrectionFactor());	

	CPlayer@ p = getLocalPlayer();
	if(p !is null)
	{		
		Camera3D@ camera;
		p.get("Camera3D", @camera);
		if (camera is null) { return; }
		if (world is null) { return; }			

		camera.render_update();		
			
		Render::SetAlphaBlend(false);
		Render::SetZBuffer(true, true);
		Render::ClearZ();
		Render::SetBackfaceCull(true);

		f32[] worldMatrix; camera.worldMatrix.getArray(worldMatrix);
        f32[] viewarray; camera.viewMatrix.getArray(viewarray);
        f32[] projarray; camera.projMatrix.getArray(projarray);

		Render::SetTransform(worldMatrix, viewarray, projarray);
		Render::SetFog(SColor(0xff3c4455), Driver::LINEAR, 500.0, 800.0, 0.0, false, true);
		//Render::SetAlphaBlend(true);
		world.Render();
		engine.worldTree.Render();
		Render::SetAlphaBlend(false);

		for (uint i = 0; i < engine.allObjects.size(); i++)
		{
			engine.allObjects[i].Render();
		}

	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	CBitStream params;
	u16 id = player.getNetworkID();
	params.write_u16(id);
	this.SendCommand(this.getCommandID(sync_id), params);	
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{		
	if (cmd == this.getCommandID(sync_id))
	{	
		u16 id = params.read_u16();
		CPlayer@ player = getPlayerByNetworkId(id);
		if (player.isMyPlayer())
		{				
			//LoadMapShapes(getMap());

			World@ _world = World();
			if (_world !is null)
			@world = _world;

		engine.addEntity(world.floor);

			//Root _tree(world.mapWidth, world.mapHeight, world.mapDepth);
			//if ( _tree !is null )
			//{
			//	@tree = _tree;
			//}
			//SetUpTree();
			//for(int i = 0; i < world.Chunks.size(); i++)
			//{
			//	DrawHitbox(world.Chunks[i].shape, 0xffffffff);
			//}
		}
	}

	if (cmd == this.getCommandID("CreatePhysicalEntity"))
	{			
		float p_x = params.read_f32();
		float p_y = params.read_f32();
		float p_z = params.read_f32();

		float dir_x = params.read_f32();
		float dir_y = params.read_f32();
		float dir_z = params.read_f32();

		u16 id = params.read_u16();
		CPlayer@ player = getPlayerByNetworkId(id);
		print("shot ");
		
        PhysicalEntity@ bullet = Bullet( player, Vec3f(p_x,p_y,p_z), Vec3f(dir_x,dir_y,dir_z), player.getTeamNum(), 0);
        if (bullet !is null)
        {
        	engine.addEntity(bullet);
        }
	}
}
