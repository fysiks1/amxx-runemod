/*
About:
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
Looking at other players make them shake in fear

Credits:
Ops in #AMXmod @ Quakenet for alot of help ( + AssKicker & CheesyPeteza ) 
Thanks to BAILOPAN & PM for help on misc problems
kaddar for orginal runemod

Todo:
This rune is currently underpowered, and needs something added to it

Changelog:
 1.0.2
 	- Changed: Plugin now uses base plugin to reset speed

 1.0.1
 	- Fixed: UnLockSpeed would not be called if the user was in fear as the round ended

 1.0.0
 	- First public release

*/

#include <amxmodx>
#include <fun>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks


#define SPEEDDECREASE 2.2

new g_HasRune[MAXPLAYERS+1] // This is the Array used to store if the user is holding a rune.(Remember the base plugin informs this plugin once he picks up a rune.)
new g_IsInFear[MAXPLAYERS+1]
new g_LastWeapon[MAXPLAYERS+1]
new g_MaxPlayers
new g_RuneEnabled
new g_FearRunes

public plugin_init() 
{
	register_plugin("RuneMod Fear", "1.0.2", "EKS")
	g_MaxPlayers = get_maxplayers()
	register_event("CurWeapon", "Event_CurWeapon", "b");
	RegisterPlugin("FearName","FearDesc",{10,75,80},API_NEWROUND+API_ROUNDSTARTED+API_USELANGSYSTEM)
}

public Event_CurWeapon(id)
{
	if(g_FearRunes == 0 || !g_IsInFear[id]) return PLUGIN_CONTINUE
	
	new WID = get_user_weaponindex(id)
	if(g_LastWeapon[id] != WID)
	{
		g_LastWeapon[id] = WID
		set_user_maxspeed(id,(get_user_maxspeed(id) / SPEEDDECREASE))
	}
	else g_LastWeapon[id] = WID
	return PLUGIN_CONTINUE
}

public Task_CheckAim(id)
{
	if(!g_RuneEnabled) return PLUGIN_CONTINUE
	new HitEnt,Body
	get_user_aiming(id,HitEnt,Body)
	if(is_user_alive(HitEnt) && get_user_team(id) != get_user_team(HitEnt))
	{
		ShakeScreen(HitEnt,15,13)
		if(!g_IsInFear[HitEnt])
		{
			set_user_maxspeed(HitEnt,(get_user_maxspeed(HitEnt) / SPEEDDECREASE))
			g_LastWeapon[HitEnt] = get_user_weaponindex(HitEnt)
			LockSpeed(HitEnt)		// We lock him for speed changes. So he cant increase his speed with other runes like speed
			
			g_IsInFear[HitEnt] = id
			new Name[32]
			get_user_name(HitEnt,Name,31)
			client_print(id,print_chat,"%L",LANG_PLAYER,"FearMakeShake",Name)
			
			get_user_name(id,Name,31)
			client_print(HitEnt,print_chat,"%L",LANG_PLAYER,"FearGetsShaken",Name)
			
			set_task(4.0,"Task_RemoveFearTag",HitEnt+32,_,_,"a",1)
		}
	}
	return PLUGIN_CONTINUE
}
public Task_RemoveFearTag(id)
{
	id = id - 32
	g_IsInFear[id] = 0
	UnLockSpeed(id)
	if(is_user_alive(id))
	{
		ResetUserSpeed(id)
	}
}

public API_DropedRune(id,reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	g_FearRunes--
	g_HasRune[id] = 0
	remove_task(id)
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	g_FearRunes++
	g_HasRune[id] = 1
	set_task(0.2,"Task_CheckAim",id,_,_,"b")
}
public API_NewRound()
{
	g_RuneEnabled = 0
}

public API_RoundStarted()
{
	g_RuneEnabled = 1
	for(new i=1;i<=g_MaxPlayers;i++) if(task_exists(i+32,1))
	{
		if(task_exists(i+32,1))
		{
			remove_task(i+32)
			UnLockSpeed(i)
		}
		g_IsInFear[i] = 0
	}
}
