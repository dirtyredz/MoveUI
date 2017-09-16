package.path = package.path .. ";mods/MoveUI/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"

local MoveUI = require('MoveUI')
require ("utility")

-- namespace ScrapyardLicenses
ScrapyardLicenses = {}

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

function ScrapyardLicenses.onPreRenderHud()
    if onClient() then
        local rect = Rect(vec2(), vec2(400, 100))
        local res = getResolution();

        local DefaulPosition = vec2(res.x * 0.88, res.y * 0.21)
        rect.position = MoveUI.CheckOverride(Player(), DefaulPosition, OverridePosition, Title)

        --get the licenses
        local licenses = Player():getValue("MoveUI#Licenses") or 'return {}'

        licenses = loadstring(licenses)()
        local i = 0
        if licenses then
            for x,cols in pairs(licenses) do
                for y,data in pairs(cols) do
                    i = i + 1
                end
            end
        end

        local HSplit = UIHorizontalMultiSplitter(rect, 10, 8, i - 1)

        if i == 0 then licenses = nil end
        --Reset index
        i = 0
        if licenses then
            for x,cols in pairs(licenses) do
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

function ScrapyardLicenses.onSectorEntered(playerIndex,x,y)
  local licenses = Player():getValue("MoveUI#Licenses") or 'return {}'

  licenses = loadstring(licenses)()
  local x,y = Sector():getCoordinates()

  if (type(licenses[x]) == "table") then
    local count = 0
    for _ in pairs( licenses[x] ) do
      count = count + 1
    end
    if count == 0 then
      --Remove X table since its empty
      licenses[x] = nil
    elseif (type(licenses[x][y]) == "number") then
      --Delete this sectors licenses since any active scrapyards will update
      licenses[x][y] = nil
      print('Removing:',x,y,'from licenses')
    end
  end

  Player():setValue("MoveUI#Licenses", MoveUI.Serialize(licenses))
end
