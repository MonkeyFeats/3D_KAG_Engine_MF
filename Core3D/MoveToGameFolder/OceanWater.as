
shared class OceanWater
{
    int CellSize = 16;
    float wavelength = 48.0f;
    float amplitude = 0.6f;
    float pi = Maths::Pi;
    float startDepth = -1.2f;

    SColor high = SColor(210,90,90,95);
    SColor mid = SColor(210,85,85,90);
    SColor low = SColor(210,70,80,85);

    Vertex[] water_Vertices;
    u16[] water_IDs;

    SMesh@ WaterMesh = SMesh();
    SMeshBuffer@ WaterMeshBuffer = SMeshBuffer();
    SMeshBuffer@ WaterMeshBuffer2 = SMeshBuffer();
    SMaterial@ WaterMat = SMaterial();
    SMaterial@ WaterMat2 = SMaterial();
    //Noise@ noise = Noise();

    f32[] test = {1,0,0,0,
                  0,1,0,0,
                  0,0,1,0,
                  0,0,0,1};

    Matrix4 mat4 = Matrix4();

    //AABBox3d box = AABBox3d();

    OceanWater()
    {
        //mat4.buildTextureTransform(0, Vec2f(0,0), Vec2f(0,0), Vec2f(1,1));

        CMap@ map = getMap();

        const int mapWidth = Maths::Round((map.tilemapwidth+CellSize)/CellSize);
        const int mapHeight = Maths::Round((map.tilemapheight+CellSize)/CellSize);

        water_Vertices.set_length((mapWidth+1)*(mapHeight+1));
        water_IDs.set_length( (mapWidth) * (mapHeight) * 6);

        uint v = 0;
        uint t = 0;
        for (uint y = 0; y <= mapHeight; y++) {
            for (uint x = 0; x <= mapWidth; x++) {      
                water_Vertices[v]= Vertex( y*CellSize*map.tilesize, 0.0, x*CellSize*map.tilesize, x*(CellSize/4), y*(CellSize/4), SColor(100,100,100,100));
                v++;
            }   
        }
        v = 0;
        for (uint y = 0; y < mapHeight; y++) {
            for (uint x = 0; x < mapWidth; x++) {       
                water_IDs[t] =   v;
                water_IDs[t+1] = water_IDs[t+3] = v+1;
                water_IDs[t+2] = water_IDs[t+4] = v+(mapWidth+1);
                water_IDs[t+5] = v+(mapWidth+1)+1;      
                v++;
                t+=6;
            }
            v++;
        }   

        WaterMat.SetTexture("Water.png", 0);
        WaterMat.SetTexture("Detail.png", 1);
        WaterMat.DisableAllFlags();
        WaterMat.SetFlag(SMaterial::ZBUFFER, true);
        WaterMat.SetFlag(SMaterial::ZWRITE_ENABLE, true);
        WaterMat.SetFlag(SMaterial::COLOR_MASK, true);

        //WaterMat2.SetTexture("NoGoZone.png", 0);
        //WaterMat2.DisableAllFlags();
        //WaterMat2.SetFlag(SMaterial::COLOR_MASK, true);
        //WaterMat2.SetFlag(SMaterial::ZBUFFER, true);
        //WaterMat2.SetFlag(SMaterial::ZWRITE_ENABLE, true);
        //WaterMat2.SetFlag(SMaterial::BACK_FACE_CULLING, false);
        //WaterMat2.MaterialType = SMaterial::TRANSPARENT_VERTEX_ALPHA;
        //WaterMat.SetFlag(SMaterial::ANTI_ALIASING, true);
        //WaterMat.SetFlag(SMaterial::ANISOTROPIC_FILTER, true);
        //WaterMat.SetLayerAnisotropicFilter(0, 8);

        //WaterMat.SetFlag(SMaterial::WIREFRAME, true);
        //WaterMat.SetFlag(SMaterial::POINTCLOUD, true);
        WaterMat.SetFlag(SMaterial::GOURAUD_SHADING, true);
        //WaterMat.SetFlag(SMaterial::LIGHTING, true);
        //WaterMat.SetFlag(SMaterial::ZBUFFER, true);
        //WaterMat.SetFlag(SMaterial::ZWRITE_ENABLE, true);
        //WaterMat.SetFlag(SMaterial::BACK_FACE_CULLING, true);
        //WaterMat.SetFlag(SMaterial::FRONT_FACE_CULLIN, true);
        //WaterMat.SetFlag(SMaterial::BILINEAR_FILTER, true);
        //WaterMat.SetFlag(SMaterial::TRILINER_FILTER, true);
        //WaterMat.SetFlag(SMaterial::ANISOTROPIC_FILTER, true);
        //WaterMat.SetFlag(SMaterial::FOG_ENABLE, true);
        //WaterMat.SetFlag(SMaterial::NORMALIZE_NORMALS, true);
        //WaterMat.SetFlag(SMaterial::TEXTURE_WRAP, true);
        //WaterMat.SetFlag(SMaterial::ANTI_ALIASING, true);
        //WaterMat.SetFlag(SMaterial::COLOR_MATERIAL, true);
        //WaterMat.SetFlag(SMaterial::USE_MIP_MAPS, true);
        //WaterMat.SetFlag(SMaterial::BLEND_OPERATION, true);
        //WaterMat.SetFlag(SMaterial::POLYGON_OFFSET, true);

        //WaterMat.AmbientColor = SColor(255,120,0,5);
        //WaterMat.DiffuseColor = SColor(255,255,0,255);
        //WaterMat.EmissiveColor = SColor(255,0,255,0);
        //WaterMat.SpecularColor = SColor(255,255,255,0);
        //WaterMat.Shininess = 0.6;
        //WaterMat.SetColorMaterial(SMaterial::NONE);
        //WaterMat.SetColorMask(SMaterial::BLUE);

        //WaterMat.SetTextureMatrix(0, mat4);

        //WaterMat.MaterialTypeParam = 5.0f;
        //WaterMat.MaterialTypeParam2 = 1.2f;

        WaterMat.MaterialType = SMaterial::TRANSPARENT_VERTEX_ALPHA;
        //WaterMat2.MaterialType = SMaterial::TRANSPARENT_VERTEX_ALPHA;
        //WaterMat.SetFlag(SMaterial::GOURAUD_SHADING, true);

        //WaterMat.Thickness = 4.0f;
        //WaterMat.AmbientColor = SColor(255,255,0,0);
        //WaterMat.SetFlag(SMaterial::WIREFRAME, true);
        //WaterMat.MaterialTypeParam = 2.0f;

        //mat4.SetArray(test);
        //mat4.buildTextureTransform(1.7, Vec2f(0,1), Vec2f(1,1), Vec2f(10,10));

        //WaterMat.SetPolygonOffsetFactor(255);

        WaterMeshBuffer.SetMaterial(WaterMat);

        WaterMeshBuffer.SetHardwareMappingHint(Driver::DYNAMIC, Driver::VERTEX_INDEX);
        WaterMeshBuffer.SetVertices(water_Vertices);
        WaterMeshBuffer.SetIndices(water_IDs); 
        WaterMeshBuffer.RecalculateBoundingBox();
        WaterMeshBuffer.SetDirty(Driver::VERTEX_INDEX);
        WaterMeshBuffer.SetHardwareMappingHint(Driver::DYNAMIC, Driver::VERTEX);
        WaterMesh.AddMeshBuffer( WaterMeshBuffer );

        //WaterMeshBuffer2.SetMaterial(WaterMat2);
        //WaterMeshBuffer2.SetHardwareMappingHint(Driver::DYNAMIC, Driver::VERTEX_INDEX);
        //WaterMeshBuffer2.SetVertices(water_Vertices);
        //WaterMeshBuffer2.SetIndices(water_IDs); 
        //WaterMeshBuffer2.SetDirty(Driver::VERTEX_INDEX);
        //WaterMeshBuffer2.SetHardwareMappingHint(Driver::DYNAMIC, Driver::VERTEX);
        //WaterMesh.AddMeshBuffer( WaterMeshBuffer2 );
    }

    void Update()
    {
        float time = getGameTime()/5.0;

         //   

        mat4.setTextureTranslate(time, time);

        if (getGameTime() == 300)
        {            
            
            //WaterMeshBuffer.Drop();

           //WaterMat = WaterMat2;

           //AABBox3d box = WaterMeshBuffer.getBoundingBox();
            //WaterMeshBuffer.Drop();

           //WaterMat = WaterMat2;
           //WaterMesh.SetBoundingBox(box);
           
          // print("icount "+WaterMesh.getMeshBuffer(0).getVertexCount());
          // print("icount2 "+WaterMesh.getMeshBuffer(WaterMat).getVertexCount());
           //print("i3pos "+WaterMeshBuffer.getPosition(0).x);
            //print("trans "+WaterMat.isTransparent());
            //WaterMesh.Clear();
            //WaterMesh.Drop();
        }

        //ye = getGameTime()%255;
        //WaterMat.SetPolygonOffsetFactor(ye);
       //if (time % 10 == 0)
       //{
       //    ye++;
       //    if (ye == 8) ye = 0;
       //    switch (ye)
       //    {
       //        case 0:  WaterMat.ZBuffer =  SMaterial::NEVER;
       //        case 1:  WaterMat.ZBuffer =  SMaterial::LESSEQUAL;
       //        case 2:  WaterMat.ZBuffer =  SMaterial::EQUAL;
       //        case 3:  WaterMat.ZBuffer =  SMaterial::LESS;
       //        case 4:  WaterMat.ZBuffer =  SMaterial::NOTEQUAL;
       //        case 5:  WaterMat.ZBuffer =  SMaterial::GREATEREQUAL;
       //        case 6:  WaterMat.ZBuffer =  SMaterial::GREATER;
       //        case 7:  WaterMat.ZBuffer =  SMaterial::ALWAYS;
       //    }
       //    
       //    WaterMeshBuffer.SetMaterial(WaterMat);
       //    print(""+ye);
       //}

       if (WaterMesh is null) return;

        for (uint i = 0; i < water_Vertices.length; i++)
        {
            f32 h1 =  (-amplitude*Maths::Sin(pi*2.0f*(i+time)/wavelength))*16;
            water_Vertices[i].y = (startDepth*16)+h1;
            water_Vertices[i].col = low.getInterpolated_quadratic(mid,high, h1/amplitude);
        }

        WaterMeshBuffer.SetVertices(water_Vertices);
        WaterMeshBuffer.SetDirty(Driver::VERTEX);
    }

    void Render()
    {        
        //Matrix::MakeIdentity(model);
        //f32[] test; WaterMat.getTextureMatrix(1).getArray(test);  
        //if (getGameTime() > 300)      
        //Render::SetModelTransform(test);
        if (WaterMesh !is null)
        WaterMesh.DrawWithMaterial(); 
    }
    
}

int ye = 0;
