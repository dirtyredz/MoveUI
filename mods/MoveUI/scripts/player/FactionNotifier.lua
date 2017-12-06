--MoveUI - Dirtyredz|David McClain
package.path = package.path .. ";mods/MoveUI/scripts/lib/?.lua"
local MoveUI = require('MoveUI')

package.path = package.path .. ";data/scripts/lib/?.lua"
FactionsMap = require ("factionsmap")
require ("stringutility")


-- namespace FactionNotifier
FactionNotifier = {}

local OverridePosition

local Title = 'FactionNotifier'
local Icon = "data/textures/icons/freedom-dove.png"
local Description = "Will display details of the owning faction of your current sector."
local DefaultOptions = {
  PF = true
}
local PF_OnOff


local FactionData
local rect
local res
local DefaulPosition
local LoadedOptions
local AllowMoving
local player
local RelationColors = {
    {Relation = -100000, R = 0.5, G = 0, B = 0},
    {Relation = -90000, R = 0.55, G = 0, B = 0},
    {Relation = -80000, R = 0.6, G = 0, B = 0},
    {Relation = -70000, R = 0.65, G = 0, B = 0},
    {Relation = -60000, R = 0.7, G = 0, B = 0},
    {Relation = -50000, R = 0.75, G = 0, B = 0},
    {Relation = -40000, R = 0.8, G = 0, B = 0},
    {Relation = -30000, R = 0.85, G = 0, B = 0},
    {Relation = -20000, R = 0.9, G = 0, B = 0},
    {Relation = -10000, R = 0.95, G = 0, B = 0},
    {Relation = 0, R = 0.3, G = 0, B = 1},
    {Relation = 10000, R = 0.4, G = 1, B = 0.9},
    {Relation = 20000, R = 0.3, G = 1, B = 0.8},
    {Relation = 30000, R = 0.2, G = 1, B = 0.7},
    {Relation = 40000, R = 0.1, G = 1, B = 0.6},
    {Relation = 50000, R = 0, G = 1, B = 0.5},
    {Relation = 60000, R = 0, G = 1, B = 0.4},
    {Relation = 70000, R = 0, G = 1, B = 0.3},
    {Relation = 80000, R = 0, G = 1, B = 0.2},
    {Relation = 90000, R = 0, G = 1, B = 0.1},
    {Relation = 100000, R = 0, G = 1, B = 0}
}
function FactionNotifier.initialize()
  if onClient() then
    player = Player()

    player:registerCallback("onPreRenderHud", "onPreRenderHud")
    FactionNotifier.detect()
    LoadedOptions = MoveUI.GetOptions(player,Title,DefaultOptions)

    rect = Rect(vec2(),vec2(350,80))
    res = getResolution();
    --MoveUI - Dirtyredz|David McClain
    DefaulPosition = vec2(res.x * 0.73,res.y * 0.85)
    rect.position = MoveUI.CheckOverride(player,DefaulPosition,OverridePosition,Title)
  end
end

function FactionNotifier.buildTab(tabbedWindow)
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
  local name = container:createLabel(TextVSplit.left.lower, "Show Present Factions", 16)

  --make sure variables are local to this file only
  PF_OnOff = container:createCheckBox(TextVSplit.right, "On / Off", 'onAllowPresentFactions')
  PF_OnOff.tooltip = 'Will Show the names of other factions in sector.'

  --Pass the name of the function, and the checkbox
  return {checkbox = {onAllowPresentFactions = PF_OnOff}, button = {}}
end

function FactionNotifier.onAllowPresentFactions(checkbox, value)
  --setNewOptions is a function inside entity/MoveUI.lua, that sets the options to the player.
  invokeServerFunction('setNewOptions', Title, {PF = value},Player().index)
end

--Executed when the Main UI Interface is opened.
function FactionNotifier.onShowWindow()
  --Get the player options
  local LoadedOptions = MoveUI.GetOptions(Player(),Title,DefaultOptions)
  --Set the checkbox to match the option
  PF_OnOff.checked = LoadedOptions.PF
end


