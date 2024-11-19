/*
About:
This is a runemod powerup plugin that interfaces with runemod_base.amxx

About this rune:
You can bunny jump, and you have a hook that can steal weapons

Credits:
Ops in #AMXmod @ Quakenet for alot of help ( + AssKicker & CheesyPeteza ) 
Cheesy Peteza <-> Bunny jumper code
SpaceDude/JTP10181 For hookmod code


Todo:
Maybe add so the hook can be used on ents on the ground(IE weapons), the problem with this is hiting the "gun" requires you to at a very spesfic point. So i have to add Origin checks
*/

#include <amxmodx>
#include <engine>
#include <cstrike>
#include <fun>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks

#define ROPE_DELAY 0.5
#define TE_BEAMENTPOINT 1
#define TE_KILLBEAM 99
#define Time_UpdateHook 0.1		// seconds
#define BEAMLIFE 100		// deciseconds
#define MOVEACCELERATION 150	// units per second^2
#define REELSPEED 200		// units per second

new g_HasRune[MAXPLAYERS+1] // This is the Array used to store if the user is holding a rune.(Remember the base plugin informs this plugin once he picks up a rune.)
new g_WeaponIndex[MAXPLAYERS+1]
new g_HookLocation[MAXPLAYERS+1][3]
new g_HookLength[MAXPLAYERS+1]
new g_ActiveHook[MAXPLAYERS+1]
new g_Ready2Use[MAXPLAYERS+1]
new Float:g_BeamCreated[MAXPLAYERS+1]

new g_Gravity
new g_SpriteIndex
new g_MaxPlayers
new g_MaxEnts

#define	FL_WATERJUMP	(1<<11)	// player jumping out of water
#define	FL_ONGROUND		(1<<9)	// At rest / on the ground

