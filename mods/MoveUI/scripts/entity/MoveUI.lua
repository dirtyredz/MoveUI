package.path = package.path .. ";data/scripts/lib/?.lua"
require ("stringutility")
require ("utility")
require ("callable")

package.path = package.path .. ";mods/MoveUI/scripts/lib/?.lua"
local MoveUI = require('MoveUI')

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace MoveUIOptions
MoveUIOptions = {}

--For EXTERNAL configuration files
package.path = package.path .. ";mods/MoveUI/config/?.lua"
MoveUIConfig = nil
exsist, MoveUIConfig = pcall(require, 'MoveUIConfig')

MoveUIOptions.HudList = MoveUIConfig.HudList or {}

local UILabels = {}
local MoveAllCheckbox
local ShowWindowFuncs = {}

function MoveUIOptions.interactionPossible(playerIndex, option)
  local factionIndex = Entity().factionIndex
  if factionIndex == playerIndex or factionIndex == Player().allianceIndex then
      return true
  end
  return false
end

function MoveUIOptions.getIcon()
    return "data/textures/icons/select-frame.png"
end

function MoveUIOptions.initUI()
    local NumUIs = #MoveUIOptions.HudList or 1

    local res = getResolution()
    local size = vec2((300 + (NumUIs*30)), (NumUIs*30)*2)

    local menu = ScriptUI()
    MainWindow = menu:createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5));
    menu:registerWindow(MainWindow, "Move UI");
    MainWindow.caption = "Move UI"
    MainWindow.showCloseButton = 1
    MainWindow.moveable = 1

    -- create a tabbed window inside the main window
    local tabbedWindow = MainWindow:createTabbedWindow(Rect(vec2(10, 10), size - 10))

    -- create buy tab
    local MainTab = tabbedWindow:createTab("Main"%_t, "", "Main"%_t)

    local container = MainTab:createContainer(Rect(vec2(0, 0), MainTab.size));
    --local container = MainWindow:createContainer(Rect(vec2(0, 0), size));

    --split it 50/50
    local mainSplit = UIHorizontalSplitter(Rect(vec2(0, 0), MainTab.size), 0, 0, 0.3)
    --local mainSplit = UIHorizontalSplitter(Rect(vec2(0, 0), size), 0, 0, 0.5)

    --Top Message
    local TopHSplit = UIHorizontalSplitter(mainSplit.top, 0, 0, 0.4)
    local TopMessage = container:createLabel(TopHSplit.top.lower + vec2(10,10), 'MoveUI controller, enable and disable UIs', 16)

    --All UI's
    local MiddleHSplit = UIHorizontalSplitter(TopHSplit.bottom, 0, 0, 0.5)

    --Move All
    local MoveAllVSplit = UIVerticalSplitter(MiddleHSplit.top,0, 0,0.65)
    local name = container:createLabel(MoveAllVSplit.left.lower, 'Enable UI Movement', 16)
    MoveAllCheckbox = container:createCheckBox(MoveAllVSplit.right, "On / Off", 'onAllowUIMovement')

    --Reset All
    local ResetVSplit = UIVerticalSplitter(MiddleHSplit.bottom,0, 0,0.5)
    local name = container:createLabel(ResetVSplit.left.lower, 'Reset All UI Positions', 16)
    local OnOff = container:createButton(ResetVSplit.right, "Reset UIs", 'onResetUIs')

    --List all available UI's
    local hsplit = UIHorizontalMultiSplitter(mainSplit.bottom, 0, 0, NumUIs)
    for index,HudFile in pairs(MoveUIOptions.HudList) do
      if HudFile.FileName then
        local rect = hsplit:partition(index)
        local TextVSplit = UIVerticalSplitter(rect,0, 3,0.65)

        local name = container:createLabel(TextVSplit.left.lower, HudFile.FileName, 14)
        local OnOff = container:createCheckBox(TextVSplit.right, "On / Off", 'onEnableUI')

        table.insert(UILabels,{name = name, hudIndex = index, OnOff = OnOff, index = OnOff.index})
      end
    end

    for index,HudFile in pairs(MoveUIOptions.HudList) do
      if HudFile.FileName then
        --Get the UI's File and all its functions.
        local exsist, UIFile = pcall(require, 'mods.MoveUI.scripts.player.'..HudFile.FileName)
        if exsist and UIFile.buildTab then
          --Check and store the UI's onShowWindow functions
          if UIFile.onShowWindow then table.insert(ShowWindowFuncs,UIFile.onShowWindow) end

          --Build the tab using the UI's buildTab function
          local InterfaceFunctions = UIFile.buildTab(tabbedWindow) or {checkbox={},button={},slider={},textBox={}}
          --The UI's buildTab option will return a table of functions to be added to the MoveUIOptions table
          --This is necassary since string callback functions search for the function inside this namespace
          if not InterfaceFunctions.checkbox then InterfaceFunctions.checkbox = {} end
          for FuncName,CheckBox in pairs(InterfaceFunctions.checkbox) do
            --prepend it with the filename so the function name is always unique
            CheckBox.onCheckedFunction = HudFile.FileName..'_'..FuncName
            MoveUIOptions[HudFile.FileName..'_'..FuncName] = UIFile[FuncName]
          end
          if not InterfaceFunctions.button then InterfaceFunctions.button = {} end
          for FuncName,button in pairs(InterfaceFunctions.button) do
            --prepend it with the filename so the function name is always unique
            button.onPressedFunction = HudFile.FileName..'_'..FuncName
            MoveUIOptions[HudFile.FileName..'_'..FuncName] = UIFile[FuncName]
          end
          if not InterfaceFunctions.slider then InterfaceFunctions.slider = {} end
          for FuncName,slider in pairs(InterfaceFunctions.slider) do
            --prepend it with the filename so the function name is always unique
            slider.onChangedFunction = HudFile.FileName..'_'..FuncName
            MoveUIOptions[HudFile.FileName..'_'..FuncName] = UIFile[FuncName]
          end
          if not InterfaceFunctions.textBox then InterfaceFunctions.textBox = {} end
          for FuncName,textBox in pairs(InterfaceFunctions.textBox) do
            --prepend it with the filename so the function name is always unique
            textBox.onTextChangedFunction = HudFile.FileName..'_'..FuncName
            MoveUIOptions[HudFile.FileName..'_'..FuncName] = UIFile[FuncName]
          end
        end
      end
    end
