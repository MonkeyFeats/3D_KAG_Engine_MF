shared enum ContainmentType
{
	None = 0,
    Contains, //fully contains another object
    Intersects // partially contains another object
}

shared enum PlaneIntersectionType //unused
{
	None = 0,
    Front, //side
    Back, //side
    Intersecting //between sides
}

shared enum CameraProjectionType
{
    Perspective = 0,
    Orthographic
}

shared enum PhysicalType
{
    Nothing = 0,
    Pawn = 1,           //pawns are ...something
    Terrain = 2,        //the ground!
    Character = 4,      //characters are creatures of some sort
    Actor = 8,          //actors are objects which can be interacted with
    Item = 16,          //pick up items
    Projectile = 32,    //arrows, flying rocks, etc
    Ethereal = 64,      //stuff can go through this, not affected by most forces such as gravity
    Building = 128,     //houses, gates, walls, etc.
    Obstacle = 256,     //trees, rocks, and other static impassables
    SOLID = Nothing | Pawn | Terrain | Character | Actor | Item | Projectile | Building | Obstacle,
    ALL = 511
};

shared enum Visibility
{
    NoDraw = 1,             //The object is never drawn
    Visible = 2,            //the object is completely visible, so it is drawn
    Invisible = 4           //the object is invisible, but needs to be drawn to represent an invisible object  (ie, an outline)
};