local isfile = isfile 

if readfile == nil or writefile == nil then
    error("Your exploit won't handle vape.")
end

if isfile == nil then 
   isfile = function(file) return pcall(function() return readfile(file) end) and true or false end 
end

local lawlwatermark = "-- lawl, credits to all of those who participated in fixing this project. https://discord.gg/Qx4cNHBvJq"

local function getVapeFile(file)
    if not isfolder("vape") then 
        makefolder("vape")
    end
    if not isfile("vape/"..file) then 
        local success, response = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/skiddinglua/NewVapeUnpatched4Roblox/main/"..file) 
        end)
        if success and response ~= "404: Not Found" then 
            response = (file:sub(#file - 4, #file) == ".lua" and lawlwatermark.."\n"..response or response)
            writefile("vape/"..file, response)
            return response
        else
            return error("Vape Unpatched - Failed to download "..file.." | HTTP 404")
        end 
    end
    return isfile("vape/"..file) and readfile("vape/"..file) or task.wait(9e9)
end

loadstring(getVapeFile("MainScript.lua"))()
