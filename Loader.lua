local errorPopupShown = false
local setidentity = syn and syn.set_thread_identity or set_thread_identity or setidentity or setthreadidentity or function() end
local getidentity = syn and syn.get_thread_identity or get_thread_identity or getidentity or getthreadidentity or function() return 8 end
local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end
local delfile = delfile or function(file) writefile(file, "") end

if not isfolder("vape") then
	makefolder("vape")
end

local function displayErrorPopup(text, func)
	local oldidentity = getidentity()
	setidentity(8)
	local ErrorPrompt = getrenv().require(game:GetService("CoreGui").RobloxGui.Modules.ErrorPrompt)
	local prompt = ErrorPrompt.new("Default")
	prompt._hideErrorCode = true
	local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
	prompt:setErrorTitle("Vape")
	prompt:updateButtons({{
		Text = "OK",
		Callback = function() 
			prompt:_close() 
			if func then func() end
		end,
		Primary = true
	}}, 'Default')
	prompt:setParent(gui)
	prompt:_open(text)
	setidentity(oldidentity)
end

local vapeWatermark = [===[--[=[
	Current Hash: placeholderGithubCommitHashStringForVape
	newvape uED (user edition)
	Discord: https://discord.gg/Qx4cNHBvJq
]=]
]===]

local function readHash(data)
	local hash = data:sub(22, 61)
	if hash == 'placeholderGithubCommitHashStringForVape' then
		return false
	end
	if hash:gsub('%W+', '') == hash then
		return hash
	end
	return false
end

local function writeHash(data, hash)
	return vapeWatermark:gsub('placeholderGithubCommitHashStringForVape', hash) .. data
end

local commit = "main"
for i,v in pairs(game:HttpGet("https://github.com/skiddinglua/NewVapeUnpatched4Roblox"):split("\n")) do 
	if v:find("commit") and v:find("fragment") then 
		local str = v:split("/")[5]
		commit = str:sub(0, str:find('"') - 1)
		break
	end
end

if not commit then
	displayErrorPopup("Failed to connect to github, please try using a VPN.")
	error("Failed to connect to github, please try using a VPN.")
end

local function vapeGithubRequest(scripturl)
	local replace = isfile("vape/"..scripturl) and readHash(readfile("vape/"..scripturl)) ~= commit or not isfile("vape/"..scripturl)
	if replace then
		task.spawn(function()
			local textlabel = Instance.new("TextLabel")
			textlabel.Size = UDim2.new(1, 0, 0, 36)
			textlabel.Text = `{isfile("vape/"..scripturl) and 'Updating' or 'Downloading'} vape/{scripturl}`
			textlabel.BackgroundTransparency = 1
			textlabel.TextStrokeTransparency = 0
			textlabel.TextSize = 30
			textlabel.Font = Enum.Font.SourceSans
			textlabel.TextColor3 = Color3.new(1, 1, 1)
			textlabel.Position = UDim2.new(0, 0, 0, -36)
			textlabel.Parent = GuiLibrary.MainGui
			repeat task.wait() until isfile("vape/"..scripturl)
			textlabel:Destroy()
		end)
		local suc, res
		task.delay(15, function()
			if not res and not errorPopupShown then 
				errorPopupShown = true
				displayErrorPopup("The connection to github is taking a while, Please be patient.")
			end
		end)
		suc, res = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/skiddinglua/NewVapeUnpatched4Roblox/"..commit.."/"..scripturl, true) end)
		if not suc or res == "404: Not Found" then
			displayErrorPopup("Failed to connect to github : vape/"..scripturl.." : "..res)
			error(res)
		end
		if scripturl:match(".lua") then res = writeHash(res, commit) end
		writefile("vape/"..scripturl, res)
	end
	return readfile("vape/"..scripturl)
end

getgenv().vapeGithubRequest = vapeGithubRequest -- simplicity

return loadstring(vapeGithubRequest("MainScript.lua"))()