/*
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
Gives you 25 extra HP

Credits:
Ops in #AMXmod @ Quakenet for alot of help ( + AssKicker & CheesyPeteza ) 
Thanks to BAILOPAN & PM for help on misc problems
kaddar for orginal runemod

Changelog:
 1.0.0
 	- First release
*/

#include <amxmodx>
#include <fun>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

#define MAX_HEALTH 250
#define Health_Increase 25

public plugin_init() 
{
	register_plugin("RuneMod MedKit", "1.0.0", "EKS")
	// The diffrence between registering this plugin, compared to a "normal" rune, is that the describtion holds the file name of the custom model to use for the rune. Also the color sendt is allways ignored
	RegisterPlugin("MedkitName","models/w_medkit.mdl",{50,125,10},API_PICKUPANDFORGET+API_USELANGSYSTEM)	
}

public API_PickUpRune(id) // This is the function called once someone picks up the rune, notice that there is no drop function in this plugin.
{
	new health = get_user_health(id)
	if(health >= MAX_HEALTH)
		return 0				// If we return 0, that the base plugin is informed that user did not pickup this rune, for whatever reason. In this case that his HP would exceed 250, witch creates bugs 
	else
	{
		health = health + Health_Increase
		if(health > MAX_HEALTH)
			set_user_health(id,MAX_HEALTH)
		else
			set_user_health(id,health)
		return 1		// We send back 1, this means the base plugin removes the rune from the world, and assumes the current user picked it up
	}
	return 0
}
public plugin_precache()
{
	precache_model("models/w_medkit.mdl")		// We precache the model
}
