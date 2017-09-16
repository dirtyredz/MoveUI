package.path = package.path .. ";data/scripts/lib/?.lua"
require ("galaxy")
require ("utility")
require ("faction")
require ("randomext")
require("stringutility")
local Dialog = require("dialogutility")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace Scrapyard
Scrapyard = {}

-- server
local licenses = {}
local illegalActions = {}
local newsBroadcastCounter = 0


-- client
local tabbedWindow = 0
local planDisplayer = 0
local sellButton = 0
local sellWarningLabel = 0
local priceLabel1 = 0
local priceLabel2 = 0
local priceLabel3 = 0
local priceLabel4 = 0
local licenseDuration = 0
local uiMoneyValue = 0
local visible = false

-- if this function returns false, the script will not be listed in the interaction window on the client,
-- even though its UI may be registered
function Scrapyard.interactionPossible(playerIndex, option)
    return CheckFactionInteraction(playerIndex, -10000)
end

function Scrapyard.restore(data)
    -- clear earlier data
    licenses = data.licenses
    illegalActions = data.illegalActions
end

function Scrapyard.secure()
    -- save licenses
    local data = {}
    data.licenses = licenses
    data.illegalActions = illegalActions

    return data
end

-- this function gets called on creation of the entity the script is attached to, on client and server
function Scrapyard.initialize()

    if onServer() then
        Sector():registerCallback("onHullHit", "onHullHit")

        local station = Entity()
        if station.title == "" then
            station.title = "Scrapyard"%_t
        end

    end

    if onClient() and EntityIcon().icon == "" then
        EntityIcon().icon = "data/textures/icons/pixel/scrapyard_fat.png"
        InteractionText().text = Dialog.generateStationInteractionText(Entity(), random())
    end

end

-- this function gets called on creation of the entity the script is attached to, on client only
-- AFTER initialize above
-- create all required UI elements for the client side
function Scrapyard.initUI()

    local res = getResolution()
    local size = vec2(700, 650)

    local menu = ScriptUI()
    local mainWindow = menu:createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5))
    menu:registerWindow(mainWindow, "Scrapyard"%_t)
    mainWindow.caption = "Scrapyard"%_t
    mainWindow.showCloseButton = 1
    mainWindow.moveable = 1

    -- create a tabbed window inside the main window
    tabbedWindow = mainWindow:createTabbedWindow(Rect(vec2(10, 10), size - 10))

    -- create a "Sell" tab inside the tabbed window
    local sellTab = tabbedWindow:createTab("Sell Ship"%_t, "", "Sell your ship to the scrapyard"%_t)
    size = sellTab.size

    planDisplayer = sellTab:createPlanDisplayer(Rect(0, 0, size.x - 20, size.y - 60))
    planDisplayer.showStats = 0

    sellButton = sellTab:createButton(Rect(0, size.y - 40, 150, size.y), "Sell Ship"%_t, "onSellButtonPressed")
    sellWarningLabel = sellTab:createLabel(vec2(200, size.y - 30), "Warning! You will not get refunds for crews or turrets!"%_t, 15)
    sellWarningLabel.color = ColorRGB(1, 1, 0)

    -- create a second tab
    local salvageTab = tabbedWindow:createTab("Salvaging /*UI Tab title*/"%_t, "", "Buy a salvaging license"%_t)
    size = salvageTab.size -- not really required, all tabs have the same size

    local textField = salvageTab:createTextField(Rect(0, 0, size.x, 50), "You can buy a temporary salvaging license here. This license makes it legal to damage or mine wreckages in this sector."%_t)
    textField.padding = 7

    salvageTab:createButton(Rect(size.x - 210, 80, 200 + size.x - 210, 40 + 80), "Buy License"%_t, "onBuyLicenseButton1Pressed")
    salvageTab:createButton(Rect(size.x - 210, 130, 200 + size.x - 210, 40 + 130), "Buy License"%_t, "onBuyLicenseButton2Pressed")
    salvageTab:createButton(Rect(size.x - 210, 180, 200 + size.x - 210, 40 + 180), "Buy License"%_t, "onBuyLicenseButton3Pressed")
    salvageTab:createButton(Rect(size.x - 210, 230, 200 + size.x - 210, 40 + 230), "Buy License"%_t, "onBuyLicenseButton4Pressed")

    local fontSize = 18
    salvageTab:createLabel(vec2(15, 85), "5", fontSize)
    salvageTab:createLabel(vec2(15, 135), "15", fontSize)
    salvageTab:createLabel(vec2(15, 185), "30", fontSize)
    salvageTab:createLabel(vec2(15, 235), "60", fontSize)

    salvageTab:createLabel(vec2(60, 85), "Minutes"%_t, fontSize)
    salvageTab:createLabel(vec2(60, 135), "Minutes"%_t, fontSize)
    salvageTab:createLabel(vec2(60, 185), "Minutes"%_t, fontSize)
    salvageTab:createLabel(vec2(60, 235), "Minutes"%_t, fontSize)

    priceLabel1 = salvageTab:createLabel(vec2(200, 85),  "", fontSize)
    priceLabel2 = salvageTab:createLabel(vec2(200, 135), "", fontSize)
    priceLabel3 = salvageTab:createLabel(vec2(200, 185), "", fontSize)
    priceLabel4 = salvageTab:createLabel(vec2(200, 235), "", fontSize)

    timeLabel = salvageTab:createLabel(vec2(10, 310), "", fontSize)

