
namespace MathsHelper
{    
    const f64 E = 2.71828182845904523536028747135266249775724709369995957496696762772407663;
    const f64 Epsilon = 4.94065645841247E-324;
    const f64 MaxValue64 = 1.7976931348623157E+308;
    const f64 MinValue64 = -1.7976931348623157E+308;
    const f32 MaxValue32 = 3.40282347E+38;
    const f32 MinValue32 = -3.40282347E+38;
    const f32 Log10E = 0.4342945f;
    const f32 Log2E = 1.442695f;
    const f32 Pi = Maths::Pi;

    const f32 PiOver2 = (Pi / 2.0);
    const f32 PiOver4 = (Pi / 4.0);
    const f32 TwoPi = (Pi * 2.0);
    const f32 DEGTORAD = Pi / 180.0f;
    const f32 RADTODEG   = 180.0f / Pi;
    const f32 reciprocalSQR(const f32 x) {return 1.0 / Maths::Sqrt(x);}

    const f64 Pi64 = 3.1415926535897932384626433832795028841971693993751058209749445923;
    const f64 PiOver264 = (Pi64 / 2.0);
    const f64 PiOver464 = (Pi64 / 4.0);
    const f64 TwoPi64 = (Pi64 * 2.0);
    const f64 DEGTORAD64 = Pi64 / 180.0;
    const f64 RADTODEG64 = 180.0 / Pi64;

    shared int Sign(f32 value)
    {
       return value > 0 ? 1 : (value < 0 ? -1 : 0);  
    }

    shared f64 Barycentric(f64 value1, f64 value2, f64 value3, f64 amount1, f64 amount2)
    {
        return value1 + (value2 - value1) * amount1 + (value3 - value1) * amount2;
    }

    shared f64 CatmullRom(f64 value1, f64 value2, f64 value3, f64 value4, f64 amount)
    {
        // Using formula from http://www.mvps.org/directx/articles/catmull/
        // Internally using f64s not to lose precission
        f64 amountSquared = amount * amount;
        f64 amountCubed = amountSquared * amount;
        return (0.5 * (2.0 * value2 +
            (value3 - value1) * amount +
            (2.0 * value1 - 5.0 * value2 + 4.0 * value3 - value4) * amountSquared +
            (3.0 * value2 - value1 - 3.0 * value3 + value4) * amountCubed));
    }
    
    shared f64 Distance(f64 value1, f64 value2)
    {
        return Maths::Abs(value1 - value2);
    }
    
    shared f64 Hermite(f64 value1, f64 tangent1, f64 value2, f64 tangent2, f64 amount)
    {
        // All transformed to f64 not to lose precission
        // Otherwise, for high numbers of param:amount the result is NaN instead of Infinity
        f64 v1 = value1, v2 = value2, t1 = tangent1, t2 = tangent2, s = amount, result;
        f64 sCubed = s * s * s;
        f64 sSquared = s * s;

        if (amount == 0.0f) result = value1;
        else if (amount == 1.0f) result = value2;
        else
            result = (2 * v1 - 2 * v2 + t2 + t1) * sCubed +
                (3 * v2 - 3 * v1 - 2 * t1 - t2) * sSquared +
                t1 * s +
                v1;
        return result;
    }
    
    
    shared f64 Lerp(f64 value1, f64 value2, f64 amount)
    {
        return value1 + (value2 - value1) * amount;
    }

    shared f64 Max(f64 value1, f64 value2)
    {
        return Maths::Max(value1, value2);
    }
    
    shared f64 Min(f64 value1, f64 value2)
    {
        return Maths::Min(value1, value2);
    }
    
    shared f64 SmoothStep(f64 value1, f64 value2, f64 amount)
    {
        // It is expected that 0 < amount < 1
        // If amount < 0, return value1
        // If amount > 1, return value2
        f64 result = Maths::Clamp(amount, 0.0f, 1.0f);
        result = Hermite(value1, 0.0f, value2, 0.0f, result);
        return result;
    } 
 
