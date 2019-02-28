--MoveUI - Dirtyredz|David McClain
package.path = package.path .. ";mods/MoveUI/scripts/lib/?.lua"
local MoveUI = require('MoveUI')

-- namespace Clock
Clock = {}

local OverridePosition

local Title = 'Clock'
local Icon = "data/textures/icons/servo.png"
local Description = "Oh no, it's morning again :)"
local rect
local res
local defaultPosition
local AllowMoving
local player
local DefaultOptions = {
  LongHour = false
}
local LongHour_OnOff
local LoadedOptions

function Clock.initialize()
  if onClient() then
    player = Player()

    player:registerCallback("onPreRenderHud", "onPreRenderHud")

    rect = Rect(vec2(),vec2(190,25))
    res = getResolution();

    LoadedOptions = MoveUI.GetVariable(Title.."_Opt",DefaultOptions)

    --MoveUI - Dirtyredz|David McClain
    defaultPosition = vec2(res.x * 0.7,res.y * 0.07)
    rect.position = MoveUI.CheckOverride(player, defaultPosition,OverridePosition,Title)
  end
end

function Clock.buildTab(tabbedWindow)
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
  local name = container:createLabel(TextVSplit.left.lower, "24 hour format", 16)

  --make sure variables are local to this file only
  LongHour_OnOff = container:createCheckBox(TextVSplit.right, "On / Off", 'onLongHour')
  LongHour_OnOff.tooltip = 'When enabled will use 24 hour format'

  --Pass the name of the function, and the checkbox
  return {checkbox = {onLongHour = LongHour_OnOff}, button = {}}
end

function Clock.onLongHour(checkbox, value)
  MoveUI.SetVariable(Title.."_Opt", {LongHour = value})
end

--Executed when the Main UI Interface is opened.
function Clock.onShowWindow()
  --Get the player options
  local LoadedOptions = MoveUI.GetVariable(Title.."_Opt",DefaultOptions)

  --Set the checkbox to match the option
  LongHour_OnOff.checked = LoadedOptions.LongHour
end

function Clock.onPreRenderHud()
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
  local DateTime = os.date("*t")
  local LongHourString = os.date("%H")
  local ShortHourString = os.date("%I")
  if LoadedOptions.LongHour then
    drawTextRect(LongHourString..":"..DateTime.min..":"..DateTime.sec, rect,0, 0,ColorRGB(1,1,1), 15, 0, 0, 0)
  else
    drawTextRect(ShortHourString..":"..DateTime.min..":"..DateTime.sec, rect,0, 0,ColorRGB(1,1,1), 15, 0, 0, 0)
  end
end

function Clock.updateClient(timeStep)
  LoadedOptions = MoveUI.GetVariable(Title.."_Opt",DefaultOptions)

  AllowMoving = MoveUI.AllowedMoving()
end

function Clock.getUpdateInterval()
  return 1
end

return Clock
