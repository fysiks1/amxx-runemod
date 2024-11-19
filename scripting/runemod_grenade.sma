/*
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
Pistol & knifes have poison damage

Credits:
Ops in #AMXmod @ Quakenet for alot of help ( + AssKicker & CheesyPeteza ) 
Thanks to BAILOPAN & PM for help on misc problems
kaddar for orginal runemod

Todo:
Balance it out

Changelog:
 1.0.2
	- Fixed: Rune working with all weapons
	- Fixed: Rune showing a extra kill message

 1.0.1
	- Changed: Color some.
 1.0.0
 	- First release
*/

#include <amxmodx>
#include <engine>
#include <fun>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

#define ReArmTime 5.0
#define SPEED 1000
#define TaskOffset 32
#define DamageIncreaes 1.2

#define TE_KILLBEAM 99 
#define TE_BEAMENTPOINT 1 

new g_RuneDisabled
new g_HasRune[MAXPLAYERS+1]
new g_EntNum[MAXPLAYERS+1]
new g_LastOrigin[MAXPLAYERS+1][3]
new g_MaxEnts
new g_MaxPlayers
new g_iSprite

public plugin_init() 
{
	register_plugin("RuneMod Grenade", "1.0.0", "EKS")
	RegisterPlugin("HEMasterName","HEMAsterDesc",{50,1,215},API_ROUNDSTARTED+API_NEWROUND+API_EVENTDAMAGE+API_USELANGSYSTEM)
	
	register_event("SendAudio","Event_SendAudio","b")
	g_MaxEnts = get_global_int(GL_maxEntities)
	g_MaxPlayers = get_maxplayers()
}
public API_Damage(victim,attacker,damage)
{
	if(!g_HasRune[attacker]) 
		return damage
	
	new Weapon
	get_user_attacker(victim,Weapon)
	if(Weapon == CSW_HEGRENADE)
	{
		damage = floatround(damage * DamageIncreaes)
	}

	return damage
}
public Task_GiveGrenades(id)
{
	if(g_HasRune[id] == 0)
	{
		remove_task(id)
		return PLUGIN_CONTINUE
	}
	if(g_RuneDisabled == 1)
		return PLUGIN_CONTINUE
	
	new weapons[32],num
	get_user_weapons(id,weapons,num)
	
	new He = 1

	for(new i=0;i<=num;i++)
	{
		if(weapons[i] == CSW_HEGRENADE)
			He--
	}
	if(He == 1)
		give_item(id,"weapon_hegrenade")
	
	return PLUGIN_CONTINUE
}
public Event_SendAudio(id)
{
	if(g_HasRune[id])
	{
		new Message[20]
		read_data(2,Message,19)
		if(contain(Message,"MRAD_FIREINHOLE") != -1)
		{
			set_task(0.1,"Task_FindGrenade",id,_,_,"a",1)
		}
	}
}
public Task_FindGrenade(id)
{
	FindGrenadeEnt(id)
	set_task(0.2,"Task_UpdateGrenade",id+TaskOffset,_,_,"b")
}

public Task_UpdateGrenade(id)
{
	id -= TaskOffset
	
	if(!is_valid_ent(g_EntNum[id]))
	{
		remove_task(id+TaskOffset)
		return PLUGIN_CONTINUE
	}
	
	new EndOrigin[3],CurOrigin[3]
	get_user_origin(id,EndOrigin,3)
	get_origin(g_EntNum[id],CurOrigin)
	

	if(g_LastOrigin[id][0] != 0)
		DrawLine(g_LastOrigin[id],g_EntNum[id])	
		
	CalcVel(CurOrigin,EndOrigin,g_EntNum[id])
	
	g_LastOrigin[id][0] = CurOrigin[0]
	g_LastOrigin[id][1] = CurOrigin[1]
	g_LastOrigin[id][2] = CurOrigin[2]
	return PLUGIN_CONTINUE
}
public plugin_precache() 
{
	g_iSprite = precache_model("sprites/zbeam5.spr")
}

