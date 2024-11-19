/*
About:
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
When you go bellow 50 in HP you have a teleported away

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

#define REDEEM_MINIMALDISTANCE 100.0

new g_HasRune[MAXPLAYERS+1] // This is the Array used to store if the user is holding a rune.(Remember the base plugin informs this plugin once he picks up a rune.)
new g_MaxPlayers

public plugin_init() 
{
	register_plugin("RuneMod Redeem", "1.0.1", "EKS")
	g_MaxPlayers = get_maxplayers()
	RegisterPlugin("RedeemName","RedeemDisc",{20,255,127},API_EVENTDAMAGEDONE+API_USELANGSYSTEM)
}

public API_DamageDone(victim,attacker,damage)
{

	if(g_HasRune[victim])
	{
		if(entity_get_float(victim,EV_FL_health) <= 50.0 && !task_exists(victim,1))
		{	
			set_task(0.1,"Task_MovePlayer",victim,_,_,"a",1)
			return PLUGIN_CONTINUE
		}
	}
	return PLUGIN_CONTINUE
}
public Task_MovePlayer(id)
{
	if(!is_user_alive(id)) return PLUGIN_CONTINUE
	new Team = get_user_team(id)
	new TelePortTo=0
	for(new i=1;i<=g_MaxPlayers;i++)
	{
		if(i != id && Team == get_user_team(i) && is_user_alive(i) && entity_range(i,id) >= REDEEM_MINIMALDISTANCE)
		{
			{
				new Float:Origin[3]
				entity_get_vector(i,EV_VEC_origin,Origin)
				Origin[2] = Origin[2] +20.0		
				
				for(new b=0;b<=2;b++)
				{
					if(random_num(0,1) == 1)
					{
						Origin[0] = Origin[0] + random_float(20.0,50.0)
						Origin[1] = Origin[1] + random_float(20.0,50.0)
					}
					else
					{
						Origin[0] = Origin[0] + random_float(-50.0,-20.0)
						Origin[1] = Origin[1] + random_float(-50.0,-20.0)
					}
					
					if(CheckVectorContent(Origin) == 1)
					{	
						TelePortTo = i
						break
					}
				}
				if(TelePortTo)
				{
					new IntOrigin[3]
					IntOrigin[0] = floatround(Origin[0])
					IntOrigin[1] = floatround(Origin[1])
					IntOrigin[2] = floatround(Origin[2])
					MakeTeleport(IntOrigin)

					get_origin(id,IntOrigin)
					entity_set_vector(id,EV_VEC_origin,Origin)
					client_print(id,print_chat,"%L",LANG_PLAYER,"RedeemTelepAway")
					MakeExpl(0,IntOrigin)
					MakeSmoke(0,IntOrigin)
					MakeSmoke(0,IntOrigin)					
					return PLUGIN_CONTINUE
				}
			}
		}
	}
	return PLUGIN_CONTINUE
}

public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	g_HasRune[id] = 0
	remove_task(id)
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	g_HasRune[id] = 1
}
stock CheckVectorContent(Float:Origin[3])	// This function check how close a rune spawnpoint is to other rune spawnpoints. And removes any that witin MIN_DISTANCE_BETWEEN_RUNES ( runemod.inc )
{
	if(point_contents(Origin) != CONTENTS_EMPTY)
		return 0
	
	Origin[0] += 5.0	
	if(point_contents(Origin) != CONTENTS_EMPTY)
		return 0

	Origin[0] -= 10.0	
	if(point_contents(Origin) != CONTENTS_EMPTY)
		return 0

	Origin[0] += 5.0
	Origin[1] += 5.0
	if(point_contents(Origin) != CONTENTS_EMPTY)
		return 0

	Origin[1] -= 10.0
	if(point_contents(Origin) != CONTENTS_EMPTY)
		return 0
		
	Origin[1] += 5.0
	Origin[2] += 5.0
	if(point_contents(Origin) != CONTENTS_EMPTY)
		return 0

	Origin[2] -= 10.0
	if(point_contents(Origin) != CONTENTS_EMPTY)
		return 0		
	return 1
}
