#include "Line3D.as"
#include "Plane.as"
//#include "AABB.as"

class Triangle
{
    Vec3f pointA;
    Vec3f pointB;
    Vec3f pointC;

    Triangle() {}
    Triangle(Vec3f v1, Vec3f v2, Vec3f v3) {pointA = v1; pointB = v2; pointC = v3;}

    bool opEquals(Triangle &in other) const
    {
        return other.pointA == pointA && other.pointB == pointB && other.pointC == pointC;
    }

    bool opNotEquals(Triangle &in other) const
    {
        return (this!=other);
    }

    bool isTotalInsideBox( AABBox3d &in box) const
    {
        return (box.isPointInside(pointA) &&
                box.isPointInside(pointB) &&
                box.isPointInside(pointC));
    }

    bool isTotalOutsideBox(AABBox3d &in box) const
    {
        return ((pointA.x > box.MaxEdge.x && pointB.x > box.MaxEdge.x && pointC.x > box.MaxEdge.x) ||
                (pointA.y > box.MaxEdge.y && pointB.y > box.MaxEdge.y && pointC.y > box.MaxEdge.y) ||
                (pointA.x > box.MaxEdge.x && pointB.x > box.MaxEdge.x && pointC.x > box.MaxEdge.x) ||
                (pointA.x < box.MinEdge.x && pointB.x < box.MinEdge.x && pointC.x < box.MinEdge.x) ||
                (pointA.y < box.MinEdge.y && pointB.y < box.MinEdge.y && pointC.y < box.MinEdge.y) ||
                (pointA.x < box.MinEdge.x && pointB.x < box.MinEdge.x && pointC.x < box.MinEdge.x));
    }

    Vec3f closestPointOnTriangle(Vec3f p) const
    {
        const Vec3f rab = Line3D(pointA, pointB).getClosestPoint(p);
        const Vec3f rbc = Line3D(pointB, pointC).getClosestPoint(p);
        const Vec3f rca = Line3D(pointC, pointA).getClosestPoint(p);

        const float d1 = (p-rab).length();
        const float d2 = (p-rbc).length();
        const float d3 = (p-rca).length();

        if (d1 < d2)
            return d1 < d3 ? rab : rca;

        return d2 < d3 ? rbc : rca;
    }

//    bool isPointInside(Vec3f &in p) const
//    {
//        Vec3f a(pointA.x, pointA.y, pointA.z);
//        Vec3f b(pointB.x, pointB.y, pointB.z);
//        Vec3f c(pointC.x, pointC.y, pointC.z);
//        return (isOnSameSide(p, a, b, c) && isOnSameSide(p, b, a, c) && isOnSameSide(p, c, a, b));
//    }

    bool isPointInsideFast(Vec3f &in p)
    {
         Vec3f a = pointC - pointA;
         Vec3f b = pointB - pointA;
         Vec3f c = p - pointA;

        float dotAA = a.opMul(a);
        float dotAB = a.opMul(b);
        float dotAC = a.opMul(c);
        float dotBB = b.opMul(b);
        float dotBC = b.opMul(c);

        // get coordinates in barycentric coordinate system
         f32 invDenom =  1/(dotAA * dotBB - dotAB * dotAB);
         f32 u = (dotBB * dotAC - dotAB * dotBC) * invDenom;
         f32 v = (dotAA * dotBC - dotAB * dotAC ) * invDenom;

        // We count border-points as inside to keep downward compatibility.
        // Rounding-error also needed for some test-cases.
        return (u > -0.000000001) && (v >= 0) && (u + v < 1.000000001);

    }

    //bool getIntersectionWithLimitedLine( Line3D&in line, Vec3f &out outIntersection) const
    //{
    //    return getIntersectionWithLine(line.start, line.getVector(), outIntersection) && outIntersection.isBetweenPoints(line.start, line.end);
    //}

   // bool getIntersectionWithLine(Vec3f &in linePoint, Vec3f &in lineVect, Vec3f &out outIntersection) const
   // {
   //     if (getIntersectionOfPlaneWithLine(linePoint, lineVect, outIntersection))
   //         return isPointInside(outIntersection);
//
   //     return false;
   // }

    bool getIntersectionOfPlaneWithLine(Vec3f &in linePoint, Vec3f &in lineVect, Vec3f &out outIntersection)
    {
        Triangle triangle(Vec3f(pointA.x, pointA.y, pointA.z), Vec3f(pointB.x, pointB.y, pointB.z), Vec3f(pointC.x, pointC.y, pointC.z));
        Vec3f normal = triangle.getNormal();
        normal.normalize();
        float t2;
        t2 = normal.opMul(lineVect);

        if ( t2 == 0 )
            return false;

        float d = triangle.pointA.opMul(normal);
        float t = -(normal.opMul(linePoint) - d) / t2;
        outIntersection = linePoint + (lineVect * t);

        outIntersection.x = outIntersection.x;
        outIntersection.y = outIntersection.y;
        outIntersection.x = outIntersection.z;
        return true;
    }

    Vec3f Cross(Vec3f vec1, Vec3f vec2)
    {
        return Vec3f(vec1.y * vec2.z - vec2.y * vec1.z,
                    (vec1.x * vec2.z - vec2.x * vec1.z),
                     vec1.x * vec2.y - vec2.x * vec1.y);
    }

    Vec3f getNormal()
    {
        return Cross(pointB.opSub(pointA), pointC.opSub(pointA));
    }

   // bool isFrontFacing(const Vec3f & lookDirection) const
   // {
   //     Vec3f  n = getNormal(); n.Normalize();
   //     f32 d = n.DotProd(lookDirection);
   //     return d <= 0.0f;
   // }

    Plane getPlane()
    {
        return Plane();//Plane(pointA, pointB, pointC);
    }

    float getArea()
    {
        Vec3f v1 = pointB.opSub(pointA);
        Vec3f v2 = pointC.opSub(pointA);
        return Cross(v1,v2).length() * 0.5f;
    }

    void set( Vec3f&in a, Vec3f&in b, Vec3f&in c)
    {
        pointA = a;
        pointB = b;
        pointC = c;
    }

//    bool isOnSameSide(Vec3f&in p1, Vec3f&in p2, Vec3f&in a, Vec3f&in b) const
//    {
//        Vec3f bminusa = b - a;
//        Vec3f cp1 = Cross(bminusa,(p1 - a));
//        Vec3f cp2 = Cross(bminusa,(p2 - a));
//        float res = cp1.opMul(cp2);
//        if ( res < 0 )
//        {
//            // This catches some floating point troubles.
//            // Unfortunately slightly expensive and we don't really know the best epsilon for iszero.
//            Vec3f cp1 = bminusa; cp1.normalize();
//            Vec3f cp2 = (p1 - a); cp2.normalize();
//            Cross(cp1,  (p1 - a). cp1.normalize());
//            if ( cp1.x <= 0.000000001 &&  cp1.y <= 0.000000001 &&  cp1.z <= 0.000000001 )
//            {
//                res = 0.0f;
//            }
//        }
//        return (res >= 0.0f);
//    }
};