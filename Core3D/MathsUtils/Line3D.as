
shared class Line3D
{
    Vec3f start;
    Vec3f end;

    Line3D() {}
    Line3D(float  xa, float  ya, float  za, float  xb, float  yb, float  zb) { start = Vec3f(xa, ya, za); end = Vec3f(xb, yb, zb);}
    Line3D(Vec3f &in _start, Vec3f &in _end) { start = _start; end = _end;}

    // operators
    Line3D opAdd(Vec3f &in point) { return Line3D (start + point, end + point); }
    Line3D opAddAssign(const Vec3f &in point) { start += point; end += point; return this; }

    Line3D opSub(const Vec3f &in point) { return Line3D (start - point, end - point); }
    Line3D opSubAssign(Vec3f &in point) { start -= point; end -= point; return this; }

    bool opEquals(Line3D & other)
    { return (start==other.start && end==other.end) || (end==other.start && start==other.end);}
    bool opNotEquals(Line3D & other)
    { return !(start==other.start && end==other.end) || (end==other.start && start==other.end);}

    // functions
    void setLine(float &in xa, float &in ya, float &in za, float &in xb, float &in yb, float &in zb)
    {start = Vec3f(xa, ya, za); end = Vec3f(xb, yb, zb);}

    void setLine(Vec3f &in nstart, Vec3f &in nend)
    {start = nstart; end = nend;}

    void setLine(Line3D &in line)
    {start = Vec3f(line.start); end = Vec3f(line.end);}

    float Length() { return (start-end).length(); } 
    float LengthSquared()  { return (start-end).lengthSquared(); }
    Vec3f getMiddle()   { return (start + end)/2.0; }
    Vec3f getVector()  { return end - start; }
    Vec3f getVectorNormalized()  { Vec3f vec = (end - start); vec.normalize(); return vec; } 

    bool isPointBetweenStartAndEnd(Vec3f &in point) { return isBetweenPoints(point, start, end); }

    bool isBetweenPoints(Vec3f &in point, Vec3f &in start, Vec3f &in end)
    {
        const float f = (end - start).lengthSquared();
        return (point-start).lengthSquared() <= f && (point-end).lengthSquared() <= f;
    } 

    Vec3f getClosestPoint(Vec3f &in point) 
    {
        Vec3f  c = point - start;
        Vec3f  v = end - start;
        float  d = v.length();
        v /= d;
        float  t = v.opMul(c);

        if (t < 0.0)
            return start;
        if (t > d)
            return end;

        v *= t;
        return start + v;
    }

    bool getIntersectionWithSphere(Vec3f sorigin, float sradius, f32 &out outdistance)
    {
        Vec3f  q = sorigin - start;
        float  c = q.length();
        Vec3f vec = getVector(); vec.normalize();
        float  v = q.opMul(vec);
        float  d = sradius * sradius - (c*c - v*v);

        if (d < 0.0)
            return false;

        outdistance = v - Maths::Sqrt( d );
        return true;
    }    
};

