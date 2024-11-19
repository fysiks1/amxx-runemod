/*
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
Give you the HL1 item medkit

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
#include <cstrike>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

#define Armor_Increase 25
#define MAX_ARMOR 250

public plugin_init() 
{
	register_plugin("RuneMod Armor", "1.0.0", "EKS")
	RegisterPlugin("ArmorName","models/w_battery.mdl",{50,125,10},API_PICKUPANDFORGET+API_USELANGSYSTEM)	
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	new armor = get_user_armor(id)
	if(armor >= MAX_ARMOR)
		return 0
	else
	{
		armor = armor + Armor_Increase
		if(armor > MAX_ARMOR)
			set_user_armor(id,MAX_ARMOR)
		else
			set_user_armor(id,armor)
		return 1		
	}
	return 0
}
public plugin_precache()
{
	precache_model("models/w_battery.mdl")
}
