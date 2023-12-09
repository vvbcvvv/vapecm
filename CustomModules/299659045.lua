local EXECUTION_LEVEL = (...)
shared.CustomSaveVape = 292439477
if isfile("vape/CustomModules/292439477.lua") then
	debugLoad(readfile("vape/CustomModules/292439477.lua"), '292439477.lua (299659045.lua)', EXECUTION_LEVEL)
else
	local publicrepo = vapeGithubRequest("CustomModules/292439477.lua")
	if publicrepo then
		debugLoad(publicrepo, '292439477.lua (299659045.lua)', EXECUTION_LEVEL)
	end
end
