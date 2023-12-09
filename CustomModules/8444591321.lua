shared.CustomSaveVape = 6872274481
if pcall(function() readfile("vape/CustomModules/6872274481.lua") end) then
	debugLoad(readfile("vape/CustomModules/6872274481.lua"), '6872274481.lua (84444591321.lua)')
else
	local publicrepo = vapeGithubRequest("CustomModules/6872274481.lua")
	if publicrepo then
		debugLoad(publicrepo, '6872274481.lua (84444591321.lua)')
	end
end
