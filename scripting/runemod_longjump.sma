/*
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
Give you the HL1 item longjump

Credits:
Ops in #AMXmod @ Quakenet for alot of help ( + AssKicker & CheesyPeteza ) 
Thanks to BAILOPAN & PM for help on misc problems
kaddar for orginal runemod

Changelog:
 1.0.0
 	- First release
*/

#include <amxmodx>
#include <fun>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

#define MAXPLAYERS 32

new g_HasPowerUp[MAXPLAYERS+1]
new g_MaxPlayers

public plugin_init() 
{
	register_plugin("RuneMod Longjump", "1.0.0", "EKS")
	g_MaxPlayers = get_maxplayers()
	RegisterPlugin("LongjumpName","models/w_longjump.mdl",{50,125,10},API_PICKUPANDFORGET+API_DEATHMSG+API_USELANGSYSTEM+API_ROUNDSTARTED)
}
public API_DeathMsg(killer,victim)
{
	if(g_HasPowerUp[victim])
	{
		g_HasPowerUp[victim] = 0
	}
}
// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	if(!g_HasPowerUp[id])
	{
		give_item(id,"item_longjump")
		g_HasPowerUp[id] = 1
		return 1
	}
	return 0	
}
public API_RoundStarted()
{
	for(new i=1;i<=g_MaxPlayers;i++)
	{
		g_HasPowerUp[i] = 0
	}
}
public plugin_precache()
{
	precache_model("models/w_longjump.mdl")
}