    f32 radToDeg(f32 radians)
    {
        return RADTODEG * radians;
    } 
 
    f64 radToDeg(f64 radians)
    {
        return RADTODEG64 * radians;
    } 
 
    f32 degToRad(f32 degrees)
    {
        return DEGTORAD * degrees;
    } 
 
    f64 degToRad(f64 degrees)
    {
        return DEGTORAD64 * degrees;
    }

	shared f64 WrapAngle(f64 angle)
	{   //angle = Maths::IEEERemainder(angle, 6.2831854820251465);
		angle = angle % 6.2831854820251465;
		if (angle <= -3.14159274f)
		{
			angle += 6.28318548f;
		}
		else
		{
		if (angle > 3.14159274f)
		{
			angle -= 6.28318548f;
		}
		}
		return angle;
	}

	bool IsPowerOfTwo(int value)
	{
		return (value > 0) && ((value & (value - 1)) == 0);
	}
}

// extra Vec3f shit
shared Vec3f Cross(Vec3f vec1, Vec3f vec2)
{
    return Vec3f(vec1.y * vec2.z - vec2.y * vec1.z,
                (vec1.x * vec2.z - vec2.x * vec1.z),
                 vec1.x * vec2.y - vec2.x * vec1.y);
}

shared float Dot(Vec3f v1, Vec3f v2)
{
    return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
}

Vec3f rotateXYBy(Vec3f vec, float degrees, Vec3f center = Vec3f())
{
    float radians = degrees * Maths::Pi / 180.0f;
    float cs = Maths::Cos(radians);
    float sn = Maths::Sin(radians);
    vec.x -= center.x;
    vec.y -= center.z;
    vec = Vec3f((vec.x*cs - vec.y*sn), (vec.x*sn + vec.y*cs), vec.z);
    vec.x += center.x;
    vec.y += center.z;
    return vec;
}

Vec3f rotateYZBy(Vec3f vec, float degrees, Vec3f center = Vec3f())
{
    float radians = degrees * Maths::Pi / 180.0f;
    float cs = Maths::Cos(radians);
    float sn = Maths::Sin(radians);
    vec.z -= center.z;
    vec.y -= center.y;
    vec = Vec3f(vec.x, (vec.y*cs - vec.z*sn), (vec.y*sn + vec.z*cs));
    vec.z += center.z;
    vec.y += center.y;
    return vec;
}

Vec3f rotateXZBy(Vec3f vec, float degrees, Vec3f center=Vec3f())
{
    float radians = degrees * Maths::Pi / 180.0f;
    f64 cs = Maths::Cos(radians);
    f64 sn = Maths::Sin(radians);
    vec.x -= center.x;
    vec.z -= center.z;
    vec = Vec3f((vec.x*cs - vec.z*sn), vec.y, (vec.x*sn + vec.z*cs));
    vec.x += center.x;
    vec.z += center.z;
    return vec;
}

Vec3f Project(Vec3f vector, Vec3f onNormal)
{
    float sqrMag = Dot(onNormal, onNormal);
    if (sqrMag > 0.00001f)
    {
        float dot = Dot(vector, onNormal);
        return Vec3f(onNormal.x * dot / sqrMag,
            onNormal.y * dot / sqrMag,
            onNormal.z * dot / sqrMag);
    }
    return vector;
}

Vec3f ProjectOnPlane(Vec3f vector, Vec3f planeNormal)
{
    float sqrMag = Dot(planeNormal, planeNormal);
    if (sqrMag > 0.00001f)
    {
        float dot = Dot(vector, planeNormal);
        return Vec3f(vector.x - planeNormal.x * dot / sqrMag,
            vector.y - planeNormal.y * dot / sqrMag,
            vector.z - planeNormal.z * dot / sqrMag);
    }

    return vector;
}

