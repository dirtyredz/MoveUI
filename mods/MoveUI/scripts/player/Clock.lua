--MoveUI - Dirtyredz|David McClain
package.path = package.path .. ";mods/MoveUI/scripts/lib/?.lua"
local MoveUI = require('MoveUI')

-- namespace Clock
Clock = {}

local OverridePosition

local Title = 'Clock'
local Icon = "data/textures/icons/servo.png"
local Description = "Oh no, it's morning again :)"
local rect
local res
local defaultPosition
local AllowMoving
local player

function Clock.initialize()
  if onClient() then
    player = Player()

    player:registerCallback("onPreRenderHud", "onPreRenderHud")

    rect = Rect(vec2(),vec2(190,25))
    res = getResolution();

    --MoveUI - Dirtyredz|David McClain
    defaultPosition = vec2(res.x * 0.7,res.y * 0.07)
    rect.position = MoveUI.CheckOverride(player, defaultPosition,OverridePosition,Title)
  end
end

function Clock.buildTab(tabbedWindow)
  -- TODO: add alarm settings in here
end

function Clock.onPreRenderHud()
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
  local DateTime = os.date("*t")
  drawTextRect(DateTime.hour..":"..DateTime.min..":"..DateTime.sec, rect,0, 0,ColorRGB(1,1,1), 15, 0, 0, 0)
end

function Clock.updateClient(timeStep)
  AllowMoving = MoveUI.AllowedMoving()
end

function Clock.getUpdateInterval()
  return 1
end

return Clock
