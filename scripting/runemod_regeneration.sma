/*
About:
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
Your HP regeneration up to 160

Credits:
Ops in #AMXmod @ Quakenet for alot of help ( + AssKicker & CheesyPeteza ) 
Thanks to BAILOPAN & PM for help on misc problems
kaddar for orginal runemod

Todo:
No plans
 1.0.1
	- Fixed: HP never reaching the max
 1.0.0
 	- First release
*/

#include <amxmodx>
#include <engine>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

#define REGEN_MAXHP 160.0
#define REGEN_TIMER 2.0
#define REGEN_AMOUNT 3.0		// self heal
#define StartHP 100.0
#define REGEN_AMOUNTOTHERS 2.0
#define REGEN_DISTANCE 200.0

new g_MaxPlayers 

public plugin_init() 
{
	register_plugin("RuneMod Regeneration", "1.0.0", "EKS")
	RegisterPlugin("RegenerationName","RegenerationDisc",{79,30,40},API_USELANGSYSTEM)
	
	g_MaxPlayers = get_maxplayers()
}
public Task_HPRegenLoop(id)
{
	new Float: NewHP
	if(entity_get_float(id, EV_FL_health) < REGEN_MAXHP) 
	{
		NewHP = entity_get_float(id, EV_FL_health) + REGEN_AMOUNT
	
		if(NewHP >= REGEN_MAXHP) // If user regened to much HP. We set the MAXHP
			NewHP = REGEN_MAXHP
		entity_set_float(id, EV_FL_health,NewHP)
	}
	
	new Team = get_user_team(id)

	for(new i=1;i<=g_MaxPlayers;i++) if(get_user_team(i) == Team && is_user_alive(i) && i != id && entity_range(id,i) <= REGEN_DISTANCE)
	{
		NewHP = entity_get_float(i, EV_FL_health) + REGEN_AMOUNTOTHERS
		
		if(NewHP >= StartHP) // If user regened to much HP. We set the MAXHP
			NewHP = StartHP

		entity_set_float(i, EV_FL_health,NewHP)
	}
	return PLUGIN_CONTINUE
}

public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	if(entity_get_float(id, EV_FL_health) > StartHP) entity_set_float(id, EV_FL_health,StartHP)
	remove_task(id)
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	set_task(REGEN_TIMER,"Task_HPRegenLoop",id,_,_,"b")
}
