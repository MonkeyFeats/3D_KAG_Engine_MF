#define SERVER_ONLY

#include "TypeEnums.as"
#include "PhysicsEngine.as"
#include "AABB.as"

//const u16 numCollisionsToSave = 8;
const float minSize = 4.0f;// Minimum size that a node can be - essentially an alternative to having a max depth 

class OcTree 
{
    OcTree@ parentNode; // The parent node of this octree
    AABB region;   
    float treesize; 
    //PhysicalEntity@[] pendingInsertion; // This is a list of all objects waiting to be inserted.  
    PhysicalEntity@[] objects; // This is a list of all objects within the current node of the octree.      
    PhysicalEntity@[] deadObjects; // List of objects that died and need to be culled.
    OcTree@[] childNodes; // These are all of the possible child octants for this node in the tree.
    AABB@[] childBoxes;

    // This is a bit mask indicating which child nodes are actively being used.
    // It adds slightly more complexity, but is faster for performance since there is only one comparison instead of 8.
    u8 activeNodes = 0;//Byte

    // This is how many frames we'll wait before deleting an empty tree branch. 
    // The maximum lifespan doubles every time a node is reused, until it hits a hard coded constant of 64
    // Lifespan is to keep active nodes 'hot' because there is a good chance objects nearby will re-use it, saves building another branch
    u16 maxLifespan = 8;
    int curLife = -1; //this is how much time we have left    

    OcTree( float Size, Vec3f initialWorldPos, OcTree@ _parent = null) 
    {
        @parentNode = _parent;
        treesize = Size;
        region = AABB(Size, initialWorldPos, SColor(255,0,0,255));
        curLife = -1;
        //GenerateChildren(Size);
    }

    OcTree( AABB@ _region, PhysicalEntity@[] objList, OcTree@ _parent = null)
    {
        @parentNode = _parent;
        region = _region;
        objects = objList;
        curLife = -1;        
    }

    OcTree( AABB@ _region, OcTree@ _parent = null)
    {
        @parentNode = _parent;
        region = _region;
        curLife = -1;        
    }

    void GenerateChildren() // todo make it load over time to make it smoother, an alternative is to load and unload nodes at runtime, which most engines do..
    {
        if (treesize <= minSize) {return;}

        Vec3f offset = region.getPosition();        
        float half = treesize/2;

        childNodes.set_length(8);
        @childNodes[0] = OcTree(half, offset+Vec3f( half,half,-half), this);
        @childNodes[1] = OcTree(half, offset+Vec3f(-half,half,-half), this);
        @childNodes[2] = OcTree(half, offset+Vec3f(-half,half, half), this);
        @childNodes[3] = OcTree(half, offset+Vec3f( half,half, half), this);
        @childNodes[4] = OcTree(half, offset+Vec3f( half,-half,-half), this);
        @childNodes[5] = OcTree(half, offset+Vec3f(-half,-half,-half), this);
        @childNodes[6] = OcTree(half, offset+Vec3f(-half,-half, half), this);
        @childNodes[7] = OcTree(half, offset+Vec3f( half,-half, half), this);    

        //for (uint i = 0; i < childNodes.size(); i++)
        //childNodes[i].GenerateChildren();
    }

    OcTree@ CreateNode(AABB@ region, PhysicalEntity@[] objList)
    {
        if (objList.size() == 0) return null;
        OcTree@ ret = OcTree(region, objList);
        @ret.parentNode = this;
        return ret;
    }

    OcTree@ CreateNode(AABB@ region, PhysicalEntity@ Item)
    {
        OcTree@ oct = OcTree(@region, @this);
        oct.objects.push_back(Item);
        @oct.parentNode = this;
        return oct;
    }
    
    int TotalObjects {get{return engine.allObjects.size();}}
    bool IsRoot      {get{return this is engine.worldTree;}}
    bool hasActiveChildNodes 
    {
        get 
        {            
            return childNodes.size() > 0;
        }
    }

    void Render() 
    { 
        if (objects.size() > 0) 
        region.Render();

        for (int i = 0; i < childNodes.size(); i++)
        childNodes[i].Render();
    }

    void Update()
    {
        UpdateTree(this);
        PruneDeadBranches(this);
    }    

