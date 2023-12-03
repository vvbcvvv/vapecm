local function getVapeFile(file, nolawl)
	if not isfolder("vape") then 
		makefolder("vape")
	end
	local lawlwatermark = "-- lawl, credits to all of those who participated in fixing this project. https://discord.gg/Qx4cNHBvJq"
    local extension = file:split(".")[#file:split(".")]
	if not isfile("vape/"..file) or readfile("vape/"..file):find(lawlwatermark) == nil and not nolawl then 
		local success, response = pcall(function()
			return game:HttpGet("https://raw.githubusercontent.com/skiddinglua/NewVapeUnpatched4Roblox/main/"..file) 
		end)
		if success and response ~= "404: Not Found" then 
			response = (extension == "lua" and lawlwatermark.."\n"..response or response)
			writefile("vape/"..file, response)
			return response
		else
			task.spawn(error, "Vape Unpatched - Failed to download "..file.." | HTTP 404")
			return task.wait(9e9)
		end 
	end
	return isfile("vape/"..file) and readfile("vape/"..file) or error("Vape Unpatched - Failed to read "..file)
end

return loadstring(getVapeFile("MainScript.lua"))()
