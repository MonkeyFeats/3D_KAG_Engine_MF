
//#define SERVER_ONLY

#include "PhysicalEntity.as"
#include "Human.as"
#include "OBB.as"

//void onInit(CRules@ this)
//{
//	
//}

Human@ CreatePhysicalEntity_WithBox(string Name, Vec3f Pos, Vec3f BoxMin, Vec3f BoxMax = -BoxMin, bool Static = false)
{			
	//RigidBody@ rigidbody = RigidBody();
	//BoundingShape@ shape = OBB(rigidbody, Vec3f(-3.3, 0.0, -3.3), Vec3f(3.3, 18.0, 3.3), Vec3f(200, 0, 200));
   	Human@ blob3d = Human(Vec3f(200, 16, 200), 0, 1.0f); 
	//@rigidbody.parent = blob3d;
	
	engine.allObjects.push_back(blob3d);
	engine.worldTree.Enqueue(blob3d);

	return blob3d;
}

//PhysicalEntity@ server_CreatePhysicalEntity(string Name, Vec3f Pos, bool Static = false)
//{			
//	BoundingShape@ shape = OBB( Vec3f(-1.3, -1.0, -1.3), Vec3f(1.3, 1.0, 1.3), Pos);
//	Mesh@ _Mesh = Mesh("cube.obj", "texMatrix.png");
//	PhysicalEntity@ blob3d = PhysicalEntity(Pos, 0, 1.0f, shape, _Mesh);
//
//
//	allObjects.push_back(blob3d);
//	Tree.Enqueue(blob3d);
//
//
//	return blob3d;
//}

