#include "TypeEnums.as"
#include "MathsHelper.as"
#include "Vec4f.as"
#include "Quaternion.as"
#include "BoundingSphere.as"
#include "BoundingFrustum.as"
#include "OBB.as"
#include "AABB.as"
#include "Ray.as"
#include "PhysicalEntity.as"
#include "PhysicsMaterial.as"
#include "World.as"
#include "IntersectData.as"
//#include "Collisions.as"

shared class BoundingShape : EntityComponent
{    
    PhysicsMaterial@ physmat;
    Mesh@ DebugMesh = Mesh();    
    //Mesh@ hitDebugMesh = Mesh();  

    Vec3f Center; //Shape local offset position
    bool onGround 	= false; //probably move these two.. somewhere
	bool onMap 		= false;
    bool Collides 	= true; //change to isTrigger?
    //bool Rotates 	= false;
	//int customData; //custom number for stuff, maybe should just add a dictionary

    bool opEquals(BoundingShape other) const {return this == other;}

    void setParent(PhysicalEntity@ _blob) {@parent = _blob;}
    PhysicalEntity@ getParent() {return cast<PhysicalEntity@>(parent);}

	void setPosition(Vec3f &in _pos) {parent.transform.setPosition(_pos);}
    Vec3f getPosition() {return parent.transform.getPosition();}
    //Vec3f getInterpolatedPosition(float amount = 0.5f) {return old_Position.Lerp(transform.Position, amount);}
    void setDirection(Vec3f &in dir) {parent.transform.setRotation(dir); }
    //void addDirection(Vec3f &in dir) {transform.Orientation +=   transform.Orientation.Transform(dir); }
    void setAngleDegreesX(float &in x)  { parent.transform.setRotation(Vec3f(x,parent.transform.getRotation().y,parent.transform.getRotation().z)); }
    void setAngleDegreesY(float &in y)  { parent.transform.setRotation(Vec3f(parent.transform.getRotation().x,y,parent.transform.getRotation().z)); }
    void setAngleDegreesZ(float &in z)  { parent.transform.setRotation(Vec3f(parent.transform.getRotation().x,parent.transform.getRotation().y,z)); }

    //void setAngleDegrees(float angle) {transform.Orientation.TransformX(angle);}
    float getAngleDegrees() {return parent.transform.getRotation().x;}
    Vec3f getDirection() {return parent.transform.getRotation();}


    bool isStatic() {return parent.isStatic();}

    void Update() 
    {
        if (this.isStatic()) return;
    }


    Vec3f CalculateMassInertia(Vec3f otherPos )
    {
        float radius = (parent.transform.position - otherPos).length()/16;
        Vec3f size = (parent.transform.position - otherPos);
        float mass = 10;
        Vec3f inertia;
        inertia.x = (1.0f / radius) * mass * (size.y * size.y + size.z * size.z);
        inertia.y = (1.0f / radius) * mass * (size.x * size.x + size.z * size.z);
        inertia.z = (1.0f / radius) * mass * (size.x * size.x + size.y * size.y);
        return inertia/16;
    }   

    void Render() {}

    IntersectionRecord Intersect(BoundingShape@ other)
    {
        Vec3f MTV;
        Vec3f[] hitPos;
        f32 dist;
        ContainmentType type = this.Contains(other, MTV, hitPos, dist);
        
        return IntersectionRecord(type, MTV, hitPos, dist);
    }


    ContainmentType Contains(BoundingShape@ other, Vec3f &out MTV, Vec3f[] &out hitPos, f32 &out dist) 
    {
        AABB@ aabbox = cast<AABB@>(other);
        OBB@ obbox = cast<OBB@>(other);
        BoundingSphere@ sphere = cast<BoundingSphere@>(other);
        if (aabbox !is null)
        {
            return this.Contains(aabbox, MTV, hitPos, dist);
        }
        else if (obbox !is null)
        {
            return this.Contains(obbox, MTV, hitPos, dist);
        }
        else if (sphere !is null)
        {
            return this.Contains(sphere, MTV, hitPos, dist);
        }        
        return ContainmentType::None;
    }

    ContainmentType Contains(BoundingShape@ other) 
    {
        AABB@ abbox = cast<AABB@>(other);
        OBB@ obbox = cast<OBB@>(other);
        BoundingSphere@ sphere = cast<BoundingSphere@>(other);

        if (abbox !is null)
        {
            return this.Contains(obbox);
        }
        if (obbox !is null)
        {
            return this.Contains(obbox);
        }
        if (sphere !is null)
        {
            return this.Contains(sphere);
        }
        return ContainmentType::None;
    }

    //overridden
    ContainmentType Contains(AABB@ box) {return ContainmentType::None;}
    ContainmentType Contains(AABB@ box, Vec3f &out MTV, Vec3f[] &out hitPos, f32 &out dist) {return ContainmentType::None;}
    ContainmentType Contains(OBB@ box) {return ContainmentType::None;}
    ContainmentType Contains(OBB@ box, Vec3f &out MTV, Vec3f[] &out hitPos, f32 &out dist) {return ContainmentType::None;}
    ContainmentType Contains(BoundingSphere@ sphere) {return ContainmentType::None;}
    ContainmentType Contains(BoundingSphere@ sphere, Vec3f &out MTV, Vec3f[] &out hitPos, f32 &out dist) {return ContainmentType::None;}

    void UpdateAttributes(SColor){};
    bool Intersects(BoundingShape@ ray, float distance = 99999999) {return ray.Intersects(this); }

}