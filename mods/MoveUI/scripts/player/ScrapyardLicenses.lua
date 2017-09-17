package.path = package.path .. ";mods/MoveUI/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"

local MoveUI = require('MoveUI')
require ("utility")

-- namespace ScrapyardLicenses
ScrapyardLicenses = {}

local FactionValues = {}
local Title = 'ScrapyardLicenses'

function ScrapyardLicenses.initialize()
  if onClient() then
    --Obviously
    Player():registerCallback("onPreRenderHud", "onPreRenderHud")
  else
    --Lets do some checks on startup/sector entered
    Player():registerCallback("onSectorEntered", "onSectorEntered")

    local x,y = Sector():getCoordinates()
    ScrapyardLicenses.onSectorEntered(Player().index,x,y)
  end
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
    if onClient() then
        local rect = Rect(vec2(), vec2(400, 100))
        local res = getResolution();

        local DefaulPosition = vec2(res.x * 0.88, res.y * 0.21)
        rect.position = MoveUI.CheckOverride(Player(), DefaulPosition, OverridePosition, Title)

        --get the licenses
        local player = Player()
        local playerShip = Entity(player.craftIndex)
        local ShipFaction = playerShip.factionIndex

        ScrapyardLicenses.GetFactionValues(ShipFaction)
        ScrapyardLicenses.sync()

        local FactionLicenses = FactionValues['MoveUI#Licenses'] or 'return { }'
        FactionLicenses = loadstring(FactionLicenses)()

        local FactionLicensesSize = ScrapyardLicenses.TableSize(FactionLicenses)

        local HSplit = UIHorizontalMultiSplitter(rect, 10, 8, FactionLicensesSize - 1)

        if FactionLicensesSize == 0 then FactionLicenses = nil end
        --Reset index
        local i = 0
        if FactionLicenses then
            for x,cols in pairs(FactionLicenses) do
                for y,duration in pairs(cols) do
                    local color = MoveUI.TimeRemainingColor(duration)
                    drawTextRect(x..' : '..y, HSplit:partition(i), -1, 0, color, 15, 0, 0, 0)
                    drawTextRect(createReadableTimeString(duration), HSplit:partition(i), 1, 0, color, 15, 0, 0, 0)

                    MoveUI.AllowClick(Player(),HSplit:partition(i),(function () GalaxyMap():show(x, y); print('Showing Galaxy:',x,y) end))
                    i = i + 1
                end
            end
        end

        --MoveUI stuff
        OverridePosition, Moving = MoveUI.Enabled(Player(), rect, OverridePosition)
        if OverridePosition and not Moving then
            invokeServerFunction('setNewPosition', OverridePosition)
        end
    end
end

function ScrapyardLicenses.setNewPosition(Position)
    MoveUI.AssignPlayerOverride(Player(), Title, Position)
end

function ScrapyardLicenses.GetFactionValues(factionIndex)
  if onClient() then
    invokeServerFunction('GetFactionValues',factionIndex)
    return
  end
  local faction = Faction(factionIndex)
  if not faction then return end
  FactionValues = faction:getValues()
end

function ScrapyardLicenses.SetFactionValues(factionIndex,licenses)
  if onClient() then
    invokeServerFunction('GetFactionValues',factionIndex,licenses)
    return
  end
  local faction = Faction(factionIndex)
  if not faction then return end
  faction:setValue("MoveUI#Licenses", MoveUI.Serialize(licenses))
end

function ScrapyardLicenses.sync(values)
  if onClient() then
    if values then
      FactionValues = values.FactionValues
      return
    end
    invokeServerFunction('sync')
    return
  end
  invokeClientFunction(Player(callingPlayer),'sync',{FactionValues = FactionValues})
end

function ScrapyardLicenses.onSectorEntered(playerIndex,x,y)
  local player = Player()
  local playerShip = Entity(player.craftIndex)
  local ShipFaction = playerShip.factionIndex

  ScrapyardLicenses.GetFactionValues(ShipFaction)
  ScrapyardLicenses.sync()

  local FactionLicenses = FactionValues['MoveUI#Licenses'] or 'return { }'
  FactionLicenses = loadstring(FactionLicenses)()

  local x,y = Sector():getCoordinates()

  if (type(FactionLicenses[x]) == "table") then
    local count = 0
    for _ in pairs( FactionLicenses[x] ) do
      count = count + 1
    end
    if count == 0 then
      --Remove X table since its empty
      FactionLicenses[x] = nil
    elseif (type(FactionLicenses[x][y]) == "number") then
      --Delete this sectors licenses since any active scrapyards will update
      FactionLicenses[x][y] = nil
      print('Removing:',x,y,'from licenses')
    end
  end
  ScrapyardLicenses.SetFactionValues(ShipFaction,FactionLicenses)
end
