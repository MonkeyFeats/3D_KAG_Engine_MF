#include "MathsHelper.as"

shared class Vec4f
{
    double x,y,z,w;

    private Vec4f Vec4f_zero
    { get { return Vec4f(); } }

   private  Vec4f Vec4f_one
    { get { return Vec4f(1, 1, 1, 1); } }

    private Vec4f Vec4f_unitX
    { get { return Vec4f(1, 0, 0, 0); } }

    private Vec4f Vec4f_unitY
    { get { return Vec4f(0, 1, 0, 0); } }

    private Vec4f Vec4f_unitZ
    { get { return Vec4f(0, 0, 1, 0); } }

    private Vec4f Vec4f_unitW
    {  get { return Vec4f(0, 0, 0, 1); } }

    //Constructors

    Vec4f(double x, double y, double z, double w)
    {
        this.x = x;
        this.y = y;
        this.z = z;
        this.w = w;
    }

    Vec4f(Vec2f value, double z, double w)
    {
        this.x = value.x;
        this.y = value.y;
        this.z = z;
        this.w = w;
    }

    Vec4f(Vec3f value, double w)
    {
        this.x = value.x;
        this.y = value.y;
        this.z = value.z;
        this.w = w;
    }

    Vec4f(double value)
    {
        this.x = value;
        this.y = value;
        this.z = value;
        this.w = value;
    }

    Vec3f getXYZ()
    {
        return Vec3f(x,y,z);
    }

    Vec4f Barycentric(Vec4f other, Vec4f other2, double amount1, double amount2)
    {
        return Vec4f(
            MathsHelper::Barycentric(this.x, other.x, other2.x, amount1, amount2),
            MathsHelper::Barycentric(this.y, other.y, other2.y, amount1, amount2),
            MathsHelper::Barycentric(this.z, other.z, other2.z, amount1, amount2),
            MathsHelper::Barycentric(this.w, other.w, other2.w, amount1, amount2));
    }

    Vec4f CatmullRom(Vec4f value1, Vec4f other, Vec4f other2, Vec4f value4, double amount)
    {
        return Vec4f(
            MathsHelper::CatmullRom(this.x, other.x, other2.x, value4.x, amount),
            MathsHelper::CatmullRom(this.y, other.y, other2.y, value4.y, amount),
            MathsHelper::CatmullRom(this.z, other.z, other2.z, value4.z, amount),
            MathsHelper::CatmullRom(this.w, other.w, other2.w, value4.w, amount));
    }

    Vec4f Clamp(Vec4f value1, Vec4f min, Vec4f max)
    {
        return Vec4f(
            Maths::Clamp(this.x, min.x, max.x),
            Maths::Clamp(this.y, min.y, max.y),
            Maths::Clamp(this.z, min.z, max.z),
            Maths::Clamp(this.w, min.w, max.w));
    }

    double Length()
    {
        return double(Maths::Sqrt(this.LengthSquared()));
    }

    double LengthSquared()
    {
        return (this.w*this.w + this.x*this.x + this.y*this.y + this.z*this.z);
    }

    double LengthSquaredWith(Vec4f other)
    {
        return (this.w - other.w) * (this.w - other.w) +
               (this.x - other.x) * (this.x - other.x) +
               (this.y - other.y) * (this.y - other.y) +
               (this.z - other.z) * (this.z - other.z);
    }

    double Dot(Vec4f vector1, Vec4f vector2)
    {
        return vector1.x * vector2.x + vector1.y * vector2.y + vector1.z * vector2.z + vector1.w * vector2.w;
    }

    int GetHashCode()
    {
        return int(this.w + this.x + this.y + this.y);
    }

    Vec4f Lerp(Vec4f other, double amount)
    {
        return Vec4f(
            Maths::Lerp(this.x, other.x, amount),
            Maths::Lerp(this.y, other.y, amount),
            Maths::Lerp(this.z, other.z, amount),
            Maths::Lerp(this.w, other.w, amount));
    }

    Vec4f Max(Vec4f other)
    {
        return Vec4f(
           Maths::Max(this.x, other.x),
           Maths::Max(this.y, other.y),
           Maths::Max(this.z, other.z),
           Maths::Max(this.w, other.w));
    }

    Vec4f Min(Vec4f other)
    {
        return Vec4f(
           Maths::Min(this.x, other.x),
           Maths::Min(this.y, other.y),
           Maths::Min(this.z, other.z),
           Maths::Min(this.w, other.w));
    }

    Vec4f Normalize()
    {
        double factor = this.LengthSquared();
        factor = 1.0f / Maths::Sqrt(factor);
        this.w = this.w * factor;
        this.x = this.x * factor;
        this.y = this.y * factor;
        this.z = this.z * factor;
        return this;
    }

    Vec4f SmoothStep(Vec4f value1, Vec4f other, double amount)
    {
        return Vec4f(
            MathsHelper::SmoothStep(value1.x, other.x, amount),
            MathsHelper::SmoothStep(value1.y, other.y, amount),
            MathsHelper::SmoothStep(value1.z, other.z, amount),
            MathsHelper::SmoothStep(value1.w, other.w, amount));
    }

    Vec4f Transform(Vec2f position, Matrix4 matrix)
    {
        return Vec4f((position.x * matrix[0]) + (position.y * matrix[4]) + matrix[12],
                     (position.x * matrix[1]) + (position.y * matrix[5]) + matrix[13],
                     (position.x * matrix[2]) + (position.y * matrix[6]) + matrix[14],
                     (position.x * matrix[3]) + (position.y * matrix[7]) + matrix[15]);
    }

    Vec4f Transform(Vec3f position, Matrix4 matrix)
    {
        return Vec4f((position.x * matrix[0]) + (position.y * matrix[4]) + (position.z * matrix[8]) + matrix[12],
                     (position.x * matrix[1]) + (position.y * matrix[5]) + (position.z * matrix[9]) + matrix[13],
                     (position.x * matrix[2]) + (position.y * matrix[6]) + (position.z * matrix[10]) + matrix[14],
                     (position.x * matrix[3]) + (position.y * matrix[7]) + (position.z * matrix[11]) + matrix[15]);
    }

    Vec4f Transform(Vec4f vector, Matrix4 matrix)
    {
        return Vec4f((vector.x * matrix[0]) + (vector.y * matrix[4]) + (vector.z * matrix[8]) + (vector.w * matrix[12]),
                     (vector.x * matrix[1]) + (vector.y * matrix[5]) + (vector.z * matrix[9]) + (vector.w * matrix[13]),
                     (vector.x * matrix[2]) + (vector.y * matrix[6]) + (vector.z * matrix[10]) + (vector.w * matrix[14]),
                     (vector.x * matrix[3]) + (vector.y * matrix[7]) + (vector.z * matrix[11]) + (vector.w * matrix[15]));
    }

    string ToString()
    {
        return ("{X:"+this.x+", Y:"+this.y+", Z:"+this.z+", W:"+this.w+"}");
    }

    //Operators    
   
    void opAssign (Vec4f &in other) {this.w = other.w; this.x = other.x; this.y = other.y; this.z = other.z; }   

    Vec4f opAdd(Vec4f &in other)
    { return Vec4f (this.w + other.w, this.x + other.x, this.y + other.y, this.z + other.z); }

    Vec4f opAdd(double &in other)
    { return Vec4f (this.w + other, this.x + other, this.y + other, this.z + other); }

    void opAddAssign(Vec4f other)
    { this.w += other.w; this.x += other.x; this.y += other.y; this.z += other.z; }

    void opAddAssign(double other)
    { this.w += other; this.x += other; this.y += other; this.z += other; }

    Vec4f opSub(Vec4f &in other)
    { return Vec4f (this.w - other.w, this.x - other.x, this.y - other.y, this.z - other.z); }

    Vec4f opSub(double &in other)
    { return Vec4f (this.w - other, this.x - other, this.y - other, this.z - other); }

    void opSubAssign(Vec4f other)
    { this.w += other.w; this.x -= other.x; this.y -= other.y; this.z -= other.z; }

    void opSubAssign(double other)
    { this.w += other; this.x -= other; this.y -= other; this.z -= other; }

    Vec4f opMul(Vec4f &in other)
    { return Vec4f (this.w * other.w, this.x * other.x, this.y * other.y, this.z * other.z); }

    Vec4f opMul(double &in other)
    { return Vec4f (this.w * other, this.x * other, this.y * other, this.z * other); }

    void opMulAssign(Vec4f other)
    { this.w *= other.w; this.x *= other.x; this.y *= other.y; this.z *= other.z; }

    void opMulAssign(double other)
    { this.w *= other; this.x *= other; this.y *= other; this.z *= other; }

    Vec4f opDiv(Vec4f &in other)
    { return Vec4f (this.w / other.w, this.x / other.x, this.y / other.y, this.z / other.z); }

    Vec4f opDiv(double &in other)
    { return Vec4f (this.w / other, this.x / other, this.y / other, this.z / other); }

    void opDivAssign(Vec4f other)
    { this.w /= other.w; this.x /= other.x; this.y /= other.y; this.z /= other.z; }

    void opDivAssign(double other)
    { this.w /= other; this.x /= other; this.y /= other; this.z /= other; }

    Vec4f opNeg()
    {
        return Vec4f(-this.x, -this.y, -this.z, -this.w);
    }  

    bool opEquals(Vec4f other)
    {
        return this.w == other.w
            && this.x == other.x
            && this.y == other.y
            && this.z == other.z;
    }

    bool opNotEquals(Vec4f value1, Vec4f other)
    {
        return (this != other);
    }
}

