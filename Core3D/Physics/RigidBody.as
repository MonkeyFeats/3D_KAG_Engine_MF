#include "World.as"
#include "PhysicalEntity.as"

shared class RigidBody : EntityComponent
{
    float Mass 	= 80.0;
	float LinearDragScale = 0.05;
    float AngularDragScale = 0.02;
	float GravityScale = 1.0;
    //float Buoyancy = 0.5;

    bool FreezePos, FreezePosX,FreezePosY,FreezePosZ;
    bool FreezeRot, FreezeRotX, FreezeRotY, FreezeRotZ;

    //private float Speed; 
    private Vec3f Velocity; //, OldVelocity;
    private Vec3f AngularVelocity;
    private Vec3f InertiaTensor;
    private Vec3f InertiaTensorRotation;
    private Vec3f WorldCenterOfMass;
    private Vec3f LocalCenterOfMass;
    private int SleepState;

    RigidBody(){}
    RigidBody(PhysicalEntity@ _parent){@parent = _parent;}

    Vec3f getVelocity() {return Velocity;}
    void setVelocity(Vec3f _vel) {Velocity = _vel;}
    void addVelocity(Vec3f _force) {Velocity += _force;}
    //void AddForceAtPosition(Vec3f force, Vec3f pos) {}
    Vec3f getAngularVelocity() {return AngularVelocity;} 
    void setAngularVelocity(Vec3f _vel) {if (FreezeRot) return; AngularVelocity = _vel*(Maths::Pi/180);}
    void addAngularVelocity(Vec3f _angvel) {if (FreezeRot) return; AngularVelocity += _angvel*(Maths::Pi/180);}
    float getLinearDrag() {return 1.0-(LinearDragScale);}
    float getAngularDrag() {return 1.0-(AngularDragScale);}
    void setLinearDrag(float _drag) {LinearDragScale = _drag;}
    float getMass() {return Mass;}

    void Update() 
    {
        if (parent.isStatic()) return;

        //if (Maths::Abs(this.Velocity.x) < 0.01) this.Velocity.x = 0;
        //if (Maths::Abs(this.Velocity.y) < 0.01) this.Velocity.y = 0;
        //if (Maths::Abs(this.Velocity.z) < 0.01) this.Velocity.z = 0;
//
        //if (Maths::Abs(this.AngularVelocity.x) < 0.01) this.AngularVelocity.x = 0;
        //if (Maths::Abs(this.AngularVelocity.y) < 0.01) this.AngularVelocity.y = 0;
        //if (Maths::Abs(this.AngularVelocity.z) < 0.01) this.AngularVelocity.z = 0;
        
        //todo: set blob to static if the mass is set to 0;

        Vec3f GravForce( 0,-9.81*GravityScale, 0); 
        this.addVelocity(GravForce);
        this.Velocity *= getLinearDrag(); 
        parent.transform.addPosition(this.getVelocity()/this.Mass);         

        //print(""+this.AngularVelocity);
        if (FreezeRot) return;
        this.AngularVelocity *= getAngularDrag(); 
        parent.transform.addRotation(this.AngularVelocity);

        float time = getGameTime()/getTicksASecond();   
    }

    //calculate this stuff for each shape
   //void CalculateMassInertia()
   //{
   //    mass = size.x * size.y * size.z;
   //    Vec3f inertia;
   //    inertia.x = (1.0f / 12.0f) * Mass * (size.y * size.y + size.z * size.z);
   //    inertia.y = (1.0f / 12.0f) * Mass * (size.x * size.x + size.z * size.z);
   //    inertia.z = (1.0f / 12.0f) * Mass * (size.x * size.x + size.y * size.y);
   //    InertiaTensor = inertia;
   //    LocalCenterOfMass = Vec3f();
   //}    

       Vec3f getInertia()
    {
        Vec3f tensor;
        Vec3f size = Vec3f(4,4,4) * 2.0f; //box
        float fraction = (1.0f / 12.0f);
        float x2 = size.x * size.x;
        float y2 = size.y * size.y;
        float z2 = size.z * size.z;
        tensor.x = (y2 + z2) * Mass * fraction;
        tensor.y = (x2 + z2) * Mass * fraction;
        tensor.z = (x2 + y2) * Mass * fraction;
        //tensor.w = 1.0f;
        return tensor;
    }  

    Vec3f inverseMassInertia()
    {
        Vec3f inertia;
        inertia.x = (1.0f / 12.0f) * this.getMass();
        inertia.y = (1.0f / 12.0f) * this.getMass();
        inertia.z = (1.0f / 12.0f) * this.getMass();
        InertiaTensor = inertia;
        LocalCenterOfMass = Vec3f();
        return inverseInertiaTensor();
    }   

    //    // Set the local inertia tensor of the body (in local-space coordinates)
//    /// Note that an inertia tensor with a zero value on its diagonal is interpreted as infinite inertia.
//    /**
//     * @param inertiaTensorLocal A vector with the three values of the diagonal 3x3 matrix of the local-space inertia tensor
//     */

    Vec3f inverseInertiaTensor()
    { return Vec3f(InertiaTensor.x != 0.0f ? 1.0f / InertiaTensor.x : 0,
                    InertiaTensor.y != 0.0f ? 1.0f / InertiaTensor.y : 0,
                     InertiaTensor.z != 0.0f ? 1.0f / InertiaTensor.z : 0);
    }

    const Vec3f getInertiaTensor() const 
    {
        return InertiaTensor;
    }


    void addForceAtLocalPosition(Vec3f force, Vec3f point) 
    {
        // If it is not a dynamic body, we do nothing
        //if (getBodyType(Entity) != BodyType::DYNAMIC) return;

        // Awake the body if it was sleeping
        //if (getIsSleeping(mEntity)) { setIsSleeping(false); }

        // Add the force
       // const Vec3f& externalForce = getExternalForce();
        //setVelocity(force*((point - parent.transform.getPosition()).length()));
//
       // // Add the torque
       // const Vec3f externalTorque = getExternalTorque();
        Vec3f angvel = Cross((point), force);
        angvel.normalize();
        addAngularVelocity(-angvel);
    }
//

    
}