end

-- this function gets called whenever the ui window gets rendered, AFTER the window was rendered (client only)
function Scrapyard.renderUI()

    if tabbedWindow:getActiveTab().name == "Sell Ship"%_t then
        renderPrices(planDisplayer.lower + 20, "Ship Value:"%_t, uiMoneyValue, nil)
    end
end

-- this function gets called every time the window is shown on the client, ie. when a player presses F and if interactionPossible() returned 1
function Scrapyard.onShowWindow()
    local ship = Player().craft

    -- get the plan of the player's ship
    local plan = ship:getPlan()
    planDisplayer.plan = plan

    if ship.isDrone then
        sellButton.active = false
        sellWarningLabel:hide()
    else
        sellButton.active = true
        sellWarningLabel:show()
    end

    priceLabel1.caption = "$${money}"%_t % {money = Scrapyard.getLicensePrice(Player(), 5)}
    priceLabel2.caption = "$${money}"%_t % {money = Scrapyard.getLicensePrice(Player(), 15)}
    priceLabel3.caption = "$${money}"%_t % {money = Scrapyard.getLicensePrice(Player(), 30)}
    priceLabel4.caption = "$${money}"%_t % {money = Scrapyard.getLicensePrice(Player(), 60)}

    uiMoneyValue = Scrapyard.getShipValue(plan)

    Scrapyard.getLicenseDuration()

    visible = true
end

-- this function gets called every time the window is closed on the client
function Scrapyard.onCloseWindow()
    local station = Entity()
    displayChatMessage("Please, do come again."%_t, station.title, 0)

    visible = false
end

function Scrapyard.onSellButtonPressed()
    invokeServerFunction("sellCraft")
end

function Scrapyard.onBuyLicenseButton1Pressed()
    invokeServerFunction("buyLicense", 60 * 5)
end

function Scrapyard.onBuyLicenseButton2Pressed()
    invokeServerFunction("buyLicense", 60 * 15)
end

function Scrapyard.onBuyLicenseButton3Pressed()
    invokeServerFunction("buyLicense", 60 * 30)
end

function Scrapyard.onBuyLicenseButton4Pressed()
    invokeServerFunction("buyLicense", 60 * 60)
end


-- this function gets called once each frame, on client only
function Scrapyard.getUpdateInterval()
    return 1
end

function Scrapyard.updateClient(timeStep)
    licenseDuration = licenseDuration - timeStep

    if visible then
        if licenseDuration > 0 then
            timeLabel.caption = "Your license will expire in ${time}."%_t % {time = createReadableTimeString(licenseDuration)}
        else
            timeLabel.caption = "You don't have a valid license."%_t
        end
    end
end

function Scrapyard.transactionComplete()
    ScriptUI():stopInteraction()
end

function Scrapyard.getLicenseDuration()
    invokeServerFunction("sendLicenseDuration")
end