    void UpdateTree(OcTree@ currentNode)
    {        
        if (currentNode is null) { warn("OcTreeNode was null for some reason"); return; }    
        //go through and update every active node in the tree 

        //update any child nodes down the branch first
        if (currentNode.hasActiveChildNodes)
        {
            for (int index = 0; index < currentNode.childNodes.size(); index++)
            {
                //if (currentNode.Active)//is this an active child node?
                {
                   UpdateTree(currentNode.childNodes[index]);
                }                
            }
        }

        //Update & move all objects in the node
        PhysicalEntity@[] movedObjects; 
        for (int a = 0; a < currentNode.objects.size(); a++)
        {
            //we should figure out if an object actually moved so that we know whether we need to update this node in the tree.
            //if (currentNode.objects[a].getVelocity().length() > 0)
            if (movedObjects.find(currentNode.objects[a]) == -1)
                movedObjects.push_back(currentNode.objects[a]);
        }

        //If an object moved, we can insert it into the parent and that will insert it into the correct tree node.
        //note that we have to do this last so that we don't accidentally update the same object more than once per frame.       
        for(uint i = 0; i < currentNode.objects.size(); i++)
        {
            PhysicalEntity@ movedObj = currentNode.objects[i];
            currentNode.objects.removeAt(currentNode.objects.find(movedObj)); //remove it from the node it's in

            //figure out how far up the tree we need to go to reinsert our moved object,try to move the object into an enclosing parent node until we've got full containment
            OcTree@ current = currentNode;
            ContainmentType ct = current.region.Contains(movedObj.shape);
            while (ct != ContainmentType::Contains)
            {
                if (current !is engine.worldTree)
                {
                    @current = current.parentNode; //move up into the parent
                }
                else
                {
                    //the root region cannot contain the object, so we need to completely rebuild the whole tree.
                    //The rarity of this event is rare enough where we can afford to take all objects out of the existing tree and rebuild the entire thing.
                    //List<Physical> tmp = engine.worldTree.AllObjects();
                    //m_root.UnloadContent();
                    //Enqueue(tmp);//add to pending queue
                    warn("an object left the octree, this is bad");
                    return;
                }

                ct = current.region.Contains(movedObj.shape); //check if parent can contain it
            }

            current.Insert(movedObj); //insert it into the node we found 
        }
    }

    void PruneDeadBranches(OcTree@ currentNode)
    {
        //print("life "+currentNode.curLife+ " objs "+currentNode.objects.size()+ " chn "+currentNode.childNodes.size());
        if (currentNode.objects.size() == 0)           //node is empty
        {  
            if (!currentNode.hasActiveChildNodes)       //node is a leaf node with no objects
            {        
                if (currentNode.curLife == -1)        //node countdown timer is inactive
                {
                    currentNode.curLife = currentNode.maxLifespan; 
                }
                else if (currentNode.curLife > 0)    //node countdown time is active
                {
                    currentNode.curLife--;
                }           
            }
        }
        else 
        {
            if (currentNode.curLife != -1)            //node countdown timer is active and it now has objects!
            {
                if (currentNode.maxLifespan <= 64)    //double the max life of the timer and reset the timer
                    currentNode.maxLifespan *= 2;
                currentNode.curLife = -1;
            }             
        }

        //prune out any dead branches in the tree
        for (int index = 0; index < currentNode.childNodes.size(); index++)
        {
            if (currentNode.childNodes[index].curLife == 0) //has the death timer completed?
            {
                if (currentNode.childNodes[index].objects.size() > 0)
                {
                    /*If this happens, an object moved into our node and we didn't catch it. That means we have to do a conceptual rethink on this implementation.*/
                    warn("Tried to delete a used branch!");
                    //currentNode.childNodes[index].active = false;
                }
                else
                {
                    currentNode.childNodes.removeAt(index); //remove the node from the active nodes flag list     
                }
            }
        }
    }

    bool AddObjectToTree(PhysicalEntity@ object, OcTree@ node)
    {
        node.curLife = -1;
        if (node.objects.find(object) == -1)
        {
            node.objects.push_back(object);
            return true;
        }
        return false;
    }

