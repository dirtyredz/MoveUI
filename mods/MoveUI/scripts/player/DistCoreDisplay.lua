--MoveUI - Dirtyredz|David McClain
package.path = package.path .. ";mods/MoveUI/scripts/lib/?.lua"
local MoveUI = require('MoveUI')

function initialize()
  Player():registerCallback("onPreRenderHud", "onPreRenderHud")
end

--MoveUI - Dirtyredz|David McClain
local Title = 'DistCore'


function onPreRenderHud()
  local rect = Rect(vec2(),vec2(160,25))
  local res = getResolution();

  --MoveUI - Dirtyredz|David McClain
  local DefaulPosition = vec2(res.x * 0.045,res.y * 0.25)
  rect.position = MoveUI.CheckOverride(Player(),DefaulPosition,OverridePosition,Title)
  --MoveUI - Dirtyredz|David McClain

  local lx, ly = Sector():getCoordinates()
  local distanceFromCenter =  math.floor(length(vec2(lx,ly)))
  drawTextRect('Dist to Core: '..distanceFromCenter, rect,0, 0,ColorRGB(0,1,0), 15, 0, 0, 0)

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