function FactionNotifier.onPreRenderHud()
  if onClient() then

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

    if not FactionData then return end
    local Length = #FactionData.OtherFactions
    if FactionData.Owner then Length = Length + 1 end


    local HSplit = UIHorizontalMultiSplitter(rect, 0, 0, math.max(Length,0))

    if FactionData.Owner then
        local faction = Faction(FactionData.Owner)
        drawTextRect('Controlled by:', HSplit:partition(0), -1, 0,ColorRGB(1,1,1), 12, 0, 0, 0)

        local MainVSplit = UIVerticalSplitter(HSplit:partition(1), 5, 5, 0.80)
        local Name = faction.name:gsub("%/*This refers to factions, such as 'The Xsotan'.", "")
        Name = Name:gsub("%/*", "")
        Name = Name:gsub("%*", "")
        drawTextRect(Name, MainVSplit.left, 1, 0,ColorRGB(GetRelationColor(FactionData.OwnerRelation)), 12, 0, 0, 0)
        drawTextRect(FactionData.OwnerLicense, MainVSplit.right,-1, 0,FactionData.OwnerLicenseColor, 10, 0, 0, 0)
    end

    if #FactionData.OtherFactions > 0 and LoadedOptions.PF then
        drawTextRect('Factions in Sector:', HSplit:partition(2), -1, 0,ColorRGB(1,1,1), 10, 0, 0, 0)
        local i = 3
        for _,factionData in pairs(FactionData.OtherFactions) do
            local faction = Faction(factionData.index)
            local MainVSplit = UIVerticalSplitter(HSplit:partition(i), 5, 5, 0.80)
            local Name = faction.name:gsub("%/*This refers to factions, such as 'The Xsotan'.", "")
            Name = Name:gsub("%/*", "")
            Name = Name:gsub("%*", "")
            drawTextRect(Name, MainVSplit.left,1, 0,ColorRGB(GetRelationColor(factionData.relation)), 10, 0, 0, 0)
            drawTextRect(factionData.License, MainVSplit.right,-1, 0,factionData.Color, 10, 0, 0, 0)
            i = i + 1
        end
    end

  end
end

function FactionNotifier.updateClient(timeStep)
  FactionNotifier.detect()
  LoadedOptions = MoveUI.GetOptions(player,Title,DefaultOptions)
  AllowMoving = MoveUI.AllowedMoving(player)
end

function FactionNotifier.getUpdateInterval()
    return 5
end

function FactionNotifier.onSectorEntered(playerIndex)
  FactionNotifier.detect()
end

function FactionNotifier.detect()
  if onClient() then
    invokeServerFunction('detect')
    return
  end
  local factionMap = FactionsMap(getGameSeed())
  local OtherFactions = {Sector():getPresentFactions()}
  local Owner = factionMap:getFaction(Sector():getCoordinates())

  local MyFaction = Faction()

  local vanillaItems = MyFaction:getInventory():getItemsByType(InventoryItemType.VanillaItem)
  local Licenses = {}
  for _, p in pairs(vanillaItems) do
      local item = p.item
      if item:getValue("isCargoLicense") == true then
          table.insert(Licenses,item)
      end
  end


  FactionData = {}
  FactionData.Owner = Owner
  if not Faction(Owner) then FactionData.Owner = nil end
  FactionData.OwnerRelation = MyFaction:getRelations(FactionData.Owner)
  FactionData.OwnerLicense = ''
  FactionData.OwnerLicenseColor = ColorRGB(1,1,1)
  for _, item in pairs(Licenses) do
      if item:getValue("faction") == FactionData.Owner then
          if not FactionData.OwnerLicenseValue or FactionData.OwnerLicenseValue < item.rarity.value then
              FactionData.OwnerLicenseValue = item.rarity.value
              FactionData.OwnerLicense = GetRarityLicenseName(item.rarity)
              FactionData.OwnerLicenseColor = item.rarity.color
          end
      end
  end
  FactionData.OtherFactions = {}
  for _,factionIndex in pairs(OtherFactions) do
      local relation = MyFaction:getRelations(factionIndex)
      local License = ''
      local Value = 0
      local Color = ColorRGB(1,1,1)
      if MyFaction.index ~= factionIndex and FactionData.Owner ~= factionIndex then
          for _, item in pairs(Licenses) do
              if item:getValue("faction") == factionIndex then
                  if Value < item.rarity.value then
                      License = GetRarityLicenseName(item.rarity)
                      Color = item.rarity.color
                      Value = item.rarity.value
                  end
              end
          end
          table.insert(FactionData.OtherFactions,{index = factionIndex, relation = relation, License = License, Color = Color})
      end
  end

  FactionNotifier.sync()
end

function GetRarityLicenseName(rarity)
    local rtn = ''
    if rarity.value == RarityType.Common then
        rtn = 'Dangerous'
    elseif rarity.value == RarityType.Uncommon then
        rtn = 'Supicious'
    elseif rarity.value == RarityType.Rare then
        rtn = 'Stolen'
    elseif rarity.value == RarityType.Exceptional then
        rtn = 'Illegal'
    end
    return rtn
end

function FactionNotifier.setNewPosition(Position)
  MoveUI.AssignPlayerOverride(Player(),Title,Position)
end

function FactionNotifier.sync(values)
  if onClient() then
      if values then
          FactionData = values.FactionData
          return
      end
      invokeServerFunction('sync')
  end

  invokeClientFunction(Player(), 'sync', {FactionData = FactionData})
end

function GetRelationColor(relation)
    for _,RC in pairs(RelationColors) do
        local result = RC.Relation-relation
        --print(RC.Relation,relation,math.abs(result))
        if math.abs(result) < 10000 then
            return RC.R,RC.G,RC.B
        end
    end
end

return FactionNotifier
