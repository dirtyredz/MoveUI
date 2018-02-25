--MoveUI - Dirtyredz|David McClain
package.path = package.path .. ";mods/MoveUI/scripts/lib/?.lua"
local MoveUI = require('MoveUI')
package.path = package.path .. ";data/scripts/lib/?.lua"
require('utility')
-- namespace PowerSystems
PowerSystems = {}

local OverridePosition

local Title = 'PowerSystems'
local Icon = "data/textures/icons/battery-pack-alt.png"
local Description = "Shows energy systems details."
local rect
local res
local DefaulPosition
local AllowMoving
local LoadedOptions
local player
local FS_Slide
local DefaultOptions = {
  FS = 15
}

function PowerSystems.initialize()
  if onClient() then
    player = Player()

    player:registerCallback("onPreRenderHud", "onPreRenderHud")

    rect = Rect(vec2(),vec2(230,130))
    res = getResolution();
    --MoveUI - Dirtyredz|David McClain
    DefaulPosition = vec2(res.x * 0.92,res.y * 0.68)
    rect.position = MoveUI.CheckOverride(player,DefaulPosition,OverridePosition,Title)

    LoadedOptions = MoveUI.GetVariable(Title.."_Opt",DefaultOptions)

    resources = {player:getResources()}
    money = player.money
  end
end

function PowerSystems.buildTab(tabbedWindow)
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

    local OptionsSplit = UIHorizontalMultiSplitter(mainSplit.bottom, 0, 0, 5)

    local TextVSplit = UIVerticalSplitter(OptionsSplit:partition(0),0, 5,0.65)
    local name = container:createLabel(TextVSplit.left.lower, "Font Size", 16)
    --make sure variables are local to this file only
    FS_Slide = container:createSlider(TextVSplit.right, 10, 30, 20, "Font Size", 'onChangeFont')
    FS_Slide.tooltip = 'Changes the Font size and rect size.'

    --Pass the name of the function, and the checkbox
    return {checkbox = {}, button = {}, slider = {onChangeFont = FS_Slide}}
end

function PowerSystems.onChangeFont(slider)
  MoveUI.SetVariable(Title.."_Opt", {FS = slider.value})
end

--Executed when the Main UI Interface is opened.
function PowerSystems.onShowWindow()
  --Get the player options
  local LoadedOptions = MoveUI.GetVariable(Title.."_Opt",DefaultOptions)

  --Set the checkbox to match the option
  FS_Slide:setValueNoCallback(LoadedOptions.FS)
end

function PowerSystems.onPreRenderHud()

  local NewRect = Rect(rect.lower,rect.upper + vec2(22 * (LoadedOptions.FS - 9),8 * (LoadedOptions.FS - 9)))

  if OverridePosition then
    rect.position = OverridePosition
  end

  if AllowMoving then
    OverridePosition, Moving = MoveUI.Enabled(NewRect, OverridePosition)
    if OverridePosition and not Moving then
        MoveUI.AssignPlayerOverride(Title,OverridePosition)
        OverridePosition = nil
    end

    drawTextRect(Title, NewRect, 0, 0,ColorRGB(1,1,1), 10, 0, 0, 0)
    return
  end

  local HSplit = UIHorizontalMultiSplitter(NewRect, 20, 5, 5)
  if not player.craftIndex then return end
  local ES = ReadOnlyEnergySystem(player.craftIndex)
  if not ES then return end
  local FontSize = LoadedOptions.FS or 15
  drawTextRect("Stored Energy", HSplit:partition(0),-1, 0,ColorRGB(1,1,1), FontSize, 0, 0, 0)
  drawTextRect(PowerSystems.convertToString(ES.energy).." / "..PowerSystems.convertToString(ES.capacity), HSplit:partition(0),1, 0,PowerSystems.GetColor(ES.energy,ES.capacity), FontSize, 0, 0, 0)
  drawTextRect("Produced Energy", HSplit:partition(1),-1, 0,ColorRGB(1,1,1), FontSize, 0, 0, 0)
  drawTextRect(PowerSystems.convertToString(ES.productionRate), HSplit:partition(1),1, 0,PowerSystems.GetColor(ES.productionRate,ES.requiredEnergy), FontSize, 0, 0, 0)
  drawTextRect("Consumable Energy", HSplit:partition(2),-1, 0,ColorRGB(1,1,1), FontSize, 0, 0, 0)
  drawTextRect(PowerSystems.convertToString(ES.consumableEnergy), HSplit:partition(2),1, 0,PowerSystems.GetColor(ES.consumableEnergy,ES.capacity+ES.superflousEnergy), FontSize, 0, 0, 0)
  drawTextRect("Required Energy", HSplit:partition(3),-1, 0,ColorRGB(1,1,1), FontSize, 0, 0, 0)
  drawTextRect(PowerSystems.convertToString(ES.requiredEnergy), HSplit:partition(3),1, 0,ColorRGB(1,1,1), FontSize, 0, 0, 0)
  drawTextRect("Recharge Rate", HSplit:partition(4),-1, 0,ColorRGB(1,1,1), FontSize, 0, 0, 0)
  drawTextRect(PowerSystems.convertToString(ES.rechargeRate), HSplit:partition(4),1, 0,ColorRGB(1,1,1), FontSize, 0, 0, 0)
  drawTextRect("Superflous Energy", HSplit:partition(5),-1, 0,ColorRGB(1,1,1), FontSize, 0, 0, 0)
  drawTextRect(PowerSystems.convertToString(ES.superflousEnergy), HSplit:partition(5),1, 0,ColorRGB(1,1,1), FontSize, 0, 0, 0)

end

function PowerSystems.convertToString(double)
    local string = " W"
    local newNum = double
    if double > 1000000000000 then
        newNum = double / 1000000000000
        string = " TJ"
    elseif double > 1000000000 then
        newNum = double / 1000000000
        string = " GJ"
    elseif double > 1000000 then
        newNum = double / 1000000
        string = " MW"
    elseif double > 1000 then
        newNum = double / 1000
        string = " kW"
    end
    return PowerSystems.round(newNum,2)..string
end

function PowerSystems.GetColor(double,double2)
    local percent = double/double2
    percent = percent * 100
    local color = ColorRGB(0,1,0)
    if percent < 25 then
        color = ColorRGB(1,0,0)
    elseif percent < 75 then
        color = ColorRGB(1,1,0)
    end
    return color
end

function PowerSystems.round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function PowerSystems.updateClient(timeStep)
  LoadedOptions = MoveUI.GetVariable(Title.."_Opt",DefaultOptions)
  resources = {player:getResources()}
  money = player.money
  AllowMoving = MoveUI.AllowedMoving()
end

function PowerSystems.getUpdateInterval()
    return 1
end

return PowerSystems
