Runemod 2.x readme

About:
Runemod is a serverside modification powered by AMXmodX, that spawns runes ( powerups ) around  
the map, for the players to pick up. 
Runemod includes lots of unique powers, adding an extra element and a whole lot of fun to the game. 
Runemod is compatible with all half-life mods

How to install:
First of you need to have AMXmodXX 1.60 ( http://www.amxmodx.org ( installed on your server, help on this can be found at http://www.amxmodx.org/doc )
The next thing you should do is enable the required modules. If your using the standard package, then
you need: engine,fun,cstrike to make all the runes run.

Now you should make sure that AMXmodX is up and running fine by trying to login as a admin. If AMXmodX is not working
you should fix this before trying to get runemod up and running.

Installing runemod:
1) Copy the compiled .amxx files to your plugins folder
2) Enable the engine/fun and cstrike module(Enable the cstrike module only if its a CS or CZ server)
3) Add the .amxx files to your plugins.ini in amxmodx/configs/plugins.ini ( edit with notepad, check configs/example_plugins.ini for your copy & past pleasure )
4) Make sure runemod_base.amxx is loaded first, it should be loaded before any stats plugins.
5) Make a runemod folder inside your amxmodx/data folder ( so its amxmodx/data/runemod )
6) Copy the runemod language file (runemod.txt) to the amxmodx language folder ( so its amxmodx/data/lang )
Optional: 7) Generate a runelist file, and upload it to a server ( read FAQ for more details)
Optional: 8) Go to http://www.runemod.org and download the runemod model ( Will make runes look better ingame )

To make sure everything is running, do a amx_plugins and check that their all listed as running. If some of them are not running, its most likely because you failed to enable the right modules.

Now its time to setup your runemod settings.
Edit amxmodx/configs/amxx.cfg
Add:

sv_runemodsettings
a == Runes bounce
b == Update spawnvector file with new spawn points ( Dont disable unless you know what your doing )
c == Update spawn points based on player movment ( Dont disable unless you know what your doing )
d == Remove runes and round end
e == Public message saying what runes where spawned
f == Prevent runes from spawing to close to one another
g == Automaticly spawn change the number of runes spawned, based on the amount of players on the server. With this option enabled: sv_runes becomes the minimaly spawned runes, with it off. It becomes the maximum spawned runes
h == Only 1 of every rune allowed 1 point in time
i == Spawn every rune(Thats not in use)
j == DM based spawning ( This means runes are spawned based on time, not when round starts or ends )
k == Does extra checks on new rune spawnpoints, making sure its not to close to other spawn points
l == When looking at runes, show the rune name center of screen
m == Clients automaticly drop old runes,when they  walk on a new rune

sv_runes <number> (read about sv_runemodsettings with the +/- g setting )

Now for the more advanced stuff: ( Can be ignored for most servers )
Runemod 2.x has hardcoded limits to different settings ( like max runes in the world ) and
these cannot be "crossed" without changing #define's in runemod.inc, doing this can also 
improve peeformance on your server.
Just open this file with notepad and remember to read the comments. If you don't know why you should do this, DON'T make changes!
Doing so can create havoc, and give you lots of error messages.

FAQ)
Q) Is there a FAQ somwehere online?
A) www.runemod.org has an updated FAQ