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
 1.0.0
 	- First release
*/

#include <amxmodx>
#include <fun>
#include <cstrike>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

new g_HasRune[MAXPLAYERS+1]

public plugin_init() 
{
	register_plugin("RuneMod No Primary Weapon", "1.0.0", "EKS")
	RegisterPlugin("NoPrimaryName","NoPrimaryDisc",{50,125,10},API_EVENTCHANGEWEAPON+API_USELANGSYSTEM+API_BADRUNE)	
}
stock CheckWeapon(id,WeaponIndex)
{
	if(IsPrimarlyWeapon(WeaponIndex))
	{
		IsPrimarlyWeapon(WeaponIndex)
		client_cmd(id,"slot1;drop")
		client_print(id,print_chat,"%L",LANG_PLAYER,"NoPrimaryWeaponDroped")
	}
}
public API_CurWeaponChange(id,WeaponIndex)
{
	if(g_HasRune[id] == 1)
	{
		CheckWeapon(id,WeaponIndex)
	}
	return PLUGIN_CONTINUE
}
// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	g_HasRune[id] = 1
	new weapons[32],num
	get_user_weapons(id,weapons,num)
	for(new i=0;i<=num;i++)
	{
		CheckWeapon(id,weapons[i])
	}
}
public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	g_HasRune[id] = 0
}
stock RemovePrimary(id)
{
	//engclient_cmd(id,"drop")
	client_cmd(id,"slot1;drop")
}
stock IsPrimarlyWeapon(WeaponIndex)
{
	if(WeaponIndex == CSW_SCOUT || WeaponIndex == CSW_XM1014 || WeaponIndex == CSW_MAC10 || WeaponIndex == CSW_AUG || WeaponIndex == CSW_UMP45 || 
	WeaponIndex == CSW_SG550 || WeaponIndex == CSW_GALI || WeaponIndex == CSW_GALIL || WeaponIndex == CSW_FAMAS || WeaponIndex == CSW_AWP || 
	WeaponIndex == CSW_MP5NAVY || WeaponIndex == CSW_M249 || WeaponIndex == CSW_M3 || WeaponIndex == CSW_M4A1 || WeaponIndex == CSW_TMP || 
	WeaponIndex == CSW_G3SG1 || WeaponIndex == CSW_SG552 || WeaponIndex == CSW_AK47 || WeaponIndex == CSW_P90)
		return 1
	return 0
}
