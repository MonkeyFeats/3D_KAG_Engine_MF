
#include "TypeEnums.as"
#include "BoundingFrustum.as"
#include "Plane.as"
#include "Ray.as"
#include "Shapes3D.as"

#include "ShapeArrays.as"

shared class BoundingSphere : BoundingShape
{    
    float Radius;

    BoundingSphere(float _radius)
    {
        this.Radius = _radius;
        UpdateAttributes(SColor(150, 0, 255, 0));
    }

    BoundingSphere(Vec3f _Position, float _radius)
    {
        //super(_Position);
        this.Radius = _radius;
        UpdateAttributes(SColor(150, 0, 255, 0));
    }

    BoundingSphere(Entity _parent, float _radius)
    {
        @parent = _parent;
        this.Radius = _radius;
        UpdateAttributes(SColor(150, 0, 255, 0));
    }

    BoundingSphere(PhysicalEntity@ _parent, float _radius, Vec3f _pos)
    {
        //super(_Position);
        @parent = _parent;
        this.setPosition(_pos);
        UpdateAttributes(SColor(150, XORRandom(255), XORRandom(255), XORRandom(255)));
    }

    
    void setPosition(Vec3f &in pos) override {if (parent !is null) parent.transform.setPosition(pos);}
    Vec3f getPosition() override {if (parent !is null) return parent.transform.getPosition(); return Vec3f();}

    void setDirection(Vec3f &in _axis) override {parent.transform.setRotation(_axis); }
    float getAngleDegrees() override {return parent.transform.getRotation().x;}
    Vec3f getDirection() override {return parent.transform.getRotation();}

    void CreateFromPoints(Vec3f[] points)
    {
        if (points.size() < 8)
        {
            warn("CreateFromPoints, needs more points");
        }

        float _radius = 0;
        Vec3f Position = Vec3f();
        // First, we'll find the Position of gravity for the point 'cloud'.
        int num_points = points.size(); // The number of points (there MUST be a better way to get this instead of counting the number of points one by one?)
        
        for (int i = 0; i < num_points; ++i)
        {
            Vec3f v = points[i];
            Position += v;    // If we actually kthe number of points, we'd get better accuracy by adding v / num_points.
        }
        
        Position /= num_points;

        // Calculate the radius of the needed sphere (it equals the distance between the Position and the point further away).
        for (int i = 0; i < num_points; ++i)
        {
            Vec3f v  = points[i];
            float distance = (v - Position).length();
            
            if (distance > _radius)
                Radius = distance;
        }

            UpdateAttributes(SColor(150, 255, 0, 0));
    }

    void UpdateAttributes(SColor col) override
    {
        @DebugMesh = Mesh(this.parent, "sphere.obj"); 
        @DebugMesh.parent = @this.parent;       
        DebugMesh.setMatFlag(SMaterial::BACK_FACE_CULLING, false);
        DebugMesh.meshMaterial.SetFlag(SMaterial::WIREFRAME, true);
        DebugMesh.meshMaterial.Thickness = 1.0f;
        DebugMesh.MaterialSetDirty();
    }

    void Render() override
    { 
        //f32[] marray; parent.model.getArray(marray);
        //Render::SetModelTransform(marray);
        DebugMesh.Render();
    }


    BoundingSphere Transform(Matrix4 matrix)
    {
        BoundingSphere sphere();
        sphere.setPosition(this.getPosition());
        sphere.Radius = this.Radius * float(Maths::Sqrt(float(Maths::Max(((matrix[0] * matrix[0]) + (matrix[1] * matrix[1])) + (matrix[2] * matrix[2]), Maths::Max(((matrix[4] * matrix[4]) + (matrix[5] * matrix[5])) + (matrix[6] * matrix[6]), ((matrix[8] * matrix[8]) + (matrix[9] * matrix[9])) + (matrix[10] * matrix[10]))))));
        return sphere;
    }

    void Transform(Matrix4 matrix, BoundingSphere &out result)
    {
        result.setPosition(this.getPosition());
        result.Radius = this.Radius * float(Maths::Sqrt(float(Maths::Max(((matrix[0] * matrix[0]) + (matrix[1] * matrix[1])) + (matrix[2] * matrix[2]), Maths::Max(((matrix[4] * matrix[4]) + (matrix[5] * matrix[5])) + (matrix[6] * matrix[6]), ((matrix[8] * matrix[8]) + (matrix[9] * matrix[9])) + (matrix[10] * matrix[10]))))));
    }

    ContainmentType Contains(AABB@ box, Vec3f &out MTV, Vec3f[] &out hitPos, f32 &out depth) override
    {
        Vec3f sphereCenter = getPosition();
         // if (sphereCenter.x - box.Min.x > Radius
         //  && sphereCenter.y - box.Min.y > Radius
         //  && sphereCenter.z - box.Min.z > Radius
         //  && box.Max.x - sphereCenter.x > Radius
         //  && box.Max.y - sphereCenter.y > Radius
         //  && box.Max.z - sphereCenter.z > Radius)
         //  return ContainmentType::Contains;

        if (sphereCenter.x - (box.getPosition().x+box.Min.x) <=  Radius)      { depth += (sphereCenter.x - (box.getPosition().x+box.Min.x)); MTV = Vec3f( -1,0,0);}
        else if ((box.getPosition().x+box.Max.x) - sphereCenter.x <= Radius)      { depth += (sphereCenter.x - (box.getPosition().x+box.Max.x)); MTV = Vec3f(1,0,0);}
        if (sphereCenter.y - (box.getPosition().y+box.Min.y) <=  Radius)      { depth += (sphereCenter.y - (box.getPosition().y+box.Min.y)); MTV = Vec3f(0, -1,0);}
        else if ((box.getPosition().y+box.Max.y) - sphereCenter.y <= Radius)      { depth += (sphereCenter.y - (box.getPosition().y+box.Max.y)); MTV = Vec3f(0,1,0);}
        if (sphereCenter.z - (box.getPosition().z+box.Min.z) <=  Radius)      { depth += (sphereCenter.z - (box.getPosition().z+box.Min.z)); MTV = Vec3f(0,0, -1);}
        else if ((box.getPosition().z+box.Max.z) - sphereCenter.z <= Radius)      { depth += (sphereCenter.z - (box.getPosition().z+box.Max.z)); MTV = Vec3f(0,0,1);}

        if (depth <= Radius)
        {
        print("depth "+depth);
        UpdateAttributes(SColor(255,255,0,0));
            return ContainmentType::Intersects;
        }

        return ContainmentType::None;
    }


    ContainmentType Contains(BoundingFrustum frustum)
    {
        //check if all corners are in sphere
        bool inside = true;

        Vec3f[] corners = frustum.corners;

        for(int i = 0; i < corners.length(); i++)
        {
            Vec3f corner = corners[i];
            if (this.Contains(corner) == ContainmentType::None)
            {
                inside = false;
                break;
            }
        }
        if (inside)
            return ContainmentType::Contains;

        //check if the distance from sphere Position to frustrum face < radius
        float dmin = 0; //TODO : calculate dmin

        if (dmin <= Radius * Radius)
            return ContainmentType::Intersects;

        //else null
        return ContainmentType::None;
    }

    ContainmentType Contains(BoundingSphere@ sphere) override
    {
        float val = (sphere.getPosition()-getPosition()).length();

        if (val > sphere.Radius + Radius)
            return ContainmentType::None;

        else if (val <= Radius - sphere.Radius)
            return ContainmentType::Contains;

        else
            return ContainmentType::Intersects;
    }

    ContainmentType Contains(BoundingSphere@ sphere, Vec3f &out MTV, Vec3f[] &out contacts, f32 &out mtvDistance) override
    {
        float radiusDistance = this.Radius + sphere.Radius;
        Vec3f normDirection = (sphere.getPosition() - this.getPosition());
        float centerDistance = normDirection.length();
        normDirection /= centerDistance;

        float distance = centerDistance - radiusDistance;


        if (distance >= 0)
            return ContainmentType::None;

        else if (distance <= -radiusDistance)
        {
            return ContainmentType::Contains;
        }

        MTV = -normDirection;
        mtvDistance = distance;
        contacts.push_back(this.getPosition());
        UpdateAttributes(SColor(255,255,0,0));

        return ContainmentType::Intersects;
    }



    void Contains(BoundingSphere@ sphere, int &out result)
    {
        result = Contains(sphere);
    }

    ContainmentType Contains(Vec3f point)
    {
        float distance = (point-getPosition()).length();

        if (distance > this.Radius)
            return ContainmentType::None;

        else if (distance < this.Radius)
            return ContainmentType::Contains;

        return ContainmentType::Intersects;
    }

    void Contains(Vec3f point, ContainmentType &out result)
    {
        result = Contains(point);
    }    

    //int GetHashCode()
    //{
    //    return this.Position.GetHashCode() + this.Radius.GetHashCode();
    //}

    bool Intersects(OBB box)
    {
		return box.Intersects(this);
    }

    //bool Intersects(BoundingFrustum frustum)
    //{
    //    if (frustum is null)
    //        throw NullReferenceException();
    //    throw NotImplementedException();
    //}

    //bool Intersects(BoundingSphere sphere)
    //{
    //    float val = (sphere.Position-Position).Length();
	//	if (val > sphere.Radius + Radius)
	//		return false;
	//	return true;
    //}

    //bool Intersects(BoundingSphere sphere)
    //{
	//	return Intersects(sphere);
    //}

    PlaneIntersectionType Intersects(Plane plane)
    {
		float distance = plane.Normal.opMul(this.getPosition()) + plane.D;
		if (distance > this.Radius)
			return PlaneIntersectionType::Front;
		if (distance < -this.Radius)
			return PlaneIntersectionType::Back;
		//else it intersect
		return PlaneIntersectionType::Intersecting;
    }

    void Intersects(Plane plane, PlaneIntersectionType &out result)
    { result = Intersects(plane); }

    bool Intersects(Ray ray)
    { return ray.Intersects(this); }

    void Intersects(Ray ray, bool &out result)
    { result = this.Intersects(ray); }

    bool Equals(BoundingSphere other)
    { return this.getPosition() == other.getPosition() && this.Radius == other.Radius; }
    
    bool opEquals(BoundingSphere a, BoundingSphere b)
    { return a.Equals(b); }

    bool opNotEquals(BoundingSphere a, BoundingSphere b)
    { return !a.Equals(b); }

}

