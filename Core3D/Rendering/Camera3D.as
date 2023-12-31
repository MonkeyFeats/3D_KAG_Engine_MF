#include "Ray.as"
#include "Plane.as"
#include "PhysicalEntity.as"
#include "Transform.as"

shared class Camera3D : Entity
{
	//u16 ownerPlayerID
	Matrix4 worldMatrix = Matrix4();
	Matrix4 viewMatrix = Matrix4();
	Matrix4 projMatrix = Matrix4();

	Quaternion q = Quaternion(1,1,1,1);
	Vec3f nd;
	//BoundingFrustum frustum;	

	float fov;
	float z_near;
	float z_far;

	PhysicalEntity@ targetBlob;
	float mouseSensitivity;
	float posLag;
	bool locked;
	
	Vec3f pos_offset;

	float rotationAngle;
	float elevationAngle = 90;
	Vec3f aimVec;
	
	Camera3D()
	{
		//pos_offset = Vec3f(0, 24, 20);
		pos_offset = Vec3f(0, 24, 0);

		worldMatrix.makeIdentity();
		viewMatrix.makeIdentity();
		projMatrix.makeIdentity();
		
		fov = 1.745329f;
		z_near = 0.3f;
		z_far = 1000000.0f;
		f64 AspectRatio = f64(getDriver().getScreenWidth()) / f64(getDriver().getScreenHeight());
		projMatrix.buildProjectionMatrixPerspectiveFovLH(fov, AspectRatio, z_near, z_far);

	}

	PhysicalEntity@ getTarget() {return @this.targetBlob;}
	void setTarget(PhysicalEntity@ _blob) {@this.targetBlob = _blob; }
	void setLocked(bool _locked) {this.locked = _locked;}

	void onTick() {}
	
	void render_update()
	{
		updateViewMatrix();
	}
	
	void updateViewMatrix()
	{
		//if (this.targetBlob !is null)//3rd person
		{			
			//viewMatrix.SetRotationCenter(this.transform.getPosition()+Vec3f(0,22,0), this.transform.getPosition()+Vec3f(0,22,0));
			//viewMatrix.setRotationDegrees(this.transform.getRotation());
			//viewMatrix.setInverseTranslation(this.transform.getPosition()+Vec3f(0,16,0));
		}
		if (this.targetBlob !is null) // should be isMe!
		{	
			//first person
			rotationAngle = rotationAngle % 360;
			elevationAngle = Maths::Clamp(elevationAngle, -90.0, 90.0); // Restrict elevation angle within -90 to 90 degrees

			float radians = Maths::Pi / 180.0f;
			float rotRad = rotationAngle * radians;
			float elevRad = elevationAngle * radians;

			float xlookat = Maths::Cos(rotRad) * -Maths::Cos(elevRad);
			float ylookat = Maths::Sin(elevRad);
			float zlookat = Maths::Sin(rotRad) * -Maths::Cos(elevRad);

			this.transform.setRotation(xlookat, ylookat, zlookat);

			Vec3f lookAtDirection = Vec3f(xlookat, ylookat, zlookat);
			Vec3f cameraPosition = targetBlob.transform.getPosition() + pos_offset;
			viewMatrix.buildCameraLookAtMatrixLH(cameraPosition, cameraPosition + this.transform.getRotation(), Vec3f(0, 1, 0));

			//viewMatrix.buildCameraLookAtMatrixLH(this.transform.getPosition()+pos_offset, this.transform.getPosition()+pos_offset+this.transform.getRotation(), Vec3f(0,1,0));
		}	
	}
}