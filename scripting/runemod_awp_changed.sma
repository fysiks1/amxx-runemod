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
#include <engine>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

new g_HasAWP[MAXPLAYERS+1]
new g_BPluginIndex
new g_BPDisable
new g_BPEnable
new g_RuneIndex

new g_MaxPlayers 
new g_MaxEnts


public plugin_init() 
{
	register_plugin("RuneMod AWP", "1.0.0", "EKS")
	register_clcmd("drop", "cmd_Drop")
	
	g_MaxPlayers = get_maxplayers()
	g_MaxEnts = get_global_int(GL_maxEntities)
	register_event("DeathMsg","Event_DeathMsg","a")
	
	g_BPluginIndex = FindBasePluginIndex()
	g_BPDisable = get_func_id("API_DisableRune",g_BPluginIndex)
	g_BPEnable = get_func_id("API_EnableRune",g_BPluginIndex)

	g_RuneIndex = RegisterPlugin("AWP","models/w_awp.mdl",{50,125,10},API_PICKUPANDFORGET+API_ROUNDSTARTED)
}
public cmd_Drop(id)
{
	if(g_HasAWP[id] == 1)
	{
		g_HasAWP[id] = 0
		remove_task(id)
		set_task(0.1,"Task_EnableRune",id,_,_,"a",1)
	}	
}
public Event_DeathMsg()
{
	new victim = read_data(2)

	if(g_HasAWP[victim] == 1)
	{
		g_HasAWP[victim] = 0
		remove_task(victim)
		set_task(0.1,"Task_EnableRune",victim,_,_,"a",1)
	}
}
// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	new weapons[32],num
	get_user_weapons(id,weapons,num)
	for(new i=0;i<=num;i++)
	{
		if(IsPrimarlyWeapon(weapons[i]))
		{
			return 0
		}
	}

	give_item(id,"weapon_awp")
	cs_set_user_bpammo(id,CSW_AWP,30)
	g_HasAWP[id] = 1
	set_task(0.1,"Task_DisableRune",id,_,_,"a",1)
	return 1
}
public Task_DisableRune()
{
	DisableRune(g_RuneIndex)
}
public Task_EnableRune(id)
{
	EnableRune(g_RuneIndex)
	RemoveAWP()
}

stock RemoveAWP()
{
	new Class[24]
	for(new i=g_MaxPlayers+1;i<=g_MaxEnts;i++) 
	{
		if(is_valid_ent(i))
		{
			entity_get_string(i,EV_SZ_classname,Class,23)
			
			if(equal(Class,"weapon_awp"))
			{
				new Owner = entity_get_edict(i, EV_ENT_owner)
				remove_entity(Owner)
				remove_entity(i)
				break
			}
		}
	}
}
public API_RoundStarted()
{
	for(new i=1;i<=g_MaxPlayers;i++) if(g_HasAWP[i])
	{
		new weapons[32],num
		new HadAWP = 0
		get_user_weapons(i,weapons,num)
		for(new b=0;b<=num;b++)
		{
			if(weapons[b] == CSW_AWP)
			{
				HadAWP = 1
				break
			}
		}
		if(HadAWP == 0)
		{
			g_HasAWP[i] = 0
			EnableRune(g_RuneIndex)
		}
	}
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
stock DisableRune(IndexOfRune)
{
	callfunc_begin_i(g_BPDisable,g_BPluginIndex)
	callfunc_push_int(IndexOfRune)
	callfunc_end()
}
stock EnableRune(IndexOfRune)
{
	callfunc_begin_i(g_BPEnable,g_BPluginIndex)
	callfunc_push_int(IndexOfRune)
	callfunc_end()
}