public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	g_HasRune[id] = 0
	if(task_exists(id+TaskOffset))
		remove_task(id+TaskOffset)
}
// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	g_HasRune[id] = 1
	if(!task_exists(id))
	{
		set_task(ReArmTime,"Task_GiveGrenades",id,_,_,"b")
		Task_GiveGrenades(id)
	}
}

public API_NewRound()
{
	g_RuneDisabled =1 
}
public API_RoundStarted()
{
	g_RuneDisabled=0
}
stock FindGrenadeEnt(id)
{
	new Class[20]
	new Owner
	new Model[30]
	
	for(new i=g_MaxPlayers+1;i<=g_MaxEnts;i++) if(is_valid_ent(i))
	{
		entity_get_string(i,EV_SZ_classname,Class,19)		
		Owner = entity_get_edict(i, EV_ENT_owner)
		if(Owner == id && equal(Class,"grenade"))
		{
			entity_get_string(i,EV_SZ_model,Model,29)
			
			if(contain(Model,"w_hegrenade") != -1)
			{
				AddGlow(i)
				g_EntNum[id] = i
				entity_set_int(i,EV_INT_movetype,MOVETYPE_FLY)
				Task_UpdateGrenade(id + TaskOffset)
			}
		}				
	}
}
stock AddGlow(EntNum)
{
	new Float:Color[3] = {255.0,0.0,0.0}
	entity_set_int(EntNum, EV_INT_renderfx, kRenderFxGlowShell)
	entity_set_float(EntNum, EV_FL_renderamt, 1000.0)
	entity_set_int(EntNum, EV_INT_rendermode, kRenderTransAlpha)
	entity_set_vector(EntNum, EV_VEC_rendercolor,Color)	
}
stock DrawLine(Origin[3],id)
{
	message_begin(MSG_ALL,SVC_TEMPENTITY,{0,0,0},id)
	write_byte ( TE_BEAMENTPOINT )  
	write_short(id)// short (start entity) 
	write_coord(Origin[0])// coords
	write_coord(Origin[1])// coords
	write_coord(Origin[2])// coords
	write_short(g_iSprite)// short (sprite index) 
	write_byte(1)// byte (starting frame) 
	write_byte(0)// byte (frame rate in 0.1's) 
	write_byte(1)// byte (life in 0.1's) 
	write_byte(150)// byte (line width in 0.1's) 
	write_byte(0)// byte (noise amplitude in 0.01's) 
	write_byte(255)// byte,byte,byte (color)
	write_byte(0)// byte,byte,byte (color)
	write_byte(0)// byte,byte,byte (color)
	write_byte(100)// byte (brightness)
	write_byte(100)// byte (scroll speed in 0.1's)
	message_end() 
}
#define MIN_DISTANCE 20
stock CalcVel(IntCurOrigin[3],IntOrigin2[3],EntNum)
{
	if(get_distance(IntCurOrigin,IntOrigin2) <= MIN_DISTANCE)
	{
		new Float:velocity[3] = {0.0,0.0,0.0}
		entity_set_vector(EntNum,EV_VEC_velocity,velocity)		
	}
	else
	{
		// Vars 
		new Float:CurOrigin[3];   // Current origin of the entity 
		new Float:Origin2[3]; 
		new Float:velocity[3]; 
		
		CopyVector(CurOrigin,IntCurOrigin)
		CopyVector(Origin2,IntOrigin2)
		
		
		// You want to go from CurOrigin to temp 
		velocity[0] = Origin2[0] - CurOrigin[0]; 
		velocity[1] = Origin2[1] - CurOrigin[1]; 
		velocity[2] = Origin2[2] - CurOrigin[2]; 
		
		// Now, normalize the vector and multiply by speed 
		new Float:invlength = 1.0 / floatsqroot(velocity[0]*velocity[0] + velocity[1]*velocity[1] + velocity[2]*velocity[2])
		
		invlength *= SPEED; 
		
		velocity[0] *= invlength; 
		velocity[1] *= invlength; 
		velocity[2] *= invlength;
		
		entity_set_vector(EntNum,EV_VEC_velocity,velocity)
	}
}
stock CopyVector(Float:Vec1[3],Vec[3])
{
	Vec1[0] = float(Vec[0])
	Vec1[1] = float(Vec[1])
	Vec1[2] = float(Vec[2])
}
