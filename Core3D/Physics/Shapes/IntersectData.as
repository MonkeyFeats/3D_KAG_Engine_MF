//IntersectionRecord stores information about an intersection that took place between 2 colliding shapes, helping us pass it along in a nice neat package

shared class IntersectionRecord
{   
    //Ray ray; //ray which caused the intersection
    private PhysicalEntity Object1; 
    private PhysicalEntity Object2;  
    private u8 intersectType;  
    private Vec3f[] hitPositions;     
    private Vec3f hitPosition;   
    private Vec3f dirNormal;
    private f32 distance;

    IntersectionRecord(const u8 _type, const Vec3f _direction, const Vec3f[] _positions, const f32 _dist)//, PhysicalEntity _object1, PhysicalEntity _object2)
    {
        //@Object1 = _object1; 
        //@Object2 = _object2;
    	intersectType = _type;    
 		hitPositions =  _positions;        
 		dirNormal =  _direction;
        distance = _dist;
    }
    IntersectionRecord(const PhysicalEntity@ _object1, const PhysicalEntity@ _object2, const u8 _type, const Vec3f _direction, const Vec3f[] _positions, const f32 _dist)//, PhysicalEntity _object1, PhysicalEntity _object2)
    {
        Object1 = _object1; 
        Object2 = _object2;
        intersectType = _type;
        hitPositions =  _positions;
        dirNormal =  _direction;
        distance = _dist;
    }
    
    bool GetDoesIntersect() const { return intersectType == 2; } //object 1 is intersecting object 2
    bool GetDoesContain() const { return intersectType == 1; } //object 1 is inside of object 2
    Vec3f GetHitPosition() {return hitPosition;} //the position of contact
    Vec3f[] GetHitPositions() {return hitPositions;} //the position of contact
    Vec3f GetDirection() { return dirNormal; } //the minimum translation (reflection) vector
    float GetDistance()  /*const*/ { return distance; }//the distance to translate
};

