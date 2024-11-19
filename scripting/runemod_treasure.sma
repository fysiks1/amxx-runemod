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
#include <cstrike>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

#define MaxMoney 16000
#define GiveMoney 8000


public plugin_init() 
{
	register_plugin("RuneMod Treasure", "1.0.0", "EKS")
	RegisterPlugin("TreasureName","models/teleporter_orange_rings.mdl",{137,10,175},API_PICKUPANDFORGET+API_USELANGSYSTEM)	
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	new money = cs_get_user_money(id)
	if(money >= MaxMoney)
		return 0
	else
	{
		money = money + GiveMoney
		if(money > MaxMoney)
			cs_set_user_money(id,MaxMoney)
		else
			cs_set_user_money(id,money)
		return 1		
	}
	return 0
}
public plugin_precache()
{
	precache_model("models/teleporter_orange_rings.mdl")
}
