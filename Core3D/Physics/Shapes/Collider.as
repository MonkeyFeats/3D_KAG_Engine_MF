#include "IntersectData.as";

class Collider //: ReferenceCounter
{
	//all the types of colliders that can be used.
	enum
	{
		TYPE_SPHERE,
		TYPE_AABB,
		TYPE_OBB,
		//TYPE_CYLINDER,
		//TYPE_CAPSULE,
		//TYPE_CONE,
		//TYPE_MESH,
		TYPE_SIZE
	};

	private int type; // The type of collider this represents.

	Collider(int type){}; //Constructor	
	
	IntersectData Intersect(const Collider other) const; //Calculates information about if this collider is intersecting with  another collider.
	
	void Transform(const Vec3f translation) {} //Moves the entire collider by translation distance. Should be overridenby subclasses.
	
	Vec3f GetCenter() const { return Vec3f(0,0,0); } //Returns the center position of the collider. Should be overriden by subclasses.
	
	int GetType() const { return type; }
};