    bool Insert(PhysicalEntity@ Item)
    {
        /*if the current node is an empty leaf node, just insert and leave it.*/
        //if (objects.size() == 0 && activeNodes == 0)
        if (engine.allObjects.size() == 0)
        {            
            return AddObjectToTree(Item, this);
        }

        //Check to see if the dimensions of the box are greater than the minimum dimensions.
        //If we're at the smallest size, just insert the item here. We can't go any lower!
        Vec3f dimensions = region.Max;
        if (dimensions.x <= minSize && dimensions.y <= minSize && dimensions.z <= minSize)
        {
            return AddObjectToTree(Item, this);
        }
        //The object won't fit into the current region, so it won't fit into any child regions.
        //therefore, try to push it up the tree. If we're at the root node, we need to resize the whole tree.
        if (region.Contains(Item.shape) < ContainmentType::Contains) // || objects.size() < 2
        {
            if (this.parentNode !is engine.worldTree)
            {
                return this.parentNode.Insert(Item);
            }
            else
            {
                return false;
            }
        }    

        if (region.Contains(Item.shape) == ContainmentType::Contains)
        {
            //At this point, we at least know this region can contain the object, but there are child nodes. Let's try to see if the object will fit
            //within a subregion of this region.   
            float half = region.Max.x/2;
            Vec3f center = region.getPosition(); 
            childBoxes.clear(); 
             childBoxes.set_length(8);
            @childBoxes[0] = AABB(half, center+Vec3f( half, half,-half), SColor(255,0,255,255));
            @childBoxes[1] = AABB(half, center+Vec3f(-half, half,-half), SColor(255,0,255,255));
            @childBoxes[2] = AABB(half, center+Vec3f(-half, half, half), SColor(255,0,255,255));
            @childBoxes[3] = AABB(half, center+Vec3f( half, half, half), SColor(255,0,255,255));
            @childBoxes[4] = AABB(half, center+Vec3f( half,-half,-half), SColor(255,0,255,255));
            @childBoxes[5] = AABB(half, center+Vec3f(-half,-half,-half), SColor(255,0,255,255));
            @childBoxes[6] = AABB(half, center+Vec3f(-half,-half, half), SColor(255,0,255,255));
            @childBoxes[7] = AABB(half, center+Vec3f( half,-half, half), SColor(255,0,255,255));
            //we will try to place the object into a child node. If we can't fit it in a child node, then we insert it into the current node object list.   
            bool found = false;         
            for(u8 a = 0; a < 8; a++)
            {
                //is the object fully contained within a quadrant?
                if (childBoxes[a].Contains(Item.shape) == ContainmentType::Contains)
                {
                        print("a "+a);
                    if (childNodes.size() >= a+1 && childNodes[a] !is null)
                    {
                        return childNodes[a].Insert(Item);   //Add the item into that tree and let the child tree figure out what to do with it
                    }
                    else
                    {
                        print("a "+a+" "+Item.Name);
                        OcTree@ newnode = CreateNode(childBoxes[a], Item);
                        childNodes.push_back(newnode);   
                        break;
                        //return AddObjectToTree(Item, newnode);
                    }
                    found = true;
                }
            }

            //we couldn't fit the item into a smaller box, so we'll have to insert it in this region            
            if (!found)
            {
                return AddObjectToTree(Item, this);
            }
            return true;
        }

        //either the item lies outside of the enclosed bounding box or it is intersecting it. Either way, we need to rebuild
        //the entire tree by enlarging the containing bounding box
        return false;
    }

    OcTree@ FindObjectInTree(PhysicalEntity@ myObject, OcTree@ currentNode)
    {
        int num = currentNode.objects.find(myObject);
        if (num > -1)
        {
            return currentNode;
        }
        else
        {
            //if (myObject.shape.Min != myObject.shape.Max) // is a box 
            {
                for (int a = 0; a < currentNode.childNodes.size(); a++)
                {
                    if (currentNode.childNodes[a].region.Contains(myObject.shape) == ContainmentType::Contains)
                    {
                        return FindContainingChildnode(myObject, currentNode.childNodes[a]);
                    }
                }
            }
            //else {} is a shpere

            //we couldn't fit the object into any child nodes and its not in the current node. There's only one last possibility:
            //the object is in a child node but has moved such that it intersects two bounding boxes. In that case, one of the child
            //nodes may still contain the object.
            OcTree@ result;
            if (FindObjectByBrute(myObject, currentNode, result))
            {
                return result;
            }
        }
        return null;
    }

    OcTree@ FindContainingChildnode(PhysicalEntity@ myObject, OcTree@ currentNode)
    {
        if (currentNode is null) {warn("current node was null"); return null;}

        //if (myObject.shape.Min != myObject.shape.Max)
        {
            for (int a = 0; a < currentNode.childNodes.size(); a++)
            {
                if (currentNode.childNodes[a].region.Contains(myObject.shape) == ContainmentType::Contains)
                {
                    if (currentNode.childNodes.size()!=0 && currentNode.childNodes[a] != null)
                        return FindContainingChildnode(myObject, currentNode.childNodes[a]);
                }
            }
        }

        //we couldn't fit the object into any child nodes and its not in the current node. There's only one last possibility:
        //the object is in a child node but has moved such that it intersects two bounding boxes. In that case, one of the child
        //nodes may still contain the object.
        return currentNode;
    }

