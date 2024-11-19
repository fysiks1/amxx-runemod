/*
About:
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
If you use a knife you become invisible when standing still

Credits:
Ops in #AMXmod @ Quakenet for alot of help ( + AssKicker & CheesyPeteza ) 
Thanks to BAILOPAN & PM for help on misc problems
kaddar for orginal runemod

Todo:
Nothing planned

Changelog:
 1.1.0
	- Added: Plugin is now using the new CurWeapon system
	- Added: Now shows how long the cooldown is
	
 1.0.1
	- Fixed: Fixed runetime error with user droping rune and not being in g_PowerState[0]
 1.0.0
 	- First release
*/

#include <amxmodx>
#include <engine>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

#define INVIS_CHECKTIME 1.0
#define COOLDOWN 10
#define InvisTime 30

new Float:gf_OrginalOrigin[MAXPLAYERS+1][3]
new g_MaxPlayers
new g_HasRune[MAXPLAYERS+1]
new g_PowerState[MAXPLAYERS+1]
new g_WeaponIndex[MAXPLAYERS+1]
new g_InvTimeLeft[MAXPLAYERS+1]
/*
0 = Power is in ready
1 = Power is in use
2 = Power is cooldown
*/
new g_InvisRunes

public plugin_init() 
{
	register_plugin("RuneMod Invisibility", "1.1.0", "EKS")
	g_MaxPlayers = get_maxplayers()
	RegisterPlugin("InvisibilityName","InvisibilityDesc",{10,10,255},API_ROUNDSTARTED+API_EVENTCHANGEWEAPON+API_USELANGSYSTEM)
}

public Task_ShowPowerState()
{
	for(new i=1;i<=g_MaxPlayers;i++) if(g_HasRune[i])
	{
		if(g_PowerState[i] == 2)
		{	
			g_InvTimeLeft[i]--
			new Message[60]
			format(Message,59,"%L",i,"PowerStateCoolDown",g_InvTimeLeft[i])
			HudMessage2(i,Message)
			if(g_InvTimeLeft[i] == 0) Task_RemoveCoolDown(i)
		}		
		else if(g_PowerState[i] == 1)
		{	
			new Message[60]
			format(Message,59,"%L",i,"InvisibilityActive",(g_InvTimeLeft[i]/2))
			
			HudMessage2(i,Message)
		}
		else if(g_PowerState[i] == 0)
		{
			new Message[60]
			format(Message,59,"%L",i,"PowerStateReady")
			HudMessage2(i,Message)
		}
	}
}

public API_CurWeaponChange(id,WeaponIndex)
{
	g_WeaponIndex[id] = WeaponIndex
	if(g_PowerState[id] == 1 && !is_meleeweapon(WeaponIndex))
	{
		StopPower(id)
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}
public Task_RemoveCoolDown(id)
{
	g_PowerState[id] = 0
	if(get_user_team(id) == 1 || get_user_team(id) == 2) 
	{
		set_task(INVIS_CHECKTIME,"Task_CheckIfMoving",id,_,_,"b")
		HudMessage2(id,"PowerState: Ready")
	}
}
public Task_CheckIfMoving(id)	// This function checks if your moving. If your not moving you get invis. If not it updates your last postion
{
	new Float:Origin[3]
	entity_get_vector(id,EV_VEC_origin,Origin)
	if(g_PowerState[id] == 0 && is_meleeweapon(g_WeaponIndex[id]) && vector_distance(Origin,gf_OrginalOrigin[id]) <= 5.0)
	{
		remove_task(id)
		set_rendering(id,kRenderFxNone, 0,0,0,kRenderTransTexture,0)
		set_task(0.5,"Task_CheckThatsNotMoving",id,_,_,"b")

		g_InvTimeLeft[id] = InvisTime * 2
		g_PowerState[id] = 1
		return PLUGIN_CONTINUE
	}
	else
	{
		gf_OrginalOrigin[id][0] = Origin[0]
		gf_OrginalOrigin[id][1] = Origin[1]
		gf_OrginalOrigin[id][2] = Origin[2]
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public Task_CheckThatsNotMoving(id)	// This is the fucntion to check if the player is NOT moving when being invisible
{
	g_InvTimeLeft[id]--
	
	new Float:Origin[3]
	entity_get_vector(id,EV_VEC_origin,Origin)

	if(g_InvTimeLeft[id] == 0 || vector_distance(Origin,gf_OrginalOrigin[id]) >= 20.0 || !is_meleeweapon(g_WeaponIndex[id]))
	{
		client_print(id,print_chat,"%L",LANG_PLAYER,"InvisibilityVisable")
		StopPower(id)
	}
}
stock StopPower(id) 	// This is the function used to stop the invisbility. And start cooldown
{
	remove_task(id)
	RemoveEffect(id)

	g_PowerState[id] = 2	
	g_InvTimeLeft[id] =  COOLDOWN
}
stock RemoveEffect(id)
{
	set_rendering(id,kRenderFxNone, 0,0,0,kRenderNormal,16)	
}

public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	if(g_PowerState[id] ==0 ) remove_task(id) 	// We only remove the task if the rune is ready to be used. To prevent ppl from abusing it
	
	if(Reason != USER_DISCONNECTED)
	{
		RemoveEffect(id)
	}
	else if(Reason == USER_DISCONNECTED)
	{
		remove_task(id)
	}
		
	g_HasRune[id] = 0
	g_InvisRunes--
	if(g_InvisRunes == 0) remove_task(128)	// If no more Invis runes are in play, we remove the task that shows the text
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	set_task(INVIS_CHECKTIME,"Task_CheckIfMoving",id,_,_,"b")
	g_HasRune[id] = 1
	g_WeaponIndex[id] = 0
	g_InvisRunes++
	if(g_InvisRunes == 1) set_task(1.0,"Task_ShowPowerState",128,_,_,"b")
}
public API_RoundStarted()
{
	for(new i=1;i<=g_MaxPlayers;i++) 
	{
		remove_task(i)
		g_PowerState[i] = 0
		if(g_HasRune[i])
		{
			RemoveEffect(i)
			set_task(INVIS_CHECKTIME,"Task_CheckIfMoving",i,_,_,"b")
		}
	}	
}
