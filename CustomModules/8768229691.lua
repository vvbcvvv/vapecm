shared.CustomSaveVape = 8542275097
if pcall(function() readfile("vape/CustomModules/8542275097.lua") end) then
	debugLoad(readfile("vape/CustomModules/8542275097.lua"), '8542275097.lua (8768229691.lua)')
else
	local publicrepo = vapeGithubRequest("CustomModules/8542275097.lua")
	if publicrepo then
		debugLoad(publicrepo, '8542275097.lua (8768229691.lua)')
	end
end
