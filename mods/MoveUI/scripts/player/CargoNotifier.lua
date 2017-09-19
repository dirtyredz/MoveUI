--MoveUI - Dirtyredz|David McClain
package.path = package.path .. ";mods/MoveUI/scripts/lib/?.lua"
local MoveUI = require('MoveUI')

-- namespace CargoNotifier
CargoNotifier = {}

function CargoNotifier.initialize(Description)
  Player():registerCallback("onPreRenderHud", "onPreRenderHud")
end

--MoveUI - Dirtyredz|David McClain
local Title = 'CargoNotifier'
local Icon = "data/textures/icons/wooden-crate.png"
local Description = "Displays warning if you have Dangerous, Stolen, Suspicious, or Illegal Cargo"

function CargoNotifier.buildTab(tabbedWindow)
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
end

local OverridePosition

function CargoNotifier.onPreRenderHud()
  if onClient() then

    local PlayerShip = Player().craft
    if not PlayerShip then return end
    local Cargos = PlayerShip:getCargos()
    local SeenIllegal = false
    local SeenStolen = false
    local SeenDangerous = false
    local SeenSuspicious = false

    local rect = Rect(vec2(),vec2(170,150))
    local res = getResolution();
    --MoveUI - Dirtyredz|David McClain
    local DefaulPosition = vec2(res.x * 0.34,res.y * 0.07)
    rect.position = MoveUI.CheckOverride(Player(),DefaulPosition,OverridePosition,Title)

    OverridePosition, Moving = MoveUI.Enabled(Player(), rect, OverridePosition)
    if OverridePosition and not Moving then
        invokeServerFunction('setNewPosition', OverridePosition)
    end

    if MoveUI.AllowedMoving(Player()) then
      drawTextRect(Title, rect, 0, 0,ColorRGB(1,1,1), 10, 0, 0, 0)
      return
    end
    --MoveUI - Dirtyredz|David McClain

    local HSplit = UIHorizontalMultiSplitter(rect, 10, 10, 3)

    for TradingGood,index in pairs(Cargos) do
      if TradingGood.illegal and not SeenIllegal then
        drawTextRect('Illegal Cargo', HSplit:partition(0),0, 0,ColorRGB(255,0,0), 15, 0, 0, 0)
        drawBorder(HSplit:partition(0), ColorRGB(255,0,0))
        SeenIllegal = true
      end
      if TradingGood.stolen and not SeenStolen  then
        drawTextRect('Stolen Cargo', HSplit:partition(1),0, 0,ColorRGB(255,0,0), 15, 0, 0, 0)
        drawBorder(HSplit:partition(1), ColorRGB(255,0,0))
        SeenStolen = true
      end
      if TradingGood.dangerous and not SeenDangerous  then
        drawTextRect('Dangerous Cargo', HSplit:partition(2),0, 0,ColorRGB(255,0,0), 15, 0, 0, 0)
        drawBorder(HSplit:partition(2), ColorRGB(255,0,0))
        SeenDangerous = true
      end
      if TradingGood.suspicious and not SeenSuspicious  then
        drawTextRect('Suspicious Cargo', HSplit:partition(3),0, 0,ColorRGB(255,0,0), 15, 0, 0, 0)
        drawBorder(HSplit:partition(3), ColorRGB(255,0,0))
        SeenSuspicious = true
      end
    end
  end
end

--MoveUI - Dirtyredz|David McClain
function CargoNotifier.setNewPosition(Position)
  MoveUI.AssignPlayerOverride(Player(),Title,Position)
end
--MoveUI - Dirtyredz|David McClain
return CargoNotifier
