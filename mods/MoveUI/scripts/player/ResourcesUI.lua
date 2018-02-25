--MoveUI - Dirtyredz|David McClain
--Tsunder wuz here
package.path = package.path .. ";mods/MoveUI/scripts/lib/?.lua"
local MoveUI = require('MoveUI')

-- namespace ResourcesUI
ResourcesUI = {}

local OverridePosition

local Title = 'ResourcesUI'
local Icon = "data/textures/icons/metal-bar.png"
local Description = "Shows all your, or your alliance's, resources."
local DefaultOptions = {
  SA = true
}
local ShowAlliance

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
    LoadedOptions = MoveUI.GetVariable(Title.."_Opt",DefaultOptions)
    ShowAlliance = LoadedOptions.SA
    player:registerCallback("onPreRenderHud", "onPreRenderHud")

    rect = Rect(vec2(),vec2(300,155))
    res = getResolution();
    --MoveUI - Dirtyredz|David McClain
    DefaulPosition = vec2(res.x * 0.92,res.y * 0.68)
    rect.position = MoveUI.CheckOverride(player,DefaulPosition,OverridePosition,Title)

    updateResourcesInfo()
  end
end

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

  local OptionsSplit = UIHorizontalMultiSplitter(mainSplit.bottom, 0, 0, 1)

  local TextVSplit = UIVerticalSplitter(OptionsSplit:partition(0),0, 5,0.65)
  local name = container:createLabel(TextVSplit.left.lower, "Show Alliance", 16)

  --make sure variables are local to this file only
  ShowAlliance = container:createCheckBox(TextVSplit.right, "On / Off", 'onShowAlliance')
  ShowAlliance.tooltip = 'Show Alliance resources instead of player resources.'

  --Pass the name of the function, and the checkbox
  return {checkbox = {onShowAlliance = ShowAlliance}, button = {}}
end

--Executed when the Main UI Interface is opened.
function ResourcesUI.onShowWindow()
  --Get the player options
  local LoadedOptions = MoveUI.GetVariable(Title.."_Opt",DefaultOptions)
  --Set the checkbox to match the option
  ShowAlliance.checked = LoadedOptions.SA
end


function ResourcesUI.onShowAlliance(checkbox, value)
  MoveUI.SetVariable(Title.."_Opt", {SA = value})
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

  if LoadedOptions.SA then
    drawTextRect('[A] Credits', HSplit:partition(0),-1, 0,ColorRGB(1,1,1), 15, 0, 0, 0)
    drawTextRect(MoveUI.NicerNumbers(money), HSplit:partition(0),1, 0,ColorRGB(1,1,1), 15, 0, 0, 0)
    for i = 0, 6 do
      drawTextRect("[A] " .. Material(i).name, HSplit:partition(i+1),-1, 0,Material(i).color, 15, 0, 0, 0)
      drawTextRect(MoveUI.NicerNumbers(resources[i+1]), HSplit:partition(i+1),1, 0,Material(i).color, 15, 0, 0, 0)
    end
  else
    drawTextRect('Credits', HSplit:partition(0),-1, 0,ColorRGB(1,1,1), 15, 0, 0, 0)
    drawTextRect(MoveUI.NicerNumbers(money), HSplit:partition(0),1, 0,ColorRGB(1,1,1), 15, 0, 0, 0)
    for i = 0, 6 do
      drawTextRect(Material(i).name, HSplit:partition(i+1),-1, 0,Material(i).color, 15, 0, 0, 0)
      drawTextRect(MoveUI.NicerNumbers(resources[i+1]), HSplit:partition(i+1),1, 0,Material(i).color, 15, 0, 0, 0)
    end
  end
end

function ResourcesUI.updateClient(timeStep)
  updateResourcesInfo()
  LoadedOptions = MoveUI.GetVariable(Title.."_Opt",DefaultOptions)
  AllowMoving = MoveUI.AllowedMoving()
end

function ResourcesUI.getUpdateInterval()
    return 1
end

function updateResourcesInfo()
  local allegiance = player.allianceIndex
  if LoadedOptions.SA and allegiance then
    local a = Alliance(allegiance)
    resources = {a:getResources()}
    money = a.money
  else
    resources = {player:getResources()}
    money = player.money
  end
end

return ResourcesUI
