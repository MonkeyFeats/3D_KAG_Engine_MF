#include "Quaternion.as"
//

//Quaternion identityQuat {return Quaternion(0, 0, 0, 1);}

shared class Quaternion
{
    //////members//////
    float x,y,z,w;

    /////constructors/////
    Quaternion() { this.x = 0; this.y = 0; this.z = 0; this.w = 1; }
    Quaternion(float _x, float _y, float _z, float _w) { this.x = _x; this.y = _y; this.z = _z; this.w = _w; }
    Quaternion(Vec3f _vectorPart, float _scalarPart) { this.x = _vectorPart.x; this.y = _vectorPart.y; this.z = _vectorPart.z; this.w = _scalarPart; } 

    Vec3f GetForward() const { return   Transformed(Vec3f( 0, 0, 1)); }
    Vec3f GetBack() const { return      Transformed(Vec3f( 0, 0,-1)); }
    Vec3f GetUp() const { return        Transformed(Vec3f( 0, 1, 0)); }
    Vec3f GetDown() const { return      Transformed(Vec3f( 0,-1, 0)); }
    Vec3f GetRight() const { return     Transformed(Vec3f( 1, 0, 0)); }
    Vec3f GetLeft() const { return      Transformed(Vec3f(-1, 0, 0)); }
    Vec3f getXYZ() { return Vec3f(x,y,z); }

    Vec3f Rotate(Vec3f axis, Quaternion rotation) // may not be correct, this func supposed to be a Vec3f.Rotate(Quaternion)
    {
        Quaternion conjugated = Quaternion(axis, 1);
        conjugated.Conjugate(rotation);
        Quaternion q = rotation * conjugated;
        Vec3f ret(q.x, q.y, q.z);
        return ret;
    }

    Vec3f getEuler()
    {        
        float sqx = x*x;
        float sqy = y*y;
        float sqz = z*z;
        float sqw = w*w;
        float unit = sqx + sqy + sqz + sqw;
        float test = (x*y) + (z*w);

        Vec3f euler;
        euler.z += Maths::ATan2((2*y*w) - (2*x*z), sqx - sqy - sqz + sqw);
        euler.y += Maths::ASin((2*test)/unit);
        euler.x += Maths::ATan2((2*x*w )- (2*y*z), -sqx + sqy - sqz + sqw);
        return euler;
    }

    void Rotate(Quaternion rotation)
    {
        Quaternion conjugated = Conjugated(this);
        Quaternion q = rotation * this * conjugated;
        this = q;
    }

    // Makes euler angles positive 0/360 with 0.0001 hacked to support old behaviour of QuaternionToEuler
    Vec3f MakePositive(Vec3f euler)
    {
        float negativeFlip = -0.0001f * (180.0f / Maths::Pi);
        float positiveFlip = 360.0f + negativeFlip;

        if (euler.x < negativeFlip)
            euler.x += 360.0f;
        else if (euler.x > positiveFlip)
            euler.x -= 360.0f;

        if (euler.y < negativeFlip)
            euler.y += 360.0f;
        else if (euler.y > positiveFlip)
            euler.y -= 360.0f;

        if (euler.z < negativeFlip)
            euler.z += 360.0f;
        else if (euler.z > positiveFlip)
            euler.z -= 360.0f;

        return euler;
    }


    Vec3f Transformed(Vec3f v)
    {
        Vec3f result;
        this.Normalize();
        float x2 = this.x + this.x;
        float y2 = this.y + this.y;
        float z2 = this.z + this.z;
        float xx2 = this.x * x2;
        float xy2 = this.x * y2;
        float xz2 = this.x * z2;
        float yy2 = this.y * y2;
        float yz2 = this.y * z2;
        float zz2 = this.z * z2;
        float wx2 = this.w * x2;
        float wy2 = this.w * y2;
        float wz2 = this.w * z2;
        //Defer the component setting since they're used in computation.
        result.x = ((v.x * ((1.0f - yy2) - zz2)) + (v.y * (xy2 - wz2))) + (v.z * (xz2 + wy2));
        result.y = ((v.x * (xy2 + wz2)) + (v.y * ((1.0f - xx2 )- zz2))) + (v.z * (yz2 - wx2));
        result.z = ((v.x * (xz2 - wy2)) + (v.y * (yz2 + wx2))) + (v.z * ((1.0f - xx2) - yy2));
        //result.normalize();
        //result *= Vec3f(Maths::Abs(v.x),Maths::Abs(v.y),Maths::Abs(v.z))*0.25;

        return  result;  
    } 

    Vec3f TransformX(float inx)
    {
        Vec3f result;
        float y2 = this.y + this.y;
        float z2 = this.z + this.z;
        float xy2 = this.x * y2;
        float xz2 = this.x * z2;
        float yy2 = this.y * y2;
        float zz2 = this.z * z2;
        float wy2 = this.w * y2;
        float wz2 = this.w * z2;
        float transformedX = inx * ((1.0f - yy2) - zz2);
        float transformedY = inx * (xy2 + wz2);
        float transformedZ = inx * (xz2 - wy2);
        result.x = transformedX;
        result.y = transformedY;
        result.z = transformedZ;
        return result;
    }

    Vec3f TransformY(float iny)
    {
        Vec3f result;
        float x2 = this.x + this.x;
        float y2 = this.y + this.y;
        float z2 = this.z + this.z;
        float xx2 = this.x * x2;
        float xy2 = this.x * y2;
        float yz2 = this.y * z2;
        float zz2 = this.z * z2;
        float wx2 = this.w * x2;
        float wz2 = this.w * z2;
        //Defer the component setting since they're used in computation.
        float transformedX = iny * (xy2 - wz2);
        float transformedY = iny * (1.0f - xx2 - zz2);
        float transformedZ = iny * (yz2 + wx2);
        result.x = transformedX;
        result.y = transformedY;
        result.z = transformedZ;
        return result;
    }

    /// Transforms a vector using a quaternion. Specialized for 0,0,z vectors.
    Vec3f TransformZ(float inz)
    {
        Vec3f result;
        float x2 = this.x + this.x;
        float y2 = this.y + this.y;
        float z2 = this.z + this.z;
        float xx2 = this.x * x2;
        float xz2 = this.x * z2;
        float yy2 = this.y * y2;
        float yz2 = this.y * z2;
        float wx2 = this.w * x2;
        float wy2 = this.w * y2;
        //Defer the component setting since they're used in computation.
        float transformedX = inz * (xz2 + wy2);
        float transformedY = inz * (yz2 - wx2);
        float transformedZ = inz * (1.0f - xx2 - yy2);
        result.x = transformedX;
        result.y = transformedY;
        result.z = transformedZ;
        return result;
    }

    // Multiplies two quaternions together in opposite order.
    Quaternion Concatenated(Quaternion value2)
    {
        Quaternion q = this;
        float x = value2.x;
        float y = value2.y;
        float z = value2.z;
        float w = value2.w;
        float num4 = q.x;
        float num3 = q.y;
        float num2 = q.z;
        float num = q.w;
        float num12 = (y * num2) - (z * num3);
        float num11 = (z * num4) - (x * num2);
        float num10 = (x * num3) - (y * num4);
        float num9 = ((x * num4) + (y * num3)) + (z * num2);
        q.x = ((x * num) + (num4 * w)) + num12;
        q.y = ((y * num) + (num3 * w)) + num11;
        q.z = ((z * num) + (num2 * w)) + num10;
        q.w = (w * num) - num9;
        return q;

    }
    void Concatenate(Quaternion value2)
    {
        float x = value2.x;
        float y = value2.y;
        float z = value2.z;
        float w = value2.w;
        float num4 = this.x;
        float num3 = this.y;
        float num2 = this.z;
        float num = this.w;
        float num12 = (y * num2) - (z * num3);
        float num11 = (z * num4) - (x * num2);
        float num10 = (x * num3) - (y * num4);
        float num9 = ((x * num4) + (y * num3)) + (z * num2);
        this.x = ((x * num) + (num4 * w)) + num12;
        this.y = ((y * num) + (num3 * w)) + num11;
        this.z = ((z * num) + (num2 * w)) + num10;
        this.w = (w * num) - num9;
    }

    Quaternion Conjugated(Quaternion value)
    {
        Quaternion quaternion( -value.x, -value.y, -value.z, value.w);
        return quaternion;
    }

    void Conjugate(Quaternion other)
    {
        Quaternion quaternion( -other.x, -other.y, -other.z, other.w);
        this = quaternion;
    }

    void Conjugate()
    {
        this.x = -this.x;
        this.y = -this.y;
        this.z = -this.z;
    }
    
    void CreateFromAxisAngle(Vec3f axis, float angle)
    {
        Quaternion result;
        float halfAngle = angle * .5f;
        float s = float(Maths::Sin(halfAngle));
        result.x = axis.x * s;
        result.y = axis.y * s;
        result.z = axis.z * s;
        result.w = float(Maths::Cos(halfAngle));
        this = result;
    }

    Quaternion CreateFromRotationMatrix(Matrix4 matrix)
    {
        Quaternion result;
        float num8 = (matrix[0] + matrix[5]) + matrix[10];
        if (num8 > 0.0f)
        {
            float num = Maths::Sqrt((num8 + 1.0f));
            result.w = num * 0.5f;
            num = 0.5f / num;
            result.x = (matrix[6] - matrix[9]) * num;
            result.y = (matrix[8] - matrix[2]) * num;
            result.z = (matrix[1] - matrix[4]) * num;
        }
        else if ((matrix[0] >= matrix[5]) && (matrix[0] >= matrix[10]))
        {
            float num7 = Maths::Sqrt((((1.0f + matrix[0]) - matrix[5]) - matrix[10]));
            float num4 = 0.5f / num7;
            result.x = 0.5f * num7;
            result.y = (matrix[1] + matrix[4]) * num4;
            result.z = (matrix[2] + matrix[8]) * num4;
            result.w = (matrix[6] - matrix[9]) * num4;
        }
        else if (matrix[5] > matrix[10])
        {
            float num6 = Maths::Sqrt((((1.0f + matrix[5]) - matrix[0]) - matrix[10]));
            float num3 = 0.5f / num6;
            result.x = (matrix[4] + matrix[1]) * num3;
            result.y = 0.5f * num6;
            result.z = (matrix[9] + matrix[6]) * num3;
            result.w = (matrix[8] - matrix[2]) * num3;
        }
        else
        {
            float num5 = Maths::Sqrt((((1.0f + matrix[10]) - matrix[0]) - matrix[5]));
            float num2 = 0.5f / num5;
            result.x = (matrix[8] + matrix[2]) * num2;
            result.y = (matrix[9] + matrix[6]) * num2;
            result.z = 0.5f * num5;
            result.w = (matrix[1] - matrix[4]) * num2;
        }

        return result;
    }
    void addQuaternion(float _x, float _y, float _z, float _w)
    {
        this.x += _x;
        this.y += _y;
        this.z += _z;
        this.w += _w;
    }
    void addQuaternion(Quaternion Q)
    {
        this.x += Q.x;
        this.y += Q.y;
        this.z += Q.z;
        this.w += Q.w;
    }

//    Quaternion ToQuaternion(float yaw, float pitch, float roll) // yaw (Z), pitch (Y), roll (X)
//    {
//        // Abbreviations for the various angular functions
//        float cy = cos(yaw * 0.5);
//        float sy = sin(yaw * 0.5);
//        float cp = cos(pitch * 0.5);
//        float sp = sin(pitch * 0.5);
//        float cr = cos(roll * 0.5);
//        float sr = sin(roll * 0.5);
//
//        Quaternion q;
//        q.w = cr * cp * cy + sr * sp * sy;
//        q.x = sr * cp * cy - cr * sp * sy;
//        q.y = cr * sp * cy + sr * cp * sy;
//        q.z = cr * cp * sy - sr * sp * cy;
//
//        return q;
//    }

    float getYaw() { return Maths::ATan2(2.0*(y*z + w*x), w*w - x*x - y*y + z*z); }
    float getPitch() { return Maths::Sin(-2.0*(x*z - w*y)); }
    float getRoll() { return Maths::ATan2(2.0*(x*y + w*z), w*w + x*x - y*y - z*z); }    
    
    Vec3f getYawPitchRoll()
    {
        float yaw = Maths::ATan2(2.0*(y*z + w*x), w*w - x*x - y*y + z*z);
        float pitch = Maths::Sin(-2.0*(x*z - w*y));
        float roll = Maths::ATan2(2.0*(x*y + w*z), w*w + x*x - y*y - z*z);

        return Vec3f(yaw,pitch,roll);
    }

    void CreateFromYawPitchRoll(float yaw, float pitch, float roll) // yaw (Z), pitch (Y), roll (X)
    {
        yaw *= (Maths::Pi / 180.0f);
        pitch *= (Maths::Pi / 180.0f);
        roll *= (Maths::Pi / 180.0f);

        float cy = Maths::Cos(yaw * 0.5);
        float sy = Maths::Sin(yaw * 0.5);
        float cp = Maths::Cos(pitch* 0.5);
        float sp = Maths::Sin(pitch * 0.5);
        float cr = Maths::Cos(roll* 0.5);
        float sr = Maths::Sin(roll * 0.5);

        Quaternion q;
        q.w = cr * cp * cy + sr * sp * sy;
        q.x = sr * cp * cy - cr * sp * sy;
        q.y = cr * sp * cy + sr * cp * sy;
        q.z = cr * cp * sy - sr * sp * cy;
        this = q;
    }

    Vec3f ToEulerAngles() 
    {
        // Convert quaternion to Euler angles
        Vec3f angles;    
        float ysqr = y * y;
        
        // Roll (x-axis rotation)
        float t0 = 2.0f * (w * x + y * z);
        float t1 = 1.0f - 2.0f * (x * x + ysqr);
        angles.x = Maths::ATan2(t0, t1);
        
        // Pitch (y-axis rotation)
        float t2 = 2.0f * (w * y - z * x);
        t2 = t2 > 1.0f ? 1.0f : t2;
        t2 = t2 < -1.0f ? -1.0f : t2;
        angles.y = Maths::ASin(t2);
        
        // Yaw (z-axis rotation)
        float t3 = 2.0f * (w * z + x * y);
        float t4 = 1.0f - 2.0f * (ysqr + z * z);
        angles.z = Maths::ATan2(t3, t4);
        
        return angles;
    }

    void AddYawPitchRoll(float yaw, float pitch, float roll)
    {
        float halfRoll = roll * 0.5;
        float halfPitch = pitch * 0.5;
        float halfYaw = yaw * 0.5;

        float sinRoll = Maths::Sin(halfRoll);
        float sinPitch = Maths::Sin(halfPitch);
        float sinYaw = Maths::Sin(halfYaw);

        float cosRoll = Maths::Cos(halfRoll);
        float cosPitch = Maths::Cos(halfPitch);
        float cosYaw = Maths::Cos(halfYaw);

        float cosYawCosPitch = cosYaw * cosPitch;
        float cosYawSinPitch = cosYaw * sinPitch;
        float sinYawCosPitch = sinYaw * cosPitch;
        float sinYawSinPitch = sinYaw * sinPitch;

        this.x += float(cosYawSinPitch * cosRoll + sinYawCosPitch * sinRoll);
        this.y += float(sinYawCosPitch * cosRoll - cosYawSinPitch * sinRoll);
        this.z += float(cosYawCosPitch * sinRoll - sinYawSinPitch * cosRoll);
        this.w += float(cosYawCosPitch * cosRoll + sinYawSinPitch * sinRoll);
    }

    void CreateFromEulerAngles(Vec3f _vec) {CreateFromEulerAngles(_vec.x, _vec.y, _vec.z);}
    void CreateFromEulerAngles(float angleX, float angleY, float angleZ) 
    {
        float angle = angleX * 0.5f;
        const float sinX = Maths::Sin(angle);
        const float cosX = Maths::Cos(angle);

        angle = angleY * 0.5f;
        const float sinY = Maths::Sin(angle);
        const float cosY = Maths::Cos(angle);

        angle = angleZ * 0.5f;
        const float sinZ = Maths::Sin(angle);
        const float cosZ = Maths::Cos(angle);

        const float cosYcosZ = cosY * cosZ;
        const float sinYcosZ = sinY * cosZ;
        const float cosYsinZ = cosY * sinZ;
        const float sinYsinZ = sinY * sinZ;

        this.x = sinX * cosYcosZ - cosX * sinYsinZ;
        this.y = cosX * sinYcosZ + sinX * cosYsinZ;
        this.z = cosX * cosYsinZ - sinX * sinYcosZ;
        this.w = cosX * cosYcosZ + sinX * sinYsinZ;

        // Normalize the quaternion
        this.Normalize();
    }

    void CreateFromYawPitchRoll(Vec3f ypr)
    {
        float cy = Maths::Cos(ypr.x * 0.5f);
        float sy = Maths::Sin(ypr.x * 0.5f);
        float cp = Maths::Cos(ypr.y * 0.5f);
        float sp = Maths::Sin(ypr.y * 0.5f);
        float cr = Maths::Cos(ypr.z * 0.5f);
        float sr = Maths::Sin(ypr.z * 0.5f);
        
        Quaternion quaternion;
        quaternion.w = cr * cp * cy + sr * sp * sy;
        quaternion.x = sr * cp * cy - cr * sp * sy;
        quaternion.y = cr * sp * cy + sr * cp * sy;
        quaternion.z = cr * cp * sy - sr * sp * cy;
        
        this = quaternion;
    }

    /// Computes the angle change represented by a normalized quaternion.
    float GetAngle()
    {
        float qw = Maths::Abs(this.w);
        if (qw > 1)
            return 0;
        return 2 * Maths::ACos(qw);
    }

    /// Computes the axis angle representation of a normalized quaternion.
    Vec3f GetAxisAngleFromQuaternion(float &out angle)
    {       
        Vec3f axis;
        Quaternion q = this;
        float qx = q.x;
        float qy = q.y;
        float qz = q.z;
        float qw = q.w;
        if (qw < 0)
        {
            qx = -qx;
            qy = -qy;
            qz = -qz;
            qw = -qw;
        }
        if (qw > 1 - 1e-6)
        {
            axis = Vec3f(0,1,0);
            angle = 0;
        }
        else
        {
            angle = (2 * Maths::ACos(qw))*(180/Maths::Pi);
            float denominator = 1.0 / Maths::Sqrt(1.0 - qw * qw);
            axis.z = qx * denominator;
            axis.y = qy * denominator;
            axis.x = qz * denominator;
        }
        return axis;
    }

    float Dot(Quaternion b)
    {
        return this.x * b.x + this.y * b.y + this.z * b.z + this.w * b.w;
    }

    /////// this is vec3f shit///
    float Dot(Vec3f vec1, Vec3f vec2)
    {
        return vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z;
    }  
    Vec3f Cross(Vec3f vec1, Vec3f vec2) const
    {
        return Vec3f(vec1.y * vec2.z - vec2.y * vec1.z,
                    (vec1.x * vec2.z - vec2.x * vec1.z),
                     vec1.x * vec2.y - vec2.x * vec1.y);
    }
    /////////////////////////////


    /// Computes the quaternion rotation between two normalized vectors.
    void GetQuaternionBetweenNormalizedVectors( Vec3f v1, Vec3f v2, Quaternion &out q)
    {
        float dot = Dot(v1,v2);        
        //For non-normal vectors, the multiplying the axes length squared would be necessary:
        //float w = dot + (float)Maths::Sqrt(v1.LengthSquared() * v2.LengthSquared());
        if (dot < -0.9999f) //parallel, opposing direction
        {
            //If this occurs, the rotation required is ~180 degrees.
            //The problem is that we could choose any perpendicular axis for the rotation. It's not uniquely defined.
            //The solution is to pick an arbitrary perpendicular axis.
            //Project onto the plane which has the lowest component magnitude.
            //On that 2d plane, perform a 90 degree rotation.
            float absX = Maths::Abs(v1.x);
            float absY = Maths::Abs(v1.y);
            float absZ = Maths::Abs(v1.z);
            if (absX < absY && absX < absZ)
                q = Quaternion(0, -v1.z, v1.y, 0);
            else if (absY < absZ)
                q = Quaternion(-v1.z, 0, v1.x, 0);
            else
                q = Quaternion(-v1.y, v1.x, 0, 0);
        }
        else
        {
            Vec3f axis = Cross(v1, v2);
            q = Quaternion(axis.x, axis.y, axis.z, dot + 1);
        }
        q.Normalize();
    }

    //The following two functions are highly similar, but it's a bit of a brain teaser to phrase one in terms of the other.
    //Providing both simplifies things.

    /// Computes the rotation from the start orientation to the end orientation such that end = QuaternionEx.Concatenate(start, relative).
    void GetRelativeRotation(Quaternion other, Quaternion &out relative)
    {
        Quaternion startInverse = Conjugated(this);
        other = relative.Concatenated(startInverse);
    }

    /// Transforms the rotation into the local space of the target basis such that rotation = QuaternionEx.Concatenate(localRotation, targetBasis)
    void GetLocalRotation(Quaternion targetBasis)
    {
        Quaternion basisInverse = Conjugated(targetBasis);
        this = basisInverse.Concatenated(this);
    }

    Quaternion Divide(Quaternion quaternion1, Quaternion quaternion2)
    {
        Quaternion quaternion;
        float x = quaternion1.x;
        float y = quaternion1.y;
        float z = quaternion1.z;
        float w = quaternion1.w;
        float num14 = (((quaternion2.x * quaternion2.x) + (quaternion2.y * quaternion2.y)) + (quaternion2.z * quaternion2.z)) + (quaternion2.w * quaternion2.w);
        float num5 = 1.0f / num14;
        float num4 = -quaternion2.x * num5;
        float num3 = -quaternion2.y * num5;
        float num2 = -quaternion2.z * num5;
        float num = quaternion2.w * num5;
        float num13 = (y * num2) - (z * num3);
        float num12 = (z * num4) - (x * num2);
        float num11 = (x * num3) - (y * num4);
        float num10 = ((x * num4) + (y * num3)) + (z * num2);
        quaternion.x = ((x * num) + (num4 * w)) + num13;
        quaternion.y = ((y * num) + (num3 * w)) + num12;
        quaternion.z = ((z * num) + (num2 * w)) + num11;
        quaternion.w = (w * num) - num10;
        return quaternion;

    }

    void Divide(Quaternion@ quaternion1, Quaternion quaternion2, Quaternion &out result)
    {
        float x = quaternion1.x;
        float y = quaternion1.y;
        float z = quaternion1.z;
        float w = quaternion1.w;
        float num14 = (((quaternion2.x * quaternion2.x) + (quaternion2.y * quaternion2.y)) + (quaternion2.z * quaternion2.z)) + (quaternion2.w * quaternion2.w);
        float num5 = 1.0f / num14;
        float num4 = -quaternion2.x * num5;
        float num3 = -quaternion2.y * num5;
        float num2 = -quaternion2.z * num5;
        float num = quaternion2.w * num5;
        float num13 = (y * num2) - (z * num3);
        float num12 = (z * num4) - (x * num2);
        float num11 = (x * num3) - (y * num4);
        float num10 = ((x * num4) + (y * num3)) + (z * num2);
        result.x = ((x * num) + (num4 * w)) + num13;
        result.y = ((y * num) + (num3 * w)) + num12;
        result.z = ((z * num) + (num2 * w)) + num11;
        result.w = (w * num) - num10;

    }


    float Dot(Quaternion quaternion1, Quaternion quaternion2)
    {
        return ((((quaternion1.x * quaternion2.x) + (quaternion1.y * quaternion2.y)) + (quaternion1.z * quaternion2.z)) + (quaternion1.w * quaternion2.w));
    }

    void Dot(Quaternion@ quaternion1, Quaternion quaternion2, float &out result)
    {
        result = (((quaternion1.x * quaternion2.x) + (quaternion1.y * quaternion2.y)) + (quaternion1.z * quaternion2.z)) + (quaternion1.w * quaternion2.w);
    }
    

    float kEpsilon = 0.000001f;
    // Is the dot product of two quaternions within tolerance for them to be considered equal?
    bool IsEqualUsingDot(float dot)
    {
        // Returns false in the presence of NaN values.
        return dot > 1.0f - kEpsilon;
    }

    // Returns the angle in degrees between two rotations /a/ and /b/.
    float Angle( Quaternion b)
    {
        float dot = this.Dot(b);
        return IsEqualUsingDot(dot) ? 0.0f : Maths::ACos(Maths::Min(Maths::Abs(dot), 1.0f)) * 2.0F * (180.0f / Maths::Pi);
    }


    Vec3f OrthoNormalize( Vec3f normal, Vec3f tangent )
    {    
        normal.normalize();    
        tangent.normalize();    
        return Cross(tangent, normal );
    }    

//    Vec3f OrthoNormalize( Vec3f normal, Vec3f tangent, Vec3f binormal)
//    {
//        normal.normalize(); 
//        v = cross(normal,u); 
//        v.normalize(); 
//        u = cross(v,normal);
//    }

    // Creates a rotation with the specified /forward/ and /upwards/ directions.
    void SetLookRotation(Vec3f view, Vec3f up = Vec3f(0,1,0)) { this = getLookRotation(view, up); }
    void AddLookRotation(Vec3f view, Vec3f up = Vec3f(0,1,0)) { this += getLookRotation(view, up); }

    Quaternion getLookRotation(Vec3f lookAt, Vec3f upDirection = Vec3f(0,1,0)) 
    {
       Vec3f forward = lookAt; 
       Vec3f up = OrthoNormalize(forward, upDirection);
       Vec3f right = Cross(up, forward);

       float m00 = right.x;
       float m01 = up.x;
       float m02 = forward.x;
       float m10 = right.y;
       float m11 = up.y;
       float m12 = forward.y;
       float m20 = right.z;
       float m21 = up.z;
       float m22 = forward.z;

       Quaternion ret;
       ret.w = Maths::Sqrt(1.0f + m00 + m11 + m22) * 0.5f;
       if (ret.w < 0.000001f) return Quaternion();
       float w4_recip = 1.0f / (4.0f * ret.w);
       ret.x = (m21 - m12) * w4_recip;
       ret.y = (m02 - m20) * w4_recip;
       ret.z = (m10 - m01) * w4_recip;

       return ret;
    }

    bool opEquals(Quaternion other)
    {
        return ((((this.x == other.x) && (this.y == other.y)) && (this.z == other.z)) && (this.w == other.w));
    }

    //int GetHashCode()
    //{
    //    return (((this.x.GetHashCode() + this.y.GetHashCode()) + this.z.GetHashCode()) + this.w.GetHashCode());
    //}

    void Invert()
    {
        float LengthSquared = this.LengthSquared();
        this.x *= -LengthSquared;
        this.y *= -LengthSquared;
        this.z *= -LengthSquared;
        this.w *=  LengthSquared;
    }

    Quaternion GetInverse()
    {
        Quaternion ret();
        float LengthSquared = this.LengthSquared();
        ret.x *= -LengthSquared;
        ret.y *= -LengthSquared;
        ret.z *= -LengthSquared;
        ret.w *=  LengthSquared;
        return ret;
    }

    float Length()
    {
        return Maths::Sqrt(this.x * this.x + this.y * this.y + this.z * this.z + this.w * this.w);
    }

    float LengthSquared()
    {
        return (this.x * this.x + this.y * this.y + this.z * this.z + this.w * this.w);
    }

    void Normalize(Quaternion &out toReturn)
    {
        if (this.Length() == 0) return;
        float inverse = (1.0f / this.Length());
        toReturn.x *= inverse;
        toReturn.y *= inverse;
        toReturn.z *= inverse;
        toReturn.w *= inverse;
    }

    void Normalized()
    {
        if (this.Length() == 0) return;
        float inverse = (1.0f / this.Length());
        this.x *= inverse;
        this.y *= inverse;
        this.z *= inverse;
        this.w *= inverse;
    }

    Quaternion Lerp(Quaternion quaternion1, Quaternion quaternion2, float amount)
    {
        float num = amount;
        float num2 = 1.0f - num;
        Quaternion quaternion = Quaternion();
        float num5 = (((quaternion1.x * quaternion2.x) + (quaternion1.y * quaternion2.y)) + (quaternion1.z * quaternion2.z)) + (quaternion1.w * quaternion2.w);
        if (num5 >= 0.0f)
        {
            quaternion.x = (num2 * quaternion1.x) + (num * quaternion2.x);
            quaternion.y = (num2 * quaternion1.y) + (num * quaternion2.y);
            quaternion.z = (num2 * quaternion1.z) + (num * quaternion2.z);
            quaternion.w = (num2 * quaternion1.w) + (num * quaternion2.w);
        }
        else
        {
            quaternion.x = (num2 * quaternion1.x) - (num * quaternion2.x);
            quaternion.y = (num2 * quaternion1.y) - (num * quaternion2.y);
            quaternion.z = (num2 * quaternion1.z) - (num * quaternion2.z);
            quaternion.w = (num2 * quaternion1.w) - (num * quaternion2.w);
        }
        float num4 = (((quaternion.x * quaternion.x) + (quaternion.y * quaternion.y)) + (quaternion.z * quaternion.z)) + (quaternion.w * quaternion.w);
        float num3 = 1.0f / (Maths::Sqrt(num4));
        quaternion.x *= num3;
        quaternion.y *= num3;
        quaternion.z *= num3;
        quaternion.w *= num3;
        return quaternion;
    }


    void Lerp(Quaternion@ quaternion1, Quaternion quaternion2, float amount, Quaternion &out result)
    {
        float num = amount;
        float num2 = 1.0f - num;
        float num5 = (((quaternion1.x * quaternion2.x) + (quaternion1.y * quaternion2.y)) + (quaternion1.z * quaternion2.z)) + (quaternion1.w * quaternion2.w);
        if (num5 >= 0.0f)
        {
            result.x = (num2 * quaternion1.x) + (num * quaternion2.x);
            result.y = (num2 * quaternion1.y) + (num * quaternion2.y);
            result.z = (num2 * quaternion1.z) + (num * quaternion2.z);
            result.w = (num2 * quaternion1.w) + (num * quaternion2.w);
        }
        else
        {
            result.x = (num2 * quaternion1.x) - (num * quaternion2.x);
            result.y = (num2 * quaternion1.y) - (num * quaternion2.y);
            result.z = (num2 * quaternion1.z) - (num * quaternion2.z);
            result.w = (num2 * quaternion1.w) - (num * quaternion2.w);
        }
        float num4 = (((result.x * result.x) + (result.y * result.y)) + (result.z * result.z)) + (result.w * result.w);
        float num3 = 1.0f / (Maths::Sqrt(num4));
        result.x *= num3;
        result.y *= num3;
        result.z *= num3;
        result.w *= num3;

    }

    void Slerp( Quaternion quaternion2, float amount)
    {
        float num2;
        float num3;
        float num = amount;
        float num4 = (((this.x * quaternion2.x) + (this.y * quaternion2.y)) + (this.z * quaternion2.z)) + (this.w * quaternion2.w);
        bool flag = false;
        if (num4 < 0.0f)
        {
            flag = true;
            num4 = -num4;
        }
        if (num4 > 0.999999f)
        {
            num3 = 1.0f - num;
            num2 = flag ? -num : num;
        }
        else
        {
            float num5 = Maths::ACos(num4);
            float num6 = (1.0 / Maths::Sin(num5));
            num3 = (Maths::Sin(((1.0f - num) * num5))) * num6;
            num2 = flag ? ((-Maths::Sin((num * num5))) * num6) : ((Maths::Sin((num * num5))) * num6);
        }
        this.x = (num3 * this.x) + (num2 * quaternion2.x);
        this.y = (num3 * this.y) + (num2 * quaternion2.y);
        this.z = (num3 * this.z) + (num2 * quaternion2.z);
        this.w = (num3 * this.w) + (num2 * quaternion2.w);
    }

    Quaternion Subtract(Quaternion quaternion1, Quaternion quaternion2)
    {
        Quaternion quaternion;
        quaternion.x = quaternion1.x - quaternion2.x;
        quaternion.y = quaternion1.y - quaternion2.y;
        quaternion.z = quaternion1.z - quaternion2.z;
        quaternion.w = quaternion1.w - quaternion2.w;
        return quaternion;
    }


    void Subtract(Quaternion@ quaternion1, Quaternion quaternion2, Quaternion &out result)
    {
        result.x = quaternion1.x - quaternion2.x;
        result.y = quaternion1.y - quaternion2.y;
        result.z = quaternion1.z - quaternion2.z;
        result.w = quaternion1.w - quaternion2.w;
    }


    Quaternion opNeg()
    {
        Quaternion q2;
        q2.x = -this.x;
        q2.y = -this.y;
        q2.z = -this.z;
        q2.w = -this.w;
        return q2;
    }

    void Normalize()
    {
        float num2 = (((this.x * this.x) + (this.y * this.y)) + (this.z * this.z)) + (this.w * this.w);
        float num = 1.0f / (Maths::Sqrt(num2));
        this.x *= num;
        this.y *= num;
        this.z *= num;
        this.w *= num;
    }

    Quaternion Normalize(Quaternion quaternion)
    {
        Quaternion quaternion2;
        float num2 = (((quaternion.x * quaternion.x) + (quaternion.y * quaternion.y)) + (quaternion.z * quaternion.z)) + (quaternion.w * quaternion.w);
        float num = 1.0f / (Maths::Sqrt(num2));
        quaternion2.x = quaternion.x * num;
        quaternion2.y = quaternion.y * num;
        quaternion2.z = quaternion.z * num;
        quaternion2.w = quaternion.w * num;
        return quaternion2;
    }


    void Normalize(Quaternion@ quaternion, Quaternion &out result)
    {
        float num2 = (((quaternion.x * quaternion.x) + (quaternion.y * quaternion.y)) + (quaternion.z * quaternion.z)) + (quaternion.w * quaternion.w);
        float num = 1.0f / (Maths::Sqrt(num2));
        result.x = quaternion.x * num;
        result.y = quaternion.y * num;
        result.z = quaternion.z * num;
        result.w = quaternion.w * num;
    }

    Quaternion opDiv(Quaternion quaternion1, Quaternion quaternion2)
    {
        Quaternion quaternion;
        float x = quaternion1.x;
        float y = quaternion1.y;
        float z = quaternion1.z;
        float w = quaternion1.w;
        float num14 = (((quaternion2.x * quaternion2.x) + (quaternion2.y * quaternion2.y)) + (quaternion2.z * quaternion2.z)) + (quaternion2.w * quaternion2.w);
        float num5 = 1.0f / num14;
        float num4 = -quaternion2.x * num5;
        float num3 = -quaternion2.y * num5;
        float num2 = -quaternion2.z * num5;
        float num = quaternion2.w * num5;
        float num13 = (y * num2) - (z * num3);
        float num12 = (z * num4) - (x * num2);
        float num11 = (x * num3) - (y * num4);
        float num10 = ((x * num4) + (y * num3)) + (z * num2);
        quaternion.x = ((x * num) + (num4 * w)) + num13;
        quaternion.y = ((y * num) + (num3 * w)) + num12;
        quaternion.z = ((z * num) + (num2 * w)) + num11;
        quaternion.w = (w * num) - num10;
        return quaternion;
    }

    bool opEquals(Quaternion quaternion1, Quaternion quaternion2)
    {
        return ((((quaternion1.x == quaternion2.x) && (quaternion1.y == quaternion2.y)) && (quaternion1.z == quaternion2.z)) && (quaternion1.w == quaternion2.w));
    }


    bool opNotEquals(Quaternion quaternion1, Quaternion quaternion2)
    {
        if (((quaternion1.x == quaternion2.x) && (quaternion1.y == quaternion2.y)) && (quaternion1.z == quaternion2.z))
        {
            return (quaternion1.w != quaternion2.w);
        }
        return true;
    }

    Quaternion opMul(Quaternion q2)
    {
        float num = q2.w;
        float num2 = q2.z;
        float num3 = q2.y;
        float num4 = q2.x;
        float num12 = (this.y * num2) - (this.z * num3);
        float num11 = (this.z * num4) - (this.x * num2);
        float num10 = (this.x * num3) - (this.y * num4);
        float num9 = ((this.x * num4) + (this.y * num3)) + (this.z * num2);
        Quaternion result;
        result.x = ((this.x * num) + (num4 * this.w)) + num12;
        result.y = ((this.y * num) + (num3 * this.w)) + num11;
        result.z = ((this.z * num) + (num2 * this.w)) + num10;
        result.w = (this.w * num) - num9;
        return result;
    }
    void opMulAssign(Quaternion q2)
    {
        this = opMul(q2);
    }

    Vec3f opMul(Vec3f point)
    {
        float x = this.x * 2.0f;
        float y = this.y * 2.0f;
        float z = this.z * 2.0f;
        float xx = this.x * x;
        float yy = this.y * y;
        float zz = this.z * z;
        float xy = this.x * y;
        float xz = this.x * z;
        float yz = this.y * z;
        float wx = this.w * x;
        float wy = this.w * y;
        float wz = this.w * z;

        Vec3f res;
        res.x = (1.0f - (yy + zz)) * point.x + (xy - wz) * point.y + (xz + wy) * point.z;
        res.y = (xy + wz) * point.x + (1.0f - (xx + zz)) * point.y + (yz - wx) * point.z;
        res.z = (xz - wy) * point.x + (yz + wx) * point.y + (1.0f - (xx + yy)) * point.z;
        return res;
    }

    Quaternion opMul(float scaleFactor)
    {
        Quaternion q;
        q.x = this.x * scaleFactor;
        q.y = this.y * scaleFactor;
        q.z = this.z * scaleFactor;
        q.w = this.w * scaleFactor;
        return q;
    }

    Quaternion opAdd(Quaternion &in otherq)
    {
        Quaternion q;
        q.x = this.x + otherq.x;
        q.y = this.y + otherq.y;
        q.z = this.z + otherq.z;
        q.Normalize();
       // q.w = this.w + otherq.w;
        return q;
    }    

    void opAddAssign(const Quaternion &in otherq)
    {
        Quaternion q;
        q.x = this.x + otherq.x;
        q.y = this.y + otherq.y;
        q.z = this.z + otherq.z;
        q.w = this.w + otherq.w;
        this = q;
    }

    Quaternion opSub(Quaternion q2)
    {
        Quaternion newq;
        newq.x = this.x - q2.x;
        newq.y = this.y - q2.y;
        newq.z = this.z - q2.z;
        newq.w = this.w - q2.w;
        return newq;
    }
    void opSubAssign(Quaternion q2)
    {
        this = opSub(q2);
    }

    float[] ToArray()
    {

        float x2 = this.x * this.x;
        float y2 = this.y * this.y;
        float z2 = this.z * this.z;
        float xy = this.x * this.y;
        float xz = this.x * this.z;
        float yz = this.y * this.z;
        float wx = this.w * this.x;
        float wy = this.w * this.y;
        float wz = this.w * this.z;

        float[] arr;

        arr.push_back(1.0f - 2.0f * (y2 + z2));
        arr.push_back(2.0f * (xy - wz));
        arr.push_back(2.0f * (xz + wy));

        arr.push_back(2.0f * (xy + wz));
        arr.push_back(1.0f - 2.0f * (x2 + z2));
        arr.push_back(2.0f * (yz - wx));

        arr.push_back(2.0f * (xz - wy));
        arr.push_back(2.0f * (yz + wx));
        arr.push_back(1.0f - 2.0f * (x2 + y2));

        return arr;
    }

    Matrix4 ToMatrix()
    {
        // source -> http://content.gpwiki.org/index.php/OpenGL:Tutorials:Using_Quaternions_to_represent_rotation#Quaternion_to_Matrix4
        float x2 = this.x * this.x;
        float y2 = this.y * this.y;
        float z2 = this.z * this.z;
        float xy = this.x * this.y;
        float xz = this.x * this.z;
        float yz = this.y * this.z;
        float wx = this.w * this.x;
        float wy = this.w * this.y;
        float wz = this.w * this.z;

        // This calculation would be a lot more complicated for non-unit length quaternions
        // Note: The constructor of Matrix4 expects the Matrix4 in column-major format like expected by
        //   OpenGL
        Matrix4 matrix;
        matrix[0] = 1.0f - 2.0f * (y2 + z2);
        matrix[1] = 2.0f * (xy - wz);
        matrix[2] = 2.0f * (xz + wy);
        matrix[3] = 0.0f;

        matrix[4] = 2.0f * (xy + wz);
        matrix[5] = 1.0f - 2.0f * (x2 + z2);
        matrix[6] = 2.0f * (yz - wx);
        matrix[7] = 0.0f;

        matrix[8] = 2.0f * (xz - wy);
        matrix[9] = 2.0f * (yz + wx);
        matrix[10] = 1.0f - 2.0f * (x2 + y2);
        matrix[11] = 0.0f;

        matrix[12] = 2.0f * (xz - wy);
        matrix[13] = 2.0f * (yz + wx);
        matrix[14] = 1.0f - 2.0f * (x2 + y2);
        matrix[15] = 0.0f;

        //return Matrix4( 1.0f - 2.0f * (y2 + z2), 2.0f * (xy - wz), 2.0f * (xz + wy), 0.0f,
        //      2.0f * (xy + wz), 1.0f - 2.0f * (x2 + z2), 2.0f * (yz - wx), 0.0f,
        //      2.0f * (xz - wy), 2.0f * (yz + wx), 1.0f - 2.0f * (x2 + y2), 0.0f,
        //      0.0f, 0.0f, 0.0f, 1.0f)
        //  }
        return matrix;
    }
}

