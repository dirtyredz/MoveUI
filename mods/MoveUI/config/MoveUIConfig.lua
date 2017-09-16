local MoveUIConfig = {}
MoveUIConfig.version = "[1.1.0]"
MoveUIConfig.ModName = "[MoveUI]"

MoveUIConfig.HudList = {}

MoveUIConfig.HudList[1] = {}
MoveUIConfig.HudList[1].FileName = "ResourcesUI" --The filename of the UI, minus the extesion .lua
MoveUIConfig.HudList[1].ForceStartEnabled = false --Will enable the UI on player log in
MoveUIConfig.HudList[1].ForceRemove = false --Will remove this UI on player log in
MoveUIConfig.HudList[1].Restriction = function (player) return true end --A function that allows you restrict enabling UI's
--Here is an example of how you would restrict a UI to a players stored value
--MoveUIConfig.HudList[1].Restriction = function (player) return player:getValue('granted_benefits') or false end --A function that allows you restrict enabling UI's

MoveUIConfig.HudList[2] = {}
MoveUIConfig.HudList[2].FileName = "DistCoreDisplay" --The filename of the UI, minus the extesion .lua
MoveUIConfig.HudList[2].ForceStartEnabled = false --Will enable the UI on player log in
MoveUIConfig.HudList[2].ForceRemove = false --Will remove this UI on player log in
MoveUIConfig.HudList[2].Restriction = function (player) return true end --A function that allows you restrict enabling UI's

MoveUIConfig.HudList[3] = {}
MoveUIConfig.HudList[3].FileName = "CargoNotifier" --The filename of the UI, minus the extesion .lua
MoveUIConfig.HudList[3].ForceStartEnabled = true --Will enable the UI on player log in
MoveUIConfig.HudList[3].ForceRemove = false --Will remove this UI on player log in
MoveUIConfig.HudList[3].Restriction = function (player) return true end --A function that allows you restrict enabling UI's

MoveUIConfig.HudList[4] = {}
MoveUIConfig.HudList[4].FileName = "ScrapyardLicenses" --The filename of the UI, minus the extesion .lua
MoveUIConfig.HudList[4].ForceStartEnabled = true --Will enable the UI on player log in
MoveUIConfig.HudList[4].ForceRemove = false --Will remove this UI on player log in
MoveUIConfig.HudList[4].Restriction = function (player) return true end --A function that allows you restrict enabling UI's

return MoveUIConfig
