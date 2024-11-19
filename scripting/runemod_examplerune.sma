/*
This example plugin contains the info you need to make your own runes for runemod

Q) How can i figure out what rune a user has?
A) You can use GetUserRune(id), but dont use this to figure out if the user has "your" rune. The plugin will be informed via API_PickUpRune

Q) Can i rename functions that start with API_
A) No. This will mess everyting upp

Q) What effects can i use in my rune?
A) Here is a list of effects the base plugin handles.

Q) If i want to make a Pickup and forget rune, how i do this?
A) Check the runemod_medkit.sma/runemod_armor.sma for examples

ShakeScreen(id,amount,time)
MakeSmoke(id,origin[3])
MakeExpl(id,origin[3])
MakeTeleport(origin[3])
MakeFadeScreen(id,Time,LastTime,type,Color[3],Alpha)

Q) Can i lock the speed of a user?
A) yes via these stocks:LockSpeed(id) , UnLockSpeed(id)

Q) Can i reset someones speed?
A) ResetUserSpeed(id)
*/

#include <amxmodx>
#include "runemod.inc"		// We need to include this file, as it contains info we need. Like #define`s and stocks


new g_HasRune[MAXPLAYERS+1] // This is the Array used to store if the user is holding a rune.(Remember the base plugin informs this plugin once he picks up a rune.)

public plugin_init() 
{
	register_plugin("RuneMod test rune", "1.0.0", "EKS")
	/*
	The first string is the Runename
	The second string is its describsion
	3 is its color ( in RGB) 
	
	Thirds is the runeflags:
	
	API_NEWROUND			This is called when a new round starts, if your rune has powers that can be abused in freezetime, then lock it from working here.
	API_ROUNDSTARTED		This is called when a new round has started. This is a good time to reset any settings in your rune. And unlock it if you frooze it in API_NEWROUND
	API_SPEEDCHANGE			This is called when a users speed is locked by another plugin. Like if the a rune makes a user stand still, the speed rune is not gonna overwrite this.
	API_EVENTDAMAGE			This is the same event as the Damage event, but USE THIS ONE. And read on the  API_Damage() for more info. Its very importent that you hook this instead of the orginal event
	API_EVENTDAMAGEDONE		This is called once the API_EVENTDAMAGE is done. This one is used if you need to know the total damage done, IE if your rune makes the player resist x% of the damage
	API_EVENTCURWEAPON		CurWeapon, was called but user dident change weapon
	API_DEATHMSG			Called when a user dies, You should use this one instead of hooking the orignal message. As sometimes the base plugin killes a player
	
	*/
	RegisterPlugin("Test rune","My test rune is the 31337",{10,75,80},API_EVENTDAMAGE+API_ROUNDSTARTED)
}

//This function is called by the base plugin to inform about the user droped his rune for whatever reason ( he could have used droprune or died )
public API_DropedRune(id,Reason)
{
	g_HasRune[id] = 0
	client_print(0,3,"%d has lost his rune",id)
}

// This function is used base plugin to inform this plugin that a user has picked up the rune.
public API_PickUpRune(id) 
{
	g_HasRune[id] = 1
	client_print(0,3,"%d has picked up",id)
}
// This means the new round has started ( ie the buytime is over, this is when runes should be renabled( if they have powers that could be abused in buytime)
public API_RoundStarted()
{
	
}
// This means we are starting on a new round, if your rune can be abused while being in freezetime. Disable it now
public API_NewRound()
{
	
}

/*
Remember, This function is only called if either the attacker or victim has a rune controled by this plugin.

The reason why we want a central plugin to handle damage is becuse of a few things. here is a example:
Imagine plugin A, wants to increase PlayerB`s damamge by 25%. So when a PlayerA shots his gun at PlayerB he 
gets this increase. The extra damage kills PlayberB.
But PlayerB has a resitence rune, that removes 25% of all damage given to him, Now if ever rune handled this themself your gonna isses 
with the above example ( depending on the order of witch the runes was loaded via plugins.ini.
And by 1 plugin checking the damage event, and making sure if any players with a rune was involved is offcourse better then having 10 runes do this :)

Remember, in the damage event all the rune plugin should do is modify the damage and return it!!! EXTREMLY IMPORTENT THAT YOU HAVE "return damage" where the code stops being proccesed

For example of use check:
runemod_frenzy.sma <- This one adds damage
runemod_resistance.sma <- This one removes damamge
*/
public API_Damage(victim,attacker,damage)
{
	return damage
}
/*
Used by API_EVENTWASKILLED flag:
This is called if the base plugins kills a player, this happens when PlayerA shots PlayerB, and PlayerA increase in damage (like done via runemod_strength.sma) kills the guy

Example of use can be found in: 
runemod_frenzy.sma
runemod_soul.sma
*/
public API_DeathMsg(killer,victim)
{
	
}

/*
Remember, This function is only called if either the attacker or victim has a rune controled by this plugin.

This event is called after the API_Damage() is done by the base plugin, if for some reason you plugin need to know the total damage done to the player

For example of use check:
runemod_redeem.sma <- This plugin needs to determin how much HP the user has left after the damage event is over. To check if the user should be teleported away
runemod_dismay.sma
*/
public API_DamageDone(victim,attacker,damage)
{
	
}
/*
This is called if when users maxspeed is free to be changed again.
runemod_speed.sma for example
*/
public API_UnLockSpeedChange(id)
{
/*
This is called once a users maxspeed is locked, this might be becuse someone with the seer rune, looks at someone. And if that person then has the
speedrune, we dont allow him to increase his speed.
runemod_speed.sma for example 
*/
}
public API_LockSpeedChange(id)
{

}