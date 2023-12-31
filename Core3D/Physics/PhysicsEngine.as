#include "IntersectData.as"

PhysicsEngine@ engine = PhysicsEngine();

class PhysicsEngine
{
	//int PhysicsStep = 0;

    OcTree@ worldTree = OcTree(512, Vec3f(256,250,256));  //The main root node of the octree
    PhysicalEntity@[] allObjects;
    IntersectionRecord@[] contactPairs;

    PhysicsEngine(){}

    void addEntities(PhysicalEntity@[] entities)
    {
    	for(uint i = 0; i < entities.size(); i++)
		{
			PhysicalEntity@ entity = entities[i];			
			allObjects.push_back(entity);				
		}
		worldTree.Enqueue(entities); 
    }

    void addEntity(PhysicalEntity@ entity)
    {	
		allObjects.push_back(entity);	
		worldTree.Enqueue(entity); 
    }

	void Update()
	{
		float time = getGameTime();
		if (time == 60)
	 	{
	 		CPlayer@ p = getLocalPlayer();
	 		PhysicalEntity@ pb3d;
			if (p.get("playerPhysicalEntity", @pb3d))
			addEntity(pb3d);
	 	}

	 	//if (getControls().isKeyJustPressed(KEY_RBUTTON))
	 	//{
	 		PhysUpdate();
	 	//}
	}

	void PhysUpdate()
	{
		ComputeResolutionPhase();

		for (uint i = 0; i < allObjects.size(); i++)
		allObjects[i].Update();

		worldTree.Update();
	}

	//TODO:  broad phase > narrow phase > and resolution phase.
	void ComputeBroadPhase(){} // fast detection for possible/likely collsions using aabb's & bounding_spheres, (Octree detection)
	void ComputeNarrowPhase(){} // obtains the collision pair list and for every pair, using their actual geometry, it checks whether the two partners are colliding.
	//void ComputeResolutionPhase(){} // computes forces according to the result of the narrow phase for pushing penetrating objects apart at every contact point. Because an object might collide with several others, appropriate handling of multiple contacts has to be done.

