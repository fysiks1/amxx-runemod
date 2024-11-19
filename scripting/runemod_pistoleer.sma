/*
About:
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
Your pistols have a extra punsh ( basicly extra damage and knockback)

Credits:
Ops in #AMXmod @ Quakenet for alot of help ( + AssKicker & CheesyPeteza ) 
Thanks to BAILOPAN & PM for help on misc problems
kaddar for orginal runemod

Todo:
No plans

Changelog:
 1.0.1
	- Changed: Color some.
 1.0.0
 	- First release
*/

#include <amxmodx>
#include <engine>
#include <fun>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

#define DamageIncrease 1.2

new g_HasRune[MAXPLAYERS+1] // This is the Array used to store if the user is holding a rune.(Remember the base plugin informs this plugin once he picks up a rune.)
new g_KineticsRunes

public plugin_init() 
{
	register_plugin("RuneMod Pistoleer", "1.0.1", "EKS")
	RegisterPlugin("PistoleerName","PistoleerDisc",{80,125,60},API_EVENTDAMAGE+API_USELANGSYSTEM)	
}

public API_Damage(victim,attacker,damage)
{
	if(!g_HasRune[attacker] || !is_weapon_pistol(attacker,0)) 
		return damage
	else
	{
		new Float:velocity[3]
		VelocityByAim(attacker, 800 , velocity)
		velocity[0] = velocity[0] + float(random_num(-40,40))
		velocity[1] = velocity[1] + float(random_num(-40,40))
		velocity[2] = velocity[2] + float(random_num(-10,10))
		entity_set_vector(victim, EV_VEC_velocity, velocity)
		damage = floatround(damage * DamageIncrease)
		
		new Origin1[3],Origin2[3]
		get_user_origin(attacker,Origin1) 
		get_user_origin(victim,Origin2)
		MakeTracer(Origin1,Origin2)
	}
	return damage
}
stock MakeTracer(Origin1[3],Origin2[3])
{
	message_begin(MSG_PAS, SVC_TEMPENTITY,Origin1 ) 
	write_byte( 6 ) 
	write_coord(Origin1[0]) 
	write_coord(Origin1[1]) 
	write_coord(Origin1[2]) 
	write_coord(Origin2[0]) 
	write_coord(Origin2[1]) 
	write_coord(Origin2[2]) 
	message_end() 	
}

public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	g_KineticsRunes--
	g_HasRune[id] = 0
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	g_KineticsRunes++
	g_HasRune[id] = 1
}
