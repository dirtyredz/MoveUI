local MoveUI = {}

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

  local OldOverrideX = player:getValue(title..'_MUIX')
  local OldOverrideY = player:getValue(title..'_MUIY')

  if OldOverrideX and OldOverrideY then
    return vec2(OldOverrideX,OldOverrideY)
  end

  return default
end

function MoveUI.AssignPlayerOverride(player,title,position)
  player:setValue(title..'_MUIX',position.x)
  player:setValue(title..'_MUIY',position.y)
end

return MoveUI
