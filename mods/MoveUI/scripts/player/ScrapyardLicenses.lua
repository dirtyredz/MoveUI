--MoveUI - Dirtyredz|David McClain
package.path = package.path .. ";mods/MoveUI/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
require ("callable")

local MoveUI = require('MoveUI')
require ("utility")

-- namespace ScrapyardLicenses
ScrapyardLicenses = {}

local AllianceValues = {}
local PlayerValues = {}
local OverridePosition
local Title = 'ScrapyardLicenses'
local Icon = "data/textures/icons/papers.png"
local Description = "Shows all current Scrapyard Licenses, Displays Alliance Licenses if inside an Alliance Ship."
local DefaultOptions = {
  Both = false,
  Clickable = false
}
local Both_OnOff
local Clickable_OnOff
local rect
local res
local DefaulPosition
local player
local timeout = 0
local AllowMoving

function ScrapyardLicenses.initialize()
  if onClient() then
    player = Player()

    player:registerCallback("onPreRenderHud", "onPreRenderHud")

    rect = Rect(vec2(), vec2(400, 100))
    res = getResolution();
    --MoveUI - Dirtyredz|David McClain
    DefaulPosition = vec2(res.x * 0.88, res.y * 0.21)
    rect.position = MoveUI.CheckOverride(player,DefaulPosition,OverridePosition,Title)

  else
    --Lets do some checks on startup/sector entered
    Player():registerCallback("onSectorEntered", "onSectorEntered")

    local x,y = Sector():getCoordinates()
    ScrapyardLicenses.onSectorEntered(Player().index,x,y)
  end
end

function ScrapyardLicenses.buildTab(tabbedWindow)
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
  local name = container:createLabel(TextVSplit.left.lower, "Show Both", 16)
  --make sure variables are local to this file only
  Both_OnOff = container:createCheckBox(TextVSplit.right, "On / Off", 'onShowBoth')
  Both_OnOff.tooltip = 'Shows both Alliance and Players licenses, othewise shows only license for the ship your driving.'

  local TextVSplit = UIVerticalSplitter(OptionsSplit:partition(1),0, 5,0.65)
  local name = container:createLabel(TextVSplit.left.lower, "Clickable", 16)
  --make sure variables are local to this file only
  Clickable_OnOff = container:createCheckBox(TextVSplit.right, "On / Off", 'onClickable')
  Clickable_OnOff.tooltip = 'Allows you to click the UIs shown licenses.'

  local TextVSplit = UIVerticalSplitter(OptionsSplit:partition(2),0, 5,0.65)
  local name = container:createLabel(TextVSplit.left.lower, "Clear Licenses", 16)
  --make sure variables are local to this file only
  ClearButton = container:createButton(TextVSplit.right, "Clear Licenses", 'onClear')
  ClearButton.tooltip = 'Clears all player and alliance licenses from the UI, you will need to jump to finish clearing the data.'

  --Pass the name of the function, and the checkbox
  return {checkbox = {onShowBoth = Both_OnOff, onClickable = Clickable_OnOff}, button = {onClear = ClearButton}}
end

function ScrapyardLicenses.onShowBoth(checkbox, value)

  local LoadedOptions = MoveUI.GetVariable(Title.."_Opt",DefaultOptions)
  --invokeServerFunction('setNewOptions', Title, {Both = value, Clickable = LoadedOptions.Clickable},Player().index)
  MoveUI.SetVariable(Title.."_Opt", {Both = value, Clickable = LoadedOptions.Clickable})
end

function ScrapyardLicenses.onClickable(checkbox, value)

  local LoadedOptions = MoveUI.GetVariable(Title.."_Opt",DefaultOptions)
  MoveUI.SetVariable(Title.."_Opt", {Both = LoadedOptions.Both, Clickable = value})
end

function ScrapyardLicenses.onClear()
  invokeServerFunction('clearValue',Entity(Player().craftIndex).factionIndex,"MoveUI#Licenses",Player().index)
  invokeServerFunction('clearValue',Player().index,"MoveUI#Licenses",Player().index)
end
callable(ScrapyardLicenses, "clearValue")

