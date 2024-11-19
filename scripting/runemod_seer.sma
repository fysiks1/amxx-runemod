/*
About:
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
Holding the knifes shows a line to the closes enemy

Credits:
Ops in #AMXmod @ Quakenet for alot of help ( + AssKicker & CheesyPeteza ) 
Thanks to BAILOPAN & PM for help on misc problems
kaddar for orginal runemod

Todo:
No plans

Changelog
 1.1.0
	- Added: Plugin is now using the new CurWeapon system 
 1.0.0
 	- First release
*/

#include <amxmodx>
#include <engine>

#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

#define MAXDISTANCE 5000.0
#define BEAMUPDATETIMER 1.0

#define TE_KILLBEAM 99 
#define TE_BEAMENTPOINT 1

new g_HasRune[MAXPLAYERS+1] // This is the Array used to store if the user is holding a rune.(Remember the base plugin informs this plugin once he picks up a rune.)
new g_MaxPlayers
new g_SpriteIndex
new Float:gf_ShortestDist

public plugin_init() 
{
	register_plugin("RuneMod Seer", "1.1.0", "kaddar")
	RegisterPlugin("SeerName","SeerDisc",{255,255,255},API_EVENTCHANGEWEAPON+API_USELANGSYSTEM)
	g_MaxPlayers = get_maxplayers()
}
public plugin_precache() 
{
	g_SpriteIndex = precache_model("sprites/zbeam5.spr")
}
public API_CurWeaponChange(id,WeaponIndex)
{
	if(is_meleeweapon(WeaponIndex))
	{
		UpdateBeam(id)
		if(!task_exists(id,1))
			set_task(BEAMUPDATETIMER,"Task_UpdateBeam",id,_,_,"b")
	}
	else
	{
		RemoveBeam(id)
		remove_task(id)
	}
	return PLUGIN_CONTINUE
}
public Task_UpdateBeam(id)
{
	UpdateBeam(id)
}

stock UpdateBeam(id)
{
	RemoveBeam(id)
	new Float:Origin[3]
	entity_get_vector(id,EV_VEC_origin,Origin)
	new ClosestIndex = FindClosesFI(id,Origin)
	if(ClosestIndex)
		DrawBeam(id,ClosestIndex)	
}

stock FindClosesFI(id,Float:Origin[3])
{
	new Team = get_user_team(id)
	new Float:NewOrigin[3]
	gf_ShortestDist = MAXDISTANCE
	new ShortestDistIndex
	new Float:Dist
	for(new i=1;i<=g_MaxPlayers;i++) if(is_user_alive(i) && Team != get_user_team(i))
	{
		entity_get_vector(i,EV_VEC_origin,NewOrigin)
		Dist = vector_distance(NewOrigin,Origin)
		if(Dist <= gf_ShortestDist)
		{
			gf_ShortestDist = Dist
			ShortestDistIndex = i
		}
	}
	return ShortestDistIndex
}
stock RemoveBeam(id)
{
	message_begin( MSG_ONE, SVC_TEMPENTITY,{0,0,0},id )
	write_byte( TE_KILLBEAM )
	write_short( id)
	message_end() 
}			
stock DrawBeam(id,ClosestIndex)		// This is the function that draws the beam, The code here is 99% from kaddars orignal runemod ( 1.0.170)	
{
	new width
	new brightness
	new Float:seerpower
	new Origin[3]
	
	get_origin(ClosestIndex,Origin)
	
	seerpower = 1.0 - gf_ShortestDist / MAXDISTANCE
	brightness = floatround(floatsqroot (seerpower)*255.0)
	width = floatround(floatsqroot (seerpower)*60.0)
	if (brightness < 0)
		brightness = 0
	if (width<0)
		width = 0
	if(brightness && width)
	{
		message_begin(MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
		write_byte ( TE_BEAMENTPOINT )  
		write_short(id)// short (start entity) 
		write_coord(Origin[0])// coords
		write_coord(Origin[1])// coords
		write_coord(Origin[2])// coords
		write_short(g_SpriteIndex)// short (sprite index) 
		write_byte(1)// byte (starting frame) 
		write_byte(0)// byte (frame rate in 0.1's) 
		write_byte(0)// byte (life in 0.1's) 
		write_byte(width)// byte (line width in 0.1's) 
		write_byte(0)// byte (noise amplitude in 0.01's) 
		write_byte(0)// byte,byte,byte (color)
		write_byte(0)// byte,byte,byte (color)
		write_byte(255)// byte,byte,byte (color)
		write_byte(brightness)// byte (brightness)
		write_byte(100)// byte (scroll speed in 0.1's)
		message_end() 
	}	
}


public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	g_HasRune[id] = 0
	if(Reason != USER_DISCONNECTED)
		RemoveBeam(id)
	remove_task(id)
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	g_HasRune[id] = 1
	
	new winx = get_user_curweaponindex(id);
	
	if(is_meleeweapon(winx))
	{
		UpdateBeam(id)
		if(!task_exists(id,1))
			set_task(BEAMUPDATETIMER,"Task_UpdateBeam",id,_,_,"b")
	}
}
