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

#define COOLDOWNTIME 20.0
#define UNLIMITEDTIME 5

new g_UnLimAmmo
new g_HasRune[MAXPLAYERS+1] 	// This is the Array used to store if the user is holding a rune.(Remember the base plugin informs this plugin once he picks up a rune.)
new g_MaxEnts
new g_MaxPlayers
new g_RuneDisabled

new g_LastAmmo[MAXPLAYERS+1][5]
// [0] 0 = Means we are checking if the ammo is going down
// [0] 1 = Means we are in Infinent ammo
// [0] 2 = Means we are in cool down

// [1] = Contains the Ammo count
// [2] = Contains weapons id
// [3] = EntNum
// [4] = Contains the cooldown time ( a counter.)

new const gs_WeaponList[31][25] = {" ","weapon_p228"," ","weapon_scout","weapon_hegrenade","weapon_xm1014","weapon_c4","weapon_mac10","weapon_aug","weapon_smokegrenade",
"weapon_elite","weapon_fiveseven","weapon_ump45","weapon_sg550","weapon_galil","weapon_famas","weapon_usp","weapon_glock18","weapon_awp","weapon_mp5navy","weapon_m249",
"weapon_m3","weapon_m4a1","weapon_tmp","weapon_g3sg1","weapon_flashbang","weapon_deagle","weapon_sg552","weapon_ak47","weapon_knife","weapon_p90" }


public plugin_init() 
{
	register_plugin("RuneMod Unlimited Ammo", "1.0.0", "EKS")
	register_event("CurWeapon", "Event_CurWeapon", "b");
	g_MaxEnts = get_global_int(GL_maxEntities)
	g_MaxPlayers = get_maxplayers()
	RegisterPlugin("UnlimitedAmmoName","UnlimitedAmmoDesc",{103,165,200},API_ROUNDSTARTED+API_NEWROUND+API_USELANGSYSTEM)
}

public plugin_modules() 
{ 
	require_module("cstrike")
} 

public Task_ShowPowerState()
{
	for(new i=1;i<=g_MaxPlayers;i++) if(g_HasRune[i])
	{
		if(g_LastAmmo[i][0] == 0)
		{
			new message[64]
			format(message,63,"%L",i,"PowerStateReady")
			HudMessage2(i,message)
		}
		else if(g_LastAmmo[i][0] == 2)
		{
			new message[64]
			format(message,63,"%L",i,"PowerStateCoolDown",COOLDOWNTIME)			
			HudMessage2(i,message)
		}
	}
}

public Event_CurWeapon(id)
{
	if(g_UnLimAmmo == 0 || !g_HasRune[id] || g_LastAmmo[id][0] == 2 || g_RuneDisabled ) return PLUGIN_CONTINUE
	new weapon = read_data(2)
	new ammo = read_data(3)
	if(weapon == CSW_HEGRENADE ||weapon == CSW_SMOKEGRENADE ||weapon == CSW_KNIFE ||weapon == CSW_FLASHBANG)
		return PLUGIN_CONTINUE
		
	else if(g_LastAmmo[id][0] == 1)	// The user is currently in his unlimited ammo
	{
		if(g_LastAmmo[id][2] == weapon) // He is still holding the same gun. We fix his ammo
		{
			// new Name[32]
			// get_user_name(id,Name,31)
			// client_print(0,3,"%s ammo is set: %d (was %d)",Name,g_LastAmmo[id][1],ammo)		// Debug
			cs_set_weapon_ammo(g_LastAmmo[id][3],g_LastAmmo[id][1])			
		}
		else // The user has changed guns, so we abort and start cooldown
		{
			g_LastAmmo[id][0] = 2
			set_task(COOLDOWNTIME,"Task_EndCoolDown",id,_,_,"a",1)
			client_print(id,print_chat,"%L",LANG_PLAYER,"UnlimitedAmmoSwitchedWeapon")
		}
		return PLUGIN_CONTINUE
	}
	else if(ammo == (g_LastAmmo[id][1]-1) && g_LastAmmo[id][0] == 0 && g_LastAmmo[id][2] == weapon) // Lets start U
	{
		StartPower(id)
		client_print(id,3,"%L",LANG_PLAYER,"UnlimitedAmmoStart")
		g_LastAmmo[id][1] = ammo
		g_LastAmmo[id][0] = 1
		return PLUGIN_CONTINUE
	}
	else
	{
		// client_print(0,3,"Saving info ammo %d lastammo %d",ammo,g_LastAmmo[id][1])
		g_LastAmmo[id][1] = ammo
		g_LastAmmo[id][2] = weapon
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}
public Task_UsingPower(id)
{
	g_LastAmmo[id][4]--
	if(g_LastAmmo[id][4] > 0)
	{
		new message[128]
		format(message,127,"%L",LANG_PLAYER,"PowerStateActive",g_LastAmmo[id][4])
		HudMessage2(id,message)
	}
	else
	{
		g_LastAmmo[id][0] = 2
		set_task(COOLDOWNTIME,"Task_EndCoolDown",id,_,_,"a",1)
	}
}

stock StartPower(id)
{
	g_LastAmmo[id][0] = 2
	g_LastAmmo[id][3] = GenWeaponEntId(id,get_user_weaponindex(id))
	g_LastAmmo[id][4] = UNLIMITEDTIME
	set_task(1.0,"Task_UsingPower",id,_,_,"b")
}
public Task_EndCoolDown(id)
{
	RestPowerUp(id)
}
		
public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	RestPowerUp(id)
	g_HasRune[id] = 0
	g_UnLimAmmo--
	if(g_UnLimAmmo == 0) remove_task(128)
}

public API_PickUpRune(id)  // This function is used base plugin to inform this plugin that a user has picked up the rune.
{
	g_HasRune[id] = 1
	g_UnLimAmmo++
	if(g_UnLimAmmo == 1) set_task(1.0,"Task_ShowPowerState",128,_,_,"b")
}
stock RestPowerUp(id)
{
	g_LastAmmo[id][0] = 0
	g_LastAmmo[id][1] = 0
	g_LastAmmo[id][2] = 0
	g_LastAmmo[id][3] = 0
	remove_task(id)	
}
public API_NewRound()
{
	g_RuneDisabled = 1
	for(new i=1;i<=g_MaxPlayers;i++) if(g_HasRune[i])
		RestPowerUp(i)
}
public API_RoundStarted()
{
	g_RuneDisabled = 0
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