function Scrapyard.setLicenseDuration(duration)
    licenseDuration = duration
end

-- this function gets called once each frame, on client and server
--function update(timeStep)
--
--end

function Scrapyard.getLicensePrice(orderingFaction, minutes)

    local price = minutes * 150 * (1.0 + GetFee(Faction(), orderingFaction)) * Balancing_GetSectorRichnessFactor(Sector():getCoordinates())

    local discountFactor = 1.0
    if minutes > 5 then discountFactor = 0.93 end
    if minutes > 15 then discountFactor = 0.86 end
    if minutes > 40 then discountFactor = 0.80 end

    return round(price * discountFactor);

end

-- this function gets called once each frame, on server only
function Scrapyard.updateServer(timeStep)

    local station = Entity();

    newsBroadcastCounter = newsBroadcastCounter + timeStep
    if newsBroadcastCounter > 60 then
        Sector():broadcastChatMessage(station.title, 0, "Get a salvaging license now and try your luck with the wreckages!"%_t)
        newsBroadcastCounter = 0
    end

    -- counter for update, this is only executed once per second to save performance.
    for playerIndex, actions in pairs(illegalActions) do

        actions = actions - 1

        if actions <= 0 then
            illegalActions[playerIndex] = nil
        else
            illegalActions[playerIndex] = actions
        end
    end

    for playerIndex, time in pairs(licenses) do

        time = time - timeStep

        -- warn player if his time is running out
        if time + 1 > 10 and time <= 10 then
            Player(playerIndex):sendChatMessage(station.title, 0, "Your salvaging license will run out in 10 seconds."%_t);
            Player(playerIndex):sendChatMessage(station.title, 2, "Your salvaging license will run out in 10 seconds."%_t);
        end

        if time + 1 > 20 and time <= 20 then
            Player(playerIndex):sendChatMessage(station.title, 0, "Your salvaging license will run out in 20 seconds."%_t);
            Player(playerIndex):sendChatMessage(station.title, 2, "Your salvaging license will run out in 20 seconds."%_t);
        end

        if time + 1 > 30 and time <= 30 then
            Player(playerIndex):sendChatMessage(station.title, 0, "Your salvaging license will run out in 30 seconds. Renew it and save yourself some trouble!"%_t);
        end

        if time + 1 > 60 and time <= 60 then
            Player(playerIndex):sendChatMessage(station.title, 0, "Your salvaging license will run out in 60 seconds. Renew it NOW and save yourself some trouble!"%_t);
        end

        if time + 1 > 120 and time <= 120 then
            Player(playerIndex):sendChatMessage(station.title, 0, "Your salvaging license will run out in 2 minutes. Renew it immediately and save yourself some trouble!"%_t);
        end

        if time < 0 then
            licenses[playerIndex] = nil

            Player(playerIndex):sendChatMessage(station.title, 0, "Your salvaging license expired. You may no longer salvage in this area."%_t);
        else
            licenses[playerIndex] = time
        end
    end

end

function Scrapyard.sellCraft()
    local buyer, ship, player = getInteractingFaction(callingPlayer, AlliancePrivilege.ModifyCrafts, AlliancePrivilege.SpendResources)
    if not buyer then return end

    -- don't allow selling drones, would be an infinite income source
    if ship.isDrone then return end

    -- Create Wreckage
    local position = ship.position
    local plan = ship:getPlan();

    -- remove the old craft
    Sector():deleteEntity(ship)

    -- create a wreckage in its place
    local wreckageIndex = Sector():createWreckage(plan, position)

    local moneyValue = Scrapyard.getShipValue(plan)
    buyer:receive(moneyValue)

    invokeClientFunction(player, "transactionComplete")
end

function Scrapyard.getShipValue(plan)
    local sum = plan:getMoneyValue()
    local resourceValue = {plan:getResourceValue()}

    for i, v in pairs (resourceValue) do
        sum = sum + Material(i - 1).costFactor * v * 10;
    end

    -- players only get money, and not even the full value.
    -- This is to avoid exploiting the scrapyard functionality by buying and then selling ships
    return sum * 0.75
end

