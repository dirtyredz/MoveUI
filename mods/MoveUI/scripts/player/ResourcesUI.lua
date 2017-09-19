--MoveUI - Dirtyredz|David McClain
package.path = package.path .. ";mods/MoveUI/scripts/lib/?.lua"
local MoveUI = require('MoveUI')

-- namespace ResourcesUI
ResourcesUI = {}

function ResourcesUI.initialize()
  Player():registerCallback("onPreRenderHud", "onPreRenderHud")
end

--MoveUI - Dirtyredz|David McClain
local Title = 'ResourcesUI'
local Icon = "data/textures/icons/brick-pile.png"
local Description = "Shows all your resources."

function ResourcesUI.buildTab(tabbedWindow)
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

--MoveUI - Dirtyredz|David McClain
function ResourcesUI.setNewPosition(Position)
  MoveUI.AssignPlayerOverride(Player(),Title,Position)
end
--MoveUI - Dirtyredz|David McClain
return ResourcesUI
