local isfile = isfile 

if readfile == nil or writefile == nil then
    error("Your exploit won't handle vape.")
end

if isfile == nil then 
   isfile = function(file) return pcall(function() return readfile(file) end) and true or false end 
end


local function getcommit()
	local success, response = pcall(function()
		return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://api.github.com/repos/skiddinglua/NewVapeUnpatched4Roblox/commits"))
	end)
	local res = (success and response[1])
	if res and response.documentation_url == nil and res.commit then 
		local slash = res.commit.url:split("/")
		return slash[#slash]
	end
	return "main"
end

local function getVapeFile(file, nolawl)
	if not isfolder("vape") then 
		makefolder("vape")
	end
	local lawlwatermark = "-- lawl, credits to all of those who participated in fixing this project. https://discord.gg/Qx4cNHBvJq"
	if not isfile("vape/"..file) or readfile("vape/"..file):find(lawlwatermark) == nil and not nolawl then 
		local success, response = pcall(function()
			return game:HttpGet("https://raw.githubusercontent.com/skiddinglua/NewVapeUnpatched4Roblox/"..getcommit().."/"..file) 
		end)
		if success and response ~= "404: Not Found" then 
			response = (file:sub(#file - 4, #file) == ".lua" and lawlwatermark.."\n"..response or response)
			writefile("vape/"..file, response)
			return response
		else
			error("Vape Unpatched - Failed to download "..file.." | HTTP 404")
			return task.wait(9e9)
		end 
	end
	return isfile("vape/"..file) and readfile("vape/"..file) or task.wait(9e9)
end

loadstring(getVapeFile("MainScript.lua"))()
