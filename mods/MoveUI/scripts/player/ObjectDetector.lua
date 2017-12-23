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
local ScanSectorTimer = 5

function ObjectDetector.initialize()
  if onClient() then
    player = Player()

    player:registerCallback("onPreRenderHud", "onPreRenderHud")
    ObjectDetector.detect()
    LoadedOptions = MoveUI.GetVariable(Title.."_Opt",DefaultOptions)

    rect = Rect(vec2(),vec2(320,20))
    res = getResolution();
    --MoveUI - Dirtyredz|David McClain
    DefaulPosition = vec2(res.x * 0.5,res.y * 0.90)
    rect.position = MoveUI.CheckOverride(player,DefaulPosition,OverridePosition,Title)
  end
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
  return {checkbox = {onAllowFlashing = AF_OnOff}, button = {}}
end

function ObjectDetector.onAllowFlashing(checkbox, value)

  --invokeServerFunction('setNewOptions', Title, {AF = value},Player().index)
  MoveUI.SetVariable(Title.."_Opt", {AF = value})
end

--Executed when the Main UI Interface is opened.
function ObjectDetector.onShowWindow()
  --Get the player options
  local LoadedOptions = MoveUI.GetVariable(Title.."_Opt",DefaultOptions)
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
          MoveUI.AssignPlayerOverride(Title,OverridePosition)
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
  ScanSectorTimer = ScanSectorTimer - timeStep
  if ScanSectorTimer < 0 then
      ObjectDetector.detect()
      ScanSectorTimer = 5
  end
  LoadedOptions = MoveUI.GetVariable(Title.."_Opt",DefaultOptions)
  AllowMoving = MoveUI.AllowedMoving()
end

function ObjectDetector.getUpdateInterval()
    return 1
end

function ObjectDetector.detect()
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

return ObjectDetector
