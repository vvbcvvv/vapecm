shared.CustomSaveVape = 8542275097
if pcall(function() readfile("vape/CustomModules/8542275097.lua") end) then
	debugLoad(readfile("vape/CustomModules/8542275097.lua"), '8542275097.lua (8592115909.lua)')
else
	local publicrepo = vapeGithubRequest("CustomModules/8542275097.lua")
	if publicrepo then
		debugLoad(publicrepo, '8542275097.lua (8592115909.lua)')
	end
end
