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
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

new g_HasRune[MAXPLAYERS+1]
new g_LastAmmo[MAXPLAYERS+1]
new g_LastWeapon[MAXPLAYERS+1]


public plugin_init() 
{
	register_plugin("RuneMod No recoil", "1.0.0", "Raheem")
	register_event("CurWeapon", "Event_CurWeapon", "b");

	RegisterPlugin("LowRecoilName","LowRecoilDisc",{150,150,210},API_USELANGSYSTEM)
}


public Event_CurWeapon(id)
{
	if(!g_HasRune[id])
		return PLUGIN_CONTINUE

	new weapon = read_data(2)
	new ammo = read_data(3)

	if(ammo != g_LastAmmo[id])	// We make sure the ammo changed, i cant think of a reason this message would be sendt would some change, but assumtion is the mother of all mistakes 
	{
		if(weapon == g_LastWeapon[id] && ammo < g_LastAmmo[id])		// Its the same weapon, and ammo is lower. He must have shot
		{
			entity_set_vector(id,EV_VEC_punchangle,Float:{0.0,0.0,0.0})
		}
	
		g_LastAmmo[id] = ammo
		g_LastWeapon[id] = weapon 
	}
	return PLUGIN_CONTINUE
}

		
public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	g_HasRune[id] = 0
}

public API_PickUpRune(id)  // This function is used base plugin to inform this plugin that a user has picked up the rune.
{
	g_HasRune[id] = 1
}