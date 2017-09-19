--MoveUI - Dirtyredz|David McClain
package.path = package.path .. ";mods/MoveUI/scripts/lib/?.lua" --Required
local MoveUI = require('MoveUI') --Required

-- namespace ExampleUI
ExampleUI = {}
--Its curcial that the namespace is unique to this file, I suggest keeping it the same name as the file name

local OverridePosition --Needed so, we can move the UI

--Its crucial the Title is unique to this file, a same title as another UI will break the storing of Moved UI's
local Title = 'ExampleUI' --Need so we can set overrided values to the player
local Icon = "data/textures/icons/chart.png" --Used by the buildTab function
local Description = "An exampleUI" --Used by the buildTab function

function ExampleUI.initialize() --Required
  --Register onPreRenderHud to the player so we can start displaying HUD's
  Player():registerCallback("onPreRenderHud", "onPreRenderHud")
end


function ExampleUI.buildTab(tabbedWindow) --Builds a tab inside of the main MoveUI interface
  --If you dont want thier to be a tab simply remove everything inside this function
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

function ExampleUI.onPreRenderHud() --Heres where we display the hud
  local rect = Rect(vec2(),vec2(160,25)) --default size of the rect (width,hight)
  local res = getResolution(); --So we can position it properly inside the clients screen

  --MoveUI - Dirtyredz|David McClain
  local DefaulPosition = vec2(res.x * 0.5, res.y * 0.5) --The default position (* 0.5 = middle of the screen)
  rect.position = MoveUI.CheckOverride(Player(),DefaulPosition,OverridePosition,Title) --Here we check if were getting an override( moving )

  OverridePosition, Moving = MoveUI.Enabled(Player(), rect, OverridePosition) --Here we enable movement of the UI
  if OverridePosition and not Moving then --Check if were done moving.
      invokeServerFunction('setNewPosition', OverridePosition) --Send the new X,Y to the server to store in the players Data
  end

  if MoveUI.AllowedMoving(Player()) then --If were moving
    drawTextRect(Title, rect, 0, 0,ColorRGB(1,1,1), 10, 0, 0, 0) --display the UI's title and return so we can clearly see each UI's Rect/Position
    return
  end
  --MoveUI - Dirtyredz|David McClain

  --Here begins what you want to display.
  --As long as you use the original (rect) you can build whatever you like here.
  drawTextRect('Example UI', rect,0, 0,ColorRGB(0,1,0), 15, 0, 0, 0)
  --[[
  Note: ColorRGB() uses floats ie
  ColorRGB(1,1,1) = White
  ColorRGB(0,0,0) = Black
  ColorRGB(0.5,0.5,0.5) = gray

  function drawTextRect(string text, Rect rect, int horizontalAlignment, int verticalAlignment, Color color, int size, int bold, int italic, int style)

  text = The text that is to be rendered
  rect = The rect that functions as boundaries for the text
  horizontalAlignment = -1 to position the text at the left, 0 to center it horizontally, +1 to position the text at the right
  verticalAlignment = -1 to position the text at the top, 0 to center it vertically, +1 to position the text at the bottom
  color = The color of the text, as an int
  size = The font size of the rendered text
  bold = Use 1 if the text should be bold, 0 otherwise
  itali =c Use 1 if the text should be italic, 0 otherwise
  style = The style of the text, 0 is default style, 1 is shadowed, 2 is outlined
  ]]
end

function ExampleUI.setNewPosition(Position) --Sends new x,y to the server
  MoveUI.AssignPlayerOverride(Player(),Title,Position)
end

return ExampleUI --We return here for when use by the main MoveUI interface.
