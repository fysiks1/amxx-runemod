/*
About:
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
No footstep sounds & knife insta kill

Credits:
Ops in #AMXmod @ Quakenet for alot of help ( + AssKicker & CheesyPeteza ) 
Thanks to BAILOPAN & PM for help on misc problems
kaddar for orginal runemod

Todo:
Nothing planned

Changelog 
 1.0.1
 	- Fixed: Hunter rune not insta killing
 	
 1.0.0
 	- First relase
*/

#include <amxmodx>
#include <engine>
#include <fun>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks


new g_HasRune[MAXPLAYERS+1] // This is the Array used to store if the user is holding a rune.(Remember the base plugin informs this plugin once he picks up a rune.)
new g_HasThrownHe[MAXPLAYERS+1] // This is the Array used to store if the user is holding a rune.(Remember the base plugin informs this plugin once he picks up a rune.)

new g_HunterRunes

new g_MaxEnts
new g_MaxPlayers

public plugin_init() 
{
	register_plugin("RuneMod Hunter", "1.0.1", "EKS")
	RegisterPlugin("HunterName","HunterDesc",{10,75,10},API_EVENTDAMAGEDONE+API_USELANGSYSTEM)
	register_event("SendAudio","Event_SendAudio","b")
	
	g_MaxEnts = get_global_int(GL_maxEntities)
	g_MaxPlayers = get_maxplayers()
}
public Event_SendAudio(id)
{
	new Message[20]
	read_data(2,Message,19)
	if(contain(Message,"MRAD_FIREINHOLE") != -1)
	{
		g_HasThrownHe[id] = 1
		set_task(8.0,"Task_RemoveHeBlock",id,_,_,"a",1)
	}
}
public Task_RemoveHeBlock(id)
{
	g_HasThrownHe[id] = 0
}
public API_DamageDone(victim,attacker,damage)
{
	if(g_HunterRunes == 0) return PLUGIN_CONTINUE // If there are no runes ingame, we stop
	
	if(g_HasRune[attacker] && g_HasThrownHe[attacker]  == 0 && is_meleeweapon(attacker,0))
	{
		if(!task_exists(victim))
		{
			new parm[2]
			parm[0] = attacker
			parm[1] = victim
			set_task(0.1,"Task_RegisterKill",victim,parm,2,"a",1)
		}
	}
	return PLUGIN_CONTINUE
}
public Task_RegisterKill(parm[])
{
	RegisterKill(parm[0],parm[1],"Hunter")
	new EntNum = GetKnifeEnt(parm[0])

	if(EntNum > 0)
	{
		new Origin[3]
		get_origin(EntNum,Origin)
		AddSpark(Origin)
	}
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
stock GetKnifeEnt(id)
{
	new Class[24]
	for(new i=g_MaxPlayers+1;i<=g_MaxEnts;i++) 
	{
		if(is_valid_ent(i) && entity_get_edict(i, EV_ENT_owner) == id)
		{
			entity_get_string(i,EV_SZ_classname,Class,23)
			if(equal("weapon_knife",Class))
			{
				return i
			}
		}
	}
	return 0
}
public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	g_HasRune[id] = 0
	set_user_footsteps(id,0)
	g_HunterRunes--
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	g_HasRune[id] = 1
	g_HunterRunes++
	set_user_footsteps(id,1)
}