--Executed when the Main UI Interface is opened.
function ScrapyardLicenses.onShowWindow()
  --Get the player options
  local LoadedOptions = MoveUI.GetVariable(Title.."_Opt",DefaultOptions)
  --Set the checkbox to match the option
  Both_OnOff.checked = LoadedOptions.Both
  Clickable_OnOff.checked = LoadedOptions.Clickable
end

function ScrapyardLicenses.TableSize(tabl)
  local i = 0
  for x,cols in pairs(tabl) do
      for y,data in pairs(cols) do
          i = i + 1
      end
  end
  return i
end

function ScrapyardLicenses.onPreRenderHud()
    if onClient() and Player() then

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

        local InAllianceShip = false
        if not player.craftIndex and not Entity(player.craftIndex) then return end
        if player.index ~= Entity(player.craftIndex).factionIndex then
          InAllianceShip = true
        end

        local playerAlliance = false

        if player.index ~= player.allianceIndex then
          playerAlliance = true
        end

        local AllinaceLicensesSize = 0
        if playerAlliance then
          AllinaceLicensesSize = ScrapyardLicenses.TableSize(AllianceValues)
        end
        local PlayerLicensesSize = ScrapyardLicenses.TableSize(PlayerValues)


        local LoadedOptions = MoveUI.GetVariable(Title.."_Opt",DefaultOptions)
        local showBoth = LoadedOptions.Both
        local Clickable = LoadedOptions.Clickable

        local NumLicenses = 0
        if showBoth then --if shoiwng both factions
          NumLicenses = (PlayerLicensesSize + AllinaceLicensesSize) - 1
        elseif InAllianceShip then --only showing alliance licenses
          NumLicenses = AllinaceLicensesSize - 1
        else --show player
          NumLicenses = PlayerLicensesSize - 1
        end

        local HSplit = UIHorizontalMultiSplitter(rect, 10, 8, math.max(NumLicenses,0))

        if NumLicenses >= 0 then
          --Reset index
          local i = 0
          local ShipFactionLicenses
          local prepend = ''
          --show Alliance if in an alliance ship, otherwise show player
          if InAllianceShip then
            if showBoth then prepend = '[A] ' end
            ShipFactionLicenses = AllianceValues
          else
            if showBoth then prepend = '[P] ' end
            ShipFactionLicenses = PlayerValues
          end

          for x,cols in pairs(ShipFactionLicenses) do
              for y,duration in pairs(cols) do
                  local color = MoveUI.TimeRemainingColor(duration)
                  drawTextRect(prepend..x..' : '..y, HSplit:partition(i), -1, 0, color, 15, 0, 0, 0)
                  drawTextRect(createReadableTimeString(duration), HSplit:partition(i), 1, 0, color, 15, 0, 0, 0)

                  if Clickable then
                    MoveUI.AllowClick(player,HSplit:partition(i),(function () GalaxyMap():show(x, y); print('Showing Galaxy:',x,y) end))
                  end
                  i = i + 1
              end
          end

          ShipFactionLicenses = nil
          if showBoth then
            --if were in an alliance ship then show player
            --otherwise if the player has an alliance show alliance
            if InAllianceShip then
              prepend = '[P] '
              ShipFactionLicenses = PlayerValues
            elseif not InAllianceShip and playerAlliance then
              prepend = '[A] '
              ShipFactionLicenses = AllianceValues
            end
            for x,cols in pairs(ShipFactionLicenses) do
                for y,duration in pairs(cols) do
                    local color = MoveUI.TimeRemainingColor(duration)
                    drawTextRect(prepend..x..' : '..y, HSplit:partition(i), -1, 0, color, 15, 0, 0, 0)
                    drawTextRect(createReadableTimeString(duration), HSplit:partition(i), 1, 0, color, 15, 0, 0, 0)

                    if Clickable then
                      MoveUI.AllowClick(player,HSplit:partition(i),(function () GalaxyMap():show(x, y); print('Showing Galaxy:',x,y) end))
                    end
                    i = i + 1
                end
            end
          end

        end
    end
end

