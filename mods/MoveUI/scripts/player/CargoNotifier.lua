--MoveUI - Dirtyredz|David McClain
package.path = package.path .. ";mods/MoveUI/scripts/lib/?.lua"
local MoveUI = require('MoveUI')

-- namespace CargoNotifier
CargoNotifier = {}

local OverridePosition

local Title = 'CargoNotifier'
local Icon = "data/textures/icons/crate.png"
local Description = "Displays warning if you have Dangerous, Stolen, Suspicious, or Illegal Cargo"
local DefaultOptions = {
  AF = false
}
local AF_OnOff
local rect
local res
local DefaulPosition
local LoadedOptions
local player
local Cargos
local AllowMoving

function CargoNotifier.initialize(Description)
  if onClient() then
    player = Player()

    player:registerCallback("onPreRenderHud", "onPreRenderHud")

    rect = Rect(vec2(),vec2(170,150))
    res = getResolution();
    --MoveUI - Dirtyredz|David McClain
    DefaulPosition = vec2(res.x * 0.34,res.y * 0.07)
    rect.position = MoveUI.CheckOverride(player,DefaulPosition,OverridePosition,Title)

    LoadedOptions = MoveUI.GetVariable(Title.."_Opt",DefaultOptions)

    local PlayerShip = player.craft
    if not PlayerShip then return end
    Cargos = PlayerShip:getCargos()
  end
end

function CargoNotifier.buildTab(tabbedWindow)
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
  AF_OnOff.tooltip = 'Will Flash when dangerous cargo is detected.'

  --Pass the name of the function, and the checkbox
  return {checkbox = {onAllowFlashing = AF_OnOff}, button = {}}
end

function CargoNotifier.onAllowFlashing(checkbox, value)
  MoveUI.SetVariable(Title.."_Opt", {AF = value})
end

--Executed when the Main UI Interface is opened.
function CargoNotifier.onShowWindow()
  --Get the player options
  local LoadedOptions = MoveUI.GetVariable(Title.."_Opt",DefaultOptions)

  --Set the checkbox to match the option
  AF_OnOff.checked = LoadedOptions.AF
end

function CargoNotifier.onPreRenderHud()
  if onClient() then

    if not Cargos then return end

    local SeenIllegal = false
    local SeenStolen = false
    local SeenDangerous = false
    local SeenSuspicious = false

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
    --MoveUI - Dirtyredz|David McClain

    local HSplit = UIHorizontalMultiSplitter(rect, 10, 10, 3)

    --Flashing Option
    if os.time() % 2 == 0 and LoadedOptions.AF then return end

    for TradingGood,index in pairs(Cargos) do
      if TradingGood.illegal and not SeenIllegal then
        drawTextRect('Illegal Cargo', HSplit:partition(0),0, 0,ColorRGB(255,0,0), 15, 0, 0, 0)
        drawBorder(HSplit:partition(0), ColorRGB(255,0,0))
        SeenIllegal = true
      end
      if TradingGood.stolen and not SeenStolen  then
        drawTextRect('Stolen Cargo', HSplit:partition(1),0, 0,ColorRGB(255,0,0), 15, 0, 0, 0)
        drawBorder(HSplit:partition(1), ColorRGB(255,0,0))
        SeenStolen = true
      end
      if TradingGood.dangerous and not SeenDangerous  then
        drawTextRect('Dangerous Cargo', HSplit:partition(2),0, 0,ColorRGB(255,0,0), 15, 0, 0, 0)
        drawBorder(HSplit:partition(2), ColorRGB(255,0,0))
        SeenDangerous = true
      end
      if TradingGood.suspicious and not SeenSuspicious  then
        drawTextRect('Suspicious Cargo', HSplit:partition(3),0, 0,ColorRGB(255,0,0), 15, 0, 0, 0)
        drawBorder(HSplit:partition(3), ColorRGB(255,0,0))
        SeenSuspicious = true
      end
    end
  end
end

function CargoNotifier.updateClient(timeStep)
  --LoadedOptions = MoveUI.GetVariable(Title.."_Opt",DefaultOptions)
  LoadedOptions = MoveUI.GetVariable(Title.."_Opt",DefaultOptions)
  local PlayerShip = player.craft
  if not PlayerShip then return end
  Cargos = PlayerShip:getCargos()
  AllowMoving = MoveUI.AllowedMoving()
end

function CargoNotifier.getUpdateInterval()
    return 1
end

return CargoNotifier
