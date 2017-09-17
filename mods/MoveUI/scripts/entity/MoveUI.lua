package.path = package.path .. ";data/scripts/lib/?.lua"
require ("stringutility")
require ("utility")

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
    local size = vec2(400, (NumUIs*50)*2)

    local menu = ScriptUI()
    MainWindow = menu:createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5));
    menu:registerWindow(MainWindow, "Move UI");
    MainWindow.caption = "Move UI"
    MainWindow.showCloseButton = 1
    MainWindow.moveable = 1

    local container = MainWindow:createContainer(Rect(vec2(0, 0), size));

    --split it 50/50
    local mainSplit = UIHorizontalSplitter(Rect(vec2(0, 0), size), 0, 0, 0.5)

    --Top Message
    local TopHSplit = UIHorizontalSplitter(mainSplit.top, 0, 0, 0.5)
    local TopMessage = container:createLabel(TopHSplit.top.lower + vec2(10,10), 'MoveUI controller, enable and disable UIs', 16)

    --All UI's
    local MiddleHSplit = UIHorizontalSplitter(TopHSplit.bottom, 0, 0, 0.5)

    --Move All
    local MoveAllVSplit = UIVerticalSplitter(MiddleHSplit.top,0, 5,0.65)
    local name = container:createLabel(MoveAllVSplit.left.lower, 'Enable UI Movement', 16)
    MoveAllCheckbox = container:createCheckBox(MoveAllVSplit.right, "On / Off", 'onAllowUIMovement')

    --Reset All
    local ResetVSplit = UIVerticalSplitter(MiddleHSplit.bottom,0, 5,0.65)
    local name = container:createLabel(ResetVSplit.left.lower, 'Reset All UI Positions', 16)
    local OnOff = container:createButton(ResetVSplit.right, "Reset UIs", 'onResetUIs')

    --List all available UI's
    local hsplit = UIHorizontalMultiSplitter(mainSplit.bottom, 0, 0, NumUIs)
    for index,HudFile in pairs(MoveUIOptions.HudList) do
      if HudFile.FileName then
        local rect = hsplit:partition(index)
        local TextVSplit = UIVerticalSplitter(rect,0, 5,0.65)

        local name = container:createLabel(TextVSplit.left.lower, HudFile.FileName, 16)
        local OnOff = container:createCheckBox(TextVSplit.right, "On / Off", 'onEnableUI')

        table.insert(UILabels,{name = name, hudIndex = index, OnOff = OnOff, index = OnOff.index})
      end
    end
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
end

function MoveUIOptions.initialize()
end

function MoveUIOptions.onResetUIs()
    if onClient() then
      invokeServerFunction('onResetUIs')
      return
    end
    local player = Player()
    local PlayerValues = player:getValues()
    for k, v in pairs(PlayerValues) do
      if string.match(k, "_MUI") then
        player:setValue(k,nil)
      end
    end
end

function MoveUIOptions.onAllowUIMovement(checkbox, value)
    if onClient() then
      invokeServerFunction('onAllowUIMovement',nil,value)
      return
    end
    if value then
      Player(callingPlayer):setValue('MoveUI',true)
      return
    end
    Player(callingPlayer):setValue('MoveUI',nil)
end

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
