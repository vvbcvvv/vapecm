local function getVapeFile(file, nolawl)
    if not isfolder("vape") then 
        makefolder("vape")
    end
    local lawlwatermark = "-- lawl, credits to all of those who participated in fixing this project. https://discord.gg/Qx4cNHBvJq"
    if not isfile("vape/"..file) or readfile("vape/"..file):find(lawlwatermark) == nil and not nolawl or nolawl and readfile("vape/"..file):find(lawlwatermark) == nil then 
        local success, response = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/skiddinglua/NewVapeUnpatched4Roblox/main/"..file, true) 
        end)
        if success and response ~= "404: Not Found" then 
            response = (file:split(".")[#file:split(".")] == "lua" and lawlwatermark.."\n"..response or response)
            writefile("vape/"..file, response)
            return response
        else
            error("Vape Unpatched - Failed to download "..file.." | HTTP 404")
            return task.wait(9e9)
        end 
    end
    return isfile("vape/"..file) and readfile("vape/"..file) or task.wait(9e9)
end

return loadstring(getVapeFile("MainScript.lua"))()
