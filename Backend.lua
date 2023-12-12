local playersService = game:GetService("Players")
local lplr = playersService.LocalPlayer
local coreGui = game:GetService("CoreGui")
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
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

local VLib = {
	assetCache = {},
	stageNames = {},
	stages = 0,
	currentStage = 1,
	steps = 0,
	currentStep = 0
}

local function randomString()
	local randomlength = math.random(10,100)
	local array = {}

	for i = 1, randomlength do
		array[i] = string.char(math.random(32, 126))
	end

	return table.concat(array)
end

local VapeLoader = Instance.new("ScreenGui")
VapeLoader.Name = randomString()
VapeLoader.DisplayOrder = 999
VapeLoader.ZIndexBehavior = Enum.ZIndexBehavior.Global
VapeLoader.OnTopOfCoreBlur = true
VapeLoader.ResetOnSpawn = false
VapeLoader.Parent = lplr.PlayerGui
VLib.MainGui = VapeLoader

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = VapeLoader
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.050
MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.15, 0, 0.15, 0)
MainFrame.Size = UDim2.new(0.7, 0, 0.7, 0)
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = MainFrame
local Title1 = Instance.new("ImageLabel")
Title1.Name = "Title1"
Title1.Parent = MainFrame
Title1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title1.BackgroundTransparency = 1.000
Title1.BorderColor3 = Color3.fromRGB(0, 0, 0)
Title1.BorderSizePixel = 0
Title1.Position = UDim2.new(0.259342611, 0, 0.209071234, 0)
Title1.Size = UDim2.new(0, 220, 0, 162)
Title1.Image = "rbxassetid://13350872035" -- VLib.downloadAsset('vape/assets/VapeLogo3.png')
Title1.ScaleType = Enum.ScaleType.Fit
local Title2 = Instance.new("ImageLabel")
Title2.Name = "Title2"
Title2.Parent = MainFrame
Title2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title2.BackgroundTransparency = 1.000
Title2.BorderColor3 = Color3.fromRGB(0, 0, 0)
Title2.BorderSizePixel = 0
Title2.Position = UDim2.new(0.599222243, 0, 0.336309165, 0)
Title2.Size = UDim2.new(0, 89, 0, 58)
Title2.Image = "rbxassetid://13350877564" -- VLib.downloadAsset('vape/assets/VapeLogo4.png')
Title2.ImageColor3 = Color3.fromRGB(80, 203, 160)
Title2.ScaleType = Enum.ScaleType.Fit

local LoadingBar = Instance.new("Frame")
LoadingBar.Name = "LoadingBar"
LoadingBar.Parent = MainFrame
LoadingBar.BackgroundColor3 = Color3.fromRGB(68, 68, 68)
LoadingBar.BackgroundTransparency = 0.250
LoadingBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
LoadingBar.BorderSizePixel = 0
LoadingBar.Position = UDim2.new(0.312999994, 0, 0.512000024, 0)
LoadingBar.Size = UDim2.new(0, 250, 0, 8)
local UICorner_2 = Instance.new("UICorner")
UICorner_2.CornerRadius = UDim.new(0, 6)
UICorner_2.Parent = LoadingBar
local LoadingBar_2 = Instance.new("Frame")
LoadingBar_2.Name = "LoadingBar"
LoadingBar_2.Parent = LoadingBar
LoadingBar_2.BackgroundColor3 = Color3.fromRGB(238, 238, 238)
LoadingBar_2.BackgroundTransparency = 0.200
LoadingBar_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
LoadingBar_2.BorderSizePixel = 0
LoadingBar_2.Size = UDim2.new(0, 0, 1, 0)

