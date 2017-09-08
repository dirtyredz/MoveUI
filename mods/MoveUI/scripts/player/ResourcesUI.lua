--MoveUI - Dirtyredz|David McClain
package.path = package.path .. ";mods/MoveUI/scripts/lib/?.lua"
local MoveUI = require('MoveUI')

function initialize()
  Player():registerCallback("onPreRenderHud", "onPreRenderHud")
end

--MoveUI - Dirtyredz|David McClain
local Title = 'Resources'

function onPreRenderHud()
  local rect = Rect(vec2(),vec2(300,155))
  local res = getResolution();

  --MoveUI - Dirtyredz|David McClain
  local DefaulPosition = vec2(res.x * 0.92,res.y * 0.68)
  rect.position = MoveUI.CheckOverride(Player(),DefaulPosition,OverridePosition,Title)
  --MoveUI - Dirtyredz|David McClain

  local HSplit = UIHorizontalMultiSplitter(rect, 10, 10, 7)
  local resources = {Player():getResources()}

  drawTextRect('Credits', HSplit:partition(0),-1, 0,ColorRGB(1,1,1), 15, 0, 0, 0)
  drawTextRect(Player().money, HSplit:partition(0),1, 0,ColorRGB(1,1,1), 15, 0, 0, 0)

  for i = 0, 6 do
    drawTextRect(Material(i).name, HSplit:partition(i+1),-1, 0,Material(i).color, 15, 0, 0, 0)
    drawTextRect(resources[i+1], HSplit:partition(i+1),1, 0,Material(i).color, 15, 0, 0, 0)
  end


  --MoveUI - Dirtyredz|David McClain
  OverridePosition, Moving = MoveUI.Enabled(Player(),rect,OverridePosition)
  if OverridePosition and not Moving then
    invokeServerFunction('setNewPosition',OverridePosition)
  end
  --MoveUI - Dirtyredz|David McClain
end

--MoveUI - Dirtyredz|David McClain
function setNewPosition(Position)
  MoveUI.AssignPlayerOverride(Player(),Title,Position)
end
--MoveUI - Dirtyredz|David McClain
