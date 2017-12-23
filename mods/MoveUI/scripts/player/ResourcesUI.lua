--MoveUI - Dirtyredz|David McClain
package.path = package.path .. ";mods/MoveUI/scripts/lib/?.lua"
local MoveUI = require('MoveUI')

-- namespace ResourcesUI
ResourcesUI = {}

local OverridePosition

local Title = 'ResourcesUI'
local Icon = "data/textures/icons/brick-pile.png"
local Description = "Shows all your resources."
local rect
local res
local DefaulPosition
local resources = {}
local money = 0
local AllowMoving
local player

function ResourcesUI.initialize()
  if onClient() then
    player = Player()

    player:registerCallback("onPreRenderHud", "onPreRenderHud")

    rect = Rect(vec2(),vec2(300,155))
    res = getResolution();
    --MoveUI - Dirtyredz|David McClain
    DefaulPosition = vec2(res.x * 0.92,res.y * 0.68)
    rect.position = MoveUI.CheckOverride(player,DefaulPosition,OverridePosition,Title)

    resources = {player:getResources()}
    money = player.money
  end
end

function ResourcesUI.buildTab(tabbedWindow)
end

function ResourcesUI.onPreRenderHud()

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

  local HSplit = UIHorizontalMultiSplitter(rect, 10, 10, 7)

  drawTextRect('Credits', HSplit:partition(0),-1, 0,ColorRGB(1,1,1), 15, 0, 0, 0)
  drawTextRect(MoveUI.NicerNumbers(money), HSplit:partition(0),1, 0,ColorRGB(1,1,1), 15, 0, 0, 0)

  for i = 0, 6 do
    drawTextRect(Material(i).name, HSplit:partition(i+1),-1, 0,Material(i).color, 15, 0, 0, 0)
    drawTextRect(MoveUI.NicerNumbers(resources[i+1]), HSplit:partition(i+1),1, 0,Material(i).color, 15, 0, 0, 0)
  end
end

function ResourcesUI.updateClient(timeStep)
  resources = {player:getResources()}
  money = player.money
  AllowMoving = MoveUI.AllowedMoving()
end

function ResourcesUI.getUpdateInterval()
    return 1
end

return ResourcesUI
