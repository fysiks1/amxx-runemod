/*
About:
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
Temporarily gives you unlimited ammo

Credits:
Ops in #AMXmod @ Quakenet for alot of help ( + AssKicker & CheesyPeteza ) 
Thanks to BAILOPAN & PM for help on misc problems
kaddar for orginal runemod

Todo:
No plans

*/

#include <amxmodx>
#include <engine>
#include <cstrike>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks


new g_UnLimAmmo
new g_HasRune[MAXPLAYERS+1] 	// This is the Array used to store if the user is holding a rune.(Remember the base plugin informs this plugin once he picks up a rune.)
new g_MaxEnts
new g_MaxPlayers
new g_RuneDisabled

new g_LastWeaponIndex[MAXPLAYERS+1]
new g_LastWeaponEntNum[MAXPLAYERS+1]

new const gs_WeaponList[31][25] = {" ","weapon_p228"," ","weapon_scout","weapon_hegrenade","weapon_xm1014","weapon_c4","weapon_mac10","weapon_aug","weapon_smokegrenade",
"weapon_elite","weapon_fiveseven","weapon_ump45","weapon_sg550","weapon_galil","weapon_famas","weapon_usp","weapon_glock18","weapon_awp","weapon_mp5navy","weapon_m249",
"weapon_m3","weapon_m4a1","weapon_tmp","weapon_g3sg1","weapon_flashbang","weapon_deagle","weapon_sg552","weapon_ak47","weapon_knife","weapon_p90" }

new g_WeaponMaxAmmo[31] = {0,13,0,10,0,8,0,30,30,0,30,20,25,30,35,25,12,20,10,30,100,8,30,30,20,0,7,30,30,0,50}


public plugin_init() 
{
	register_plugin("RuneMod No Reload", "1.0.0", "EKS")
	register_event("CurWeapon", "Event_CurWeapon", "b");
	g_MaxEnts = get_global_int(GL_maxEntities)
	g_MaxPlayers = get_maxplayers()
	RegisterPlugin("No Reload","You dont have to reload",{220,165,175},API_ROUNDSTARTED+API_NEWROUND)
}
public Event_CurWeapon(id)
{
	if(g_UnLimAmmo == 0 || !g_HasRune[id] || g_RuneDisabled ) return PLUGIN_CONTINUE
	
	new weapon = read_data(2)
	new ammo = read_data(3)
	
	if(weapon == CSW_HEGRENADE ||weapon == CSW_SMOKEGRENADE ||weapon == CSW_KNIFE || weapon == CSW_FLASHBANG || weapon == CSW_C4)
	{
		g_LastWeaponIndex[id] = -1
		return PLUGIN_CONTINUE
	}
		
	if(weapon != g_LastWeaponIndex[id])
	{
		g_LastWeaponEntNum[id] = GenWeaponEntId(id,weapon) //get_user_weaponindex(id)
		g_LastWeaponIndex[id] = weapon
	}
	if(ammo >= g_WeaponMaxAmmo[weapon])
	{
		//client_print(0,print_chat,"Weapon index: %d  ammo %d (Max: %d)  (No Change needed)",weapon,ammo,g_WeaponMaxAmmo[weapon])
		return PLUGIN_CONTINUE
	}

	new bammo = cs_get_user_bpammo(id,weapon)
	if(bammo > 0)
	{
		//client_print(0,print_chat,"Weapon index: %d  ammo %d (Max: %d)  Backpack: %d",weapon,ammo,g_WeaponMaxAmmo[weapon],bammo)
		cs_set_weapon_ammo(g_LastWeaponEntNum[id],ammo+1)			
		cs_set_user_bpammo(id,weapon,bammo-1)
	}
	return PLUGIN_CONTINUE
}
stock SetupWeaponInfo(id)
{
	new weapon = get_user_curweaponindex(id)
	g_LastWeaponEntNum[id] = GenWeaponEntId(id,weapon) //get_user_weaponindex(id)
	g_LastWeaponIndex[id] = weapon	
}
	
public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	g_HasRune[id] = 0
	g_UnLimAmmo--
	if(g_UnLimAmmo == 0) remove_task(128)
}

public API_PickUpRune(id)  // This function is used base plugin to inform this plugin that a user has picked up the rune.
{
	g_HasRune[id] = 1
	g_UnLimAmmo++
	SetupWeaponInfo(id)
}

public API_NewRound()
{
	g_RuneDisabled = 1
}
public API_RoundStarted()
{
	g_RuneDisabled = 0
	for(new i=1;i<=g_MaxPlayers;i++)
		SetupWeaponInfo(i)
}

stock GenWeaponEntId(id,WeaponIndex)
{
	new Class[24]
	for(new i=g_MaxPlayers+1;i<=g_MaxEnts;i++) 
	{
		if(is_valid_ent(i) && entity_get_edict(i, EV_ENT_owner) == id)
		{
			entity_get_string(i,EV_SZ_classname,Class,23)
			if(equal(gs_WeaponList[WeaponIndex],Class))
			{
				return i
			}
		}
	}
	return 0
}
