local EXECUTION_INFO = (...)
shared.CustomSaveVape = 8542275097
if pcall(function() readfile("vape/CustomModules/8542275097.lua") end) then
	debugLoad(readfile("vape/CustomModules/8542275097.lua"), '8542275097.lua', EXECUTION_INFO)
else
	local publicrepo = vapeGithubRequest("CustomModules/8542275097.lua")
	if publicrepo then
		debugLoad(publicrepo, '8542275097.lua', EXECUTION_INFO)
	end
end
