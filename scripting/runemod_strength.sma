/*
About:
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
You do extra 40% extra damage with rifle/pistols

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
new g_WeaponIndex[MAXPLAYERS+1]
new g_StrenghtRunes

#define DamageIncrease 1.40

public plugin_init() 
{
	register_plugin("RuneMod Strength", "1.0.0", "EKS")
	RegisterPlugin("StrengthName","StrengthDisc",{230,50,025},API_EVENTDAMAGE+API_EVENTCHANGEWEAPON+API_USELANGSYSTEM)
}
public API_CurWeaponChange(id,WeaponIndex)
{
	g_WeaponIndex[id] = WeaponIndex
}
public API_Damage(victim,attacker,damage)
{
	if(g_HasRune[attacker] && !is_weapon_sniper(g_WeaponIndex[attacker]))
	{
		return floatround(damage * DamageIncrease)
	}
	return damage
}

public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	g_HasRune[id] = 0
	g_StrenghtRunes--
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	g_HasRune[id] = 1
	g_StrenghtRunes++
}
