
#include "Transform.as"
#include "RigidBody.as"
#include "Mesh.as"
#include "Entity.as"
#include "Component.as"
#include "Shapes3D.as"

//PhysicalEntity aka CBlob3D, a generic physical object
shared class PhysicalEntity : Entity
{
    Mesh@ mesh = Mesh();
    RigidBody@ rigidbody = RigidBody();
    BoundingShape@ shape;

    CPlayer@ player;
    float Health; float MaxHealth = 2.0f;
    bool Attached = false;
    int Team = -1;
    int Type = 0; //todo: make a PhysicsType classes (box,sphere,ray, etc.) instead of this, and do it in the shape
    int CustomData; //free real-estate
    private u32 TimeCreated;

    PhysicalEntity() 
    {
        TimeCreated = getGameTime();
        static = true;
    }

    bool isMyPlayer() const {return (player is getLocalPlayer());}
    bool opEquals(PhysicalEntity &in other) const {return this.netID == other.netID;}
    bool opNotEquals(PhysicalEntity &in  other) const {return this.netID != other.netID;}

    void SetPlayer(CPlayer@ _player) {@player = @_player;}
    void SetShape(BoundingShape@ _shape) {@shape = @_shape;}
    BoundingShape GetCollider() const {return shape;}
    Vec3f GetPosition() const {return transform.getPosition();}
    Vec3f GetVelocity() const {return rigidbody.getVelocity();}
    Vec3f GetAngularVelocity() const {return rigidbody.getAngularVelocity();}
    void SetVelocity(Vec3f &in vel) {rigidbody.setVelocity(vel);}
    void AddVelocity(Vec3f &in vel) {rigidbody.addVelocity(vel);}

    int getTeamNum() const {return this.Team;}
    CPlayer@ getPlayer() const {return this.player;};
    void setPlayer(CPlayer@ _player) {@this.player = _player;}
   
    void Damage(float _amount /*, PhysicalEntity@ damager*/) {Health -= _amount;}
    void server_Heal(float amount) {Health += amount; if (Health > MaxHealth) Health = MaxHealth;}
    void server_SetHealth(float amount) {Health = amount; if (Health > MaxHealth) Health = MaxHealth;}
    void server_Die() {Health = 0;}
    bool isAttached() const {return Attached;}
    bool isStatic() const {return static;}
    u32 getTickSinceCreated() const {return getGameTime() - TimeCreated;}

    void Update() 
    {
        if (!isStatic())
        rigidbody.Update();
    }

    IntersectionRecord Intersect(PhysicalEntity@ other)
    {
        Vec3f dirNormal;
        f32 distance;
        Vec3f[] intersectionPoints;
        ContainmentType type = shape.Contains(other.shape, dirNormal, intersectionPoints, distance);
        
        return IntersectionRecord(type, dirNormal, intersectionPoints, distance);
    }

    void Render() //override
    {  
        if(shape !is null)
        shape.Render();  
        if(mesh !is null)
        mesh.Render();
    }
}