# MoveUI

___
A mod designed for custom UI elements to be displayed on the players screen, and give them the ability to move those UI's around on thier screen.

The best way to show off this mod is with a video so here ya go:

https://www.youtube.com/watch?v=YGAwFltwAsE&feature=youtu.be
___

Heres also a couple picture of the current UI's I have available:

## CargoNotifier
Tired of getting stopped by the local faction because you forgot you had that suspicious cargo left in your hold?
Well no more, for this UI will display 4 separate alerts when carrying: Illegal, Suspicious, Dangerous, or Stolen Cargo.

![alt text](https://imgur.com/L3vK83V.png)


## DistCore
This UI will display how far you are from the core of the galaxy.

![alt text](https://imgur.com/HOwmJjF.png)


## ResourcesUI
Tired of being frustrated that you cant see your resources all the time anymore?
Well this UI is for you, It will display credits and resources on your screen at all times.

![alt text](https://imgur.com/w7rYjMM.png)

## ScrapyardLicenses
This UI will show all ScrapyardLicenses that are currently active.
The UI will only countdown on Loaded Sectors.
It will aslo change colors depending on time remaining.

![alt text](https://imgur.com/R26PXPS.png)

ScrapyardLicenses UI also has the ability to click one of the lines to show that sector on the galaxy map.
![alt text](https://imgur.com/SYqJIAy.png)

SPECIAL THANKS AND CREDIT: dnightmare
For his original idea, and work. He started this idea while working on: http://www.avorion.net/forum/index.php/topic,3850.0.html
He continued to work with me on the best approach to make this UI possible.
Thxs again!!

## ObjectDetector
This UI will display when your C43 Object Detector Module, has detected a valuable object inside the sector.
not only will it detect it, but it will display what was detected, and maintain the UI until you leave the sector, so you always know if thiers a valuable object inside the sector.

![alt text](https://imgur.com/6gdhrMw.png)

SPECIAL THANKS AND CREDIT: dnightmare
He and I infact started work on this together, but he beat me to it.
So I took his work and incorperated my work in to his.
Thxs again!!

## PVPSector
This UI will display when you are inside a Player Enabled/Disabled Sector.

![alt text](https://imgur.com/S4SPW7R.png)

Remember with all these UI's they can be Moved, Enabled, Disabled, or even restricted to specific situations (coding skill required)

![alt text](https://imgur.com/oy5WRlG.png)

I look forward to everyone feedback, and I welcome ideas for more UI's that I can add.

## FactionNotifier
This UI will display the factions that are present in the sector.
The names of the factions will be colored in relation to your relationship status with that faction.

If you have any one of the 4 cargo licenses for that faction the UI will display the license you have for that faction to the right of thier name. allowing you to quickly identify if youll be safe to transport goods in the sector.

## Clock
Simple UI to display your computers current time.

SPECIAL THANKS AND CREDIT: dnightmare

## PowerSystems
A simple UI that displays additional details about your power systems.

## Notepad
A UI that displays notes added via the MoveUI Menu.


## INSTALLATION
___
1. Download the zip file
2. Drag and Drop the contents into the /Avorion/ directory,
    File structure:
        /avorion
            |---->/data
            |---->/mods
                   |---->/MoveUI

3. Place this line at the bottom of this file: data/scripts/entity/merchants/scrapyard.lua

    if not pcall(require, 'mods.MoveUI.scripts.entity.merchants.scrapyard') then print('Mod: MoveUI, failed to extend scrapyard.lua!') end

4. Place these two lines at the bottom of this file: data/scripts/server/server.lua


    local s, b = pcall(require, 'mods/MoveUI/scripts/server/server')
    if s then if b.onPlayerLogIn then local a = onPlayerLogIn; onPlayerLogIn = function(c) a(c); b.onPlayerLogIn(c); end end else print(b); end


## Note
___
I wanted to also notify other modders that this mod and all my future mods/patchs will be using this new file structure.
After discussing it with several other modders including koonschi himself, its been agreed upon that a separate directory mimicing the main data directory will be the best approach.
I encourage all modders to adopt this file structure as default, as its likely to became standard possible required for future mods, when avorion supports steam mods.

## Downloads
___
https://github.com/dirtyredz/MoveUI/releases/download/v2.2.1/MoveUI.v2.2.1.zip

https://github.com/dirtyredz/MoveUI/releases/download/v2.2.0/MoveUI.v2.2.0.zip

https://github.com/dirtyredz/MoveUI/releases/download/2.1.1/MoveUI.v2.1.1.zip

https://github.com/dirtyredz/MoveUI/releases/download/2.1.0/MoveUI.v2.1.0.zip

https://github.com/dirtyredz/MoveUI/releases/download/1.4.0/MoveUI.v1.4.0.zip

https://github.com/dirtyredz/MoveUI/releases/download/1.3.0/MoveUI.v1.3.0.zip

https://github.com/dirtyredz/MoveUI/releases/download/1.2.1/MoveUI.v1.2.1.zip

https://github.com/dirtyredz/MoveUI/releases/download/1.2.0/MoveUI.v1.2.0.zip

https://github.com/dirtyredz/MoveUI/releases/download/1.1.0/MoveUI.v1.1.0.zip

https://github.com/dirtyredz/MoveUI/releases/download/1.0.0/MoveUI.v1.0.0.zip


## Changelog
___
2.2.1
  --Added 12/24 option for the Clock

2.2.0
  --Support for 0.20 security update

2.1.1
  --Fixed bug in PowerSystems
  --Changed how Clock UI gets current time

2.1.0
  --Added PowerSystems UI
  --Added Notepad UI
  --Adjusted core moveui to use local data storage, increases client and server performance.
  --Decreased the amount of space used by FactionNotifier
  --Dynamic UI's now shrink and grow depending on the individual UI.

1.4.0
  --Added Clock UI, Thxs  DNightmare
  --Added FactionNotifier UI
  --Added ability to delete scrapyard licenses data from the UI
  --Removed Vanilla files from zip, follow installation instructions please

1.3.0
  --Every UI now utilizes delayed server/client communication
      Will help tremendously with any high ping issues.
      This will also cause a 1-5 sec delay when activating Movement of the UI's
  --Added PVPSector, will show if a sector has pvp damaged Enabled/Disabled.
  --ScrapyardLicenses now has the option to Allow for Clicking to show the sector on the map.
  --ScrapyardLicenses now has the option to show both alliance/player licenses at the same time.
  --CargoNotifier now has the option to have the UI Flash
  --ObjectDetector now has the option to have the UI Flash

1.2.1
  -Fixed Entity Creation bug error.

1.2.0
  -Added ObjectDetector
      Special Thxs to dnightmare, we were apprently working on this at the same time.
  -Cleaned up the files, and added ExampleUI.lua to easily show others how its done.
  -Added tab support to the main MoveUI interface.
  -Each UI can now build its own tab inside the main MoveUI interface, allowing for more options and descriptions

1.1.0
  -Added ScrapyardLicenses
      Special Thxs to dnightmare, for working with me and collaborating on how to get this to work.
  -ResourceUI now had valid currency format
      Special Thxs to dnightmare, for adding this in.
  -MoveUI should work with alliance ships now.

## GITHUB
___
https://github.com/dirtyredz/MoveUI


## DONATE
___
Wanna show your appreciation?
http://dirtyredz.com/donate

Become a patron:
https://www.patreon.com/Dirtyredz


## MY OTHER MODS
___
__DSM__
-A project dedicated to server deployment, management, and exposing features to a web interface.
http://www.avorion.net/forum/index.php/topic,3507.0.html

__Reganerative Asteroid Fields__
-Regenerates designated sectors, and randomly appearing sectors, of minable asteroids.
http://www.avorion.net/forum/index.php/topic,3055.0.html

__MoveUI__
-A mod for adding custom UIs to the screen.
http://www.avorion.net/forum/index.php/topic,3834.0.html

__Subspace Corridor__
-A modders recources, designed to mimick /teleport, due to server commands not being available through the api.
http://www.avorion.net/forum/index.php/topic,3148.0.html

__Dirty Buoy's__
-Allows players to spawn Navigational and Sentry Buoys, More to come soon.
-These buoys have unique features players cant get in normal game play, for example: Navigational buoys are invincible and cannot be moved. A great way to mark a distance wreckage or minarable rich asteroid field.
--Rusty Servers only at the moment.

__LogLevels__
-LogLevels gives modders the ability to set levels for there print functions.
-Aswell as allowing server owners to clean up there consoles, making it easier to read.
http://www.avorion.net/forum/index.php/topic,3799.0.html

__NoNeutralCore__
-A small script for stopping the creation of neutral zones inside the core.
http://www.avorion.net/forum/index.php/topic,3472.0.html

__DirtyCargoExtender__
-Extends the cargo hold of any NPC station discovered with low cargo holds.
--Patreon Members only

__DirtySecure__
-A mod which assigned PVP or PVE sectors based on distance from core.
-Provides Offline Protection to Players ships.
-Provides protection for NPC stations.
--Rusty Servers only at the moment

__Reganerative Claimable Asteroids__
-A mod which respawns claimable asteroids, when theyve been moved or turned into a mine.
-Also will unclaim or unsell an asteroid after a configured number of days
-Keeps the galaxy alive, providing claimable asteroids for new players.
--Rusty Servers only at the moment

__Death Info__
-Used to track cords of a players death point, assigning player values, for other mods to use.
--Rusty Servers only at the moment.

__/Back__
-A command using DeathInfo and Subspace Corridor, to teleport a players drone BACK to there death point.
--Rusty Servers only at the moment.

__DistCore HUD__
-Displays distance to the core on the players hud
--Rusty Servers only at the moment.

Any mod listed as Rusty Servers only, are live and active on the Rusty Servers.
Want the mod for your server? Lets talk and ill see about releasing the mod to you/public.
Not all mods on Rusty will remain there, they will eventually be released to the public.
