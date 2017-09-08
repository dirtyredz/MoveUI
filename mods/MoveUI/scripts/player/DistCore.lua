function initialize()
  local lx, ly = Sector():getCoordinates()
  local distanceFromCenter =  math.floor(length(vec2(lx,ly)))
  Player():sendChatMessage("Server", 0, "Distance to core is (%i).", distanceFromCenter)

  terminate()
end
