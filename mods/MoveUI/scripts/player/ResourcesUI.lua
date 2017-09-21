--MoveUI - Dirtyredz|David McClain
package.path = package.path .. ";mods/MoveUI/scripts/lib/?.lua"
local MoveUI = require('MoveUI')

-- namespace ResourcesUI
ResourcesUI = {}

local OverridePosition

local Title = 'ResourcesUI'
local Icon = "data/textures/icons/brick-pile.png"
local Description = "Shows all your resources."

function ResourcesUI.initialize()
  Player():registerCallback("onPreRenderHud", "onPreRenderHud")
end

function ResourcesUI.buildTab(tabbedWindow)
end

function ResourcesUI.onPreRenderHud()
  local rect = Rect(vec2(),vec2(300,155))
  local res = getResolution();

  --MoveUI - Dirtyredz|David McClain
  local DefaulPosition = vec2(res.x * 0.92,res.y * 0.68)
  rect.position = MoveUI.CheckOverride(Player(),DefaulPosition,OverridePosition,Title)

  OverridePosition, Moving = MoveUI.Enabled(Player(),rect,OverridePosition)
  if OverridePosition and not Moving then
    invokeServerFunction('setNewPosition',OverridePosition)
  end
  --MoveUI - Dirtyredz|David McClain

  if MoveUI.AllowedMoving(Player()) then
    drawTextRect(Title, rect, 0, 0,ColorRGB(1,1,1), 10, 0, 0, 0)
    return
  end

  local HSplit = UIHorizontalMultiSplitter(rect, 10, 10, 7)
  local resources = {Player():getResources()}

  drawTextRect('Credits', HSplit:partition(0),-1, 0,ColorRGB(1,1,1), 15, 0, 0, 0)
  drawTextRect(MoveUI.NicerNumbers(Player().money), HSplit:partition(0),1, 0,ColorRGB(1,1,1), 15, 0, 0, 0)

  for i = 0, 6 do
    drawTextRect(Material(i).name, HSplit:partition(i+1),-1, 0,Material(i).color, 15, 0, 0, 0)
    drawTextRect(MoveUI.NicerNumbers(resources[i+1]), HSplit:partition(i+1),1, 0,Material(i).color, 15, 0, 0, 0)
  end
end

function ResourcesUI.setNewPosition(Position)
  MoveUI.AssignPlayerOverride(Player(),Title,Position)
end

return ResourcesUI