BoundingSphere CreateFromOBB(OBB@ box)
{
    // Find the Position of the box.
    Vec3f Position = Vec3f((box.Min.x + box.Max.x) / 2.0f,
                           (box.Min.y + box.Max.y) / 2.0f,
                           (box.Min.z + box.Max.z) / 2.0f);

    // Find the distance between the Position and one of the corners of the box.
    float radius = (Position-box.Max).length();
    return BoundingSphere(Position, radius);
}

//BoundingSphere CreateFromFrustum(BoundingFrustum@ frustum)
//{
//    return CreateFromPoints(frustum.GetCorners());
//}

BoundingSphere CreateMerged(BoundingSphere original, BoundingSphere additional)
{
    Vec3f oPositionToaPosition = (additional.getPosition() - original.getPosition());
    float distance = oPositionToaPosition.length();
    if (distance <= original.Radius + additional.Radius)//intersect
    {
        if (distance <= original.Radius - additional.Radius)//original contain additional
            return original;
        if (distance <= additional.Radius - original.Radius)//additional contain original
            return additional;
    }

    //else find Position of sphere and radius
    float leftRadius = Maths::Max(original.Radius - distance, additional.Radius);
    float Rightradius = Maths::Max(original.Radius + distance, additional.Radius);
    oPositionToaPosition += (oPositionToaPosition * (2 * distance)) / (leftRadius - Rightradius);//oPositionToResultPosition
    
    BoundingSphere result = BoundingSphere();
    result.parent.transform.getPosition() = original.getPosition() + oPositionToaPosition;
    result.Radius = (leftRadius + Rightradius) / 2;
    return result;
}
