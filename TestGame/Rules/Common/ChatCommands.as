// Simple chat processing example.
// If the player sends a command, the server does what the command says.
// You can also modify the chat message before it is sent to clients by modifying text_out
// By the way, in case you couldn't tell, "mat" stands for "material(s)"
#include "PhysicalEntity.as";
#include "Server.as";

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (player is null) return true;

	PhysicalEntity@ b;
	if (!player.get("playerPhysicalEntity", @b)) return true;
	//PhysicalEntity@ blob; if (!b.get("blob",@blob)) return true;

	int team = 0;
	Vec3f pos = b.transform.getPosition();
	{
		if (text_in == "!human")
		{
			CreatePhysicalEntity_WithBox("human", pos+Vec3f(0,0,16), Vec3f(-2,-2,-2), Vec3f(2,2,2), false);
		}
		else 
		if (text_in.substr(0, 1) == "!")
		{
			// otherwise, try to spawn an actor with this name !actor
			string name = text_in.substr(1, text_in.size());
			if (server_CreateBlob(name, team, Vec2f(pos.x,pos.z)) is null)
			{
				client_AddToChat("blob " + text_in + " not found", SColor(255, 255, 0, 0));
			}
		}
	}

	return true;
}

bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (text_in == "!debug" && !getNet().isServer())
	{
		// print all blobs
		CBlob@[] all;
		getBlobs(@all);

		for (u32 i = 0; i < all.length; i++)
		{
			CBlob@ blob = all[i];
			print("[" + blob.getName() + " " + blob.getNetworkID() + "] ");

			if (blob.getShape() !is null)
			{
				CBlob@[] overlapping;
				if (blob.getOverlapping(@overlapping))
				{
					for (uint i = 0; i < overlapping.length; i++)
					{
						CBlob@ overlap = overlapping[i];
						print("       " + overlap.getName() + " " + overlap.isLadder());
					}
				}
			}
		}
	}

	return true;
}