    bool FindObjectByBrute(PhysicalEntity@ myObject, OcTree@ currentNode, OcTree@ &out returned)
    {
        if (currentNode.objects.find(myObject) > -1)
        {
            @returned = currentNode;
            return true;
        }
        else
        {
            if (currentNode.hasActiveChildNodes)
            {
                for (int a = 0; a < currentNode.childNodes.size(); a++)
                {
                    if (currentNode.childNodes[a] !is null)
                    {
                        if (FindObjectByBrute(myObject, currentNode.childNodes[a], returned))
                            return true;
                    }
                }
            }
            return false;
        }
        return false;
    } 

    // Inserts a bunch of items into the oct tree.
    void Enqueue(PhysicalEntity@[] ItemList)
    {
        for (int i = 0; i < ItemList.size(); i++)
        {
            PhysicalEntity@ Item = ItemList[i];
            //if (Item.HasBounds)
            {
                Enqueue(Item);
            }
            //else
            //{
            //    warn("Every object being inserted into the octTree must have a bounding region!");
            //}
        }
    }

    void Enqueue(PhysicalEntity@ Item)
    {
        //if (Item.HasBounds) //sanity check
        {
            //are we trying to add at the root node? If so, we can assume that the user doesn't know where in the tree it needs to go.
            if (@this is engine.worldTree)
            {
                AddObjectToTree(Item, this);
            }
            else
            {
                //the user is giving us a hint on where in the tree they think the object should go. Let's try to insert as close to the hint as possible.
                OcTree@ current = this;
                current.Insert(Item);
                print(""+Item.Name+ "Inserted into tree");
            }
        }
        //else
        //{
        //    warn("Every object being inserted into the octTree must have a bounding region!");
        //}
    }

//    PhysicalEntity@[] AllObjects(int type = PhysicalType::ALL)
//    {
//        //if (type == PhysicalType::ALL)
//        //    return allObjects;
//
//        PhysicalEntity@[] ret;
//
//        //you know... if you were smart, you'd maintain a list for each object type or at least sort the objects.
//        //then you could just merge lists together rather than going through each individual object and testing for a match.
//
//        for(int i = 0; i < allObjects.size(); i++)
//        {
//            PhysicalEntity@ p = allObjects[i];
//            ret.push_back(p);
//        }
//
//        return ret;
//    }
    
//    // Check if the specified AABB intersect with anything in the tree. See also: GetColliding.
//    bool IsColliding(AABB checkBounds) {
//        AddCollisionCheck(checkBounds);
//        return rootNode.IsColliding(checkBounds);
//    }
//    
//    // Check if the specified ray intersects with anything in the tree. See also: GetColliding.
//    bool IsColliding(BoundingShape checkRay, float maxDistance) {
//        return rootNode.IsColliding(checkRay, maxDistance);
//    }
//    
//    // Returns an array of objects that intersect with the specified bounds, if any. Otherwise returns an empty array. See also: IsColliding.
//    void GetColliding(PhysicalEntity[] collidingWith, AABB checkBounds) {
//        AddCollisionCheck(checkBounds);
//        rootNode.GetColliding(checkBounds, collidingWith);
//    }
//
//    
//    // Returns an array of objects that intersect with the specified ray, if any. Otherwise returns an empty array. See also: IsColliding.
//    void GetColliding(PhysicalEntity[] collidingWith, BoundingShape checkRay, float maxDistance = 9999999) {
//        rootNode.GetColliding(checkRay, collidingWith, maxDistance);
//    }

//   PhysicalEntity[] GetWithinFrustum(Camera cam) {
//       var planes = GeometryUtility.CalculateFrustumPlanes(cam);
//       PhysicalEntity[] list;
//       rootNode.GetWithinFrustum(planes, list);
//       return list;
//   }

//   OcTree@ CreateNode(AABB@ region, PhysicalEntity@[] objList)  //complete & tested
//   {
//       if (objList.size() == 0)
//           return null;
//       OcTree@ ret = OcTree(region, objList);
//       @ret.parentNode = this;
//       return ret;
//   }

//   OcTree@ CreateNode(AABB@ region, PhysicalEntity@ Item)
//   {
//       PhysicalEntity@[] objList; //sacrifice potential CPU time for a smaller memory footprint
//       objList.push_back(Item);
//       OcTree@ ret = OcTree(region, objList);
//       @ret.parentNode = this;
//       return ret;
//   }

    // Gives you a list of all objects within this branch and all of its children    
    PhysicalEntity@[] AllBranchObjects
    {  
        get
        {  
            PhysicalEntity@[] ret;
            if (objects.size() > 0)
            {
                ret = objects;
            }

            if (hasActiveChildNodes)
            {
                for (int i = 0; i < 8; i++)
                {
                    for (int j = 0; j < childNodes[i].AllBranchObjects.size(); j++)
                        ret.push_back(childNodes[i].AllBranchObjects[j]);
                }
            }
            
            return ret;
        }
    }
}