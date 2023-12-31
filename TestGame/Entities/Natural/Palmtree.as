#include "PhysicalEntity.as"

Random rnd(941527533);

shared class PalmTree : PhysicalEntity
{
	PalmTree(){}
	PalmTree( CPlayer@ _player, Vec3f _Pos, int _team, float _maxhealth, BoundingShape@ _shape)
    {    	
        this.netID = XORRandom(999999999);
        Name = "palmtree";
        Team = _team;
        transform.Position = _Pos;
        MaxHealth = Health = _maxhealth; 
        @player = _player;
        @_shape.parent = this;
        @shape = _shape;

        shape.SetStatic(true);

        onInit();
    }

	void onInit() override
	{	
		this.LoadObjIntoMesh("RockCorner1.obj");
		SMaterial@ meshMaterial = this.meshbuffer.getMaterial();
		meshMaterial.SetFlag(SMaterial::LIGHTING, false);	

		//mesh.setAngleDegrees(rnd.NextRanged(360));	
	}

	f32 onHit(Vec2f worldPoint, Vec2f velocity, f32 damage, PhysicalEntity@ hitterBlob, u8 customData )
	{
		damage = 0.0f;
		return damage;
	}

};