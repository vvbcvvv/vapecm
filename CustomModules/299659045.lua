local EXECUTION_INFO = (...)
shared.CustomSaveVape = 292439477
if isfile("vape/CustomModules/292439477.lua") then
	debugLoad(readfile("vape/CustomModules/292439477.lua"), '292439477.lua', EXECUTION_INFO)
else
	local publicrepo = vapeGithubRequest("CustomModules/292439477.lua")
	if publicrepo then
		debugLoad(publicrepo, '292439477.lua', EXECUTION_INFO)
	end
end