local UICorner_3 = Instance.new("UICorner")
UICorner_3.CornerRadius = UDim.new(0, 6)
UICorner_3.Parent = LoadingBar_2
local LoadingInfo = Instance.new("TextLabel")
LoadingInfo.Name = "LoadingInfo"
LoadingInfo.Parent = MainFrame
LoadingInfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LoadingInfo.BackgroundTransparency = 1.000
LoadingInfo.BorderColor3 = Color3.fromRGB(0, 0, 0)
LoadingInfo.BorderSizePixel = 0
LoadingInfo.Position = UDim2.new(0.31400007, 0, 0.670000017, -30)
LoadingInfo.Size = UDim2.new(0.424267262, 0, 0.108225107, 30)
LoadingInfo.Font = Enum.Font.Arial
LoadingInfo.Text = "Your vape is slow dummy."
LoadingInfo.TextColor3 = Color3.fromRGB(238, 238, 238)
LoadingInfo.TextSize = 15.000
LoadingInfo.TextTransparency = 0.200
LoadingInfo.TextXAlignment = Enum.TextXAlignment.Left
LoadingInfo.TextYAlignment = Enum.TextYAlignment.Top
local LoadingInfo2 = Instance.new("TextLabel")
LoadingInfo2.Name = "LoadingInfo2"
LoadingInfo2.Parent = MainFrame
LoadingInfo2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LoadingInfo2.BackgroundTransparency = 1.000
LoadingInfo2.BorderColor3 = Color3.fromRGB(0, 0, 0)
LoadingInfo2.BorderSizePixel = 0
LoadingInfo2.Position = UDim2.new(0.31400007, 0, 0.670000017, -30)
LoadingInfo2.Size = UDim2.new(0.424267262, 0, 0.108225107, 30)
LoadingInfo2.Font = Enum.Font.Arial
LoadingInfo2.Text = "Your vape is slow dummy."
LoadingInfo2.TextColor3 = Color3.fromRGB(238, 238, 238)
LoadingInfo2.TextSize = 15.000
LoadingInfo2.TextTransparency = 0.200
LoadingInfo2.TextXAlignment = Enum.TextXAlignment.Left
LoadingInfo2.TextYAlignment = Enum.TextYAlignment.Top
local StageInfo = Instance.new("TextLabel")
StageInfo.Name = "StageInfo"
StageInfo.Parent = MainFrame
StageInfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
StageInfo.BackgroundTransparency = 1.000
StageInfo.BorderColor3 = Color3.fromRGB(0, 0, 0)
StageInfo.BorderSizePixel = 0
StageInfo.Position = UDim2.new(0.313686877, 0, 0.611056268, -26)
StageInfo.Size = UDim2.new(0.424580514, 0, -0.0419999994, 30)
StageInfo.Font = Enum.Font.Arial
StageInfo.Text = "Stage 8/11"
StageInfo.TextColor3 = Color3.fromRGB(238, 238, 238)
StageInfo.TextSize = 15.000
StageInfo.TextTransparency = 0.200
StageInfo.TextXAlignment = Enum.TextXAlignment.Left
StageInfo.TextYAlignment = Enum.TextYAlignment.Top
local StageInfo2 = Instance.new("TextLabel")
StageInfo2.Name = "StageInfo2"
StageInfo2.Parent = MainFrame
StageInfo2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
StageInfo2.BackgroundTransparency = 1.000
StageInfo2.BorderColor3 = Color3.fromRGB(0, 0, 0)
StageInfo2.BorderSizePixel = 0
StageInfo2.Position = UDim2.new(0.313686877, 0, 0.611056268, -26)
StageInfo2.Size = UDim2.new(0.615999997, 0, -0.0419999994, 30)
StageInfo2.Font = Enum.Font.Arial
StageInfo2.Text = "Stage 8/11"
StageInfo2.TextColor3 = Color3.fromRGB(238, 238, 238)
StageInfo2.TextSize = 15.000
StageInfo2.TextTransparency = 0.200
StageInfo2.TextXAlignment = Enum.TextXAlignment.Left
StageInfo2.TextYAlignment = Enum.TextYAlignment.Top

local currentTween
local function updateBar(progress)
    pcall(function() currentTween:Cancel() end)
	currentTween = tweenService:Create(LoadingBar_2, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(progress, 0, 1, 0)}):Play()
end

function VLib.updateProgress()
	local normal = (VLib.currentStage - 1) / VLib.stages
	local current = 0
	for i, v in next, VLib.steps do
		if v.done then
			current += (1 / VLib.stages) / #VLib.steps
		end
	end
	updateBar(normal + current)
	if VLib.currentStage == VLib.stages then
	end
end

function VLib.addStage(stage)
	VLib.stages += 1
	table.insert(VLib.stageNames, stage)
	StageInfo.Text = `Stage{VLib.currentStage}/{VLib.stages}`
	StageInfo2.Text = `Stage{VLib.currentStage}/{VLib.stages}`
	VLib.updateProgress()
end

function VLib.nextStage()
	VLib.currentStage += 1
	StageInfo.Text = `Stage{VLib.currentStage}/{VLib.stages}`
	StageInfo2.Text = `Stage{VLib.currentStage}/{VLib.stages}`
	VLib.updateInfo(VLib.stageNames[VLib.currentStage] or 'Finalizing')
	VLib.currentStep = 0
	VLib.steps = 0
	VLib.updateProgress()
