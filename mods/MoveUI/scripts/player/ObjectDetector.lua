--MoveUI - Dirtyredz|David McClain
package.path = package.path .. ";mods/MoveUI/scripts/lib/?.lua"
local MoveUI = require('MoveUI')

-- namespace ObjectDetector
ObjectDetector = {}

--MoveUI - Dirtyredz|David McClain
local Title = 'ObjectDetector'
local timeout = 0
local asteroids = 0
local wrecks = 0
local stashes = 0
local exodus = 0

function ObjectDetector.initialize()
  Player():registerCallback("onPreRenderHud", "onPreRenderHud")
  Player():registerCallback("onSectorEntered", "onSectorEntered")
end

local OverridePosition

function ObjectDetector.onPreRenderHud()
  if onClient() then

    local ship = Player().craft
    if not ship then return end

    local rect = Rect(vec2(),vec2(320,20))
    local res = getResolution();
    --MoveUI - Dirtyredz|David McClain
    local DefaulPosition = vec2(res.x * 0.34,res.y * 0.07)
    rect.position = MoveUI.CheckOverride(Player(),DefaulPosition,OverridePosition,Title)
    --MoveUI - Dirtyredz|David McClain
    local VSplit = UIVerticalMultiSplitter(rect, 5, 5, 3)

    if asteroids > 0 then
      drawTextRect('Asteroid', VSplit:partition(0), 0, 0,ColorRGB(255,255,255), 10, 0, 0, 0)
      drawBorder(VSplit:partition(0), ColorRGB(255,255,255))
    end

    if wrecks > 0 then
      drawTextRect('Wreck', VSplit:partition(1), 0, 0,ColorRGB(255,255,255), 10, 0, 0, 0)
      drawBorder(VSplit:partition(1), ColorRGB(255,255,255))
    end

    if stashes > 0 then
      drawTextRect('Stash', VSplit:partition(2), 0, 0,ColorRGB(255,255,255), 10, 0, 0, 0)
      drawBorder(VSplit:partition(2), ColorRGB(255,255,255))
    end

    if exodus > 0 then
      drawTextRect('Exodus', VSplit:partition(3), 0, 0,ColorRGB(255,255,255), 10, 0, 0, 0)
      drawBorder(VSplit:partition(3), ColorRGB(255,255,255))
    end

    --MoveUI - Dirtyredz|David McClain
    OverridePosition, Moving = MoveUI.Enabled(Player(),rect,OverridePosition)
    if OverridePosition and not Moving then
      invokeServerFunction('setNewPosition',OverridePosition)
    end
    --MoveUI - Dirtyredz|David McClain
  end
end

function ObjectDetector.updateClient(timeStep)
  timeout = timeout + timeStep
  if timeout > 5 then
    timeout = 0
    ObjectDetector.detect()
  end
end

function ObjectDetector.onSectorEntered(playerIndex)
  invokeClientFunction(Player(playerIndex), 'detect')
end

function ObjectDetector.detect()
  asteroids = 0
  wrecks = 0
  stashes = 0
  exodus = 0

  local ship = Player().craft
  if not ship then return end
  if ship:hasScript("systems/valuablesdetector") then

    local entities = {Sector():getEntitiesByComponent(ComponentType.Scripts)}
    for _, entity in pairs(entities) do
      if entity:hasScript("entity/claim.lua") then
        asteroids = asteroids + 1
      elseif entity:hasScript("entity/wreckagetoship.lua") then
        wrecks = wrecks + 1
      elseif entity:hasScript("entity/stash.lua") then
        stashes = stashes + 1
      elseif entity:hasScript("entity/exodusbeacon.lua") then
        exodus = exodus + 1
      end
    end
  end
end

--MoveUI - Dirtyredz|David McClain
function ObjectDetector.setNewPosition(Position)
  MoveUI.AssignPlayerOverride(Player(),Title,Position)
end
--MoveUI - Dirtyredz|David McClain
