#define SERVER_ONLY

void onNewPlayerJoin( CRules@ this, CPlayer@ player )
{
	string pName = player.getUsername();
	player.server_setTeamNum(0);
}

bool onServerProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	if (player is null )
		return true;

	CBlob@ b = player.getBlob(); 
	if (b !is null)
	{
		//PhysicalEntity@ blob; if (!b.get("blob",@blob)) return true;

		int team = b.getTeamNum();
		Vec2f pos = b.getPosition();
		{
			if (text_in == "!bot")
			{
				AddBot("Henry");
				return true;
			}
			else if (text_in.substr(0, 1) == "!")
			{
				// otherwise, try to spawn an actor with this name !actor
				string name = text_in.substr(1, text_in.size());
				if (server_CreateBlob(name, team, pos) is null)
				{
					client_AddToChat("blob " + text_in + " not found", SColor(255, 255, 0, 0));
				}
			}
		}
	}	


	if ( player.isMod() )
	{
		if (text_in.substr(0,1) == "!" )
		{
			string[]@ tokens = text_in.split(" ");

			if (tokens.length > 1)
			{
				if (tokens[0] == "!team")
				{
					int team = parseInt(tokens[1]);
					player.getBlob().server_setTeamNum(team);
					//player.server_setTeamNum( parseInt( tokens[1] ));
					//if ( player.getBlob() !is null )
					//	player.getBlob().server_Die();
					
					return false;
				}
			}
		}
	}

	return true;
}