end

function VLib.updateInfo(text)
	LoadingInfo.Text = text
	LoadingInfo2.Text = text
end

function VLib.newStep(tag)
	VLib.steps += 1
	VLib.updateProgress()
end

function VLib.nextStep()
	VLib.currentStep += 1
	VLib.updateProgress()
end

function VLib.displayErrorPopup(text, func)
	local oldidentity = getidentity()
	setidentity(8)
	local ErrorPrompt = getrenv().require(coreGui.RobloxGui.Modules.ErrorPrompt)
	local prompt = ErrorPrompt.new("Default")
	prompt._hideErrorCode = true
	local gui = Instance.new("ScreenGui", coreGui)
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

-- if not shared.isScrxpted then VLib.displayErrorPopup("scrxpted is fixing newvape, please shut the fuck up <3") return end

VLib.addStage('Fetching lastest commit') -- commit fetching
-- VLib.addStage() -- authentication
VLib.addStage('Loaded gui library') -- gui library loading
VLib.addStage('Loaded internal functions') -- main script loading
-- VLib.addStage() -- hooking
VLib.addStage('Loading game script') -- game script loading
VLib.addStage('Loading profile') -- profile loading
-- VLib.addStage() -- finalize

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

local cachedCommits = {}

VLib.newStep()
local base_commit = "main"
for i,v in pairs(game:HttpGet("https://github.com/skiddinglua/NewVapeUnpatched4Roblox"):split("\n")) do 
	if v:find("commit") and v:find("fragment") then 
		local str = v:split("/")[5]
		base_commit = str:sub(0, str:find('"') - 1)
		break
	end
end
VLib.nextStep()

local verified_commit = base_commit

VLib.newStep()
if shared.NoVerify then
	writefile('vape/noverify.txt', 'dontdeleteme')
elseif isfile('vape/noverify.txt') and not isfile('vape/noverifyshown.txt') then
	writefile('vape/noverifyshown.txt', 'dontdeleteme')
	VLib.updateInfo('You have enabled no commit verifitication. This is not recommended and will often lead to downtime issues arising')
else
	local suc, res
	task.delay(15, function()
		if not res and not errorPopupShown then 
			errorPopupShown = true
			VLib.updateInfo("The connection to github is taking a while, Please be patient.")
		end
	end)
	suc, res = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/skiddinglua/NewVapeUnpatched4Roblox/"..base_commit.."/verified.txt", true) end)
	if not suc or res == "404: Not Found" then
		VLib.updateInfo("Failed to connect to github : vape/"..scripturl.." : "..res)
		error(res)
	end
	verified_commit = res
end

if verified_commit == '' then
	verified_commit = base_commit
	warn('Unable to find a verififed commit (using beta version)')
end
VLib.nextStep()

local function getFileCommit(scripturl)
	if cachedCommits[scripturl] then
		return cachedCommits[scripturl]
	end
	local commit = base_commit
	for i,v in pairs(game:HttpGet("https://github.com/skiddinglua/NewVapeUnpatched4Roblox/commits/"..commit.."/"..scripturl):split("\n")) do 
		if v:find("commits_list_item") then 
			local commit = v:split("/")[5]
			cachedCommits[scripturl] = commit
			break
		end
	end
	return commit
end

if not base_commit then
	VLib.updateInfo("Failed to connect to github, please try using a VPN.")
	error("Failed to connect to github, please try using a VPN.")
end

