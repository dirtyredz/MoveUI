Scrapyard.updateServerOld = Scrapyard.updateServer

require('mods.MoveUI.scripts.lib.serialize')

function Scrapyard.updateServer(timeStep)

    Data = Scrapyard.secure()
    licenses = Data["licenses"]

    local x,y = Sector():getCoordinates()
    for playerIndex,duration in pairs(licenses) do
        local player = Player(playerIndex)

        if player.isPlayer then
            -- read current or init new
            local pLicenses = Scrapyard.GetPlayerLicense(playerIndex)
            local time = round(duration - timeStep)
            if time < 0 then
              time = nil
            end
            pLicenses[x][y] = time

            player:setValue("MoveUI#Licenses", serialize(pLicenses))
        end
    end

    Scrapyard.updateServerOld(timeStep)
end

function Scrapyard.GetPlayerLicense(playerIndex)

    local x,y = Sector():getCoordinates()
    local player = Player(playerIndex)

    local licenses
    local PlayerLicenses = player:getValue("MoveUI#Licenses") or false
    if player and player.isPlayer and PlayerLicenses then
        licenses = loadstring(PlayerLicenses)()
    else
        licenses = {}
    end

    -- Sanity checks / init new
    if (type(licenses) ~= "table") then
        licenses = {}
    end
    if (type(licenses[x]) ~= "table") then
        licenses[x] = {}
    end
    if (type(licenses[x][y]) ~= "table") then
        licenses[x][y] = {}
    end

    return licenses
end
