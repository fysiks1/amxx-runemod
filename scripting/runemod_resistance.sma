/*
About:
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
You resist 50% of the damange dealt to you

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

#define RESIST_AMOUT 0.50
#define ShowMsg 1

new g_HasRune[MAXPLAYERS+1] // This is the Array used to store if the user is holding a rune.(Remember the base plugin informs this plugin once he picks up a rune.)
new g_RestRunes

public plugin_init() 
{
	register_plugin("RuneMod Resistance", "1.0.0", "EKS")
	RegisterPlugin("ResistanceName","ResistanceDisc",{127,10,127},API_EVENTDAMAGE+API_USELANGSYSTEM)
}

public API_Damage(victim,attacker,damage)
{
	if(g_RestRunes == 0 ) return PLUGIN_CONTINUE // If there are no runes ingame, we stop
	
	// If the attacker does not have the vampire rune. Also if the user allready has max hp we stop
	if(g_HasRune[victim])
	{
#if ShowMsg == 1
		new Text[128]
		get_user_name(attacker,Text,31)
		format(Text,127,"%L",LANG_PLAYER,"ResistanceResAmount",floatround(damage * RESIST_AMOUT),Text)
		HudMessage2(victim,Text)
#endif		
		return damage - floatround(damage * RESIST_AMOUT)
	}
	return damage	
}

public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	g_HasRune[id] = 0
	g_RestRunes--
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	g_HasRune[id] = 1
	g_RestRunes++
}
