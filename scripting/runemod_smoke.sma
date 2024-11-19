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
#include "runemod.inc"			// We need to include this file, as it contains info we need. Like #define`s and stocks

#define REDEEM_MINIMALDISTANCE 100.0

new g_HasRune[MAXPLAYERS+1] 		// This is the Array used to store if the user is holding a rune.(Remember the base plugin informs this plugin once he picks up a rune.)
new g_ActiveRunes = 0
new g_MaxPlayers
new g_RuneDisabled

public plugin_init() 
{
	register_plugin("RuneMod Smoke", "1.0.0", "EKS")
	g_MaxPlayers = get_maxplayers()
	RegisterPlugin("SmokeName","SmokeDisc",{127,75,255},API_USELANGSYSTEM)
}

public Task_AddSmoke()
{
	if(g_RuneDisabled == 1)
		return PLUGIN_CONTINUE
		
	for(new i=1;i<=g_MaxPlayers;i++)
	{
		if(g_HasRune[i] == 1)
		{
			new Origin[3],NewOrigin[3]
			get_user_origin(i,Origin)
			new Smoke2Add = random_num(1,5)
			
			for(new b=0;b<=Smoke2Add;b++)
			{
				NewOrigin[0] = Origin[0]
				NewOrigin[1] = Origin[1]
				NewOrigin[2] = Origin[2]

				NewOrigin[0] += random_num(-50,50)
				NewOrigin[1] += random_num(-50,50)
				NewOrigin[2] += random_num(-15,15)
				
				MakeSmoke(0,NewOrigin)
			}
		}
	}
	return PLUGIN_CONTINUE
}

public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	g_HasRune[id] = 0
	g_ActiveRunes--
	if(g_ActiveRunes == 0)
		remove_task(512)
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	g_HasRune[id] = 1
	g_ActiveRunes++
	
	if(g_ActiveRunes == 1)
		set_task(0.5,"Task_AddSmoke",512,_,_,"b")
}
public API_NewRound()
{
	g_RuneDisabled =1 
}
public API_RoundStarted()
{
	g_RuneDisabled=0
}
