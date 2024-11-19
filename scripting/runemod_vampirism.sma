/*
About:
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
You steal part of the damage you deal out

Credits:
Ops in #AMXmod @ Quakenet for alot of help ( + AssKicker & CheesyPeteza ) 
Thanks to BAILOPAN & PM for help on misc problems
kaddar for orginal runemod

Todo:
No plans
*/

#include <amxmodx>
#include <engine>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

#define VAMP_MAXHP 100.0
#define VAMP_HP2STEAL 0.25
#define ShowMsg 1

new g_HasRune[MAXPLAYERS+1] // This is the Array used to store if the user is holding a rune.(Remember the base plugin informs this plugin once he picks up a rune.)
new g_VampRunes

public plugin_init() 
{
	register_plugin("RuneMod Vampirism", "1.0.0", "EKS")
	RegisterPlugin("VampirismName","VampirismDesc",{0,255,255},API_EVENTDAMAGEDONE+API_USELANGSYSTEM)
}

public API_DamageDone(victim,attacker,damage)
{
	if(g_VampRunes == 0) return PLUGIN_CONTINUE // If there are no runes ingame, we stop
	// If the attacker does not have the vampire rune. Also if the user allready has max hp we stop
	if(!g_HasRune[attacker] || entity_get_float(attacker, EV_FL_health) >= VAMP_MAXHP)
	{
		return PLUGIN_CONTINUE	
	}
	else
	{
		new Float:NewHP = float(damage) * VAMP_HP2STEAL + entity_get_float(attacker,EV_FL_health)
		if(NewHP > VAMP_MAXHP)
			NewHP = VAMP_MAXHP

		entity_set_float(attacker, EV_FL_health,NewHP)
#if ShowMsg == 1
		new Text[128]
		get_user_name(victim,Text,31)
		format(Text,127,"%L",attacker,"VampirismStoleHP",floatround(float(damage) * VAMP_HP2STEAL),Text)
		HudMessage2(attacker,Text)
#endif
	}
	return PLUGIN_CONTINUE	
}

public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	g_HasRune[id] = 0
	g_VampRunes--
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	g_HasRune[id] = 1
	g_VampRunes++
}
