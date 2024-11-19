/*
About:
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
Your immune to headshots

Credits:
Ops in #AMXmod @ Quakenet for alot of help ( + AssKicker & CheesyPeteza ) 
Thanks to BAILOPAN & PM for help on misc problems
kaddar for orginal runemod

Todo:
Nothing planned

*/

#include <amxmodx>
#include <engine>
#include <fun>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

#define MAX_GRENADES 20

#define GEN_FLASH 1
#define GEN_HE 2

#define MOVE_HE_DIST 200.0

new g_HasRune[MAXPLAYERS+1]
new g_MsgFade
new g_MaxEnts
new g_MaxPlayers

new g_GEnt[MAX_GRENADES+1][2]
new g_FActive 		// Contains a count of the flashbans currently Armed & thrown
new g_HActive 		// Contains a count of the flashbans currently Armed & thrown

public plugin_init() 
{
	register_plugin("RuneMod Protection", "1.0.0", "EKS")
	RegisterPlugin("ProtectionName","ProtectionDisc",{200,20,100},API_USELANGSYSTEM)
	
	g_MsgFade = get_user_msgid("ScreenFade")
	g_MaxEnts = get_global_int(GL_maxEntities)
	g_MaxPlayers = get_maxplayers()
	
	register_event("SendAudio","Event_SendAudio","b")
	register_message(g_MsgFade,"Event_ScreenFade")
}
public Event_ScreenFade(msgid, msgDest, msgEnt)
{
	if(!g_FActive)
		return PLUGIN_CONTINUE
	if(g_HasRune[msgEnt] == 1)
	{
		new byte4 = get_msg_arg_int(4)
		new byte5 = get_msg_arg_int(5)
		new byte6 = get_msg_arg_int(6)
		new byte7 = get_msg_arg_int(7)
		
		if(byte4 == 255 && byte5 == 255 && byte6 == 255 && byte7 == 255)
		{
			client_print(msgEnt,print_chat,"%L",LANG_PLAYER,"ProtectionIgnoreFlash")
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE
}

public Event_SendAudio(id)
{
	new Message[20]
	read_data(2,Message,19)
	if(contain(Message,"MRAD_FIREINHOLE") != -1)
	{
		set_task(0.1,"Task_FindGrenade",id,_,_,"a",1)
	}
}
public Task_FindGrenade(id)
{
	FindGrenadeEnt(id)
}
stock FindGrenadeEnt(id)
{
	new Class[20]
	new Owner
	new Model[30]
	
	for(new i=g_MaxPlayers+1;i<=g_MaxEnts;i++) if(is_valid_ent(i))
	{
		entity_get_string(i,EV_SZ_classname,Class,19)		
		Owner = entity_get_edict(i, EV_ENT_owner)
		if(Owner == id && equal(Class,"grenade") && IsNewNade(i))
		{
			entity_get_string(i,EV_SZ_model,Model,29)
			
			if(contain(Model,"w_flashbang") != -1)
			{
				g_FActive++
				SaveNadeEnt(i,GEN_FLASH)
				return 1
			}
			else if(contain(Model,"w_hegrenade") != -1)
			{
				g_HActive++
				SaveNadeEnt(i,GEN_HE)
				return 2
			}
			else
				return -2
		}				
	}
	return -1
}

stock SaveNadeEnt(EntNum,Grenade)
{
	for(new i=1;i<MAX_GRENADES;i++) if(g_GEnt[i][0] == 0)
	{
		g_GEnt[i][0] = EntNum
		g_GEnt[i][1] = Grenade
		
		if(Grenade == GEN_FLASH)
			set_task(0.1,"Task_RemoveEntInfo",EntNum,_,_,"b")
		else if(Grenade == GEN_HE)
			set_task(0.1,"Task_MoveHEGren",EntNum,_,_,"b")
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}
stock IsNewNade(EntNum)
{
	for(new i=0;i<MAX_GRENADES;i++)
	{
		if(g_GEnt[i][0] == EntNum)
			return 0
	}
	return 1
}
public Task_RemoveEntInfo(id)
{
	if(!is_valid_ent(id))
	{
		for(new i=0;i<MAX_GRENADES;i++)
		{
			if(g_GEnt[i][0] == id)
			{
				g_GEnt[i][0] = 0
				g_FActive--					
				remove_task(id)
				return PLUGIN_CONTINUE
			}
		}
	}
	return PLUGIN_CONTINUE
}
public Task_MoveHEGren(id)
{
	if(!is_valid_ent(id))
	{
		for(new i=0;i<MAX_GRENADES;i++)
		{
			if(g_GEnt[i][0] == id)
			{
				g_GEnt[i][0] = 0
				g_HActive--

				remove_task(id)
				return PLUGIN_CONTINUE
			}
		}		
	}
	new Owner
	for(new i=1;i<=g_MaxPlayers;i++) if(g_HasRune[i])
	{
		Owner = entity_get_edict(id, EV_ENT_owner)
		if(entity_range(id,i) < MOVE_HE_DIST && id != Owner && get_user_team(Owner) != get_user_team(i))
		{
			new Float:Vel[3]
			entity_get_vector(id, EV_VEC_velocity, Vel)			
			
			if(!Vel[0])
				floatabs(Vel[0])
			else if(Vel[0])
				Vel[0] = Vel[0] - Vel[0]	- Vel[0]
		
			if(!Vel[1])
				floatabs(Vel[1])	
			else if(Vel[1])
				Vel[1] = Vel[1] - Vel[1]	- Vel[1]			
		
			if(!Vel[2])
				floatabs(Vel[2])
			else if(Vel[2])
				Vel[2] = Vel[2] - Vel[2] - Vel[2]
			entity_set_vector(id,EV_VEC_velocity,Vel)
			
			new Origin[3]
			get_origin(id,Origin)
			//AddSpark(Origin)
			
		}
	}
	return PLUGIN_CONTINUE
}
#define TE_SPARKS     9    //8 random tracers with gravity, ricochet sprite 
stock AddSpark(Origin[3])
{
	message_begin(MSG_ALL,SVC_TEMPENTITY) //message begin 
	write_byte(TE_SPARKS) 
	write_coord(Origin[0]) // start position 
	write_coord(Origin[1]) 
	write_coord(Origin[2]) 
	message_end()
}
public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	g_HasRune[id] = 0
	set_user_hitzones(0,id,255)
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	g_HasRune[id] = 1
	set_user_hitzones(0,id,253)
}
