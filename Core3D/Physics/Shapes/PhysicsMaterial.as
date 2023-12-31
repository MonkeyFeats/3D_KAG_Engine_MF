
shared class PhysicsMaterial
{
	f32 DynamicFriction = 0.6f; //The friction used when already moving. Usually a value from 0 to 1. A value of zero feels like ice, a value of 1 will make it come to rest very quickly unless a lot of force or gravity pushes the object.
	f32 StaticFriction = 0.6f; //The friction used when an object is laying still on a surface. Usually a value from 0 to 1. A value of zero feels like ice, a value of 1 will make it very hard to get the object moving.
	f32 Bounciness = 0.1f; //How bouncy is the surface? A value of 0 will not bounce. A value of 1 will bounce without any loss of energy, certain approximations are to be expected though that might add small amounts of energy to the simulation.

	u8 FrictionCombineMode = ComboMode::Average; // How the friction of two colliding objects is combined.
	u8 BounceCombineMode = ComboMode::Average; // How the bounce of two colliding objects is combined.
};

shared enum ComboMode
{
	Average = 0, //The two friction values are averaged.
	Minimum = 1, //The smallest of the two values is used.
	Maximum = 2, //The largest of the two values is used.
	Multiply = 3 //The friction values are multiplied with each other.
};