function Scrapyard.buyLicense(duration)

    local buyer, ship, player = getInteractingFaction(callingPlayer, AlliancePrivilege.SpendResources)
    if not buyer then return end

    local price = Scrapyard.getLicensePrice(buyer, duration / 60) -- minutes!

    local station = Entity()

    local canPay, msg, args = buyer:canPay(price)
    if not canPay then
        player:sendChatMessage(station.title, 1, msg, unpack(args));
        return;
    end

    buyer:pay(price)

    -- register player's license
    licenses[buyer.index] = duration

    -- send a message as response
    local minutes = licenses[buyer.index] / 60
    player:sendChatMessage(station.title, 0, "You bought a %s minutes salvaging license."%_t, minutes);
    player:sendChatMessage(station.title, 0, "%s cannot be held reliable for any damage to ships or deaths caused by salvaging."%_t, Faction().name);

    Scrapyard.sendLicenseDuration()
end

function Scrapyard.sendLicenseDuration()
    local duration = licenses[callingPlayer]

    if duration ~= nil then
        invokeClientFunction(Player(callingPlayer), "setLicenseDuration", duration)
    end
end

function Scrapyard.onHullHit(objectIndex, block, shootingCraftIndex, damage, position)
    local object = Entity(objectIndex)
    if object and object.isWreckage then
        local shooter = Entity(shootingCraftIndex)
        if shooter then
            local faction = Faction(shooter.factionIndex)
            if not faction.isAIFaction and licenses[faction.index] == nil then
                Scrapyard.unallowedDamaging(shooter, faction, damage)
            end
        end
    end
end

function Scrapyard.unallowedDamaging(shooter, faction, damage)

    local pilots = {}

    if faction.isAlliance then
        for _, playerIndex in pairs({shooter:getPilotIndices()}) do
            local player = Player(playerIndex)

            if player then
                table.insert(pilots, player)
            end
        end

    elseif faction.isPlayer then
        table.insert(pilots, Player(faction.index))
    end

    local station = Entity()

    local actions = illegalActions[faction.index]
    if actions == nil then
        actions = 0
    end

    newActions = actions + damage

    for _, player in pairs(pilots) do
        if actions < 10 and newActions >= 10 then
            player:sendChatMessage(station.title, 0, "Salvaging or damaging wreckages in this sector is illegal. Please buy a salvaging license."%_t);
            player:sendChatMessage(station.title, 2, "You need a salvaging license for this sector."%_t);
        end

        if actions < 200 and newActions >= 200 then
            player:sendChatMessage(station.title, 0, "Salvaging wreckages in this sector is forbidden. Please buy a salvaging license."%_t);
            player:sendChatMessage(station.title, 2, "You need a salvaging license for this sector."%_t);
        end

        if actions < 500 and newActions >= 500 then
            player:sendChatMessage(station.title, 0, "Wreckages in this sector are the property of %s. Please buy a salvaging license."%_t, Faction().name);
            player:sendChatMessage(station.title, 2, "You need a salvaging license for this sector."%_t);
        end

        if actions < 1000 and newActions >= 1000 then
            player:sendChatMessage(station.title, 0, "Illegal salvaging will be punished by destruction. Buy a salvaging license or there will be consequences."%_t);
            player:sendChatMessage(station.title, 2, "You need a salvaging license for this sector."%_t);
        end

        if actions < 1500 and newActions >= 1500 then
            player:sendChatMessage(station.title, 0, "This is your last warning. If you do not stop salvaging without a license, you will be destroyed."%_t);
            player:sendChatMessage(station.title, 2, "You need a salvaging license for this sector."%_t);
        end

        if actions < 2000 and newActions >= 2000 then
            player:sendChatMessage(station.title, 0, "You have been warned. You will be considered an enemy of %s if you do not stop your illegal activities."%_t, Faction().name);
            player:sendChatMessage(station.title, 2, "You need a salvaging license for this sector."%_t);
        end
    end

    if newActions > 5 then
        Galaxy():changeFactionRelations(Faction(), faction, -newActions / 100)
    end

    illegalActions[faction.index] = newActions

end

if not pcall(require, 'mods.MoveUI.scripts.entity.merchants.scrapyard') then print('Mod: MoveUI, failed to extend scrapyard.lua!') end
