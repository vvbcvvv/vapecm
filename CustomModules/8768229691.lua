local function vapeGithubRequest(scripturl)
	if not isfile("vape/"..scripturl) then
		local suc, res = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/skiddinglua/NewVapeUnpatched4Roblox/main/"..scripturl, true) end)
		if not suc or res == "404: Not Found" then return nil end
		if scripturl:find(".lua") then res = "--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.\n"..res end
		writefile("vape/"..scripturl, res)
	end
	return readfile("vape/"..scripturl)
end

shared.CustomSaveVape = 8542275097
if pcall(function() readfile("vape/CustomModules/8542275097.lua") end) then
	debugLoad(readfile("vape/CustomModules/8542275097.lua"))
else
	local publicrepo = vapeGithubRequest("CustomModules/8542275097.lua")
	if publicrepo then
		debugLoad(publicrepo)
	end
end
