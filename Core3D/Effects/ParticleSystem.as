
shared class ParticleSystem  
{
    ParticleSystem() {}
    void Update() {};
}

shared class PhysicalParticle : Entity
{
    Mesh@ mesh = Mesh();
    RigidBody@ rigidbody = RigidBody();
    u32 ticksSinceCreated = 0;

    void Update()
    {
        rigidbody.Update();
    }
    void Render()
    { 
        mesh.Render();
    }
}