VLib.newStep()
local fallbackAssets = {["vape/assets/AddItem.png"]="rbxassetid://13350763121",["vape/assets/AddRemoveIcon1.png"]="rbxassetid://13350764147",["vape/assets/ArrowIndicator.png"]="rbxassetid://13350766521",["vape/assets/BackIcon.png"]="rbxassetid://13350767223",["vape/assets/BindBackground.png"]="rbxassetid://13350767577",["vape/assets/BlatantIcon.png"]="rbxassetid://13350767943",["vape/assets/CircleListBlacklist.png"]="rbxassetid://13350768647",["vape/assets/CircleListWhitelist.png"]="rbxassetid://13350769066",["vape/assets/ColorSlider1.png"]="rbxassetid://13350769439",["vape/assets/ColorSlider2.png"]="rbxassetid://13350769842",["vape/assets/CombatIcon.png"]="rbxassetid://13350770192",["vape/assets/DownArrow.png"]="rbxassetid://13350770749",["vape/assets/ExitIcon1.png"]="rbxassetid://13350771140",["vape/assets/FriendsIcon.png"]="rbxassetid://13350771464",["vape/assets/HoverArrow.png"]="rbxassetid://13350772201",["vape/assets/HoverArrow2.png"]="rbxassetid://13350772588",["vape/assets/HoverArrow3.png"]="rbxassetid://13350773014",["vape/assets/HoverArrow4.png"]="rbxassetid://13350773643",["vape/assets/InfoNotification.png"]="rbxassetid://13350774006",["vape/assets/KeybindIcon.png"]="rbxassetid://13350774323",["vape/assets/LegitModeIcon.png"]="rbxassetid://13436400428",["vape/assets/MoreButton1.png"]="rbxassetid://13350775005",["vape/assets/MoreButton2.png"]="rbxassetid://13350775731",["vape/assets/MoreButton3.png"]="rbxassetid://13350776241",["vape/assets/NotificationBackground.png"]="rbxassetid://13350776706",["vape/assets/NotificationBar.png"]="rbxassetid://13350777235",["vape/assets/OnlineProfilesButton.png"]="rbxassetid://13350777717",["vape/assets/PencilIcon.png"]="rbxassetid://13350778187",["vape/assets/PinButton.png"]="rbxassetid://13350778654",["vape/assets/ProfilesIcon.png"]="rbxassetid://13350779149",["vape/assets/RadarIcon1.png"]="rbxassetid://13350779545",["vape/assets/RadarIcon2.png"]="rbxassetid://13350779992",["vape/assets/RainbowIcon1.png"]="rbxassetid://13350780571",["vape/assets/RainbowIcon2.png"]="rbxassetid://13350780993",["vape/assets/RightArrow.png"]="rbxassetid://13350781908",["vape/assets/SearchBarIcon.png"]="rbxassetid://13350782420",["vape/assets/SettingsWheel1.png"]="rbxassetid://13350782848",["vape/assets/SettingsWheel2.png"]="rbxassetid://13350783258",["vape/assets/SliderArrow1.png"]="rbxassetid://13350783794",["vape/assets/SliderArrowSeperator.png"]="rbxassetid://13350784477",["vape/assets/SliderButton1.png"]="rbxassetid://13350785680",["vape/assets/TargetIcon.png"]="rbxassetid://13350786128",["vape/assets/TargetIcon1.png"]="rbxassetid://13350786776",["vape/assets/TargetIcon2.png"]="rbxassetid://13350787228",["vape/assets/TargetIcon3.png"]="rbxassetid://13350787729",["vape/assets/TargetIcon4.png"]="rbxassetid://13350788379",["vape/assets/TargetInfoIcon1.png"]="rbxassetid://13350788860",["vape/assets/TargetInfoIcon2.png"]="rbxassetid://13350789239",["vape/assets/TextBoxBKG.png"]="rbxassetid://13350789732",["vape/assets/TextBoxBKG2.png"]="rbxassetid://13350790229",["vape/assets/TextGUIIcon1.png"]="rbxassetid://13350790634",["vape/assets/TextGUIIcon2.png"]="rbxassetid://13350791175",["vape/assets/TextGUIIcon3.png"]="rbxassetid://13350791758",["vape/assets/TextGUIIcon4.png"]="rbxassetid://13350792279",["vape/assets/ToggleArrow.png"]="rbxassetid://13350792786",["vape/assets/UpArrow.png"]="rbxassetid://13350793386",["vape/assets/UtilityIcon.png"]="rbxassetid://13350793918",["vape/assets/WarningNotification.png"]="rbxassetid://13350794868",["vape/assets/WindowBlur.png"]="rbxassetid://13350795660",["vape/assets/WorldIcon.png"]="rbxassetid://13350796199",["vape/assets/VapeIcon.png"]="rbxassetid://13350808582",["vape/assets/RenderIcon.png"]="rbxassetid://13350832775",["vape/assets/VapeLogo1.png"]="rbxassetid://13350860863",["vape/assets/VapeLogo3.png"]="rbxassetid://13350872035",["vape/assets/VapeLogo2.png"]="rbxassetid://13350876307",["vape/assets/VapeLogo4.png"]="rbxassetid://13350877564"}

if userInputService.TouchEnabled then 
	--mobile exploit fix
	getgenv().getsynasset = nil
	getgenv().getcustomasset = nil
	-- why is this needed
	getsynasset = nil
	getcustomasset = nil
