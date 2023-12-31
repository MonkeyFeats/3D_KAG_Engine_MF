//#include "PrecacheTextures.as"

const int BUTTON_SIZE = 4;

void onInit( CRules@ this )
{
    particles_gravity.y = 0.0f; 
    sv_gravity = 0;    
    sv_visiblity_scale = 2.0f;
	cc_halign = 2;
	cc_valign = 2;
	s_effects = false;
	sv_max_localplayers = 1;	
	
	//smooth shader
	//Driver@ driver = getDriver();
//
	//driver.AddShader("hq2x", 1.0f);
	//driver.SetShader("hq2x", true);

	//driver.AddShader("FXAA", 2.0f);
	//driver.SetShader("FXAA", true);
	//driver.ForceStartShaders();	

	//PrecacheTextures(); //crashing, player sprites too big :C

	//reset var if you came from another gamemode that edits it
	SetGridMenusSize(24,2.0f,32);

	//spectator stuff
	this.addCommandID("pick teams");
    this.addCommandID("pick spectator");
	this.addCommandID("pick none");
}

void ShowTeamMenu( CRules@ this )
{
	CPlayer@ local = getLocalPlayer();
    if (local is null) 
	{
        return;
    }

    CGridMenu@ menu = CreateGridMenu( getDriver().getScreenCenterPos(), null, Vec2f( BUTTON_SIZE, BUTTON_SIZE), "Change team" );

    if (menu !is null)
    {
		CBitStream exitParams;
		menu.AddKeyCommand( KEY_ESCAPE, this.getCommandID("pick none"), exitParams );
		menu.SetDefaultCommand( this.getCommandID("pick none"), exitParams );


        CBitStream params;
        params.write_u16( local.getNetworkID() );
        if (local.getTeamNum() == this.getSpectatorTeamNum())
        {
			CGridButton@ button = menu.AddButton( "$TEAMS$", "Auto-pick teams", this.getCommandID("pick teams"), Vec2f(BUTTON_SIZE, BUTTON_SIZE), params );
		}
		else
		{
			CGridButton@ button = menu.AddButton( "$SPECTATOR$", "Spectator", this.getCommandID("pick spectator"), Vec2f(BUTTON_SIZE, BUTTON_SIZE), params );
		}
    }
}

void ReadChangeTeam( CRules@ this, CBitStream @params, int team )
{
    CPlayer@ player = getPlayerByNetworkId( params.read_u16() );
    if (player is getLocalPlayer())
    {
        player.client_ChangeTeam( team );
        getHUD().ClearMenus();
    }
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("pick teams"))
    {
        ReadChangeTeam( this, params, -1);
    }
    else if (cmd == this.getCommandID("pick spectator"))
    {
        ReadChangeTeam( this, params, this.getSpectatorTeamNum() );
	} else if (cmd == this.getCommandID("pick none"))
	{
		getHUD().ClearMenus();
	}
}