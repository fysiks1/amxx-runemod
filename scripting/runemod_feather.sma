/*
About:
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
Increases your maxpspeed by 100%

Credits:
Ops in #AMXmod @ Quakenet for alot of help ( + AssKicker & CheesyPeteza ) 
Thanks to BAILOPAN & PM for help on misc problems
kaddar for orginal runemod

Todo:
No plans
*/

#include <amxmodx>
#include <engine>
#include <fun>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

#define MAXSPEED 1.25			// How much to add to the max speed
#define Gravity 0.6

new g_MaxPlayers
new g_HasRune[MAXPLAYERS+1] 	// This is the Array used to store if the user is holding a rune.(Remember the base plugin informs this plugin once he picks up a rune.)
new g_SpeedLocked[MAXPLAYERS+1]

public plugin_init() 
{
	register_plugin("RuneMod Feather", "1.0.0", "EKS")
	g_MaxPlayers = get_maxplayers()
	RegisterPlugin("FeatherName","FeatherDisc",{80,255,240},API_SPEEDCHANGE+API_NEWROUND+API_ROUNDSTARTED+API_USELANGSYSTEM+API_EVENTCHANGEWEAPON)
}

public API_CurWeaponChange(id,WeaponIndex)
{
	if(g_SpeedLocked[id]) return PLUGIN_CONTINUE
	IncreaseSpeed(id,get_user_maxspeedint(id))
	return PLUGIN_CONTINUE
}
public API_UnLockSpeedChange(id)
{
	g_SpeedLocked[id] = 0
}
public API_LockSpeedChange(id)
{
	g_SpeedLocked[id] = 1
}

public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	if(Reason != USER_DISCONNECTED)
		ResetUserSpeed(id)

	g_HasRune[id] = 0
	entity_set_float(id, EV_FL_gravity, 1.0)
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	if(!g_SpeedLocked[id])
		IncreaseSpeed(id,get_user_maxspeedint(id))

	g_HasRune[id] = 1
	entity_set_float(id, EV_FL_gravity, Gravity)
}
public API_RoundStarted()
{
	new Speed
	for(new i=1;i<=g_MaxPlayers;i++) if(g_HasRune[i])
	{
		g_SpeedLocked[i] = 0
		Speed = ResetUserSpeed(i)
		IncreaseSpeed(i,Speed)
		entity_set_float(i, EV_FL_maxspeed, Gravity)
	}
}
public API_NewRound()
{
	for(new i=1;i<=g_MaxPlayers;i++) if(g_HasRune[i])
	{
		g_SpeedLocked[i] = 1
	}
}
stock IncreaseSpeed(id,maxpspeed)
{
	set_user_maxspeed(id,(maxpspeed * MAXSPEED))	
}
stock get_user_maxspeedint(id)
{
	return floatround(get_user_maxspeed(id))
}
