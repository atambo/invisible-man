#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
new solo, newsolo, firstround
public plugin_init()
{	
	register_plugin("invis", "1", "atambo")
	register_cvar("sv_invis", "0")
	register_concmd("amx_invis","toggle",ADMIN_CVAR,"1=on/0=off")
	register_event("DeathMsg", "death_event", "a")
	register_logevent("event_round_end", 2, "0=World triggered", "1=Round_End")
	register_menucmd(register_menuid("Team_Select",1), (1<<0)|(1<<1)|(1<<4)|(1<<5), "team_select")
        register_clcmd("jointeam", "join_team")
	register_event("CurWeapon", "check_change", "be", "1=1")
}
public client_connected_msg(id)
	client_print(id, print_chat, "Invisible Man Mod is currently enabled. Kill the invisible man to become the next invisible man.")
public client_putinserver(id)
	if(get_cvar_num("sv_invis") == 1)
		set_task(20.0, "client_connected_msg", id)
public client_disconnect(id)
{
	if(get_cvar_num("sv_invis") != 1) return PLUGIN_CONTINUE
	if(id==newsolo)
}
public check_change(id)
{
	if(get_cvar_num("sv_invis") != 1) return PLUGIN_CONTINUE
	new wpnid = read_data(2)
	new CsTeams:team = cs_get_user_team(id)
	if(wpnid!=CSW_KNIFE && team==CS_TEAM_T)
	{
		strip_user_weapons(id)
		give_item(id,"weapon_knife")
	}
	return PLUGIN_CONTINUE
}
public toggle(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED
	new arg1[32]
	read_argv(1,arg1,31)
	if(equali(arg1,"1"))
	{
		if(get_cvar_num("sv_invis") == 1) return PLUGIN_CONTINUE
		set_hudmessage(0, 100, 0, -1.0, 0.65, 2, 0.02, 10.0, 0.01, 0.1, 2)
		show_hudmessage(0,"Invisible Man Mode Enabled!")
		set_cvar_num("mp_limitteams",0)
		set_cvar_num("mp_autoteambalance",0)
		set_cvar_num("mp_startmoney",16000)
		set_cvar_num("sv_invis",1)
		firstround=1
		set_cvar_num("sv_restart",1)
		event_round_end()
		return PLUGIN_CONTINUE
	}
	if(equali(arg1,"0"))
	{
		if(get_cvar_num("sv_invis") == 0) return PLUGIN_CONTINUE
		set_hudmessage(0, 100, 0, -1.0, 0.65, 2, 0.02, 10.0, 0.01, 0.1, 2)
		show_hudmessage(0,"Invisible Man Mode Disabled!")
		set_cvar_num("mp_limitteams",1)
		set_cvar_num("mp_autoteambalance",1)
		set_cvar_num("mp_startmoney",800)
		set_cvar_num("sv_invis",0)
		set_cvar_num("sv_restartround",1)
		set_user_rendering(newsolo,kRenderFxNone,0,0,0,kRenderNormal,0)
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}
public team_select(id, key)
{
	if(get_cvar_num("sv_invis") != 1) return PLUGIN_CONTINUE
        if(key==0 || key==4)
	{
                engclient_cmd(id,"chooseteam")
                return PLUGIN_HANDLED
        }
        return PLUGIN_CONTINUE
}
public join_team(id)
{
	if(get_cvar_num("sv_invis") != 1) return PLUGIN_CONTINUE
        new arg[2]
        read_argv(1,arg,1)
        if((str_to_num(arg)-1)==0 || (str_to_num(arg)-1)==4)
	{
                engclient_cmd(id,"chooseteam")
                return PLUGIN_HANDLED
        }
        return PLUGIN_CONTINUE
}
public death_event()
{
	if(get_cvar_num("sv_invis") != 1) return PLUGIN_CONTINUE
	newsolo = read_data(1)
   	solo = read_data(2)
	return PLUGIN_CONTINUE
}
public event_round_end()
{
	if(get_cvar_num("sv_invis") != 1) return PLUGIN_CONTINUE
	if(firstround==1)
	{
		new playersT[32], playersCT[32], numT, numCT
		get_players(playersT,numT,"e","TERRORIST")
		
		for(new i=0;i<numT;i++)
			cs_set_user_team(playersT[i],CS_TEAM_CT)
		get_players(playersCT,numCT,"e","CT")
		if(numCT==0) return PLUGIN_CONTINUE
		newsolo = playersCT[random_num(0,numCT-1)]
		cs_set_user_team(newsolo,CS_TEAM_T)
		set_user_rendering(newsolo, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0)
		firstround=0
	}
	else
	{
		if(newsolo==solo || newsolo==0)
		{
			new playersCT[32], numCT
			get_players(playersCT,numCT,"e","CT")
			newsolo = playersCT[random_num(0,numCT-1)]
			cs_set_user_team(newsolo,CS_TEAM_T)
			cs_set_user_team(solo,CS_TEAM_CT)
			set_user_rendering(solo,kRenderFxNone,0,0,0,kRenderNormal,0)
			set_user_rendering(newsolo, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0)
		}
		else
		{
			cs_set_user_team(newsolo,CS_TEAM_T)
			cs_set_user_team(solo,CS_TEAM_CT)
			set_user_rendering(solo,kRenderFxNone,0,0,0,kRenderNormal,0)
			set_user_rendering(newsolo, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0)
		}
	}
	return PLUGIN_CONTINUE
}
public plugin_end()
{
	set_cvar_num("mp_limitteams",1)
	set_cvar_num("mp_autoteambalance",1)
	set_cvar_num("mp_startmoney",800)
	set_cvar_num("sv_invis",0)
}