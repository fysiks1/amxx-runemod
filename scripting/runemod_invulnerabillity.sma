/*
About:
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
Increases your maxpspeed by 100%

Credits:
Ops in #AMXmod @ Quakenet for alot of help ( + AssKicker & CheesyPeteza ) 
Thanks to BAILOPAN & PM for help on misc problems
kaddar for orginal runemod

Todo:
No plans
*/

#include <amxmodx>
#include <engine>
#include <fun>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

#define MAXSPEED 1.50			// How much to add to the max speed
#define DamageIncrease 1.3

#define POWER_COOLDOWN 2
#define POWER_ACTIVE 1
#define POWER_READY 0

#define COOLDOWN_TIME 20
#define POWER_ACTIVE_TIME 5

new g_MaxPlayers
new g_InvulRunes
new g_HasRune[MAXPLAYERS+1] 	// This is the Array used to store if the user is holding a rune.(Remember the base plugin informs this plugin once he picks up a rune.)
new g_SpeedLocked[MAXPLAYERS+1]
new g_PowerState[MAXPLAYERS+1]
new g_WeaponIndex[MAXPLAYERS+1]
new g_CoolDownLeft[MAXPLAYERS+1]

public plugin_init() 
{
	register_plugin("RuneMod Invulnerabillity", "1.0.0", "EKS")
	g_MaxPlayers = get_maxplayers()
	RegisterPlugin("InvulnerabillityName","InvulnerabillityDesc",{57,30,250},API_SPEEDCHANGE+API_ROUNDSTARTED+API_EVENTCHANGEWEAPON+API_EVENTDAMAGE+API_USELANGSYSTEM)
}
public API_Damage(victim,attacker,damage)
{
	if(g_HasRune[attacker] && is_meleeweapon(g_WeaponIndex[attacker]) && g_PowerState[attacker] == POWER_READY)
	{
		return floatround(damage * DamageIncrease)
	}
	return damage
}

public Task_ShowPowerState()
{
	for(new i=1;i<=g_MaxPlayers;i++) if(g_HasRune[i])
	{
		if(g_PowerState[i] == POWER_COOLDOWN)
		{	
			g_CoolDownLeft[i]--
			new Message[60]
			format(Message,59,"%L",i,"PowerStateCoolDown",(g_CoolDownLeft[i]))
			HudMessage2(i,Message)
			if(g_CoolDownLeft[i] == 0) g_PowerState[i] = POWER_READY
		}		
		else if(g_PowerState[i] == POWER_ACTIVE)
		{	
			g_CoolDownLeft[i]--
			new Message[60]
			format(Message,59,"%L",i,"InvulnerabillityRage",(g_CoolDownLeft[i]))
			HudMessage2(i,Message)
			if(g_CoolDownLeft[i] == 0) StopPower(i)
		}
		else if(g_PowerState[i] == POWER_READY)
		{
			new Message[60]
			format(Message,59,"%L",i,"PowerStateReady")			
			HudMessage2(i,Message)
		}
	}
}
public API_CurWeaponChange(id,WeaponIndex)
{
	g_WeaponIndex[id] = WeaponIndex
	if(g_PowerState[id] == POWER_READY && is_meleeweapon(WeaponIndex))
	{
		StartPower(id)
	}
	else if(g_PowerState[id] == POWER_ACTIVE)
	{
		StopPower(id)
	}	
	return PLUGIN_CONTINUE
}

public API_UnLockSpeedChange(id)
{
	g_SpeedLocked[id] = 0
}
public API_LockSpeedChange(id)
{
	g_SpeedLocked[id] = 1
}

public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	g_InvulRunes--
	if(g_InvulRunes == 0) remove_task(128)
	if(g_PowerState[id] == POWER_ACTIVE)
		StopPower(id)
	g_HasRune[id] = 0
	if(Reason == USER_DISCONNECTED)
		g_PowerState[id] = POWER_READY
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	g_InvulRunes++
	if(g_InvulRunes == 1) set_task(1.0,"Task_ShowPowerState",128,_,_,"b")	
	g_HasRune[id] = 1
}
public API_RoundStarted()
{
	for(new i=1;i<=g_MaxPlayers;i++)
	{
		g_PowerState[i] = POWER_READY
	}
}
stock StartPower(id)
{
	client_print(id,print_chat,"%L",LANG_PLAYER,"InvulnerabillityPowerActive")
	new Message[64]
	format(Message,59,"%L",id,"InvulnerabillityRage",POWER_ACTIVE_TIME)

	HudMessage2(id,Message)
	
	if(is_user_connected(id))
	{
		if(!g_SpeedLocked[id])
			set_user_maxspeed(id,(get_user_maxspeed(id) * MAXSPEED))
		
		set_user_hitzones(0,id,0)
		set_rendering(id,kRenderFxGlowShell, 255,0,0,kRenderNormal,16)
	}
	g_PowerState[id] = POWER_ACTIVE
	g_CoolDownLeft[id] = POWER_ACTIVE_TIME
}
stock StopPower(id)
{
	client_print(id,print_chat,"%L",LANG_PLAYER,"InvulnerabillityPowerDeactive")
	
	new Message[60]
	format(Message,59,"%L",id,"PowerStateCoolDown",COOLDOWN_TIME)

	HudMessage2(id,Message)
	if(!g_SpeedLocked[id])
		ResetUserSpeed(id)
	
	set_user_hitzones(0,id,255)
	set_rendering(id,kRenderFxNone, 0,0,0,kRenderNormal,16)
	
	g_PowerState[id] = POWER_COOLDOWN
	g_CoolDownLeft[id] = COOLDOWN_TIME
}
