/*


*/

#include <amxmodx>
#include <engine>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

new g_HasRune[MAXPLAYERS+1] // This is the Array used to store if the user is holding a rune.(Remember the base plugin informs this plugin once he picks up a rune.)
new g_FrenzyRunes
new Float:g_DmgInc[MAXPLAYERS+1]
new g_LastKilled[MAXPLAYERS+1]
new g_MaxPlayers

#define StartDmgIncrease 0.30

public plugin_init() 
{
	register_plugin("RuneMod Frenzy", "1.0.0", "EKS")
	
	g_MaxPlayers = get_maxplayers()
	RegisterPlugin("FrenzyName","FrenzyDesc",{120,50,225},API_ROUNDSTARTED+API_EVENTDAMAGE+API_DEATHMSG+API_USELANGSYSTEM)
}
public API_DeathMsg(killer,victim)
{
	if(g_HasRune[killer])
	{
		DmgIncrease(killer)
	}
}
stock DisableRune(IndexOfRune)
{
	new Temp = callfunc_begin("API_DisableRune","runemod_base.amxx")
	if(!Temp)
	{
		return -1
	}
	callfunc_push_int(IndexOfRune)
	return callfunc_end()
}
public API_Damage(victim,attacker,damage)
{
	if(g_HasRune[attacker])
	{
		return floatround(damage * g_DmgInc[attacker]) + damage
	}
	return damage
}

public Task_ResetLastKill(id)
	g_LastKilled[id] = 0
	

public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	g_HasRune[id] = 0
	g_DmgInc[id] = 0.00
	g_FrenzyRunes--
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	g_HasRune[id] = 1
	g_DmgInc[id] = StartDmgIncrease
	g_FrenzyRunes++
}
public API_RoundStarted()
{
	for(new i=1;i<=g_MaxPlayers;i++) if(g_HasRune[i])
	{
		g_DmgInc[i] = StartDmgIncrease - 0.05
		DmgIncrease(i)
	}
}
stock DmgIncrease(id)
{
	g_LastKilled[id] = 0
	g_DmgInc[id] = g_DmgInc[id] + 0.05
	new DamageInc[8]
	format(DamageInc,7,"%.2f",g_DmgInc[id])
	replace(DamageInc,7,"0.","")
	client_print(id,print_chat,"%L",LANG_PLAYER,"FrenzyCurDmgIncr",DamageInc)	
}
