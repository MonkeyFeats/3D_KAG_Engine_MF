#include "PhysicalEntity.as"
#include "Octree.as"
#include "Camera3D.as"

int useClickTime = 0;
const int FIRE_RATE = 40;
const f32 BULLET_SPREAD = 0.2f;
const f32 BULLET_SPEED = 9.0f;
const f32 BULLET_RANGE = 350.0f;
Random _shotspreadrandom(0x11598); //clientside

shared class Human : PhysicalEntity
{
	Human(){}
	Human(Vec3f _Pos, int _team, float _maxhealth)
    {
        Name = "human";
        Team = _team;
        transform.setPosition(_Pos);
        MaxHealth = Health = _maxhealth; 

		@rigidbody = RigidBody(this);
        @shape = AABB(this, Vec3f(-3.3, 0.0, -3.3), Vec3f(3.3, 18.0, 3.3), _Pos);

        this.setStatic(false);
        @mesh = Mesh(this, "Capsule.obj");
    }
	Human( CPlayer@ _player, Vec3f _Pos, int _team, float _maxhealth)
    {
        Name = "human";
        Team = _team;
        transform.setPosition(_Pos);
        MaxHealth = Health = _maxhealth; 
        @player = _player;

        @rigidbody = RigidBody();
        @rigidbody.parent = this;
        @shape = AABB(this, Vec3f(-3.3, 0.0, -3.3), Vec3f(3.3, 18.0, 3.3), _Pos);

        this.setStatic(false);

        @mesh = Mesh(this, "Capsule.obj");
    }

    bool canShootPistol( PhysicalEntity@ this )
	{
		//return !this.hasTag( "dead" ) && this.get_string( "current tool" ) == "pistol" && this.get_u32("fire time") + FIRE_RATE < getGameTime();
		return this.get_u32("fire time") + FIRE_RATE < getGameTime();
	}

	void Update() override
	{
		CControls@ controls = getControls();
	    Driver@ driver = getDriver();

		if(player !is null)
		{	
			//const bool myPlayer = player.isMyPlayer();
			//const bool attached = this.isAttached();

			//Vec3f pos = this.getPosition();//sat_shape.Pos;	
			//Vec3f aimpos = this.getAimPos();
			//Vec3f forward = aimpos - pos;
			//CShape@ shape = this.getShape();
			//CSprite@ sprite = this.getSprite();
			
			//string currentTool = this.get_string( "current tool" );
			
			if (!isAttached())
			{	
				const bool action1 = controls.ActionKeyPressed(AK_ACTION1);
				
				if (canShootPistol( this ) && action1)
				{	
					ShootPistol( this, player );
				}
			}
		}


		Movement(controls, driver);
		rigidbody.Update();
	}

	void Movement(CControls@ controls, Driver@ driver)
	{	
		//if (this.getTickSinceCreated() < 10) return;		

		const bool left		= controls.ActionKeyPressed(AK_MOVE_LEFT);
		const bool right	= controls.ActionKeyPressed(AK_MOVE_RIGHT);
		const bool up		= controls.ActionKeyPressed(AK_MOVE_UP);
		const bool down		= controls.ActionKeyPressed(AK_MOVE_DOWN);
		const bool spacebar	= controls.ActionKeyPressed(AK_ACTION3);
		const bool shift	= controls.isKeyPressed( KEY_LSHIFT );
		const bool is_client = getNet().isClient();
		const float time = getGameTime();

		Vec3f Vel = this.rigidbody.getVelocity();
		Vec3f Pos = this.transform.getPosition();
		Vec3f moveForce;

		bool playerHasControls = isWindowActive() && isWindowFocused() && Menu::getMainMenu() is null && !getHUD().hasButtons()/* && !block_menu*/;

		CPlayer@ player = getLocalPlayer();
		if(player !is null)
		{
			Camera3D@ camera; player.get("Camera3D", @camera);
			if (camera !is null)
			{	
			    if ( playerHasControls )
			    {
			    	float angle = -camera.rotationAngle;

			    	float radians = Maths::Pi/180.0f;
    				float cs = 8*  Maths::Cos(radians*(angle));
    				float sn = 8*  Maths::Sin(radians*(angle));
    				float cs90 = 8* Maths::Cos(radians*(angle-90));
    				float sn90 = 8* Maths::Sin(radians*(angle-90));

			        //this.transform.rotation.CreateFromAxisAngle(Vec3f(0,0,1), angle*(Maths::Pi/180));
					// move	
					if (up)	{ moveForce.x += -sn90; moveForce.z += -cs90; }
					if (down){ moveForce.x = sn90; moveForce.z += cs90; } 		
					if (left){ moveForce.x += sn; moveForce.z += cs; }
					if (right){ moveForce.x += -sn; moveForce.z += -cs; }
					//if (shift)	  moveForce.y = -moveVars.walkSpeed;
					//jumping
					//if (canjump)
					//if (shape.onGround)
					{			
					    if (spacebar) 
					    {
					    	moveForce.y = 100;
					    }
					}
				}
			}
		}
		
		//if (canmove)
		{
			moveForce.rotateXZ(-this.transform.getRotation().y);
			rigidbody.addVelocity(moveForce);
		}
	}

	void ShootPistol(PhysicalEntity@ this, CPlayer@ player)
	{
		if ( !this.isMyPlayer() )
			return;

		Camera3D@ camera; player.get("Camera3D", @camera);
		if (camera !is null)
		{
			Vec3f pos = this.transform.getPosition()+Vec3f(0,32, 0);
			Vec3f aimVector = camera.transform.rotation.getYawPitchRoll();
			//const f32 aimdist = aimVector.Normalize();
			//Vec2f offset(_shotspreadrandom.NextFloat() * BULLET_SPREAD,0);
			//offset.RotateBy(_shotspreadrandom.NextFloat() * 360.0f, Vec2f());
			//Vec2f vel = (aimVector * BULLET_SPEED) + offset;
			//f32 lifetime = Maths::Min( 0.05f + BULLET_RANGE/BULLET_SPEED/32.0f, 1.35f);
	
			CBitStream params;
			params.write_f32( pos.x );  params.write_f32( pos.y );  params.write_f32( pos.z );
			params.write_f32( aimVector.x );  params.write_f32( aimVector.y );  params.write_f32( aimVector.z );
			u16 id = player.getNetworkID();
			params.write_u16(id);
	
			getRules().SendCommand( getRules().getCommandID("CreatePhysicalEntity"), params );
	
			this.set_u32("fire time", getGameTime());
		}
	}
};