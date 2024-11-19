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
#include <fun>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

new g_HasRune[MAXPLAYERS +1]
public plugin_init() 
{
	register_plugin("RuneMod Concret Boots", "1.0.0", "EKS")
	RegisterPlugin("ConcretBootsName","ConcretBootsDisc",{250,190,80},API_BADRUNE+API_USELANGSYSTEM)
	
	register_event("CurWeapon", "Event_CurWeapon", "b");
}
public Event_CurWeapon(id)
{
	if(g_HasRune[id] == 1)
	{
		set_user_maxspeed(id,1.0)
	}
	return PLUGIN_CONTINUE
}
public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	g_HasRune[id] = 0
	UnLockSpeed(id)
}
public API_PickUpRune(id) 
{
	StopPlayer(id)
}
stock StopPlayer(id)
{
	g_HasRune[id] = 1
	LockSpeed(id)
	set_user_maxspeed(id,1.0)
	client_print(id,print_chat,"%L",id,"ConcretBootsActive")
}
