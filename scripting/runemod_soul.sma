/*
About:
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
You get 100hp when you kill someone

Credits:
Ops in #AMXmod @ Quakenet for alot of help ( + AssKicker & CheesyPeteza ) 
Thanks to BAILOPAN & PM for help on misc problems
kaddar for orginal runemod
*/

#include <amxmodx>
#include <engine>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

#define HPAfterKill 100.0
#define ShowMsg 1

new g_HasRune[MAXPLAYERS+1] // This is the Array used to store if the user is holding a rune.(Remember the base plugin informs this plugin once he picks up a rune.)
new g_SoulRunes


public plugin_init() 
{
	register_plugin("RuneMod Soul", "1.0.0", "EKS")
	RegisterPlugin("SoulName","SoulDisc",{255,0,0},API_DEATHMSG+API_USELANGSYSTEM)
}
public API_DeathMsg(killer,victim)
{
	if(g_HasRune[killer])
	{
		if(entity_get_float(killer, EV_FL_health) >= 100)
			return;
			
		entity_set_float(killer, EV_FL_health,HPAfterKill)
#if ShowMsg == 1
		new Text[128]
		get_user_name(victim,Text,31)
		format(Text,127,"%L",LANG_PLAYER,"SoulKilled",HPAfterKill,Text)
		HudMessage2(killer,Text)
#endif		
	}
}

public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	g_HasRune[id] = 0
	g_SoulRunes--
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	g_HasRune[id] = 1
	g_SoulRunes++
}
