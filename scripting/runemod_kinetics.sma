/*
About:
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
Holding the knife gives you flight, and shoting ppl with a pistol you steal money

Credits:
Ops in #AMXmod @ Quakenet for alot of help ( + AssKicker & CheesyPeteza ) 
Thanks to BAILOPAN & PM for help on misc problems
kaddar for orginal runemod

Todo:
Nothing planned

Changelog:
 1.0.0
 	- First release
*/

#include <amxmodx>
#include <cstrike>
#include <engine>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

#define Task_Time 0.5
#define Money2steal 50
#define MAX_MONEY 16000
#define UpSpeedIncrease 280.0

new Float:Vec[3]
new g_HasRune[MAXPLAYERS+1]
new g_WeaponIndex[MAXPLAYERS+1]
new g_WasAirBorn

public plugin_init() 
{
	register_plugin("RuneMod Kinetics", "1.0.0", "EKS")
	RegisterPlugin("KineticsName","KineticsDesc",{150,45,80},API_EVENTCHANGEWEAPON+API_EVENTDAMAGEDONE+API_USELANGSYSTEM)
}
public Task_StartFlying(id)
{
	if(IsOnTheGround(id))
	{
		g_WasAirBorn = 1
		entity_get_vector(id,EV_VEC_velocity,Vec)
		if(Vec[2] <= UpSpeedIncrease)
		{
			Vec[2] = random_float(260.0,280.0)
			entity_set_vector(id, EV_VEC_velocity, Vec)
			entity_set_float(id, EV_FL_gravity, 0.8)
		}
	}
	else if(g_WasAirBorn == 1)
	{
		g_WasAirBorn = 0
		entity_set_float(id, EV_FL_gravity, 1.0)
	}
}

public API_DamageDone(victim,attacker,damage)
{
	if(g_HasRune[attacker] == 1 && (is_meleeweapon(g_WeaponIndex[attacker]) || is_weapon_pistol(g_WeaponIndex[attacker])))
	{
		new vMoney = cs_get_user_money(victim)
		new aMoney = cs_get_user_money(attacker)
		if(vMoney <= Money2steal || aMoney >= MAX_MONEY)
		{
			new vName[32]
			get_user_name(victim,vName,31)
			
			if(vMoney <= Money2steal)
				client_print(attacker,print_chat,"%L",LANG_PLAYER,"KineticsNoAmmo",vName)
			else
				client_print(attacker,print_chat,"%L",LANG_PLAYER,"KineticsAmmoFull",MAX_MONEY,vName)
			return PLUGIN_CONTINUE			
		}
		else
		{
			new vName[32],aName[32]

			get_user_name(victim,vName,31)
			get_user_name(attacker,aName,31)

			client_print(attacker,print_chat,"%L",LANG_PLAYER,"KineticsStole",Money2steal,vName)
			client_print(victim,print_chat,"%L",LANG_PLAYER,"KineticsStoleFromPlayer",aName,Money2steal)
			
			aMoney = aMoney + Money2steal
			if(aMoney > MAX_MONEY)
				aMoney = MAX_MONEY

			cs_set_user_money(attacker,(aMoney))
			cs_set_user_money(victim,(vMoney-Money2steal))
			return PLUGIN_CONTINUE
		}
	}
	return PLUGIN_CONTINUE
}

public API_CurWeaponChange(id,WeaponIndex)
{
	g_WeaponIndex[id] = WeaponIndex
	if(is_meleeweapon(WeaponIndex))
	{
		set_task(Task_Time,"Task_StartFlying",id,_,_,"b")
	}
	else 
		remove_task(id)
	return PLUGIN_CONTINUE
}

public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	remove_task(id)
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	g_HasRune[id] = 1
	g_WeaponIndex[id] = 0
	if(is_meleeweapon(id,0))
	{
		set_task(Task_Time,"Task_StartFlying",id,_,_,"b")
	}	
}
stock IsOnTheGround(id)
{
	new flags = entity_get_int(id,EV_INT_flags)
	if(flags & FL_ONGROUND)
		return 0
	return 1
	
}
