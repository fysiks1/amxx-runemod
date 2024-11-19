/*
About:
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
You do 30% less damage

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

new g_HasRune[MAXPLAYERS+1] // This is the Array used to store if the user is holding a rune.(Remember the base plugin informs this plugin once he picks up a rune.)

#define Weakness_power 0.7

public plugin_init() 
{
	register_plugin("RuneMod Weakness", "1.0.0", "EKS")
	RegisterPlugin("WeaknessName","WeaknessDisc",{230,50,025},API_EVENTDAMAGE+API_BADRUNE+API_USELANGSYSTEM)
}
public API_Damage(victim,attacker,damage)
{
	if(g_HasRune[attacker])
	{
		return floatround(damage * Weakness_power)
	}
	return damage
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
