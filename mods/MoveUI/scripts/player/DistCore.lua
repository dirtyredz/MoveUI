--MoveUI - Dirtyredz|David McClain
package.path = package.path .. ";data/scripts/lib/?.lua"
require ("callable")

package.path = package.path .. ";mods/MoveUI/scripts/lib/?.lua"
local MoveUI = require('MoveUI')

-- namespace DistCore
DistCore = {}

local OverridePosition

local Title = 'DistCore'
local Icon = "data/textures/icons/chart.png"
local Description = "Displays Distance to the center of the galaxy (core)."
local rect
local res
local DefaulPosition
local distanceFromCenter = ''
local AllowMoving
local player

function DistCore.initialize()
  if onClient() then
    player = Player()

    player:registerCallback("onPreRenderHud", "onPreRenderHud")

    rect = Rect(vec2(),vec2(160,25))
    res = getResolution();

    --MoveUI - Dirtyredz|David McClain
    DefaulPosition = vec2(res.x * 0.045,res.y * 0.25)
    rect.position = MoveUI.CheckOverride(player,DefaulPosition,OverridePosition,Title)

    DistCore.GetDistance()
  end

  Player():registerCallback("onSectorEntered", "onSectorEntered")
end

function DistCore.buildTab(tabbedWindow)
  --local Button = container:createButton(mainSplit.bottom, 'button', 'ColorPicker' )

  --Color Picker Window
  --[[local menu = ScriptUI()
  local res = getResolution()
  local size = vec2(300, 300)
  ColorPickerWindow = menu:createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5))
  ColorPickerWindow.visible = false
  ColorPickerWindow.caption = "ColorPicker"
  ColorPickerWindow.showCloseButton = 1
  ColorPickerWindow.moveable = 1
  ColorPickerWindow.closeableWithEscape = 1

  local hsplit = UIHorizontalMultiSplitter(Rect(ColorPickerWindow.size), 10, 10, 10)
  local R = ColorPickerWindow:createSlider(hsplit:partition(0),1,255,254,'R','UpdateColor')
  local G = ColorPickerWindow:createSlider(hsplit:partition(2),1,255,254,'G','UpdateColor')
  local B = ColorPickerWindow:createSlider(hsplit:partition(4),1,255,254,'B','UpdateColor')
  local A = ColorPickerWindow:createSlider(hsplit:partition(6),0,100,100,'A','UpdateColor')]]
end

--[[function MoveUIOptions.ColorPicker()
  ColorPickerWindow:show()
end

function MoveUIOptions.UpdateColor(slider)
  print(slider.value)
end]]

function DistCore.onPreRenderHud()

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

  drawTextRect('Dist to Core: '..distanceFromCenter, rect,0, 0,ColorRGB(0,1,0), 15, 0, 0, 0)
end

function DistCore.onSectorEntered(playerIndex)
  DistCore.GetDistance()
end

function DistCore.GetDistance(Distance)
  if onClient() then
    if Distance then
      distanceFromCenter = Distance
      return
    end
    invokeServerFunction('GetDistance')
    return
  end
  local lx, ly = Sector():getCoordinates()
  distanceFromCenter =  math.floor(length(vec2(lx,ly)))
  invokeClientFunction(Player(callingPlayer),'GetDistance',distanceFromCenter)
end
callable(DistCore, "GetDistance")

function DistCore.updateClient(timeStep)
  AllowMoving = MoveUI.AllowedMoving()
end

function DistCore.getUpdateInterval()
    return 5
end

return DistCore