	void ComputeResolutionPhase()
	{
		for(uint i = 0; i < allObjects.size(); i++)
		{			
			PhysicalEntity@ Object1 = allObjects[i];
			if ( Object1.isStatic() || Object1.shape is null) continue;
			for(uint j = 0; j < allObjects.size(); j++)
			{
				if (i == j) continue;
				PhysicalEntity@ Object2 = allObjects[j];

				IntersectionRecord intersectData = Object1.Intersect(Object2);
				if(intersectData.GetDoesIntersect())
				{
					Vec3f direction = intersectData.GetDirection(); 
					Vec3f dirNorm = intersectData.GetDirection(); dirNorm.normalize();
            		
					if ( Object2.isStatic() )
        		    {
        		    	Vec3f impulse = dirNorm*intersectData.GetDistance();
						Object1.transform.addPosition(direction*intersectData.GetDistance());
						Object1.SetVelocity(Object1.GetVelocity().reflect(dirNorm));
						//Object1.rigidbody.addAngularVelocity(moment);
					}
					else
					{
						Vec3f impulse = (direction*intersectData.GetDistance())/2;
        		    		Object1.transform.addPosition(impulse );
        		    	Vec3f Vel = (Object1.GetVelocity());
        		    	if (Vel.length() < 0.1) continue;
						//Object1.SetVelocity(Vel.reflect(dirNorm));
						Vec3f[] pos = intersectData.GetHitPositions();

						Vec3f relativeVel = Object2.GetVelocity() - Object1.GetVelocity();
						Vec3f t = relativeVel - (dirNorm * Dot(relativeVel, dirNorm));

						//if (Dot(Object1.GetVelocity(), dirNorm) > 0.0f) { continue; }

						float e = 0.2;//min(A.elasticityCo, B.elasticityCo);
						float numerator = (-(1.0f + e) * Dot(relativeVel, dirNorm));
						float d1 = -1.0;//invMassSum;


						Vec3f angimp;
						Vec3f tangentImpuse;

						for (int i = 0; i < pos.size(); i++)
						{

							Vec3f r1 = pos[i] - Object1.transform.getPosition();
							Vec3f r2 = pos[i] - Object2.transform.getPosition();

							Vec3f d2 = Cross(Cross(r1, dirNorm), r1);
							Vec3f d3 = Cross(Cross(r2, dirNorm), r2);
							float denominator = d1 + Dot(dirNorm, d2 );

							float jt = (denominator == 0.0f) ? 0.0f : numerator / denominator;
							if (pos.size() > 0.0f && jt != 0.0f) {
								jt /= pos.size();
							}

							jt = jt > 0 ? 1 : jt < 0 ? -1 : 0;

							float friction = 0.1f; //Maths:Sqrt(obj1.fric * obj2.fric);
							jt = Maths::Clamp(-jt * friction, jt * friction, jt);
							tangentImpuse += t * -jt;


							Vec3f p = r1-Object1.transform.getPosition();
							Object1.SetVelocity(tangentImpuse);
							//angimp = Cross(r1, tangentImpuse)*0.12;
							Object1.rigidbody.addForceAtLocalPosition(r1, tangentImpuse);
						}
							//print("angimp "+angimp);
							//Object1.rigidbody.addAngularVelocity(angimp);
							//Object2.rigidbody.addAngularVelocity(-angimp);

						//Vec3f moment = Cross((Object1.transform.getPosition() - intersectData.GetHitPositions()), impulse);
						//moment *= 0.5;
						//moment.normalize();
						//print(""+(Object1.transform.getPosition() - intersectData.GetHitPositions()));
						//Object1.rigidbody.addAngularVelocity(moment);


        		    	//allObjects[j].transform.addPosition(otherDirection/2);
						//allObjects[j].SetVelocity(Vec3f((allObjects[j].GetVelocity()).reflect(otherDirection/2)));

					}
				}
			}
		}
	}
/*
	void ResolveCollisions(  )
	{
		for(uint i = 0; i < allObjects.size(); i++)
		{			
			if ( allObjects[i].isStatic() ) continue;
			for(uint j = 0; j < allObjects.size(); j++)
			{
				if ( i == j) continue;

				IntersectionRecord intersectData = allObjects[i].Intersect(allObjects[j]);
				if(intersectData.GetDoesIntersect())
				{

				    rigid_body &Body = aBodies[CollidingBodyIndex];
				    rigid_body::configuration &Configuration = Body.aConfigurations[ConfigurationIndex];
				    
				    Vec3f Position = Configuration.aBoundingVertices[CollidingCornerIndex];
				    
				    Vec3f R = Position - Configuration.CMPosition;

				    Vec3f Velocity = Configuration.CMVelocity + CrossProd(Configuration.AngularVelocity,R);
				    
				    float ImpulseNumerator = -(r(1) + Body.CoefficientOfRestitution) * DotProd(Velocity,CollisionNormal);

				    float ImpulseDenominator = Body.OneOverMass + DotProd(CrossProd(Configuration.InverseWorldInertiaTensor * CrossProd(R,CollisionNormal),R), CollisionNormal);
				    
				    Vec3f Impulse = (ImpulseNumerator/ImpulseDenominator) * CollisionNormal;
				    
				    // apply impulse to primary quantities
				    allObjects[i].AddVelocity(Mass * Impulse);
				    Configuration.AngularMomentum += CrossProd(R,Impulse);
				    
				    // compute affected auxiliary quantities
				    Configuration.AngularVelocity = Configuration.InverseWorldInertiaTensor * Configuration.AngularMomentum;

			    }
			}
		}
	}
	*/
};

    Vec3f CrossProd(Vec3f vec1, Vec3f vec2)
    {
        return Vec3f(vec1.y * vec2.z - vec2.y * vec1.z,
                    (vec1.x * vec2.z - vec2.x * vec1.z),
                     vec1.x * vec2.y - vec2.x * vec1.y);
    }

