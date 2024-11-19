/* Runemod base Control","1.0.0","EKS")
About:
This plugin is used to make the runemod 2.x base plugin change settings in "realtime" or pause/unpause it

FAQ:
Q) Why can you just use cvars?
A) Checkign cvars is slow.

Q) Why cant this be included in the base plugin?
A) Becuse the plugin cannot unpause itself

Credits:
Ops in #AMXmod @ Quakenet for alot of help ( + AssKicker & CheesyPeteza ) 

 1.1.0
	- Added: amx_rmc enable/disable IndexOfRune
	- Added: amx_rmc pause/unpause
	
 1.0.0
	- First public release
*/

#include <amxmodx>
#include <amxmisc>
#include "runemod.inc"

public plugin_init() 
{
	register_plugin("Runemod base Control","1.1.0","EKS")
	register_concmd("amx_rmc","Check_Command",ADMIN_RCON," - amx_rmc <reload/pause/unpause/enable or disable <IndexOfRune>")
}

public Check_Command(id,level,cid)
{
	if(!cmd_access (id,level,cid,1)) return PLUGIN_HANDLED
	
	new Text[32]
	read_argv(1,Text,31)
	if(equali(Text,"reload"))
	{
		new Success = ForceReloadOfSettings()
		if(Success) console_print(id,"%L",LANG_PLAYER,"ControlReload")
		else  console_print(id,"%L",LANG_PLAYER,"ControlReloadFailed")
	}
	else if(equali(Text,"pause"))
	{
		new Success = ForceShutDown()
		if(Success) 
		{
			console_print(id,"%L",LANG_PLAYER,"ControlShutDown")
			pause("ac","runemod_base.amxx")
		}
		else  console_print(id,"%L",LANG_PLAYER,"ControlUnKnownError")
	}
	else if(equali(Text,"unpause"))
	{
		unpause("ac","runemod_base.amxx")
		ForceStart()
	}
	else if(equali(Text,"disable"))
	{
		read_argv(2,Text,31)
		new IndexOfRune = str_to_num(Text)
		if(!IndexOfRune || IndexOfRune >= MAX_RUNESINGAME) 
		{
			console_print(id,"%L",LANG_PLAYER,"ControlWrongCommand")
			return PLUGIN_HANDLED
		}
		else
		{
			new Success = DisableRune(IndexOfRune)
			if(Success)
			{
				console_print(id,"%L",LANG_PLAYER,"ControlDisableRune",IndexOfRune)
				return PLUGIN_HANDLED				
			}
			else if(Success == -1)
			{
				console_print(id,"%L",LANG_PLAYER,"ControlRuneIsDisabled")
				return PLUGIN_HANDLED				
			}
			else
			{
				console_print(id,"%L",LANG_PLAYER,"ControlUnKnownError")
				return PLUGIN_HANDLED				
			}
		}
		
	}
	else if(equali(Text,"enable"))
	{
		read_argv(2,Text,31)
		new IndexOfRune = str_to_num(Text)
		if(!IndexOfRune || IndexOfRune >= MAX_RUNESINGAME) 
		{
			console_print(id,"%L",LANG_PLAYER,"ControlWrongCommand")
			return PLUGIN_HANDLED
		}
		else
		{
			new Success = EnableRune(IndexOfRune)
			if(Success)
			{
				console_print(id,"%L",LANG_PLAYER,"ControlEnableRune",IndexOfRune)
				return PLUGIN_HANDLED				
			}
			else if(Success == -1)
			{
				console_print(id,"%L",LANG_PLAYER,"ControlRuneIsEnabled")
				return PLUGIN_HANDLED				
			}
			else
			{
				console_print(id,"%L",LANG_PLAYER,"ControlUnKnownError")
				return PLUGIN_HANDLED				
			}
		}
	}	
	else
		console_print(id,"[Runemod] You entered a wrong command, valid commands are: amx_rmc <reload/pause/unpause/enable or disable <IndexOfRune>")
		
	return PLUGIN_HANDLED
}

stock DisableRune(IndexOfRune)
{
	new Temp = callfunc_begin("API_DisableRune","runemod_base.amxx")
	if(!Temp)
	{
		return -1
	}
	callfunc_push_int(IndexOfRune)
	return callfunc_end()
}
stock EnableRune(IndexOfRune)
{
	new Temp = callfunc_begin("API_EnableRune","runemod_base.amxx")
	if(!Temp)
	{
		return -1
	}
	callfunc_push_int(IndexOfRune)
	return callfunc_end()
}
stock ForceReloadOfSettings()
{
	new Temp = callfunc_begin("plugin_cfg","runemod_base.amxx")
	if(!Temp)
	{
		return -1
	}
	callfunc_end()
	return 1
}
stock ForceStart()
{
	new Temp = callfunc_begin("API_PluginStart","runemod_base.amxx")
	if(!Temp)
	{
		return -1
	}
	callfunc_end()
	return 1
}
stock ForceShutDown()
{
	new Temp = callfunc_begin("API_PluginShutDown","runemod_base.amxx")
	if(!Temp)
	{
		return -1
	}
	callfunc_end()
	return 1
}
