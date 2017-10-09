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
local currentDate
local currentTime = ''
local date
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
    Clock.getCurrentDate()
  end
end

function Clock.buildTab(tabbedWindow)
  -- TODO: add alarm settings in here
end


function Clock.onSectorEntered()
  Clock.getCurrentDate() -- sync time with server on sector change
end

function Clock.onPreRenderHud()
  if OverridePosition then
    rect.position = OverridePosition
  end

  if AllowMoving then
    OverridePosition, Moving = MoveUI.Enabled(rect, OverridePosition)
    if OverridePosition and not Moving then
        invokeServerFunction('setNewPosition', OverridePosition)
        OverridePosition = nil
    end
    drawTextRect(Title, rect, 0, 0,ColorRGB(1,1,1), 10, 0, 0, 0)
    return
  end

  drawTextRect(currentTime, rect,0, 0,ColorRGB(1,1,1), 15, 0, 0, 0)
end

function Clock.getCurrentDate(date)
  if onClient() then
    if date then
      currentDate = date
      return
    end
    invokeServerFunction('getCurrentDate')
    return
  end

  local cDate = os.date ("*t")
  invokeClientFunction(Player(callingPlayer),'getCurrentDate', cDate)
end

function Clock.updateClient(timeStep)
  if currentDate then
    currentDate.sec = math.floor(currentDate.sec + timeStep)
    if currentDate.sec >= 60 then
      currentDate.sec = 0
      currentDate.min = currentDate.min + 1
      if currentDate.min >= 60 then
        currentDate.min = 0
        currentDate.hours = currentDate.hour + 1
        -- TODO: add 12/24hr support
        if currentDate.hour >= 24 then
          currentDate.hour = 0
        end
      end
    end
    currentTime = string.format("%02d:%02d:%02d", currentDate.hour, currentDate.min, currentDate.sec)
  end
  AllowMoving = MoveUI.AllowedMoving(player)
end

function Clock.getUpdateInterval()
  return 1
end

function Clock.setNewPosition(Position)
  MoveUI.AssignPlayerOverride(Player(),Title,Position)
end

return Clock
