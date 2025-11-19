/***************************************************************
	Stealth Assassin
	Author: TaRgEt*TuRkEy (Code From Rabid Baboon & MMX)
	Version: 1.3
	Mod: Counter-Strike
	Requires: AMX Mod X v1.0 
	Description: 
		This plugin allows players to enter "stealth" when
		using the knife. Players gain the ability to lose
		visibility, enable one hit kills with knife, have
		no footstep sounds, gain extra speed, and have third 
		person view. Most of these abilities are configurable 
		with the commands.
	
	Notes:
		Thanks to Rabid Baboon and Firestorm for the one
		hit knife kills code and suicide block. Thanks
		to MMX for the invisibility code. Thanks to
		AssKicR for no footstep sounds.
		
		One Hit Knife Kills by Rabid Baboon: 
		http://amxmodx.org/forums/viewtopic.php?t=8257

		Weapon Cloak by MMX (AMX): 
		http://amxmod.net/showplugin.php?id=167518

	Cvars:

	amx_stealthvalue <0-255>
		-Changes how visible you are when stealthing.
	amx_stealth3rdperson <0 or 1>
		-Set to 0 if you don't want players turning to
		 third person view when using knife.
	amx_stealthonehitkill <0 or 1>
		-Switches to turn one hit knife kills off or on.

***************************************************************/

#include <amxmodx> 
#include <amxmisc> 
#include <fun>
#include <csx>
#include <engine>
#include <fakemeta>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

new Title[32] = "Stealth Assassin"
new Version[32] = "1.3.0"
new Author[16] = "TaRgEt*TuRkEy"
new knifekill = 0

new g_HasRune[MAXPLAYERS+1] 	// This is the Array used to store if the user is holding a rune.(Remember the base plugin informs this plugin once he picks up a rune.)

//This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
public API_DropedRune(id,Reason)
{
	g_HasRune[id] = 0
	BackToNorm(id)
	
	if(Reason != USER_DISCONNECTED)
		BackToNorm(id)

}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id)
{
	g_HasRune[id] = 1
	
	new WeaponIndex = get_user_weapon(id) 

	if(WeaponIndex == 29) 
	{
		if(is_user_alive(id))
			AlterAlpha(id,get_cvar_num("amx_stealthvalue"))
	} 
}

public client_damage(attacker, victim, damage, wpnindex, hitplace, TA)
{	
	if(!g_HasRune[attacker])
		return PLUGIN_CONTINUE

	if(get_cvar_num("amx_stealthonehitkill")==1)
	{
		if(is_user_alive(victim))
		{
			if(attacker != victim) //prevents killing self with knife from fall damage.
			{
				if(wpnindex == CSW_KNIFE && TA != 1)
				{
					knifekill = 1
					if(hitplace == HIT_HEAD)
					{
						make_deathmsg(attacker, victim, 1, "knife")
					}
					else
					{
						make_deathmsg(attacker, victim, 0, "knife")
					}
					user_silentkill(victim)
					set_user_frags(attacker, get_user_frags(attacker)+1)
				}
			}
		}
	}
			
	return PLUGIN_HANDLED
}

public blocksuicide(at_type, message[])
{
	if(containi(message,"suicide") > -1 && containi(message,"world") > -1 && knifekill == 1)
	{
		knifekill = 0
		return FMRES_SUPERCEDE
	}
	return PLUGIN_CONTINUE
}  

public SetVisibility(id)
{ 
	if(!g_HasRune[id])
		return PLUGIN_CONTINUE
		
	new wepi = read_data(2)
	
	BackToNorm(id)

	if(wepi == 29 && g_HasRune[id]) 
	{
		if(is_user_alive(id))
			AlterAlpha(id,get_cvar_num("amx_stealthvalue"))
	} 
	else 
	{
		BackToNorm(id)
	}
	
	return PLUGIN_HANDLED
}

public BackToNorm(id)
{
	set_user_footsteps(id,0)
	set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,255)
	set_hudmessage(200, 100, 0, -2.0, 0.20, 0, 6.0, 6.0, 0.5, 0.15, 4)
	show_hudmessage(id,"")
	set_view(id, CAMERA_NONE)
}

public AlterAlpha(id,alphaVal)
{
	set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,alphaVal)
	set_hudmessage(200, 100, 0, -2.0, 0.20, 0, 6.0, 99999.0, 0.5, 0.15, 4)
	show_hudmessage(id,"You are stealthing!")
	set_user_footsteps(id,1)
	
	if(get_cvar_num("amx_stealth3rdperson")==1)
		set_view(id, CAMERA_3RDPERSON)
}

public plugin_init() 
{ 
	register_plugin(Title,Version,Author)
	
	RegisterPlugin("Stealth_AssassinName","Stealth_AssassinDesc",{10,75,10},API_USELANGSYSTEM)

	register_event("CurWeapon","SetVisibility","b","1=1")
	register_forward(FM_AlertMessage,"blocksuicide")
	register_cvar("amx_stealthvalue","170")
	register_cvar("amx_stealthonehitkill","1")
	register_cvar("amx_stealth3rdperson","0")

	return PLUGIN_HANDLED 
}

public plugin_precache() 
{	
	//Fixes set_view bug that needs this model on map change
	precache_model("models/rpgrocket.mdl")
	return PLUGIN_CONTINUE
}
