/*
About:
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
Walk into a wall to walk through it

Credits:
Ops in #AMXmod @ Quakenet for alot of help ( + AssKicker & CheesyPeteza ) 
Thanks to BAILOPAN & PM for help on misc problems
kaddar for orginal runemod

Todo:
As i failed to find a perfect way to discover if a player was stuck, this rune does a stuck check(witch often fails. But gets the worste cases) 
and then adds some speed to the player(ie push him forward.) and then check if he moved. If he dident moved, we teleport him back.
It also does some hackish +35 on his hight, to stop his feet from getting stuck. The curretn system works in most cases, but will proberbly fail if a user 
goes into a tight stop(by fail i mean teleport him back once he realy is NOT stuck)

Changelog:
 1.0.1
	- Changed: Color some.
 1.0.0
 	- First release
*/

#include <amxmodx>
#include <engine>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

#define PHANTOM_TASKTIME 1.0
#define PHANTOM_NOCLIPTIME 4

new Float:gf_OrginalOrigin[MAXPLAYERS+1][2][3]
new g_UserIsNoClip[MAXPLAYERS+1]
new g_UserTimer[MAXPLAYERS+1]
new g_HasRune[MAXPLAYERS+1]
new g_MaxPlayers

public plugin_init() 
{
	register_plugin("RuneMod Phantom", "1.0.1", "EKS")
	g_MaxPlayers = get_maxplayers()
	RegisterPlugin("PhantomName","PhantomDisc",{10,255,20},API_NEWROUND+API_ROUNDSTARTED+API_USELANGSYSTEM)
}
public Task_PhantomCheck(id)
{
	new UserOrg[3],HitOrig[3]
	get_user_origin(id,UserOrg,1)
	get_user_origin(id,HitOrig,3)
	if(get_distance(UserOrg,HitOrig) <= 30)
	{
		remove_task(id)
		g_UserIsNoClip[id] = 1
		entity_get_vector(id,EV_VEC_origin,gf_OrginalOrigin[id][0])
		entity_set_int(id, EV_INT_movetype, MOVETYPE_NOCLIP)
		g_UserTimer[id] = PHANTOM_NOCLIPTIME
		set_rendering(id,kRenderFxGlowShell,255,255,255,kRenderNormal,25)
		
		new Message[32]
		format(Message,31,"%L",LANG_PLAYER,"PowerStateActive",g_UserTimer[id])
		HudMessage2(id,Message)
		
		set_task(1.0,"Task_CountDown",id,_,_,"b")
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}
// This function is used to check if the user is inside a wall
public Task_CountDown(id)
{
	g_UserTimer[id]--
	if(g_UserTimer[id] > 0)
	{
		new Message[32]
		format(Message,31,"%L",id,"PowerStateActive",g_UserTimer[id])
		HudMessage2(id,Message)
	}
	else	// This means the countdown is over, and we now check if the player is stuck or not.
	{
		remove_task(id)
		new Float:Origin[3]
		entity_get_vector(id,EV_VEC_origin,Origin)
		Origin[2] = Origin[2] + 20.0
		entity_set_int(id, EV_INT_movetype,CONTENTS_CLIP)
		if(point_contents(Origin) == CONTENTS_EMPTY)
		{
			new Float:Velocity[3]
			entity_set_vector(id,EV_VEC_origin,Origin)
			entity_get_vector(id,EV_VEC_origin,gf_OrginalOrigin[id][1])
			velocity_by_aim(id,10,Velocity)						// We now force the player to move some.
			entity_set_vector(id,EV_VEC_velocity,Velocity)
			set_task(0.2,"Task_StuckCheck",id,_,_,"b")
		}
		else 
		{
			RemoveNoClip(id)
			new IntOrigin[3]
			IntOrigin[0] = floatround(Origin[0])
			IntOrigin[1] = floatround(Origin[1])
			IntOrigin[2] = floatround(Origin[2])
			
			MakeTeleport(IntOrigin)
			set_task(PHANTOM_TASKTIME,"Task_PhantomCheck",id,_,_,"b")
		}
	}
}
public Task_StuckCheck(id)
{
	remove_task(id)
	new Float:Origin[3]
	entity_get_vector(id,EV_VEC_origin,Origin)
	if(point_contents(Origin) != CONTENTS_EMPTY || vector_distance(gf_OrginalOrigin[id][1],Origin) <= 2.0)
	{
		RemoveNoClip(id)
		new IntOrigin[3]
		IntOrigin[0] = floatround(Origin[0])
		IntOrigin[1] = floatround(Origin[1])
		IntOrigin[2] = floatround(Origin[2])
		
		MakeTeleport(IntOrigin)
		set_task(PHANTOM_TASKTIME,"Task_PhantomCheck",id,_,_,"b")	
	}
	else
	{
		g_UserIsNoClip[id] = 0
		set_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,25)
		set_task(PHANTOM_TASKTIME,"Task_PhantomCheck",id,_,_,"b")
	}
}
stock RemoveNoClip(id)
{
	if(!g_UserIsNoClip[id]) return PLUGIN_CONTINUE
	remove_task(id)
	set_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,25)
	new Float:Vel[3]
	entity_set_vector(id,EV_VEC_velocity,Vel)
	g_UserIsNoClip[id] = 0
	entity_set_vector(id,EV_VEC_origin,gf_OrginalOrigin[id][0])
	entity_set_int(id, EV_INT_movetype,CONTENTS_CLIP)
	
	client_print(id,print_chat,"%L",LANG_PLAYER,"PhantomTeleportBack")
	return PLUGIN_CONTINUE
}

public API_DropedRune(id) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	remove_task(id) 
	if(g_UserIsNoClip[id]) RemoveNoClip(id)
	g_HasRune[id] = 0
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id)
{
	g_HasRune[id] = 1
	set_task(PHANTOM_TASKTIME,"Task_PhantomCheck",id,_,_,"b")
}
public API_RoundStarted()
{
	for(new i=1;i<=g_MaxPlayers;i++) if(g_HasRune[i])
	{
		set_task(PHANTOM_TASKTIME,"Task_PhantomCheck",i,_,_,"b")
	}
}
public API_NewRound()
{
	for(new i=1;i<=g_MaxPlayers;i++) if(g_HasRune[i])
	{
		remove_task(i)
		g_UserIsNoClip[i] = 0
		entity_set_int(i, EV_INT_movetype,CONTENTS_CLIP)
		set_rendering(i,kRenderFxGlowShell,0,0,0,kRenderNormal,25)
	}
}
