--MoveUI - Dirtyredz|David McClain
package.path = package.path .. ";data/scripts/lib/?.lua"
require ("callable")

package.path = package.path .. ";mods/MoveUI/scripts/lib/?.lua"
local MoveUI = require('MoveUI')

-- namespace PVPSector
PVPSector = {}

local OverridePosition

local Title = 'PVPSector'
local Icon = "data/textures/icons/chart.png"
local Description = "Display when a player is inside a PVP Sector"
local rect
local res
local DefaulPosition
local PVPMessage = ''
local AllowMoving
local player

function PVPSector.initialize()
  if onClient() then
    player = Player()

    player:registerCallback("onPreRenderHud", "onPreRenderHud")

    rect = Rect(vec2(),vec2(190,25))
    res = getResolution();

    --MoveUI - Dirtyredz|David McClain
    DefaulPosition = vec2(res.x * 0.7,res.y * 0.05)
    rect.position = MoveUI.CheckOverride(player,DefaulPosition,OverridePosition,Title)

    PVPSector.GetPVPStatus()
  end

  Player():registerCallback("onSectorEntered", "onSectorEntered")
end

function PVPSector.buildTab(tabbedWindow)
end

function PVPSector.onPreRenderHud()

  if OverridePosition then
    rect.position = OverridePosition
  end

  if AllowMoving then
    OverridePosition, Moving = MoveUI.Enabled(rect, OverridePosition)
    if OverridePosition and not Moving then
        MoveUI.AssignPlayerOverride(Title,OverridePosition)
        OverridePosition = nil
    end


    drawTextRect(Title, rect, 0, 0,ColorRGB(1,1,1), 10, 0, 0, 0)
    return
  end

  drawTextRect('PVP Damage', rect,-1, 0,ColorRGB(1,1,1), 15, 0, 0, 0)
  local Color = ColorRGB(0,1,0)
  if PVPMessage == 'Enabled' then
    Color = ColorRGB(1,0,0)
  end
  drawTextRect(PVPMessage, rect,1, 0,Color, 15, 0, 0, 0)
end

function PVPSector.onSectorEntered(playerIndex)
  PVPSector.GetPVPStatus()
end

function PVPSector.GetPVPStatus(Message)
  if onClient() then
    if Message then
      PVPMessage = Message
      return
    end
    invokeServerFunction('GetPVPStatus')
    return
  end

  local PVP = Sector().pvpDamage
  if PVP then
    PVPMessage = 'Enabled'
  else
    PVPMessage = 'Disabled'
  end
  invokeClientFunction(Player(callingPlayer),'GetPVPStatus',PVPMessage)
end
callable(PVPSector, "GetPVPStatus")

function PVPSector.updateClient(timeStep)
  AllowMoving = MoveUI.AllowedMoving()
end

function PVPSector.getUpdateInterval()
  return 1
end

return PVPSector