end
local getcustomasset = getsynasset or getcustomasset or function(location) return fallbackAssets[location] or "" end

function VLib.requestFile(scripturl)
	VLib.newStep()
	local oldCommit = isfile("vape/"..scripturl) and readHash(readfile("vape/"..scripturl))
	local newCommit = base_commit -- getFileCommit(scripturl)
	local replace = oldCommit ~= newCommit
	if replace then
		task.spawn(function()
			VLib.updateInfo(`{oldCommit and 'Updating' or 'Downloading'} vape/{scripturl}`)
			repeat task.wait() until isfile("vape/"..scripturl)
		end)
		local suc, res
		task.delay(15, function()
			if not res and not errorPopupShown then 
				errorPopupShown = true
				VLib.updateInfo("The connection to github is taking a while, Please be patient.")
			end
		end)
		suc, res = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/skiddinglua/NewVapeUnpatched4Roblox/"..newCommit.."/"..scripturl, true) end)
		if not suc or res == "404: Not Found" then
			VLib.updateInfo("Failed to connect to github : vape/"..scripturl.." : "..res)
			error(res)
		end
		if scripturl:match(".lua") then res = writeHash(res, newCommit) end
		writefile("vape/"..scripturl, res)
	end
	VLib.nextStep()
	return readfile("vape/"..scripturl)
end

function VLib.downloadAsset(path)
	VLib.newStep()
	if VLib.assetCache[path] then
		VLib.nextStep()
		return VLib.assetCache[path]
	end
	if not isfile(path) then
		local suc, req = pcall(VLib.requestFile, path:gsub("vape/assets", "assets"))
        if suc and req then
		    writefile(path, req)
        else
			VLib.nextStep()
            return vapeAssetTable[path] or ""
        end
	end
	if not VLib.assetCache[path] then VLib.assetCache[path] = getcustomasset(path) end
	VLib.nextStep()
	return VLib.assetCache[path]
end

getgenv().vapeGithubRequest = VLib.requestFile -- simplicity
getgenv().downloadVapeAsset = VLib.downloadAsset

local debug_traceback = debug.traceback or getrenv().debug.traceback -- thanks hydrogen

local ExInfo = {}
ExInfo.__index = ExInfo

function ExInfo.new(base, level, previous, trace)
	local self = setmetatable({}, ExInfo)
	self.Self = base
	self.Level = level
	self.Previous = previous
	self.Trace = `{trace}->{previous}`
	return self
end

function VLib.loadFile(source, id, exec_info)
	VLib.newStep()
	id = id or 'unknown'
	local chunk, fail = loadstring(source)
	if chunk then
		print(`{(('  '):rep(exec_info.Level))}⚙️ Compiled {id} ({exec_info.Previous})`)
		VLib.updateInfo(`Compiled: {id} ({exec_info.Previous})`)
		print(`{(('  '):rep(exec_info.Level))}▶️ Running {id} ({exec_info.Previous})`)
		VLib.updateInfo(`Running: {id} ({exec_info.Previous})`)
		local new_info = ExInfo.new(id, exec_info.Level + 1, id, exec_info.Trace)
		local function errorHandler(err)
			VLib.updateInfo(`Error: {id} ({exec_info.Previous}) ({err})`)
			print(`{(('  '):rep(exec_info.Level))}❌ Failed {id} ({exec_info.Previous}) ({err}) {debug_traceback('Traceback: ')}`)
		end
		local packed = {xpcall(chunk, errorHandler, new_info)}
		success = packed[1]
		table.remove(packed, 1)
		if success then
			print(`{(('  '):rep(exec_info.Level))}✅ Success {id} ({exec_info.Previous})`)
			VLib.updateInfo(`Success: {id} ({exec_info.Previous})`)
			VLib.nextStep()
			return unpack(packed)
		else
			if shared.GuiLibrary then
				shared.GuiLibrary.SaveSettings = function() end
			end
			return task.wait(math.huge)
		end
	else
		print(`{(('  '):rep(exec_info.Level))}❌ Failed {tag} ({exec_info.Previous}) ({fail})`)
		VLib.updateInfo(`Error:  {id} ({exec_info.Previous})`)
		return task.wait(math.huge)
	end
end

VLib.nextStep()
VLib.nextStage()

getgenv().debugLoad = VLib.loadFile

getgenv().VLib = VLib

VLib.loadFile(VLib.requestFile("MainScript.lua"), 'MainScript.lua', ExInfo.new('root', 0, 'root', ''))

VLib.MainGui.MainFrame.Visible = false