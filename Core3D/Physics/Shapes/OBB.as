#include "TypeEnums.as"
#include "MathsHelper.as"
#include "Vec4f.as"
#include "Shapes3D.as"
#include "Line3D.as"

shared class OBB : BoundingShape
{    
    bool inside = false;
    Vec3f Min, Max;
    PhysicalEntity@ hitsphere;
    AABB bounding;

    OBB() {}

    void setPosition(Vec3f &in pos) override {if (parent !is null) parent.transform.setPosition(pos);}
    Vec3f getPosition() override {if (parent !is null) return parent.transform.getPosition(); return Vec3f();}

    void setDirection(Vec3f &in _axis) override {parent.transform.setRotation(_axis); }
    float getAngleDegrees() override {return parent.transform.getRotation().x;}
    Vec3f getDirection() override {return parent.transform.getRotation();}

    OBB(float size, Vec3f pos)
    {
        //super();
        this.Min = -Vec3f(size,size,size);
        this.Max = Vec3f(size,size,size);
        this.setPosition(pos);
        UpdateAttributes(SColor(150, XORRandom(255), XORRandom(255), XORRandom(255)));
    }

    OBB(float size, Vec3f pos, SColor col)
    {
        //super();
        this.Min = -Vec3f(size,size,size);
        this.Max = Vec3f(size,size,size);
        this.setPosition(pos);
        UpdateAttributes(col);
    }

    OBB(PhysicalEntity@ _parent, float size, Vec3f pos)
    {
        //super();
        @parent = _parent;
        this.Min = -Vec3f(size,size,size);
        this.Max = Vec3f(size,size,size);
        this.setPosition(pos);
        UpdateAttributes(SColor(150, XORRandom(255), XORRandom(255), XORRandom(255)));   

        bounding = AABB(getParent(), 1, getPosition()); 
    }

    OBB(Vec3f min, Vec3f max)
    {
        //super();
        this.Min = min;
        this.Max = max;
        UpdateAttributes(SColor(150, XORRandom(255), XORRandom(255), XORRandom(255)));
    }

    OBB(Vec3f min, Vec3f max, Vec3f pos)
    {
        //super();
        this.Min = min;
        this.Max = max;
        this.setPosition(pos);
        UpdateAttributes(SColor(150, XORRandom(255), XORRandom(255), XORRandom(255)));
        
        bounding = AABB(getParent(), 1, getPosition());
    }

    OBB(PhysicalEntity@ _parent, Vec3f min, Vec3f max, Vec3f pos)
    {
        //super();
        @parent = _parent;
        this.Min = min;
        this.Max = max;
        this.setPosition(pos);
        UpdateAttributes(SColor(150, XORRandom(255), XORRandom(255), XORRandom(255)));
        bounding = AABB(getParent(), 1, getPosition());
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

        const u16[] _IDs = {0,1,3,1,2,3,
                            4,7,5,7,6,5,
                            0,4,1,4,5,1,
                            1,5,2,5,6,2,
                            2,6,3,6,7,3,
                            4,0,7,0,3,7};

        @DebugMesh = Mesh(this.parent, _Verts, _IDs); 
        @DebugMesh.parent = @this.parent;       
        DebugMesh.setMatFlag(SMaterial::BACK_FACE_CULLING, false);
        DebugMesh.meshMaterial.SetFlag(SMaterial::WIREFRAME, true);
        DebugMesh.meshMaterial.Thickness = 1.0f;
        DebugMesh.MaterialSetDirty();

        @hitsphere = PhysicalEntity();
        @hitsphere.mesh = Mesh(hitsphere, "sphere.obj");
        //@hitsphere.parent = @this.parent; 
    }

    void Render() override
    { 
       DebugMesh.Render();

       if (hitsphere !is null)
        hitsphere.Render(); 

        //bounding.Render();
    }

    Vec3f getLocalInertiaTensor(float mass) const 
    {
        const float factor = (1.0 / 3.0) * mass;
        const float xSquare = Max.x * Max.x;
        const float ySquare = Max.y * Max.y;
        const float zSquare = Max.z * Max.z;
        return Vec3f(factor * (ySquare + zSquare), factor * (xSquare + zSquare), factor * (xSquare + ySquare));
    }

    ContainmentType Contains(AABB@ aabb, Vec3f &out MTV, Vec3f[] &out hitPos, f32 &out mtvDistance) override
    {
        bounding.CreateFromPoints(this.GetCorners());     
        return bounding.Contains(aabb, MTV, hitPos, mtvDistance);
    }

//   Vec3f ClosestPoint(OBB@ box2) 
//   {
//       Vec3f result = parent.transform.getPosition();
//       Vec3f dir = box2.parent.transform.getPosition() - parent.transform.getPosition();

//       //for (int i = 0; i < 3; ++i) 
//       {
//           Vec3f axis = parent.transform.rotation.Transformed(Vec3f(0, 1, 0));

//           float distance = Dot(dir, axis);

//           if (distance > obb.size.asArray[i]) {
//               distance = obb.size.asArray[i];
//           }
//           if (distance < -box2.Min) {
//               distance = -box2.Min;
//           }

//           result = result + (axis * distance);
//       }

//       return result;
//   }

    ContainmentType Contains(OBB@ box2, Vec3f &out MTV, Vec3f[] &out contacts, f32 &out mtvDistance) override
    {
        mtvDistance = 999999.999; //abartralily high number
        const Quaternion o1 = this.parent.transform.rotation;
        const Quaternion o2 = box2.parent.transform.rotation;
        Vec3f[] test; test.set_length(15);        
        test[0] = o1.GetRight();
        test[1] = o1.GetUp();
        test[2] = o1.GetForward();
        test[3] = o2.GetRight();
        test[4] = o2.GetUp();
        test[5] = o2.GetForward();

        for (int i = 0; i < 3; ++i)  // Fill out rest of axis
        {
            test[6 + i * 3 + 0] = Cross(test[i], test[0]);
            test[6 + i * 3 + 1] = Cross(test[i], test[1]);
            test[6 + i * 3 + 2] = Cross(test[i], test[2]);
        }

        bool intersect = false;

        for (int i = 0; i < 15; ++i) 
        {
            if (test[i].x < 0.000001f) test[i].x = 0.0f;
            if (test[i].y < 0.000001f) test[i].y = 0.0f;
            if (test[i].z < 0.000001f) test[i].z = 0.0f;
            if (test[i].lengthSquared() < 0.0001f) {
                continue;
            }
            bool shouldFlip;
            float depth = PenetrationDepth(box2, test[i], shouldFlip);
            
            if (depth <= 0.0f) { return ContainmentType::None; }
            else if (depth < mtvDistance) 
            {
                if (shouldFlip) test[i] *= -1.0f;
                mtvDistance = depth;
                MTV = test[i];
            }
        }
        Vec3f axis = MTV; axis.normalize();
        if (axis.lengthSquared() < 0.0001f) 
        {
            return ContainmentType::None;
        }

        contacts = ClipEdgesToOBB(box2.GetEdges()); 
        Vec3f[] c2 = box2.ClipEdgesToOBB(GetEdges());

        for (int i = 0; i < c2.size(); i++) contacts.push_back(c2[i]);

        Vec2f v = TestVertex(axis);
        float distance = (v.y - v.x) * 0.5f - mtvDistance * 0.5f;
        Vec3f pointOnPlane = this.parent.transform.getPosition() + axis * distance;

        for (int i = contacts.size() - 1; i >= 0; --i) 
        {
            Vec3f contact = contacts[i] + (axis * Dot(axis,pointOnPlane+contacts[i]));

            for (int j = contacts.size() - 1; j > i; --j) {
                if ((contacts[j] - contacts[i]).lengthSquared() < 0.00001f) {
                    contacts.removeAt(j);
                    break;
                }
            }
            contacts[i] = this.parent.transform.getPosition()+contact;
        }
        for (int i = 0; i >contacts.size(); ++i) 
        hitsphere.transform.setPosition(contacts[i]);

        return ContainmentType::Intersects;

    }

    float PenetrationDepth(const OBB@ obb2, Vec3f axis, bool &out ShouldFlip) 
    {  
        Vec3f v = axis; v.normalize();

        Vec2f i1 = this.TestVertex(v);
        Vec2f i2 = obb2.TestVertex(v);
        if (!((i2.x <= i1.y) && (i1.x <= i2.y))) 
        {
            return 0.0f; // No penerattion
        }

        float len1 = i1.y - i1.x;
        float len2 = i2.y - i2.x;
        float min = Maths::Min(i2.x, i1.x);
        float max = Maths::Max(i2.y, i1.y);
        float length = max - min;
        ShouldFlip = !(i2.x <= i1.x);
        return (len1 + len2) - length;
    }

    Vec2f TestVertex(Vec3f axis) const
    {
        Vec3f C = this.parent.transform.getPosition();
        Vec3f E = Max; // OBB Extents > HalfWidth


        Vec3f v1 = parent.transform.rotation.GetRight();
        Vec3f v2 = parent.transform.rotation.GetUp();
        Vec3f v3 = parent.transform.rotation.GetForward();


        Vec3f[] verts;  verts.set_length(8);
        verts[0] = C + v1 * E.x + v2 * E.y + v3 * E.z;
        verts[1] = C - v1 * E.x + v2 * E.y + v3 * E.z;
        verts[2] = C + v1 * E.x - v2 * E.y + v3 * E.z;
        verts[3] = C + v1 * E.x + v2 * E.y - v3 * E.z;
        verts[4] = C - v1 * E.x - v2 * E.y - v3 * E.z;
        verts[5] = C + v1 * E.x - v2 * E.y - v3 * E.z;
        verts[6] = C - v1 * E.x + v2 * E.y - v3 * E.z;
        verts[7] = C - v1 * E.x - v2 * E.y + v3 * E.z;

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

    Line3D[] GetEdges()
    {
        Line3D[] result;
        Vec3f[] v = GetCorners();

        int[][] index = { // Indices of edges
            { 6, 1 },{ 6, 3 },{ 6, 4 },{ 2, 7 },{ 2, 5 },{ 2, 0 },
            { 0, 1 },{ 0, 3 },{ 7, 1 },{ 7, 4 },{ 4, 5 },{ 5, 3 }
        };
        Vec3f C = this.parent.transform.getPosition();
        for (int j = 0; j < 12; ++j) 
        { result.push_back( Line3D(C+v[index[j][0]], C+v[index[j][1]])); }

        return result;
    }

    Plane[] GetPlanes() 
    {
        Vec3f c = this.parent.transform.getPosition();  // OBB Center
        Vec3f e = Max;  // OBB Extents
        Vec3f v1 = parent.transform.rotation.GetRight();
        Vec3f v2 = parent.transform.rotation.GetUp();
        Vec3f v3 = parent.transform.rotation.GetForward();        

        Plane[] result; result.set_length(6);
        result[0] = Plane(v1        ,  Dot(v1, (c + v1 * e.x)));
        result[1] = Plane(v1 * -1.0f, -Dot(v1, (c - v1 * e.x)));
        result[2] = Plane(v2        ,  Dot(v2, (c + v2 * e.y)));
        result[3] = Plane(v2 * -1.0f, -Dot(v2, (c - v2 * e.y)));
        result[4] = Plane(v3        ,  Dot(v3, (c + v3 * e.z)));
        result[5] = Plane(v3 * -1.0f, -Dot(v3, (c - v3 * e.z)));

        return result;
    }

    bool ClipToPlane(const Plane plane, Line3D line, Vec3f &out outPoint) 
    {
        Vec3f ab = line.end - line.start;

        float nA = Dot(plane.Normal, line.start);
        float nAB = Dot(plane.Normal, ab);

        //if (CMP(nAB, 0)) 
        if (nAB == 0)
        {
            return false;
        }

        float t = (plane.D - nA) / nAB;
        if (t >= 0.0f && t <= 1.0f) 
        {
            outPoint = line.start + ab * t;
            return true;
        }

        return false;
    }

    Vec3f[] ClipEdgesToOBB(const Line3D[] edges) 
    {
        Vec3f[] result;
        Vec3f intersection;
        Plane[] planes = GetPlanes();

        for (int i = 0; i < planes.size(); ++i)
            for (int j = 0; j < edges.size(); ++j)
                if (ClipToPlane(planes[i], edges[j], intersection))
                    if (PointInside(intersection))
                    {
                        result.push_back(intersection);
                    }

        return result;
    }

    bool PointInside(Vec3f point) 
    {
        Vec3f dir = this.parent.transform.getPosition() - point;
        {
            Vec3f axis = parent.transform.rotation.GetRight();
            float distance = Dot(dir, axis);
            if (distance > Max.x) {
                return false;
            }
            if (distance < Min.x) {
                return false;
            }
        }
        {
            Vec3f axis = parent.transform.rotation.GetUp();
            float distance = Dot(dir, axis);

            if (distance > Max.y) {
                return false;
            }
            if (distance < Min.y) {
                return false;
            }
        }
        {
            Vec3f axis = parent.transform.rotation.GetForward();
            float distance = Dot(dir, axis);

            if (distance > Max.z) {
                return false;
            }
            if (distance < Min.z) {
                return false;
            }
        }
        return true;
    }

    void satCheck(Vec3f axis, float proj1, float proj2, float projC12, float &out minDepth, int &out minDepthSign, Vec3f &out minDepthAxis) 
    {       
        float sum = proj1 + proj2;
        bool neg = projC12 < 0;
        float abs = neg ? -projC12 : projC12;
        if (abs < sum) 
        {
            float depth = sum - abs;
            if (depth < minDepth) 
            { // giving some bias to edge-edge separating axes
                minDepth = depth; //* biasMult;
                //minDepthId = id;
                minDepthAxis  = axis;
                minDepthSign = neg ? -1 : 1;
            }
        }
    }

    ContainmentType Contains(BoundingFrustum@ frustum)
    {
        //TODO: bad done here need a fix. 
        //Because question is not frustum contain box but the reverse, and this is not the same
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

        if (i == corners.size()) // we checked all the corners and they were all contained or instersect
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

    //void Contains(BoundingSphere sphere, ContainmentType &out result)
    //{
    //    result = this.Contains(sphere);
    //}

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

    OBB CreateFromSphere(BoundingSphere sphere)
    {
        Vec3f vector1 = Vec3f(sphere.Radius,sphere.Radius,sphere.Radius);
        return OBB(sphere.parent.transform.getPosition() - vector1, sphere.parent.transform.getPosition() + vector1);
    }

    OBB CreateMerged(OBB original, OBB additional)
    {
        return OBB( original.Min.min(additional.Min), original.Max.max(additional.Max));
    }

    bool Equals(OBB other)
    {
        return (this.Min == other.Min) && (this.Max == other.Max);
    }

    Vec3f[] GetCorners()
    {        
        Vec3f minR(this.Min); //minR = parent.transform.rotation.Transformed(this.Min), 
        Vec3f maxR(this.Max); //maxR = parent.transform.rotation.Transformed(this.Max),

         Vec3f[] boxcorners = {
            parent.transform.rotation.Transformed(Vec3f(minR.x, maxR.y, maxR.z)), 
            parent.transform.rotation.Transformed(Vec3f(maxR.x, maxR.y, maxR.z)),
            parent.transform.rotation.Transformed(Vec3f(maxR.x, minR.y, maxR.z)), 
            parent.transform.rotation.Transformed(Vec3f(minR.x, minR.y, maxR.z)), 
            parent.transform.rotation.Transformed(Vec3f(minR.x, maxR.y, minR.z)),
            parent.transform.rotation.Transformed(Vec3f(maxR.x, maxR.y, minR.z)),
            parent.transform.rotation.Transformed(Vec3f(maxR.x, minR.y, minR.z)),
            parent.transform.rotation.Transformed(Vec3f(minR.x, minR.y, minR.z))
        };

        return boxcorners;
    }

    //int GetHashCode()
    //{
    //    return this.Min.GetHashCode() + this.Max.GetHashCode();
    //}

    bool Intersects(OBB box)
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

    bool Intersects(Ray@ ray, float distance = 99999999)
    { return ray.Intersects(this); }

    //void Intersects(Ray ray, double &out result)
    //{ result = Intersects(ray); }

    bool opEquals(OBB a, OBB b)
    { return a.Equals(b); }

    bool opNotEquals(OBB a, OBB b)
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

OBB CreateMerged(OBB original, OBB additional)
{
    return CreateMerged(original, additional);
}