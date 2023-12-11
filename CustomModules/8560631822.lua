local EXECUTION_INFO = (...)
shared.CustomSaveVape = 6872274481
if pcall(function() readfile("vape/CustomModules/6872274481.lua") end) then
	VLib.loadFile(readfile("vape/CustomModules/6872274481.lua"), '6872274481.lua', EXECUTION_INFO)
else
	local publicrepo = VLib.requestFile("CustomModules/6872274481.lua")
	if publicrepo then
		VLib.loadFile(publicrepo, '6872274481.lua', EXECUTION_INFO)
	end
end
