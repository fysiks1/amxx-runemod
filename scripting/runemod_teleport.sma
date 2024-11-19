/*
About:
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
People loose hp when attacking you

Credits:
Ops in #AMXmod @ Quakenet for alot of help ( + AssKicker & CheesyPeteza ) 
Thanks to BAILOPAN & PM for help on misc problems
kaddar for orginal runemod

Todo:
Nothing spesial planned. Might need to balanced

*/

#include <amxmodx>
#include <engine>
#include <fun>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

#define DISMAY_HP2STEAL 0.50

new g_HasRune[MAXPLAYERS+1] // This is the Array used to store if the user is holding a rune.(Remember the base plugin informs this plugin once he picks up a rune.)
new g_WeaponIndex[MAXPLAYERS+1]
new g_Flags
new g_CanTelePort[MAXPLAYERS+1]

public plugin_init() 
{
	register_plugin("RuneMod Teleport", "1.0.0", "EKS")
	RegisterPlugin("TeleportName","TeleportDisc",{35,190,225},API_EVENTCHANGEWEAPON+API_USELANGSYSTEM)
}

public API_CurWeaponChange(id,WeaponIndex)
{
	g_WeaponIndex[id] = WeaponIndex
	return PLUGIN_CONTINUE
}

public client_PostThink(id)
{
	if(g_HasRune[id] == 1)
	{
		g_Flags = entity_get_int(id,EV_INT_button)

		if(g_Flags & IN_ATTACK && g_CanTelePort[id] == 1 && is_meleeweapon(g_WeaponIndex[id]))
		{
			HudMessage2(id,"Your being teleported back to spawn")
			
			new Float:HP = entity_get_float(id, EV_FL_health)
			new Origin[3]
			get_user_origin(id,Origin)
			MakeTeleport(Origin)

			DispatchSpawn(id)
			entity_set_float(id, EV_FL_health,HP)
			g_CanTelePort[id] = 0
			set_task(5.0,"Task_ReEnableTelePort",id,_,_,"a",1)
		}
	}
}
public Task_ReEnableTelePort(id)
{
	g_CanTelePort[id] = 1	
}
public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	g_HasRune[id] = 0
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	g_HasRune[id] = 1
	g_CanTelePort[id] = 1
}