Vec4f Clamp(Vec4f value1, Vec4f min, Vec4f max)
{
    return Vec4f(
        Maths::Clamp(value1.x, min.x, max.x),
        Maths::Clamp(value1.y, min.y, max.y),
        Maths::Clamp(value1.z, min.z, max.z),
        Maths::Clamp(value1.w, min.w, max.w));
}

double Distance(Vec4f value1, Vec4f other)
{
    return Maths::Sqrt(LengthSquared(value1, other));
}

double LengthSquared(Vec4f value1, Vec4f other)
{
    return  (value1.w - other.w) * (value1.w - other.w) +
             (value1.x - other.x) * (value1.x - other.x) +
             (value1.y - other.y) * (value1.y - other.y) +
             (value1.z - other.z) * (value1.z - other.z);
}

double Dot(Vec4f vector1, Vec4f vector2)
{
    return vector1.x * vector2.x + vector1.y * vector2.y + vector1.z * vector2.z + vector1.w * vector2.w;
}

Vec4f Hermite(Vec4f value1, Vec4f tangent1, Vec4f other, Vec4f tangent2, double amount)
{
    return Vec4f(
     MathsHelper::Hermite(value1.w, tangent1.w, other.w, tangent2.w, amount),
     MathsHelper::Hermite(value1.x, tangent1.x, other.x, tangent2.x, amount),
     MathsHelper::Hermite(value1.y, tangent1.y, other.y, tangent2.y, amount),
     MathsHelper::Hermite(value1.z, tangent1.z, other.z, tangent2.z, amount));
}

Vec4f Barycentric(Vec4f value1, Vec4f other, Vec4f other2, double amount1, double amount2)
{
    return Vec4f(
        MathsHelper::Barycentric(value1.x, other.x, other2.x, amount1, amount2),
        MathsHelper::Barycentric(value1.y, other.y, other2.y, amount1, amount2),
        MathsHelper::Barycentric(value1.z, other.z, other2.z, amount1, amount2),
        MathsHelper::Barycentric(value1.w, other.w, other2.w, amount1, amount2));
}

Vec4f CatmullRom(Vec4f value1, Vec4f other, Vec4f other2, Vec4f value4, double amount)
{
    return Vec4f(
        MathsHelper::CatmullRom(value1.x, other.x, other2.x, value4.x, amount),
        MathsHelper::CatmullRom(value1.y, other.y, other2.y, value4.y, amount),
        MathsHelper::CatmullRom(value1.z, other.z, other2.z, value4.z, amount),
        MathsHelper::CatmullRom(value1.w, other.w, other2.w, value4.w, amount));
}