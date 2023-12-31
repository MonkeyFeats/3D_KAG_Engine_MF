#include "PhysicalEntity.as"
#include "Octree.as"
#include "World.as"

shared class Bullet : PhysicalEntity
{
	Bullet(){}
	Bullet( CPlayer@ _ownerPlayer, Vec3f _Pos, Vec3f _Dir, int _team, int type = 0)
    {    	
        @rigidbody = RigidBody(this);
        transform.setPosition(_Pos-Vec3f(0,0,0));
        switch (type)
        {
            case 1:
            {
                @mesh = Mesh(this, "cube.obj", "box.png");
                @shape = BoundingSphere(@this, 4.0f, _Pos); 
                this.rigidbody.setVelocity( _Dir*300 );
                this.rigidbody.setLinearDrag( 0.1f );
                break;
            }
            default:
            {
                @mesh = Mesh(this, "sphere.obj");
                //mesh.setScale(Vec3f(4,4,4));
                @shape = BoundingSphere(@this, 4.0f, _Pos);    
                float r = -60+XORRandom(120);

                this.rigidbody.setVelocity( _Dir*300 ); //why work here... but not elsewhere
                //this.rigidbody.setAngularVelocity( Vec3f(-20+XORRandom(200),-20+XORRandom(200),-20+XORRandom(200)) );
                this.rigidbody.setLinearDrag( 0.11f ); 
 
            }
        }

        //this.netID = XORRandom(999999999);
        Name = "bullet";
        Team = _team;
        MaxHealth = Health = 1.0f; 
        @player = _ownerPlayer;

        this.setStatic(false);
    }
};
