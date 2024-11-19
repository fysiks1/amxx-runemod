/*
About:
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
People loose hp when attacking you

Credits:
Ops in #AMXmod @ Quakenet for alot of help ( + AssKicker & CheesyPeteza ) 
Thanks to BAILOPAN & PM for help on misc problems
kaddar for orginal runemod

Todo:
Nothing spesial planned. Might need to balanced

*/

#include <amxmodx>
#include <engine>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

#define DISMAY_HP2STEAL 0.50

new g_HasRune[MAXPLAYERS+1] // This is the Array used to store if the user is holding a rune.(Remember the base plugin informs this plugin once he picks up a rune.)
new g_DismayRunes

public plugin_init() 
{
	register_plugin("RuneMod Dismay", "1.0.0", "EKS")
	
	RegisterPlugin("DismayName","DismayDesc",{225,125,10},API_EVENTDAMAGEDONE+API_USELANGSYSTEM)
}

public API_DamageDone(victim,attacker,damage)
{
	if(g_DismayRunes == 0) return PLUGIN_CONTINUE // If there are no runes ingame, we stop
	
	if(g_HasRune[victim] && is_user_alive(attacker))
	{
		new Float:NewHP = entity_get_float(attacker,EV_FL_health) - (float(damage) * DISMAY_HP2STEAL)
		if(NewHP < 0.0)
		{
			new parm[2]
			parm[0] = attacker
			parm[1]	= victim
			set_task(0.1,"Task_FakeKill",attacker,parm,2,"a",1)
			return PLUGIN_CONTINUE
		}
		else 
		{
			entity_set_float(attacker, EV_FL_health,NewHP)
			MakeFadeScreen(attacker,1,1,1,{255,0,0},100)
		}
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}
public Task_FakeKill(parm[]) 
{
	RegisterKill(parm[1],parm[0],"Dismay")
	return PLUGIN_CONTINUE
}
public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	g_HasRune[id] = 0
	g_DismayRunes--
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	g_HasRune[id] = 1
	g_DismayRunes++
}
