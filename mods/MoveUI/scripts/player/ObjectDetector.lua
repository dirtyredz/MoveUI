--MoveUI - Dirtyredz|David McClain
package.path = package.path .. ";mods/MoveUI/scripts/lib/?.lua"
local MoveUI = require('MoveUI')

-- namespace ObjectDetector
ObjectDetector = {}

local OverridePosition

local Title = 'ObjectDetector'
local Icon = "data/textures/icons/movement-sensor.png"
local Description = "Will display if you have valuable objects inside the sector, depending if you have the c43 Object Detector Module equiped."
local DefaultOptions = {
  AF = false
}
local AF_OnOff

local timeout = 0
local asteroids = 0
local wrecks = 0
local stashes = 0
local exodus = 0
local rect
local res
local DefaulPosition
local LoadedOptions
local AllowMoving
local player

function ObjectDetector.initialize()
  if onClient() then
    player = Player()

    player:registerCallback("onPreRenderHud", "onPreRenderHud")
    ObjectDetector.detect()
    LoadedOptions = MoveUI.GetOptions(player,Title,DefaultOptions)

    rect = Rect(vec2(),vec2(320,20))
    res = getResolution();
    --MoveUI - Dirtyredz|David McClain
    DefaulPosition = vec2(res.x * 0.5,res.y * 0.90)
    rect.position = MoveUI.CheckOverride(player,DefaulPosition,OverridePosition,Title)
  end

  Player():registerCallback("onSectorEntered", "onSectorEntered")
end

function ObjectDetector.buildTab(tabbedWindow)
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

  local OptionsSplit = UIHorizontalMultiSplitter(mainSplit.bottom, 0, 0, 1)

  local TextVSplit = UIVerticalSplitter(OptionsSplit:partition(0),0, 5,0.65)
  local name = container:createLabel(TextVSplit.left.lower, "Allow Flashing", 16)

  --make sure variables are local to this file only
  AF_OnOff = container:createCheckBox(TextVSplit.right, "On / Off", 'onAllowFlashing')
  AF_OnOff.tooltip = 'Will Flash when an object is detected.'

  --Pass the name of the function, and the checkbox
  return {onAllowFlashing = AF_OnOff}
end

function ObjectDetector.onAllowFlashing(checkbox, value)
  --setNewOptions is a function inside entity/MoveUI.lua, that sets the options to the player.
  invokeServerFunction('setNewOptions', Title, {AF = value})
end

--Executed when the Main UI Interface is opened.
function ObjectDetector.onShowWindow()
  --Get the player options
  local LoadedOptions = MoveUI.GetOptions(Player(),Title,DefaultOptions)
  --Set the checkbox to match the option
  AF_OnOff.checked = LoadedOptions.AF
end

function ObjectDetector.onPreRenderHud()
  if onClient() then

    local ship = player.craft
    if not ship then return end

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

    --Flashing Option
    if os.time() % 2 == 0 and LoadedOptions.AF then return end

    local VSplit = UIVerticalMultiSplitter(rect, 5, 5, 3)

    if asteroids > 0 then
      drawTextRect('Asteroid', VSplit:partition(0), 0, 0,ColorRGB(1,1,1), 10, 0, 0, 0)
      drawBorder(VSplit:partition(0), ColorRGB(1,1,1))
    end

    if wrecks > 0 then
      drawTextRect('Wreck', VSplit:partition(1), 0, 0,ColorRGB(1,1,1), 10, 0, 0, 0)
      drawBorder(VSplit:partition(1), ColorRGB(1,1,1))
    end

    if stashes > 0 then
      drawTextRect('Stash', VSplit:partition(2), 0, 0,ColorRGB(1,1,1), 10, 0, 0, 0)
      drawBorder(VSplit:partition(2), ColorRGB(1,1,1))
    end

    if exodus > 0 then
      drawTextRect('Exodus', VSplit:partition(3), 0, 0,ColorRGB(1,1,1), 10, 0, 0, 0)
      drawBorder(VSplit:partition(3), ColorRGB(1,1,1))
    end


  end
end

function ObjectDetector.updateClient(timeStep)
  ObjectDetector.detect()
  LoadedOptions = MoveUI.GetOptions(player,Title,DefaultOptions)
  AllowMoving = MoveUI.AllowedMoving(player)
end

function ObjectDetector.getUpdateInterval()
    return 5
end

function ObjectDetector.onSectorEntered(playerIndex)
  ObjectDetector.detect()
end

function ObjectDetector.detect()
  if onServer() then
    invokeClientFunction(Player(playerIndex), 'detect')
    return
  end

  asteroids = 0
  wrecks = 0
  stashes = 0
  exodus = 0

  local ship = Player().craft
  if not ship then return end
  if ship:hasScript("systems/valuablesdetector") then

    local ret, data = ship:invokeFunction("scripts/systems/valuablesdetector.lua",'secure')
    local rarity = Rarity(data.rarity) or Rarity(0)
    local ret, detections, highlightRange = ship:invokeFunction("scripts/systems/valuablesdetector.lua",'getBonuses',data.seed, rarity)

    local entities = {Sector():getEntitiesByComponent(ComponentType.Scripts)}
    for _, entity in pairs(entities) do
      if entity:hasScript("entity/claim.lua") then
        asteroids = asteroids + 1
      elseif entity:hasScript("entity/wreckagetoship.lua") and rarity.value >= RarityType.Common then
        wrecks = wrecks + 1
      elseif entity:hasScript("entity/stash.lua") and rarity.value >= RarityType.Uncommon then
        stashes = stashes + 1
      elseif entity:hasScript("entity/story/exodusbeacon.lua") and rarity.value >= RarityType.Uncommon then
        exodus = exodus + 1
      end
    end
  end
end

function ObjectDetector.setNewPosition(Position)
  MoveUI.AssignPlayerOverride(Player(),Title,Position)
end

return ObjectDetector
