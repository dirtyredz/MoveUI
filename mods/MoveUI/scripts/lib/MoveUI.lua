local MoveUI = {}
require('mods.MoveUI.scripts.lib.serialize')

MoveUI.Serialize = serialize

function MoveUI.Enabled(player,rect,overide)
  local OverridePosition = false
  local AllowMoving = player:getValue('MoveUI') or false
  if AllowMoving then
    drawBorder(rect, ColorRGB(0.8,0.8,0.8))

    local mouse = Mouse()
    local Inside = false
    if mouse.position.x < rect.upper.x and mouse.position.x > rect.lower.x then
      if mouse.position.y < rect.upper.y and mouse.position.y > rect.lower.y then
        Inside = true
      end
    end

    if Inside and mouse:mousePressed(1) then
      return mouse.position, true
    elseif overide then
      return overide, false
    end
  end
  return OverridePosition, false
end

function MoveUI.CheckOverride(player,default,override,title)
  if override then return override end

  local OldOverride = Player():getValue(title..'_MUI') or 'return nil'

  OldOverride = loadstring(OldOverride)()
  if OldOverride then
    return vec2(OldOverride.x,OldOverride.y)
  end

  return default
end

function MoveUI.AssignPlayerOverride(player,title,position)
  local NewPosition = {}
  NewPosition.x = position.x
  NewPosition.y = position.y
  player:setValue(title..'_MUI', MoveUI.Serialize(NewPosition))
end

function MoveUI.NicerNumbers(n) -- http://lua-users.org/wiki/FormattingNumbers // credit http://richard.warburton.it
  local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
  return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

function MoveUI.TimeRemainingColor(seconds)
   local color

   -- hurry up! 3m or less -> RED
   if seconds <= 180 then
     color = ColorRGB(1,0,0)
   end
   -- start moving. 5m or less -> ORANGE
   if seconds > 180 and seconds <= 300 then
     color = ColorRGB(1,0.5,0)
   end
   -- keep an eye on that line. 10m or less -> YELLOW
   if seconds > 300 and seconds <= 600 then
     color = ColorRGB(1,1,0)
   end
   -- no worries. more than 10m -> WHITE
   if seconds > 600 then
     color = ColorRGB(1,1,1)
   end

   return color
end

function MoveUI.AllowClick(player,rect,func)
  local mouse = Mouse()
  local Inside = false
  local AllowMoving = player:getValue('MoveUI') or false
  if not AllowMoving then
    if mouse.position.x < rect.upper.x and mouse.position.x > rect.lower.x then
      if mouse.position.y < rect.upper.y and mouse.position.y > rect.lower.y then
        Inside = true
        drawRect(rect, ColorARGB(0.3,1,0.1,0.1))
      end
    end

    if Inside and mouse:mouseDown(1) then
      func()
    end
  end
end

return MoveUI
