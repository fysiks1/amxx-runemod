/*
About:
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
This rune allows you to see the enemy on your radar, and increases your fov(Field of view)

Credits:
Ops in #AMXmod @ Quakenet for alot of help ( + AssKicker & CheesyPeteza ) 
Thanks to BAILOPAN & PM for help on misc problems
kaddar for orginal runemod
BlueRaja for Originaly finding our how to send hostage/Bomb messages to the radar

Todo:
Nothing planned

Changelog:
 1.0.0
 	- First release
*/

#include <amxmodx>
#include <engine>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

#define Spy_FOV 120
#define ChangeFOV 0
#define MAXPLAYERS 32

#define CS_TEAM_CT 2
#define CS_TEAM_T 1

new g_MaxPlayers
new g_MsgBombDrop
new g_MsgHostagePos
new g_StatusText

new g_HasRune[MAXPLAYERS+1]

public plugin_init() 
{
	register_plugin("RuneMod Spy", "1.0.0", "EKS")
	RegisterPlugin("SpyName","SpyDisc",{240,80,90},API_USELANGSYSTEM)
	

	g_MaxPlayers = get_maxplayers()
	g_MsgBombDrop   = get_user_msgid("BombDrop")
	g_MsgHostagePos = get_user_msgid("HostagePos")
	g_StatusText = get_user_msgid("StatusText")
}
public Task_UpdateRadar(id)
{
	new TargetID,body
	get_user_aiming(id,TargetID,body)
	if(TargetID)
	{
		new Name[32],Text[64]
		get_user_name(TargetID,Name,31)
		new Health = get_user_health(TargetID)
		new Armor = get_user_armor(TargetID)
		
		format(Text,63,"%s - HP: %d ( Armor: %d )",Name,Health,Armor)
		UpdateStatus(id,Text)
	}
	else 			// We remove the old text
		UpdateStatus(id,"")
			
	new Closest = FindClosesFI(id)
	if(Closest > 0)
	{
		new Origin[3]
		get_user_origin(Closest,Origin)
		ShowOnRadar(id,Origin)
	}
}

public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	g_HasRune[id] = 0
	remove_task(id)	
	
	if(Reason != USER_DISCONNECTED)
		UpdateStatus(id,"")	
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	g_HasRune[id] = 1
	set_task(1.0,"Task_UpdateRadar",id,_,_,"b")
}
stock FindClosesFI(id)
{
	new Team = get_user_team(id)
	new Float:Dist
	new Float:gf_ShortestDist = 4000.0
	new ShortestDistIndex

	for(new i=1;i<=g_MaxPlayers;i++) if(is_user_alive(i) && Team != get_user_team(i))
	{
		Dist = entity_range(id,i)

		if(Dist <= gf_ShortestDist)
		{
			gf_ShortestDist = Dist
			ShortestDistIndex = i
		}
	}
	return ShortestDistIndex
}

stock ShowOnRadar(id,Origin[3])
{
	new Team = get_user_team(id)
	if(Team == CS_TEAM_T)
	{
		message_begin(MSG_ONE, g_MsgBombDrop, {0,0,0}, id)
		write_coord(Origin[0])	//X Coordinate
		write_coord(Origin[1])	//Y Coordinate
		write_coord(Origin[2])	//Z Coordinate
		write_byte(0)			//?? This byte seems to always be 0...so, w/e
		message_end()
	}
	else if(Team == CS_TEAM_CT)
	{
		message_begin(MSG_ONE, g_MsgHostagePos, {0,0,0}, id)
		write_byte(1)			//No idea what this byte does; I think it has something to do with whether or not the hostage is following someone
		write_byte(1)			//The number of the hostage, 1-4
		write_coord(Origin[0])	//X Coordinate
		write_coord(Origin[1])	//Y Coordinate
		write_coord(Origin[2])	//Z Coordinate
		message_end()
	}
}
stock UpdateStatus(id,Text[])
{
	message_begin( MSG_ONE, g_StatusText, {0,0,0}, id)
	write_byte(0)
	write_string(Text)
	message_end()
}
