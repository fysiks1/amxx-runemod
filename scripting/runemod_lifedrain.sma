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

#define DECAY_MINHP 30.0
#define DECAY_AMOUNT 3.0
#define DECAY_TIMER 10.0


public plugin_init() 
{
	register_plugin("RuneMod Life Drain", "1.0.0", "EKS")
	RegisterPlugin("LifeDrainName","LifeDrainDisc",{79,30,40},API_BADRUNE+API_USELANGSYSTEM)
	
}
public Task_HPDecayLoop(id)
{
	new Float: NewHP
	if(entity_get_float(id, EV_FL_health) > DECAY_MINHP) 
	{
		NewHP = entity_get_float(id, EV_FL_health) - DECAY_AMOUNT
	
		if(NewHP < DECAY_MINHP) // If user regened to much HP. We set the MAXHP
			NewHP = DECAY_MINHP
			
		entity_set_float(id, EV_FL_health,NewHP)
	}
	return PLUGIN_CONTINUE
}

public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	remove_task(id)
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	set_task(DECAY_TIMER,"Task_HPDecayLoop",id,_,_,"b")
}