function ScrapyardLicenses.updateClient(timeStep)
  AllowMoving = MoveUI.AllowedMoving()

  local lx, ly = Sector():getCoordinates()
  if PlayerValues[lx] then
    if PlayerValues[lx][ly] then
      PlayerValues[lx][ly] = PlayerValues[lx][ly] - 1
    end
  end
  if AllianceValues[lx] then
    if AllianceValues[lx][ly] then
      AllianceValues[lx][ly] = AllianceValues[lx][ly] - 1
    end
  end

  timeout = timeout + timeStep
  if timeout > 5 then
    timeout = 0
    --get the licenses
    local playerShip = Sector():getEntity(player.craftIndex)
    if not playerShip then return end
    local playerAlliance = player.allianceIndex

    local InAllianceShip = false
    if playerShip then
      if player.index ~= playerShip.factionIndex then
        InAllianceShip = true
      end
    end

    ScrapyardLicenses.GetFactionValues(player.allianceIndex,player.index)
    ScrapyardLicenses.sync()
  end
end

function ScrapyardLicenses.getUpdateInterval()
    return 1
end

function ScrapyardLicenses.GetFactionValues(allianceIndex,playerIndex)
  if onClient() then
    invokeServerFunction('GetFactionValues',allianceIndex,playerIndex)
    return
  end

  if allianceIndex then
    local alliance = Faction(allianceIndex)
    if alliance then
      local TmpAllianceValues = alliance:getValues()
      if TmpAllianceValues['MoveUI#Licenses'] then
        AllianceValues = TmpAllianceValues['MoveUI#Licenses'] or 'return { }'
        AllianceValues = loadstring(AllianceValues)()
      end
    end
  end

  local player = Faction(playerIndex)
  if player then
    local TmpPlayerValues = player:getValues()
    if TmpPlayerValues['MoveUI#Licenses'] then
      PlayerValues = TmpPlayerValues['MoveUI#Licenses'] or 'return { }'
      PlayerValues = loadstring(PlayerValues)()
    end
  end
end
callable(ScrapyardLicenses, "GetFactionValues")

function ScrapyardLicenses.SetFactionValues(allianceIndex,allianceLicenses,playerLicenses)
  if onClient() then
    invokeServerFunction('GetFactionValues',allianceIndex,allianceLicenses,playerLicenses)
    return
  end

  if allianceIndex then
    local faction = Faction(allianceIndex)
    faction:setValue("MoveUI#Licenses", MoveUI.Serialize(allianceLicenses))
  end
  Player():setValue("MoveUI#Licenses", MoveUI.Serialize(playerLicenses))
end
callable(ScrapyardLicenses, "SetFactionValues")

function ScrapyardLicenses.sync(values)
  if onClient() then
    if values then
      AllianceValues = values.AllianceValues
      PlayerValues = values.PlayerValues
      return
    end
    invokeServerFunction('sync')
    return
  end
  invokeClientFunction(Player(callingPlayer),'sync',{AllianceValues = AllianceValues, PlayerValues = PlayerValues})
end
callable(ScrapyardLicenses, "sync")

function ScrapyardLicenses.onSectorEntered(playerIndex,x,y)
  local player = Player()
  --Verify Entity Exsist
  if not Sector():getEntity(player.craftIndex) then return end
  local playerShip = Entity(player.craftIndex)

  local ShipFaction
  if playerShip then
    ShipFaction = playerShip.factionIndex
  else
    ShipFaction = player.index
  end

  ScrapyardLicenses.GetFactionValues(player.allianceIndex, player.index)
  ScrapyardLicenses.sync()

  local x,y = Sector():getCoordinates()

  if (type(AllianceValues[x]) == "table") then
    local count = 0
    for _ in pairs( AllianceValues[x] ) do
      count = count + 1
    end
    if count == 0 then
      --Remove X table since its empty
      AllianceValues[x] = nil
    elseif (type(AllianceValues[x][y]) == "number") then
      --Delete this sectors licenses since any active scrapyards will update
      AllianceValues[x][y] = nil
      print('Removing:',x,y,'from licenses')
    end
  end

  if (type(PlayerValues[x]) == "table") then
    local count = 0
    for _ in pairs( PlayerValues[x] ) do
      count = count + 1
    end
    if count == 0 then
      --Remove X table since its empty
      PlayerValues[x] = nil
    elseif (type(PlayerValues[x][y]) == "number") then
      --Delete this sectors licenses since any active scrapyards will update
      PlayerValues[x][y] = nil
      print('Removing:',x,y,'from licenses')
    end
  end
  ScrapyardLicenses.SetFactionValues(player.allianceIndex, AllianceValues, PlayerValues)
end

return ScrapyardLicenses
