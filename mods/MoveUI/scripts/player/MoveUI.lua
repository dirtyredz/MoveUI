--MoveUI - Dirtyredz|David McClain
package.path = package.path .. ";mods/MoveUI/scripts/lib/?.lua"
local MoveUI = require('MoveUI')

-- namespace MoveUILoader
MoveUILoader = {}

--For EXTERNAL configuration files
package.path = package.path .. ";mods/MoveUI/config/?.lua"
MoveUIConfig = nil
exsist, MoveUIConfig = pcall(require, 'MoveUIConfig')

MoveUILoader.HudList = MoveUIConfig.HudList or {}

function MoveUILoader.initialize()
  if onServer() and Player() then
    local player = Player()
    for _,HudFile in pairs(MoveUILoader.HudList) do
      if HudFile.FileName and HudFile.ForceStartEnabled then
        if HudFile.Restriction(player) then
          player:addScriptOnce("mods/MoveUI/scripts/player/"..HudFile.FileName..".lua")
          --player:sendChatMessage('MoveUI', 0, HudFile.FileName .. " Enabled!")
        else
          player:removeScript("mods/MoveUI/scripts/player/"..HudFile.FileName..".lua")
          --player:sendChatMessage('MoveUI', 1, "You do not have permission to do that!")
        end
      end
    end

    Player():registerCallback("onShipChanged", "onShipChanged")
    local CurrentShip = Player().craftIndex
    MoveUILoader.onShipChanged(Player().index, CurrentShip)
  end
end

function MoveUILoader.onShipChanged(playerIndex, craftIndex)
  if Player().index ~= playerIndex then return end  --WTF, why is this function run against every player?
  --Verify Entity Exsist
  if not Sector():getEntity(Player().craftIndex) then return end
  local ship = Entity(craftIndex) --assign the ship entity so we can protect it later
  if not ship then return end
  local faction = Faction(ship.factionIndex)
  if faction.isPlayer or faction.isAlliance then
    if not ship:hasScript('mods/MoveUI/scripts/entity/MoveUI.lua') then
      ship:addScriptOnce('mods/MoveUI/scripts/entity/MoveUI.lua')
    end
  end
end
