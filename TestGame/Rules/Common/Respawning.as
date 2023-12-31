#define SERVER_ONLY

#include "Server.as"
#include "Human.as"
#include "Camera3D.as"

const string PLAYER_BLOB = "human";
const string SPAWN_TAG = "mothership";

bool oneTeamLeft = false;

shared class Respawn
{
	string username;
	u32 timeStarted;

	Respawn( const string _username, const u32 _timeStarted ){
		username = _username;
		timeStarted = _timeStarted;
	}
};


void onInit(CRules@ this)
{
	Respawn[] respawns;
	this.set("respawns", respawns);
	this.set_u8( "endCount", 0 );
    onRestart(this);
}

void onReload(CRules@ this)
{
    this.clear("respawns"); 
	this.set_u8( "endCount", 0 );	
    for (int i = 0; i < getPlayerCount(); i++)
    {
        CPlayer@ player = getPlayer(i);
        if ( player.getTeamNum() == this.getSpectatorTeamNum() )
			player.server_setTeamNum( this.getSpectatorTeamNum() );
        else if (player.getBlob() is null)
        {
            Respawn r(player.getUsername(), getGameTime());
            this.push("respawns", r);
        }
    }
}

void onRestart(CRules@ this)
{
	this.clear("respawns");
	this.set_u8( "endCount", 0 );
	//assign teams
    for (int i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if ( player.getTeamNum() == this.getSpectatorTeamNum() )
			player.server_setTeamNum( this.getSpectatorTeamNum() );
		else
		{
			//print ( "onRestart: assigning " + player.getUsername() );
			player.server_setTeamNum(0);
			Respawn r(player.getUsername(), getGameTime());
			this.push("respawns", r);
		}
	}

    this.SetCurrentState(GAME);
    this.SetGlobalMessage( "" );
}

void onPlayerRequestSpawn( CRules@ this, CPlayer@ player )
{
	if (!isRespawnAdded( this, player.getUsername()) && player.getTeamNum() != this.getSpectatorTeamNum())
	{
    	Respawn r(player.getUsername(), getGameTime());
    	this.push("respawns", r);
    }
}

void onTick( CRules@ this )
{
	const u32 gametime = getGameTime();
	if (this.isMatchRunning() && gametime % 30 == 0)
	{
		Respawn[]@ respawns;
		if (this.get("respawns", @respawns))
		{
			for (uint i = 0; i < respawns.length; i++)
			{
				Respawn@ r = respawns[i];
				if (r.timeStarted == 0 || r.timeStarted + this.playerrespawn_seconds*getTicksASecond() <= gametime)
				{
					SpawnPlayer( this, getPlayerByUsername( r.username ));
					respawns.erase(i);
					i = 0;
				}
			}
		}
	}
}

void SpawnPlayer( CRules@ this, CPlayer@ player )
{
    if (player !is null)
    {
        // remove previous players blob
        CBlob @blob = player.getBlob();		   
        if (blob !is null)
        {
            CBlob @blob = player.getBlob();
            blob.server_SetPlayer( null );
            blob.server_Die();
        }

        player.server_setTeamNum(0); 

		Human@ blob3d = Human(player, Vec3f(200, 16, 200), 0, 1.0f);
		if ( blob3d !is null )
		{
			Camera3D@ camera; 
			player.get("Camera3D", @camera);
			if (camera !is null && blob3d !is null)
			{
				camera.setTarget(blob3d);
			}
			//allObjects.push_back(blob3d); 
			player.set("playerPhysicalEntity", @blob3d);
		}
    }
}

bool isRespawnAdded( CRules@ this, const string username )
{
	Respawn[]@ respawns;
	if (this.get("respawns", @respawns))
	{
		for (uint i = 0; i < respawns.length; i++)
		{
			Respawn@ r = respawns[i];
			if (r.username == username)
				return true;
		}
	}
	return false;
}

void onPlayerRequestTeamChange( CRules@ this, CPlayer@ player, u8 newteam )
{
    CBlob@ blob = player.getBlob();
	if (blob !is null)
        blob.server_Die();
			
	else if (newteam == this.getSpectatorTeamNum())
    {

    }
}

bool allPlayersInOneTeam( CRules@ this )
{
    if (getPlayerCount() <= 1)
        return false;
    int team = -1;
	u16 specTeam = this.getSpectatorTeamNum();
    for (int i = 0; i < getPlayerCount(); i++)
    {
        CPlayer@ player = getPlayer(i);
        if (i == 0)
            team = player.getTeamNum();
        else if (team != player.getTeamNum() && player.getTeamNum() != specTeam)
            return false;
    }

    return true;
}