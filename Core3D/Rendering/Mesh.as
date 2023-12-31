#include "Component.as"

enum EMF_Flags
{
    EMFZBUFFER = 0,
    WIREFRAME,
    POINTCLOUD,
    GOURAUD_SHADING,
    LIGHTING,
    ZBUFFER,
    ZWRITE_ENABLE,
    BACK_FACE_CULLING,
    FRONT_FACE_CULLING,
    BILINEAR_FILTER,
    TRILINER_FILTER,
    ANISOTROPIC_FILTER,
    FOG_ENABLE,
    NORMALIZE_NORMALS,
    TEXTURE_WRAP,
    ANTI_ALIASING,
    COLOR_MASK,
    COLOR_MATERIAL,
    USE_MIP_MAPS,
    BLEND_OPERATION,
    POLYGON_OFFSET
};

shared class Mesh
{    
    Entity@ parent;
    SMesh@ mesh = SMesh();
    SMeshBuffer@ meshBuffer = SMeshBuffer();
    SMaterial@ meshMaterial = SMaterial();
    string texture = "texMatrix.png";    
    Matrix4 model = Matrix4();
    Vec3f scale = Vec3f(1,1,1);

    Mesh(){}

    Mesh(Entity@ _owner, string _objName)
    {
        @parent = _owner;
        LoadObjIntoMesh(_objName);
        model.makeIdentity();
    }

    Mesh(Entity@ _owner, string _objName, string _texturName)
    {
         @parent = _owner;
        LoadObjIntoMesh(_objName);
        meshMaterial.SetTexture(_texturName, 0);
        model.makeIdentity();
    }

    Mesh(string _objName, string _texturName) //todo: remove this and make all meshes require an entity/parent, for the transform
    {
        LoadObjIntoMesh(_objName);
        meshMaterial.SetTexture(_texturName, 0);
        model.makeIdentity();
    }

    Mesh(Entity@ _owner, Vertex[] _vertices, u16[] _vertIDs, string _texturName = "", SMaterial::EMT _matType = SMaterial::SOLID)
    {        
         @parent = _owner;
        meshBuffer.SetVertices(_vertices);
        meshBuffer.SetIndices(_vertIDs); 
        //meshBuffer.RecalculateBoundingBox();
        meshBuffer.SetDirty(Driver::VERTEX_INDEX);

        mesh.AddMeshBuffer( meshBuffer );
        meshMaterial.SetTexture(_texturName, 0);
        setDefaultMaterialFlags();
        meshMaterial.MaterialType = _matType;
        meshBuffer.SetMaterial(meshMaterial);
        model.makeIdentity();

    }

    void setScale(Vec3f _scale) {scale = _scale; }
    void setOwner(Entity@ _owner) { @parent = _owner;}

    void LoadObjIntoMesh(string objname)
    {
        @mesh = SMesh::loadObjIntoMesh(objname);
        @meshBuffer = mesh.getMeshBuffer(0);
        @meshMaterial = meshBuffer.getMaterial();
        setDefaultMaterialFlags();
    }

    void setDefaultMaterialFlags()
    {
        meshMaterial.DisableAllFlags();
        meshMaterial.SetFlag(SMaterial::COLOR_MASK, true);
        meshMaterial.SetFlag(SMaterial::ZBUFFER, true);
        meshMaterial.SetFlag(SMaterial::ZWRITE_ENABLE, true);
        meshMaterial.SetFlag(SMaterial::BACK_FACE_CULLING, true);
    }
    
    //example:
    //SMaterial::EMF[] trueflags = {
    //    SMaterial::ZBUFFER,
    //    SMaterial::ZWRITE_ENABLE,
    //    SMaterial::COLOR_MASK
    //}; 
    //setMaterialFlags(trueflags, true);
    
    void setMaterialFlags(SMaterial::EMF[] flags, bool value)
    {   
        for (uint i = 0; i < flags.size(); i++)
        {
            meshMaterial.SetFlag(flags[i], value);            
        }
    }    

    void setMatFlag(SMaterial::EMF flag, bool value)
    {
       meshMaterial.SetFlag(flag, value);  
    }

    void MaterialSetDirty() //updates material values and flags, call this after changinging everthing you want
    {
       meshBuffer.SetMaterial(meshMaterial);        
    }

    void Render(bool translates = true, bool rotates = true)
    {   
        if (parent !is null)
        {     
            if (translates)
            model.setTranslation(parent.transform.getPosition());
            if (rotates)
            model.setRotationDegrees(parent.transform.getRotation());     
        }

        //model.setScale(scale);
        f32[] Array; model.getArray(Array);
        Render::SetModelTransform(Array);
        mesh.DrawWithMaterial();
    }

    //void RenderBlob(Entity@ owner)
    //{
    //    Matrix4 model = Matrix4();
    //    model.makeIdentity();
    //    model.setTranslation(parent.transform.getPosition());
    //    model.setRotationDegrees(parent.transform.getRotation());
    //    //model.setScale(owner.transform.getScale());
    //    f32[] Array; model.getArray(Array);
    //    Render::SetModelTransform(Array);
    //    mesh.DrawWithMaterial();
    //}
}