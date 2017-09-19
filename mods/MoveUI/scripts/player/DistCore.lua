--MoveUI - Dirtyredz|David McClain
package.path = package.path .. ";mods/MoveUI/scripts/lib/?.lua"
local MoveUI = require('MoveUI')

-- namespace DistCore
DistCore = {}

function DistCore.initialize()
  Player():registerCallback("onPreRenderHud", "onPreRenderHud")
end

--MoveUI - Dirtyredz|David McClain
local Title = 'DistCore'
local Icon = "data/textures/icons/chart.png"
local Description = "Displays Distance to the center of the galaxy (core)."

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
end

local OverridePosition

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

--MoveUI - Dirtyredz|David McClain
function DistCore.setNewPosition(Position)
  MoveUI.AssignPlayerOverride(Player(),Title,Position)
end
--MoveUI - Dirtyredz|David McClain
return DistCore