public plugin_init() 
{
	register_plugin("Runemod Ninja", "1.0.0", "Cheesy Peteza & SpaceDude/JTP10181")
	RegisterPlugin("NinjaName","NinjaDisc",{12,10,10},API_EVENTCHANGEWEAPON+API_ROUNDSTARTED+API_NEWROUND+API_USELANGSYSTEM)
	g_Gravity = get_cvar_num("sv_gravity")	
	g_MaxPlayers = get_maxplayers()
	g_MaxEnts = get_global_int(GL_maxEntities)
}
public API_CurWeaponChange(id,WeaponIndex)
{
	g_WeaponIndex[id] = WeaponIndex
	if(!is_meleeweapon(WeaponIndex) && g_ActiveHook[id] == 1)
	{
		RelaseHook(id)
	}
	return PLUGIN_CONTINUE
}
stock AddHook(id)
{
	new HitEnt,Body
	get_user_aiming(id,HitEnt,Body)
	
	if(HitEnt > 0)
	{
		if(is_user_alive(HitEnt) && HitEnt <= g_MaxPlayers && get_user_team(id) != get_user_team(HitEnt))
		{
			new weapons[32],num
			get_user_weapons(id,weapons,num)
			for(new i=0;i<=num;i++) if(IsPrimarlyWeapon(weapons[i]))
			{
				client_print(id,print_chat,"%L",LANG_PLAYER,"NinjaCantSteal")
				
				g_Ready2Use[id] = 0
						
				set_task(1.0,"Task_ReEnableHook",id,_,_,"a",1)
				return PLUGIN_CONTINUE
			}
			new Name[32]
			get_user_name(HitEnt,Name,31)
			
			new WIndex = get_user_curweaponindex(HitEnt)
			if(IsPrimarlyWeapon(WIndex))
			{
				new WPName[32]
				get_wpname(WIndex, WPName, 31)
				
				//give_item(id,WPName)			
				client_print(id,print_chat,"%L",LANG_PLAYER,"NinjaStole",WPName,Name)
				client_cmd(HitEnt,"drop")
				
				new parm[2]
				parm[0] = id
				parm[1] = HitEnt
				
				remove_task(id)			
				set_task(0.1,"Task_MoveWeapon",id,parm,2,"a",1)
				
				emit_sound(id,CHAN_STATIC,"weapons/xbow_hit1.wav",1.0,ATTN_NORM,0,PITCH_NORM)
				//format(gs_WeaponName[id],31,"weapon_%s",WPName)		// We now give the stolen weapon, to the guy with the rune
			}
			else
			{
				client_print(id,print_chat,"%L",LANG_PLAYER,"NinjaNoPrimary",Name)
			}
			g_Ready2Use[id] = 0
		}
	}
	else if(HitEnt == 0 || HitEnt > g_MaxPlayers)
	{
		new user_origin[3]
		g_ActiveHook[id] = 1
		get_user_origin(id, user_origin)
		get_user_origin(id, g_HookLocation[id], 3)
		g_HookLength[id] = get_distance(g_HookLocation[id],user_origin)
	
		set_user_gravity(id,0.001)
		AddBeamPoint(id)
		emit_sound(id, CHAN_STATIC, "weapons/xbow_hit2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		set_task(Time_UpdateHook, "Task_UpdateHook",id,_,_, "b")
		Task_UpdateHook(id)
	}
	return PLUGIN_CONTINUE
}
public Task_MoveWeapon(parm[])
{
	new id = parm[0]
	new Target = parm[1]

	new WEntNum = FindEntNum(Target)	// We are getting the Entnum for the weapon just droped

	if(WEntNum == 0)
		return PLUGIN_CONTINUE
	MoveEntNum(id,WEntNum,1500)
	killbeam(id)
	return PLUGIN_CONTINUE
}
stock MoveEntNum(id,EntNum,speed)
{
	new Float:velocity[3]
	VelocityByAim(id, speed , velocity)
	
	if(!velocity[0])
		floatabs(velocity[0])
	else if(velocity[0])
		velocity[0] = velocity[0] - velocity[0]	- velocity[0]

	if(!velocity[1])
		floatabs(velocity[1])	
	else if(velocity[1])
		velocity[1] = velocity[1] - velocity[1]	- velocity[1]			

	if(!velocity[2])
		floatabs(velocity[2])
	else if(velocity[2])
		velocity[2] = velocity[2] - velocity[2] - velocity[2]
	entity_set_vector(EntNum,EV_VEC_velocity,velocity)	
}
stock FindEntNum(id)
{
	new Class[24]
	for(new i=g_MaxPlayers;i<=g_MaxEnts;i++) 
	{
		if(is_valid_ent(i) && entity_get_edict(i, EV_ENT_owner) == id)
		{
			entity_get_string(i,EV_SZ_classname,Class,23)
			if(equal("weaponbox",Class) && entity_range(id,i) <= 100)
			{
				return i
			}
		}
	}
	return 0
}
public plugin_precache()
{
	g_SpriteIndex = precache_model("sprites/rope.spr")
	precache_sound("weapons/xbow_hit2.wav")
	precache_sound("weapons/xbow_hit1.wav")
}
new OrZ[32]
public client_PreThink(id) 
{
	if(g_HasRune[id] == 0) return PLUGIN_CONTINUE

	entity_set_float(id, EV_FL_fuser2, 0.0)		// Disable slow down after jumping
	new flags = entity_get_int(id, EV_INT_flags)
	new buttons = entity_get_int(id,EV_INT_button)

	// Code from CBasePlayer::Jump (player.cpp)		Make a player jump automatically
	if(buttons & IN_JUMP)
	{
		if (!(flags & FL_WATERJUMP) && entity_get_int(id, EV_INT_waterlevel) < 2 && flags & FL_ONGROUND)
		{
			new Float:velocity[3]
			entity_get_vector(id, EV_VEC_velocity, velocity)
			
			new Float:Speed = floatabs(velocity[0] + velocity[1])
			new Float:MSpeed = entity_get_float(id,EV_FL_maxspeed)
			
			new Origin[3]
			get_user_origin(id,Origin)
			if(Speed > MSpeed + 10.0)
			{
				if(Origin[2] >  OrZ[id])
				{
					velocity[0] = velocity[0] * 0.98 
					velocity[1] = velocity[1] * 0.98 					
				}
				if(Origin[2] ==  OrZ[id])
				{
	
					velocity[0] = velocity[0] * 0.98 
					velocity[1] = velocity[1] * 0.98 
				}
			}
			OrZ[id] = Origin[2]

			velocity[2] += 250.0
			entity_set_vector(id, EV_VEC_velocity, velocity)
	
			entity_set_int(id, EV_INT_gaitsequence, 6)	// Play the Jump Animation
		}
	}
	if(buttons & IN_ATTACK && is_meleeweapon(g_WeaponIndex[id]))
	{
		if(g_ActiveHook[id] == 0 && g_Ready2Use[id] == 1) 	// We are adding the hook
		{
			AddHook(id)
			g_Ready2Use[id] = 0
		}
		else if(g_Ready2Use[id] == 1)
		{
			RelaseHook(id)
			g_Ready2Use[id] = 0
		}
	}
	else if(g_Ready2Use[id] == 0 && !(buttons & IN_ATTACK))
		g_Ready2Use[id] = 1
	return PLUGIN_HANDLED
}
public Task_ReEnableHook(id)
{
	g_Ready2Use[id] = 1
}
public API_DropedRune(id,Reason) //This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
{
	g_HasRune[id] = 0
	remove_task(id)
	if(g_ActiveHook[id] >= 1)
		RelaseHook(id)
}
public API_RoundStarted()
{
	for(new i=1;i<=g_MaxPlayers;i++) if(g_HasRune[i])
	{
		g_Ready2Use[i] = 1
	}
}
public API_NewRound()
{
	for(new i=1;i<=g_MaxPlayers;i++) if(g_HasRune[i])
	{
		if(g_ActiveHook[i] == 1)
			RelaseHook(i)

		g_Ready2Use[i] = -1
	}
}
public API_PickUpRune(id) 
{
	g_Ready2Use[id] = 1
	g_HasRune[id] = 1
}
public Task_UpdateHook(id) 
{
	new Flags = get_user_button(id)
	new user_origin[3], user_look[3], user_direction[3], move_direction[3]
	new A[3], D[3], buttonadjust[3]
	new acceleration, velocity_TA, desired_velocity_TA
	new velocity[3], null[3]
	new Float:tmpVector[3]

	if (g_BeamCreated[id] + BEAMLIFE/10 <= get_gametime()) 
	{
		AddBeamPoint(id)
	}
	
	null[0] = 0
	null[1] = 0
	null[2] = 0

	get_user_origin(id, user_origin)
	get_user_origin(id, user_look,2)
	
	entity_get_vector(id, EV_VEC_velocity, tmpVector)
	FVecIVec(tmpVector, velocity)

	buttonadjust[0]=0
	buttonadjust[1]=0

	if (Flags & IN_FORWARD) 
	{
		buttonadjust[0]+=1
	}
	if (Flags & IN_BACK) 
	{
		buttonadjust[0]-=1
	}
	if (Flags & IN_MOVERIGHT)
	{
		buttonadjust[1]+=1
	}
	if (Flags & IN_MOVELEFT) 
	{
		buttonadjust[1]-=1
	}
	if (Flags & IN_JUMP) 
	{
		buttonadjust[2]+=1
	}
	if (Flags & IN_DUCK) 
	{
		buttonadjust[2]-=1
	}

	if (buttonadjust[0] || buttonadjust[1]) {
		user_direction[0] = user_look[0] - user_origin[0]
		user_direction[1] = user_look[1] - user_origin[1]

		move_direction[0] = buttonadjust[0]*user_direction[0] + user_direction[1]*buttonadjust[1]
		move_direction[1] = buttonadjust[0]*user_direction[1] - user_direction[0]*buttonadjust[1]
		move_direction[2] = 0

		velocity[0] += floatround(move_direction[0] * MOVEACCELERATION * Time_UpdateHook / get_distance(null,move_direction))
		velocity[1] += floatround(move_direction[1] * MOVEACCELERATION * Time_UpdateHook / get_distance(null,move_direction))
	}
	if (buttonadjust[2]) 
	{
		g_HookLength[id] -= floatround(buttonadjust[2] * REELSPEED * Time_UpdateHook)
	}
	if (g_HookLength[id] < 100) 
	{
		(g_HookLength[id]) = 100
	}

	A[0] = g_HookLocation[id][0] - user_origin[0]
	A[1] = g_HookLocation[id][1] - user_origin[1]
	A[2] = g_HookLocation[id][2] - user_origin[2]

	D[0] = A[0]*A[2] / get_distance(null,A)
	D[1] = A[1]*A[2] / get_distance(null,A)
	D[2] = -(A[1]*A[1] + A[0]*A[0]) / get_distance(null,A)

	new aDistance = get_distance(null,D) ? get_distance(null,D) : 1
	acceleration = - g_Gravity * D[2] / aDistance

	velocity_TA = (velocity[0] * A[0] + velocity[1] * A[1] + velocity[2] * A[2]) / get_distance(null,A)
	desired_velocity_TA = (get_distance(user_origin,g_HookLocation[id]) - g_HookLength[id] /*- 10*/) * 4

	if (get_distance(null,D)>10) 
	{
		velocity[0] += floatround((acceleration * Time_UpdateHook * D[0]) / get_distance(null,D))
		velocity[1] += floatround((acceleration * Time_UpdateHook * D[1]) / get_distance(null,D))
		velocity[2] += floatround((acceleration * Time_UpdateHook * D[2]) / get_distance(null,D))
	}

	velocity[0] += ((desired_velocity_TA - velocity_TA) * A[0]) / get_distance(null,A)
	velocity[1] += ((desired_velocity_TA - velocity_TA) * A[1]) / get_distance(null,A)
	velocity[2] += ((desired_velocity_TA - velocity_TA) * A[2]) / get_distance(null,A)

	IVecFVec(velocity, tmpVector)
	entity_set_vector(id, EV_VEC_velocity, tmpVector)
}
stock AddBeamPoint(id)
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte( TE_BEAMENTPOINT )
	write_short( id )
	write_coord( g_HookLocation[id][0] )
	write_coord( g_HookLocation[id][1] )
	write_coord( g_HookLocation[id][2] )
	write_short( g_SpriteIndex )	// sprite index
	write_byte( 0 )		// start frame
	write_byte( 0 )		// framerate
	write_byte( BEAMLIFE )	// life
	write_byte( 2 )	// width
	write_byte( 1 )		// noise
	write_byte( 250 )	// r, g, b
	write_byte( 250 )	// r, g, b
	write_byte( 250 )	// r, g, b
	write_byte( 250 )	// brightness

	write_byte( 0 )		// speed
	message_end( )
	g_BeamCreated[id] = get_gametime()
}
stock killbeam(id)
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte( TE_KILLBEAM )
	write_short( id )
	message_end()
}
stock IsPrimarlyWeapon(WeaponIndex)
{
	if(WeaponIndex == CSW_SCOUT || WeaponIndex == CSW_XM1014 || WeaponIndex == CSW_MAC10 || WeaponIndex == CSW_AUG || WeaponIndex == CSW_UMP45 || 
	WeaponIndex == CSW_SG550 || WeaponIndex == CSW_GALI || WeaponIndex == CSW_GALIL || WeaponIndex == CSW_FAMAS || WeaponIndex == CSW_AWP || 
	WeaponIndex == CSW_MP5NAVY || WeaponIndex == CSW_M249 || WeaponIndex == CSW_M3 || WeaponIndex == CSW_M4A1 || WeaponIndex == CSW_TMP || 
	WeaponIndex == CSW_G3SG1 || WeaponIndex == CSW_SG552 || WeaponIndex == CSW_AK47 || WeaponIndex == CSW_P90)
		return 1
	else
		return 0
	return 0
}
stock get_wpname(wp, name[], imax)
{
	switch (wp) {
		case CSW_P228:
			copy(name, imax, "p228")
		case CSW_SCOUT:
			copy(name, imax, "scout")
		case CSW_HEGRENADE:
			copy(name, imax, "hegrenade")
		case CSW_XM1014:
			copy(name, imax, "xm1014")
		case CSW_C4:
			copy(name, imax, "c4")
		case CSW_MAC10:
			copy(name, imax, "mac10")
		case CSW_AUG:
			copy(name, imax, "aug")
		case CSW_SMOKEGRENADE:
			copy(name, imax, "smokegrenade")
		case CSW_ELITE:
			copy(name, imax, "elite")
		case CSW_FIVESEVEN:
			copy(name, imax, "fiveseven")
		case CSW_UMP45:
			copy(name, imax, "ump45")
		case CSW_SG550:
			copy(name, imax, "sg550")
		case CSW_GALIL:
			copy(name, imax, "galil")
		case CSW_FAMAS:
			copy(name, imax, "famas")
		case CSW_USP:
			copy(name, imax, "usp")
		case CSW_GLOCK18:
			copy(name, imax, "glock18")
		case CSW_AWP:
			copy(name, imax, "awp")
		case CSW_MP5NAVY:
			copy(name, imax, "mp5navy")
		case CSW_M249:
			copy(name, imax, "m249")
		case CSW_M3:
			copy(name, imax, "m3")
		case CSW_M4A1:
			copy(name, imax, "m4a1")
		case CSW_TMP:
			copy(name, imax, "tmp")
		case CSW_G3SG1:
			copy(name, imax, "g3sg1")
		case CSW_FLASHBANG:
			copy(name, imax, "flashbang")
		case CSW_DEAGLE:
			copy(name, imax, "deagle")
		case CSW_SG552:
			copy(name, imax, "sg552")
		case CSW_AK47:
			copy(name, imax, "ak47")
		case CSW_KNIFE:
			copy(name, imax, "knife")
		case CSW_P90:
			copy(name, imax, "p90")
	}
	
	return 1
}
stock RelaseHook(id)
{
	g_ActiveHook[id] = 0
	killbeam(id)
	set_user_gravity(id)
	remove_task(id)
}
