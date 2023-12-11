local EXECUTION_INFO = (...)
shared.CustomSaveVape = 292439477
if isfile("vape/CustomModules/292439477.lua") then
	VLib.loadFile(readfile("vape/CustomModules/292439477.lua"), '292439477.lua', EXECUTION_INFO)
else
	local publicrepo = VLib.requestFile("CustomModules/292439477.lua")
	if publicrepo then
		VLib.loadFile(publicrepo, '292439477.lua', EXECUTION_INFO)
	end
end
