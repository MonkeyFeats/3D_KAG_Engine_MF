#include "TypeEnums.as"
#include "MathsHelper.as"
#include "Vec4f.as"
#include "Shapes3D.as"

shared class AABB : BoundingShape
{    
    bool inside = false;
    Vec3f Min, Max;    

    AABB() {}

    void setPosition(Vec3f &in pos) override {if (parent !is null) parent.transform.setPosition(pos);}
    Vec3f getPosition() override {if (parent !is null) return parent.transform.getPosition(); return Vec3f();}

    AABB(float size)
    {
        //super();
        this.Min = -Vec3f(size,size,size);
        this.Max = Vec3f(size,size,size);
        UpdateAttributes(SColor(150, 0, 255, 0));
    }

    AABB(float size, Vec3f pos)
    {
        //super();
        this.Min = -Vec3f(size,size,size);
        this.Max = Vec3f(size,size,size);
        this.setPosition(pos);
        UpdateAttributes(SColor(150, 0, 255, 0));
    }

    AABB(float size, Vec3f pos, SColor col)
    {
        //super();
        this.Min = -Vec3f(size,size,size);
        this.Max = Vec3f(size,size,size);
        this.setPosition(pos);
        UpdateAttributes(col);
    }

    AABB(PhysicalEntity@ _parent, float size, Vec3f pos)
    {
        //super();
        this.Min = -Vec3f(size,size,size);
        this.Max = Vec3f(size,size,size);
        this.setPosition(pos);
        @parent = _parent;
        UpdateAttributes(SColor(150, 0, 255, 0));  
    }

    AABB(Vec3f min, Vec3f max)
    {
        //super();
        this.Min = min;
        this.Max = max;
        UpdateAttributes(SColor(150, 0, 255, 0));
    }

    AABB(Vec3f min, Vec3f max, Vec3f pos)
    {
        //super();
        this.Min = min;
        this.Max = max;
        this.setPosition(pos);
        UpdateAttributes(SColor(150, 0, 255, 0));
    }

    AABB(PhysicalEntity@ _parent, Vec3f min, Vec3f max, Vec3f pos)
    {
        //super();
        this.Min = min;
        this.Max = max;
        this.setPosition(pos);
        @parent = _parent;
        UpdateAttributes(SColor(150, 0, 255, 0));
    }

    void UpdateAttributes(SColor col) override
    {
        const Vertex[] _Verts = {
        Vertex( Max.x, Min.y, Min.z,  0, 0, col),
        Vertex( Max.x, Min.y, Max.z,  1, 0, col),
        Vertex( Min.x, Min.y, Max.z,  1, 1, col),
        Vertex( Min.x, Min.y, Min.z,  0, 1, col),
        Vertex( Max.x, Max.y, Min.z,  0, 1, col),
        Vertex( Max.x, Max.y, Max.z,  0, 0, col),
        Vertex( Min.x, Max.y, Max.z,  1, 0, col),
        Vertex( Min.x, Max.y, Min.z,  1, 1, col)
        };

        const u16[] _IDs = {0,1,3,1,2,3, 4,7,5,7,6,5, 0,4,1,4,5,1, 1,5,2,5,6,2, 2,6,3,6,7,3, 4,0,7,0,3,7};

        @DebugMesh = Mesh(this.parent, _Verts, _IDs); 
        @DebugMesh.parent = @this.parent;       
        DebugMesh.setMatFlag(SMaterial::BACK_FACE_CULLING, false);
        DebugMesh.meshMaterial.SetFlag(SMaterial::WIREFRAME, true);
        DebugMesh.meshMaterial.Thickness = 3.0f;
        DebugMesh.MaterialSetDirty();
    }

    void Render() override
    { 
       DebugMesh.Render(true, false);
    }

    bool isCollidingWith(AABB@ box)
    {
        Vec3f b1p = this.getPosition();
        Vec3f b2p = box.getPosition();

        Vec3f min(b1p+Min);
        Vec3f max(b1p+Max);
        Vec3f omin(b2p+box.Min);
        Vec3f omax(b2p+box.Max);

        if ( min.x > omax.x || max.x < omin.x || min.z > omax.z || max.z < omin.z || min.y > omax.y || max.y < omin.y  ) {return false;}

        return true;
    }

    Vec2f TestVertex(Vec3f axis)
    {
        Vec3f[] verts = 
        {
            Vec3f(Min.x, Max.y, Max.z),
            Vec3f(Min.x, Max.y, Min.z),
            Vec3f(Min.x, Min.y, Max.z),
            Vec3f(Min.x, Min.y, Min.z),
            Vec3f(Max.x, Max.y, Max.z),
            Vec3f(Max.x, Max.y, Min.z),
            Vec3f(Max.x, Min.y, Max.z),
            Vec3f(Max.x, Min.y, Min.z)
        };
        Vec2f result;
        result.x = result.y = Dot(axis, verts[0]);
        for (int i = 1; i < 8; ++i) 
        {
            float projection = Dot(axis, verts[i]);
            result.x = (projection < result.x) ? projection : result.x;
            result.y = (projection > result.y) ? projection : result.y;
        }               

        return result;
    }


    ContainmentType Contains(AABB@ box) override
    {
        Vec3f b1p = this.getPosition();
        Vec3f b2p = box.getPosition();

        Vec3f min =  (b1p+Min);
        Vec3f max =  (b1p+Max);
        Vec3f omin = (b2p+box.Min);
        Vec3f omax = (b2p+box.Max);

        if ( min.x > omax.x || max.x < omin.x ||
             min.z > omax.z || max.z < omin.z ||
             min.y > omax.y || max.y < omin.y  ) {return ContainmentType::None;}

        if (min.x <= omin.x && max.x >= omax.x &&
            min.y <= omin.y && max.y >= omax.y &&
            min.z <= omin.z && max.z >= omax.z) {return ContainmentType::Contains;}

        return ContainmentType::Intersects;
    }

    ContainmentType Contains(AABB@ box, Vec3f &out MTV, Vec3f[] &out hitPos, float &out mtvDistance) override
    {
        mtvDistance = 9999999.9f;
        Vec3f mtvAxis = Vec3f();
        Vec3f b1p = this.getPosition();
        Vec3f b2p = box.getPosition();

        Vec3f min =  (b1p+this.Min);
        Vec3f max =  (b1p+this.Max);
        Vec3f omin = (b2p+box.Min);
        Vec3f omax = (b2p+box.Max);

        if ( min.x > omax.x || max.x < omin.x ) {return ContainmentType::None;}
        if ( min.z > omax.z || max.z < omin.z ) {return ContainmentType::None;}
        if ( min.y > omax.y || max.y < omin.y ) {return ContainmentType::None;}

        if (min.x <= omin.x && max.x >= omax.x &&
            min.y <= omin.y && max.y >= omax.y &&
            min.z <= omin.z && max.z >= omax.z)
            {return ContainmentType::Contains;}

        // Seperating Axis Theorum, find the smallest overlapped axis normal and return it multiplied by the overlap
        //xAxis
        {
            Vec3f axis(1,0,0);
            f32 d0x = (omax.x - min.x);   // 'Left' side
            f32 d1x = (max.x - omin.x);   // 'Right' side
            f32 overlap = (d0x < d1x) ? d0x : -d1x; //signed
            Vec3f sep = (axis * overlap); //
            f32 sepLengthSquared = sep.length();   
         
            if (sepLengthSquared < mtvDistance)
            {
                mtvDistance = sepLengthSquared;
                mtvAxis = sep;
            }            
        }
        //yAxis
        {            
            Vec3f axis(0,1,0);
            f32 d0y = (omax.y - min.y);   // 'Left' side
            f32 d1y = (max.y - omin.y);   // 'Right' side
            f32 overlap = (d0y < d1y) ? d0y : -d1y;
            Vec3f sep = (axis * overlap);
            f32 sepLengthSquared = sep.length();            
            if (sepLengthSquared < mtvDistance)
            {
                mtvDistance = sepLengthSquared;
                mtvAxis = sep;
            }
        }
        //zAxis
        {
            Vec3f axis(0,0,1);
            f32 d0z = (omax.z - min.z);   // 'Left' side
            f32 d1z = (max.z - omin.z);   // 'Right' side            
            f32 overlap = (d0z < d1z) ? d0z : -d1z;
            Vec3f sep = (axis * overlap);
            f32 sepLengthSquared = sep.length();            
            if (sepLengthSquared < mtvDistance)
            {
                mtvDistance = sepLengthSquared;
                mtvAxis = sep;
            }
        }
        MTV = mtvAxis*mtvDistance;
        return ContainmentType::Intersects;
    }

    bool TestAxis(Vec3f axis, f32 minA, f32 maxA, f32 minB, f32 maxB, string axe, f32 mtvDistance_in, f32 &out mtvDistance_out, Vec3f &out mtvAxis)
    {
        mtvDistance_out = mtvDistance_in;
        f32 axisLengthSquared = axis.lengthSquared();

        f32 d0 = (maxB - minA);   // 'Left' side
        f32 d1 = (maxA - minB);   // 'Right' side

        if (d0 <= 0.0f || d1 <= 0.0f)
        {
            return false;
        }

        f32 overlap = (d0 < d1) ? d0 : -d1;
        Vec3f sep = (axis * (overlap / axisLengthSquared));
        f32 sepLengthSquared = sep.lengthSquared();
        
        if (sepLengthSquared < mtvDistance_in)
        {
            mtvDistance_out = sepLengthSquared;
            mtvAxis = sep;
        }

        print(axe+mtvDistance_out);

        return true;
    }

    ContainmentType Contains(BoundingFrustum@ frustum)
    {
        //TODO: bad done here need a fix. 
        //Because question is not frustum contain box but reverse and this is not the same
        int i;
        ContainmentType contained;
        Vec3f[] corners = frustum.corners;

        // First we check if frustum is in box
        for (i = 0; i < corners.size(); i++)
        {
            this.Contains(corners[i], contained);
            if (contained == ContainmentType::None)
                break;
        }

        if (i == corners.size()) // This means we checked all the corners and they were all contain or instersect
            return ContainmentType::Contains;

        if (i != 0)             // if i is not equal to zero, we can fastpath and say that this box intersects
            return ContainmentType::Intersects;


        // If we get here, it means the first (and only) point we checked was actually contained in the frustum.
        // So we assume that all other points will also be contained. If one of the points is null, we can
        // exit immediately saying that the result is Intersects
        i++;
        for (; i < corners.size(); i++)
        {
            this.Contains(corners[i], contained);
            if (contained != ContainmentType::Contains)
                return ContainmentType::Intersects;

        }

        // If we get here, then we know all the points were actually contained, therefore result is Contains
        return ContainmentType::Contains;
    }

    ContainmentType Contains(BoundingSphere sphere)
    {
        Vec3f sphereCenter = sphere.getPosition();
           if (sphereCenter.x - Min.x > sphere.Radius
            && sphereCenter.y - Min.y > sphere.Radius
            && sphereCenter.z - Min.z > sphere.Radius
            && Max.x - sphereCenter.x > sphere.Radius
            && Max.y - sphereCenter.y > sphere.Radius
            && Max.z - sphereCenter.z > sphere.Radius)
            return ContainmentType::Contains;

        double dMin = 0;

        if (sphereCenter.x - Min.x <= sphere.Radius)      dMin += (sphereCenter.x - Min.x) * (sphereCenter.x - Min.x);
        else if (Max.x - sphereCenter.x <= sphere.Radius) dMin += (sphereCenter.x - Max.x) * (sphereCenter.x - Max.x);
        if (sphereCenter.y - Min.y <= sphere.Radius)      dMin += (sphereCenter.y - Min.y) * (sphereCenter.y - Min.y);
        else if (Max.y - sphereCenter.y <= sphere.Radius) dMin += (sphereCenter.y - Max.y) * (sphereCenter.y - Max.y);
        if (sphereCenter.z - Min.z <= sphere.Radius)      dMin += (sphereCenter.z - Min.z) * (sphereCenter.z - Min.z);
        else if (Max.z - sphereCenter.z <= sphere.Radius) dMin += (sphereCenter.z - Max.z) * (sphereCenter.z - Max.z);

        if (dMin <= sphere.Radius * sphere.Radius)
            return ContainmentType::Intersects;

        return ContainmentType::None;
    }

    

  // void Contains(BoundingSphere sphere, ContainmentType &out result)
  // {
  //     result = this.Contains(sphere);
  // }

    ContainmentType Contains(Vec3f point)
    {
        ContainmentType result;
        this.Contains(point, result);
        return result;
    }

    void Contains(Vec3f point, ContainmentType &out result)
    {
        //first we get if point is of box
        if (point.x < this.Min.x || point.x > this.Max.x || point.y < this.Min.y || point.y > this.Max.y || point.z < this.Min.z || point.z > this.Max.z)
        {
            result = ContainmentType::None;
        }//or if point is on box because coordonate of point is lesser or equal
        else if (point.x == this.Min.x || point.x == this.Max.x || point.y == this.Min.y || point.y == this.Max.y || point.z == this.Min.z || point.z == this.Max.z)
            result = ContainmentType::Intersects;
        else
            result = ContainmentType::Contains;
    }


    void CreateFromPoints(Vec3f[] points)
    {
        Vec3f minVec(-4,-4,-4);
        Vec3f maxVec( 4, 4, 4);
        for( int i = 0; i < points.size(); i++)
        {
            minVec = points[i].min(minVec);
            maxVec = points[i].max(maxVec);
        }
        this.Min = minVec;
        this.Max = maxVec;
        UpdateAttributes(SColor(150, 255, 0, 0));
    }

    AABB CreateFromSphere(BoundingSphere sphere)
    {
        Vec3f vector1 = Vec3f(sphere.Radius,sphere.Radius,sphere.Radius);
        return AABB(sphere.parent.transform.getPosition() - vector1, sphere.parent.transform.getPosition() + vector1);
    }

    AABB CreateMerged(AABB original, AABB additional)
    {
        return AABB( original.Min.min(additional.Min), original.Max.max(additional.Max));
    }

    bool Equals(AABB other)
    {
        return (this.Min == other.Min) && (this.Max == other.Max);
    }

    Vec3f[] GetCorners()
    {
         Vec3f[] boxcorners = {
            Vec3f(this.Min.x, this.Max.y, this.Max.z), 
            Vec3f(this.Max.x, this.Max.y, this.Max.z),
            Vec3f(this.Max.x, this.Min.y, this.Max.z), 
            Vec3f(this.Min.x, this.Min.y, this.Max.z), 
            Vec3f(this.Min.x, this.Max.y, this.Min.z),
            Vec3f(this.Max.x, this.Max.y, this.Min.z),
            Vec3f(this.Max.x, this.Min.y, this.Min.z),
            Vec3f(this.Min.x, this.Min.y, this.Min.z)
        };
        return boxcorners;
    }

    //int GetHashCode()
    //{
    //    return this.Min.GetHashCode() + this.Max.GetHashCode();
    //}

    bool Intersects(AABB box)
    {
        return this.Intersects(box);
    }

    bool Intersects(BoundingFrustum frustum)
    {
        return frustum.Intersects(this);
    }

    PlaneIntersectionType Intersects(Plane plane)
    {
        return this.Intersects(plane);
    }

    //void Intersects(Ray ray, double &out result)
    //{ result = Intersects(ray); }

    bool opEquals(AABB a, AABB b)
    { return a.Equals(b); }

    bool opNotEquals(AABB a, AABB b)
    { return !a.Equals(b); }

    //string ToString()
    //{
    //    return string.Format("{{Min:{0} Max:{1}}}", this.Min.ToString(), this.Max.ToString());
    //}

    void  Intersects(Plane plane, PlaneIntersectionType &out result)
    {
        // See http://zach.in.tu-clausthal.de/teaching/cg_literatur/lighthouse3d_view_frustum_culling/index.html
        Vec3f positiveVertex;
        Vec3f negativeVertex;

        if (plane.Normal.x >= 0)
        {
            positiveVertex.x = Max.x;
            negativeVertex.x = Min.x;
        }
        else
        {
            positiveVertex.x = Min.x;
            negativeVertex.x = Max.x;
        }

        if (plane.Normal.y >= 0)
        {
            positiveVertex.y = Max.y;
            negativeVertex.y = Min.y;
        }
        else
        {
            positiveVertex.y = Min.y;
            negativeVertex.y = Max.y;
        }

        if (plane.Normal.z >= 0)
        {
            positiveVertex.z = Max.z;
            negativeVertex.z = Min.z;
        }
        else
        {
            positiveVertex.z = Min.z;
            negativeVertex.z = Max.z;
        }

        float distance = plane.Normal.opMul(negativeVertex) + plane.D;
        if (distance > 0)
        {
            result = PlaneIntersectionType::Front;
            return;
        }

        distance = plane.Normal.opMul(positiveVertex) + plane.D;
        if (distance < 0)
        {
            result = PlaneIntersectionType::Back;
            return;
        }
       
        result = PlaneIntersectionType::Intersecting;
    }

//    Vec3f calculateLocalInertia(float mass) const
//    {        
//        float lx = 2.0 * Max.x; //halfextent
//        float ly = 2.0 * Max.y;
//        float lz = 2.0 * Max.z;
//
//        return Vec3f(mass / 12.0 * (ly * ly + lz * lz),
//                     mass / 12.0 * (lx * lx + lz * lz),
//                     mass / 12.0 * (lx * lx + ly * ly));
//    }

}

AABB CreateMerged(AABB original, AABB additional)
{
    return CreateMerged(original, additional);
}