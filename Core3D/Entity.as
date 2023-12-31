//Entity "GameObject", is the main class in the engine, every other object class is a child of it in some way, basically an empty object that holds everthing in one place

#include "Component.as"

shared class Entity  
{       
    u16 netID;
    string Name = "";
    bool static = true;
    RigidTransform@ transform = RigidTransform(Vec3f(), Vec3f(), Vec3f(1,1,1));

    Entity@ parent;
    Entity@[] children;
    //EntityComponent@[] components; //stuff that
    //dictionary componentDictionary;
    dictionary propertyDictionary;

    // constructors //
    Entity() {}
    Entity(string _name = "", bool _static = true, Vec3f _pos = Vec3f(), Vec3f _rot = Vec3f(), Vec3f _scale = Vec3f(1,1,1))
    {        
        Name = _name;
        static = _static;
        @transform = RigidTransform(_pos, _rot, _scale); // every entity requires a transform
    }

    // methods //
    void set_string(string to_change, string _in) { propertyDictionary.set(to_change, _in); }
    string get_string(string to_get)
    {
        string _got;
        if (propertyDictionary.get(to_get, _got))
        return _got;
        //warn("tried to get a no existant entity 'string' property");
        return "";
    }

    void set_u32(string to_change, u32 _in) { propertyDictionary.set(to_change, _in); }
    u32 get_u32(string to_get)
    {
        u32 _got;
        if (propertyDictionary.get(to_get, _got))
        return _got;
        //warn("tried to get a no existant entity 'u32' property");
        return -1;
    }

    //unused, just a reminder i might want to make a shapes, rigidbody, mesh, etc a component class and this might be the way to do it
    void set_Component(string to_change, EntityComponent _in) { propertyDictionary.set(to_change, _in); }
    EntityComponent@ get_Component(string to_get)
    {
        EntityComponent _got;
        if (propertyDictionary.get(to_get, _got))
        return _got;
        //warn("tried to get a no existant entity 'EntityComponent' property");
        return null;
    }

    void Update(float delta) {};

    void AddChildEntity(Entity _child) { _child.parent = this; children.push_back(_child); }
    Entity@ GetParent() { return parent; }  
    Entity@[] GetChildren() { return children; }  
    bool isStatic() {return static;}
    void setStatic(bool _static) {static = _static;}
    
    bool opEquals(const Entity other) { return this == other; }
    bool opNotEquals(const Entity other) { return this != other; }
}