end

--Set the UI's Options to the players data
function MoveUIOptions.clearValue(FactionIndex,ValueName,PlayerIndex)
  MoveUI.ClearValue(FactionIndex,ValueName)
  Player(PlayerIndex):removeScript('mods/MoveUI/scripts/player/ScrapyardLicenses.lua')
  Player(PlayerIndex):addScript('mods/MoveUI/scripts/player/ScrapyardLicenses.lua')
end

function MoveUIOptions.onShowWindow()
  if Player():getValue('MoveUI') then
    MoveAllCheckbox.checked = true
  end
  for _,checkbox in pairs(UILabels) do
    if Player():hasScript('mods/MoveUI/scripts/player/'..MoveUIOptions.HudList[checkbox.hudIndex].FileName..'.lua') then
      checkbox.OnOff.checked = true
    else
      checkbox.OnOff.checked = false
    end
  end

  --execute all onShowWindows for all UI's
  for _,func in pairs(ShowWindowFuncs) do
    if type(func) == 'function' then
      func()
    end
  end
end

function MoveUIOptions.initialize()
end

function MoveUIOptions.onResetUIs()
    MoveUI.SaveVariables({})
    for _,cb in pairs(UILabels) do
        if cb.OnOff.checked then print(cb.name) end
    end
end

function MoveUIOptions.onAllowUIMovement(checkbox, value)
    if onClient() then
      MoveUI.SetVariable("AllowMoving", value)
      invokeServerFunction('onAllowUIMovement',nil,value)
      return
    end
    if value then
      Player(callingPlayer):setValue('MoveUI',true)
      return
    end
    Player(callingPlayer):setValue('MoveUI',nil)
end
callable(MoveUIOptions, "onAllowUIMovement")

function MoveUIOptions.onEnableUI(checkbox, value, hudIndex)
    if onClient() then
      local hudIndex = 0
      for _,cb in pairs(UILabels) do
        if cb.OnOff.index == checkbox.index then
          hudIndex = cb.hudIndex
        end
      end
      invokeServerFunction('onEnableUI',nil,value,hudIndex)
      return
    end
    local player = Player(callingPlayer)
    local hudOptions = MoveUIOptions.HudList[hudIndex]
    if value then
      if hudOptions.Restriction(player) then
        player:addScriptOnce("mods/MoveUI/scripts/player/"..hudOptions.FileName..".lua")
      else
        player:removeScript("mods/MoveUI/scripts/player/"..hudOptions.FileName..".lua")
        player:sendChatMessage('MoveUI', 1, "You do not have permission to do that!")
        invokeClientFunction(player, 'onShowWindow')
      end
      return
    end
    player:removeScript("mods/MoveUI/scripts/player/"..hudOptions.FileName..".lua")
end
callable(MoveUIOptions, "onEnableUI")
