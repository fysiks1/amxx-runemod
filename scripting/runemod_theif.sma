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
Make it buffer everyonces weapons indexes?

Changelog
 1.1.0
	- Added: Plugin is now using the new CurWeapon system (Witch means this plugin is now optimised alot)
 1.0.0
 	- First release
*/

#include <amxmodx>
#include <engine>
#include <cstrike>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

#define AMMO2STEAL 3

new g_HasRune[MAXPLAYERS+1] 	// This is the Array used to store if the user is holding a rune.(Remember the base plugin informs this plugin once he picks up a rune.)
new g_MaxEnts
new g_MaxPlayers
new g_WarnMessage[MAXPLAYERS+1]
new g_WeapEntIndex[MAXPLAYERS+1]

new const gs_WeaponList[31][25] = {" ","weapon_p228"," ","weapon_scout","weapon_hegrenade","weapon_xm1014","weapon_c4","weapon_mac10","weapon_aug","weapon_smokegrenade",
"weapon_elite","weapon_fiveseven","weapon_ump45","weapon_sg550","weapon_galil","weapon_famas","weapon_usp","weapon_glock18","weapon_awp","weapon_mp5navy","weapon_m249",
"weapon_m3","weapon_m4a1","weapon_tmp","weapon_g3sg1","weapon_flashbang","weapon_deagle","weapon_sg552","weapon_ak47","weapon_knife","weapon_p90" }

public plugin_init() 
{
	register_plugin("RuneMod Theif", "1.1.0", "EKS")
	g_MaxEnts = get_global_int(GL_maxEntities)
	g_MaxPlayers = get_maxplayers()
	RegisterPlugin("TheifName","TheifDisc",{53,150,240},API_EVENTDAMAGEDONE+API_ROUNDSTARTED+API_EVENTCHANGEWEAPON+API_USELANGSYSTEM)
}

public API_CurWeaponChange(id,WeaponIndex)
{
	g_WeapEntIndex[id] = GenWeaponEntId(id,WeaponIndex)
}
public API_DamageDone(victim,attacker,damage)
{
	if(!g_HasRune[attacker]) return PLUGIN_CONTINUE
	
	new winx = get_user_curweaponindex(victim);
	if(winx == CSW_HEGRENADE || winx ==  CSW_SMOKEGRENADE  || winx == CSW_FLASHBANG || winx ==CSW_C4)
		return PLUGIN_CONTINUE;
	
	StealAmmo(victim,attacker)
	if(g_WarnMessage[victim] != attacker)
	{
		new Name[32]
		get_user_name(attacker,Name,31)
		
		client_print(victim,print_chat,"%L",LANG_PLAYER,"TheifStealing",Name)
	}
	return PLUGIN_CONTINUE
}

stock StealAmmo(victim,attacker)
{
	new EntNum = GenWeaponEntId(victim,get_user_curweaponindex(victim) )
	new Ammo = cs_get_weapon_ammo(EntNum)
	Ammo = Ammo - AMMO2STEAL
	if(Ammo < 0) Ammo = 0
	cs_set_weapon_ammo(EntNum,Ammo)
	
	if(Ammo > 0) // This means we stole ammo
	{
		Ammo = cs_get_weapon_ammo(g_WeapEntIndex[attacker])
		Ammo = Ammo + AMMO2STEAL
		cs_set_weapon_ammo(g_WeapEntIndex[attacker],Ammo)
	}
}
		
public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	g_HasRune[id] = 0
	g_WeapEntIndex[id] = 0
}
public API_PickUpRune(id)  // This function is used base plugin to inform this plugin that a user has picked up the rune.
{
	g_HasRune[id] = 1
	g_WeapEntIndex[id] = GenWeaponEntId(id,get_user_weaponindex(id))
}
public API_RoundStarted()
{
	for(new i=1;i<=g_MaxPlayers;i++)
	{
		g_WarnMessage[i] = 0
	}
}
stock GenWeaponEntId(id,WeaponIndex)
{
	new Class[24]
	for(new i=g_MaxPlayers;i<=g_MaxEnts;i++) 
		if(is_valid_ent(i) && entity_get_edict(i, EV_ENT_owner) == id)
		{
			entity_get_string(i,EV_SZ_classname,Class,23)
			if(equal(gs_WeaponList[WeaponIndex],Class))
			{
				return i
			}
		}
	return 0
}