/*
// Solve the contacts
void ContactSolverSystem::solve() {

    double deltaLambda;
    double lambdaTemp;
    uint contactPointIndex = 0;

    const double beta = mIsSplitImpulseActive ? BETA_SPLIT_IMPULSE : BETA;

    // For each contact manifold
    for (uint c=0; c<mNbContactManifolds; c++) {

        double sumPenetrationImpulse = 0.0;

        // Get the constrained velocities
        const Vec3f v1 = b1.mConstrainedLinearVelocities;
        const Vec3f w1 = b1.mConstrainedAngularVelocities;
        const Vec3f v2 = b2.mConstrainedLinearVelocities;
        const Vec3f w2 = b2.mConstrainedAngularVelocities;

        for (short int i=0; i<mContactConstraints[c].nbContacts; i++) 
        {
            // --------- Penetration --------- //

            // Compute J*v
            //Vec3f deltaV = v2 + w2.cross(mContactPoints[contactPointIndex].r2) - v1 - w1.cross(mContactPoints[contactPointIndex].r1);
            Vec3f deltaV(v2.x + w2.y * mContactPoints[contactPointIndex].r2.z - w2.z * mContactPoints[contactPointIndex].r2.y - v1.x -
                           w1.y * mContactPoints[contactPointIndex].r1.z + w1.z * mContactPoints[contactPointIndex].r1.y,
                           v2.y + w2.z * mContactPoints[contactPointIndex].r2.x - w2.x * mContactPoints[contactPointIndex].r2.z - v1.y -
                           w1.z * mContactPoints[contactPointIndex].r1.x + w1.x * mContactPoints[contactPointIndex].r1.z,
                           v2.z + w2.x * mContactPoints[contactPointIndex].r2.y - w2.y * mContactPoints[contactPointIndex].r2.x - v1.z -
                           w1.x * mContactPoints[contactPointIndex].r1.y + w1.y * mContactPoints[contactPointIndex].r1.x);

            double deltaVDotN = deltaV.x * mContactPoints[contactPointIndex].normal.x + deltaV.y * mContactPoints[contactPointIndex].normal.y + deltaV.z * mContactPoints[contactPointIndex].normal.z;
            double Jv = deltaVDotN;

            // Compute the bias "b" of the constraint
            double biasPenetrationDepth = 0.0f;
            if (mContactPoints[contactPointIndex].penetrationDepth > SLOP) 
            {
                biasPenetrationDepth = -(beta/mTimeStep) * max(0.0f, float(mContactPoints[contactPointIndex].penetrationDepth - SLOP));
            }
            double b = biasPenetrationDepth + mContactPoints[contactPointIndex].restitutionBias;

            // Compute the Lagrange multiplier lambda
            if (mIsSplitImpulseActive) 
            {
                deltaLambda = - (Jv + mContactPoints[contactPointIndex].restitutionBias) * mContactPoints[contactPointIndex].inversePenetrationMass;
            }
            else 
            {
                deltaLambda = - (Jv + b) * mContactPoints[contactPointIndex].inversePenetrationMass;
            }
            lambdaTemp = mContactPoints[contactPointIndex].penetrationImpulse;
            mContactPoints[contactPointIndex].penetrationImpulse = std::max(mContactPoints[contactPointIndex].penetrationImpulse + deltaLambda, 0.0f);
            deltaLambda = mContactPoints[contactPointIndex].penetrationImpulse - lambdaTemp;

            Vec3f linearImpulse(mContactPoints[contactPointIndex].normal * deltaLambda);

            // Update the velocities of the body 1 by applying the impulse P
            b1.mConstrainedLinearVelocities -= mContactConstraints[c].massInverseBody1 * linearImpulse;
            b1.mConstrainedAngularVelocities -= mContactPoints[contactPointIndex].i1TimesR1CrossN * deltaLambda;

            // Update the velocities of the body 2 by applying the impulse P
            b2.mConstrainedLinearVelocities += mContactConstraints[c].massInverseBody2 * linearImpulse;
            b2.mConstrainedAngularVelocities += mContactPoints[contactPointIndex].i2TimesR2CrossN * deltaLambda;

            sumPenetrationImpulse += mContactPoints[contactPointIndex].penetrationImpulse; 
        }           
    }
}