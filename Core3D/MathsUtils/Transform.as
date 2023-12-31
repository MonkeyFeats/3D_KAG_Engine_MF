shared enum RotationOrder { OrderXYZ, OrderXZY, OrderYZX, OrderYXZ, OrderZXY, OrderZYX }

shared class RigidTransform : EntityComponent
{
    Vec3f position;
    Vec3f localPosition;
    Vec3f scale;

    //Vec3f rotation;
    Quaternion rotation;
    Quaternion localRotation;

    RigidTransform() {}
    RigidTransform(Vec3f _position = Vec3f(), Vec3f _rotation = Vec3f(), Vec3f _scale = Vec3f(1,1,1))
    {
        setPosition(_position);
        setRotation(_rotation);
        setScale(_scale);
    }

    //Vec3f right { get { return rotation * Vector3.right; } set { rotation = Quaternion.FromToRotation(Vector3.right, value); } }
    //Vec3f up { get { return rotation * Vector3.up; } set { rotation = Quaternion.FromToRotation(Vector3.up, value); } }
    //Vec3f forward { get { return rotation * Vector3.forward; } set { rotation = Quaternion.LookRotation(value); } }

    void setPosition(Vec3f _pos) {position = _pos;}
    void setPosition(f32 _x, f32 _y, f32 _z) {position = Vec3f(_x,_y,_z);}
    void addPosition(Vec3f _pos) {position += _pos;}
    void addPosition(f32 _x, f32 _y, f32 _z) {position += Vec3f(_x,_y,_z);}
    Vec3f getPosition() {return position;}

    void setRotation(Quaternion _quat) {rotation = _quat;}
    void setRotation(Vec3f _axis) {rotation.CreateFromEulerAngles(_axis);}
    void setRotation(f32 _x, f32 _y, f32 _z) { rotation.CreateFromEulerAngles(_x,_y,_z); }

    void setLocalRotation(Vec3f _axis) {localRotation.CreateFromEulerAngles(_axis);}
    void setLocalRotation(f32 _x, f32 _y, f32 _z) { localRotation.CreateFromEulerAngles(_x,_y,_z); }
    Vec3f getRotation() {  return rotation.ToEulerAngles();}    
    Vec3f getLocalRotation() {  return localRotation.getEuler()*(180.0f / Maths::Pi);}

    void addRotation(Vec3f _axis) 
    {
        rotation.AddYawPitchRoll(_axis.z,_axis.y,_axis.z);
        localRotation.AddYawPitchRoll(_axis.z,_axis.y,_axis.z);
    }
    void addRotation(f32 _x, f32 _y, f32 _z) 
    {
        rotation.AddYawPitchRoll(_x,_y,_z);
        localRotation.AddYawPitchRoll(_x,_y,_z);
    }
    void addLocalRotation(Vec3f _axis) 
    {
        localRotation.AddYawPitchRoll(_axis.z,_axis.y,_axis.z);
    }
    void addLocalRotation(f32 _x, f32 _y, f32 _z) 
    {
        localRotation.AddYawPitchRoll(_x,_y,_z);
    }


    void setScale(Vec3f _scale) {scale = _scale;}
    void addScale(Vec3f _scale) {scale += _scale;}

    Vec3f getScale() const { return scale; }

    //Vec3f eulerAngles { get { return rotation.eulerAngles; } set { rotation = Quaternion.Euler(value); } }
    //Vec3f eulerAngles { get { return rotation.getEuler(); } set { rotation = Quaternion()); } }

    void RotateLocal(Vec3f eulers)
    {
        Quaternion eulerRot();
        eulerRot.CreateFromEulerAngles(eulers.x, eulers.y, eulers.z);
        localRotation = localRotation * eulerRot;
    }

    void Rotate(Vec3f eulers)
    {
        Quaternion eulerRot();
        eulerRot.CreateFromEulerAngles(eulers.x, eulers.y, eulers.z);
        rotation = rotation * (rotation.GetInverse() * eulerRot * rotation);
    }

    float getDistanceTo( Vec3f otherPos ) {return (getPosition() - otherPos).length();}

};

