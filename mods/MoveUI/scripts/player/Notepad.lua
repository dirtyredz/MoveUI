--MoveUI - Dirtyredz|David McClain
package.path = package.path .. ";mods/MoveUI/scripts/lib/?.lua"
local MoveUI = require('MoveUI')
package.path = package.path .. ";data/scripts/lib/?.lua"
require('utility')
-- namespace Notepad
Notepad = {}

local OverridePosition

local Title = 'Notepad'
local Icon = "data/textures/icons/open-book.png"
local Description = "Notepad enough said."
local rect
local res
local DefaulPosition
local AllowMoving
local LoadedOptions
local Notes= {}
local player
local FS_Slide
local AddNote_Button
local AllowClick
local ClearNote_Button
local Clickable_OnOff
local Note_TextBox
local DefaultOptions = {
  FS = 15,
  C = false
}

function Notepad.initialize()
  if onClient() then
    player = Player()

    player:registerCallback("onPreRenderHud", "onPreRenderHud")

    rect = Rect(vec2(),vec2(400,10))
    res = getResolution();
    --MoveUI - Dirtyredz|David McClain
    DefaulPosition = vec2(res.x * 0.5,res.y * 0.5)
    rect.position = MoveUI.CheckOverride(player,DefaulPosition,OverridePosition,Title)

    LoadedOptions = MoveUI.GetVariable(Title.."_Opt",DefaultOptions)

    resources = {player:getResources()}
    money = player.money
  end
end

function Notepad.buildTab(tabbedWindow)
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
    FS_Slide = container:createSlider(TextVSplit.right, 10, 30, 20, "Font Size", 'onChangeFont')
    FS_Slide.tooltip = 'Changes the Font size and rect size.'

    local TextVSplit = UIVerticalSplitter(OptionsSplit:partition(1),0, 5,0.65)
    local name = container:createLabel(TextVSplit.left.lower, "Clickable (Delete individual)", 16)
    Clickable_OnOff = container:createCheckBox(TextVSplit.right, "On / Off", 'onClickable')
    Clickable_OnOff.tooltip = 'Allows you to click individual notes to delete them.'

    Note_TextBox = container:createTextBox(OptionsSplit:partition(2),"onTextChanged")
    Note_TextBox.maxCharacters = 50

    local TextVSplit = UIVerticalSplitter(OptionsSplit:partition(3),0, 5,0.65)
    local name = container:createLabel(TextVSplit.left.lower, "Add Note", 16)
    AddNote_Button = container:createButton(TextVSplit.right, "Add Notes", 'onAddNote')
    AddNote_Button.tooltip = 'Add Note to Notepad UI.'

    local TextVSplit = UIVerticalSplitter(OptionsSplit:partition(4),0, 5,0.65)
    local name = container:createLabel(TextVSplit.left.lower, "Clear Notes", 16)
    ClearNote_Button = container:createButton(TextVSplit.right, "Clear Notes", 'onClearNotes')
    ClearNote_Button.tooltip = 'Clear Notes to Notepad UI.'

    --Pass the name of the function, and the checkbox
    return {checkbox = {onClickable = Clickable_OnOff}, button = {onAddNote = AddNote_Button, onClearNotes = ClearNote_Button}, slider = {onChangeFont = FS_Slide}, textBox = {onTextChanged = Note_TextBox}}
end

function Notepad.onChangeFont(slider)
    local LoadedOptions = MoveUI.GetVariable(Title.."_Opt",DefaultOptions)
    LoadedOptions.FS = slider.value
    MoveUI.SetVariable(Title.."_Opt", LoadedOptions)
end

--Executed when the Main UI Interface is opened.
function Notepad.onShowWindow()
  --Get the player options
  local LoadedOptions = MoveUI.GetVariable(Title.."_Opt",DefaultOptions)

  --Set the checkbox to match the option
  FS_Slide:setValueNoCallback(LoadedOptions.FS)
  Clickable_OnOff.checked = LoadedOptions.C
end

function Notepad.onAddNote()
    local Notes = MoveUI.GetVariable(Title.."_OptNotes",{})
    table.insert(Notes,Note_TextBox.text)
    MoveUI.SetVariable(Title.."_OptNotes", Notes)
    Note_TextBox:clear()
end

function Notepad.onClearNotes()
    MoveUI.SetVariable(Title.."_OptNotes",{})
    Notes = {}
end

function Notepad.onClickable(checkbox, value)
    local LoadedOptions = MoveUI.GetVariable(Title.."_Opt",DefaultOptions)
    LoadedOptions.C = value
    MoveUI.SetVariable(Title.."_Opt", LoadedOptions)
end

function Notepad.onTextChanged()
end

function Notepad.onPreRenderHud()
  if not LoadedOptions.FS then LoadedOptions.FS = 15 end
  local Length = #Notes * 15
  local NewRect = Rect(rect.lower,rect.upper + vec2(22 * (LoadedOptions.FS - 9),Length + 8 * (LoadedOptions.FS - 9)))

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

  local HSplit = UIHorizontalMultiSplitter(NewRect, 0, 0, #Notes-1)
  local FontSize = LoadedOptions.FS or 15

  for i,note in pairs(Notes) do
      drawTextRect(i..". "..note, HSplit:partition(i-1),-1, 0,ColorRGB(1,1,1), FontSize, 0, 0, 0)
      if LoadedOptions.C then
          MoveUI.AllowClick(player,HSplit:partition(i-1),(function () table.remove(Notes,i); MoveUI.SetVariable(Title.."_OptNotes", Notes); end))
      end
  end
end

function Notepad.updateClient(timeStep)
  LoadedOptions = MoveUI.GetVariable(Title.."_Opt",DefaultOptions)
  Notes = MoveUI.GetVariable(Title.."_OptNotes",{})
  AllowMoving = MoveUI.AllowedMoving()
end

function Notepad.getUpdateInterval()
    return 1
end

return Notepad
