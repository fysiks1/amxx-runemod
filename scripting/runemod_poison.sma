/*
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
Pistol & knifes have poison damage

Credits:
Ops in #AMXmod @ Quakenet for alot of help ( + AssKicker & CheesyPeteza ) 
Thanks to BAILOPAN & PM for help on misc problems
kaddar for orginal runemod

Todo:
Balance it out

Changelog:
 1.0.2
	- Fixed: Rune working with all weapons
	- Fixed: Rune showing a extra kill message

 1.0.1
	- Changed: Color some.
 1.0.0
 	- First release
*/

#include <amxmodx>
#include <engine>
#include <fun>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

#define DOTDMG 3.0			// The amount of damage the DOT does.
#define DOT_TIMER 1.0		// How often the DOT happens
#define DOT_DOTTIMES 10		// The amount of times the DOT happens
#define WorkOnAnyWeapon 0	// If the poisen rune should work on any weapon, not just knifes or pistols.

new g_HasRune[MAXPLAYERS+1] // This is the Array used to store if the user is holding a rune.(Remember the base plugin informs this plugin once he picks up a rune.)
new g_ActiveDOT[MAXPLAYERS+1][2] // 0 == The DOT Times | 1 == the attacker
new g_RuneDisabled=0
new g_MsgDeathMsg
new g_MaxPlayers

public plugin_init() 
{
	register_plugin("RuneMod Poison", "1.0.2", "EKS")

	RegisterPlugin("PoisonName","PoisonDisc",{50,125,10},API_EVENTDAMAGEDONE+API_ROUNDSTARTED+API_NEWROUND+API_USELANGSYSTEM)	
	g_MaxPlayers = get_maxplayers()
	g_MsgDeathMsg = get_user_msgid("DeathMsg")
}

public API_DamageDone(victim,attacker,damage)
{
#if WorkOnAnyWeapon == 0
	if(!g_RuneDisabled && g_HasRune[attacker] && is_user_alive(victim) && (is_weapon_pistol(attacker,0) || is_meleeweapon(attacker,0))) 
#else
	if(!g_RuneDisabled && g_HasRune[attacker] && is_user_alive(victim)) 
#endif
	{
		if(g_ActiveDOT[victim][0] == 0) 
		{
			new Name[32]
			get_user_name(victim,Name,31)
			client_print(attacker,print_chat,"%L",LANG_PLAYER,"PoisonDotOn",Name)
		}
		g_ActiveDOT[victim][0] = DOT_DOTTIMES
		g_ActiveDOT[victim][1] = attacker
		if(!task_exists(victim,1)) 
		{
			set_task(DOT_TIMER,"Task_ApplyDmg",victim,_,_,"b")
		}
	}
	return PLUGIN_CONTINUE
}
public Task_ApplyDmg(id)
{
	g_ActiveDOT[id][0]--
	if(!is_user_alive(id) || g_ActiveDOT[id][0] == -1) 
	{
		remove_task(id)
		return PLUGIN_CONTINUE 
	}
	else 
		ApplyDamage(id)
	return PLUGIN_CONTINUE 
		
}
public client_disconnect(id)
{
	remove_task(id)
}
stock ApplyDamage(id)
{
	new Float:HP = entity_get_float(id,EV_FL_health) - DOTDMG
	if(HP < 1.0)	// This means the user either has no HP left or will die from the comming poisen effect.
	{
		remove_task(id)

		set_msg_block(g_MsgDeathMsg, BLOCK_SET)
		user_kill(id)
		set_msg_block(g_MsgDeathMsg, BLOCK_NOT)
		FakeKill(g_ActiveDOT[id][1],id,"Poisen")
		if(is_user_connected(g_ActiveDOT[id][1]))
			set_user_frags(g_ActiveDOT[id][1], get_user_frags(g_ActiveDOT[id][1])+ 1 )
		
		g_ActiveDOT[id][0] = 0
		g_ActiveDOT[id][1] = 0
	}
	else
	{
		entity_set_float(id,EV_FL_health,HP)
		MakeFadeScreen(id,2,1,1,{0,250,0},100)
	}
}

public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	g_HasRune[id] = 0
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	g_HasRune[id] = 1
}

public API_NewRound()
{
	g_RuneDisabled =1 
	for(new i=1;i<=g_MaxPlayers;i++)
	{
		remove_task(i)
		g_ActiveDOT[i][0] = 0
		g_ActiveDOT[i][1] = 0
	}
}
public API_RoundStarted()
{
	g_RuneDisabled=0
}
