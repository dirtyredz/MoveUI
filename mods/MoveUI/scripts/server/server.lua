local MoveUI = {}

function MoveUI.onPlayerLogIn(playerIndex)
  -- Adding script to player when they log in
  local player = Player(playerIndex)
  player:addScriptOnce("mods/MoveUI/scripts/player/MoveUI.lua")
end

return MoveUI
