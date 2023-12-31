#include "Camera3D.as";



/// A physical object has all of the physical properties and behaviors you'd expect a physical object to have.
/// 

shared class Physical : PhysicalEntity
{
    //#region Bounding volume areas
    //Note: A model may have a bounding volume for its meshes which is different from the bounding
    //volumes of the actual physical bounds. A tree would have a long narrow trunk and a large canopy,
    //which should have very different physical boundary areas than that whole bounding area for the 
    //whole tree mesh.

    
    /// This is the broad phase bounding sphere. This should enclose the whole object!
    /// Use this first for any collision detection since it is the fastest to calculate.
    /// Note: Use length squared to avoid a square root calculation!
    
    BoundingSphere m_boundingSphere;
    
    /// This is the broad phase bounding sphere for physical collisions.    
    BoundingSphere m_hitSphere;
    Vec3f m_hitSphereOffset = Vec3f();

    
    /// this is a coarse bounding box for the entire object. If this bounding box doesn't intersect with another coarse bounding box, 
    /// then there isn't a need for any further collision checks.    
    OBB m_OBB;
    
    /// This is the physical hit box for the object    
    OBB m_hitBox;
    

    float m_mass;                 //measured in Kg
    Vec3f m_position;             //current position of the object
    Vec3f m_lastPosition;       //position last frame
    Vec3f m_velocity;           //change in position over time -- note that velocity may be distinct from orientation (ie. facing forwards but moving backwards)
    Vec3f m_acceleration;       //change in velocity over time
    float m_topAccelleration;     //this is the top accelleration
    float m_topSpeed;             //maximum speed for velocity   -- note: using a range in case you want to temporarily reduce the top speed
    Vec3f m_steerForce;         //These are all of the forces acting on the object accelleration (thrust, gravity, drag, etc) 
    float m_scale = 1.0f;         //this is the scale factor for the object
    Vec3f m_gravityForce = Vec3f();

    
    /// In some cases, you want to attach a physical property to another object via composition instead of inheritance. This gives the physical
    /// property a reference to the object its attached to, so that when the physical object updates, it will call the update of the attached object
    /// as well.
    
    PhysicalEntity m_pAttachment = null;
    Quaternion m_orientation;     //orientation in 3D space

    
    /// This is the current rotation in 2D
    
    Vec3f m_rotation;
    
    /// The rotation velocity is how fast the rotation angle can change over time. Set to Pi for instantaneous rotation.
    
    float m_rotationVelocity;

    
    /// This sets the fastest an object can rotate
    
    float m_rotationSpeed;
    

    //#region Meta properties
    int m_type = PhysicalType::Nothing;

    
    /// These are all of the categories of objects this physical object can collide with.
    /// If this object intersects with any of these objects, a collision event is raised and it is up
    /// to the implementer to decide how they want to handle that event.
    
    int m_colliders = PhysicalType::Nothing;

    //Effect m_effect;
    int m_visible;

    
    /// This indicates that the object doesn't actually move (such as terrain)
    
    bool m_stationary = true;

    
    /// This is the current level of detail used to draw the object based on its distance from the active camera.
    /// <para>0 - Highest level of detail</para>
    /// <para>1 - medium level of detail</para>
    /// <para>2 - low level of detail</para>
    /// <para>3 - no draw</para>
    
    int m_activeLOD = 0;

    //because you don't want to go hunting around an octree for an object just to see its update loop.
    bool m_breakOnUpdate = false;
    bool BreakOnUpdate { set { m_breakOnUpdate = value; } }
    

    //#region Constructors
    
    /// Creates a physical object with default properties
    
    Physical()
    {
        m_mass = 1.0f;
        m_position = Vec3f();
        m_lastPosition = Vec3f();
        m_velocity = Vec3f();
        m_acceleration = Vec3f();
        m_topAccelleration = 1.0;
        m_topSpeed = -1.0;
        m_orientation = Quaternion();
        m_rotation = Vec3f();
        m_rotationSpeed = (Maths::Pi*2) * 4;
        m_rotationVelocity = m_rotationSpeed;

        m_boundingSphere = BoundingSphere(m_position, 1.0f);

        m_steerForce = Vec3f();
        m_visible = Visibility::Visible;
    }
    
    /// Creates a deep copy of the physical object    
    /// <param name="copy">The object to duplicate</param>
    Physical(Physical copy)
    {
        copy.SanityCheck();

        if (copy.m_OBB != null)
            m_OBB = OBB(copy.m_OBB.Min, copy.m_OBB.Max);
        if (copy.m_boundingSphere != null)
            m_boundingSphere = BoundingSphere(copy.m_boundingSphere.getPosition(), copy.m_boundingSphere.Radius);
        if (copy.m_hitBox != null)
            m_hitBox = OBB(copy.m_hitBox.Min, copy.m_hitBox.Max);
        if (copy.m_hitSphere != null)
            m_hitSphere = BoundingSphere(copy.m_hitSphere.getPosition(), copy.m_hitSphere.Radius);
        
        m_mass = copy.m_mass;
        m_position = Vec3f(copy.m_position.x, copy.m_position.y, copy.m_position.z);
        m_lastPosition = Vec3f(copy.m_lastPosition.x, copy.m_lastPosition.y, copy.m_lastPosition.z);
        m_velocity = Vec3f(copy.m_velocity.x, copy.m_velocity.y, copy.m_velocity.z);
        m_acceleration = Vec3f(copy.m_acceleration.x, copy.m_acceleration.y, copy.m_acceleration.z);
        m_topAccelleration = float(copy.m_topAccelleration);
        m_topSpeed = float(copy.m_topSpeed);
        m_orientation = copy.m_orientation;
        m_rotation = copy.m_rotation;
        m_rotationVelocity = float(copy.m_rotationVelocity);
        m_steerForce = Vec3f(copy.m_steerForce.x, copy.m_steerForce.y, copy.m_steerForce.z);
        

        m_stationary = copy.m_stationary;
        m_type = copy.m_type;
        //if (copy.m_effect != null) m_effect = copy.m_effect.Clone();
        m_activeLOD = copy.m_activeLOD;
        
    }
    

    
    
    /// Moves an object according to its position, velocity and acceleration and the change in game time
    
    /// <param name="worldTime">The change in world time since last update</param>
    /// <returns>
    /// 0 = The object did not move.
    /// 1 = the object was moved.
    /// 2 = the object just died.
    ///</returns>
    int Update(float time = getGameTime())// override 
    {
        //if (m_breakOnUpdate)
        //{
        //    string myName = Name;
        //}
//
        //if (m_alive == false)
        //    return 2;

        if (m_pAttachment != null)
        {
            //m_pAttachment.Update();
        }

        if (!m_stationary)
        {
            SanityCheck();

            float t = getGameTime();
            m_lastPosition = Position;
            m_rotation += m_rotationVelocity * t;
            m_acceleration = (m_steerForce / m_mass) + (m_gravityForce * t); //F = ma -> a = F/m
            m_velocity += m_acceleration;  //velocity is the change in acceleration over time

            //don't move faster than our top speed
            if (m_velocity != Vec3f() && m_topSpeed != -1)
            {
                //we're constraining the object to a top speed.
                if (m_velocity.length() > m_topSpeed)
                {
                    m_velocity.normalize();
                    m_velocity *= m_topSpeed;
                }
            }

            Vec3f moveStep = m_velocity * t;
            m_position += moveStep;  //Position += moveStep;     //position is the change in velocity over time

            if(m_boundingSphere != null)
               m_boundingSphere.setPosition(m_boundingSphere.getPosition() + moveStep);
            if (m_hitSphere != null)
                m_hitSphere.setPosition(m_hitSphere.getPosition() + moveStep);
            if (m_OBB != null)
            {
                m_OBB.Max += moveStep;
                m_OBB.Min += moveStep;
            }
            if (m_hitBox != null)
            {
                m_hitBox.Max += moveStep;
                m_hitBox.Min += moveStep;
            }

            if (m_lastPosition != Position) return 1;
        }        

        return 0;
    }

    
    /// Detect value corruption before it spreads!
    
    void SanityCheck()
    {
        

        //if (float.IsNaN(Position.x) || float.IsNaN(Position.y) || float.IsNaN(Position.z))
        //    throw Exception("Object position data is corrupted.");
        //if (float.IsNaN(m_rotationVelocity))
        //    throw Exception("Rotation velocity data is corrupted.");
        //if (float.IsNaN(m_steerForce.x) || float.IsNaN(m_steerForce.y) || float.IsNaN(m_steerForce.z))
        //    throw Exception("Steer force data has been corrupted.");
        //if (float.IsNaN(m_acceleration.x) || float.IsNaN(m_acceleration.y) || float.IsNaN(m_acceleration.z))
        //    throw Exception("accelleration data has been corrupted.");
        //if (float.IsNaN(m_velocity.x) || float.IsNaN(m_velocity.y) || float.IsNaN(m_velocity.z))
        //    throw Exception("velocity data has been corrupted.");
        //if (float.IsNaN(m_topSpeed))
        //    throw Exception("top speed current value has been corrupted.");
        //if (m_mass == 0)
        //    throw Exception("A massless object has been detected. Impossibru!");
    }

    
    /// In some cases, you want to attach a physical property to another object via composition instead of inheritance. This gives the physical
    /// property a reference to the object its attached to, so that when the physical object updates, it will call the update of the attached object
    /// as well.
    
    /// <param name="parentObject">This is the object which contains the physical object.</param>
    void AttachTo(PhysicalEntity parentObject)
    {
        m_pAttachment = parentObject;
    }
    
    /// Applies a change in accelleration by accellerating in the direction of the current orientation
    
    /// <param name="force">A scalar amount of force to thrust with</param>
    /// <remarks>This is automatically truncated to the max speed.</remarks>
    void Thrust(float force)
    {
        Vec3f thrustVec = m_rotation; //Vec3f(m_rotation.x,m_rotation.y, 0);
        //already normalized...
        thrustVec *= force;
        ApplyForce(thrustVec);
    }
    
    /// Changes the accelleration of the whole object by the given force vector.
    /// Note that this has no bearing on the orientation of the object!
    
    /// <param name="forceVec">the force vector to change accelleration by</param>
    void ApplyForce(Vec3f forceVec)
    {
        //if (float.IsNaN(forceVec.x) || float.IsNaN(forceVec.y) || float.IsNaN(forceVec.z))
        if (forceVec == Vec3f())
        {
            warn("force vec is zero! ApplyForce() in PhysicalObject.as ");
            return;
        }

        Vec3f truncatedDirection = forceVec;

        //make sure we're not moving faster than our top speed
        if (truncatedDirection.length() > m_topSpeed)
        {
            truncatedDirection = truncatedDirection; truncatedDirection.normalize();
            truncatedDirection *= m_topSpeed;
        }

        if (truncatedDirection == Vec3f())
        {
            warn("direction vec is zero! ApplyForce() in PhysicalObject.as ");
            return;
        }

        m_steerForce = truncatedDirection;
    }

    //TODO: Write a function to apply a non-centered force impulse, causing the object to spin around and move

    
    /// Renders the physical object
    
    /// <param name="worldtime">This is the current world time. It is used for animation and key frames.</param>
    /// <param name="viewProjection">This is the camera view projection matrix</param>
    /// <returns> 0 if it was not drawn, 1 if drawn.</returns>
    int Render(Matrix4 viewProjection)
    {
        //the object isn't visible, so skip drawing
        if (m_visible == Visibility::NoDraw) return 0;
        return 1;
    }

    
    /// Every physical object can draw itself
    
    /// <param name="time"></param>
    void Draw()//coreTime time
    {
        //the object isn't visible, so skip drawing
        if (m_visible == Visibility::NoDraw) return;
    }

    void UpdateLOD(Camera3D currentCamera)
    {
        float dist = (currentCamera.getPosition() - m_position).lengthSquared();

        if (dist <= 2500)
            m_activeLOD = 0;
        else if (dist <= 15000)
            m_activeLOD = 1;
        else if (dist <= 50000)
            m_activeLOD = 2;
        else
            m_activeLOD = 3;
    }

    IntersectionRecord@ Intersects(Ray intersectionRay)
    {        
        float f;
        if (m_OBB != null && m_OBB.Min != m_OBB.Max)
        {
            f = m_OBB.Intersects(intersectionRay) ? 1 : 0;           
        }
        else if (m_boundingSphere.Radius != 0)
        {
            f = m_boundingSphere.Intersects(intersectionRay) ? 1 : 0;
        }
        
        //if (f != null)
        {
            Physical obj2();
            IntersectionRecord record(intersectionRay.Position + (intersectionRay.Direction * f), Vec3f(1,0,0), this, obj2, intersectionRay, f);            
            return record;
        }
        return null;
    }

    //void SetDirectionalLight(Vec3f direction, SColor color)
    //{
    //    m_effect.Parameters["xLightDirection0"].SetValue(direction);
    //    m_effect.Parameters["xLightColor0"].SetValue(color.ToVec3f());
    //    m_effect.Parameters["xEnableLighting"].SetValue(true);
    //}


    //#region Intersection    
    /// Tells you if the bounding regions for this object [intersect or are contained within] the bounding frustum
    
    /// <param name="intersectionFrustum">The frustum to do bounds checking against</param>
    /// <returns>An intersection record containing any intersection information, or null if there isn't any
    /// </returns>
    IntersectionRecord@ Intersects(BoundingFrustum intersectionFrustum)
    {
        //if (m_boundingSphere == null && m_OBB == null)
        //{
        //    warn("no bounding area for this object!");
        //    return null;
        //}
        //if (m_OBB != null && m_OBB.Max - m_OBB.Min != Vec3f())
        //{
        //    ContainmentType ct = intersectionFrustum.Contains(m_OBB);
        //    if (ct != ContainmentType::None)
        //    {
        //        IntersectionRecord record(); 
        //        record.m_intersectedObject1 = this;
        //        return record;
        //        //return IntersectionRecord(this);
        //    }
        //}
        //else if (m_boundingSphere != null && m_boundingSphere.Radius != 0.0f)
        //{
        //    ContainmentType ct = intersectionFrustum.Contains(m_boundingSphere);
        //    if (ct != ContainmentType::None)
        //    {
        //        IntersectionRecord record(); 
        //        record.m_intersectedObject1 = this;
        //        return record;
        //    }
        //}

        return null;
    }

    
    /// Coarse collision check: Tells you if this object intersects with the given intersection sphere.
    
    /// <param name="intersectionSphere">The intersection sphere to check against</param>
    /// <returns>An intersection record containing this object</returns>
    /// <remarks>You'll want to override this for granular collision detection</remarks>
    IntersectionRecord@ Intersects(BoundingSphere intersectionSphere)
    {
        if (m_OBB != null && m_OBB.Max != m_OBB.Min)
        {
            if (m_OBB.Contains(intersectionSphere) != ContainmentType::None)
            {
                IntersectionRecord record(); 
                record.m_intersectedObject1 = this;
                return record;
            }
        }
        else if (m_boundingSphere != null && m_boundingSphere.Radius != 0.0f)
        {
            if (m_boundingSphere.Contains(intersectionSphere) != ContainmentType::None)
            {
                IntersectionRecord record(); 
                record.m_intersectedObject1 = this;
                return record;
            }
        }

        return null;
    }

    
    /// Coarse collision check: Tells you if this object intersects with the given intersection box.
    
    /// <param name="intersectionBox">The intersection box to check against</param>
    /// <returns>An intersection record containing this object</returns>
    /// <remarks>You'll want to override this for granular collision detection</remarks>
    IntersectionRecord@ Intersects(OBB intersectionBox)
    {
        Vec3f mtv;
        if (m_OBB != null && m_OBB.Max != m_OBB.Min)
        {
            ContainmentType ct = m_OBB.Contains(intersectionBox, Vec3f(), mtv);
            if (ct != ContainmentType::None)
            {
                IntersectionRecord record(); 
                record.m_intersectedObject1 = this;
                return record;
            }
        }
        else if (m_boundingSphere != null && m_boundingSphere.Radius != 0.0f)
        {
            if (m_boundingSphere.Contains(intersectionBox, Vec3f(), mtv) != ContainmentType::None)
            {
                IntersectionRecord record(); 
                record.m_intersectedObject1 = this;
                return record;
            }
        }

        return null;
    }

    
    /// Tests for intersection with this object against the other object
    
    /// <param name="otherObj">The other object to test for intersection against</param>
    /// <returns>Null if there isn't an intersection, an intersection record if there is a hit.</returns>
    IntersectionRecord@ Intersects(Physical otherObj)
    {
        IntersectionRecord ir;

        if (otherObj.m_OBB != null && otherObj.m_OBB.Min != otherObj.m_OBB.Max)
        {
            ir = Intersects(otherObj.m_OBB);
        }
        else if (otherObj.m_boundingSphere != null && otherObj.m_boundingSphere.Radius != 0.0f)
        {
            ir = Intersects(otherObj.m_boundingSphere);
        }
        else
            return null;

        if (ir != null)
        {
            //ir.PhysicalObject = this;
            //ir.OtherPhysicalObject = otherObj;
        }

        IntersectionRecord record(); 
        record.m_intersectedObject1 = this;
        return record;
    }

    void HandleIntersection(IntersectionRecord ir)
    {

    }
    

    //#region Overrides
    string ToString()//override 
    {
        if (m_pAttachment != null)
            return "m_pAttachment.ToString()";
        return "base.ToString()";
    }
    

    //#region helper functions
    void UndoLastMove()
    {
        //Position = m_lastPosition;
    }

    void SetCollisionRadius(float radius)
    {
        m_boundingSphere.Radius = radius;
    }

    
    /// Gives you the force for a given instantaneous accelleration vector
    
    /// <param name="instantAccelleration">the instantaneous accelleration</param>
    /// <returns>A force vector</returns>
    Vec3f GetForce(Vec3f instantAccelleration)
    {
        return  instantAccelleration*m_mass;
    }

        
    /// Tells you if the point is within this creatures bounding volume
    bool HasPoint(int x, int y)
    {
        //Vec3f mtv;
        return m_boundingSphere.Contains(Vec3f(x, y, 0)) != ContainmentType::None;
    }

    bool HasPoint(Vec2f point)
    {
        //Vec3f mtv;
        return m_boundingSphere.Contains(Vec3f(point.x, point.y, 0)) != ContainmentType::None;
    }

    //static void FilterByType<T>(ref List<T> objList, PhysicalType filterOut) where T: Physical
    //{
    //    //UNTESTED
    //    if (objList == null || objList.Count == 0) return;
//
    //    int size = objList.Count;
    //    for (int a = 0; a < size; a++)
    //    {
    //        byte test = (byte)(objList[a].m_type & filterOut);
    //        if (test != 0)
    //        {
    //            objList.Remove(objList[a--]);
    //            size--;
    //        }
    //    }
    //}

    

    //#region Accessors
    int Type { get { return m_type; } set { m_type = value; } }

    Vec3f Position
    {
        get
        {
            return m_position;
        }
        set
        {
            if (value == Vec3f())
            {
                warn("Invalid position values recieved. Vec3f Position in PhysicalObject.as");
            }

            m_position = value;
            m_hitSphere.setPosition(value + m_hitSphereOffset); //.Position should be .center
            m_boundingSphere.setPosition(value);
        }
    }

    Vec3f LastPosition
    {
        get { return m_lastPosition; }
    }

    
    /// This is the creatures current 2D facing direction
    
    Vec3f Rotation
    {
        get { return m_rotation; }
        set { m_rotation = value; }
    }

    
    /// This is how much the rotation value changes over time
    
    float RotationVelocity
    {
        get { return m_rotationVelocity; }
        set { m_rotationVelocity = value; }
    }

    
    /// This is the maximum speed the object can rotate over time
    
    /// the rotational velocity is a value which normally ranges between its min and max values.
    /// the current value is how much the rotation changes over time.
    /// in some cases, the min and max rotational velocities can change.
    /// example: I'm an object moving very fast. My min/max change in rotation is -15/15 degrees, but my current value is 1 degree.
    /// I slow down, so my min/max change in rotation increases to -45/45.
    /// If I stop, my min/max change in rotation goes all the way up to -180/180 (instantaneous).
    float MaxRotationVelocity
    {
        get { return m_rotationVelocity; }
        set 
        {
            if (value < m_rotationSpeed)    //cap values to the max rotation speed
            {
                m_rotationVelocity = value;
            }
            else if (value > 0)             //cap values above zero
            {
                m_rotationVelocity = 0;
            }
            else
            {
                m_rotationVelocity = m_rotationSpeed;
            }
        }
    }

    bool IsStationary
    {
        get { return m_stationary; }
        set { m_stationary = value; }
    }

    OBB EnclosingBox
    {
        get
        {
            return m_OBB;
        }
        set
        {
            m_OBB = value;
        }
    }

    BoundingSphere EnclosingSphere
    {
        get
        {
            return m_boundingSphere;
        }
        set
        {
            m_boundingSphere = value;
        }
    }

    OBB HitBox
    {
        get
        {
            if (m_hitBox == null)
                return m_OBB;
            return m_hitBox;
        }
        set
        {
            m_hitBox = value;
        }
    }

    BoundingSphere HitSphere
    {
        get
        {
            if (m_hitSphere == null)
                return m_boundingSphere;
            return m_hitSphere;
        }
        set
        {
            m_hitSphere = value;
            m_hitSphereOffset = m_position - value.getPosition();
        }
    }

    Quaternion Orientation
    {
        get
        {
            return m_orientation;
        }
        set
        {
            m_orientation = value;
        }
    }

    //Range SpeedLimit
    //{
    //    get
    //    {
    //        return SpeedLimit;
    //    }
    //    set
    //    {
    //        SpeedLimit = value;
    //    }
    //}

    Vec3f Velocity
    {
        get
        {
            return m_velocity;
        }
        set
        {
            m_velocity = value;
        }
    }

    Vec3f Accelleration
    {
        get { return m_acceleration; }
        set 
        { 
            m_acceleration = value;
            if (m_acceleration.length() > m_topAccelleration)
            {
                m_acceleration.normalize();
                m_acceleration *= m_topAccelleration;
            }
        }
    }

    Vec3f GravityForce
    {
        get { return m_gravityForce; }
        set { m_gravityForce = value; }
    }

    
    /// This tells you how fast the object is moving on the velocity vector without using sqrt
    
    float SpeedSquared
    {
        get { return m_velocity.lengthSquared(); }
    }

    
    /// This tells you how fast the object is moving on the velocity vector
    
    float Speed
    {
        get { return m_velocity.length(); }
    }

    
    /// The current value is the current top speed of the object.
    /// <para>The MAX value is the fastest the object can move with any temporary boosts.</para>
    /// <para>The MIN value is the slowest maximum value the object can move. This should always be zero or greater.</para>
    /// <para>Values of -1,-1 are invalid and mean that the object has no top speed, so it can go as fast as you want.</para>
    /// <para>Example: A speedometers maximum value is 150mph. A car just physically cannot exceed this value.</para>
    
    float TopSpeed
    {
        get { return m_topSpeed; }
        set { m_topSpeed = value; }
    }

    
    /// Set/get the maximum speed an object is capable of traveling
    
    float MaxTopSpeed
    {
        get { return m_topSpeed; }
        set { m_topSpeed = value; }
    }

    
    /// This lets you change the maximum top speed.
    /// <para>Example: Changing the speedometer maximum range from 100mph to 150mph</para>
    
    /// <param name="value"></param>
    void SetMaxTopSpeed(float value, float currentTopSpeed)
    {
        m_topSpeed = value;
        m_topSpeed = currentTopSpeed;
    }

    
    /// A flag indicating if the object is a visible object. If the object is not visible, it will not be processed for drawing.
    
    int Visible
    {
        get { return m_visible; }
        set { m_visible = value; }
    }

    int CollidesWith
    {
        get { return m_colliders; }
        set { m_colliders = value; }
    }

    
    /// The mass of the object in Kilograms
    
    float Mass
    {
        get { return m_mass; }
        set { m_mass = value; }
    }

    
    /// tells you if a valid bounding area encloses the object. Doesn't indicate which kind though.        
    bool HasBounds
    {
        get
        {
            if (m_hitSphere == null && m_hitBox == null && m_OBB == null && m_boundingSphere == null)
                return false;
            else
            {
                //bounding objects exist, so let's return true if either of them are valid.
                return (m_hitSphere.Radius != 0 || m_hitBox.Min != m_hitBox.Max || m_boundingSphere.Radius != 0 || m_OBB.Min != m_OBB.Max);
            }
        }
    }

    //Effect Effect
    //{
    //    get { return m_effect; }
    //    set { m_effect = value; }
    //}
    
}