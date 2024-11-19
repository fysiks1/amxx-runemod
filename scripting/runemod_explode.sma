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
#include <engine>
#include <fun>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

#define MaxDmg 130
#define ExplRange 250.0

#define DmgPrPoint = ExplRange / StartDMG
new g_HasRune[MAXPLAYERS+1] // This is the Array used to store if the user is holding a rune.(Remember the base plugin informs this plugin once he picks up a rune.)
new g_MaxPlayers

public plugin_init() 
{
	register_plugin("RuneMod Self Explode", "1.0.0", "EKS")
	g_MaxPlayers = get_maxplayers()
	RegisterPlugin("SelfExplodeName","Self ExplodeDisc",{250,190,80},API_BADRUNE+API_USELANGSYSTEM)
}
public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	g_HasRune[id] = 0
}
public API_PickUpRune(id) 
{
	g_HasRune[id] = 1
	MakeExplotion(id)
}
stock MakeExplotion(id)
{
	user_kill(id)
	new Origin[3]
	new Team = get_user_team(id)
	new Float:Dist

	get_user_origin(id,Origin)
	for(new i=0;i<=3;i++)
	{
		MakeExpl(id,Origin)
		MakeSmoke(id,Origin)
	}

	for(new i=1;i<=g_MaxPlayers;i++) if(is_user_alive(i) && get_user_team(i) != Team)
	{
		Dist = entity_range(id,i)
		if(Dist < ExplRange)
		{
			RadiusDmg(id,i,Dist)				
		}
	}
}

stock RadiusDmg(attacker,victim,Float:Dist)
{
	new Float:Dmg = MaxDmg * (1 - Dist/ExplRange)
	
	new Float:HP = entity_get_float(victim, EV_FL_health)
	if(HP > Dmg)
	{
		entity_set_float(victim, EV_FL_health,(HP-Dmg))
		
		new Name[32]
		get_user_name(victim,Name,31)
		client_print(attacker,print_chat,"You did %.0f Damage on %s",Dmg,Name)	
	}
	else
		RegisterKill(attacker,victim,"Self Exp")
}
