local MoveUIConfig = {}
MoveUIConfig.Author = "Dirtyredz"
MoveUIConfig.ModName = "[MoveUI]"

MoveUIConfig.version = {
    major=1, minor=4, patch = 0,
    string = function()
        return  Config.version.major .. '.' ..
                Config.version.minor .. '.' ..
                Config.version.patch
    end
}

function MoveUIConfig.print(...)
  local args = table.pack(...)
  table.insert(args,1,"[" .. MoveUIConfig.ModName .. "][" .. MoveUIConfig.version.string() .. "]")
  print(table.unpack(args))
end

MoveUIConfig.HudList = {}

function MoveUIConfig.AddUI(FileName, ForceStartEnabled, ForceRemove, Restriction)
    if FileName ~= nil then
        table.insert(MoveUIConfig.HudList, {
            FileName = FileName,
            ForceStartEnabled = ForceStartEnabled or false,
            ForceRemove = ForceRemove or false,
            Restriction = Restriction or function (player) return true end
        })
    end

end

MoveUIConfig.AddUI("ResourcesUI", true)
MoveUIConfig.AddUI("DistCore", true)
MoveUIConfig.AddUI("CargoNotifier", true)
MoveUIConfig.AddUI("ScrapyardLicenses", false)
MoveUIConfig.AddUI("ObjectDetector", false)
MoveUIConfig.AddUI("PVPSector", false)
MoveUIConfig.AddUI("FactionNotifier", false)
--MoveUIConfig.AddUI("TargetingData", false)

return MoveUIConfig
