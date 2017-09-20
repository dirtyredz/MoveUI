--MoveUI - Dirtyredz|David McClain
package.path = package.path .. ";mods/MoveUI/scripts/lib/?.lua"
local MoveUI = require('MoveUI')

-- namespace DistCore
DistCore = {}

local OverridePosition

local Title = 'DistCore'
local Icon = "data/textures/icons/chart.png"
local Description = "Displays Distance to the center of the galaxy (core)."

function DistCore.initialize()
  Player():registerCallback("onPreRenderHud", "onPreRenderHud")
end

function DistCore.buildTab(tabbedWindow)
  local FileTab = tabbedWindow:createTab("", Icon, Title)
  local container = FileTab:createContainer(Rect(vec2(0, 0), FileTab.size));

  --split it 50/50
  local mainSplit = UIHorizontalSplitter(Rect(vec2(0, 0), FileTab.size), 0, 0, 0.5)

  --Top Message
  local TopHSplit = UIHorizontalSplitter(mainSplit.top, 0, 0, 0.3)
  local TopMessage = container:createLabel(TopHSplit.top.lower + vec2(10,10), Title, 16)
  TopMessage.centered = 1
  TopMessage.size = vec2(FileTab.size.x - 40, 20)

  local Description = container:createTextField(TopHSplit.bottom, Description)

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
  local rect = Rect(vec2(),vec2(160,25))
  local res = getResolution();

  --MoveUI - Dirtyredz|David McClain
  local DefaulPosition = vec2(res.x * 0.045,res.y * 0.25)
  rect.position = MoveUI.CheckOverride(Player(),DefaulPosition,OverridePosition,Title)

  OverridePosition, Moving = MoveUI.Enabled(Player(), rect, OverridePosition)
  if OverridePosition and not Moving then
      invokeServerFunction('setNewPosition', OverridePosition)
  end

  if MoveUI.AllowedMoving(Player()) then
    drawTextRect(Title, rect, 0, 0,ColorRGB(1,1,1), 10, 0, 0, 0)
    return
  end
  --MoveUI - Dirtyredz|David McClain

  local lx, ly = Sector():getCoordinates()
  local distanceFromCenter =  math.floor(length(vec2(lx,ly)))
  drawTextRect('Dist to Core: '..distanceFromCenter, rect,0, 0,ColorRGB(0,1,0), 15, 0, 0, 0)
end

function DistCore.setNewPosition(Position)
  MoveUI.AssignPlayerOverride(Player(),Title,Position)
end

return DistCore
