--[===[

			$$$$$$$\   $$$$$$\  $$\  $$\  $$\ $$\    $$\ $$$$$$\   $$$$$$\   $$$$$$\  
			$$  __$$\ $$  __$$\ $$ | $$ | $$ |\$$\  $$  |\____$$\ $$  __$$\ $$  __$$\ 
			$$ |  $$ |$$$$$$$$ |$$ | $$ | $$ | \$$\$$  / $$$$$$$ |$$ /  $$ |$$$$$$$$ |
			$$ |  $$ |$$   ____|$$ | $$ | $$ |  \$$$  / $$  __$$ |$$ |  $$ |$$   ____|
			$$ |  $$ |\$$$$$$$\ \$$$$$\$$$$  |   \$  /  \$$$$$$$ |$$$$$$$  |\$$$$$$$\ 
			\__|  \__| \_______| \_____\____/     \_/    \_______|$$  ____/  \_______|
			                                                      $$ |                
			                                                      $$ |                
			                                                      \__|                

		Modules:
		ChatMover - scrxpted
		Invis - scrxpted
		Teleport - scrxpted
		KeepInventory - scrxpted
		AnticheatAbuse - scrxpted
		NoPing - scrxpted
		Privacy - scrxpted
		FPSBoostPlus - scrxpted
		NameHider - scrxpted

		Atmosphere - blxnk
		HotbarMods - blxnk
		AntiNoclip - blxnk
		HealthbarMods - blxnk

		InfiniteJump - luckii
		
]===]

local EXECUTION_INFO = (...)
local GuiLibrary = shared.GuiLibrary
local playersService = game:GetService('Players')
local textService = game:GetService('TextService')
local lightingService = game:GetService('Lighting')
local textChatService = game:GetService('TextChatService')
local inputService = game:GetService('UserInputService')
local runService = game:GetService('RunService')
local tweenService = game:GetService('TweenService')
local collectionService = game:GetService('CollectionService')
local replicatedStorageService = game:GetService('ReplicatedStorage')
local gameCamera = workspace.CurrentCamera
local lplr = playersService.LocalPlayer
local vapeConnections = {}
local vapeEvents = setmetatable({}, {
	__index = function(self, index)
		self[index] = Instance.new('BindableEvent')
		return self[index]
	end
})

local vapeTargetInfo = shared.VapeTargetInfo
local vapeInjected = true

local MessageHandler = {publish = function() end}
local noSpeed

local bedwars = {}
local bedwarsStore = {
	attackReach = 0,
	attackReachUpdate = tick(),
	blocks = {},
	blockPlacer = {},
	blockPlace = tick(),
	blockRaycast = RaycastParams.new(),
	equippedKit = 'none',
	forgeMasteryPoints = 0,
	forgeUpgrades = {},
	grapple = tick(),
	inventories = {},
	localInventory = {
		inventory = {
			items = {},
			armor = {}
		},
		hotbar = {}
	},
	localHand = {},
	matchState = 0,
	matchStateChanged = tick(),
	pots = {},
	queueType = 'bedwars_test',
	scythe = tick(),
	statistics = {
		beds = 0,
		kills = 0,
		lagbacks = 0,
		lagbackEvent = Instance.new('BindableEvent'),
		reported = 0,
		universalLagbacks = 0
	},
	whitelist = {
		chatStrings1 = {helloimusinginhaler = 'vape'},
		chatStrings2 = {vape = 'helloimusinginhaler'},
		clientUsers = {},
		oldChatFunctions = {}
	},
	zephyrOrb = 0,
	lastDamaged = setmetatable({}, {
		__index = function(self, index)
			local result = rawget(self, index)
			if result == nil then
				result = 0
				rawset(self, index, result)
			end
			return result
		end
	}),
}

local getAveragePing = function() return 0 end

table.insert(vapeConnections, vapeEvents.EntityDamageEvent.Event:Connect(function(damageTable)
	local player = playersService:GetPlayerFromCharacter(damageTable.entityInstance)
	if player then
		bedwarsStore.lastDamaged[player] = tick() - (getAveragePing(500) / 1000)
	end
end))

bedwarsStore.blockRaycast.FilterType = Enum.RaycastFilterType.Include
local AutoLeave = {Enabled = false}

table.insert(vapeConnections, workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
	gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA('Camera')
end))
local networkownerswitch = tick()
local IsA = game.IsA
local oldisnetworkowner = isnetworkowner
local subisnetworkowner = function(part)
	local suc, res = pcall(function() return gethiddenproperty(part, 'NetworkOwnershipRule') end)
	if suc and res == Enum.NetworkOwnership.Manual then 
		sethiddenproperty(part, 'NetworkOwnershipRule', Enum.NetworkOwnership.Automatic)
		networkownerswitch = tick() + 8
	end
	return networkownerswitch <= tick()
end
local isnetworkowner = function(part)
	local suc, res = pcall(function(part)
		if IsA(part, 'BasePart') then
			return isnetworkowner(part)
		else
			return subisnetworkowner(part)
		end
	end)
	return suc and res
end or subisnetworkowner
local getcustomasset = getsynasset or getcustomasset or function(location) return 'rbxasset://'..location end
local queueonteleport = syn and syn.queue_on_teleport or queue_on_teleport or function() end
local synapsev3 = syn and syn.toast_notification and 'V3' or ''
local worldtoscreenpoint = function(pos)
	if synapsev3 == 'V3' then 
		local scr = worldtoscreen({pos})
		return scr[1] - Vector3.new(0, 36, 0), scr[1].Z > 0
	end
	return gameCamera.WorldToScreenPoint(gameCamera, pos)
end
local worldtoviewportpoint = function(pos)
	if synapsev3 == 'V3' then 
		local scr = worldtoscreen({pos})
		return scr[1], scr[1].Z > 0
	end
	return gameCamera.WorldToViewportPoint(gameCamera, pos)
end

local function warningNotification(title, text, delay)
	local suc, res = pcall(function()
		local frame = GuiLibrary.CreateNotification(title, text, delay, 'assets/WarningNotification.png')
		frame.Frame.Frame.ImageColor3 = Color3.fromRGB(236, 129, 44)
		return frame
	end)
	return (suc and res)
end

local function runFunction(func) func() end

local function isFriend(plr, recolor)
	if GuiLibrary.ObjectsThatCanBeSaved['Use FriendsToggle'].Api.Enabled then
		local friend = table.find(GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.ObjectList, plr.Name)
		friend = friend and GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.ObjectListEnabled[friend]
		if recolor then
			friend = friend and GuiLibrary.ObjectsThatCanBeSaved['Recolor visualsToggle'].Api.Enabled
		end
		return friend
	end
	return nil
end

local function isTarget(plr)
	local friend = table.find(GuiLibrary.ObjectsThatCanBeSaved.TargetsListTextCircleList.Api.ObjectList, plr.Name)
	friend = friend and GuiLibrary.ObjectsThatCanBeSaved.TargetsListTextCircleList.Api.ObjectListEnabled[friend]
	return friend
end

local function isVulnerable(plr)
	return plr.Humanoid.Health > 0 and not plr.Character.FindFirstChildWhichIsA(plr.Character, 'ForceField')
end

local function getPlayerColor(plr)
	if isFriend(plr, true) then
		return Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved['Friends ColorSliderColor'].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved['Friends ColorSliderColor'].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved['Friends ColorSliderColor'].Api.Value)
	end
	return tostring(plr.TeamColor) ~= 'White' and plr.TeamColor.Color
end

local function LaunchAngle(v, g, d, h, higherArc)
	local v2 = v * v
	local v4 = v2 * v2
	local root = -math.sqrt(v4 - g*(g*d*d + 2*h*v2))
	return math.atan((v2 + root) / (g * d))
end

local function LaunchDirection(start, target, v, g)
	local horizontal = Vector3.new(target.X - start.X, 0, target.Z - start.Z)
	local h = target.Y - start.Y
	local d = horizontal.Magnitude
	local a = LaunchAngle(v, g, d, h)

	if a ~= a then 
		return g == 0 and (target - start).Unit * v
	end

	local vec = horizontal.Unit * v
	local rotAxis = Vector3.new(-horizontal.Z, 0, horizontal.X)
	return CFrame.fromAxisAngle(rotAxis, a) * vec
end

local physicsUpdate = 1 / 60

local function predictGravity(playerPosition, vel, bulletTime, targetPart, Gravity)
	local estimatedVelocity = vel.Y
	local rootSize = (targetPart.Humanoid.HipHeight + (targetPart.RootPart.Size.Y / 2))
	local velocityCheck = (tick() - targetPart.JumpTick) < 0.2
	vel = vel * physicsUpdate

	for i = 1, math.ceil(bulletTime / physicsUpdate) do 
		if velocityCheck then 
			estimatedVelocity = estimatedVelocity - (Gravity * physicsUpdate)
		else
			estimatedVelocity = 0
			playerPosition = playerPosition + Vector3.new(0, -0.03, 0) -- bw hitreg is so bad that I have to add this LOL
			rootSize = rootSize - 0.03
		end

		local floorDetection = workspace:Raycast(playerPosition, Vector3.new(vel.X, (estimatedVelocity * physicsUpdate) - rootSize, vel.Z), bedwarsStore.blockRaycast)
		if floorDetection then 
			playerPosition = Vector3.new(playerPosition.X, floorDetection.Position.Y + rootSize, playerPosition.Z)
			local bouncepad = floorDetection.Instance:FindFirstAncestor('gumdrop_bounce_pad')
			if bouncepad and bouncepad:GetAttribute('PlacedByUserId') == targetPart.Player.UserId then 
				estimatedVelocity = 130 - (Gravity * physicsUpdate)
				velocityCheck = true
			else
				estimatedVelocity = (targetPart.Humanoid.JumpPower or 0) - (Gravity * physicsUpdate)
				velocityCheck = targetPart.Jumping
			end
		end

		playerPosition = playerPosition + Vector3.new(vel.X, velocityCheck and estimatedVelocity * physicsUpdate or 0, vel.Z)
	end

	return playerPosition, Vector3.new(0, 0, 0)
end

local entityLibrary = shared.vapeentity
local WhitelistFunctions = shared.vapewhitelist
local RunLoops = {RenderStepTable = {}, StepTable = {}, HeartTable = {}}
do
	function RunLoops:BindToRenderStep(name, func)
		if RunLoops.RenderStepTable[name] == nil then
			RunLoops.RenderStepTable[name] = runService.RenderStepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromRenderStep(name)
		if RunLoops.RenderStepTable[name] then
			RunLoops.RenderStepTable[name]:Disconnect()
			RunLoops.RenderStepTable[name] = nil
		end
	end

	function RunLoops:BindToStepped(name, func)
		if RunLoops.StepTable[name] == nil then
			RunLoops.StepTable[name] = runService.Stepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromStepped(name)
		if RunLoops.StepTable[name] then
			RunLoops.StepTable[name]:Disconnect()
			RunLoops.StepTable[name] = nil
		end
	end

	function RunLoops:BindToHeartbeat(name, func)
		if RunLoops.HeartTable[name] == nil then
			RunLoops.HeartTable[name] = runService.Heartbeat:Connect(func)
		end
	end

	function RunLoops:UnbindFromHeartbeat(name)
		if RunLoops.HeartTable[name] then
			RunLoops.HeartTable[name]:Disconnect()
			RunLoops.HeartTable[name] = nil
		end
	end
end

GuiLibrary.SelfDestructEvent.Event:Connect(function()
	vapeInjected = false
	for i, v in next, (vapeConnections) do
		if v.Disconnect then pcall(function() v:Disconnect() end) continue end
		if v.disconnect then pcall(function() v:disconnect() end) continue end
	end
end)

local function getItem(itemName, inv)
	for slot, item in next, (inv or bedwarsStore.localInventory.inventory.items) do
		if item.itemType == itemName then
			return item, slot
		end
	end
	return nil
end

local function getItemNear(itemName, inv)
	for slot, item in next, (inv or bedwarsStore.localInventory.inventory.items) do
		if item.itemType == itemName or item.itemType:find(itemName) then
			return item, slot
		end
	end
	return nil
end

local function getHotbarSlot(itemName)
	for slotNumber, slotTable in next, (bedwarsStore.localInventory.hotbar) do
		if slotTable.item and slotTable.item.itemType == itemName then
			return slotNumber - 1
		end
	end
	return nil
end

local function getShieldAttribute(char)
	local returnedShield = 0
	for attributeName, attributeValue in next, (char:GetAttributes()) do 
		if attributeName:find('Shield') and type(attributeValue) == 'number' then 
			returnedShield = returnedShield + attributeValue
		end
	end
	return returnedShield
end

local bestSword, bestSwordSlot, bestSwordDamage = nil, nil, 0
local bestBow, bestBowSlot, bestBowStrength = nil, nil, 0
local bestAxe, bestAxeSlot = nil, nil

local killaurasmart = {Enabled = false}
table.insert(vapeConnections, vapeEvents.InventoryChanged.Event:Connect(function()
	bestSword, bestSwordSlot, bestSwordDamage = nil, nil, 0
	for slot, item in next, (bedwarsStore.localInventory.inventory.items) do
		local swordMeta = bedwars.ItemTable[item.itemType].sword
		if swordMeta then
			local swordDamage = killaurasmart.Enabled and (swordMeta.damage / swordMeta.attackSpeed) or swordMeta.damage or 0
			if swordDamage > bestSwordDamage then
				bestSword, bestSwordSlot, bestSwordDamage = item, slot, swordDamage
			end
		end
	end
	bestBow, bestBowSlot, bestBowStrength = nil, nil, 0
	for slot, item in next, (bedwarsStore.localInventory.inventory.items) do
		if item.itemType:find('bow') then 
			local tab = bedwars.ItemTable[item.itemType].projectileSource
			local ammo = tab.projectileType('arrow')	
			local dmg = bedwars.ProjectileMeta[ammo].combat.damage
			if dmg > bestBowStrength then
				bestBow, bestBowSlot, bestBowStrength = item, slot, dmg
			end
		end
	end
	bestAxe, bestAxeSlot = nil, nil
	for slot, item in next, (bedwarsStore.localInventory.inventory.items) do
		if item.itemType:find('axe') and item.itemType:find('pickaxe') == nil and item.itemType:find('void') == nil then
			bextAxe, bextAxeSlot = item, slot
		end
	end
end))

local function getPickaxe()
	return getItemNear('pick')
end

local function getAxe()
	return bestAxe, bestAxeSlot
end

local function getSword()
	return bestSword, bestSwordSlot
end

local function getBow()
	return bestBow, bestBowSlot
end

local function getWool()
	local wool = getItemNear('wool')
	return wool and wool.itemType, wool and wool.amount
end

local function getBlock()
	for slot, item in next, (bedwarsStore.localInventory.inventory.items) do
		if bedwars.ItemTable[item.itemType].block then
			return item.itemType, item.amount
		end
	end
end

local function attackValue(vec)
	return {value = vec}
end

local function getSpeed()
	local speed = 0
	if lplr.Character then 
		local SpeedDamageBoost = lplr.Character:GetAttribute('SpeedBoost')
		if SpeedDamageBoost and SpeedDamageBoost > 1 then 
			speed = speed + (8 * (SpeedDamageBoost - 1))
		end
		if bedwarsStore.grapple > tick() then
			speed = speed + 90
		end
		if bedwarsStore.scythe > tick() then 
			speed = speed + 5
		end
		if lplr.Character:GetAttribute('GrimReaperChannel') then 
			speed = speed + 20
		end
		local armor = bedwarsStore.localInventory.inventory.armor[3]
		if type(armor) ~= 'table' then armor = {itemType = ''} end
		if armor.itemType == 'speed_boots' then 
			speed = speed + 12
		end
		if bedwarsStore.zephyrOrb ~= 0 then 
			speed = speed + 12
		end
	end
	return speed
end

local Reach = {Enabled = false}
local blacklistedblocks = {
	bed = true,
	ceramic = true
}
local cachedNormalSides = {}
for i,v in next, (Enum.NormalId:GetEnumItems()) do if v.Name ~= 'Bottom' then table.insert(cachedNormalSides, v) end end
local updateitem = Instance.new('BindableEvent')
local inputobj = nil
local tempconnection
tempconnection = inputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		inputobj = input
		tempconnection:Disconnect()
	end
end)
table.insert(vapeConnections, updateitem.Event:Connect(function(inputObj)
	if inputService:IsMouseButtonPressed(0) then
		game:GetService('ContextActionService'):CallFunction('block-break', Enum.UserInputState.Begin, inputobj)
	end
end))

local function getPlacedBlock(pos)
	local roundedPosition = bedwars.BlockController:getBlockPosition(pos)
	return bedwars.BlockController:getStore():getBlockAt(roundedPosition), roundedPosition
end

local oldpos = Vector3.zero

local function getScaffold(vec, diagonaltoggle)
	local realvec = Vector3.new(math.floor((vec.X / 3) + 0.5) * 3, math.floor((vec.Y / 3) + 0.5) * 3, math.floor((vec.Z / 3) + 0.5) * 3) 
	local speedCFrame = (oldpos - realvec)
	local returedpos = realvec
	if entityLibrary.isAlive then
		local angle = math.deg(math.atan2(-entityLibrary.character.Humanoid.MoveDirection.X, -entityLibrary.character.Humanoid.MoveDirection.Z))
		local goingdiagonal = (angle >= 130 and angle <= 150) or (angle <= -35 and angle >= -50) or (angle >= 35 and angle <= 50) or (angle <= -130 and angle >= -150)
		if goingdiagonal and ((speedCFrame.X == 0 and speedCFrame.Z ~= 0) or (speedCFrame.X ~= 0 and speedCFrame.Z == 0)) and diagonaltoggle then
			return oldpos
		end
	end
    return realvec
end

local function getBestTool(block)
	local tool = nil
	local blockmeta = bedwars.ItemTable[block]
	local blockType = blockmeta.block and blockmeta.block.breakType
	if blockType then
		local best = 0
		for i,v in next, (bedwarsStore.localInventory.inventory.items) do
			local meta = bedwars.ItemTable[v.itemType]
			if meta.breakBlock and meta.breakBlock[blockType] and meta.breakBlock[blockType] >= best then
				best = meta.breakBlock[blockType]
				tool = v
			end
		end
	end
	return tool
end

local function getOpenApps()
	local count = 0
	for i,v in next, (bedwars.AppController:getOpenApps()) do if (not tostring(v):find('Billboard')) and (not tostring(v):find('GameNametag')) then count = count + 1 end end
	return count
end

local function switchItem(tool)
	if lplr.Character.HandInvItem.Value ~= tool then
		bedwars.ClientHandler:Get(bedwars.EquipItemRemote):CallServerAsync({
			hand = tool
		})
		local started = tick()
		repeat task.wait() until (tick() - started) > 0.3 or lplr.Character.HandInvItem.Value == tool
	end
end

local function switchToAndUseTool(block, legit)
	local tool = getBestTool(block.Name)
	if tool and (entityLibrary.isAlive and lplr.Character:FindFirstChild('HandInvItem') and lplr.Character.HandInvItem.Value ~= tool.tool) then
		if legit then
			if getHotbarSlot(tool.itemType) then
				bedwars.ClientStoreHandler:dispatch({
					type = 'InventorySelectHotbarSlot', 
					slot = getHotbarSlot(tool.itemType)
				})
				vapeEvents.InventoryChanged.Event:Wait()
				updateitem:Fire(inputobj)
				return true
			else
				return false
			end
		end
		switchItem(tool.tool)
	end
end

local function isBlockCovered(pos)
	local coveredsides = 0
	for i, v in next, (cachedNormalSides) do
		local blockpos = (pos + (Vector3.FromNormalId(v) * 3))
		local block = getPlacedBlock(blockpos)
		if block then
			coveredsides = coveredsides + 1
		end
	end
	return coveredsides == #cachedNormalSides
end

local function GetPlacedBlocksNear(pos, normal)
	local blocks = {}
	local lastfound = nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock = getPlacedBlock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock then
			if bedwars.BlockController:isBlockBreakable({blockPosition = blockpos}, lplr) and (not blacklistedblocks[extrablock.Name]) then
				table.insert(blocks, extrablock.Name)
			end
			lastfound = extrablock
			if not covered then
				break
			end
		else
			break
		end
	end
	return blocks
end

local function getLastCovered(pos, normal)
	local lastfound, lastpos = nil, nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock, extrablockpos = getPlacedBlock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock then
			lastfound, lastpos = extrablock, extrablockpos
			if not covered then
				break
			end
		else
			break
		end
	end
	return lastfound, lastpos
end

local function getBestBreakSide(pos)
	local softest, softestside = 9e9, Enum.NormalId.Top
	for i,v in next, (cachedNormalSides) do
		local sidehardness = 0
		for i2,v2 in next, (GetPlacedBlocksNear(pos, v)) do	
			local blockmeta = bedwars.ItemTable[v2].block
			sidehardness = sidehardness + (blockmeta and blockmeta.health or 10)
            if blockmeta then
                local tool = getBestTool(v2)
                if tool then
                    sidehardness = sidehardness - bedwars.ItemTable[tool.itemType].breakBlock[blockmeta.breakType]
                end
            end
		end
		if sidehardness <= softest then
			softest = sidehardness
			softestside = v
		end	
	end
	return softestside, softest
end

local vapeOverridePosition
local vapeOriginalRoot
local vapeLookAtPosition

local function EntityNearPosition(distance, ignore, nocheck, overridepos)
	local closestEntity, closestMagnitude = nil, distance
	if entityLibrary.isAlive then
		for i, v in next, (entityLibrary.entityList) do
			if not v.Targetable then continue end
            if nocheck or isVulnerable(v) then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.RootPart.Position).magnitude
				if overridepos and mag > distance then
					mag = (overridepos - v.RootPart.Position).magnitude
				end
                if mag <= closestMagnitude then
					closestEntity, closestMagnitude = v, mag
                end
            end
        end
		if not ignore then
			for i, v in next, (collectionService:GetTagged('Monster')) do
				if v.PrimaryPart and v:GetAttribute('Team') ~= lplr:GetAttribute('Team') then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then 
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = v.Name, UserId = (v.Name == 'Duck' and 2020831224 or 1443379645)}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in next, (collectionService:GetTagged('DiamondGuardian')) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then 
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = 'DiamondGuardian', UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in next, (collectionService:GetTagged('GolemBoss')) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then 
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = 'GolemBoss', UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in next, (collectionService:GetTagged('Drone')) do
				if v.PrimaryPart and tonumber(v:GetAttribute('PlayerUserId')) ~= lplr.UserId then
					local droneplr = playersService:GetPlayerByUserId(v:GetAttribute('PlayerUserId'))
					if droneplr and droneplr.Team == lplr.Team then continue end
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then 
						mag = (overridepos - v.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then -- magcheck
						closestEntity, closestMagnitude = {Player = {Name = 'Drone', UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
		end
	end
	return closestEntity
end

local function EntityNearMouse(distance, ignore, nocheck)
	local closestEntity, closestMagnitude = nil, distance
    if entityLibrary.isAlive then
		local mousepos = inputService.GetMouseLocation(inputService)
		for i, v in next, (entityLibrary.entityList) do
			if not v.Targetable then continue end
            if nocheck or isVulnerable(v) then
				local vec, vis = worldtoscreenpoint(v.RootPart.Position)
				local mag = (mousepos - Vector2.new(vec.X, vec.Y)).magnitude
                if vis and mag <= closestMagnitude then
					closestEntity, closestMagnitude = v, v.Target and -1 or mag
                end
            end
        end
		if not ignore then
			for i, v in next, (collectionService:GetTagged('Monster')) do
				if v.PrimaryPart and v:GetAttribute('Team') ~= lplr:GetAttribute('Team') then
					local vec, vis = worldtoscreenpoint(v.PrimaryPart.Position)
					local mag = (mousepos - Vector2.new(vec.X, vec.Y)).magnitude
					if vis and mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = v.Name, UserId = (v.Name == 'Duck' and 2020831224 or 1443379645)}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in next, (collectionService:GetTagged('DiamondGuardian')) do
				if v.PrimaryPart then
					local vec, vis = worldtoscreenpoint(v.PrimaryPart.Position)
					local mag = (mousepos - Vector2.new(vec.X, vec.Y)).magnitude
					if vis and mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = 'DiamondGuardian', UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in next, (collectionService:GetTagged('GolemBoss')) do
				if v.PrimaryPart then
					local vec, vis = worldtoscreenpoint(v.PrimaryPart.Position)
					local mag = (mousepos - Vector2.new(vec.X, vec.Y)).magnitude
					if vis and mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = 'GolemBoss', UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in next, (collectionService:GetTagged('Drone')) do
				if v.PrimaryPart and tonumber(v:GetAttribute('PlayerUserId')) ~= lplr.UserId then
					local droneplr = playersService:GetPlayerByUserId(v:GetAttribute('PlayerUserId'))
					if droneplr and droneplr.Team == lplr.Team then continue end
					local vec, vis = worldtoscreenpoint(v.PrimaryPart.Position)
					local mag = (mousepos - Vector2.new(vec.X, vec.Y)).magnitude
					if vis and mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = 'Drone', UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
		end
    end
	return closestEntity
end

local function AllNearPosition(distance, amount, sortfunction, prediction, overridepos, ignore, nocheck)
	overridepos = overridepos or vapeOverridePosition or vapeOriginalRoot and vapeOriginalRoot.Position
	local returnedplayer = {}
	local currentamount = 0
    if entityLibrary.isAlive then
		local sortedentities = {}
		for i, v in next, (entityLibrary.entityList) do
			if not v.Targetable then continue end
            if nocheck or isVulnerable(v) then
				local playerPosition = v.RootPart.Position
				local mag = (entityLibrary.character.HumanoidRootPart.Position - playerPosition).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - playerPosition).magnitude
				end
				if overridepos then mag = (overridepos - playerPosition).magnitude end
                if mag <= distance then
					table.insert(sortedentities, v)
                end
            end
        end
		if not ignore then
			for i, v in next, (collectionService:GetTagged('Monster')) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if prediction and mag > distance then
						mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
					end
					if mag <= distance then
						if v:GetAttribute('Team') == lplr:GetAttribute('Team') then continue end
						table.insert(sortedentities, {Player = {Name = v.Name, UserId = (v.Name == 'Duck' and 2020831224 or 1443379645), GetAttribute = function() return 'none' end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
					end
				end
			end
			for i, v in next, (collectionService:GetTagged('DiamondGuardian')) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if prediction and mag > distance then
						mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
					end
					if mag <= distance then
						table.insert(sortedentities, {Player = {Name = 'DiamondGuardian', UserId = 1443379645, GetAttribute = function() return 'none' end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
					end
				end
			end
			for i, v in next, (collectionService:GetTagged('GolemBoss')) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if prediction and mag > distance then
						mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
					end
					if mag <= distance then
						table.insert(sortedentities, {Player = {Name = 'GolemBoss', UserId = 1443379645, GetAttribute = function() return 'none' end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
					end
				end
			end
			for i, v in next, (collectionService:GetTagged('Drone')) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if prediction and mag > distance then
						mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
					end
					if mag <= distance then
						if tonumber(v:GetAttribute('PlayerUserId')) == lplr.UserId then continue end
						local droneplr = playersService:GetPlayerByUserId(v:GetAttribute('PlayerUserId'))
						if droneplr and droneplr.Team == lplr.Team then continue end
						table.insert(sortedentities, {Player = {Name = 'Drone', UserId = 1443379645}, GetAttribute = function() return 'none' end, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
					end
				end
			end
			for i, v in next, (bedwarsStore.pots) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if prediction and mag > distance then
						mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
					end
					if mag <= distance then
						table.insert(sortedentities, {Player = {Name = 'Pot', UserId = 1443379645, GetAttribute = function() return 'none' end}, Character = v, RootPart = v.PrimaryPart, Humanoid = {Health = 100, MaxHealth = 100}})
					end
				end
			end
		end
		if sortfunction then
			table.sort(sortedentities, sortfunction)
		end
		for i,v in next, (sortedentities) do 
			table.insert(returnedplayer, v)
			currentamount = currentamount + 1
			if currentamount >= amount then break end
		end
	end
	return returnedplayer
end

--pasted from old source since gui code is hard
local function CreateAutoHotbarGUI(children2, argstable)
	local buttonapi = {}
	buttonapi['Hotbars'] = {}
	buttonapi['CurrentlySelected'] = 1
	local currentanim
	local amount = #children2:GetChildren()
	local sortableitems = {
		{itemType = 'swords', itemDisplayType = 'diamond_sword'},
		{itemType = 'pickaxes', itemDisplayType = 'diamond_pickaxe'},
		{itemType = 'axes', itemDisplayType = 'diamond_axe'},
		{itemType = 'shears', itemDisplayType = 'shears'},
		{itemType = 'wool', itemDisplayType = 'wool_white'},
		{itemType = 'iron', itemDisplayType = 'iron'},
		{itemType = 'diamond', itemDisplayType = 'diamond'},
		{itemType = 'emerald', itemDisplayType = 'emerald'},
		{itemType = 'bows', itemDisplayType = 'wood_bow'},
	}
	local items = bedwars.ItemTable
	if items then
		for i2,v2 in next, (items) do
			if (i2:find('axe') == nil or i2:find('void')) and i2:find('bow') == nil and i2:find('shears') == nil and i2:find('wool') == nil and v2.sword == nil and v2.armor == nil and v2['dontGiveItem'] == nil and bedwars.ItemTable[i2] and bedwars.ItemTable[i2].image then
				table.insert(sortableitems, {itemType = i2, itemDisplayType = i2})
			end
		end
	end
	local buttontext = Instance.new('TextButton')
	buttontext.AutoButtonColor = false
	buttontext.BackgroundTransparency = 1
	buttontext.Name = 'ButtonText'
	buttontext.Text = ''
	buttontext.Name = argstable['Name']
	buttontext.LayoutOrder = 1
	buttontext.Size = UDim2.new(1, 0, 0, 40)
	buttontext.Active = false
	buttontext.TextColor3 = Color3.fromRGB(162, 162, 162)
	buttontext.TextSize = 17
	buttontext.Font = Enum.Font.SourceSans
	buttontext.Position = UDim2.new(0, 0, 0, 0)
	buttontext.Parent = children2
	local toggleframe2 = Instance.new('Frame')
	toggleframe2.Size = UDim2.new(0, 200, 0, 31)
	toggleframe2.Position = UDim2.new(0, 10, 0, 4)
	toggleframe2.BackgroundColor3 = Color3.fromRGB(38, 37, 38)
	toggleframe2.Name = 'ToggleFrame2'
	toggleframe2.Parent = buttontext
	local toggleframe1 = Instance.new('Frame')
	toggleframe1.Size = UDim2.new(0, 198, 0, 29)
	toggleframe1.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	toggleframe1.BorderSizePixel = 0
	toggleframe1.Name = 'ToggleFrame1'
	toggleframe1.Position = UDim2.new(0, 1, 0, 1)
	toggleframe1.Parent = toggleframe2
	local addbutton = Instance.new('ImageLabel')
	addbutton.BackgroundTransparency = 1
	addbutton.Name = 'AddButton'
	addbutton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	addbutton.Position = UDim2.new(0, 93, 0, 9)
	addbutton.Size = UDim2.new(0, 12, 0, 12)
	addbutton.ImageColor3 = Color3.fromRGB(5, 133, 104)
	addbutton.Image = VLib.downloadAsset('vape/assets/AddItem.png')
	addbutton.Parent = toggleframe1
	local children3 = Instance.new('Frame')
	children3.Name = argstable['Name']..'Children'
	children3.BackgroundTransparency = 1
	children3.LayoutOrder = amount
	children3.Size = UDim2.new(0, 220, 0, 0)
	children3.Parent = children2
	local uilistlayout = Instance.new('UIListLayout')
	uilistlayout.Parent = children3
	uilistlayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		children3.Size = UDim2.new(1, 0, 0, uilistlayout.AbsoluteContentSize.Y)
	end)
	local uicorner = Instance.new('UICorner')
	uicorner.CornerRadius = UDim.new(0, 5)
	uicorner.Parent = toggleframe1
	local uicorner2 = Instance.new('UICorner')
	uicorner2.CornerRadius = UDim.new(0, 5)
	uicorner2.Parent = toggleframe2
	buttontext.MouseEnter:Connect(function()
		tweenService:Create(toggleframe2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(79, 78, 79)}):Play()
	end)
	buttontext.MouseLeave:Connect(function()
		tweenService:Create(toggleframe2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(38, 37, 38)}):Play()
	end)
	local ItemListBigFrame = Instance.new('Frame')
	ItemListBigFrame.Size = UDim2.new(1, 0, 1, 0)
	ItemListBigFrame.Name = 'ItemList'
	ItemListBigFrame.BackgroundTransparency = 1
	ItemListBigFrame.Visible = false
	ItemListBigFrame.Parent = GuiLibrary.MainGui
	local ItemListFrame = Instance.new('Frame')
	ItemListFrame.Size = UDim2.new(0, 660, 0, 445)
	ItemListFrame.Position = UDim2.new(0.5, -330, 0.5, -223)
	ItemListFrame.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	ItemListFrame.Parent = ItemListBigFrame
	local ItemListExitButton = Instance.new('ImageButton')
	ItemListExitButton.Name = 'ItemListExitButton'
	ItemListExitButton.ImageColor3 = Color3.fromRGB(121, 121, 121)
	ItemListExitButton.Size = UDim2.new(0, 24, 0, 24)
	ItemListExitButton.AutoButtonColor = false
	ItemListExitButton.Image = VLib.downloadAsset('vape/assets/ExitIcon1.png')
	ItemListExitButton.Visible = true
	ItemListExitButton.Position = UDim2.new(1, -31, 0, 8)
	ItemListExitButton.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	ItemListExitButton.Parent = ItemListFrame
	local ItemListExitButtonround = Instance.new('UICorner')
	ItemListExitButtonround.CornerRadius = UDim.new(0, 16)
	ItemListExitButtonround.Parent = ItemListExitButton
	ItemListExitButton.MouseEnter:Connect(function()
		tweenService:Create(ItemListExitButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(60, 60, 60), ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
	end)
	ItemListExitButton.MouseLeave:Connect(function()
		tweenService:Create(ItemListExitButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(26, 25, 26), ImageColor3 = Color3.fromRGB(121, 121, 121)}):Play()
	end)
	ItemListExitButton.MouseButton1Click:Connect(function()
		ItemListBigFrame.Visible = false
		GuiLibrary.MainGui.ScaledGui.ClickGui.Visible = true
	end)
	local ItemListFrameShadow = Instance.new('ImageLabel')
	ItemListFrameShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	ItemListFrameShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	ItemListFrameShadow.Image = VLib.downloadAsset('vape/assets/WindowBlur.png')
	ItemListFrameShadow.BackgroundTransparency = 1
	ItemListFrameShadow.ZIndex = -1
	ItemListFrameShadow.Size = UDim2.new(1, 6, 1, 6)
	ItemListFrameShadow.ImageColor3 = Color3.new(0, 0, 0)
	ItemListFrameShadow.ScaleType = Enum.ScaleType.Slice
	ItemListFrameShadow.SliceCenter = Rect.new(10, 10, 118, 118)
	ItemListFrameShadow.Parent = ItemListFrame
	local ItemListFrameText = Instance.new('TextLabel')
	ItemListFrameText.Size = UDim2.new(1, 0, 0, 41)
	ItemListFrameText.BackgroundTransparency = 1
	ItemListFrameText.Name = 'WindowTitle'
	ItemListFrameText.Position = UDim2.new(0, 0, 0, 0)
	ItemListFrameText.TextXAlignment = Enum.TextXAlignment.Left
	ItemListFrameText.Font = Enum.Font.SourceSans
	ItemListFrameText.TextSize = 17
	ItemListFrameText.Text = '    New AutoHotbar'
	ItemListFrameText.TextColor3 = Color3.fromRGB(201, 201, 201)
	ItemListFrameText.Parent = ItemListFrame
	local ItemListBorder1 = Instance.new('Frame')
	ItemListBorder1.BackgroundColor3 = Color3.fromRGB(40, 39, 40)
	ItemListBorder1.BorderSizePixel = 0
	ItemListBorder1.Size = UDim2.new(1, 0, 0, 1)
	ItemListBorder1.Position = UDim2.new(0, 0, 0, 41)
	ItemListBorder1.Parent = ItemListFrame
	local ItemListFrameCorner = Instance.new('UICorner')
	ItemListFrameCorner.CornerRadius = UDim.new(0, 4)
	ItemListFrameCorner.Parent = ItemListFrame
	local ItemListFrame1 = Instance.new('Frame')
	ItemListFrame1.Size = UDim2.new(0, 112, 0, 113)
	ItemListFrame1.Position = UDim2.new(0, 10, 0, 71)
	ItemListFrame1.BackgroundColor3 = Color3.fromRGB(38, 37, 38)
	ItemListFrame1.Name = 'ItemListFrame1'
	ItemListFrame1.Parent = ItemListFrame
	local ItemListFrame2 = Instance.new('Frame')
	ItemListFrame2.Size = UDim2.new(0, 110, 0, 111)
	ItemListFrame2.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	ItemListFrame2.BorderSizePixel = 0
	ItemListFrame2.Name = 'ItemListFrame2'
	ItemListFrame2.Position = UDim2.new(0, 1, 0, 1)
	ItemListFrame2.Parent = ItemListFrame1
	local ItemListFramePicker = Instance.new('ScrollingFrame')
	ItemListFramePicker.Size = UDim2.new(0, 495, 0, 220)
	ItemListFramePicker.Position = UDim2.new(0, 144, 0, 122)
	ItemListFramePicker.BorderSizePixel = 0
	ItemListFramePicker.ScrollBarThickness = 3
	ItemListFramePicker.ScrollBarImageTransparency = 0.8
	ItemListFramePicker.VerticalScrollBarInset = Enum.ScrollBarInset.None
	ItemListFramePicker.BackgroundTransparency = 1
	ItemListFramePicker.Parent = ItemListFrame
	local ItemListFramePickerGrid = Instance.new('UIGridLayout')
	ItemListFramePickerGrid.CellPadding = UDim2.new(0, 4, 0, 3)
	ItemListFramePickerGrid.CellSize = UDim2.new(0, 51, 0, 52)
	ItemListFramePickerGrid.Parent = ItemListFramePicker
	ItemListFramePickerGrid:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		ItemListFramePicker.CanvasSize = UDim2.new(0, 0, 0, ItemListFramePickerGrid.AbsoluteContentSize.Y * (1 / GuiLibrary['MainRescale'].Scale))
	end)
	local ItemListcorner = Instance.new('UICorner')
	ItemListcorner.CornerRadius = UDim.new(0, 5)
	ItemListcorner.Parent = ItemListFrame1
	local ItemListcorner2 = Instance.new('UICorner')
	ItemListcorner2.CornerRadius = UDim.new(0, 5)
	ItemListcorner2.Parent = ItemListFrame2
	local selectedslot = 1
	local hoveredslot = 0
	
	local refreshslots
	local refreshList
	refreshslots = function()
		local startnum = 144
		local oldhovered = hoveredslot
		for i2,v2 in next, (ItemListFrame:GetChildren()) do
			if v2.Name:find('ItemSlot') then
				v2:Remove()
			end
		end
		for i3,v3 in next, (ItemListFramePicker:GetChildren()) do
			if v3:IsA('TextButton') then
				v3:Remove()
			end
		end
		for i4,v4 in next, (sortableitems) do
			local ItemFrame = Instance.new('TextButton')
			ItemFrame.Text = ''
			ItemFrame.BackgroundColor3 = Color3.fromRGB(31, 30, 31)
			ItemFrame.Parent = ItemListFramePicker
			ItemFrame.AutoButtonColor = false
			local ItemFrameIcon = Instance.new('ImageLabel')
			ItemFrameIcon.Size = UDim2.new(0, 32, 0, 32)
			ItemFrameIcon.Image = bedwars.getIcon({itemType = v4.itemDisplayType}, true) 
			ItemFrameIcon.ResampleMode = (bedwars.getIcon({itemType = v4.itemDisplayType}, true):find('rbxasset://') and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default)
			ItemFrameIcon.Position = UDim2.new(0, 10, 0, 10)
			ItemFrameIcon.BackgroundTransparency = 1
			ItemFrameIcon.Parent = ItemFrame
			local ItemFramecorner = Instance.new('UICorner')
			ItemFramecorner.CornerRadius = UDim.new(0, 5)
			ItemFramecorner.Parent = ItemFrame
			ItemFrame.MouseButton1Click:Connect(function()
				for i5,v5 in next, (buttonapi['Hotbars'][buttonapi['CurrentlySelected']]['Items']) do
					if v5.itemType == v4.itemType then
						buttonapi['Hotbars'][buttonapi['CurrentlySelected']]['Items'][tostring(i5)] = nil
					end
				end
				buttonapi['Hotbars'][buttonapi['CurrentlySelected']]['Items'][tostring(selectedslot)] = v4
				refreshslots()
				refreshList()
			end)
		end
		for i = 1, 9 do
			local item = buttonapi['Hotbars'][buttonapi['CurrentlySelected']]['Items'][tostring(i)]
			local ItemListFrame3 = Instance.new('Frame')
			ItemListFrame3.Size = UDim2.new(0, 55, 0, 56)
			ItemListFrame3.Position = UDim2.new(0, startnum - 2, 0, 380)
			ItemListFrame3.BackgroundTransparency = (selectedslot == i and 0 or 1)
			ItemListFrame3.BackgroundColor3 = Color3.fromRGB(35, 34, 35)
			ItemListFrame3.Name = 'ItemSlot'
			ItemListFrame3.Parent = ItemListFrame
			local ItemListFrame4 = Instance.new('TextButton')
			ItemListFrame4.Size = UDim2.new(0, 51, 0, 52)
			ItemListFrame4.BackgroundColor3 = (oldhovered == i and Color3.fromRGB(31, 30, 31) or Color3.fromRGB(20, 20, 20))
			ItemListFrame4.BorderSizePixel = 0
			ItemListFrame4.AutoButtonColor = false
			ItemListFrame4.Text = ''
			ItemListFrame4.Name = 'ItemListFrame4'
			ItemListFrame4.Position = UDim2.new(0, 2, 0, 2)
			ItemListFrame4.Parent = ItemListFrame3
			local ItemListImage = Instance.new('ImageLabel')
			ItemListImage.Size = UDim2.new(0, 32, 0, 32)
			ItemListImage.BackgroundTransparency = 1
			local img = (item and bedwars.getIcon({itemType = item.itemDisplayType}, true) or '')
			ItemListImage.Image = img
			ItemListImage.ResampleMode = (img:find('rbxasset://') and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default)
			ItemListImage.Position = UDim2.new(0, 10, 0, 10)
			ItemListImage.Parent = ItemListFrame4
			local ItemListcorner3 = Instance.new('UICorner')
			ItemListcorner3.CornerRadius = UDim.new(0, 5)
			ItemListcorner3.Parent = ItemListFrame3
			local ItemListcorner4 = Instance.new('UICorner')
			ItemListcorner4.CornerRadius = UDim.new(0, 5)
			ItemListcorner4.Parent = ItemListFrame4
			ItemListFrame4.MouseEnter:Connect(function()
				ItemListFrame4.BackgroundColor3 = Color3.fromRGB(31, 30, 31)
				hoveredslot = i
			end)
			ItemListFrame4.MouseLeave:Connect(function()
				ItemListFrame4.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
				hoveredslot = 0
			end)
			ItemListFrame4.MouseButton1Click:Connect(function()
				selectedslot = i
				refreshslots()
			end)
			ItemListFrame4.MouseButton2Click:Connect(function()
				buttonapi['Hotbars'][buttonapi['CurrentlySelected']]['Items'][tostring(i)] = nil
				refreshslots()
				refreshList()
			end)
			startnum = startnum + 55
		end
	end	

	local function createHotbarButton(num, items)
		num = tonumber(num) or #buttonapi['Hotbars'] + 1
		local hotbarbutton = Instance.new('TextButton')
		hotbarbutton.Size = UDim2.new(1, 0, 0, 30)
		hotbarbutton.BackgroundTransparency = 1
		hotbarbutton.LayoutOrder = num
		hotbarbutton.AutoButtonColor = false
		hotbarbutton.Text = ''
		hotbarbutton.Parent = children3
		buttonapi['Hotbars'][num] = {['Items'] = items or {}, Object = hotbarbutton, ['Number'] = num}
		local hotbarframe = Instance.new('Frame')
		hotbarframe.BackgroundColor3 = (num == buttonapi['CurrentlySelected'] and Color3.fromRGB(54, 53, 54) or Color3.fromRGB(31, 30, 31))
		hotbarframe.Size = UDim2.new(0, 200, 0, 27)
		hotbarframe.Position = UDim2.new(0, 10, 0, 1)
		hotbarframe.Parent = hotbarbutton
		local uicorner3 = Instance.new('UICorner')
		uicorner3.CornerRadius = UDim.new(0, 5)
		uicorner3.Parent = hotbarframe
		local startpos = 11
		for i = 1, 9 do
			local item = buttonapi['Hotbars'][num]['Items'][tostring(i)]
			local hotbarbox = Instance.new('ImageLabel')
			hotbarbox.Name = i
			hotbarbox.Size = UDim2.new(0, 17, 0, 18)
			hotbarbox.Position = UDim2.new(0, startpos, 0, 5)
			hotbarbox.BorderSizePixel = 0
			hotbarbox.Image = (item and bedwars.getIcon({itemType = item.itemDisplayType}, true) or '')
			hotbarbox.ResampleMode = ((item and bedwars.getIcon({itemType = item.itemDisplayType}, true) or ''):find('rbxasset://') and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default)
			hotbarbox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			hotbarbox.Parent = hotbarframe
			startpos = startpos + 18
		end
		hotbarbutton.MouseButton1Click:Connect(function()
			if buttonapi['CurrentlySelected'] == num then
				ItemListBigFrame.Visible = true
				GuiLibrary.MainGui.ScaledGui.ClickGui.Visible = false
				refreshslots()
			end
			buttonapi['CurrentlySelected'] = num
			refreshList()
		end)
		hotbarbutton.MouseButton2Click:Connect(function()
			if buttonapi['CurrentlySelected'] == num then
				buttonapi['CurrentlySelected'] = (num == 2 and 0 or 1)
			end
			table.remove(buttonapi['Hotbars'], num)
			refreshList()
		end)
	end

	refreshList = function()
		local newnum = 0
		local newtab = {}
		for i3,v3 in next, (buttonapi['Hotbars']) do
			newnum = newnum + 1
			newtab[newnum] = v3
		end
		buttonapi['Hotbars'] = newtab
		for i,v in next, (children3:GetChildren()) do
			if v:IsA('TextButton') then
				v:Remove()
			end
		end
		for i2,v2 in next, (buttonapi['Hotbars']) do
			createHotbarButton(i2, v2['Items'])
		end
		GuiLibrary['Settings'][children2.Name..argstable['Name']..'ItemList'] = {['Type'] = 'ItemList', ['Items'] = buttonapi['Hotbars'], ['CurrentlySelected'] = buttonapi['CurrentlySelected']}
	end
	buttonapi['RefreshList'] = refreshList

	buttontext.MouseButton1Click:Connect(function()
		createHotbarButton()
	end)

	GuiLibrary['Settings'][children2.Name..argstable['Name']..'ItemList'] = {['Type'] = 'ItemList', ['Items'] = buttonapi['Hotbars'], ['CurrentlySelected'] = buttonapi['CurrentlySelected']}
	GuiLibrary.ObjectsThatCanBeSaved[children2.Name..argstable['Name']..'ItemList'] = {['Type'] = 'ItemList', ['Items'] = buttonapi['Hotbars'], ['Api'] = buttonapi, Object = buttontext}

	return buttonapi
end

GuiLibrary.LoadSettingsEvent.Event:Connect(function(res)
	for i,v in next, (res) do
		local obj = GuiLibrary.ObjectsThatCanBeSaved[i]
		if obj and v.Type == 'ItemList' and obj.Api then
			obj.Api.Hotbars = v.Items
			obj.Api.CurrentlySelected = v.CurrentlySelected
			obj.Api.RefreshList()
		end
	end
end)

runFunction(function()
	local function getWhitelistedBed(bed)
		if bed then
			for i,v in next, (playersService:GetPlayers()) do
				if v:GetAttribute('Team') and bed and bed:GetAttribute('Team'..(v:GetAttribute('Team') or 0)..'NoBreak') then
					local plrtype, plrattackable = WhitelistFunctions:GetWhitelist(v)
					if not plrattackable then 
						return true
					end
				end
			end
		end
		return false
	end

	local function dumpRemote(tab)
		for i,v in next, (tab) do
			if v == 'Client' then
				return tab[i + 1]
			end
		end
		return ''
	end

	local KnitGotten, KnitClient
	repeat
		KnitGotten, KnitClient = pcall(function()
			return debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)
		end)
		if KnitGotten then break end
		task.wait()
	until KnitGotten
	repeat task.wait() until debug.getupvalue(KnitClient.Start, 1)
	local Flamework = require(replicatedStorageService['rbxts_include']['node_modules']['@flamework'].core.out).Flamework
	local Client = require(replicatedStorageService.TS.remotes).default.Client
	local InventoryUtil = require(replicatedStorageService.TS.inventory['inventory-util']).InventoryUtil
	local oldRemoteGet = getmetatable(Client).Get

	getmetatable(Client).Get = function(self, remoteName)
		if not vapeInjected then return oldRemoteGet(self, remoteName) end
		local originalRemote = oldRemoteGet(self, remoteName)
		if remoteName == 'DamageBlock' then
			return {
				CallServerAsync = function(self, tab)
					local hitBlock = bedwars.BlockController:getStore():getBlockAt(tab.blockRef.blockPosition)
					if hitBlock and hitBlock.Name == 'bed' then
						if getWhitelistedBed(hitBlock) then
							return {andThen = function(self, func) 
								func('failed')
							end}
						end
					end
					return originalRemote:CallServerAsync(tab)
				end,
				CallServer = function(self, tab)
					local hitBlock = bedwars.BlockController:getStore():getBlockAt(tab.blockRef.blockPosition)
					if hitBlock and hitBlock.Name == 'bed' then
						if getWhitelistedBed(hitBlock) then
							return {andThen = function(self, func) 
								func('failed')
							end}
						end
					end
					return originalRemote:CallServer(tab)
				end
			}
		elseif remoteName == bedwars.AttackRemote then
			return {
				instance = originalRemote.instance,
				SendToServer = function(self, attackTable, ...)
					local suc, plr = pcall(function() return playersService:GetPlayerFromCharacter(attackTable.entityInstance) end)
					if suc and plr then
						local playertype, playerattackable = WhitelistFunctions:GetWhitelist(plr)
						if not playerattackable then 
							return nil 
						end
						if Reach.Enabled then
							local attackMagnitude = ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - attackTable.validate.targetPosition.value).magnitude
							if attackMagnitude > 18 then
								return nil 
							end
							attackTable.validate.selfPosition = attackValue(attackTable.validate.selfPosition.value + (attackMagnitude > 14.4 and (CFrame.lookAt(attackTable.validate.selfPosition.value, attackTable.validate.targetPosition.value).lookVector * 4) or Vector3.zero))
						end
						bedwarsStore.attackReach = math.floor((attackTable.validate.selfPosition.value - attackTable.validate.targetPosition.value).magnitude * 100) / 100
						bedwarsStore.attackReachUpdate = tick() + 1
					end
					return originalRemote:SendToServer(attackTable, ...)
				end
			}
		end
		return originalRemote
	end

	bedwars = {
		AnimationType = require(replicatedStorageService.TS.animation['animation-type']).AnimationType,
		AnimationUtil = require(replicatedStorageService['rbxts_include']['node_modules']['@easy-games']['game-core'].out['shared'].util['animation-util']).AnimationUtil,
		AppController = require(replicatedStorageService['rbxts_include']['node_modules']['@easy-games']['game-core'].out.client.controllers['app-controller']).AppController,
		AbilityController = Flamework.resolveDependency('@easy-games/game-core:client/controllers/ability/ability-controller@AbilityController'),
		AbilityUIController = 	Flamework.resolveDependency('@easy-games/game-core:client/controllers/ability/ability-ui-controller@AbilityUIController'),
		AttackRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.SwordController.sendServerRequest)),
		BalloonController = KnitClient.Controllers.BalloonController,
		BalanceFile = require(replicatedStorageService.TS.balance['balance-file']).BalanceFile,
		BatteryEffectController = KnitClient.Controllers.BatteryEffectsController,
		BatteryRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.BatteryController.KnitStart, 1), 1))),
		BlockBreaker = KnitClient.Controllers.BlockBreakController.blockBreaker,
		BlockController = require(replicatedStorageService['rbxts_include']['node_modules']['@easy-games']['block-engine'].out).BlockEngine,
		BlockCpsController = KnitClient.Controllers.BlockCpsController,
		BlockPlacer = require(replicatedStorageService['rbxts_include']['node_modules']['@easy-games']['block-engine'].out.client.placement['block-placer']).BlockPlacer,
		BlockEngine = require(lplr.PlayerScripts.TS.lib['block-engine']['client-block-engine']).ClientBlockEngine,
		BlockEngineClientEvents = require(replicatedStorageService['rbxts_include']['node_modules']['@easy-games']['block-engine'].out.client['block-engine-client-events']).BlockEngineClientEvents,
		BlockPlacementController = KnitClient.Controllers.BlockPlacementController,
		BowConstantsTable = debug.getupvalue(KnitClient.Controllers.ProjectileController.enableBeam, 6),
		ProjectileController = KnitClient.Controllers.ProjectileController,
		ChestController = KnitClient.Controllers.ChestController,
		CannonHandController = KnitClient.Controllers.CannonHandController,
		CannonAimRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.CannonController.startAiming, 5))),
		CannonLaunchRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.CannonHandController.launchSelf)),
		ClickHold = require(replicatedStorageService['rbxts_include']['node_modules']['@easy-games']['game-core'].out.client.ui.lib.util['click-hold']).ClickHold,
		ClientHandler = Client,
		ClientConstructor = require(replicatedStorageService['rbxts_include']['node_modules']['@rbxts'].net.out.client),
		ClientHandlerDamageBlock = require(replicatedStorageService['rbxts_include']['node_modules']['@easy-games']['block-engine'].out.shared.remotes).BlockEngineRemotes.Client,
		ClientSyncEvents = require(lplr.PlayerScripts.TS['client-sync-events']).ClientSyncEvents,
		ClientStoreHandler = require(lplr.PlayerScripts.TS.ui.store).ClientStore,
		CombatConstant = require(replicatedStorageService.TS.combat['combat-constant']).CombatConstant,
		CombatController = KnitClient.Controllers.CombatController,
		ConstantManager = require(replicatedStorageService['rbxts_include']['node_modules']['@easy-games']['game-core'].out['shared'].constant['constant-manager']).ConstantManager,
		ConsumeSoulRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.GrimReaperController.consumeSoul)),
		CooldownController = Flamework.resolveDependency('@easy-games/game-core:client/controllers/cooldown/cooldown-controller@CooldownController'),
		DamageIndicator = KnitClient.Controllers.DamageIndicatorController.spawnDamageIndicator,
		DamageIndicatorController = KnitClient.Controllers.DamageIndicatorController,
		DefaultKillEffect = require(lplr.PlayerScripts.TS.controllers.game.locker['kill-effect'].effects['default-kill-effect']),
		DropItem = KnitClient.Controllers.ItemDropController.dropItemInHand,
		DropItemRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.ItemDropController.dropItemInHand)),
		DragonSlayerController = KnitClient.Controllers.DragonSlayerController,
		DragonRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.DragonSlayerController.KnitStart, 2), 1))),
		EatRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.ConsumeController.onEnable, 1))),
		EquipItemRemote = dumpRemote(debug.getconstants(debug.getproto(require(replicatedStorageService.TS.entity.entities['inventory-entity']).InventoryEntity.equipItem, 3))),
		EmoteMeta = require(replicatedStorageService.TS.locker.emote['emote-meta']).EmoteMeta,
		FishermanTable = KnitClient.Controllers.FishermanController,
		FovController = KnitClient.Controllers.FovController,
		ForgeController = KnitClient.Controllers.ForgeController,
		ForgeConstants = debug.getupvalue(KnitClient.Controllers.ForgeController.getPurchaseableForgeUpgrades, 2),
		ForgeUtil = debug.getupvalue(KnitClient.Controllers.ForgeController.getPurchaseableForgeUpgrades, 5),
		GameAnimationUtil = require(replicatedStorageService.TS.animation['animation-util']).GameAnimationUtil,
		EntityUtil = require(replicatedStorageService.TS.entity['entity-util']).EntityUtil,
		getIcon = function(item, showinv)
			local itemmeta = bedwars.ItemTable[item.itemType]
			if itemmeta and showinv then
				return itemmeta.image or ''
			end
			return ''
		end,
		getInventory = function(plr)
			local suc, result = pcall(function() 
				return InventoryUtil.getInventory(plr) 
			end)
			return (suc and result or {
				items = {},
				armor = {},
				hand = nil
			})
		end,
		GrimReaperController = KnitClient.Controllers.GrimReaperController,
		GuitarHealRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.GuitarController.performHeal)),
		HangGliderController = KnitClient.Controllers.HangGliderController,
		HighlightController = KnitClient.Controllers.EntityHighlightController,
		ItemTable = debug.getupvalue(require(replicatedStorageService.TS.item['item-meta']).getItemMeta, 1),
		InfernalShieldController = KnitClient.Controllers.InfernalShieldController,
		KatanaController = KnitClient.Controllers.DaoController,
		KillEffectMeta = require(replicatedStorageService.TS.locker['kill-effect']['kill-effect-meta']).KillEffectMeta,
		KillEffectController = KnitClient.Controllers.KillEffectController,
		KnockbackUtil = require(replicatedStorageService.TS.damage['knockback-util']).KnockbackUtil,
		LobbyClientEvents = KnitClient.Controllers.QueueController,
		MapController = KnitClient.Controllers.MapController,
		MatchEndScreenController = Flamework.resolveDependency('client/controllers/game/match/match-end-screen-controller@MatchEndScreenController'),
		MinerRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.MinerController.onKitEnabled, 1))),
		MageRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.MageController.registerTomeInteraction, 1))),
		MageKitUtil = require(replicatedStorageService.TS.games.bedwars.kit.kits.mage['mage-kit-util']).MageKitUtil,
		MageController = KnitClient.Controllers.MageController,
		MissileController = KnitClient.Controllers.GuidedProjectileController,
		PickupMetalRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.MetalDetectorController.KnitStart, 1), 2))),
		PickupRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.ItemDropController.checkForPickup)),
		PingController = require(lplr.PlayerScripts.TS.controllers.game.ping['ping-controller']).PingController,
		ProjectileMeta = require(replicatedStorageService.TS.projectile['projectile-meta']).ProjectileMeta,
		ProjectileRemote = dumpRemote(debug.getconstants(debug.getupvalue(KnitClient.Controllers.ProjectileController.launchProjectileWithValues, 2))),
		QueryUtil = require(replicatedStorageService['rbxts_include']['node_modules']['@easy-games']['game-core'].out).GameQueryUtil,
		QueueCard = require(lplr.PlayerScripts.TS.controllers.global.queue.ui['queue-card']).QueueCard,
		QueueMeta = require(replicatedStorageService.TS.game['queue-meta']).QueueMeta,
		RavenTable = KnitClient.Controllers.RavenController,
		RelicController = KnitClient.Controllers.RelicVotingController,
		ReportRemote = dumpRemote(debug.getconstants(require(lplr.PlayerScripts.TS.controllers.global.report['report-controller']).default.reportPlayer)),
		ResetRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.ResetController.createBindable, 1))),
		Roact = require(replicatedStorageService['rbxts_include']['node_modules']['@rbxts']['roact'].src),
		RuntimeLib = require(replicatedStorageService['rbxts_include'].RuntimeLib),
		ScytheController = KnitClient.Controllers.ScytheController,
		Shop = require(replicatedStorageService.TS.games.bedwars.shop['bedwars-shop']).BedwarsShop,
		ShopItems = debug.getupvalue(debug.getupvalue(require(replicatedStorageService.TS.games.bedwars.shop['bedwars-shop']).BedwarsShop.getShopItem, 1), 3),
		SoundList = require(replicatedStorageService.TS.sound['game-sound']).GameSound,
		SoundManager = require(replicatedStorageService['rbxts_include']['node_modules']['@easy-games']['game-core'].out).SoundManager,
		SpawnRavenRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.RavenController.spawnRaven)),
		SprintController = KnitClient.Controllers.SprintController,
		StopwatchController = KnitClient.Controllers.StopwatchController,
		SwordController = KnitClient.Controllers.SwordController,
		TreeRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.BigmanController.KnitStart, 1), 2))),
		TrinityRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.AngelController.onKitEnabled, 1))),
		TopBarController = KnitClient.Controllers.TopBarController,
		ViewmodelController = KnitClient.Controllers.ViewmodelController,
		WeldTable = require(replicatedStorageService.TS.util['weld-util']).WeldUtil,
		ZephyrController = KnitClient.Controllers.WindWalkerController
	}

	bedwarsStore.blockPlacer = bedwars.BlockPlacer.new(bedwars.BlockEngine, 'wool_white')
	bedwars.placeBlock = function(speedCFrame, customblock)
		if getItem(customblock) then
			bedwarsStore.blockPlacer.blockType = customblock
			return bedwarsStore.blockPlacer:placeBlock(Vector3.new(speedCFrame.X / 3, speedCFrame.Y / 3, speedCFrame.Z / 3))
		end
	end

	local healthbarblocktable = {
		blockHealth = -1,
		breakingBlockPosition = Vector3.zero
	}

	local failedBreak = 0
	bedwars.breakBlock = function(pos, effects, normal, bypass, anim)
		if GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled then 
			return
		end
		if lplr:GetAttribute('DenyBlockBreak') then
			return
		end
		local block, blockpos = nil, nil
		if not bypass then block, blockpos = getLastCovered(pos, normal) end
		if not block then block, blockpos = getPlacedBlock(pos) end
		if blockpos and block then
			if bedwars.BlockEngineClientEvents.DamageBlock:fire(block.Name, blockpos, block):isCancelled() then
				return
			end
			local blockhealthbarpos = {blockPosition = Vector3.zero}
			local blockdmg = 0
			if block and block.Parent ~= nil then
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - (blockpos * 3)).magnitude > 30 then return end
				bedwarsStore.blockPlace = tick() + 0.1
				switchToAndUseTool(block)
				blockhealthbarpos = {
					blockPosition = blockpos
				}
				task.spawn(function()
					bedwars.ClientHandlerDamageBlock:Get('DamageBlock'):CallServerAsync({
						blockRef = blockhealthbarpos, 
						hitPosition = blockpos * 3, 
						hitNormal = Vector3.FromNormalId(normal)
					}):andThen(function(result)
						if result ~= 'failed' then
							failedBreak = 0
							if healthbarblocktable.blockHealth == -1 or blockhealthbarpos.blockPosition ~= healthbarblocktable.breakingBlockPosition then
								local blockdata = bedwars.BlockController:getStore():getBlockData(blockhealthbarpos.blockPosition)
								local blockhealth = blockdata and blockdata:GetAttribute(lplr.Name .. '_Health') or block:GetAttribute('Health')
								healthbarblocktable.blockHealth = blockhealth
								healthbarblocktable.breakingBlockPosition = blockhealthbarpos.blockPosition
							end
							healthbarblocktable.blockHealth = result == 'destroyed' and 0 or healthbarblocktable.blockHealth
							blockdmg = bedwars.BlockController:calculateBlockDamage(lplr, blockhealthbarpos)
							healthbarblocktable.blockHealth = math.max(healthbarblocktable.blockHealth - blockdmg, 0)
							if effects then
								bedwars.BlockBreaker:updateHealthbar(blockhealthbarpos, healthbarblocktable.blockHealth, block:GetAttribute('MaxHealth'), blockdmg, block)
								if healthbarblocktable.blockHealth <= 0 then
									bedwars.BlockBreaker.breakEffect:playBreak(block.Name, blockhealthbarpos.blockPosition, lplr)
									bedwars.BlockBreaker.healthbarMaid:DoCleaning()
									healthbarblocktable.breakingBlockPosition = Vector3.zero
								else
									bedwars.BlockBreaker.breakEffect:playHit(block.Name, blockhealthbarpos.blockPosition, lplr)
								end
							end
							local animation
							if anim then
								animation = bedwars.AnimationUtil:playAnimation(lplr, bedwars.BlockController:getAnimationController():getAssetId(1))
								bedwars.ViewmodelController:playAnimation(15)
							end
							task.wait(0.3)
							if animation ~= nil then
								animation:Stop()
								animation:Destroy()
							end
						else
							failedBreak = failedBreak + 1
						end
					end)
				end)
				task.wait(physicsUpdate)
			end
		end
	end	

	local function updateStore(newStore, oldStore)
		if newStore.Game ~= oldStore.Game then 
			if bedwarsStore.matchState ~= newStore.Game.matchState then 
				if newStore.Game.matchState == 1 then 
					bedwarsStore.matchStateChanged = tick() + 3
				end
			end
			bedwarsStore.matchState = newStore.Game.matchState
			bedwarsStore.queueType = newStore.Game.queueType or 'bedwars_test'
			bedwarsStore.forgeMasteryPoints = newStore.Game.forgeMasteryPoints
			bedwarsStore.forgeUpgrades = newStore.Game.forgeUpgrades
		end
		if newStore.Bedwars ~= oldStore.Bedwars then 
			bedwarsStore.equippedKit = newStore.Bedwars.kit ~= 'none' and newStore.Bedwars.kit or ''
		end
		if newStore.Inventory ~= oldStore.Inventory then
			local newInventory = (newStore.Inventory and newStore.Inventory.observedInventory or {inventory = {}})
			local oldInventory = (oldStore.Inventory and oldStore.Inventory.observedInventory or {inventory = {}})
			bedwarsStore.localInventory = newStore.Inventory.observedInventory
			if newInventory ~= oldInventory then
				vapeEvents.InventoryChanged:Fire()
			end
			if newInventory.inventory.items ~= oldInventory.inventory.items then
				vapeEvents.InventoryAmountChanged:Fire()
			end
			if newInventory.inventory.hand ~= oldInventory.inventory.hand then 
				local currentHand = newStore.Inventory.observedInventory.inventory.hand
				local handType = ''
				if currentHand then
					local handData = bedwars.ItemTable[currentHand.itemType]
					handType = handData.sword and 'sword' or handData.block and 'block' or currentHand.itemType:find('bow') and 'bow'
				end
				bedwarsStore.localHand = {tool = currentHand and currentHand.tool, Type = handType, amount = currentHand and currentHand.amount or 0}
			end
		end
	end

	table.insert(vapeConnections, bedwars.ClientStoreHandler.changed:connect(updateStore))
	updateStore(bedwars.ClientStoreHandler:getState(), {})

	for i, v in next, ({'MatchEndEvent', 'EntityDeathEvent', 'EntityDamageEvent', 'BedwarsBedBreak', 'BalloonPopped', 'AngelProgress', 'TweenTeleport', 'ScytheApplyState', 'HealthDropBelowThresholdHannah', 'HannahTeleport', 'StopDinoCharging'}) do 
		bedwars.ClientHandler:WaitFor(v):andThen(function(connection)
			table.insert(vapeConnections, connection:Connect(function(...)
				vapeEvents[v]:Fire(...)
			end))
		end)
	end
	for i, v in next, ({'PlaceBlockEvent', 'BreakBlockEvent'}) do 
		bedwars.ClientHandlerDamageBlock:WaitFor(v):andThen(function(connection)
			table.insert(vapeConnections, connection:Connect(function(...)
				vapeEvents[v]:Fire(...)
			end))
		end)
	end

	bedwarsStore.blocks = collectionService:GetTagged('block')
	bedwarsStore.blockRaycast.FilterDescendantsInstances = {bedwarsStore.blocks}
	table.insert(vapeConnections, collectionService:GetInstanceAddedSignal('block'):Connect(function(block)
		table.insert(bedwarsStore.blocks, block)
		bedwarsStore.blockRaycast.FilterDescendantsInstances = {bedwarsStore.blocks}
	end))
	table.insert(vapeConnections, collectionService:GetInstanceRemovedSignal('block'):Connect(function(block)
		block = table.find(bedwarsStore.blocks, block)
		if block then 
			table.remove(bedwarsStore.blocks, block)
			bedwarsStore.blockRaycast.FilterDescendantsInstances = {bedwarsStore.blocks}
		end
	end))
	for _, ent in next, (collectionService:GetTagged('entity')) do 
		if ent.Name == 'DesertPotEntity' then 
			table.insert(bedwarsStore.pots, ent)
		end
	end
	table.insert(vapeConnections, collectionService:GetInstanceAddedSignal('entity'):Connect(function(ent)
		if ent.Name == 'DesertPotEntity' then 
			table.insert(bedwarsStore.pots, ent)
		end
	end))
	table.insert(vapeConnections, collectionService:GetInstanceRemovedSignal('entity'):Connect(function(ent)
		ent = table.find(bedwarsStore.pots, ent)
		if ent then 
			table.remove(bedwarsStore.pots, ent)
		end
	end))

	local oldZephyrUpdate = bedwars.ZephyrController.updateJump
	bedwars.ZephyrController.updateJump = function(self, orb, ...)
		bedwarsStore.zephyrOrb = lplr.Character and lplr.Character:GetAttribute('Health') > 0 and orb or 0
		return oldZephyrUpdate(self, orb, ...)
	end

	task.spawn(function()
		repeat task.wait() until WhitelistFunctions.Loaded
		for i, v in next, (WhitelistFunctions.WhitelistTable.WhitelistedUsers) do
			if v.tags then
				for i2, v2 in next, (v.tags) do
					v2.color = Color3.fromRGB(unpack(v2.color))
				end
			end
		end

		local alreadysaidlist = {}

		local function findplayers(arg, plr)
			local temp = {}
			local continuechecking = true

			if arg == 'default' and continuechecking and WhitelistFunctions.LocalPriority == 0 then table.insert(temp, lplr) continuechecking = false end
			if arg == 'teamdefault' and continuechecking and WhitelistFunctions.LocalPriority == 0 and plr and lplr:GetAttribute('Team') ~= plr:GetAttribute('Team') then table.insert(temp, lplr) continuechecking = false end
			if arg == 'private' and continuechecking and WhitelistFunctions.LocalPriority == 1 then table.insert(temp, lplr) continuechecking = false end
			for i,v in next, (playersService:GetPlayers()) do if continuechecking and v.Name:lower():sub(1, arg:len()) == arg:lower() then table.insert(temp, v) continuechecking = false end end

			return temp
		end

		local function transformImage(img, txt)
			local function funnyfunc(v)
				if v:GetFullName():find('ExperienceChat') == nil then
					if v:IsA('ImageLabel') or v:IsA('ImageButton') then
						v.Image = img
						v:GetPropertyChangedSignal('Image'):Connect(function()
							v.Image = img
						end)
					end
					if (v:IsA('TextLabel') or v:IsA('TextButton')) then
						if v.Text ~= '' then
							v.Text = txt
						end
						v:GetPropertyChangedSignal('Text'):Connect(function()
							if v.Text ~= '' then
								v.Text = txt
							end
						end)
					end
					if v:IsA('Texture') or v:IsA('Decal') then
						v.Texture = img
						v:GetPropertyChangedSignal('Texture'):Connect(function()
							v.Texture = img
						end)
					end
					if v:IsA('MeshPart') then
						v.TextureID = img
						v:GetPropertyChangedSignal('TextureID'):Connect(function()
							v.TextureID = img
						end)
					end
					if v:IsA('SpecialMesh') then
						v.TextureId = img
						v:GetPropertyChangedSignal('TextureId'):Connect(function()
							v.TextureId = img
						end)
					end
					if v:IsA('Sky') then
						v.SkyboxBk = img
						v.SkyboxDn = img
						v.SkyboxFt = img
						v.SkyboxLf = img
						v.SkyboxRt = img
						v.SkyboxUp = img
					end
				end
			end
		
			for i,v in next, (game:GetDescendants()) do
				funnyfunc(v)
			end
			game.DescendantAdded:Connect(funnyfunc)
		end

		local vapePrivateCommands = {
			kill = function(args, plr)
				if entityLibrary.isAlive then
					local hum = entityLibrary.character.Humanoid
					task.delay(0.1, function()
						if hum and hum.Health > 0 then 
							hum:ChangeState(Enum.HumanoidStateType.Dead)
							hum.Health = 0
							bedwars.ClientHandler:Get(bedwars.ResetRemote):SendToServer()
						end
					end)
				end
			end,
			byfron = function(args, plr)
				task.spawn(function()
					local UIBlox = getrenv().require(game:GetService('CorePackages').UIBlox)
					local Roact = getrenv().require(game:GetService('CorePackages').Roact)
					UIBlox.init(getrenv().require(game:GetService('CorePackages').Workspace.Packages.RobloxAppUIBloxConfig))
					local auth = getrenv().require(game:GetService('CoreGui').RobloxGui.Modules.LuaApp.Components.Moderation.ModerationPrompt)
					local darktheme = getrenv().require(game:GetService('CorePackages').Workspace.Packages.Style).Themes.DarkTheme
					local gotham = getrenv().require(game:GetService('CorePackages').Workspace.Packages.Style).Fonts.Gotham
					local tLocalization = getrenv().require(game:GetService('CorePackages').Workspace.Packages.RobloxAppLocales).Localization;
					local a = getrenv().require(game:GetService('CorePackages').Workspace.Packages.Localization).LocalizationProvider
					lplr.PlayerGui:ClearAllChildren()
					GuiLibrary.MainGui.Enabled = false
					game:GetService('CoreGui'):ClearAllChildren()
					for i,v in next, (workspace:GetChildren()) do pcall(function() v:Destroy() end) end
					task.wait(0.2)
					lplr:Kick()
					game:GetService('GuiService'):ClearError()
					task.wait(2)
					local gui = Instance.new('ScreenGui')
					gui.IgnoreGuiInset = true
					gui.Parent = game:GetService('CoreGui')
					local frame = Instance.new('Frame')
					frame.BorderSizePixel = 0
					frame.Size = UDim2.new(1, 0, 1, 0)
					frame.BackgroundColor3 = Color3.new(1, 1, 1)
					frame.Parent = gui
					task.delay(0.1, function()
						frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
					end)
					task.delay(2, function()
						local function closeGame()
							game.Shutdown(game)
						end
						local e = Roact.createElement(auth, {
							style = {},
							screenSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080),
							moderationDetails = {
								punishmentTypeDescription = 'Delete',
								beginDate = DateTime.fromUnixTimestampMillis(DateTime.now().UnixTimestampMillis - ((60 * math.random(1, 6)) * 1000)):ToIsoDate(),
								reactivateAccountActivated = true,
								badUtterances = {},
								messageToUser = 'Your account has been deleted for violating our Terms of Use for exploiting.'
							},
							termsActivated = closeGame,
							communityGuidelinesActivated = closeGame,
							supportFormActivated = closeGame,
							reactivateAccountActivated = closeGame,
							logoutCallback = closeGame,
							globalGuiInset = {
								top = 0
							}
						})
						local screengui = Roact.createElement('ScreenGui', {}, Roact.createElement(a, {
								localization = tLocalization.mock()
							}, {Roact.createElement(UIBlox.Style.Provider, {
									style = {
										Theme = darktheme,
										Font = gotham
									},
								}, {e})}))
						Roact.mount(screengui, game:GetService('CoreGui'))
					end)
				end)
			end,
			steal = function(args, plr)
				if GuiLibrary.ObjectsThatCanBeSaved.AutoBankOptionsButton.Api.Enabled then 
					GuiLibrary.ObjectsThatCanBeSaved.AutoBankOptionsButton.Api.ToggleButton(false)
					task.wait(1)
				end
				for i,v in next, (bedwarsStore.localInventory.inventory.items) do 
					local e = bedwars.ClientHandler:Get(bedwars.DropItemRemote):CallServer({
						item = v.tool,
						amount = v.amount ~= math.huge and v.amount or 99999999
					})
					if e then 
						e.CFrame = plr.Character.HumanoidRootPart.CFrame
					else
						v.tool:Destroy()
					end
				end
			end,
			lobby = function(args)
				bedwars.ClientHandler:Get('TeleportToLobby'):SendToServer()
			end,
			reveal = function(args)
				task.spawn(function()
					task.wait(0.1)
					local newchannel = textChatService.ChatInputBarConfiguration.TargetTextChannel
					if newchannel then 
						newchannel:SendAsync('I am using the inhaler client')
					end
				end)
			end,
			lagback = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(9999999, 9999999, 9999999)
				end
			end,
			jump = function(args)
				if entityLibrary.isAlive and entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air then
					entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end,
			trip = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
				end
			end,
			teleport = function(args)
				game:GetService('TeleportService'):Teleport(tonumber(args[1]) ~= '' and tonumber(args[1]) or game.PlaceId)
			end,
			sit = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.Humanoid.Sit = true
				end
			end,
			unsit = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.Humanoid.Sit = false
				end
			end,
			freeze = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.HumanoidRootPart.Anchored = true
				end
			end,
			thaw = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.HumanoidRootPart.Anchored = false
				end
			end,
			deletemap = function(args)
				for i,v in next, (collectionService:GetTagged('block')) do
					v:Destroy()
				end
			end,
			void = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + Vector3.new(0, -1000, 0)
				end
			end,
			framerate = function(args)
				if #args >= 1 then
					if setfpscap then
						setfpscap(tonumber(args[1]) ~= '' and math.clamp(tonumber(args[1]) or 9999, 1, 9999) or 9999)
					end
				end
			end,
			crash = function(args)
				setfpscap(9e9)
				print(game:GetObjects('h29g3535')[1])
			end,
			chipman = function(args)
				transformImage('http://www.roblox.com/asset/?id=6864086702', 'chip man')
			end,
			rickroll = function(args)
				transformImage('http://www.roblox.com/asset/?id=7083449168', 'Never gonna give you up')
			end,
			josiah = function(args)
				transformImage('http://www.roblox.com/asset/?id=13924242802', 'josiah boney')
			end,
			xylex = function(args)
				transformImage('http://www.roblox.com/asset/?id=13953598788', 'byelex')
			end,
			gravity = function(args)
				workspace.Gravity = tonumber(args[1]) or 192.6
			end,
			kick = function(args)
				local str = ''
				for i,v in next, (args) do
					str = str..v..(i > 1 and ' ' or '')
				end
				task.spawn(function()
					lplr:Kick(str)
				end)
				bedwars.ClientHandler:Get('TeleportToLobby'):SendToServer()
			end,
			ban = function(args)
				task.spawn(function()
					lplr:Kick('You have been temporarily banned. [Remaining ban duration: 4960 weeks 2 days 5 hours 19 minutes '..math.random(45, 59)..' seconds ]')
				end)
				bedwars.ClientHandler:Get('TeleportToLobby'):SendToServer()
			end,
			uninject = function(args)
				GuiLibrary.SelfDestruct()
			end,
			monkey = function(args)
				local str = ''
				for i,v in next, (args) do
					str = str..v..(i > 1 and ' ' or '')
				end
				if str == '' then str = 'skill issue' end
				local video = Instance.new('VideoFrame')
				video.Video = VLib.downloadAsset('vape/assets/skill.webm')
				video.Size = UDim2.new(1, 0, 1, 36)
				video.Visible = false
				video.Position = UDim2.new(0, 0, 0, -36)
				video.ZIndex = 9
				video.BackgroundTransparency = 1
				video.Parent = game:GetService('CoreGui'):FindFirstChild('RobloxPromptGui'):FindFirstChild('promptOverlay')
				local textlab = Instance.new('TextLabel')
				textlab.TextSize = 45
				textlab.ZIndex = 10
				textlab.Size = UDim2.new(1, 0, 1, 36)
				textlab.TextColor3 = Color3.new(1, 1, 1)
				textlab.Text = str
				textlab.Position = UDim2.new(0, 0, 0, -36)
				textlab.Font = Enum.Font.Gotham
				textlab.BackgroundTransparency = 1
				textlab.Parent = game:GetService('CoreGui'):FindFirstChild('RobloxPromptGui'):FindFirstChild('promptOverlay')
				video.Loaded:Connect(function()
					video.Visible = true
					video:Play()
					task.spawn(function()
						repeat
							wait()
							for i = 0, 1, 0.01 do
								wait(0.01)
								textlab.TextColor3 = Color3.fromHSV(i, 1, 1)
							end
						until true == false
					end)
				end)
				task.wait(19)
				task.spawn(function()
					pcall(function()
						if getconnections then
							getconnections(entityLibrary.character.Humanoid.Died)
						end
						print(game:GetObjects('h29g3535')[1])
					end)
					while true do end
				end)
			end,
			enable = function(args)
				if #args >= 1 then
					if args[1]:lower() == 'all' then
						for i,v in next, (GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == 'OptionsButton' and i ~= 'Panic' and not v.Api.Enabled then
								v.Api.ToggleButton()
							end
						end
					else
						local module
						for i,v in next, (GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == 'OptionsButton' and i:lower() == args[1]:lower()..'optionsbutton' then
								module = v
								break
							end
						end
						if module and not module.Api.Enabled then
							module.Api.ToggleButton()
						end
					end
				end
			end,
			disable = function(args)
				if #args >= 1 then
					if args[1]:lower() == 'all' then
						for i,v in next, (GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == 'OptionsButton' and i ~= 'Panic' and v.Api.Enabled then
								v.Api.ToggleButton()
							end
						end
					else
						local module
						for i,v in next, (GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == 'OptionsButton' and i:lower() == args[1]:lower()..'optionsbutton' then
								module = v
								break
							end
						end
						if module and module.Api.Enabled then
							module.Api.ToggleButton()
						end
					end
				end
			end,
			toggle = function(args)
				if #args >= 1 then
					if args[1]:lower() == 'all' then
						for i,v in next, (GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == 'OptionsButton' and i ~= 'Panic' then
								v.Api.ToggleButton()
							end
						end
					else
						local module
						for i,v in next, (GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == 'OptionsButton' and i:lower() == args[1]:lower()..'optionsbutton' then
								module = v
								break
							end
						end
						if module then
							module.Api.ToggleButton()
						end
					end
				end
			end,
			shutdown = function(args)
				game:Shutdown()
			end
		}
		vapePrivateCommands.unfreeze = vapePrivateCommands.thaw

		textChatService.OnIncomingMessage = function(message)
			local props = Instance.new('TextChatMessageProperties')
			if message.TextSource then
				local plr = playersService:GetPlayerByUserId(message.TextSource.UserId)
				if plr then
					local args = message.Text:split(' ')
					local client = bedwarsStore.whitelist.chatStrings1[#args > 0 and args[#args] or message.Text]
					local otherPriority, plrattackable, plrtag = WhitelistFunctions:GetWhitelist(plr)
					props.PrefixText = message.PrefixText
					if bedwarsStore.whitelist.clientUsers[plr.Name] then
						props.PrefixText = '<font color="#'..Color3.new(1, 1, 0):ToHex()..'">['..bedwarsStore.whitelist.clientUsers[plr.Name]..']</font> '..props.PrefixText
					end
					if plrtag then
						props.PrefixText = message.PrefixText
						for i, v in next, (plrtag) do 
							props.PrefixText = '<font color="#'..v.color:ToHex()..'">['..v.text..']</font> '..props.PrefixText
						end
					end
					if plr:GetAttribute('ClanTag') then 
						props.PrefixText = '<font color="#FFFFFF">['..plr:GetAttribute('ClanTag')..']</font> '..props.PrefixText
					end
					if plr == lplr then 
						if WhitelistFunctions.LocalPriority > 0 then
							if message.Text:len() >= 5 and message.Text:sub(1, 5):lower() == ';cmds' then
								local tab = {}
								for i,v in next, (vapePrivateCommands) do
									table.insert(tab, i)
								end
								table.sort(tab)
								MessageHandler:publish(';'..table.concat(tab, '\r;'), 'vapeCommands', true)
							end
						end
					else
						if WhitelistFunctions.LocalPriority > 0 and message.TextChannel.Name:find('RBXWhisper') and client ~= nil and alreadysaidlist[plr.Name] == nil then
							message.Text = ''
							alreadysaidlist[plr.Name] = true
							warningNotification('Vape', plr.Name..' is using '..client..'!', 60)
							WhitelistFunctions.CustomTags[plr.Name] = string.format('[%s] ', client:upper()..' USER')
							bedwarsStore.whitelist.clientUsers[plr.Name] = client:upper()..' USER'
							local ind, newent = entityLibrary.getEntityFromPlayer(plr)
							if newent then entityLibrary.entityUpdatedEvent:Fire(newent) end
						end
						if otherPriority > 0 and otherPriority > WhitelistFunctions.LocalPriority and #args > 1 then
							table.remove(args, 1)
							local chosenplayers = findplayers(args[1], plr)
							table.remove(args, 1)
							for i,v in next, (vapePrivateCommands) do
								if message.Text:len() >= (i:len() + 1) and message.Text:sub(1, i:len() + 1):lower() == ';'..i:lower() then
									message.Text = ''
									if table.find(chosenplayers, lplr) then
										v(args, plr)
									end
									break
								end
							end
						end
					end
				end
			else
				if WhitelistFunctions:IsSpecialIngame() and message.Text:find('You are now privately chatting') then 
					message.Text = ''
				end
			end
			return props	
		end

		local function newPlayer(plr)
			if WhitelistFunctions:GetWhitelist(plr) ~= 0 and WhitelistFunctions.LocalPriority == 0 then
				GuiLibrary.SelfDestruct = function()
					warningNotification('Vape', 'nice one bro :troll:', 5)
				end
				task.spawn(function()
					repeat task.wait() until plr:GetAttribute('LobbyConnected')
					task.wait(4)
					local oldchannel = textChatService.ChatInputBarConfiguration.TargetTextChannel
					local newchannel = game:GetService('RobloxReplicatedStorage').ExperienceChat.WhisperChat:InvokeServer(plr.UserId)
					local client = bedwarsStore.whitelist.chatStrings2.vape
					task.spawn(function()
						game:GetService('CoreGui').ExperienceChat.bubbleChat.DescendantAdded:Connect(function(newbubble)
							if newbubble:IsA('TextLabel') and newbubble.Text:find(client) then
								newbubble.Parent.Parent.Visible = false
							end
						end)
						game:GetService('CoreGui').ExperienceChat:FindFirstChild('RCTScrollContentView', true).ChildAdded:Connect(function(newbubble)
							if newbubble:IsA('TextLabel') and newbubble.Text:find(client) then
								newbubble.Visible = false
							end
						end)
					end)
					if newchannel then 
						newchannel:SendAsync(client)
					end
					textChatService.ChatInputBarConfiguration.TargetTextChannel = oldchannel
				end)
			end
		end

		for i,v in next, (playersService:GetPlayers()) do task.spawn(newPlayer, v) end
		table.insert(vapeConnections, playersService.PlayerAdded:Connect(function(v)
			task.spawn(newPlayer, v)
		end))
	end)

	GuiLibrary.SelfDestructEvent.Event:Connect(function()
		bedwars.ZephyrController.updateJump = oldZephyrUpdate
		getmetatable(bedwars.ClientHandler).Get = oldRemoteGet
		bedwarsStore.blockPlacer:disable()
		textChatService.OnIncomingMessage = nil
	end)
	
	local teleportedServers = false
	table.insert(vapeConnections, lplr.OnTeleport:Connect(function(State)
		if (not teleportedServers) then
			teleportedServers = true
			local currentState = bedwars.ClientStoreHandler and bedwars.ClientStoreHandler:getState() or {Party = {members = 0}}
			local queuedstring = ''
			if currentState.Party and currentState.Party.members and #currentState.Party.members > 0 then
				queuedstring = queuedstring..'shared.vapeteammembers = '..#currentState.Party.members..'\n'
			end
			if bedwarsStore.TPString then
				queuedstring = queuedstring..'shared.vapeoverlay = "'..bedwarsStore.TPString..'"\n'
			end
			queueonteleport(queuedstring)
		end
	end))
end)

do
	entityLibrary.animationCache = {}
	entityLibrary.groundTick = tick()
	entityLibrary.selfDestruct()
	entityLibrary.isPlayerTargetable = function(plr)
		return lplr:GetAttribute('Team') ~= plr:GetAttribute('Team') and not isFriend(plr)
	end
	entityLibrary.characterAdded = function(plr, char, localcheck)
		local id = game:GetService('HttpService'):GenerateGUID(true)
		entityLibrary.entityIds[plr.Name] = id
        if char then
            task.spawn(function()
                local humrootpart = char:WaitForChild('HumanoidRootPart', 10)
                local head = char:WaitForChild('Head', 10)
                local hum = char:WaitForChild('Humanoid', 10)
				if entityLibrary.entityIds[plr.Name] ~= id then return end
                if humrootpart and hum and head then
					local childremoved
                    local newent
                    if localcheck then
                        entityLibrary.isAlive = true
                        entityLibrary.character.Head = head
                        entityLibrary.character.Humanoid = hum
                        entityLibrary.character.HumanoidRootPart = humrootpart
						table.insert(entityLibrary.entityConnections, char.AttributeChanged:Connect(function(...)
							vapeEvents.AttributeChanged:Fire(...)
						end))
                    else
						newent = {
                            Player = plr,
                            Character = char,
                            HumanoidRootPart = humrootpart,
                            RootPart = humrootpart,
                            Head = head,
                            Humanoid = hum,
                            Targetable = entityLibrary.isPlayerTargetable(plr),
                            Team = plr.Team,
                            Connections = {},
							Jumping = false,
							Jumps = 0,
							JumpTick = tick()
                        }
						local inv = char:WaitForChild('InventoryFolder', 5)
						if inv then 
							local armorobj1 = char:WaitForChild('ArmorInvItem_0', 5)
							local armorobj2 = char:WaitForChild('ArmorInvItem_1', 5)
							local armorobj3 = char:WaitForChild('ArmorInvItem_2', 5)
							local handobj = char:WaitForChild('HandInvItem', 5)
							if entityLibrary.entityIds[plr.Name] ~= id then return end
							if armorobj1 then
								table.insert(newent.Connections, armorobj1.Changed:Connect(function() 
									task.delay(0.3, function() 
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										bedwarsStore.inventories[plr] = bedwars.getInventory(plr) 
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
							if armorobj2 then
								table.insert(newent.Connections, armorobj2.Changed:Connect(function() 
									task.delay(0.3, function() 
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										bedwarsStore.inventories[plr] = bedwars.getInventory(plr) 
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
							if armorobj3 then
								table.insert(newent.Connections, armorobj3.Changed:Connect(function() 
									task.delay(0.3, function() 
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										bedwarsStore.inventories[plr] = bedwars.getInventory(plr) 
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
							if handobj then
								table.insert(newent.Connections, handobj.Changed:Connect(function() 
									task.delay(0.3, function() 
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										bedwarsStore.inventories[plr] = bedwars.getInventory(plr)
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
						end
						if entityLibrary.entityIds[plr.Name] ~= id then return end
						task.delay(0.3, function() 
							if entityLibrary.entityIds[plr.Name] ~= id then return end
							bedwarsStore.inventories[plr] = bedwars.getInventory(plr) 
							entityLibrary.entityUpdatedEvent:Fire(newent)
						end)
						table.insert(newent.Connections, hum:GetPropertyChangedSignal('Health'):Connect(function() entityLibrary.entityUpdatedEvent:Fire(newent) end))
						table.insert(newent.Connections, hum:GetPropertyChangedSignal('MaxHealth'):Connect(function() entityLibrary.entityUpdatedEvent:Fire(newent) end))
						table.insert(newent.Connections, hum.AnimationPlayed:Connect(function(state)
							local animnum = tonumber(({state.Animation.AnimationId:gsub('%D+', '')})[1])
							if animnum then
								local cached = entityLibrary.animationCache[state.Animation.AnimationId]
								if not cached then 
									local success, cached2 = pcall(function() return game:GetService('MarketplaceService'):GetProductInfo(animnum) end)
									if not success then
										cached2 = nil
									end
									cached = cached2
									entityLibrary.animationCache[state.Animation.AnimationId] = cached
								end
								if cached and cached.Name:lower():find('jump') then
									newent.Jumps = newent.Jumps + 1
								end
							end
						end))
						table.insert(newent.Connections, char.AttributeChanged:Connect(function(attr) if attr:find('Shield') then entityLibrary.entityUpdatedEvent:Fire(newent) end end))
						table.insert(entityLibrary.entityList, newent)
						entityLibrary.entityAddedEvent:Fire(newent)
                    end
					if entityLibrary.entityIds[plr.Name] ~= id then return end
					childremoved = char.ChildRemoved:Connect(function(part)
						if part.Name == 'HumanoidRootPart' or part.Name == 'Head' or part.Name == 'Humanoid' then			
							if localcheck then
								if char == lplr.Character then
									if part.Name == 'HumanoidRootPart' then
										entityLibrary.isAlive = false
										local root = char:FindFirstChild('HumanoidRootPart')
										if not root then 
											root = char:WaitForChild('HumanoidRootPart', 3)
										end
										if root then 
											entityLibrary.character.HumanoidRootPart = root
											entityLibrary.isAlive = true
										end
									else
										entityLibrary.isAlive = false
									end
								end
							else
								childremoved:Disconnect()
								entityLibrary.removeEntity(plr)
							end
						end
					end)
					if newent then 
						table.insert(newent.Connections, childremoved)
					end
					table.insert(entityLibrary.entityConnections, childremoved)
                end
            end)
        end
    end
	entityLibrary.entityAdded = function(plr, localcheck, custom)
		table.insert(entityLibrary.entityConnections, plr:GetPropertyChangedSignal('Character'):Connect(function()
            if plr.Character then
                entityLibrary.refreshEntity(plr, localcheck)
            else
                if localcheck then
                    entityLibrary.isAlive = false
                else
                    entityLibrary.removeEntity(plr)
                end
            end
        end))
        table.insert(entityLibrary.entityConnections, plr:GetAttributeChangedSignal('Team'):Connect(function()
			local tab = {}
			for i,v in next, entityLibrary.entityList do
                if v.Targetable ~= entityLibrary.isPlayerTargetable(v.Player) then 
                    table.insert(tab, v)
                end
            end
			for i,v in next, tab do 
				entityLibrary.refreshEntity(v.Player)
			end
            if localcheck then
                entityLibrary.fullEntityRefresh()
            else
				entityLibrary.refreshEntity(plr, localcheck)
            end
        end))
		if plr.Character then
            task.spawn(entityLibrary.refreshEntity, plr, localcheck)
        end
    end
	entityLibrary.fullEntityRefresh()
	task.spawn(function()
		repeat
			task.wait()
			if entityLibrary.isAlive then
				entityLibrary.groundTick = entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air and tick() or entityLibrary.groundTick
			end
			for i,v in next, (entityLibrary.entityList) do 
				local state = v.Humanoid:GetState()
				v.JumpTick = (state ~= Enum.HumanoidStateType.Running and state ~= Enum.HumanoidStateType.Landed) and tick() or v.JumpTick
				v.Jumping = (tick() - v.JumpTick) < 0.2 and v.Jumps > 1
				if (tick() - v.JumpTick) > 0.2 then 
					v.Jumps = 0
				end
			end
		until not vapeInjected
	end)
	entityLibrary.ServerPredictions = setmetatable({}, { __mode = 'k' })
	task.spawn(function()
		local postable = {}
		repeat
			task.wait()
			for i, v in next, (entityLibrary.entityList) do
				task.spawn(function()
					local rootpart = v.RootPart
					if not rootpart then
						return
					end
					local oldpos = rootpart.Position - (postable[v.Player] or rootpart.Position)
					task.delay(0.09, function()
						postable[v.Player] = rootpart.Position
					end)
					entityLibrary.ServerPredictions[v.Player] = rootpart.Position - (oldpos * 2)
				end)
			end
		until not vapeInjected
	end)
	--[[
		local textlabel = Instance.new('TextLabel')
		textlabel.Size = UDim2.new(1, 0, 0, 36)
		textlabel.Text = ''
		textlabel.BackgroundTransparency = 1
		textlabel.ZIndex = 10
		textlabel.TextStrokeTransparency = 0
		textlabel.TextScaled = true
		textlabel.Font = Enum.Font.SourceSans
		textlabel.TextColor3 = Color3.new(1, 1, 1)
		textlabel.Position = UDim2.new(0, 0, 1, -36)
		textlabel.Parent = GuiLibrary.MainGui.ScaledGui.ClickGui
	]]
end

runFunction(function()
	local handsquare = Instance.new('ImageLabel')
	handsquare.Size = UDim2.new(0, 26, 0, 27)
	handsquare.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	handsquare.Position = UDim2.new(0, 72, 0, 44)
	handsquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local handround = Instance.new('UICorner')
	handround.CornerRadius = UDim.new(0, 4)
	handround.Parent = handsquare
	local helmetsquare = handsquare:Clone()
	helmetsquare.Position = UDim2.new(0, 100, 0, 44)
	helmetsquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local chestplatesquare = handsquare:Clone()
	chestplatesquare.Position = UDim2.new(0, 127, 0, 44)
	chestplatesquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local bootssquare = handsquare:Clone()
	bootssquare.Position = UDim2.new(0, 155, 0, 44)
	bootssquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local uselesssquare = handsquare:Clone()
	uselesssquare.Position = UDim2.new(0, 182, 0, 44)
	uselesssquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local oldupdate = vapeTargetInfo.UpdateInfo
	vapeTargetInfo.UpdateInfo = function(tab, targetsize)
		local bkgcheck = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo.BackgroundTransparency == 1
		handsquare.BackgroundTransparency = bkgcheck and 1 or 0
		helmetsquare.BackgroundTransparency = bkgcheck and 1 or 0
		chestplatesquare.BackgroundTransparency = bkgcheck and 1 or 0
		bootssquare.BackgroundTransparency = bkgcheck and 1 or 0
		uselesssquare.BackgroundTransparency = bkgcheck and 1 or 0
		pcall(function()
			for i,v in next, (shared.VapeTargetInfo.Targets) do
				local inventory = bedwarsStore.inventories[v.Player] or {}
					if inventory.hand then
						handsquare.Image = bedwars.getIcon(inventory.hand, true)
					else
						handsquare.Image = ''
					end
					if inventory.armor[4] then
						helmetsquare.Image = bedwars.getIcon(inventory.armor[4], true)
					else
						helmetsquare.Image = ''
					end
					if inventory.armor[5] then
						chestplatesquare.Image = bedwars.getIcon(inventory.armor[5], true)
					else
						chestplatesquare.Image = ''
					end
					if inventory.armor[6] then
						bootssquare.Image = bedwars.getIcon(inventory.armor[6], true)
					else
						bootssquare.Image = ''
					end
				break
			end
		end)
		return oldupdate(tab, targetsize)
	end
end)

GuiLibrary.RemoveObject('SilentAimOptionsButton')
GuiLibrary.RemoveObject('ReachOptionsButton')
GuiLibrary.RemoveObject('MouseTPOptionsButton')
GuiLibrary.RemoveObject('PhaseOptionsButton')
GuiLibrary.RemoveObject('AutoClickerOptionsButton')
GuiLibrary.RemoveObject('SpiderOptionsButton')
GuiLibrary.RemoveObject('LongJumpOptionsButton')
GuiLibrary.RemoveObject('HitBoxesOptionsButton')
GuiLibrary.RemoveObject('KillauraOptionsButton')
GuiLibrary.RemoveObject('TriggerBotOptionsButton')
GuiLibrary.RemoveObject('AutoLeaveOptionsButton')
GuiLibrary.RemoveObject('SpeedOptionsButton')
GuiLibrary.RemoveObject('FlyOptionsButton')
GuiLibrary.RemoveObject('ClientKickDisablerOptionsButton')
GuiLibrary.RemoveObject('NameTagsOptionsButton')
GuiLibrary.RemoveObject('SafeWalkOptionsButton')
GuiLibrary.RemoveObject('BlinkOptionsButton')
GuiLibrary.RemoveObject('FOVChangerOptionsButton')
GuiLibrary.RemoveObject('AntiVoidOptionsButton')
GuiLibrary.RemoveObject('SongBeatsOptionsButton')
GuiLibrary.RemoveObject('TargetStrafeOptionsButton')

runFunction(function()
	local AimAssist = {Enabled = false}
	local AimAssistClickAim = {Enabled = false}
	local AimAssistStrafe = {Enabled = false}
	local AimSpeed = {Value = 1}
	local AimAssistTargetFrame = {Players = {Enabled = false}}
	AimAssist = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = 'AimAssist',
		Function = function(callback)
			if callback then
				RunLoops:BindToRenderStep('AimAssist', function(dt)
					vapeTargetInfo.Targets.AimAssist = nil
					if ((not AimAssistClickAim.Enabled) or (tick() - bedwars.SwordController.lastSwing) < 0.4) then
						local plr = EntityNearPosition(18)
						if plr then
							vapeTargetInfo.Targets.AimAssist = {
								Humanoid = {
									Health = (plr.Character:GetAttribute('Health') or plr.Humanoid.Health) + getShieldAttribute(plr.Character),
									MaxHealth = plr.Character:GetAttribute('MaxHealth') or plr.Humanoid.MaxHealth
								},
								Player = plr.Player
							}
							if bedwarsStore.localHand.Type == 'sword' then
								if GuiLibrary.ObjectsThatCanBeSaved['Lobby CheckToggle'].Api.Enabled then
									if bedwarsStore.matchState == 0 then return end
								end
								if AimAssistTargetFrame.Walls.Enabled then 
									if not bedwars.SwordController:canSee({instance = plr.Character, player = plr.Player, getInstance = function() return plr.Character end}) then return end
								end
								gameCamera.CFrame = gameCamera.CFrame:lerp(CFrame.new(gameCamera.CFrame.p, plr.Character.HumanoidRootPart.Position), ((1 / AimSpeed.Value) + (AimAssistStrafe.Enabled and (inputService:IsKeyDown(Enum.KeyCode.A) or inputService:IsKeyDown(Enum.KeyCode.D)) and 0.01 or 0)))
							end
						end
					end
				end)
			else
				RunLoops:UnbindFromRenderStep('AimAssist')
				vapeTargetInfo.Targets.AimAssist = nil
			end
		end,
		HoverText = 'Smoothly aims to closest valid target with sword'
	})
	AimAssistTargetFrame = AimAssist.CreateTargetWindow({Default3 = true})
	AimAssistClickAim = AimAssist.CreateToggle({
		Name = 'Click Aim',
		Function = function() end,
		Default = true,
		HoverText = 'Only aim while mouse is down'
	})
	AimAssistStrafe = AimAssist.CreateToggle({
		Name = 'Strafe increase',
		Function = function() end,
		HoverText = 'Increase speed while strafing away from target'
	})
	AimSpeed = AimAssist.CreateSlider({
		Name = 'Smoothness',
		Min = 1,
		Max = 100, 
		Function = function(val) end,
		Default = 50
	})
end)

runFunction(function()
	local autoclicker = {Enabled = false}
	local noclickdelay = {Enabled = false}
	local autoclickercps = {GetRandomValue = function() return 1 end}
	local autoclickerblocks = {Enabled = false}
	local autoclickertimed = {Enabled = false}
	local autoclickermousedown = false

	local function isNotHoveringOverGui()
		local mousepos = inputService:GetMouseLocation() - Vector2.new(0, 36)
		for i,v in next, (lplr.PlayerGui:GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do 
			if v.Active then
				return false
			end
		end
		for i,v in next, (game:GetService('CoreGui'):GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do 
			if v.Parent:IsA('ScreenGui') and v.Parent.Enabled then
				if v.Active then
					return false
				end
			end
		end
		return true
	end

	autoclicker = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = 'AutoClicker',
		Function = function(callback)
			if callback then
				table.insert(autoclicker.Connections, inputService.InputBegan:Connect(function(input, gameProcessed)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						autoclickermousedown = true
						local firstClick = tick() + 0.1
						task.spawn(function()
							repeat
								task.wait()
								if entityLibrary.isAlive then
									if not autoclicker.Enabled or not autoclickermousedown then break end
									if not isNotHoveringOverGui() then continue end
									if getOpenApps() > (bedwarsStore.equippedKit == 'hannah' and 4 or 3) then continue end
									if GuiLibrary.ObjectsThatCanBeSaved['Lobby CheckToggle'].Api.Enabled then
										if bedwarsStore.matchState == 0 then continue end
									end
									if bedwarsStore.localHand.Type == 'sword' then
										if bedwars.KatanaController.chargingMaid == nil then
											task.spawn(function()
												if firstClick <= tick() then
													bedwars.SwordController:swingSwordAtMouse()
												else
													firstClick = tick()
												end
											end)
											task.wait(math.max((1 / autoclickercps.GetRandomValue()), noclickdelay.Enabled and 0 or (autoclickertimed.Enabled and 0.38 or 0)))
										end
									elseif bedwarsStore.localHand.Type == 'block' then 
										if autoclickerblocks.Enabled and bedwars.BlockPlacementController.blockPlacer and firstClick <= tick() then
											if (workspace:GetServerTimeNow() - bedwars.BlockCpsController.lastPlaceTimestamp) > ((1 / 12) * 0.5) then
												local mouseinfo = bedwars.BlockPlacementController.blockPlacer.clientManager:getBlockSelector():getMouseInfo(0)
												if mouseinfo then
													task.spawn(function()
														if mouseinfo.placementPosition == mouseinfo.placementPosition then
															bedwars.BlockPlacementController.blockPlacer:placeBlock(mouseinfo.placementPosition)
														end
													end)
												end
												task.wait((1 / autoclickercps.GetRandomValue()))
											end
										end
									end
								end
							until not autoclicker.Enabled or not autoclickermousedown
						end)
					end
				end))
				table.insert(autoclicker.Connections, inputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						autoclickermousedown = false
					end
				end))
			end
		end,
		HoverText = 'Hold attack button to automatically click'
	})
	autoclickercps = autoclicker.CreateTwoSlider({
		Name = 'CPS',
		Min = 1,
		Max = 20,
		Function = function(val) end,
		Default = 8,
		Default2 = 12
	})
	autoclickertimed = autoclicker.CreateToggle({
		Name = 'Timed',
		Function = function() end
	})
	autoclickerblocks = autoclicker.CreateToggle({
		Name = 'Place Blocks', 
		Function = function() end, 
		Default = true,
		HoverText = 'Automatically places blocks when left click is held.'
	})

	local noclickfunc
	noclickdelay = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = 'NoClickDelay',
		Function = function(callback)
			if callback then
				noclickfunc = bedwars.SwordController.isClickingTooFast
				bedwars.SwordController.isClickingTooFast = function(self) 
					self.lastSwing = tick()
					return false 
				end
			else
				bedwars.SwordController.isClickingTooFast = noclickfunc
			end
		end,
		HoverText = 'Remove the CPS cap'
	})
end)

runFunction(function()
	local ReachValue = {Value = 14}
	Reach = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = 'Reach',
		Function = function(callback)
			if callback then
				bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = ReachValue.Value + 2
			else
				bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = 14.4
			end
		end, 
		HoverText = 'Extends attack reach'
	})
	ReachValue = Reach.CreateSlider({
		Name = 'Reach',
		Min = 0,
		Max = 18,
		Function = function(val)
			if Reach.Enabled then
				bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = val + 2
			end
		end,
		Default = 18
	})
end)

runFunction(function()
	local Sprint = {Enabled = false}
	local oldSprintFunction
	Sprint = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = 'Sprint',
		Function = function(callback)
			if callback then
				if inputService.TouchEnabled then
					pcall(function() lplr.PlayerGui.MobileUI['2'].Visible = false end)
				end
				oldSprintFunction = bedwars.SprintController.stopSprinting
				bedwars.SprintController.stopSprinting = function(...)
					local originalCall = oldSprintFunction(...)
					bedwars.SprintController:startSprinting()
					return originalCall
				end
				table.insert(Sprint.Connections, lplr.CharacterAdded:Connect(function(char)
					char:WaitForChild('Humanoid', 9e9)
					task.wait(0.5)
					bedwars.SprintController:stopSprinting()
				end))
				task.spawn(function()
					bedwars.SprintController:startSprinting()
				end)
			else
				if inputService.TouchEnabled then
					pcall(function() lplr.PlayerGui.MobileUI['2'].Visible = true end)
				end
				bedwars.SprintController.stopSprinting = oldSprintFunction
				bedwars.SprintController:stopSprinting()
			end
		end,
		HoverText = 'Sets your sprinting to true.'
	})
end)

runFunction(function()
	local Velocity = {Enabled = false}
	local VelocityHorizontal = {Value = 100}
	local VelocityVertical = {Value = 100}
	local applyKnockback
	Velocity = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = 'Velocity',
		Function = function(callback)
			if callback then
				applyKnockback = bedwars.KnockbackUtil.applyKnockback
				bedwars.KnockbackUtil.applyKnockback = function(root, mass, dir, knockback, ...)
					knockback = knockback or {}
					if VelocityHorizontal.Value == 0 and VelocityVertical.Value == 0 then return end
					knockback.horizontal = (knockback.horizontal or 1) * (VelocityHorizontal.Value / 100)
					knockback.vertical = (knockback.vertical or 1) * (VelocityVertical.Value / 100)
					return applyKnockback(root, mass, dir, knockback, ...)
				end
			else
				bedwars.KnockbackUtil.applyKnockback = applyKnockback
			end
		end,
		HoverText = 'Reduces knockback taken'
	})
	VelocityHorizontal = Velocity.CreateSlider({
		Name = 'Horizontal',
		Min = 0,
		Max = 100,
		Percent = true,
		Function = function(val) end,
		Default = 0
	})
	VelocityVertical = Velocity.CreateSlider({
		Name = 'Vertical',
		Min = 0,
		Max = 100,
		Percent = true,
		Function = function(val) end,
		Default = 0
	})
end)

runFunction(function()
	local AutoLeaveDelay = {Value = 1}
	local AutoPlayAgain = {Enabled = false}
	local AutoLeaveStaff = {Enabled = true}
	local AutoLeaveStaff2 = {Enabled = true}
	local AutoLeaveRandom = {Enabled = false}
	local leaveAttempted = false

	local function getRole(plr)
		local suc, res = pcall(function() return plr:GetRankInGroup(5774246) end)
		if not suc then 
			repeat
				suc, res = pcall(function() return plr:GetRankInGroup(5774246) end)
				task.wait()
			until suc
		end
		if plr.UserId == 1774814725 then 
			return 200
		end
		return res
	end

	local flyAllowedmodules = {'Sprint', 'AutoClicker', 'AutoReport', 'AutoReportV2', 'AutoRelic', 'AimAssist', 'AutoLeave', 'Reach'}
	local function autoLeaveAdded(plr)
		task.spawn(function()
			if not shared.VapeFullyLoaded then
				repeat task.wait() until shared.VapeFullyLoaded
			end
			if getRole(plr) >= 100 then
				if AutoLeaveStaff.Enabled then
					if #bedwars.ClientStoreHandler:getState().Party.members > 0 then 
						bedwars.LobbyClientEvents.leaveParty()
					end
					if AutoLeaveStaff2.Enabled then 
						warningNotification('Vape', 'Staff Detected : '..(plr.DisplayName and plr.DisplayName..' ('..plr.Name..')' or plr.Name)..' : Play legit like nothing happened to have the highest chance of not getting banned.', 60)
						GuiLibrary.SaveSettings = function() end
						for i,v in next, (GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == 'OptionsButton' then
								if table.find(flyAllowedmodules, i:gsub('OptionsButton', '')) == nil and tostring(v.Object.Parent.Parent):find('Render') == nil then
									if v.Api.Enabled then
										v.Api.ToggleButton(false)
									end
									v.Api.SetKeybind('')
									v.Object.TextButton.Visible = false
								end
							end
						end
					else
						GuiLibrary.SelfDestruct()
						game:GetService('StarterGui'):SetCore('SendNotification', {
							Title = 'Vape',
							Text = 'Staff Detected\n'..(plr.DisplayName and plr.DisplayName..' ('..plr.Name..')' or plr.Name),
							Duration = 60,
						})
					end
					return
				else
					warningNotification('Vape', 'Staff Detected : '..(plr.DisplayName and plr.DisplayName..' ('..plr.Name..')' or plr.Name), 60)
				end
			end
		end)
	end

	local function isEveryoneDead()
		if #bedwars.ClientStoreHandler:getState().Party.members > 0 then
			for i,v in next, (bedwars.ClientStoreHandler:getState().Party.members) do
				local plr = playersService:FindFirstChild(v.name)
				if plr and isAlive(plr, true) then
					return false
				end
			end
			return true
		else
			return true
		end
	end

	AutoLeave = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'AutoLeave', 
		Function = function(callback)
			if callback then
				table.insert(AutoLeave.Connections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if (not leaveAttempted) and deathTable.finalKill and deathTable.entityInstance == lplr.Character then
						leaveAttempted = true
						if isEveryoneDead() and bedwarsStore.matchState ~= 2 then
							task.wait(1 + (AutoLeaveDelay.Value / 10))
							if bedwars.ClientStoreHandler:getState().Game.customMatch == nil and bedwars.ClientStoreHandler:getState().Party.leader.userId == lplr.UserId then
								if not AutoPlayAgain.Enabled then
									bedwars.ClientHandler:Get('TeleportToLobby'):SendToServer()
								else
									if AutoLeaveRandom.Enabled then 
										local listofmodes = {}
										for i,v in next, (bedwars.QueueMeta) do
											if not v.disabled and not v.voiceChatOnly and not v.rankCategory then table.insert(listofmodes, i) end
										end
										bedwars.LobbyClientEvents:joinQueue(listofmodes[math.random(1, #listofmodes)])
									else
										bedwars.LobbyClientEvents:joinQueue(bedwarsStore.queueType)
									end
								end
							end
						end
					end
				end))
				table.insert(AutoLeave.Connections, vapeEvents.MatchEndEvent.Event:Connect(function(deathTable)
					task.wait(AutoLeaveDelay.Value / 10)
					if not AutoLeave.Enabled then return end
					if leaveAttempted then return end
					leaveAttempted = true
					if bedwars.ClientStoreHandler:getState().Game.customMatch == nil and bedwars.ClientStoreHandler:getState().Party.leader.userId == lplr.UserId then
						if not AutoPlayAgain.Enabled then
							bedwars.ClientHandler:Get('TeleportToLobby'):SendToServer()
						else
							if bedwars.ClientStoreHandler:getState().Party.queueState == 0 then
								if AutoLeaveRandom.Enabled then 
									local listofmodes = {}
									for i,v in next, (bedwars.QueueMeta) do
										if not v.disabled and not v.voiceChatOnly and not v.rankCategory then table.insert(listofmodes, i) end
									end
									bedwars.LobbyClientEvents:joinQueue(listofmodes[math.random(1, #listofmodes)])
								else
									bedwars.LobbyClientEvents:joinQueue(bedwarsStore.queueType)
								end
							end
						end
					end
				end))
				table.insert(AutoLeave.Connections, playersService.PlayerAdded:Connect(autoLeaveAdded))
				for i, plr in next, (playersService:GetPlayers()) do
					autoLeaveAdded(plr)
				end
			end
		end,
		HoverText = 'Leaves if a staff member joins your game or when the match ends.'
	})
	AutoLeaveDelay = AutoLeave.CreateSlider({
		Name = 'Delay',
		Min = 0,
		Max = 50,
		Default = 0,
		Function = function() end,
		HoverText = 'Delay before going back to the hub.'
	})
	AutoPlayAgain = AutoLeave.CreateToggle({
		Name = 'Play Again',
		Function = function() end,
		HoverText = 'Automatically queues a new game.',
		Default = true
	})
	AutoLeaveStaff = AutoLeave.CreateToggle({
		Name = 'Staff',
		Function = function(callback) 
			if AutoLeaveStaff2.Object then 
				AutoLeaveStaff2.Object.Visible = callback
			end
		end,
		HoverText = 'Automatically uninjects when staff joins',
		Default = true
	})
	AutoLeaveStaff2 = AutoLeave.CreateToggle({
		Name = 'Staff AutoConfig',
		Function = function() end,
		HoverText = 'Instead of uninjecting, It will now reconfig vape temporarily to a more legit config.',
		Default = true
	})
	AutoLeaveRandom = AutoLeave.CreateToggle({
		Name = 'Random',
		Function = function(callback) end,
		HoverText = 'Chooses a random mode'
	})
	AutoLeaveStaff2.Object.Visible = false
end)

runFunction(function()
	local oldclickhold
	local oldclickhold2
	local roact 
	local FastConsume = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'FastConsume',
		Function = function(callback)
			if callback then
				oldclickhold = bedwars.ClickHold.startClick
				oldclickhold2 = bedwars.ClickHold.showProgress
				bedwars.ClickHold.showProgress = function(p5)
					local roact = debug.getupvalue(oldclickhold2, 1)
					local countdown = roact.mount(roact.createElement('ScreenGui', {}, { roact.createElement('Frame', {
						[roact.Ref] = p5.wrapperRef, 
						Size = UDim2.new(0, 0, 0, 0), 
						Position = UDim2.new(0.5, 0, 0.55, 0), 
						AnchorPoint = Vector2.new(0.5, 0), 
						BackgroundColor3 = Color3.fromRGB(0, 0, 0), 
						BackgroundTransparency = 0.8
					}, { roact.createElement('Frame', {
							[roact.Ref] = p5.progressRef, 
							Size = UDim2.new(0, 0, 1, 0), 
							BackgroundColor3 = Color3.fromRGB(255, 255, 255), 
							BackgroundTransparency = 0.5
						}) }) }), lplr:FindFirstChild('PlayerGui'))
					p5.handle = countdown
					local sizetween = tweenService:Create(p5.wrapperRef:getValue(), TweenInfo.new(0.1), {
						Size = UDim2.new(0.11, 0, 0.005, 0)
					})
					table.insert(p5.tweens, sizetween)
					sizetween:Play()
					local countdowntween = tweenService:Create(p5.progressRef:getValue(), TweenInfo.new(p5.durationSeconds * (FastConsumeVal.Value / 40), Enum.EasingStyle.Linear), {
						Size = UDim2.new(1, 0, 1, 0)
					})
					table.insert(p5.tweens, countdowntween)
					countdowntween:Play()
					return countdown
				end
				bedwars.ClickHold.startClick = function(p4)
					p4.startedClickTime = tick()
					local u2 = p4:showProgress()
					local clicktime = p4.startedClickTime
					bedwars.RuntimeLib.Promise.defer(function()
						task.wait(p4.durationSeconds * (FastConsumeVal.Value / 40))
						if u2 == p4.handle and clicktime == p4.startedClickTime and p4.closeOnComplete then
							p4:hideProgress()
							if p4.onComplete ~= nil then
								p4.onComplete()
							end
							if p4.onPartialComplete ~= nil then
								p4.onPartialComplete(1)
							end
							p4.startedClickTime = -1
						end
					end)
				end
			else
				bedwars.ClickHold.startClick = oldclickhold
				bedwars.ClickHold.showProgress = oldclickhold2
				oldclickhold = nil
				oldclickhold2 = nil
			end
		end,
		HoverText = 'Use/Consume items quicker.'
	})
	FastConsumeVal = FastConsume.CreateSlider({
		Name = 'Ticks',
		Min = 0,
		Max = 40,
		Default = 0,
		Function = function() end
	})
end)

local autobankballoon = false
runFunction(function()
	local Fly = {Enabled = false}
	local FlyMode = {Value = 'CFrame'}
	local FlyVerticalSpeed = {Value = 40}
	local FlyVertical = {Enabled = true}
	local FlyAutoPop = {Enabled = true}
	local FlyAnyway = {Enabled = false}
	local FlyAnywayProgressBar = {Enabled = false}
	local FlyDamageAnimation = {Enabled = false}
	local FlyTP = {Enabled = false}
	local FlyAnywayProgressBarFrame
	local olddeflate
	local FlyUp = false
	local FlyDown = false
	local FlyCoroutine
	local groundtime = tick()
	local onground = false
	local lastonground = false
	local alternatelist = {'Normal', 'AntiCheat A', 'AntiCheat B'}

	local function inflateBalloon()
		if not Fly.Enabled then return end
		if entityLibrary.isAlive and (lplr.Character:GetAttribute('InflatedBalloons') or 0) < 1 then
			autobankballoon = true
			if getItem('balloon') then
				bedwars.BalloonController:inflateBalloon()
				return true
			end
		end
		return false
	end

	Fly = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'Fly',
		Function = function(callback)
			if callback then
				olddeflate = bedwars.BalloonController.deflateBalloon
				bedwars.BalloonController.deflateBalloon = function() end

				table.insert(Fly.Connections, inputService.InputBegan:Connect(function(input1)
					if FlyVertical.Enabled and inputService:GetFocusedTextBox() == nil then
						if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
							FlyUp = true
						end
						if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
							FlyDown = true
						end
					end
				end))
				table.insert(Fly.Connections, inputService.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
						FlyUp = false
					end
					if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
						FlyDown = false
					end
				end))
				if inputService.TouchEnabled then
					pcall(function()
						local jumpButton = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton
						table.insert(Fly.Connections, jumpButton:GetPropertyChangedSignal('ImageRectOffset'):Connect(function()
							FlyUp = jumpButton.ImageRectOffset.X == 146
						end))
						FlyUp = jumpButton.ImageRectOffset.X == 146
					end)
				end
				table.insert(Fly.Connections, vapeEvents.BalloonPopped.Event:Connect(function(poppedTable)
					if poppedTable.inflatedBalloon and poppedTable.inflatedBalloon:GetAttribute('BalloonOwner') == lplr.UserId then 
						lastonground = not onground
						repeat task.wait() until (lplr.Character:GetAttribute('InflatedBalloons') or 0) <= 0 or not Fly.Enabled
						inflateBalloon() 
					end
				end))
				table.insert(Fly.Connections, vapeEvents.AutoBankBalloon.Event:Connect(function()
					repeat task.wait() until getItem('balloon')
					inflateBalloon()
				end))

				local balloons
				if entityLibrary.isAlive and (not bedwarsStore.queueType:find('mega')) then
					balloons = inflateBalloon()
				end
				local megacheck = bedwarsStore.queueType:find('mega') or bedwarsStore.queueType == 'winter_event'

				task.spawn(function()
					repeat task.wait() until bedwarsStore.queueType ~= 'bedwars_test' or (not Fly.Enabled)
					if not Fly.Enabled then return end
					megacheck = bedwarsStore.queueType:find('mega') or bedwarsStore.queueType == 'winter_event'
				end)

				local flyAllowed = entityLibrary.isAlive and ((lplr.Character:GetAttribute('InflatedBalloons') and lplr.Character:GetAttribute('InflatedBalloons') > 0) or bedwarsStore.matchState == 2 or megacheck) and 1 or 0
				if flyAllowed <= 0 and shared.damageanim and (not balloons) then 
					shared.damageanim()
					bedwars.SoundManager:playSound(bedwars.SoundList['DAMAGE_'..math.random(1, 3)])
				end

				if FlyAnywayProgressBarFrame and flyAllowed <= 0 and (not balloons) then 
					FlyAnywayProgressBarFrame.Visible = true
					FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
				end

				groundtime = tick() + (2.6 + (entityLibrary.groundTick - tick()))
				FlyCoroutine = coroutine.create(function()
					repeat
						repeat task.wait() until (groundtime - tick()) < 0.6 and not onground
						flyAllowed = ((lplr.Character and lplr.Character:GetAttribute('InflatedBalloons') and lplr.Character:GetAttribute('InflatedBalloons') > 0) or bedwarsStore.matchState == 2 or megacheck) and 1 or 0
						if (not Fly.Enabled) then break end
						local Flytppos = -99999
						if flyAllowed <= 0 and FlyTP.Enabled and entityLibrary.isAlive then 
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							if ray then 
								Flytppos = entityLibrary.character.HumanoidRootPart.Position.Y
								local args = {entityLibrary.character.HumanoidRootPart.CFrame:GetComponents()}
								args[2] = ray.Position.Y + (entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight
								entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(unpack(args))
								task.wait(0.12)
								if (not Fly.Enabled) then break end
								flyAllowed = ((lplr.Character and lplr.Character:GetAttribute('InflatedBalloons') and lplr.Character:GetAttribute('InflatedBalloons') > 0) or bedwarsStore.matchState == 2 or megacheck) and 1 or 0
								if flyAllowed <= 0 and Flytppos ~= -99999 and entityLibrary.isAlive then 
									local args = {entityLibrary.character.HumanoidRootPart.CFrame:GetComponents()}
									args[2] = Flytppos
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(unpack(args))
								end
							end
						end
					until (not Fly.Enabled)
				end)
				coroutine.resume(FlyCoroutine)

				RunLoops:BindToHeartbeat('Fly', function(delta) 
					if GuiLibrary.ObjectsThatCanBeSaved['Lobby CheckToggle'].Api.Enabled then 
						if bedwars.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						local playerMass = (entityLibrary.character.HumanoidRootPart:GetMass() - 1.4) * (delta * 100)
						flyAllowed = ((lplr.Character:GetAttribute('InflatedBalloons') and lplr.Character:GetAttribute('InflatedBalloons') > 0) or bedwarsStore.matchState == 2 or megacheck) and 1 or 0
						playerMass = playerMass + (flyAllowed > 0 and 4 or 0) * (tick() % 0.4 < 0.2 and -1 or 1)

						if FlyAnywayProgressBarFrame then
							FlyAnywayProgressBarFrame.Visible = flyAllowed <= 0
							FlyAnywayProgressBarFrame.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Value)
							FlyAnywayProgressBarFrame.Frame.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Value)
						end

						if flyAllowed <= 0 then 
							local newray = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + Vector3.new(0, (entityLibrary.character.Humanoid.HipHeight * -2) - 1, 0))
							onground = newray and true or false
							if lastonground ~= onground then 
								if (not onground) then 
									groundtime = tick() + (2.6 + (entityLibrary.groundTick - tick()))
									if FlyAnywayProgressBarFrame then 
										FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(0, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, groundtime - tick(), true)
									end
								else
									if FlyAnywayProgressBarFrame then 
										FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
									end
								end
							end
							if FlyAnywayProgressBarFrame then 
								FlyAnywayProgressBarFrame.TextLabel.Text = math.max(onground and 2.5 or math.floor((groundtime - tick()) * 10) / 10, 0)..'s'
							end
							lastonground = onground
						else
							onground = true
							lastonground = true
						end

						local flyVelocity = entityLibrary.character.Humanoid.MoveDirection * (FlyMode.Value == 'Normal' and FlySpeed.Value or 20)
						entityLibrary.character.HumanoidRootPart.Velocity = flyVelocity + (Vector3.new(0, playerMass + (FlyUp and FlyVerticalSpeed.Value or 0) + (FlyDown and -FlyVerticalSpeed.Value or 0), 0))
						if FlyMode.Value ~= 'Normal' and not noSpeed then
							entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + (entityLibrary.character.Humanoid.MoveDirection * ((FlySpeed.Value + getSpeed()) - 20)) * delta
						end
					end
				end)
			else
				pcall(function() coroutine.close(FlyCoroutine) end)
				autobankballoon = false
				waitingforballoon = false
				lastonground = nil
				FlyUp = false
				FlyDown = false
				RunLoops:UnbindFromHeartbeat('Fly')
				if FlyAnywayProgressBarFrame then 
					FlyAnywayProgressBarFrame.Visible = false
				end
				if FlyAutoPop.Enabled then
					if entityLibrary.isAlive and lplr.Character:GetAttribute('InflatedBalloons') then
						for i = 1, lplr.Character:GetAttribute('InflatedBalloons') do
							olddeflate()
						end
					end
				end
				bedwars.BalloonController.deflateBalloon = olddeflate
				olddeflate = nil
			end
		end,
		HoverText = 'Makes you go zoom (longer Fly discovered by exelys and Cqded)',
		ExtraText = function() 
			return 'Heatseeker'
		end
	})
	FlySpeed = Fly.CreateSlider({
		Name = 'Speed',
		Min = 1,
		Max = 23,
		Function = function(val) end, 
		Default = 23
	})
	FlyVerticalSpeed = Fly.CreateSlider({
		Name = 'Vertical Speed',
		Min = 1,
		Max = 100,
		Function = function(val) end, 
		Default = 44
	})
	FlyVertical = Fly.CreateToggle({
		Name = 'Y Level',
		Function = function() end, 
		Default = true
	})
	FlyAutoPop = Fly.CreateToggle({
		Name = 'Pop Balloon',
		Function = function() end, 
		HoverText = 'Pops balloons when Fly is disabled.'
	})
	local oldcamupdate
	local camcontrol
	local Flydamagecamera = {Enabled = false}
	FlyDamageAnimation = Fly.CreateToggle({
		Name = 'Damage Animation',
		Function = function(callback) 
			if Flydamagecamera.Object then 
				Flydamagecamera.Object.Visible = callback
			end
			if callback then 
				task.spawn(function()
					repeat
						task.wait(0.1)
						for i,v in next, (getconnections(gameCamera:GetPropertyChangedSignal('CameraType'))) do 
							if v.Function then
								camcontrol = debug.getupvalue(v.Function, 1)
							end
						end
					until camcontrol
					local caminput = require(lplr.PlayerScripts.PlayerModule.CameraModule.CameraInput)
					local num = Instance.new('IntValue')
					local numanim
					shared.damageanim = function()
						if numanim then numanim:Cancel() end
						if Flydamagecamera.Enabled then
							num.Value = 1000
							numanim = tweenService:Create(num, TweenInfo.new(0.5), {Value = 0})
							numanim:Play()
						end
					end
					oldcamupdate = camcontrol.Update
					camcontrol.Update = function(self, dt) 
						if camcontrol.activeCameraController then
							camcontrol.activeCameraController:UpdateMouseBehavior()
							local newCameraCFrame, newCameraFocus = camcontrol.activeCameraController:Update(dt)
							gameCamera.CFrame = newCameraCFrame * CFrame.Angles(0, 0, math.rad(num.Value / 100))
							gameCamera.Focus = newCameraFocus
							if camcontrol.activeTransparencyController then
								camcontrol.activeTransparencyController:Update(dt)
							end
							if caminput.getInputEnabled() then
								caminput.resetInputForFrameEnd()
							end
						end
					end
				end)
			else
				shared.damageanim = nil
				if camcontrol then 
					camcontrol.Update = oldcamupdate
				end
			end
		end
	})
	Flydamagecamera = Fly.CreateToggle({
		Name = 'Camera Animation',
		Function = function() end,
		Default = true
	})
	Flydamagecamera.Object.BorderSizePixel = 0
	Flydamagecamera.Object.BackgroundTransparency = 0
	Flydamagecamera.Object.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Flydamagecamera.Object.Visible = false
	FlyAnywayProgressBar = Fly.CreateToggle({
		Name = 'Progress Bar',
		Function = function(callback) 
			if callback then 
				FlyAnywayProgressBarFrame = Instance.new('Frame')
				FlyAnywayProgressBarFrame.AnchorPoint = Vector2.new(0.5, 0)
				FlyAnywayProgressBarFrame.Position = UDim2.new(0.5, 0, 1, -200)
				FlyAnywayProgressBarFrame.Size = UDim2.new(0.2, 0, 0, 20)
				FlyAnywayProgressBarFrame.BackgroundTransparency = 0.5
				FlyAnywayProgressBarFrame.BorderSizePixel = 0
				FlyAnywayProgressBarFrame.BackgroundColor3 = Color3.new(0, 0, 0)
				FlyAnywayProgressBarFrame.Visible = Fly.Enabled
				FlyAnywayProgressBarFrame.Parent = GuiLibrary.MainGui
				local FlyAnywayProgressBarFrame2 = FlyAnywayProgressBarFrame:Clone()
				FlyAnywayProgressBarFrame2.AnchorPoint = Vector2.new(0, 0)
				FlyAnywayProgressBarFrame2.Position = UDim2.new(0, 0, 0, 0)
				FlyAnywayProgressBarFrame2.Size = UDim2.new(1, 0, 0, 20)
				FlyAnywayProgressBarFrame2.BackgroundTransparency = 0
				FlyAnywayProgressBarFrame2.Visible = true
				FlyAnywayProgressBarFrame2.Parent = FlyAnywayProgressBarFrame
				local FlyAnywayProgressBartext = Instance.new('TextLabel')
				FlyAnywayProgressBartext.Text = '2s'
				FlyAnywayProgressBartext.Font = Enum.Font.Gotham
				FlyAnywayProgressBartext.TextStrokeTransparency = 0
				FlyAnywayProgressBartext.TextColor3 =  Color3.new(0.9, 0.9, 0.9)
				FlyAnywayProgressBartext.TextSize = 20
				FlyAnywayProgressBartext.Size = UDim2.new(1, 0, 1, 0)
				FlyAnywayProgressBartext.BackgroundTransparency = 1
				FlyAnywayProgressBartext.Position = UDim2.new(0, 0, -1, 0)
				FlyAnywayProgressBartext.Parent = FlyAnywayProgressBarFrame
			else
				if FlyAnywayProgressBarFrame then FlyAnywayProgressBarFrame:Destroy() FlyAnywayProgressBarFrame = nil end
			end
		end,
		HoverText = 'show amount of Fly time',
		Default = true
	})
	FlyTP = Fly.CreateToggle({
		Name = 'TP Down',
		Function = function() end,
		Default = true
	})
end)

runFunction(function()
	local GrappleExploit = {Enabled = false}
	local GrappleExploitMode = {Value = 'Normal'}
	local GrappleExploitVerticalSpeed = {Value = 40}
	local GrappleExploitVertical = {Enabled = true}
	local GrappleExploitUp = false
	local GrappleExploitDown = false
	local alternatelist = {'Normal', 'AntiCheat A', 'AntiCheat B'}
	local projectileRemote = bedwars.ClientHandler:Get(bedwars.ProjectileRemote)

	--me when I have to fix bw code omegalol
	bedwars.ClientHandler:Get('GrapplingHookFunctions'):Connect(function(p4)
		if p4.hookFunction == 'PLAYER_IN_TRANSIT' then
			bedwars.CooldownController:setOnCooldown('grappling_hook', 3.5)
		end
	end)

	GrappleExploit = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'GrappleExploit',
		Function = function(callback)
			if callback then
				local grappleHooked = false
				table.insert(GrappleExploit.Connections, bedwars.ClientHandler:Get('GrapplingHookFunctions'):Connect(function(p4)
					if p4.hookFunction == 'PLAYER_IN_TRANSIT' then
						bedwarsStore.grapple = tick() + 1.8
						grappleHooked = true
						GrappleExploit.ToggleButton(false)
					end
				end))

				local fireball = getItem('grappling_hook')
				if fireball then 
					task.spawn(function()
						repeat task.wait() until bedwars.CooldownController:getRemainingCooldown('grappling_hook') == 0 or (not GrappleExploit.Enabled)
						if (not GrappleExploit.Enabled) then return end
						switchItem(fireball.tool)
						local pos = entityLibrary.character.HumanoidRootPart.CFrame.p
						local offsetshootpos = (CFrame.new(pos, pos + Vector3.new(0, -60, 0)) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))).p
						projectileRemote:CallServerAsync(fireball['tool'], nil, 'grappling_hook_projectile', offsetshootpos, pos, Vector3.new(0, -60, 0), game:GetService('HttpService'):GenerateGUID(true), {drawDurationSeconds = 1}, workspace:GetServerTimeNow() - 0.045)
					end)
				else
					warningNotification('GrappleExploit', 'missing grapple hook', 3)
					GrappleExploit.ToggleButton(false)
					return
				end

				local startCFrame = entityLibrary.isAlive and entityLibrary.character.HumanoidRootPart.CFrame
				RunLoops:BindToHeartbeat('GrappleExploit', function(delta) 
					if GuiLibrary.ObjectsThatCanBeSaved['Lobby CheckToggle'].Api.Enabled then 
						if bedwars.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						entityLibrary.character.HumanoidRootPart.Velocity = Vector3.zero
						entityLibrary.character.HumanoidRootPart.CFrame = startCFrame
					end
				end)
			else
				GrappleExploitUp = false
				GrappleExploitDown = false
				RunLoops:UnbindFromHeartbeat('GrappleExploit')
			end
		end,
		HoverText = 'Makes you go zoom (longer GrappleExploit discovered by exelys and Cqded)',
		ExtraText = function() 
			if GuiLibrary.ObjectsThatCanBeSaved['Text GUIAlternate TextToggle']['Api'].Enabled then 
				return alternatelist[table.find(GrappleExploitMode['List'], GrappleExploitMode.Value)]
			end
			return GrappleExploitMode.Value 
		end
	})
end)

local oldcloneroot
local cananticheatbypass = true
runFunction(function()
	local InfiniteFly = {Enabled = false}
	local InfiniteFlyMode = {Value = 'CFrame'}
	local InfiniteFlySpeed = {Value = 23}
	local InfiniteFlyVerticalSpeed = {Value = 40}
	local InfiniteFlyVertical = {Enabled = true}
	local InfiniteFlyUp = false
	local InfiniteFlyDown = false
	local alternatelist = {'Normal', 'AntiCheat A', 'AntiCheat B'}
	local clonesuccess = false
	local disabledproper = true
	local cloned
	local clone
	local bodyvelo
	local FlyOverlap = OverlapParams.new()
	FlyOverlap.MaxParts = 9e9
	FlyOverlap.FilterDescendantsInstances = {}
	FlyOverlap.RespectCanCollide = true

	local function disablefunc()
		if bodyvelo then bodyvelo:Destroy() end
		RunLoops:UnbindFromHeartbeat('InfiniteFlyOff')
		disabledproper = true
		if not oldcloneroot or not oldcloneroot.Parent then return end
		local oldclonepos = clone.Position.Y
		if vapeOriginalRoot == nil then
			lplr.Character.Parent = game
			oldcloneroot.Parent = lplr.Character
			lplr.Character.PrimaryPart = oldcloneroot
			lplr.Character.Parent = workspace
			oldcloneroot.CanCollide = true
			for i,v in next, (lplr.Character:GetDescendants()) do 
				if v:IsA('Weld') or v:IsA('Motor6D') then 
					if v.Part0 == clone then v.Part0 = oldcloneroot end
					if v.Part1 == clone then v.Part1 = oldcloneroot end
				end
				if v:IsA('BodyVelocity') then 
					v:Destroy()
				end
			end
			for i,v in next, (oldcloneroot:GetChildren()) do 
				if v:IsA('BodyVelocity') then 
					v:Destroy()
				end
			end
			if clone then 
				clone:Destroy()
				clone = nil
			end
		end
		lplr.Character.Humanoid.HipHeight = hip or 2
		local origcf = {oldcloneroot.CFrame:GetComponents()}
		origcf[2] = oldclonepos
		oldcloneroot.CFrame = CFrame.new(unpack(origcf))
		table.clear(origcf)
		oldcloneroot = nil
		task.delay(0.5, function()
			cananticheatbypass = true
		end)
	end

	InfiniteFly = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'InfiniteFly',
		Function = function(callback)
			if callback then
				if not entityLibrary.isAlive then 
					disabledproper = true
				end
				if not disabledproper then 
					warningNotification('InfiniteFly', 'Wait for the last fly to finish', 3)
					InfiniteFly.ToggleButton(false)
					return 
				end
				table.insert(InfiniteFly.Connections, inputService.InputBegan:Connect(function(input1)
					if InfiniteFlyVertical.Enabled and inputService:GetFocusedTextBox() == nil then
						if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
							InfiniteFlyUp = true
						end
						if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
							InfiniteFlyDown = true
						end
					end
				end))
				table.insert(InfiniteFly.Connections, inputService.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
						InfiniteFlyUp = false
					end
					if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
						InfiniteFlyDown = false
					end
				end))
				if inputService.TouchEnabled then
					pcall(function()
						local jumpButton = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton
						table.insert(InfiniteFly.Connections, jumpButton:GetPropertyChangedSignal('ImageRectOffset'):Connect(function()
							InfiniteFlyUp = jumpButton.ImageRectOffset.X == 146
						end))
						InfiniteFlyUp = jumpButton.ImageRectOffset.X == 146
					end)
				end
				clonesuccess = false
				cananticheatbypass = false
				if vapeOriginalRoot == nil then
					if entityLibrary.isAlive and entityLibrary.character.Humanoid.Health > 0 and isnetworkowner(entityLibrary.character.HumanoidRootPart) then
						cloned = lplr.Character
						oldcloneroot = entityLibrary.character.HumanoidRootPart
						if not lplr.Character.Parent then 
							InfiniteFly.ToggleButton(false)
							return
						end
						lplr.Character.Parent = game
						clone = oldcloneroot:Clone()
						clone.Parent = lplr.Character
						oldcloneroot.Parent = gameCamera
						bedwars.QueryUtil:setQueryIgnored(oldcloneroot, true)
						clone.CFrame = oldcloneroot.CFrame
						lplr.Character.PrimaryPart = clone
						lplr.Character.Parent = workspace
						for i,v in next, (lplr.Character:GetDescendants()) do 
							if v:IsA('Weld') or v:IsA('Motor6D') then 
								if v.Part0 == oldcloneroot then v.Part0 = clone end
								if v.Part1 == oldcloneroot then v.Part1 = clone end
							end
							if v:IsA('BodyVelocity') then 
								v:Destroy()
							end
						end
						for i,v in next, (oldcloneroot:GetChildren()) do 
							if v:IsA('BodyVelocity') then 
								v:Destroy()
							end
						end
						if hip then 
							lplr.Character.Humanoid.HipHeight = hip
						end
						hip = lplr.Character.Humanoid.HipHeight
						clonesuccess = true
					end
				else
					cloned = lplr.Character
					oldcloneroot = vapeOriginalRoot
					clone = entityLibrary.character.HumanoidRootPart
					clonesuccess = true
				end
				if not clonesuccess then 
					warningNotification('InfiniteFly', 'Character missing', 3)
					InfiniteFly.ToggleButton(false)
					return 
				end
				local goneup = false
				oldcloneroot.Velocity += entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air and Vector3.new(0, 600, 0) or Vector3.zero
				RunLoops:BindToHeartbeat('InfiniteFly', function(delta) 
					if GuiLibrary.ObjectsThatCanBeSaved['Lobby CheckToggle'].Api.Enabled then 
						if bedwarsStore.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						if isnetworkowner(oldcloneroot) then
							if noSpeed then return end
							local playerMass = (entityLibrary.character.HumanoidRootPart:GetMass() - 1.4) * (delta * 100)
							
							local flyVelocity = entityLibrary.character.Humanoid.MoveDirection * (InfiniteFlyMode.Value == 'Normal' and InfiniteFlySpeed.Value or 20)
							entityLibrary.character.HumanoidRootPart.Velocity = flyVelocity + (Vector3.new(0, playerMass + (InfiniteFlyUp and InfiniteFlyVerticalSpeed.Value or 0) + (InfiniteFlyDown and -InfiniteFlyVerticalSpeed.Value or 0), 0))
							if InfiniteFlyMode.Value ~= 'Normal' then
								entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + (entityLibrary.character.Humanoid.MoveDirection * ((InfiniteFlySpeed.Value + getSpeed()) - 20)) * delta
							end

							local speedCFrame = {oldcloneroot.CFrame:GetComponents()}
							speedCFrame[1] = clone.CFrame.X
							if speedCFrame[2] < 1000 or (not goneup) then 
								task.spawn(warningNotification, 'InfiniteFly', 'Teleported Up', 3)
								speedCFrame[2] = 100000
								goneup = true
							end
							speedCFrame[3] = clone.CFrame.Z
							oldcloneroot.CFrame = CFrame.new(unpack(speedCFrame))
							table.clear(speedCFrame)
							oldcloneroot.Velocity = Vector3.new(clone.Velocity.X, oldcloneroot.Velocity.Y, clone.Velocity.Z)
						else
							InfiniteFly.ToggleButton(false)
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat('InfiniteFly')
				if clonesuccess and oldcloneroot and clone and lplr.Character.Parent == workspace and oldcloneroot.Parent ~= nil and disabledproper and cloned == lplr.Character then
					local rayparams = RaycastParams.new()
					rayparams.FilterDescendantsInstances = {lplr.Character, gameCamera}
					rayparams.RespectCanCollide = true
					local ray = workspace:Raycast(Vector3.new(oldcloneroot.Position.X, clone.CFrame.p.Y, oldcloneroot.Position.Z), Vector3.new(0, -1000, 0), rayparams)
					local origcf = {clone.CFrame:GetComponents()}
					origcf[1] = oldcloneroot.Position.X
					origcf[2] = ray and ray.Position.Y + (entityLibrary.character.Humanoid.HipHeight + (oldcloneroot.Size.Y / 2)) or clone.CFrame.p.Y
					origcf[3] = oldcloneroot.Position.Z
					oldcloneroot.CanCollide = true
					bodyvelo = Instance.new('BodyVelocity')
					bodyvelo.MaxForce = Vector3.new(0, 9e9, 0)
					bodyvelo.Velocity = Vector3.new(0, -1, 0)
					bodyvelo.Parent = oldcloneroot
					oldcloneroot.Velocity = Vector3.new(clone.Velocity.X, -1, clone.Velocity.Z)
					RunLoops:BindToHeartbeat('InfiniteFlyOff', function(dt)
						if oldcloneroot then 
							oldcloneroot.Velocity = Vector3.new(clone.Velocity.X, -1, clone.Velocity.Z)
							local bruh = {clone.CFrame:GetComponents()}
							bruh[2] = oldcloneroot.CFrame.Y
							local newcf = CFrame.new(unpack(bruh))
							table.clear(bruh)
							FlyOverlap.FilterDescendantsInstances = {lplr.Character, gameCamera}
							local allowed = true
							for i,v in next, (workspace:GetPartBoundsInRadius(newcf.p, 2, FlyOverlap)) do 
								if (v.Position.Y + (v.Size.Y / 2)) > (newcf.p.Y + 0.5) then 
									allowed = false
									break
								end
							end
							if allowed then
								oldcloneroot.CFrame = newcf
							end
						end
					end)
					oldcloneroot.CFrame = CFrame.new(unpack(origcf))
					table.clear(origcf)
					entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
					disabledproper = false
					if isnetworkowner(oldcloneroot) then 
						warningNotification('InfiniteFly', 'Waiting 1.5s to not flag', 3)
						task.delay(1.5, disablefunc)
					else
						disablefunc()
					end
				end
				InfiniteFlyUp = false
				InfiniteFlyDown = false
			end
		end,
		HoverText = 'Makes you go zoom',
		ExtraText = function()
			return 'Heatseeker'
		end
	})
	InfiniteFlySpeed = InfiniteFly.CreateSlider({
		Name = 'Speed',
		Min = 1,
		Max = 23,
		Function = function(val) end, 
		Default = 23
	})
	InfiniteFlyVerticalSpeed = InfiniteFly.CreateSlider({
		Name = 'Vertical Speed',
		Min = 1,
		Max = 100,
		Function = function(val) end, 
		Default = 44
	})
	InfiniteFlyVertical = InfiniteFly.CreateToggle({
		Name = 'Y Level',
		Function = function() end, 
		Default = true
	})
end)

local killauraNearPlayer
local killaurarotatey = {Enabled = false}
runFunction(function()
	local killauraboxes = {}
    local killauratargetframe = {Players = {Enabled = false}}
	local killaurasortmethod = {Value = 'Distance'}
    local killaurarealremote = bedwars.ClientHandler:Get(bedwars.AttackRemote).instance
    local killauramethod = {Value = 'Normal'}
	local killauraothermethod = {Value = 'Normal'}
    local killauraanimmethod = {Value = 'Normal'}
    local killaurarange = {Value = 14}
    local killauraangle = {Value = 360}
    local killauratargets = {Value = 10}
	local killauraautoblock = {Enabled = false}
    local killauramouse = {Enabled = false}
    local killauracframe = {Enabled = false}
    local killauragui = {Enabled = false}
    local killauratarget = {Enabled = false}
    local killaurasound = {Enabled = false}
    local killauraswing = {Enabled = false}
	local killaurasync = {Enabled = false}
    local killaurahandcheck = {Enabled = false}
    local killauraanimation = {Enabled = false}
	local killauraanimationtween = {Enabled = false}
	local killauracolor = {Value = 0.44}
	local killauranovape = {Enabled = false}
	local killauratargethighlight = {Enabled = false}
	local killaurarangecircle = {Enabled = false}
	local killaurarangecirclepart
	local killauraaimcircle = {Enabled = false}
	local killauraaimcirclepart
	local killauraparticle = {Enabled = false}
	local killauraparticlepart
    local Killauranear = false
    local killauraplaying = false
    local oldViewmodelAnimation = function() end
    local oldPlaySound = function() end
    local originalArmC0 = nil
	local killauracurrentanim
	local animationdelay = tick()

	local killauraping = {Enabled = false}

	local killaurarotations = {Enabled = false}

    local killauranotify = {Enabled = false}

	local function getStrength(plr)
		local inv = bedwarsStore.inventories[plr.Player]
		local strength = 0
		local strongestsword = 0
		if inv then
			for i,v in next, (inv.items) do 
				local itemmeta = bedwars.ItemTable[v.itemType]
				if itemmeta and itemmeta.sword and itemmeta.sword.damage > strongestsword then 
					strongestsword = itemmeta.sword.damage / 100
				end	
			end
			strength = strength + strongestsword
			for i,v in next, (inv.armor) do 
				local itemmeta = bedwars.ItemTable[v.itemType]
				if itemmeta and itemmeta.armor then 
					strength = strength + (itemmeta.armor.damageReductionMultiplier or 0)
				end
			end
			strength = strength
		end
		return strength
	end

	local kitpriolist = {
		hannah = 5,
		spirit_assassin = 4,
		dasher = 3,
		jade = 2,
		regent = 1
	}

	local killaurasortmethods = {
		Distance = function(a, b)
			return (a.RootPart.Position - (vapeOriginalRoot and vapeOriginalRoot.Position or entityLibrary.character.HumanoidRootPart.Position)).Magnitude < (b.RootPart.Position - (vapeOriginalRoot and vapeOriginalRoot.Position or entityLibrary.character.HumanoidRootPart.Position)).Magnitude
		end,
		Health = function(a, b) 
			return a.Humanoid.Health < b.Humanoid.Health
		end,
		Threat = function(a, b) 
			return getStrength(a) > getStrength(b)
		end,
		Kit = function(a, b)
			return (kitpriolist[a.Player:GetAttribute('PlayingAsKit')] or 0) > (kitpriolist[b.Player:GetAttribute('PlayingAsKit')] or 0)
		end,
		Damage = function(a, b)
			return bedwarsStore.lastDamaged[a.Player] < bedwarsStore.lastDamaged[b.Player]
		end
	}

	local originalNeckC0
	local originalRootC0
	local anims = {
		--vape animations
		Normal = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.05},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
		},
		Slow = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15}
		},
		New = {
			{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.12},
			{CFrame = CFrame.new(0.74, -0.92, 0.88) * CFrame.Angles(math.rad(147), math.rad(71), math.rad(53)), Time = 0.12}
		},
		Latest = {
			{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Time = 0.1},
			{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), Time = 0.1}
		},
		['Vertical Spin'] = {
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), Time = 0.1}
		},
		Exhibition = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		['Exhibition Old'] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15}
		},
		--old dortwars's src aura anims
		['Old Extend'] = {
		    {CFrame = CFrame.new(3, 0, 1) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-40)), Time = 0.1},
            {CFrame = CFrame.new(3.3, -.2, 0.7) * CFrame.Angles(math.rad(-70), math.rad(10), math.rad(-20)), Time = 0.2},
            {CFrame = CFrame.new(3.8, -.2, 1.3) * CFrame.Angles(math.rad(-80), math.rad(0), math.rad(-20)), Time = 0.01},
            {CFrame = CFrame.new(3, .3, 1.3) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-20)), Time = 0.07},
            {CFrame = CFrame.new(3, .3, .8) * CFrame.Angles(math.rad(-90), math.rad(10), math.rad(-40)), Time = 0.07}
		},
		['Horizontal Spin'] = {
		    {CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-80)), Time = 0.14},
            {CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(90), math.rad(-100)), Time = 0.14},
            {CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(180), math.rad(-100)), Time = 0.14},
            {CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(270), math.rad(-80)), Time = 0.14}
		},
		['BlockHit'] = {
		    {CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-70)), Time = 0.15},
            {CFrame = CFrame.new(0.5, -0.7, -0.2) * CFrame.Angles(math.rad(-120), math.rad(60), math.rad(-50)), Time = 0.15}
		},
		['Rise'] = {
		    {CFrame = CFrame.new(0.9, 0, 0) * CFrame.Angles(math.rad(-80), math.rad(60), math.rad(-40)), Time = 0.14},
            {CFrame = CFrame.new(0.5, 0.2, -0.7) * CFrame.Angles(math.rad(-150), math.rad(55), math.rad(20)), Time = 0.14}
		},
		['Jab'] = {
		    {CFrame = CFrame.new(0.8, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(65), math.rad(-90)), Time = 0.15},
            {CFrame = CFrame.new(0.6, -0.6, 0.5) * CFrame.Angles(math.rad(-45), math.rad(50), math.rad(-105)), Time = 0.1}
		},
		['Exhibition2'] = {
		    {CFrame = CFrame.new(1, 0, 0) * CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-80)), Time = 0.12},
            {CFrame = CFrame.new(1, 0, -0.3) * CFrame.Angles(math.rad(-80), math.rad(40), math.rad(-60)), Time = 0.16}
		},
		['Smooth'] = {
		    {CFrame = CFrame.new(1, 0, -0.5) * CFrame.Angles(math.rad(-90), math.rad(60), math.rad(-60)), Time = 0.2},
            {CFrame = CFrame.new(1, -0.2, -0.5) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(-30)), Time = 0.12}
		},
		['Butter'] = {
		    {CFrame = CFrame.new(3.0, -1.7, -1.1) * CFrame.Angles(math.rad(307), math.rad(57), math.rad(145)), Time = 0.18},
            {CFrame = CFrame.new(3.0, -1.7, -1.3) * CFrame.Angles(math.rad(203), math.rad(57), math.rad(226)), Time = 0.14}
		},
		['Slash'] = {
		    {CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.01},
            {CFrame = CFrame.new(-1.71, -1.11, -0.94) * CFrame.Angles(math.rad(-105), math.rad(85), math.rad(7)), Time = 0.19}
		},
		['Slide'] = {
		    {CFrame = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.15},
            {CFrame = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.3},
            {CFrame = CFrame.new(0.2, -1, -10) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.0},
            {CFrame = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.1},
            {CFrame = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.3}
		},
		['Swong'] = {
		    {CFrame = CFrame.new(0, 0, -0.6) * CFrame.Angles(math.rad(-60), math.rad(50), math.rad(-70)), Time = 0.1},
            {CFrame = CFrame.new(0, -0.3, -0.6) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(10)), Time = 0.2}
		},
		['Kill X'] = {
		    {CFrame = CFrame.new(0.8, -0.92, 0.9) * CFrame.Angles(math.rad(147), math.rad(140), math.rad(53)), Time = 0.12},
			{CFrame = CFrame.new(0.8, -0.92, 0.9) * CFrame.Angles(math.rad(147), math.rad(45), math.rad(53)), Time = 0.12}
		},
		['Stab'] = {
		    {CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.1, Size = 2},
			{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(90), math.rad(-81)), Time = 0.1, Size = 5}
		},
		['Exhibition vertical spin'] = {
		    {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), Time = 0.1}
		},
		['LiquidBounce'] = {
		    {CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(-80)), Time = 0.17},
            {CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-80)), Time = 0.17}
		},
		['OddSwing'] = {
		    {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.15},
            {CFrame = CFrame.new(0.03, 0.07, -0.07) * CFrame.Angles(math.rad(-20), math.rad(-2), math.rad(-8)), Time = 0.15}
		},
		['Sigma'] = {
		    {CFrame = CFrame.new(0.3, -0.8, -1.3) * CFrame.Angles(math.rad(160), math.rad(84), math.rad(90)), Time = 0.18},
            {CFrame = CFrame.new(0.3, -0.9, -1.17) * CFrame.Angles(math.rad(160), math.rad(70), math.rad(90)), Time = 0.18},
            {CFrame = CFrame.new(0.4, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.18}
		},
		['SigmaJello'] = {
		    {CFrame = CFrame.new(0.2, 0, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.18},
            {CFrame = CFrame.new(0, -0.2, -1.7) * CFrame.Angles(math.rad(30), math.rad(111), math.rad(190)), Time = 0.18}
		},
		['Drop'] = {
		    {CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
            {CFrame = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.23},
            {CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
            {CFrame = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.23},
            {CFrame = CFrame.new(-0.8, -0.6, -1) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.19}
		},
		['Cookless'] = {
		    {CFrame = CFrame.new(2, -2.5, 0.2) * CFrame.Angles(math.rad(268), math.rad(54), math.rad(327)), Time = 0.17},
            {CFrame = CFrame.new(1.6, -2.5, 0.2) * CFrame.Angles(math.rad(189), math.rad(52), math.rad(347)), Time = 0.16}
		},
		['Roll'] = {
		    {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.2},
            {CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(295), math.rad(60), math.rad(100)), Time = 0.2}
		},
		['Shrink'] = {
		    {CFrame = CFrame.new(0.3, 0, 0) * CFrame.Angles(math.rad(-2), math.rad(5), math.rad(25)), Time = 0.2},
            {CFrame = CFrame.new(0.69, -0.71, 0.6), Time = 0.2}
		},
		['Push'] = {
		    {CFrame = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
            {CFrame = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.35}
		},
		['Flat'] = {
		    {CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(-30), math.rad(-80)), Time = 0.15},
            {CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(30), math.rad(-100)), Time = 0.15}
		},
		['Dortware'] = {
		    {CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.1},
			{CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.6},
            {CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.6},
            {CFrame = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(90), math.rad(90)), Time = 0.8},
            {CFrame = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(80), math.rad(90)), Time = 1.2},
            {CFrame = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.6},
            {CFrame = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.6}
		},
		['Template'] = {
		    {CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.01},
            {CFrame = CFrame.new(-1.71, -1.11, -0.94) * CFrame.Angles(math.rad(-105), math.rad(85), math.rad(7)), Time = 0.19}
		},
		['Hamsterware'] = {
		    {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(40), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-135)), Time = 0.1}
		},
		['CatV5'] = {
		    {CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(25), math.rad(-60)), Time = 0.1},
			{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(55), math.rad(-115)), Time = 0.1},
			{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-50), math.rad(70), math.rad(-60)), Time = 0.1},
            {CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-70)), Time = 0.1}
		},
		['Astral2'] = {
		    {CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.15},
			{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.15}
		},
		['Leaked'] = {
		    {CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(16), math.rad(59), math.rad(-90)), Time = 0.15}
		},
		['Slide3'] = {
		    {CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0},
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-171), math.rad(47), math.rad(74)), Time = 0.16}
		},
		['Femboy'] = {
		    {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-0), math.rad(0), math.rad(-0)), Time = 0.08},
			{CFrame = CFrame.new(-0.01, 0, 0) * CFrame.Angles(math.rad(-7), math.rad(-7), math.rad(-1)), Time = 0.08},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0.11}
		},
		['MontCostume'] = {
		    {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.58) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.17},
            {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.05},
            {CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
		},
		['fdp slow'] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.90},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.50}
		},
		['swong'] = {
			{CFrame = CFrame.new(0, 0, -0.6) * CFrame.Angles(math.rad(-60), math.rad(50), math.rad(-70)), Time = 0.1, RealDelay = 0.1},
			{CFrame = CFrame.new(0, -0.3, -0.6) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(10)), Time = 0.2, RealDelay = 0.2}
		},
		['Blochit'] = {
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-70)), Time = 0.15, RealDelay = 0.15},
			{CFrame = CFrame.new(0.5, -0.7, -0.2) * CFrame.Angles(math.rad(-120), math.rad(60), math.rad(-50)), Time = 0.15, RealDelay = 0.15}
		},
		['Future2'] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.90},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.90},
		},
		['rise'] = {
			{CFrame = CFrame.new(0.9, 0, 0) * CFrame.Angles(math.rad(-80), math.rad(60), math.rad(-40)), Time = 0.14, RealDelay = 0.14},
			{CFrame = CFrame.new(0.5, -0.2, -0.7) * CFrame.Angles(math.rad(-150), math.rad(55), math.rad(20)), Time = 0.14, RealDelay = 0.14}			
		},
		['mine (rel)'] = {
			{CFrame = CFrame.new(0.8, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(65), math.rad(-90)), Time = 0.15},
			{CFrame = CFrame.new(0.8, -0.92, 0.9) * CFrame.Angles(math.rad(-40), math.rad(65), math.rad(-90)), Time = 0.3},
			{CFrame = CFrame.new(0.8, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(65), math.rad(-90)), Time = 0.15}
			
		},
		['jab'] = {
			{CFrame = CFrame.new(0.8, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(65), math.rad(-90)), Time = 0.15},
			{CFrame = CFrame.new(0.6, -0.6, 0.5) * CFrame.Angles(math.rad(-45), math.rad(50), math.rad(-105)), Time = 0.1},					
		},
		['VAPE OLD'] = {
			{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.07, Size = 2},
			{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(90), math.rad(-81)), Time = 0.06, Size = 5},
		},
		['meelkware'] = {
			{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.02, Size = 2},
			{CFrame = CFrame.new(0.69, -0.77 + 2, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.02, Size = 2},
			{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.02, Size = 2},
		},
		['pistonware blue'] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(40), math.rad(55), math.rad(290)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(40), math.rad(70), math.rad(1)), Time = 0.15}
		},
		['idk'] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(60), math.rad(304)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(90), math.rad(304)), Time = 0.15}
		},
		YourMom = {
			{CFrame = CFrame.new(0.67, -0.68, 0.62) * CFrame.Angles(math.rad(-40), math.rad(65), math.rad(-80)), Time = 0.12},
			{CFrame = CFrame.new(0.72, -0.72, 0.6) * CFrame.Angles(math.rad(-94), math.rad(70), math.rad(-28)), Time = 0.26}
		},
		ZeroPrime = {
			{CFrame = CFrame.new(0.7, -0.89, 0.6) * CFrame.Angles(math.rad(-45), math.rad(47), math.rad(-77)), Time = 0.14},
			{CFrame = CFrame.new(0.67, -0.66, 0.59) * CFrame.Angles(math.rad(-76), math.rad(50), math.rad(-37)), Time = 0.26}
		},
		DortVersion2 = {
			{CFrame = CFrame.new(0.72, -0.67, 0.68) * CFrame.Angles(math.rad(-35), math.rad(45), math.rad(-84)), Time = 0.12},
			{CFrame = CFrame.new(0.68, -0.74, 0.53) * CFrame.Angles(math.rad(-80), math.rad(50), math.rad(-35)), Time = 0.24}
		},
		SlowSwordThrowAnim = {
			{CFrame = CFrame.new(-3, -3, -3) * CFrame.Angles(math.rad(180), math.rad(90), math.rad(270)), Time = 0.1},
			{CFrame = CFrame.new(3, 3, 3) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(180)), Time = 0.1},
		   
		},
		SwordThrowAnim = {
			{CFrame = CFrame.new(-3, -3, -3) * CFrame.Angles(math.rad(180), math.rad(90), math.rad(270)), Time = 0.3},
			{CFrame = CFrame.new(3, 3, 3) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(180)), Time = 0.3},
		},
		  
		FastSwordThrowAnim = {
			{CFrame = CFrame.new(-3, -3, -3) * CFrame.Angles(math.rad(180), math.rad(90), math.rad(270)), Time = 0.5},
			{CFrame = CFrame.new(3, 3, 3) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(180)), Time = 0.5},
		},
		SlowAndFast = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.8},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.01}
		},
		SkidWare = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(65), math.rad(-79)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-98), math.rad(35), math.rad(-56)), Time = 0.2}
		},
		Monsoon = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-45), math.rad(70), math.rad(-90)), Time = 0.07},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-89), math.rad(70), math.rad(-38)), Time = 0.13}
		},
		N1san1StopFuckingAnnoyingMe = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-89), math.rad(68), math.rad(-56)), Time = 0.12},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-65), math.rad(68), math.rad(-35)), Time = 0.19}
		},
		Spooky = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(54), math.rad(-56)), Time = 0.08},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-98), math.rad(38), math.rad(-23)), Time = 0.15}
		},
		['SkidWare New'] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(98), math.rad(-354)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-98), math.rad(65), math.rad(-68)), Time = 0.2}
		},
		['Kys'] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(50), math.rad(50), math.rad(100)), Time = 0.3},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(84), math.rad(50), math.rad(50)), Time = 0.3}
		},
		['Astral'] = {
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0},
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.900},
			{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.15}
		},
		xarq0n1 = {
			{CFrame = CFrame.new(0, -3, 0) * CFrame.Angles(-math.rad(120), math.rad(530), -math.rad(220)), Time = 0.2},
			{CFrame = CFrame.new(0.9, 0, 1.5) * CFrame.Angles(math.rad(7), math.rad(30), math.rad(820)), Time = 0.2}
		},
		xarq0n2 = {
			{CFrame = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(190)), Time = 0.8},
			{CFrame = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(200), math.rad(40), math.rad(1)), Time = 0.8}
		},
		xarq0n3 = {
			{CFrame = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(195), math.rad(95), math.rad(130)), Time = 0.1},
			{CFrame = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(300), math.rad(40), math.rad(1)), Time = 0.2}
		},
		Swiss = {
			{CFrame = CFrame.new(1, -1.4, 1.4) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.15},
			{CFrame = CFrame.new(-1.4, 1, -1) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15}
		},
		SlowSwiss = {
			{CFrame = CFrame.new(1, -1.4, 1.4) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.25},
			{CFrame = CFrame.new(-1.4, 1, -1) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.25}
		},
		OldAstralAnim = {
			{CFrame = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.1},
			{CFrame = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.1}
		},
		SlowOldAstralAnim = {
			{CFrame = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.4},
			{CFrame = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.4}
		},
		ZylaAnim = {
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
			{CFrame = CFrame.new(0.3, -2, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.3}
		},
		SliceAnim = {
			{CFrame = CFrame.new(3, -4, 3) * CFrame.Angles(math.rad(90), math.rad(90), math.rad(90)), Time = 0.2},
			{CFrame = CFrame.new(-4, 3, -4) * CFrame.Angles(math.rad(111), math.rad(222), math.rad(333)), Time = 0.2}
		},
		SlowSliceAnim = {
			{CFrame = CFrame.new(3, -4, 3) * CFrame.Angles(math.rad(90), math.rad(90), math.rad(90)), Time = 0.4},
			{CFrame = CFrame.new(-4, 3, -4) * CFrame.Angles(math.rad(111), math.rad(222), math.rad(333)), Time = 0.4}
		},
		PistonWareBlock = {
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.00001} 
	},
	--[[['Normal'] = {
        {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.05},
        {CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
    },
    ['Smooth'] = {
        {CFrame = CFrame.new(1, 0, 0.5) * CFrame.Angles(math.rad(-90), math.rad(60), math.rad(-60)), Time = 0.2},
        {CFrame = CFrame.new(1, -0.2, -0.5) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(-30)), Time = 0.12}
    },
    ['Slow'] = {
        {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.15},
        {CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15}
    },]]
    ['1.8'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Time = 0.12},
		{CFrame = CFrame.new(0.16, -1.16, 1) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), Time = 0.12}
	},
    ['Blocking'] = {
        {CFrame = CFrame.new(-0.01, -3.51, -2.01) * CFrame.Angles(math.rad(-180), math.rad(85), math.rad(-180)), Time = 0}
    },
    ['Swag2'] = {
        {CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.1},
        {CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.13},
        {CFrame = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(90), math.rad(90)), Time = 0.13},
        {CFrame = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.13},
    },
	['Kawaii'] = {
		{CFrame = CFrame.new(-0.01, 0.49, -1.51) * CFrame.Angles(math.rad(90), math.rad(45), math.rad(-90)),Time = 0},
		{CFrame = CFrame.new(-0.01, 0.49, -1.51) * CFrame.Angles(math.rad(-51), math.rad(48), math.rad(24)),Time = 0.06},
		{CFrame = CFrame.new(-0.01, 0.49, -1.51) * CFrame.Angles(math.rad(90), math.rad(45), math.rad(-90)),Time = 0.06}
	},
	['Swank'] = {
		{CFrame = CFrame.new(-0.01, -.45, -0.7) * CFrame.Angles(math.rad(-0), math.rad(85), math.rad(0)),Time = 0.1},
        {CFrame = CFrame.new(-0.02, -.45, -0.7) * CFrame.Angles(math.rad(59), math.rad(19), math.rad(-37)),Time = 0.09},
	},
    ['Swank2'] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.09},
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.09},
		{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.15}
    },
    ['TenacityOld2'] = {
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(25), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(55), math.rad(-115)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-50), math.rad(70), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-70)), Time = 0.1}
	},
    ['OldSwank3'] = {
		{CFrame = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.4},
		{CFrame = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.4}
	},
    ['TenacityOld'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
		{CFrame = CFrame.new(0.3, -2, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.3}
	},
    ['AstolfoNew'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
	},
	['Sigma2'] = {
        {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.05},
        {CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
    },
    ['Sigma3'] = {
        {CFrame = CFrame.new(0.3, -0.8, -1.3) * CFrame.Angles(math.rad(160), math.rad(84), math.rad(90)), Time = 0.18},
        {CFrame = CFrame.new(0.3, -0.9, -1.17) * CFrame.Angles(math.rad(160), math.rad(70), math.rad(90)), Time = 0.18},
        {CFrame = CFrame.new(0.4, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.18}
    },
    ['Tap'] = {
        {CFrame = CFrame.new(5, -1, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(10)), Time = 0.25},
        {CFrame = CFrame.new(5, -1, -0.3) * CFrame.Angles(math.rad(-100), math.rad(-30), math.rad(10)), Time = 0.25}
    },
    ['Swag'] = {
        {CFrame = CFrame.new(-0.01, -0.01, -1.01) * CFrame.Angles(math.rad(-90), math.rad(90), math.rad(0)), Time = 0.08},
        {CFrame = CFrame.new(-0.01, -0.01, -1.01) * CFrame.Angles(math.rad(10), math.rad(70), math.rad(-90)), Time = 0.08},
    },
    ['Suicide'] = {
        {CFrame = CFrame.new(-2.5, -4.5, -0.02) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(-0)), Time = 0.1},
        {CFrame = CFrame.new(-2.5, -1, -0.02) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(-0)), Time = 0.05}
    },
    ['Goofy2'] = {
        {CFrame = CFrame.new(0.5, -0.01, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.10},
        {CFrame = CFrame.new(0.5, -0.51, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.08},
        {CFrame = CFrame.new(0.5, -0.01, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.08}
    },
    ['Rise2'] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0},
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.900},
		{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.15}
	},
    ['Rise4'] = {
        {CFrame = CFrame.new(0.9,0,0) * CFrame.Angles(math.rad(-80), math.rad(60), math.rad(-40)), Time = 0.14},
        {CFrame = CFrame.new(0.5,-0.2,-0.7) * CFrame.Angles(math.rad(-150), math.rad(55), math.rad(20)), Time = 0.14}
    },
    ['Rise3'] = {
        {CFrame = CFrame.new(0.6, -1, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
        {CFrame = CFrame.new(0.6, -1.5, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.1}    
    },
    ['Rise4'] = {
        {CFrame = CFrame.new(0.3, -2, 0.5) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
        {CFrame = CFrame.new(0.3, -1.5, 1.5) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.1}
    },
    ['Swong2'] = {
        {CFrame = CFrame.new(0,0,-.6) * CFrame.Angles(math.rad(-60), math.rad(50), math.rad(-70)), Time = 0.1},
        {CFrame = CFrame.new(0,-.3, -.6) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(10)), Time = 0.2},
    },
    ['Eternal'] = {
        {CFrame = CFrame.new(0,0,-1) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(-80)), Time = 0.17},
        {CFrame = CFrame.new(0,0,-1) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-80)), Time = 0.17}
    },
    ['monkey'] = {
		{CFrame = CFrame.new(0, -3, 0) * CFrame.Angles(-math.rad(120), math.rad(530), -math.rad(220)), Time = 0.2},
		{CFrame = CFrame.new(0.9, 0, 1.5) * CFrame.Angles(math.rad(7), math.rad(30), math.rad(820)), Time = 0.2}
	},
    ['Throw'] = {
		{CFrame = CFrame.new(-3, -3, -3) * CFrame.Angles(math.rad(255), math.rad(122), math.rad(321)), Time = 0.5},
		{CFrame = CFrame.new(1, 1, 1) * CFrame.Angles(math.rad(156), math.rad(54), math.rad(91)), Time = 0.5}
	},
    ['Slide2'] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0},
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-171), math.rad(47), math.rad(74)), Time = 0.16}
	},
    ['Ketamine2'] = {
        {CFrame = CFrame.new(5, -3, 2) * CFrame.Angles(math.rad(120), math.rad(160), math.rad(140)), Time = 0.07},
        {CFrame = CFrame.new(5, -2.5, -1) * CFrame.Angles(math.rad(80), math.rad(180), math.rad(180)), Time = 0.07},
        {CFrame = CFrame.new(5, -3.4, -3.3) * CFrame.Angles(math.rad(45), math.rad(160), math.rad(190)), Time = 0.07},
        {CFrame = CFrame.new(5, -2.5, -1) * CFrame.Angles(math.rad(80), math.rad(180), math.rad(180)), Time = 0.07},
    },
    ['Astolfo2'] = {
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(25), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(55), math.rad(-115)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-50), math.rad(70), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-70)), Time = 0.1}
	},
    ['Ketamine'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-0), math.rad(0), math.rad(-0)), Time = 0.08},
	    {CFrame = CFrame.new(-0.01, 0, 0) * CFrame.Angles(math.rad(-7), math.rad(-7), math.rad(-1)), Time = 0.08},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0.11}
	},
    ['Swiss2'] = {
		{CFrame = CFrame.new(1, -1.4, 1.4) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.25},
		{CFrame = CFrame.new(-1.4, 1, -1) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.25}
	},
    ['Old'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
		{CFrame = CFrame.new(0.3, -2, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.3}
	},
    ['Extension'] = {
        {CFrame = CFrame.new(3, 0, 1) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-40)), Time = 0.2},
        {CFrame = CFrame.new(3.3, -.2, 0.7) * CFrame.Angles(math.rad(-70), math.rad(10), math.rad(-20)), Time = 0.2},
        {CFrame = CFrame.new(3.8, -.2, 1.3) * CFrame.Angles(math.rad(-80), math.rad(0), math.rad(-20)), Time = 0.1},
        {CFrame = CFrame.new(3, .3, 1.3) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-20)), Time = 0.07},
        {CFrame = CFrame.new(3, .3, .8) * CFrame.Angles(math.rad(-90), math.rad(10), math.rad(-40)), Time = 0.07},
    },
    ['Astolfo'] = {
        {CFrame = CFrame.new(5, -1, -1) * CFrame.Angles(math.rad(-40), math.rad(0), math.rad(0)), Time = 0.05},
        {CFrame = CFrame.new(5, -0.7, -1) * CFrame.Angles(math.rad(-120), math.rad(20), math.rad(-10)), Time = 0.05},
    },
    German = {
        {CFrame = CFrame.new(0.5, -0.01, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.10},
        {CFrame = CFrame.new(0.5, -0.51, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.08},
        {CFrame = CFrame.new(0.5, -0.01, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.08}
    },
    Penis = {
        {CFrame = CFrame.new(-1.8, 0.5, -1.01) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-90)), Time = 0.05},
        {CFrame = CFrame.new(-1.8, -0.21, -1.01) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-90)), Time = 0.05}
    },
    KillMyself = {
        {CFrame = CFrame.new(-2.5, -4.5, -0.02) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(-0)), Time = 0.1},
        {CFrame = CFrame.new(-2.5, -1, -0.02) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(-0)), Time = 0.05}
    },
	--scrxpted needs to do this ^^
	['SmootherExhibition'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.6},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.3},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.7},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.9},
		{CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 1}
	},
	['PurpulV1'] = {
		 {CFrame = CFrame.new(0.33, -0.45, 0.3) * CFrame.Angles(math.rad(-23), math.rad(50), math.rad(-90)), Time = 0.1},
		 {CFrame = CFrame.new(0.33, -0.7, 0.6) * CFrame.Angles(math.rad(-25), math.rad(50), math.rad(-90)), Time = 0.1}
	},
	SuperSlowSlow = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.50},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.50}
	},
	--new anims thanks to inum or activisisnice on discord :pray:
	NewCatV5 = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-70)), Time = 0.1},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(1)), Time = 0.1},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-0), math.rad(0), math.rad(-0)), Time = -0.2},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-22), math.rad(56), math.rad(-106)), Time = 0.1}
	},
	blackwareFast = {
		{CFrame = CFrame.new(1.49, -1, 0.12) * CFrame.Angles(math.rad(260), math.rad(55), math.rad(200)), Time = 0.30},
		{CFrame = CFrame.new(0.37, -2, -0.4) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(-20)), Time = 0.30}
	},
	blackwareSlow = {
		{CFrame = CFrame.new(1.5, -0.80, 0.14) * CFrame.Angles(math.rad(260), math.rad(50), math.rad(240)), Time = 0.40},
		{CFrame = CFrame.new(0.5, -0.15, -0.6) * CFrame.Angles(math.rad(-40), math.rad(55), math.rad(-50)), Time = 0.40}
	},
	blackMeteor = {
		{CFrame = CFrame.new(0.80, -0.77, 0.9) * CFrame.Angles(math.rad(-30), math.rad(55), math.rad(-90)), Time = 0.20},
		{CFrame = CFrame.new(0.32, -0.81, 0.10) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 0.20}
	},
	Blackware = {
		{CFrame = CFrame.new(0.6, -0.7, 0.6) * CFrame.Angles(math.rad(-8), math.rad(40), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(0.49, -0.8, 0.3) * CFrame.Angles(math.rad(8), math.rad(40), math.rad(-10)), Time = 0.15}
	},
	['icespice'] = {
		{CFrame = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(190)), Time = 0.8},
		{CFrame = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(200), math.rad(40), math.rad(1)), Time = 0.8}
	},
	['KEK'] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
		{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.1}
	},
	['normalv2'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.09},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.09}
	},
	['sillydick'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
		{CFrame = CFrame.new(0.3, -2, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.3}
	},
	['normalv3'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.06},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
	},
	--https://cdn.discordapp.com/attachments/1180128067239292949/1182778437790879824/IMG_0129.png?ex=6585ef42&is=65737a42&hm=66a4a46d8e748b3b0a1c1e2e36e1142d70bc0a7f83d1752a7b69e7f87b665793&
	['PRISMASTADAWN'] = {
		{CFrame = CFrame.new(0.3, -2, .1) * CFrame.Angles(math.rad(190), math.rad(75), math.rad(90)), Time = 0.13},
		{CFrame = CFrame.new(0.3, -2, .2) * CFrame.Angles(math.rad(190), math.rad(95), math.rad(80)), Time = 0.13},
		{CFrame = CFrame.new(0.3, -2, .1) * CFrame.Angles(math.rad(120), math.rad(170), math.rad(90)), Time = 0.13},
	},
	['Custom+'] = {
		{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.13},
		{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.03},
		{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.09},
		{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
		{CFrame = CFrame.new(0.39, 0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.13}
	},
	['FastslowBETTER'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.8},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.01}
	},	
	['cum'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-45), math.rad(70), math.rad(-90)), Time = 0.07},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-89), math.rad(70), math.rad(-38)), Time = 0.13}
	},
	['meteor4'] = {
		{CFrame = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
		{CFrame = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.35}
	},
	['meteor'] = {
		{CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(-80)), Time = 0.17},
		{CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-80)), Time = 0.17}
	},
	['meteor6'] = {
		{CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
		{CFrame = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.23},
		{CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
	},
	['astrolfo'] = {
		{CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
		{CFrame = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.23},
		{CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
		{CFrame = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.23},
		{CFrame = CFrame.new(-0.8, -0.6, -1) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.19},
	},
	['idkthesenames'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-89), math.rad(68), math.rad(-56)), Time = 0.12},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-65), math.rad(68), math.rad(-35)), Time = 0.19}
	},
	['sexy'] = {
		{CFrame = CFrame.new(0.3, -2, 0.5) * CFrame.Angles(math.rad(190), math.rad(110), math.rad(90)), Time = 0.3},
		{CFrame = CFrame.new(0.3, -1.5, 1.5) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.1}
	},
	['meteor2'] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-70)), Time = 0.15},
		{CFrame = CFrame.new(0.5, -0.7, -0.2) * CFrame.Angles(math.rad(-120), math.rad(60), math.rad(-50)), Time = 0.15}
	},
	['meteor7'] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-70)), Time = 0.15},
		{CFrame = CFrame.new(0.5, -0.7, -0.2) * CFrame.Angles(math.rad(-120), math.rad(60), math.rad(10)), Time = 0.14},
	},
	['meteor8'] = {
		{CFrame = CFrame.new(0.9, 0, 0) * CFrame.Angles(math.rad(-80), math.rad(60), math.rad(-40)), Time = 0.14},
		{CFrame = CFrame.new(0.5, -0.2, -0.7) * CFrame.Angles(math.rad(-150), math.rad(55), math.rad(20)), Time = 0.14},
	},
	['sexyfr'] = {
		{CFrame = CFrame.new(0.3, -2, 0.5) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
		{CFrame = CFrame.new(0.3, -1.5, 1.5) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.1}
	},
	['2cum'] = {
		{CFrame = CFrame.new(0.7, -0.4, 0.612) * CFrame.Angles(math.rad(285), math.rad(65), math.rad(293)), Time = 0.13},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(210), math.rad(70), math.rad(3)), Time = 0.13}
	},
	['fatbitch'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(350), math.rad(45), math.rad(85)), Time = 0.12},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(350), math.rad(80), math.rad(60)), Time = 0.12},
	},
	['meteor3'] = {
		{CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.13},
		{CFrame = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(90), math.rad(90)), Time = 0.13},
		{CFrame = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.13},
	},
	['random'] = {
		{CFrame = CFrame.new(-0.06, -0.5, -1.03) * CFrame.Angles(math.rad(-39), math.rad(97), math.rad(-92)), Time = 0.2},
		{CFrame = CFrame.new(-0.05, -0.5, -1.03) * CFrame.Angles(math.rad(-39), math.rad(75), math.rad(-93)), Time = 0.3},
		{CFrame = CFrame.new(-0.03, -0.5, 0.4) * CFrame.Angles(math.rad(-39), math.rad(75), math.rad(-91)), Time = 0.2}
	},
	SlowAsstral = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.14},
		{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.26}
	},
	Karambit = {
		{CFrame = CFrame.new(-0.01, 0, -1.51) * CFrame.Angles(math.rad(-50), math.rad(0), math.rad(0)), Time = 0},
		{CFrame = CFrame.new(-0.01, -0.01, -1.51) * CFrame.Angles(math.rad(-155), math.rad(0), math.rad(-0)), Time = 0.03},
		{CFrame = CFrame.new(-0.01, -0.01, -1.51) * CFrame.Angles(math.rad(120), math.rad(0), math.rad(0)), Time = 0.03},
		{CFrame = CFrame.new(-0.01, -0.01, -1.51) * CFrame.Angles(math.rad(30), math.rad(-0), math.rad(0)), Time = 0.03},
		{CFrame = CFrame.new(-0.01, 0, -1.51) * CFrame.Angles(math.rad(-50), math.rad(0), math.rad(0)), Time = 0.15}
	},
	LiquidBounceV2 = {
		{CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(-80)), Time = 0.17},
		{CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-80)), Time = 0.23}
	},
	Tenacity = {
		{CFrame = CFrame.new(0.9, 0, 0) * CFrame.Angles(math.rad(-80), math.rad(60), math.rad(-40)), Time = 0.2},
		{CFrame = CFrame.new(0.5, -0.2, -0.7) * CFrame.Angles(math.rad(-150), math.rad(55), math.rad(20)), Time = 0.2}
	},
	StabRemake = {
		{CFrame = CFrame.new(2, -2.5, 0.2) * CFrame.Angles(math.rad(268), math.rad(54), math.rad(327)), Time = 0.17},
		{CFrame = CFrame.new(1.6, -2.5, 0.2) * CFrame.Angles(math.rad(189), math.rad(52), math.rad(347)), Time = 0.16}
	},
	SlashRemake = {
		{CFrame = CFrame.new(3.0, -1.7, -1.1) * CFrame.Angles(math.rad(307), math.rad(57), math.rad(145)), Time = 0.18},
		{CFrame = CFrame.new(3.0, -1.7, -1.3) * CFrame.Angles(math.rad(203), math.rad(57), math.rad(226)), Time = 0.14}
	},
	ExhiRemake = {
		{CFrame = CFrame.new(1, 0, -0.5) * CFrame.Angles(math.rad(-90), math.rad(60), math.rad(-60)), Time = 0.2},
		{CFrame = CFrame.new(1, -0.2, -0.5) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(-30)), Time = 0.12}
	},
	PushRemake = {
		{CFrame = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
		{CFrame = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.35}
	},
	SwongRemake = {
		{CFrame = CFrame.new(0, 0, -0.6) * CFrame.Angles(math.rad(-60), math.rad(50), math.rad(-70)), Time = 0.1},
		{CFrame = CFrame.new(0, -0.3, -0.6) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(10)), Time = 0.2}
	},
	BetterDortware = {
		{CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.1},
		{CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.13},
		{CFrame = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.03},
		{CFrame = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(90), math.rad(90)), Time = 0.13},
		{CFrame = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(80), math.rad(90)), Time = 0.07},
		{CFrame = CFrame.new(0.5, -0.2, -0.8) * CFrame.Angles(math.rad(-150), math.rad(111), math.rad(20)), Time = 0.13},
		{CFrame = CFrame.new(0.5, -0.2, -0.8) * CFrame.Angles(math.rad(-150), math.rad(111), math.rad(20)), Time = 0.03}
	},
	BingChilling = {
		{CFrame = CFrame.new(0.07, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
	},
	HypixelBlock = {
		{CFrame = CFrame.new(1, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(45), math.rad(0), math.rad(0)), Time = 0.2},
		{CFrame = CFrame.new(1, 0, 0) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0)), Time = 0.2},
		{CFrame = CFrame.new(0.3, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
	},
	INUMAURA = {
		{CFrame = CFrame.new(0, -0.1, -0.30) * CFrame.Angles(math.rad(-20), math.rad(20), math.rad(0)), Time = 0.30},
		{CFrame = CFrame.new(0, -0.50, -0.30) * CFrame.Angles(math.rad(-40), math.rad(41), math.rad(0)), Time = 0.32},
		{CFrame = CFrame.new(0, -0.1, -0.30) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0)), Time = 0.32}
	},
	Shake = {
		{CFrame = CFrame.new(0.69, -0.8, 0.6) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-35)), Time = 0.05},
		{CFrame = CFrame.new(0.8, -0.71, 0.30) * CFrame.Angles(math.rad(-60), math.rad(39), math.rad(-55)), Time = 0.02},
		{CFrame = CFrame.new(0.8, -2, 0.45) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-55)), Time = 0.03}
	},
	PopV3 = {
		{CFrame = CFrame.new(0.69, -0.10, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
		{CFrame = CFrame.new(0.69, -2, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1}
	},
	PopV4 = {
		{CFrame = CFrame.new(0.69, -0.10, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.01},
		{CFrame = CFrame.new(0.7, -0.30, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.01},
		{CFrame = CFrame.new(0.69, -2, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.01}
	},
	Remake = {
		{CFrame = CFrame.new(-0.10, -0.45, -0.20) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-50)), Time = 0.01},
		{CFrame = CFrame.new(0.7, -0.71, -1) * CFrame.Angles(math.rad(-90), math.rad(50), math.rad(-38)), Time = 0.2},
		{CFrame = CFrame.new(0.63, -0.1, 1.50) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15}
	},
	PopV2 = {
		{CFrame = CFrame.new(0.10, -0.3, -0.30) * CFrame.Angles(math.rad(295), math.rad(80), math.rad(290)), Time = 0.09},
		{CFrame = CFrame.new(0.10, 0.10, -1) * CFrame.Angles(math.rad(295), math.rad(80), math.rad(300)), Time = 0.1},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
	},
	Bob = {
		{CFrame = CFrame.new(-0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
		{CFrame = CFrame.new(-0.7, -2.5, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
	},
	Knife = {
		{CFrame = CFrame.new(-0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
		{CFrame = CFrame.new(1, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
		{CFrame = CFrame.new(4, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
	},
	FunnyExhibition = {
		{CFrame = CFrame.new(-1.5, -0.50, 0.20) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.10},
		{CFrame = CFrame.new(-0.55, -0.20, 1.5) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
	},
	FasterSmooth = {
		{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(80), math.rad(60)), Time = 0.11},
		{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(100), math.rad(60)), Time = 0.11},
		{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(60), math.rad(60)), Time = 0.11},
	},
	Smooth2 = {
		{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(80), math.rad(60)), Time = 0.25},
		{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(100), math.rad(60)), Time = 0.25},
		{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(60), math.rad(60)), Time = 0.25},
	},
	Funny = {
		{CFrame = CFrame.new(0, 0, 1.5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.15},
		{CFrame = CFrame.new(0, 0, -1.5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.15},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.15},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-55), math.rad(0), math.rad(0)), Time = 0.15}
	},
	FunnyFuture = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0)),Time = 0.25},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25}
	},
	Goofy = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.25},
		{CFrame = CFrame.new(-1, -1, 1) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(-33)),Time = 0.25}
	},
	Future = {
		{CFrame = CFrame.new(0.69, -0.7, 0.10) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.20},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25}
	},
	Pop = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-30), math.rad(80), math.rad(-90)), Time = 0.35},
		{CFrame = CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.35}
	},
	FunnyV2 = {
		{CFrame = CFrame.new(0.10, -0.5, -1) * CFrame.Angles(math.rad(295), math.rad(80), math.rad(300)), Time = 0.45},
		{CFrame = CFrame.new(-5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.45},
		{CFrame = CFrame.new(5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.45},
	},
	Slowest = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.1},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15},
		{CFrame = CFrame.new(0.69, -0.72, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.15},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.1},
	},
	BigAuraAnimation = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.1},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.1},
		{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Time = 0.1},
		{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), Time = 0.1},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
		{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.13},
		{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.09},
		{CFrame = CFrame.new(0.39, 0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.13},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), Time = 0.1},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), Time = 0.1},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), Time = 0.1},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), Time = 0.1},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
		{CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15},
	},
	Acronisware = {
		{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.03},
		{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
		{CFrame = CFrame.new(0.39, 0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.13},
	},
	['CustomSP+'] = {
		{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.13},
		{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.03},
		{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.09},
		{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
		{CFrame = CFrame.new(0.39, 0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.13}
	},
	['FemboyActivis'] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-0), math.rad(0), math.rad(-0)), Time = 0.08},
		{CFrame = CFrame.new(-0.01, 0, 0) * CFrame.Angles(math.rad(-7), math.rad(-7), math.rad(-1)), Time = 0.08},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0.11}
	},
	Lift = {
		{CFrame = CFrame.new(0.5, -0.5, 0.5) * CFrame.Angles(math.rad(-15), math.rad(0), math.rad(0)), Time = 0.2},
		{CFrame = CFrame.new(0.5, -0.4, 0.5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.3},
	},
	SlowLift = {
		{CFrame = CFrame.new(0.5, -0.5, 0.5) * CFrame.Angles(math.rad(-30), math.rad(0), math.rad(0)), Time = 0.5},
		{CFrame = CFrame.new(0.5, -0.4, 0.5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 1},
	},
	Shit = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.2},
		{CFrame = CFrame.new(-0.1, -0.2, 0.05) * CFrame.Angles(math.rad(-15), math.rad(30), math.rad(15)), Time = 0.4},
		{CFrame = CFrame.new(-0.12, -0.22, 0.06) * CFrame.Angles(math.rad(-10), math.rad(60), math.rad(25)), Time = 0.6},
		{CFrame = CFrame.new(-0.1, -0.18, 0.08) * CFrame.Angles(math.rad(-25), math.rad(30), math.rad(10)), Time = 0.8},
		{CFrame = CFrame.new(0.2, -0.15, -0.05) * CFrame.Angles(math.rad(-5), math.rad(0), math.rad(-10)), Time = 1},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 1.2},
	},
	SwingOld = {
		{CFrame = CFrame.new(0, -0.5, 0) * CFrame.Angles(math.rad(5), math.rad(0), math.rad(5)), Time = 0.2},
		{CFrame = CFrame.new(0, -0.48, 0) * CFrame.Angles(math.rad(-5), math.rad(0), math.rad(-5)), Time = 0.25},
		{CFrame = CFrame.new(0, -0.5, 0) * CFrame.Angles(math.rad(5), math.rad(0), math.rad(5)), Time = 0.2},
		{CFrame = CFrame.new(0, -0.52, 0) * CFrame.Angles(math.rad(-5), math.rad(0), math.rad(-5)), Time = 0.25},
	},		
	throw = { 
		{CFrame = CFrame.new(-0.04, -0.4, -1.05) * CFrame.Angles(math.rad(-30), math.rad(100), math.rad(-90)), Time = 0.15},
		{CFrame = CFrame.new(0.32, -0.81, 0.10) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 0.20},
		{CFrame = CFrame.new(0.10, -0.5, -0.3) * CFrame.Angles(math.rad(-40), math.rad(55), math.rad(-50)), Time = 0.30},
		{CFrame = CFrame.new(-0.04, -0.4, 0.5) * CFrame.Angles(math.rad(-30), math.rad(80), math.rad(-90)), Time = 0.15}
	},
	OLD = { 
		{CFrame = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.15},
		{CFrame = CFrame.new(0.02, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 0.25},
		{CFrame = CFrame.new(0.80, -0.77, 0.9) * CFrame.Angles(math.rad(-30), math.rad(55), math.rad(-90)), Time = 0.20},
		{CFrame = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.15},
		{CFrame = CFrame.new(0.3, -0.4, 0.6) * CFrame.Angles(math.rad(-8), math.rad(40), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(-0.04, -0.4, -1.05) * CFrame.Angles(math.rad(-30), math.rad(100), math.rad(-90)), Time = 0.15},
		{CFrame = CFrame.new(-0.04, -0.4, 0.5) * CFrame.Angles(math.rad(-30), math.rad(80), math.rad(-90)), Time = 0.15}
	},
	SwingAnimation = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.2},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(45), math.rad(0), math.rad(0)), Time = 0.2},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-45), math.rad(0), math.rad(0)), Time = 0.2},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.2},
	},
	ExhibitionV2 = {
		{CFrame = CFrame.new(0.65, -0.6, 0.7) * CFrame.Angles(math.rad(-60), math.rad(70), math.rad(-100)), Time = 0.1},
		{CFrame = CFrame.new(0.75, -0.65, 0.7) * CFrame.Angles(math.rad(-70), math.rad(80), math.rad(-50)), Time = 0.2},
		{CFrame = CFrame.new(0.8, -0.7, 0.75) * CFrame.Angles(math.rad(-80), math.rad(90), math.rad(-40)), Time = 0.3}
	},
	FrontwardAscend = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.1},
		{CFrame = CFrame.new(0, 0.2, -0.1) * CFrame.Angles(math.rad(10), math.rad(0), math.rad(0)), Time = 0.3},
		{CFrame = CFrame.new(0, 0.4, -0.2) * CFrame.Angles(math.rad(20), math.rad(0), math.rad(0)), Time = 0.5},
		{CFrame = CFrame.new(0, 0.2, -0.5) * CFrame.Angles(math.rad(10), math.rad(0), math.rad(0)), Time = 0.8},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 1.2}
	},
	SpiralReturn = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.05},
		{CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(360), math.rad(0), math.rad(0)), Time = 0.3},
		{CFrame = CFrame.new(0, 0, -2) * CFrame.Angles(math.rad(720), math.rad(0), math.rad(0)), Time = 0.6},
		{CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(1080), math.rad(0), math.rad(0)), Time = 0.9},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1440), math.rad(0), math.rad(0)), Time = 1.2},
	},
	Boomerang = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.05},
		{CFrame = CFrame.new(1, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.15},
		{CFrame = CFrame.new(2, 0, -1) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.3},
		{CFrame = CFrame.new(1, 0, -2) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.45},
		{CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.6},
		{CFrame = CFrame.new(-1, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.75},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.9},
	},
	SmoothFlow = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.05},
		{CFrame = CFrame.new(0.5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(10), math.rad(0)), Time = 0.2},
		{CFrame = CFrame.new(1, 0, 0) * CFrame.Angles(math.rad(0), math.rad(20), math.rad(0)), Time = 0.4},
		{CFrame = CFrame.new(0.5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(10), math.rad(0)), Time = 0.6},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.8},
	},
	OldSmooth = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.1},
		{CFrame = CFrame.new(0.25, -0.35, 0.3) * CFrame.Angles(math.rad(-15), math.rad(25), math.rad(-45)), Time = 0.3},
		{CFrame = CFrame.new(0.5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(10), math.rad(0)), Time = 0.5},
		{CFrame = CFrame.new(0.625, -0.355, 0.295) * CFrame.Angles(math.rad(-42), math.rad(30), math.rad(-64)), Time = 0.7},
		{CFrame = CFrame.new(0.750, -0.71, 0.29) * CFrame.Angles(math.rad(-57), math.rad(55), math.rad(-81)), Time = 0.9},
		{CFrame = CFrame.new(0.5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(10), math.rad(0)), Time = 1.1},
		{CFrame = CFrame.new(0.25, -0.35, 0.3) * CFrame.Angles(math.rad(-15), math.rad(25), math.rad(-45)), Time = 1.3},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 1.5},
	},		
	SlowlySmooth = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.25},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.5},
		{CFrame = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.75},
		{CFrame = CFrame.new(0.02, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 1.25},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 1.5},
	},
	['Meteor+'] = { 
		{CFrame = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.15},
		{CFrame = CFrame.new(0.02, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 0.15}
	},
	ExhiCloneAndMeteor = {
		{CFrame = CFrame.new(0.68, -0.7, 0.61) * CFrame.Angles(math.rad(-20), math.rad(45), math.rad(-85)), Time = 0.15},
		{CFrame = CFrame.new(0.695, -0.705, 0.595) * CFrame.Angles(math.rad(-60), math.rad(48), math.rad(-65)), Time = 0.3},
		{CFrame = CFrame.new(0.72, -0.72, 0.58) * CFrame.Angles(math.rad(-90), math.rad(52), math.rad(-40)), Time = 0.45},
		{CFrame = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.6},
		{CFrame = CFrame.new(0.02, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 0.75}
	},	
	ExhibitionClone = {
		{CFrame = CFrame.new(0.68, -0.7, 0.61) * CFrame.Angles(math.rad(-20), math.rad(45), math.rad(-85)), Time = 0.15},  
		{CFrame = CFrame.new(0.695, -0.705, 0.595) * CFrame.Angles(math.rad(-60), math.rad(48), math.rad(-65)), Time = 0.3},  
		{CFrame = CFrame.new(0.72, -0.72, 0.58) * CFrame.Angles(math.rad(-90), math.rad(52), math.rad(-40)), Time = 0.45}   
	},	
	LatestClone = {
		{CFrame = CFrame.new(0.68, -0.72, 0.12) * CFrame.Angles(math.rad(-63), math.rad(57), math.rad(-49)), Time = 0.4},
		{CFrame = CFrame.new(0.17, -1.18, 0.52) * CFrame.Angles(math.rad(-177), math.rad(56), math.rad(31)), Time = 0.4}
	},
	SpinClone = {
		{CFrame = CFrame.new(0.5, -0.6, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.15},
		{CFrame = CFrame.new(0.5, -0.55, 0) * CFrame.Angles(math.rad(0), math.rad(45), math.rad(0)), Time = 0.2},
		{CFrame = CFrame.new(0.5, -0.5, 0) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0)), Time = 0.15},
		{CFrame = CFrame.new(0.5, -0.55, 0) * CFrame.Angles(math.rad(0), math.rad(135), math.rad(0)), Time = 0.2},
		{CFrame = CFrame.new(0.5, -0.6, 0) * CFrame.Angles(math.rad(0), math.rad(180), math.rad(0)), Time = 0.15},
	},
	--inums contribution lawl
	["Inum's Ass"] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.05},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.15},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15},
		{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.12},
		{CFrame = CFrame.new(0.74, -0.92, 0.88) * CFrame.Angles(math.rad(147), math.rad(71), math.rad(53)), Time = 0.12},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), Time = 0.1},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), Time = 0.1},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), Time = 0.1},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), Time = 0.1},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
		{CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.8},
		{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.01},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(65), math.rad(-79)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-98), math.rad(35), math.rad(-56)), Time = 0.2},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-45), math.rad(70), math.rad(-90)), Time = 0.07},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-89), math.rad(70), math.rad(-38)), Time = 0.13},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-89), math.rad(68), math.rad(-56)), Time = 0.12},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-65), math.rad(68), math.rad(-35)), Time = 0.19},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(54), math.rad(-56)), Time = 0.08},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-98), math.rad(38), math.rad(-23)), Time = 0.15},
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(98), math.rad(-354)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-98), math.rad(65), math.rad(-68)), Time = 0.2},
		{CFrame = CFrame.new(0.67, -0.66, 0.57) * CFrame.Angles(math.rad(-46), math.rad(45.73), math.rad(-85)), Time = 0.1},
		{CFrame = CFrame.new(0.72, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(59), math.rad(-50)), Time = 0.2},
		{CFrame = CFrame.new(0.65, -0.68, 0.57) * CFrame.Angles(math.rad(-46), math.rad(45.73), math.rad(-76)), Time = 0.15},
		{CFrame = CFrame.new(0.77, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(76), math.rad(-32)), Time = 0.17},
		{CFrame = CFrame.new(0.63, -0.68, 0.57) * CFrame.Angles(math.rad(-46), math.rad(65), math.rad(-65)), Time = 0.21},
		{CFrame = CFrame.new(0.73, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(49), math.rad(-25)), Time = 0.26}
	},
	Ware = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(65), math.rad(-79)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-98), math.rad(35), math.rad(-56)), Time = 0.2}
	},
    Wearish = {
        {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
        {CFrame = CFrame.new(0.7, -0.71, 0.58) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.17}
    },
    --https://media.discordapp.net/attachments/1149060010177994792/1149060015655751720/image.png?ex=657a0288&is=65678d88&hm=a37a5b3a55e14f8874c6cae3e6dd658dd712199fb0351737ba365491aa3eed59&=&format=webp&quality=lossless&width=478&height=571
    --https://media.discordapp.net/attachments/1149060010177994792/1156242027973980190/attachment.gif?ex=6581ae4d&is=656f394d&hm=b3b8bfcfa3c356ef7d0618229af567c151ef7213fe3ae1f2dc03b773b407ffeb&=&width=329&height=571
    Assura = {
        {CFrame = CFrame.new(0.67, -0.66, 0.57) * CFrame.Angles(math.rad(-46), math.rad(45.73), math.rad(-85)), Time = 0.1},
        {CFrame = CFrame.new(0.72, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(59), math.rad(-50)), Time = 0.2}
    },
    ["Assura Old"] = {
        {CFrame = CFrame.new(0.65, -0.68, 0.57) * CFrame.Angles(math.rad(-46), math.rad(45.73), math.rad(-76)), Time = 0.15},
        {CFrame = CFrame.new(0.77, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(76), math.rad(-32)), Time = 0.17},
        {CFrame = CFrame.new(0.63, -0.68, 0.57) * CFrame.Angles(math.rad(-46), math.rad(65), math.rad(-65)), Time = 0.21},
        {CFrame = CFrame.new(0.73, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(49), math.rad(-25)), Time = 0.26}
    },
    ["Assura Combined"] = {
        {CFrame = CFrame.new(0.67, -0.66, 0.57) * CFrame.Angles(math.rad(-46), math.rad(45.73), math.rad(-85)), Time = 0.12},
        {CFrame = CFrame.new(0.72, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(59), math.rad(-50)), Time = 0.14},
        {CFrame = CFrame.new(0.65, -0.68, 0.57) * CFrame.Angles(math.rad(-46), math.rad(45.73), math.rad(-76)), Time = 0.15},
        {CFrame = CFrame.new(0.77, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(76), math.rad(-32)), Time = 0.17},
        {CFrame = CFrame.new(0.63, -0.68, 0.57) * CFrame.Angles(math.rad(-46), math.rad(65), math.rad(-65)), Time = 0.21},
        {CFrame = CFrame.new(0.73, -0.71, 0.62) * CFrame.Angles(math.rad(-73), math.rad(49), math.rad(-25)), Time = 0.26}
    },
	--scrxpted skidded from rise backend
    ScrxptedIsBLACK = {
        {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-89), math.rad(68), math.rad(-56)), Time = 0.12},
        {CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-65), math.rad(68), math.rad(-35)), Time = 0.19}
    },
	--lunar vape
	["Lunar Old"] = {
		{CFrame = CFrame.new(0.150, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.15},
		{CFrame = CFrame.new(0.02, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 0.15}
	},
	["Lunar New"] = {
		{CFrame = CFrame.new(0.86, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.17},
		{CFrame = CFrame.new(0.73, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 0.17}
	},
	["Lunar Fast"] = {
		{CFrame = CFrame.new(0.95, -0.8, 0.1) * CFrame.Angles(math.rad(-45), math.rad(40), math.rad(-75)), Time = 0.15},
		{CFrame = CFrame.new(0.40, -0.8, 0.05) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-95)), Time = 0.15}
	},
	["LiquidBounceX"] = {
		{CFrame = CFrame.new(-0.01, -0.3, -1.01) * CFrame.Angles(math.rad(-35), math.rad(90), math.rad(-90)), Time = 0.45},
		{CFrame = CFrame.new(-0.01, -0.3, -1.01) * CFrame.Angles(math.rad(-35), math.rad(70), math.rad(-90)), Time = 0.45},
		{CFrame = CFrame.new(-0.01, -0.3, 0.4) * CFrame.Angles(math.rad(-35), math.rad(70), math.rad(-90)), Time = 0.32}
	},
	["Auto Block"] = {
		{CFrame = CFrame.new(-0.6, -0.2, 0.3) * CFrame.Angles(math.rad(0), math.rad(80), math.rad(65)), Time = 0.15},
		{CFrame = CFrame.new(-0.6, -0.2, 0.3) * CFrame.Angles(math.rad(0), math.rad(110), math.rad(65)), Time = 0.15},
		{CFrame = CFrame.new(-0.6, -0.2, 0.3) * CFrame.Angles(math.rad(0), math.rad(65), math.rad(65)), Time = 0.15}
	},
	Switch = {
		{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Time = 0.1},
		{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), Time = 0.1}
	},
	Sideways = {
		{CFrame = CFrame.new(5, -3, 2) * CFrame.Angles(math.rad(120), math.rad(160), math.rad(140)), Time = 0.12},
		{CFrame = CFrame.new(5, -2.5, -1) * CFrame.Angles(math.rad(80), math.rad(180), math.rad(180)), Time = 0.12},
		{CFrame = CFrame.new(5, -3.4, -3.3) * CFrame.Angles(math.rad(45), math.rad(160), math.rad(190)), Time = 0.12},
		{CFrame = CFrame.new(5, -2.5, -1) * CFrame.Angles(math.rad(80), math.rad(180), math.rad(180)), Time = 0.12}
	},
	Stand = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1}
	},
}

	local function closestpos(block, pos)
		local blockpos = block:GetRenderCFrame()
		local startpos = (blockpos * CFrame.new(-(block.Size / 2))).p
		local endpos = (blockpos * CFrame.new((block.Size / 2))).p
		local speedCFrame = block.Position + (pos - block.Position)
		local x = startpos.X > endpos.X and endpos.X or startpos.X
		local y = startpos.Y > endpos.Y and endpos.Y or startpos.Y
		local z = startpos.Z > endpos.Z and endpos.Z or startpos.Z
		local x2 = startpos.X < endpos.X and endpos.X or startpos.X
		local y2 = startpos.Y < endpos.Y and endpos.Y or startpos.Y
		local z2 = startpos.Z < endpos.Z and endpos.Z or startpos.Z
		return Vector3.new(math.clamp(speedCFrame.X, x, x2), math.clamp(speedCFrame.Y, y, y2), math.clamp(speedCFrame.Z, z, z2))
	end

	local cachedSword
	local cachedSwordMeta
	local toolCached

	table.insert(vapeConnections, vapeEvents.InventoryAmountChanged.Event:Connect(function()
		cachedSword, cachedSwordMeta = nil, nil
	end))

	table.insert(vapeConnections, vapeEvents.InventoryChanged.Event:Connect(function()
		toolCached = nil
	end))

	local function getAttackData()
		if bedwarsStore.canSpin then
			local scythe = getItemNear('_scythe')
			if not scythe or not scythe.tool then return end
			local scythemeta = bedwars.ItemTable[scythe.tool.Name]
			return scythe, scythemeta
		end
		if cachedSword and cachedSwordMeta then
			return cachedSword, cachedSwordMeta
		end
		if GuiLibrary.ObjectsThatCanBeSaved['Lobby CheckToggle'].Api.Enabled then 
			if bedwarsStore.matchState == 0 then return end
		end
		if killauramouse.Enabled then
			if not inputService:IsMouseButtonPressed(0) then return end
		end
		if killauragui.Enabled then
			if getOpenApps() > (bedwarsStore.equippedKit == 'hannah' and 4 or 3) then return end
		end
		local sword = killaurahandcheck.Enabled and bedwarsStore.localHand or getSword()
		if not sword or not sword.tool then return end
		local swordmeta = bedwars.ItemTable[sword.tool.Name]
		if killaurahandcheck.Enabled then
			if bedwarsStore.localHand.Type ~= 'sword' or bedwars.KatanaController.chargingMaid then return end
		end
		cachedSword, cachedSwordMeta = sword, swordmeta
		return sword, swordmeta
	end

	local function autoBlockLoop()
		if not killauraautoblock.Enabled or not Killaura.Enabled then return end
		repeat
			if bedwarsStore.blockPlace < tick() and entityLibrary.isAlive then
				local shield = getItem('infernal_shield')
				if shield then 
					switchItem(shield.tool)
					if not lplr.Character:GetAttribute('InfernalShieldRaised') then
						bedwars.InfernalShieldController:raiseShield()
					end
				end
			end
			task.wait()
		until (not Killaura.Enabled) or (not killauraautoblock.Enabled)
	end

	local lastAttack = tick()
	local lastAttackedReal = {}
	local lastAttacked = setmetatable({}, {
		__index = lastAttackedReal,
		__newindex = function(t, k, v)
			lastAttack = v
			return rawset(t, k, v)
		end
	})
	lastAttackedReal = setmetatable(lastAttackedReal, {
		__index = function(self, index)
			rawset(lastAttacked, index, 0)
			return 0
		end
	})

	local noPlay = {
		[15] = true,
		[168] = true,
		[384] = true,
		[385] = true,
		[387] = true,
		[389] = true
	}

	local function rotateTo(position)
		vapeLookAtPosition = position
		local newcf = CFrame.lookAt(entityLibrary.character.HumanoidRootPart.Position, (killaurarotatey.Enabled and bedwarsStore.matchState ~= 0) and position or Vector3.new(position.X, entityLibrary.character.HumanoidRootPart.Position.Y, position.Z))
		if newcf == newcf then
			entityLibrary.character.HumanoidRootPart.CFrame = newcf
		end
	end

	local targetedPlayer
	local firstPlayerNear
	local lastmissed = tick()
	local function attackEntityAsync(plr, sword, swordmeta)
		if ((tick() - lastAttack) <= 0.09) then-- or (tick() - lastAttacked[plr.Player]) <= 0.09 then--(swordmeta.sword.attackSpeed / (ReducePackets.Enabled and ReduceKillAura.Enabled and 2.3 or 3.3)) then
			if killauraNearPlayer then
				targetedPlayer = plr
				firstPlayerNear = true
			end
			return -- continue
		end
		local root = plr.RootPart
		if not root then 
			return -- continue
		end
		local selfroot = (vapeOriginalRoot or entityLibrary.character.HumanoidRootPart)
		if killauraangle.Value < 360 then
			local localfacing = selfroot.CFrame.lookVector
			local vec = ((entityLibrary.ServerPredictions[plr.Player] or root.Position) - (vapeOverridePosition or selfroot.Position)).unit
			local angle = math.acos(localfacing:Dot(vec))
			if angle >= (math.rad(killauraangle.Value) / 2) then
				return -- continue
			end
		end
		if killauratargetframe.Walls.Enabled then
			if not bedwars.SwordController:canSee({player = plr.Player, getInstance = function() return plr.Character end}) then
				return -- continue
			end
		end
		if not ({WhitelistFunctions:GetWhitelist(plr.Player)})[2] then
			return -- continue
		end
		if killauranovape.Enabled and bedwarsStore.whitelist.clientUsers[plr.Player.Name] then
			return -- continue
		end
		if not firstPlayerNear then 
			firstPlayerNear = true
			killauraNearPlayer = true
			targetedPlayer = plr
			vapeTargetInfo.Targets.Killaura = {
				Humanoid = {
					Health = (plr.Character:GetAttribute('Health') or plr.Humanoid.Health) + getShieldAttribute(plr.Character),
					MaxHealth = plr.Character:GetAttribute('MaxHealth') or plr.Humanoid.MaxHealth
				},
				Player = plr.Player
			}
			if animationdelay <= tick() then
				animationdelay = tick() + (swordmeta.sword.respectAttackSpeedForEffects and swordmeta.sword.attackSpeed or (killaurasync.Enabled and 0.24 or 0.14))
				if not killauraswing.Enabled then 
					bedwars.SwordController:playSwordEffect(swordmeta, false)
				end
				if not killauraswing.Enabled and swordmeta.displayName:find(' Scythe') then 
					bedwars.ScytheController:playLocalAnimation()
				end
			end
		end
		local selfpos = selfroot.Position
		local rootpos = (entityLibrary.ServerPredictions[plr.Player] or root.Position)
		if vapeOverridePosition then
			if (vapeOverridePosition - rootpos).magnitude < (selfpos - rootpos).magnitude then
				selfpos = vapeOverridePosition
			end
		end
		local offset = rootpos - selfpos
		local newselfpos = selfpos + (killaurarange.Value > 14 and offset.magnitude > 14.4 and (offset.Unit * (offset.magnitude - 14)) or Vector3.zero)
		local chargedAttack = swordmeta.sword.chargedAttack
		local newrootpos = selfpos + offset.Unit * math.min(offset.magnitude, 18)
		killaurarealremote:FireServer({
			chargedAttack = {chargeRatio = chargedAttack and not chargedAttack.disableOnGrounded and 0.999 or 0},
			entityInstance = plr.Character,
			validate = {
				raycast = {
					cameraPosition = attackValue(newrootpos), 
					cursorDirection = attackValue(CFrame.new(newselfpos, newrootpos).lookVector)
				},
				targetPosition = attackValue(newrootpos),
				selfPosition = attackValue(newselfpos)
			},
			weapon = sword.tool,
		})
		lastAttacked[plr.Player] = tick()
		if not awaitinghit and killauranotify.Enabled then
			awaitinghit = true
			task.delay(0, function()
				if (tick() - bedwarsStore.lastDamaged[plr.Player]) > 0.44 and (tick() - bedwarsStore.lastDamaged[plr.Player]) < 0.8 then
					if lastmissed <= tick() then
						lastAttacked[plr.Player] = 0
						warningNotification('Killaura', 'missed hit!', 1)
						lastmissed = tick() + 0.1
					end
				end
				awaitinghit = false
			end)
		end
		task.spawn(function()
			bedwars.SwordController.lastAttack = workspace:GetServerTimeNow()
		end)
		bedwarsStore.attackReach = math.floor((selfpos - rootpos).magnitude * 100) / 100
		bedwarsStore.attackReachUpdate = tick() + 1
	end

    Killaura = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
        Name = 'Killaura',
        Function = function(callback)
            if callback then
				if killauraaimcirclepart then killauraaimcirclepart.Parent = gameCamera end
				if killaurarangecirclepart then killaurarangecirclepart.Parent = gameCamera end
				if killauraparticlepart then killauraparticlepart.Parent = gameCamera end

				task.spawn(function()
					local oldNearPlayer
					repeat
						task.wait()
						if (killauraanimation.Enabled and not killauraswing.Enabled) then
							if killauraNearPlayer then
								pcall(function()
									if originalArmC0 == nil then
										originalArmC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
									end
									if killauraplaying == false then
										killauraplaying = true
										for i,v in next, (anims[killauraanimmethod.Value]) do
											if (not Killaura.Enabled) or ((tick() - lastAttack > 0.6) and not killauraNearPlayer) then break end
											if not oldNearPlayer and killauraanimationtween.Enabled then
												gameCamera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0 * v.CFrame
												continue
											end
											killauracurrentanim = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(v.Time), {C0 = originalArmC0 * v.CFrame})
											killauracurrentanim:Play()
											task.wait(v.Time - 0.01)
										end
										killauraplaying = false
									end
								end)	
							end
							if not killauraNearPlayer and (tick() - lastAttack > 0.6) then
								oldNearPlayer = killauraNearPlayer
							end
						end
					until Killaura.Enabled == false
				end)

                oldViewmodelAnimation = bedwars.ViewmodelController.playAnimation
                oldPlaySound = bedwars.SoundManager.playSound
                bedwars.SoundManager.playSound = function(tab, soundid, ...)
                    if (soundid == bedwars.SoundList.SWORD_SWING_1 or soundid == bedwars.SoundList.SWORD_SWING_2) and Killaura.Enabled and killaurasound.Enabled and killauraNearPlayer then
                        return nil
                    end
                    return oldPlaySound(tab, soundid, ...)
                end
                bedwars.ViewmodelController.playAnimation = function(Self, id, ...)
                    if noPlay[id] and killauraNearPlayer and (killauraswing.Enabled or killauraanimation.Enabled) and entityLibrary.isAlive then
                        return nil
                    end
                    return oldViewmodelAnimation(Self, id, ...)
                end

				local targetedPlayer
				RunLoops:BindToHeartbeat('Killaura', function()
					if entityLibrary.isAlive then
						if targetedPlayer and killaurarotations.Enabled then
							task.spawn(rotateTo, entityLibrary.ServerPredictions[targetedPlayer.Player] or targetedPlayer.RootPart.Position)
						else
							vapeLookAtPosition = nil
						end
						if killauraaimcirclepart then 
							killauraaimcirclepart.Position = targetedPlayer and closestpos(targetedPlayer.RootPart, entityLibrary.character.HumanoidRootPart.Position) or Vector3.new(99999, 99999, 99999)
						end
						if killauraparticlepart then 
							killauraparticlepart.Position = targetedPlayer and targetedPlayer.RootPart.Position or Vector3.new(99999, 99999, 99999)
						end
						local Root = entityLibrary.character.HumanoidRootPart
						if Root then
							if killaurarangecirclepart then 
								killaurarangecirclepart.Position = Root.Position - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)
							end
							local Neck = entityLibrary.character.Head:FindFirstChild('Neck')
							local LowerTorso = Root.Parent and Root.Parent:FindFirstChild('LowerTorso')
							local RootC0 = LowerTorso and LowerTorso:FindFirstChild('Root')
							if Neck and RootC0 then
								if originalNeckC0 == nil then
									originalNeckC0 = Neck.C0.p
								end
								if originalRootC0 == nil then
									originalRootC0 = RootC0.C0.p
								end
								if originalRootC0 and killauracframe.Enabled then
									if targetedPlayer ~= nil then
										local targetPos = targetedPlayer.RootPart.Position + Vector3.new(0, 2, 0)
										local direction = (Vector3.new(targetPos.X, targetPos.Y, targetPos.Z) - entityLibrary.character.Head.Position).Unit
										local direction2 = (Vector3.new(targetPos.X, Root.Position.Y, targetPos.Z) - Root.Position).Unit
										local lookCFrame = (CFrame.new(Vector3.zero, (Root.CFrame):VectorToObjectSpace(direction)))
										local lookCFrame2 = (CFrame.new(Vector3.zero, (Root.CFrame):VectorToObjectSpace(direction2)))
										Neck.C0 = CFrame.new(originalNeckC0) * CFrame.Angles(lookCFrame.LookVector.Unit.y, 0, 0)
										RootC0.C0 = lookCFrame2 + originalRootC0
									else
										Neck.C0 = CFrame.new(originalNeckC0)
										RootC0.C0 = CFrame.new(originalRootC0)
									end
								end
							end
						end
					end
					for i,v in next, (killauraboxes) do 
						if v:IsA('BoxHandleAdornment') and v.Adornee then
							local cf = v.Adornee and v.Adornee.CFrame
							local onex, oney, onez = cf:ToEulerAnglesXYZ() 
							v.CFrame = CFrame.new() * CFrame.Angles(-onex, -oney, -onez)
						end
					end
				end)
				if killauraautoblock.Enabled then 
					task.spawn(autoBlockLoop)
				end
				local awaitinghit = false
                task.spawn(function()
					repeat
						task.wait()
						if not Killaura.Enabled then break end
						if killauraping.Enabled then 
							if bedwarsStore.pingSpiking then
								continue
							end
						end
						local plrs = AllNearPosition(killaurarange.Value, 1, killaurasortmethods[killaurasortmethod.Value], true, nil, false, false)
						firstPlayerNear = nil
						if #plrs > 0 then
							local sword, swordmeta = getAttackData()
							if sword then
								if toolCached ~= sword.tool then
									switchItem(sword.tool)
									toolCached = sword.tool
								end
								for i, plr in next, plrs do
									task.spawn(attackEntityAsync, plr, sword, swordmeta)
									break
								end
							end
						else
							vapeTargetInfo.Targets.Killaura = nil
						end
						if not firstPlayerNear then 
							targetedPlayer = nil
							killauraNearPlayer = false
							pcall(function()
								if (tick() - lastAttack > 0.6) then
									if originalArmC0 == nil then
										originalArmC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
									end
									if gameCamera.Viewmodel.RightHand.RightWrist.C0 ~= originalArmC0 then
										pcall(function()
											killauracurrentanim:Cancel()
										end)
										if killauraanimationtween.Enabled then 
											gameCamera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0
										else
											killauracurrentanim = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(0.1), {C0 = originalArmC0})
											killauracurrentanim:Play()
										end
									end
								end
							end)
						end
						for i,v in next, (killauraboxes) do 
							local attacked = killauratarget.Enabled and plrs[i] or nil
							v.Adornee = attacked and ((not killauratargethighlight.Enabled) and attacked.RootPart or (not GuiLibrary.ObjectsThatCanBeSaved.ChamsOptionsButton.Api.Enabled) and attacked.Character or nil)
						end
					until (not Killaura.Enabled)
				end)
            else
				vapeTargetInfo.Targets.Killaura = nil
				RunLoops:UnbindFromHeartbeat('Killaura') 
                killauraNearPlayer = false
				for i,v in next, (killauraboxes) do v.Adornee = nil end
				if killauraaimcirclepart then killauraaimcirclepart.Parent = nil end
				if killaurarangecirclepart then killaurarangecirclepart.Parent = nil end
				if killauraparticlepart then killauraparticlepart.Parent = nil end
                if oldViewmodelAnimation then
                	bedwars.ViewmodelController.playAnimation = oldViewmodelAnimation
				end
				if oldPlaySound then
                	bedwars.SoundManager.playSound = oldPlaySound
				end
                pcall(function()
					if entityLibrary.isAlive then
						local Root = entityLibrary.character.HumanoidRootPart
						if Root then
							local Neck = Root.Parent.Head.Neck
							if originalNeckC0 and originalRootC0 then 
								Neck.C0 = CFrame.new(originalNeckC0)
								Root.Parent.LowerTorso.Root.C0 = CFrame.new(originalRootC0)
							end
						end
					end
                    if originalArmC0 == nil then
                        originalArmC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
                    end
                    if gameCamera.Viewmodel.RightHand.RightWrist.C0 ~= originalArmC0 then
						pcall(function()
							killauracurrentanim:Cancel()
						end)
						if killauraanimationtween.Enabled then 
							gameCamera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0
						else
							killauracurrentanim = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(0.1), {C0 = originalArmC0})
							killauracurrentanim:Play()
						end
                    end
                end)
            end
        end,
        HoverText = 'Attack players around you\nwithout aiming at them.'
    })
    killauratargetframe = Killaura.CreateTargetWindow({})
	local sortmethods = {'Distance'}
	for i,v in next, (killaurasortmethods) do if i ~= 'Distance' then table.insert(sortmethods, i) end end
	killaurasortmethod = Killaura.CreateDropdown({
		Name = 'Sort',
		Function = function() end,
		List = sortmethods
	})
    killaurarange = Killaura.CreateSlider({
        Name = 'Attack range',
        Min = 1,
        Max = 18,
        Function = function(val) 
			if killaurarangecirclepart then 
				killaurarangecirclepart.Size = Vector3.new(val * 0.7, 0.01, val * 0.7)
			end
		end, 
        Default = 18
    })
    killauraangle = Killaura.CreateSlider({
        Name = 'Max angle',
        Min = 1,
        Max = 360,
        Function = function(val) end,
        Default = 360
    })
	local animmethods = {}
	for i,v in next, (anims) do table.insert(animmethods, i) end
    killauraanimmethod = Killaura.CreateDropdown({
        Name = 'Animation', 
        List = animmethods,
        Function = function(val) end
    })
	local oldviewmodel
	local oldraise
	local oldeffect
	killauraautoblock = Killaura.CreateToggle({
		Name = 'AutoBlock',
		Function = function(callback)
			if callback then
				task.spawn(function()
					oldviewmodel = bedwars.ViewmodelController.setHeldItem
					bedwars.ViewmodelController.setHeldItem = function(self, newItem, ...)
						if newItem and newItem.Name == 'infernal_shield' then 
							return
						end
						return oldviewmodel(self, newItem)
					end
					oldraise = bedwars.InfernalShieldController.raiseShield
					bedwars.InfernalShieldController.raiseShield = function(self)
						if os.clock() - self.lastShieldRaised < 0.4 then
							return
						end
						self.lastShieldRaised = os.clock()
						self.infernalShieldState:SendToServer({raised = true})
						self.raisedMaid:GiveTask(function()
							self.infernalShieldState:SendToServer({raised = false})
						end)
					end
					oldeffect = bedwars.InfernalShieldController.playEffect
					bedwars.InfernalShieldController.playEffect = function()
						return
					end
					if bedwars.ViewmodelController.heldItem and bedwars.ViewmodelController.heldItem.Name == 'infernal_shield' then 
						local sword, swordmeta = getSword()
						if sword then 
							bedwars.ViewmodelController:setHeldItem(sword.tool)
						end
					end
					task.spawn(autoBlockLoop)
				end)
			else
				if oldviewmodel then
					bedwars.ViewmodelController.setHeldItem = oldviewmodel
				end
				if oldraise then
					bedwars.InfernalShieldController.raiseShield = oldraise
				end
				if oldeffect then
					bedwars.InfernalShieldController.playEffect = oldeffect
				end
			end
		end,
		Default = true
	})
    killauramouse = Killaura.CreateToggle({
        Name = 'Require mouse down',
        Function = function() end,
		HoverText = 'Only attacks when left click is held.',
        Default = false
    })
    killauragui = Killaura.CreateToggle({
        Name = 'GUI Check',
        Function = function()
			cachedSword, cachedSwordMeta = nil, nil
		end,
		HoverText = 'Attacks when you are not in a GUI.'
    })
    killauratarget = Killaura.CreateToggle({
        Name = 'Show target',
        Function = function(callback) 
			if killauratargethighlight.Object then 
				killauratargethighlight.Object.Visible = callback
			end
		end,
		HoverText = 'Shows a red box over the opponent.'
    })
	killauratargethighlight = Killaura.CreateToggle({
		Name = 'Use New Highlight',
		Function = function(callback) 
			for i,v in next, (killauraboxes) do 
				v:Remove()
			end
			for i = 1, 10 do 
				local killaurabox
				if callback then 
					killaurabox = Instance.new('Highlight')
					killaurabox.FillTransparency = 0.39
					killaurabox.FillColor = Color3.fromHSV(killauracolor.Hue, killauracolor.Sat, killauracolor.Value)
					killaurabox.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					killaurabox.OutlineTransparency = 1
					killaurabox.Parent = GuiLibrary.MainGui
				else
					killaurabox = Instance.new('BoxHandleAdornment')
					killaurabox.Transparency = 0.39
					killaurabox.Color3 = Color3.fromHSV(killauracolor.Hue, killauracolor.Sat, killauracolor.Value)
					killaurabox.Adornee = nil
					killaurabox.AlwaysOnTop = true
					killaurabox.Size = Vector3.new(3, 6, 3)
					killaurabox.ZIndex = 11
					killaurabox.Parent = GuiLibrary.MainGui
				end
				killauraboxes[i] = killaurabox
			end
		end
	})
	killauratargethighlight.Object.BorderSizePixel = 0
	killauratargethighlight.Object.BackgroundTransparency = 0
	killauratargethighlight.Object.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	killauratargethighlight.Object.Visible = false
	killauracolor = Killaura.CreateColorSlider({
		Name = 'Target Color',
		Function = function(hue, sat, val) 
			for i,v in next, (killauraboxes) do 
				v[(killauratargethighlight.Enabled and 'FillColor' or 'Color3')] = Color3.fromHSV(hue, sat, val)
			end
			if killauraaimcirclepart then 
				killauraaimcirclepart.Color = Color3.fromHSV(hue, sat, val)
			end
			if killaurarangecirclepart then 
				killaurarangecirclepart.Color = Color3.fromHSV(hue, sat, val)
			end
		end,
		Default = 1
	})
	for i = 1, 10 do 
		local killaurabox = Instance.new('BoxHandleAdornment')
		killaurabox.Transparency = 0.5
		killaurabox.Color3 = Color3.fromHSV(killauracolor['Hue'], killauracolor['Sat'], killauracolor.Value)
		killaurabox.Adornee = nil
		killaurabox.AlwaysOnTop = true
		killaurabox.Size = Vector3.new(3, 6, 3)
		killaurabox.ZIndex = 11
		killaurabox.Parent = GuiLibrary.MainGui
		killauraboxes[i] = killaurabox
	end
    killauracframe = Killaura.CreateToggle({
        Name = 'Face target',
        Function = function() end,
		HoverText = 'Makes your character face the opponent.'
    })
	killaurarangecircle = Killaura.CreateToggle({
		Name = 'Range Visualizer',
		Function = function(callback)
			if callback then 
				killaurarangecirclepart = Instance.new('MeshPart')
				killaurarangecirclepart.MeshId = 'rbxassetid://3726303797'
				killaurarangecirclepart.Color = Color3.fromHSV(killauracolor['Hue'], killauracolor['Sat'], killauracolor.Value)
				killaurarangecirclepart.CanCollide = false
				killaurarangecirclepart.Anchored = true
				killaurarangecirclepart.Material = Enum.Material.Neon
				killaurarangecirclepart.Size = Vector3.new(killaurarange.Value * 0.7, 0.01, killaurarange.Value * 0.7)
				if Killaura.Enabled then 
					killaurarangecirclepart.Parent = gameCamera
				end
				bedwars.QueryUtil:setQueryIgnored(killaurarangecirclepart, true)
			else
				if killaurarangecirclepart then 
					killaurarangecirclepart:Destroy()
					killaurarangecirclepart = nil
				end
			end
		end
	})
	killauraaimcircle = Killaura.CreateToggle({
		Name = 'Aim Visualizer',
		Function = function(callback)
			if callback then 
				killauraaimcirclepart = Instance.new('Part')
				killauraaimcirclepart.Shape = Enum.PartType.Ball
				killauraaimcirclepart.Color = Color3.fromHSV(killauracolor['Hue'], killauracolor['Sat'], killauracolor.Value)
				killauraaimcirclepart.CanCollide = false
				killauraaimcirclepart.Anchored = true
				killauraaimcirclepart.Material = Enum.Material.Neon
				killauraaimcirclepart.Size = Vector3.new(0.5, 0.5, 0.5)
				if Killaura.Enabled then 
					killauraaimcirclepart.Parent = gameCamera
				end
				bedwars.QueryUtil:setQueryIgnored(killauraaimcirclepart, true)
			else
				if killauraaimcirclepart then 
					killauraaimcirclepart:Destroy()
					killauraaimcirclepart = nil
				end
			end
		end
	})
	killauraparticle = Killaura.CreateToggle({
		Name = 'Crit Particle',
		Function = function(callback)
			if callback then 
				killauraparticlepart = Instance.new('Part')
				killauraparticlepart.Transparency = 1
				killauraparticlepart.CanCollide = false
				killauraparticlepart.Anchored = true
				killauraparticlepart.Size = Vector3.new(3, 6, 3)
				killauraparticlepart.Parent = cam
				bedwars.QueryUtil:setQueryIgnored(killauraparticlepart, true)
				local particle = Instance.new('ParticleEmitter')
				particle.Lifetime = NumberRange.new(0.5)
				particle.Rate = 500
				particle.Speed = NumberRange.new(0)
				particle.RotSpeed = NumberRange.new(180)
				particle.Enabled = true
				particle.Size = NumberSequence.new(0.3)
				particle.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(67, 10, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 98, 255))})
				particle.Parent = killauraparticlepart
			else
				if killauraparticlepart then 
					killauraparticlepart:Destroy()
					killauraparticlepart = nil
				end
			end
		end
	})
    killaurasound = Killaura.CreateToggle({
        Name = 'No Swing Sound',
        Function = function() end,
		HoverText = 'Removes the swinging sound.'
    })
    killauraswing = Killaura.CreateToggle({
        Name = 'No Swing',
        Function = function() end,
		HoverText = 'Removes the swinging animation.'
    })
    killaurahandcheck = Killaura.CreateToggle({
        Name = 'Limit to items',
        Function = function()
			cachedSword, cachedSwordMeta = nil, nil
		end,
		HoverText = 'Only attacks when your sword is held.'
    })
    killaurasmart = Killaura.CreateToggle({
        Name = 'Smart',
        Function = function()
			vapeEvents.InventoryAmountChanged:Fire()
			cachedSword, cachedSwordMeta = nil, nil
		end,
		HoverText = 'Decides your weapon based on dps'
    })
    killaurarotations = Killaura.CreateToggle({
        Name = 'Serverside Rotations',
        Function = function(callback)
			if killaurarotatey.Object then killaurarotatey.Object.Visible = callback end
		end,
		HoverText = 'For the funny hit',
        Default = true
    })
    killaurarotatey = Killaura.CreateToggle({
        Name = 'Rotate Y',
        Function = function() end,
		HoverText = 'Rotates your y with the server rotations to hit from above',
        Default = true
    })
	killaurarotatey.Object.Visible = killaurarotations.Enabled
	killauraping = Killaura.CreateToggle({
        Name = 'Preserve Ping',
        Function = function() end,
		HoverText = 'Pauses attacks while ping spiking',
        Default = true
    })
    killauraanimation = Killaura.CreateToggle({
        Name = 'Custom Animation',
        Function = function(callback)
			if killauraanimationtween.Object then killauraanimationtween.Object.Visible = callback end
		end,
		HoverText = 'Uses a custom animation for swinging'
    })
	killauraanimationtween = Killaura.CreateToggle({
		Name = 'No Tween',
		Function = function() end,
		HoverText = 'Disable\'s the in and out ease'
	})
	killauraanimationtween.Object.Visible = false
	killauranotify = Killaura.CreateToggle({
        Name = 'Notify Missed',
        Function = function() end,
		HoverText = 'Notifies you if you missed a hit'
    })
	killaurasync = Killaura.CreateToggle({
        Name = 'Synced Animation',
        Function = function() end,
		HoverText = 'Times animation with hit attempt'
    })
	killauranovape = Killaura.CreateToggle({
		Name = 'No Vape',
		Function = function() end,
		HoverText = 'no hit vape user'
	})
	killauranovape.Object.Visible = false
	task.spawn(function()
		repeat task.wait() until WhitelistFunctions.Loaded
		killauranovape.Object.Visible = WhitelistFunctions.LocalPriority ~= 0
	end)
end)

local LongJump = {Enabled = false}
runFunction(function()
	local damagetimer = 0
	local damagetimertick = 0
	local directionvec
	local LongJumpSpeed = {Value = 1.5}
	local projectileRemote = bedwars.ClientHandler:Get(bedwars.ProjectileRemote)

	local function calculatepos(vec)
		local returned = vec
		if entityLibrary.isAlive then 
			local newray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, returned, bedwarsStore.blockRaycast)
			if newray then returned = (newray.Position - entityLibrary.character.HumanoidRootPart.Position) end
		end
		return returned
	end

	local damagemethods = {
		fireball = function(fireball, pos)
			if not LongJump.Enabled then return end
			pos = pos - (entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 0.2)
			if not (getPlacedBlock(pos - Vector3.new(0, 3, 0)) or getPlacedBlock(pos - Vector3.new(0, 6, 0))) then
				local sound = Instance.new('Sound')
				sound.SoundId = 'rbxassetid://4809574295'
				sound.Parent = workspace
				sound.Ended:Connect(function()
					sound:Destroy()
				end)
				sound:Play()
			end
			local origpos = pos
			local offsetshootpos = (CFrame.new(pos, pos + Vector3.new(0, -60, 0)) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))).p
			local ray = workspace:Raycast(pos, Vector3.new(0, -30, 0), bedwarsStore.blockRaycast)
			if ray then
				pos = ray.Position
				offsetshootpos = pos
			end
			task.spawn(function()
				switchItem(fireball.tool)
				bedwars.ProjectileController:createLocalProjectile(bedwars.ProjectileMeta.fireball, 'fireball', 'fireball', offsetshootpos, '', Vector3.new(0, -60, 0), {drawDurationSeconds = 1})
				projectileRemote:CallServerAsync(fireball.tool, 'fireball', 'fireball', offsetshootpos, pos, Vector3.new(0, -60, 0), game:GetService('HttpService'):GenerateGUID(true), {drawDurationSeconds = 1, shotId = game:GetService('HttpService'):GenerateGUID(false)}, workspace:GetServerTimeNow() - 0.045)
			end)
		end,
		tnt = function(tnt, pos2)
			if not LongJump.Enabled then return end
			local pos = Vector3.new(pos2.X, getScaffold(Vector3.new(0, pos2.Y - (((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight) - 1.5), 0)).Y, pos2.Z)
			local block = bedwars.placeBlock(pos, 'tnt')
		end,
		cannon = function(tnt, pos2)
			task.spawn(function()
				local pos = Vector3.new(pos2.X, getScaffold(Vector3.new(0, pos2.Y - (((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight) - 1.5), 0)).Y, pos2.Z)
				local block = bedwars.placeBlock(pos, 'cannon')
				task.delay(0.1, function()
					local block, pos2 = getPlacedBlock(pos)
					if block and block.Name == 'cannon' and (entityLibrary.character.HumanoidRootPart.CFrame.p - block.Position).Magnitude < 20 then 
						switchToAndUseTool(block)
						local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
						local damage = bedwars.BlockController:calculateBlockDamage(lplr, {
							blockPosition = pos2
						})
						bedwars.ClientHandler:Get(bedwars.CannonAimRemote):SendToServer({
							cannonBlockPos = pos2,
							lookVector = vec
						})
						local broken = 0.1
						if damage < block:GetAttribute('Health') then 
							task.spawn(function()
								broken = 0.4
								bedwars.breakBlock(block.Position, true, getBestBreakSide(block.Position), true, true)
							end)
						end
						task.delay(broken, function()
							for i = 1, 3 do 
								local call = bedwars.ClientHandler:Get(bedwars.CannonLaunchRemote):CallServer({cannonBlockPos = bedwars.BlockController:getBlockPosition(block.Position)})
								if call then
									bedwars.breakBlock(block.Position, true, getBestBreakSide(block.Position), true, true)
									task.delay(0.1, function()
										damagetimer = LongJumpSpeed.Value * 5
										damagetimertick = tick() + 2.5
										directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
									end)
									break
								end
								task.wait(0.1)
							end
						end)
					end
				end)	
			end)
		end,
		wood_dao = function(tnt, pos2)
			task.spawn(function()
				switchItem(tnt.tool)
				if not (not lplr.Character:GetAttribute('CanDashNext') or lplr.Character:GetAttribute('CanDashNext') < workspace:GetServerTimeNow()) then
					repeat task.wait() until (not lplr.Character:GetAttribute('CanDashNext') or lplr.Character:GetAttribute('CanDashNext') < workspace:GetServerTimeNow()) or not LongJump.Enabled
				end
				if LongJump.Enabled then
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					replicatedStorageService['events-@easy-games/game-core:shared/game-core-networking@getEvents.Events'].useAbility:FireServer('dash', {
						direction = vec,
						origin = entityLibrary.character.HumanoidRootPart.CFrame.p,
						weapon = tnt.itemType
					})
					damagetimer = LongJumpSpeed.Value * 3.5
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end,
		jade_hammer = function(tnt, pos2)
			task.spawn(function()
				if not bedwars.AbilityController:canUseAbility('jade_hammer_jump') then
					repeat task.wait() until bedwars.AbilityController:canUseAbility('jade_hammer_jump') or not LongJump.Enabled
					task.wait(0.1)
				end
				if bedwars.AbilityController:canUseAbility('jade_hammer_jump') and LongJump.Enabled then
					bedwars.AbilityController:useAbility('jade_hammer_jump')
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					damagetimer = LongJumpSpeed.Value * 2.75
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end,
		void_axe = function(tnt, pos2)
			task.spawn(function()
				if not bedwars.AbilityController:canUseAbility('void_axe_jump') then
					repeat task.wait() until bedwars.AbilityController:canUseAbility('void_axe_jump') or not LongJump.Enabled
					task.wait(0.1)
				end
				if bedwars.AbilityController:canUseAbility('void_axe_jump') and LongJump.Enabled then
					bedwars.AbilityController:useAbility('void_axe_jump')
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					damagetimer = LongJumpSpeed.Value * 2.75
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end
	}
	damagemethods.stone_dao = damagemethods.wood_dao
	damagemethods.iron_dao = damagemethods.wood_dao
	damagemethods.diamond_dao = damagemethods.wood_dao
	damagemethods.emerald_dao = damagemethods.wood_dao

	local oldgrav
	local LongJumpacprogressbarframe = Instance.new('Frame')
	LongJumpacprogressbarframe.AnchorPoint = Vector2.new(0.5, 0)
	LongJumpacprogressbarframe.Position = UDim2.new(0.5, 0, 1, -200)
	LongJumpacprogressbarframe.Size = UDim2.new(0.2, 0, 0, 20)
	LongJumpacprogressbarframe.BackgroundTransparency = 0.5
	LongJumpacprogressbarframe.BorderSizePixel = 0
	LongJumpacprogressbarframe.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Value)
	LongJumpacprogressbarframe.Visible = LongJump.Enabled
	LongJumpacprogressbarframe.Parent = GuiLibrary.MainGui
	local LongJumpacprogressbarframe2 = LongJumpacprogressbarframe:Clone()
	LongJumpacprogressbarframe2.AnchorPoint = Vector2.new(0, 0)
	LongJumpacprogressbarframe2.Position = UDim2.new(0, 0, 0, 0)
	LongJumpacprogressbarframe2.Size = UDim2.new(1, 0, 0, 20)
	LongJumpacprogressbarframe2.BackgroundTransparency = 0
	LongJumpacprogressbarframe2.Visible = true
	LongJumpacprogressbarframe2.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Value)
	LongJumpacprogressbarframe2.Parent = LongJumpacprogressbarframe
	local LongJumpacprogressbartext = Instance.new('TextLabel')
	LongJumpacprogressbartext.Text = '2.5s'
	LongJumpacprogressbartext.Font = Enum.Font.Gotham
	LongJumpacprogressbartext.TextStrokeTransparency = 0
	LongJumpacprogressbartext.TextColor3 =  Color3.new(0.9, 0.9, 0.9)
	LongJumpacprogressbartext.TextSize = 20
	LongJumpacprogressbartext.Size = UDim2.new(1, 0, 1, 0)
	LongJumpacprogressbartext.BackgroundTransparency = 1
	LongJumpacprogressbartext.Position = UDim2.new(0, 0, -1, 0)
	LongJumpacprogressbartext.Parent = LongJumpacprogressbarframe
	LongJump = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'LongJump',
		Function = function(callback)
			if callback then
				table.insert(LongJump.Connections, vapeEvents.EntityDamageEvent.Event:Connect(function(damageTable)
					if damageTable.entityInstance == lplr.Character and (not damageTable.knockbackMultiplier or not damageTable.knockbackMultiplier.disabled) then 
						local knockbackBoost = damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.horizontal and damageTable.knockbackMultiplier.horizontal * LongJumpSpeed.Value or LongJumpSpeed.Value
						if damagetimertick < tick() or knockbackBoost >= damagetimer then
							damagetimer = knockbackBoost
							damagetimertick = tick() + 2.5
							local newDirection = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
							directionvec = Vector3.new(newDirection.X, 0, newDirection.Z).Unit
						end
					end
				end))
				task.spawn(function()
					task.spawn(function()
						repeat
							task.wait()
							if LongJumpacprogressbarframe then
								LongJumpacprogressbarframe.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Value)
								LongJumpacprogressbarframe2.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Value)
							end
						until (not LongJump.Enabled)
					end)
					local LongJumpOrigin = entityLibrary.isAlive and entityLibrary.character.HumanoidRootPart.Position
					local tntcheck
					for i,v in next, (damagemethods) do 
						local item = getItem(i)
						if item then
							if i == 'tnt' then 
								local pos = getScaffold(LongJumpOrigin)
								tntcheck = Vector3.new(pos.X, LongJumpOrigin.Y, pos.Z)
								v(item, pos)
							else
								v(item, LongJumpOrigin)
							end
							break
						end
					end
					local changecheck
					LongJumpacprogressbarframe.Visible = true
					RunLoops:BindToHeartbeat('LongJump', function(dt)
						if entityLibrary.isAlive then 
							if entityLibrary.character.Humanoid.Health <= 0 then 
								LongJump.ToggleButton(false)
								return
							end
							if not LongJumpOrigin then 
								LongJumpOrigin = entityLibrary.character.HumanoidRootPart.Position
							end
							local newval = damagetimer ~= 0
							if changecheck ~= newval then 
								if newval then 
									LongJumpacprogressbarframe2:TweenSize(UDim2.new(0, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 2.5, true)
								else
									LongJumpacprogressbarframe2:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
								end
								changecheck = newval
							end
							if newval then 
								local newnum = math.max(math.floor((damagetimertick - tick()) * 10) / 10, 0)
								if LongJumpacprogressbartext then 
									LongJumpacprogressbartext.Text = newnum..'s'
								end
								if directionvec == nil then 
									directionvec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
								end
								local longJumpCFrame = Vector3.new(directionvec.X, 0, directionvec.Z)
								local newvelo = longJumpCFrame.Unit == longJumpCFrame.Unit and longJumpCFrame.Unit * (newnum > 1 and damagetimer or 20) or Vector3.zero
								newvelo = Vector3.new(newvelo.X, 0, newvelo.Z)
								longJumpCFrame = longJumpCFrame * (getSpeed() + 3) * dt
								local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, longJumpCFrame, bedwarsStore.blockRaycast)
								if ray then 
									longJumpCFrame = Vector3.zero
									newvelo = Vector3.zero
								end

								entityLibrary.character.HumanoidRootPart.Velocity = newvelo
								entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + longJumpCFrame
							else
								LongJumpacprogressbartext.Text = '2.5s'
								entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(LongJumpOrigin, LongJumpOrigin + entityLibrary.character.HumanoidRootPart.CFrame.lookVector)
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
								if tntcheck then 
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(tntcheck + entityLibrary.character.HumanoidRootPart.CFrame.lookVector, tntcheck + (entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 2))
								end
							end
						else
							if LongJumpacprogressbartext then 
								LongJumpacprogressbartext.Text = '2.5s'
							end
							LongJumpOrigin = nil
							tntcheck = nil
						end
					end)
				end)
			else
				LongJumpacprogressbarframe.Visible = false
				RunLoops:UnbindFromHeartbeat('LongJump')
				directionvec = nil
				tntcheck = nil
				LongJumpOrigin = nil
				damagetimer = 0
				damagetimertick = 0
			end
		end, 
		HoverText = 'Lets you jump farther (Not landing on same level & Spamming can lead to lagbacks)'
	})
	LongJumpSpeed = LongJump.CreateSlider({
		Name = 'Speed',
		Min = 1,
		Max = 52,
		Function = function() end,
		Default = 52
	})
end)

runFunction(function()
	local NoFall = {Enabled = false}
	local oldfall
	NoFall = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'NoFall',
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait(0.5)
						bedwars.ClientHandler:Get('GroundHit'):SendToServer()
					until (not NoFall.Enabled)
				end)
			end
		end, 
		HoverText = 'Prevents taking fall damage.'
	})
end)

runFunction(function()
	local NoSlowdown = {Enabled = false}
	local OldSetSpeedFunc
	NoSlowdown = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'NoSlowdown',
		Function = function(callback)
			if callback then
				OldSetSpeedFunc = bedwars.SprintController.setSpeed
				bedwars.SprintController.setSpeed = function(tab1, val1)
					local hum = entityLibrary.character.Humanoid
					if hum then
						hum.WalkSpeed = math.max(20 * tab1.moveSpeedMultiplier, 20)
					end
				end
				bedwars.SprintController:setSpeed(20)
			else
				bedwars.SprintController.setSpeed = OldSetSpeedFunc
				bedwars.SprintController:setSpeed(20)
				OldSetSpeedFunc = nil
			end
		end, 
		HoverText = 'Prevents slowing down when using items.'
	})
end)

local spiderActive = false
local holdingshift = false
runFunction(function()
	local activatePhase = false
	local oldActivatePhase = false
	local PhaseDelay = tick()
	local Phase = {Enabled = false}
	local PhaseStudLimit = {Value = 1}
	local PhaseModifiedParts = {}
	local raycastparameters = RaycastParams.new()
	raycastparameters.RespectCanCollide = true
	raycastparameters.FilterType = Enum.RaycastFilterType.Whitelist
	local overlapparams = OverlapParams.new()
	overlapparams.RespectCanCollide = true

	local function isPointInMapOccupied(p)
		overlapparams.FilterDescendantsInstances = {lplr.Character, gameCamera}
		local possible = workspace:GetPartBoundsInBox(CFrame.new(p), Vector3.new(1, 2, 1), overlapparams)
		return (#possible == 0)
	end

	Phase = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'Phase',
		Function = function(callback)
			if callback then
				RunLoops:BindToHeartbeat('Phase', function()
					if entityLibrary.isAlive and entityLibrary.character.Humanoid.MoveDirection ~= Vector3.zero and (not GuiLibrary.ObjectsThatCanBeSaved.SpiderOptionsButton.Api.Enabled or holdingshift) then
						if PhaseDelay <= tick() then
							raycastparameters.FilterDescendantsInstances = {bedwarsStore.blocks, collectionService:GetTagged('spawn-cage'), workspace.SpectatorPlatform}
							local PhaseRayCheck = workspace:Raycast(entityLibrary.character.Head.CFrame.p, entityLibrary.character.Humanoid.MoveDirection * 1.15, raycastparameters)
							if PhaseRayCheck then
								local PhaseDirection = (PhaseRayCheck.Normal.Z ~= 0 or not PhaseRayCheck.Instance:GetAttribute('GreedyBlock')) and 'Z' or 'X'
								if PhaseRayCheck.Instance.Size[PhaseDirection] <= PhaseStudLimit.Value * 3 and PhaseRayCheck.Instance.CanCollide and PhaseRayCheck.Normal.Y == 0 then
									local PhaseDestination = entityLibrary.character.HumanoidRootPart.CFrame + (PhaseRayCheck.Normal * (-(PhaseRayCheck.Instance.Size[PhaseDirection]) - (entityLibrary.character.HumanoidRootPart.Size.X / 1.5)))
									if isPointInMapOccupied(PhaseDestination.p) then
										PhaseDelay = tick() + 1
										entityLibrary.character.HumanoidRootPart.CFrame = PhaseDestination
									end
								end
							end
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat('Phase')
			end
		end,
		HoverText = 'Lets you Phase/Clip through walls. (Hold shift to use Phase over spider)'
	})
	PhaseStudLimit = Phase.CreateSlider({
		Name = 'Blocks',
		Min = 1,
		Max = 3,
		Function = function() end
	})
end)

runFunction(function()
	local oldCalculateAim
	local BowAimbotProjectiles = {Enabled = false}
	local BowAimbotPart = {Value = 'HumanoidRootPart'}
	local BowAimbotFOV = {Value = 1000}
	local noveloproj = {
		'fireball',
		'telepearl'
	}

	local BowAimbot = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'ProjectileAimbot',
		Function = function(callback)
			if callback then
				oldCalculateAim = bedwars.ProjectileController.calculateImportantLaunchValues
				bedwars.ProjectileController.calculateImportantLaunchValues = function(self, projmeta, worldmeta, shootpospart, ...)
					local plr = EntityNearMouse(BowAimbotFOV.Value, true)
					if plr then
						local startPos = self:getLaunchPosition(shootpospart)
						if not startPos then
							return oldCalculateAim(self, projmeta, worldmeta, shootpospart, ...)
						end

						if (not BowAimbotProjectiles.Enabled) and projmeta.projectile:find('arrow') == nil then
							return oldCalculateAim(self, projmeta, worldmeta, shootpospart, ...)
						end

						local projmetatab = projmeta:getProjectileMeta()
						local projectilePrediction = (worldmeta and projmetatab.predictionLifetimeSec or projmetatab.lifetimeSec or 3)
						local projectileSpeed = (projmeta.projectile:find('arrow') and 240 or projmetatab.launchVelocity or 100)
						local gravity = (projmetatab.gravitationalAcceleration or 196.2)
						local projectileGravity = gravity * projmeta.gravityMultiplier
						local offsetStartPos = startPos + projmeta.fromPositionOffset
						local pos = plr.Character[BowAimbotPart.Value].Position
						local playerGravity = workspace.Gravity
						local balloons = plr.Character:GetAttribute('InflatedBalloons')

						if balloons and balloons > 0 then 
							playerGravity = (workspace.Gravity * (1 - ((balloons >= 4 and 1.2 or balloons >= 3 and 1 or 0.975))))
						end

						if plr.Character.PrimaryPart:FindFirstChild('rbxassetid://8200754399') then 
							playerGravity = (workspace.Gravity * 0.3)
						end

						local shootpos, shootvelo = predictGravity(pos, plr.Character.HumanoidRootPart.Velocity, (pos - offsetStartPos).Magnitude / projectileSpeed, plr, playerGravity)
						if table.find(noveloproj, projmeta.projectile) then
							shootpos = pos
							shootvelo = Vector3.zero
						end
						
						local newlook = CFrame.new(offsetStartPos, shootpos) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, 0))
						shootpos = newlook.p + (newlook.lookVector * (offsetStartPos - shootpos).magnitude)
						local calculated = LaunchDirection(offsetStartPos, shootpos, projectileSpeed, projectileGravity, false)
						oldmove = plr.Character.Humanoid.MoveDirection
						if calculated then
							return {
								initialVelocity = calculated,
								positionFrom = offsetStartPos,
								deltaT = projectilePrediction,
								gravitationalAcceleration = projectileGravity,
								drawDurationSeconds = 5
							}
						end
					end
					return oldCalculateAim(self, projmeta, worldmeta, shootpospart, ...)
				end
			else
				bedwars.ProjectileController.calculateImportantLaunchValues = oldCalculateAim
			end
		end
	})
	BowAimbotPart = BowAimbot.CreateDropdown({
		Name = 'Part',
		List = {'HumanoidRootPart', 'Head'},
		Function = function() end
	})
	BowAimbotFOV = BowAimbot.CreateSlider({
		Name = 'FOV',
		Function = function() end,
		Min = 1,
		Max = 1000,
		Default = 1000
	})
	BowAimbotProjectiles = BowAimbot.CreateToggle({
		Name = 'Other Projectiles',
		Function = function() end,
		Default = true
	})
end)

--until I find a way to make the spam switch item thing not bad I'll just get rid of it, sorry.

local Scaffold = {Enabled = false}
runFunction(function()
	local scaffoldtext = Instance.new('TextLabel')
	scaffoldtext.Font = Enum.Font.SourceSans
	scaffoldtext.TextSize = 20
	scaffoldtext.BackgroundTransparency = 1
	scaffoldtext.TextColor3 = Color3.fromRGB(255, 0, 0)
	scaffoldtext.Size = UDim2.new(0, 0, 0, 0)
	scaffoldtext.Position = UDim2.new(0.5, 0, 0.5, 30)
	scaffoldtext.Text = '0'
	scaffoldtext.Visible = false
	scaffoldtext.Parent = GuiLibrary.MainGui
	local ScaffoldExpand = {Value = 1}
	local ScaffoldDiagonal = {Enabled = false}
	local ScaffoldTower = {Enabled = false}
	local ScaffoldDownwards = {Enabled = false}
	local ScaffoldStopMotion = {Enabled = false}
	local ScaffoldBlockCount = {Enabled = false}
	local ScaffoldHandCheck = {Enabled = false}
	local ScaffoldMouseCheck = {Enabled = false}
	local ScaffoldAnimation = {Enabled = false}
	local scaffoldstopmotionval = false
	local scaffoldposcheck = tick()
	local scaffoldstopmotionpos = Vector3.zero
	local scaffoldposchecklist = {}
	task.spawn(function()
		for x = -3, 3, 3 do 
			for y = -3, 3, 3 do 
				for z = -3, 3, 3 do 
					if Vector3.new(x, y, z) ~= Vector3.new(0, 0, 0) then 
						table.insert(scaffoldposchecklist, Vector3.new(x, y, z)) 
					end 
				end 
			end 
		end
	end)

	local function checkblocks(pos)
		for i,v in next, (scaffoldposchecklist) do
			if getPlacedBlock(pos + v) then
				return true
			end
		end
		return false
	end

	local function closestpos(block, pos)
		local startpos = block.Position - (block.Size / 2) - Vector3.new(1.5, 1.5, 1.5)
		local endpos = block.Position + (block.Size / 2) + Vector3.new(1.5, 1.5, 1.5)
		local speedCFrame = block.Position + (pos - block.Position)
		return Vector3.new(math.clamp(speedCFrame.X, startpos.X, endpos.X), math.clamp(speedCFrame.Y, startpos.Y, endpos.Y), math.clamp(speedCFrame.Z, startpos.Z, endpos.Z))
	end

	local function getclosesttop(newmag, pos)
		local closest, closestmag = pos, newmag * 3
		if entityLibrary.isAlive then 
			for i,v in next, (bedwarsStore.blocks) do 
				local close = closestpos(v, pos)
				local mag = (close - pos).magnitude
				if mag <= closestmag then 
					closest = close
					closestmag = mag
				end
			end
		end
		return closest
	end

	local oldspeed
	Scaffold = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'Scaffold',
		Function = function(callback)
			if callback then
				scaffoldtext.Visible = ScaffoldBlockCount.Enabled
				if entityLibrary.isAlive then 
					scaffoldstopmotionpos = entityLibrary.character.HumanoidRootPart.CFrame.p
				end
				task.spawn(function()
					repeat
						task.wait()
						if ScaffoldHandCheck.Enabled then 
							if bedwarsStore.localHand.Type ~= 'block' then continue end
						end
						if ScaffoldMouseCheck.Enabled then 
							if not inputService:IsMouseButtonPressed(0) then continue end
						end
						if entityLibrary.isAlive then
							local wool, woolamount = getWool()
							if bedwarsStore.localHand.Type == 'block' then
								wool = bedwarsStore.localHand.tool.Name
								woolamount = getItem(bedwarsStore.localHand.tool.Name).amount or 0
							elseif (not wool) then 
								wool, woolamount = getBlock()
							end

							scaffoldtext.Text = (woolamount and tostring(woolamount) or '0')
							scaffoldtext.TextColor3 = woolamount and (woolamount >= 128 and Color3.fromRGB(9, 255, 198) or woolamount >= 64 and Color3.fromRGB(255, 249, 18)) or Color3.fromRGB(255, 0, 0)
							if not wool then continue end

							local towering = ScaffoldTower.Enabled and inputService:IsKeyDown(Enum.KeyCode.Space) and game:GetService('UserInputService'):GetFocusedTextBox() == nil
							if towering then
								if (not scaffoldstopmotionval) and ScaffoldStopMotion.Enabled then
									scaffoldstopmotionval = true
									scaffoldstopmotionpos = entityLibrary.character.HumanoidRootPart.CFrame.p
								end
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 28, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								if ScaffoldStopMotion.Enabled and scaffoldstopmotionval then
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(scaffoldstopmotionpos.X, entityLibrary.character.HumanoidRootPart.CFrame.p.Y, scaffoldstopmotionpos.Z))
								end
							else
								scaffoldstopmotionval = false
							end
							
							for i = 1, ScaffoldExpand.Value do
								local speedCFrame = getScaffold((entityLibrary.character.HumanoidRootPart.Position + ((scaffoldstopmotionval and Vector3.zero or entityLibrary.character.Humanoid.MoveDirection) * (i * 3.5))) + Vector3.new(0, -((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight + (inputService:IsKeyDown(Enum.KeyCode.LeftShift) and ScaffoldDownwards.Enabled and 4.5 or 1.5))), 0)
								speedCFrame = Vector3.new(speedCFrame.X, speedCFrame.Y - (towering and 4 or 0), speedCFrame.Z)
								if speedCFrame ~= oldpos then
									if not checkblocks(speedCFrame) then
										local oldspeedCFrame = speedCFrame
										speedCFrame = getScaffold(getclosesttop(20, speedCFrame))
										if getPlacedBlock(speedCFrame) then speedCFrame = oldspeedCFrame end
									end
									if ScaffoldAnimation.Enabled then 
										if not getPlacedBlock(speedCFrame) then
										bedwars.ViewmodelController:playAnimation(bedwars.AnimationType.FP_USE_ITEM)
										end
									end
									task.spawn(bedwars.placeBlock, speedCFrame, wool, ScaffoldAnimation.Enabled)
									if ScaffoldExpand.Value > 1 then 
										task.wait()
									end
									oldpos = speedCFrame
								end
							end
						end
					until (not Scaffold.Enabled)
				end)
			else
				scaffoldtext.Visible = false
				oldpos = Vector3.zero
				oldpos2 = Vector3.zero
			end
		end, 
		HoverText = 'Helps you make bridges/scaffold walk.'
	})
	ScaffoldExpand = Scaffold.CreateSlider({
		Name = 'Expand',
		Min = 1,
		Max = 8,
		Function = function(val) end,
		Default = 1,
		HoverText = 'Build range'
	})
	ScaffoldDiagonal = Scaffold.CreateToggle({
		Name = 'Diagonal', 
		Function = function(callback) end,
		Default = true
	})
	ScaffoldTower = Scaffold.CreateToggle({
		Name = 'Tower', 
		Function = function(callback) 
			if ScaffoldStopMotion.Object then
				ScaffoldTower.Object.ToggleArrow.Visible = callback
				ScaffoldStopMotion.Object.Visible = callback
			end
		end
	})
	ScaffoldMouseCheck = Scaffold.CreateToggle({
		Name = 'Require mouse down', 
		Function = function(callback) end,
		HoverText = 'Only places when left click is held.',
	})
	ScaffoldDownwards  = Scaffold.CreateToggle({
		Name = 'Downwards', 
		Function = function(callback) end,
		HoverText = 'Goes down when left shift is held.'
	})
	ScaffoldStopMotion = Scaffold.CreateToggle({
		Name = 'Stop Motion',
		Function = function() end,
		HoverText = 'Stops your movement when going up'
	})
	ScaffoldStopMotion.Object.BackgroundTransparency = 0
	ScaffoldStopMotion.Object.BorderSizePixel = 0
	ScaffoldStopMotion.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	ScaffoldStopMotion.Object.Visible = ScaffoldTower.Enabled
	ScaffoldBlockCount = Scaffold.CreateToggle({
		Name = 'Block Count',
		Function = function(callback) 
			if Scaffold.Enabled then
				scaffoldtext.Visible = callback 
			end
		end,
		HoverText = 'Shows the amount of blocks in the middle.'
	})
	ScaffoldHandCheck = Scaffold.CreateToggle({
		Name = 'Whitelist Only',
		Function = function() end,
		HoverText = 'Only builds with blocks in your hand.'
	})
	ScaffoldAnimation = Scaffold.CreateToggle({
		Name = 'Animation',
		Function = function() end
	})
end)

local antivoidvelo
runFunction(function()
	local Speed = {Enabled = false}
	local SpeedMode = {Value = 'CFrame'}
	local SpeedValue = {Value = 1}
	local SpeedValueLarge = {Value = 1}
	local SpeedDamageBoost = {Enabled = false}
	local SpeedJump = {Enabled = false}
	local SpeedJumpHeight = {Value = 20}
	local SpeedJumpAlways = {Enabled = false}
	local SpeedJumpSound = {Enabled = false}
	local SpeedJumpVanilla = {Enabled = false}
	local SpeedAnimation = {Enabled = false}
	local raycastparameters = RaycastParams.new()
	local damagetick = tick()

	local alternatelist = {'Normal', 'AntiCheat A', 'AntiCheat B'}
	Speed = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'Speed',
		Function = function(callback)
			if callback then
				table.insert(Speed.Connections, vapeEvents.EntityDamageEvent.Event:Connect(function(damageTable)
					if damageTable.entityInstance == lplr.Character and (damageTable.damageType ~= 0 or damageTable.extra and damageTable.extra.chargeRatio ~= nil) and (not (damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.disabled or damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.horizontal == 0)) and SpeedDamageBoost.Enabled then 
						damagetick = tick() + 0.4
					end
				end))
				RunLoops:BindToHeartbeat('Speed', function(delta)
					if GuiLibrary.ObjectsThatCanBeSaved['Lobby CheckToggle'].Api.Enabled then
						if bedwarsStore.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						if not (isnetworkowner(entityLibrary.character.HumanoidRootPart) and entityLibrary.character.Humanoid:GetState() ~= Enum.HumanoidStateType.Climbing and (not spiderActive) and (not GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled) and (not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled)) then return end
						if GuiLibrary.ObjectsThatCanBeSaved.GrappleExploitOptionsButton and GuiLibrary.ObjectsThatCanBeSaved.GrappleExploitOptionsButton.Api.Enabled then return end
						if LongJump.Enabled then return end
						if noSpeed then return end
						if SpeedAnimation.Enabled then
							for i, v in next, (entityLibrary.character.Humanoid:GetPlayingAnimationTracks()) do
								if v.Name == 'WalkAnim' or v.Name == 'RunAnim' then
									v:AdjustSpeed(entityLibrary.character.Humanoid.WalkSpeed / 16)
								end
							end
						end

						local speedValue = SpeedValue.Value + getSpeed()
						if damagetick > tick() then speedValue = speedValue + 20 end

						local speedVelocity = entityLibrary.character.Humanoid.MoveDirection * (SpeedMode.Value == 'Normal' and SpeedValue.Value or 20)
						entityLibrary.character.HumanoidRootPart.Velocity = antivoidvelo or Vector3.new(speedVelocity.X, entityLibrary.character.HumanoidRootPart.Velocity.Y, speedVelocity.Z)
						if SpeedMode.Value ~= 'Normal' then 
							local speedCFrame = entityLibrary.character.Humanoid.MoveDirection * (speedValue - 20) * delta
							raycastparameters.FilterDescendantsInstances = {lplr.Character}
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, speedCFrame, raycastparameters)
							if ray then speedCFrame = (ray.Position - entityLibrary.character.HumanoidRootPart.Position) end
							entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + speedCFrame
						end

						if SpeedJump.Enabled and (not Scaffold.Enabled) and (SpeedJumpAlways.Enabled or killauraNearPlayer) then
							if (entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air) and entityLibrary.character.Humanoid.MoveDirection ~= Vector3.zero then
								if SpeedJumpSound.Enabled then 
									pcall(function() entityLibrary.character.HumanoidRootPart.Jumping:Play() end)
								end
								if SpeedJumpVanilla.Enabled then 
									entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
								else
									entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, SpeedJumpHeight.Value, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								end
							end 
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat('Speed')
			end
		end, 
		HoverText = 'Increases your movement.',
		ExtraText = function() 
			return 'Heatseeker'
		end
	})
	SpeedValue = Speed.CreateSlider({
		Name = 'Speed',
		Min = 1,
		Max = 27,
		Function = function(val) end,
		Default = 23
	})
	SpeedValueLarge = Speed.CreateSlider({
		Name = 'Big Mode Speed',
		Min = 1,
		Max = 27,
		Function = function(val) end,
		Default = 23
	})
	SpeedDamageBoost = Speed.CreateToggle({
		Name = 'Damage Boost',
		Function = function() end,
		Default = true
	})
	SpeedJump = Speed.CreateToggle({
		Name = 'AutoJump', 
		Function = function(callback) 
			if SpeedJumpHeight.Object then SpeedJumpHeight.Object.Visible = callback end
			if SpeedJumpAlways.Object then
				SpeedJump.Object.ToggleArrow.Visible = callback
				SpeedJumpAlways.Object.Visible = callback
			end
			if SpeedJumpSound.Object then SpeedJumpSound.Object.Visible = callback end
			if SpeedJumpVanilla.Object then SpeedJumpVanilla.Object.Visible = callback end
		end,
		Default = true
	})
	SpeedJumpHeight = Speed.CreateSlider({
		Name = 'Jump Height',
		Min = 0,
		Max = 30,
		Default = 25,
		Function = function() end
	})
	SpeedJumpAlways = Speed.CreateToggle({
		Name = 'Always Jump',
		Function = function() end
	})
	SpeedJumpSound = Speed.CreateToggle({
		Name = 'Jump Sound',
		Function = function() end
	})
	SpeedJumpVanilla = Speed.CreateToggle({
		Name = 'Real Jump',
		Function = function() end
	})
	SpeedAnimation = Speed.CreateToggle({
		Name = 'Slowdown Anim',
		Function = function() end
	})
end)

runFunction(function()
	local function roundpos(dir, pos, size)
		local suc, res = pcall(function() return Vector3.new(math.clamp(dir.X, pos.X - (size.X / 2), pos.X + (size.X / 2)), math.clamp(dir.Y, pos.Y - (size.Y / 2), pos.Y + (size.Y / 2)), math.clamp(dir.Z, pos.Z - (size.Z / 2), pos.Z + (size.Z / 2))) end)
		return suc and res or Vector3.zero
	end

	local Spider = {Enabled = false}
	local SpiderSpeed = {Value = 0}
	local SpiderMode = {Value = 'Normal'}
	local SpiderPart
	Spider = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'Spider',
		Function = function(callback)
			if callback then
				table.insert(Spider.Connections, inputService.InputBegan:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.LeftShift then 
						holdingshift = true
					end
				end))
				table.insert(Spider.Connections, inputService.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.LeftShift then 
						holdingshift = false
					end
				end))
				RunLoops:BindToHeartbeat('Spider', function()
					if entityLibrary.isAlive and (GuiLibrary.ObjectsThatCanBeSaved.PhaseOptionsButton.Api.Enabled == false or holdingshift == false) then
						if SpiderMode.Value == 'Normal' then
							local vec = entityLibrary.character.Humanoid.MoveDirection * 2
							local newray = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + (vec + Vector3.new(0, 0.1, 0)))
							local newray2 = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + (vec - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)))
							if newray and (not newray.CanCollide) then newray = nil end 
							if newray2 and (not newray2.CanCollide) then newray2 = nil end 
							if spiderActive and (not newray) and (not newray2) then
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 0, entityLibrary.character.HumanoidRootPart.Velocity.Z)
							end
							spiderActive = ((newray or newray2) and true or false)
							if (newray or newray2) then
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(newray2 and newray == nil and entityLibrary.character.HumanoidRootPart.Velocity.X or 0, SpiderSpeed.Value, newray2 and newray == nil and entityLibrary.character.HumanoidRootPart.Velocity.Z or 0)
							end
						else
							if not SpiderPart then 
								SpiderPart = Instance.new('TrussPart')
								SpiderPart.Size = Vector3.new(2, 2, 2)
								SpiderPart.Transparency = 1
								SpiderPart.Anchored = true
								SpiderPart.Parent = gameCamera
							end
							local newray2, newray2pos = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + ((entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 1.5) - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)))
							if newray2 and (not newray2.CanCollide) then newray2 = nil end
							spiderActive = (newray2 and true or false)
							if newray2 then 
								newray2pos = newray2pos * 3
								local newpos = roundpos(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(newray2pos.X, math.min(entityLibrary.character.HumanoidRootPart.Position.Y, newray2pos.Y), newray2pos.Z), Vector3.new(1.1, 1.1, 1.1))
								SpiderPart.Position = newpos
							else
								SpiderPart.Position = Vector3.zero
							end
						end
					end
				end)
			else
				if SpiderPart then SpiderPart:Destroy() end
				RunLoops:UnbindFromHeartbeat('Spider')
				holdingshift = false
			end
		end,
		HoverText = 'Lets you climb up walls'
	})
	SpiderMode = Spider.CreateDropdown({
		Name = 'Mode',
		List = {'Normal', 'Classic'},
		Function = function() 
			if SpiderPart then SpiderPart:Destroy() end
		end
	})
	SpiderSpeed = Spider.CreateSlider({
		Name = 'Speed',
		Min = 0,
		Max = 40,
		Function = function() end,
		Default = 40
	})
end)

runFunction(function()
	local TargetStrafe = {Enabled = false}
	local TargetStrafeRange = {Value = 18}
	local oldmove
	local controlmodule
	local block
	TargetStrafe = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = 'TargetStrafe',
		Function = function(callback)
			if callback then 
				task.spawn(function()
					if not controlmodule then
						local suc = pcall(function() controlmodule = require(lplr.PlayerScripts.PlayerModule).controls end)
						if not suc then controlmodule = {} end
					end
					oldmove = controlmodule.moveFunction
					local ang = 0
					local oldplr
					block = Instance.new('Part')
					block.Anchored = true
					block.CanCollide = false
					block.Parent = gameCamera
					controlmodule.moveFunction = function(Self, vec, facecam, ...)
						if entityLibrary.isAlive then
							local plr = AllNearPosition(TargetStrafeRange.Value + 5, 10)[1]
							plr = plr and (not workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, (plr.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position), bedwarsStore.blockRaycast)) and workspace:Raycast(plr.RootPart.Position, Vector3.new(0, -70, 0), bedwarsStore.blockRaycast) and plr or nil
							if plr ~= oldplr then
								if plr then
									local x, y, z = CFrame.new(plr.RootPart.Position, entityLibrary.character.HumanoidRootPart.Position):ToEulerAnglesXYZ()
									ang = math.deg(z)
								end
								oldplr = plr
							end
							if plr then 
								facecam = false
								local localPos = CFrame.new(plr.RootPart.Position)
								local ray = workspace:Blockcast(localPos, Vector3.new(3, 3, 3), CFrame.Angles(0, math.rad(ang), 0).lookVector * TargetStrafeRange.Value, bedwarsStore.blockRaycast)
								local newPos = localPos + (CFrame.Angles(0, math.rad(ang), 0).lookVector * (ray and ray.Distance - 1 or TargetStrafeRange.Value))
								local factor = getSpeed() > 0 and (2 + getSpeed() / 10) or 4
								if not workspace:Raycast(newPos.p, Vector3.new(0, -70, 0), bedwarsStore.blockRaycast) then 
									newPos = localPos
									factor = 40
								end
								if ((entityLibrary.character.HumanoidRootPart.Position * Vector3.new(1, 0, 1)) - (newPos.p * Vector3.new(1, 0, 1))).Magnitude < 4 or ray then
									ang = ang + factor % 360
								end
								block.Position = newPos.p
								vec = (newPos.p - entityLibrary.character.HumanoidRootPart.Position) * Vector3.new(1, 0, 1)
							end
						end
						return oldmove(Self, vec, facecam, ...)
					end
				end)
			else
				block:Destroy()
				controlmodule.moveFunction = oldmove
			end
		end
	})
	TargetStrafeRange = TargetStrafe.CreateSlider({
		Name = 'Range',
		Min = 0,
		Max = 18,
		Function = function() end
	})
end)

runFunction(function()
	local BedESP = {Enabled = false}
	local BedESPFolder = Instance.new('Folder')
	BedESPFolder.Name = 'BedESPFolder'
	BedESPFolder.Parent = GuiLibrary.MainGui
	local BedESPTable = {}
	local BedESPColor = {Value = 0.44}
	local BedESPTransparency = {Value = 1}
	local BedESPOnTop = {Enabled = true}
	BedESP = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'BedESP',
		Function = function(callback) 
			if callback then
				table.insert(BedESP.Connections, collectionService:GetInstanceAddedSignal('bed'):Connect(function(bed)
					task.wait(0.2)
					if not BedESP.Enabled then return end
					local BedFolder = Instance.new('Folder')
					BedFolder.Parent = BedESPFolder
					BedESPTable[bed] = BedFolder
					for bedespnumber, bedesppart in next, (bed:GetChildren()) do
						local boxhandle = Instance.new('BoxHandleAdornment')
						boxhandle.Size = bedesppart.Size + Vector3.new(.01, .01, .01)
						boxhandle.AlwaysOnTop = true
						boxhandle.ZIndex = (bedesppart.Name == 'Covers' and 10 or 0)
						boxhandle.Visible = true
						boxhandle.Adornee = bedesppart
						boxhandle.Color3 = bedesppart.Color
						boxhandle.Name = bedespnumber
						boxhandle.Parent = BedFolder
					end
				end))
				table.insert(BedESP.Connections, collectionService:GetInstanceRemovedSignal('bed'):Connect(function(bed)
					if BedESPTable[bed] then 
						BedESPTable[bed]:Destroy()
						BedESPTable[bed] = nil
					end
				end))
				for i, bed in next, (collectionService:GetTagged('bed')) do 
					local BedFolder = Instance.new('Folder')
					BedFolder.Parent = BedESPFolder
					BedESPTable[bed] = BedFolder
					for bedespnumber, bedesppart in next, (bed:GetChildren()) do
						if bedesppart:IsA('BasePart') then
							local boxhandle = Instance.new('BoxHandleAdornment')
							boxhandle.Size = bedesppart.Size + Vector3.new(.01, .01, .01)
							boxhandle.AlwaysOnTop = true
							boxhandle.ZIndex = (bedesppart.Name == 'Covers' and 10 or 0)
							boxhandle.Visible = true
							boxhandle.Adornee = bedesppart
							boxhandle.Color3 = bedesppart.Color
							boxhandle.Parent = BedFolder
						end
					end
				end
			else
				BedESPFolder:ClearAllChildren()
				table.clear(BedESPTable)
			end
		end,
		HoverText = 'Render Beds through walls' 
	})
end)

runFunction(function()
	local function getallblocks2(pos, normal)
		local blocks = {}
		local lastfound = nil
		for i = 1, 20 do
			local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
			local extrablock = getPlacedBlock(blockpos)
			local covered = true
			if extrablock and extrablock.Parent ~= nil then
				if bedwars.BlockController:isBlockBreakable({blockPosition = blockpos}, lplr) then
					table.insert(blocks, extrablock:GetAttribute('NoBreak') and 'unbreakable' or extrablock.Name)
				else
					table.insert(blocks, 'unbreakable')
					break
				end
				lastfound = extrablock
				if covered == false then
					break
				end
			else
				break
			end
		end
		return blocks
	end

	local function getallbedblocks(pos)
		local blocks = {}
		for i,v in next, (cachedNormalSides) do
			for i2,v2 in next, (getallblocks2(pos, v)) do	
				if table.find(blocks, v2) == nil and v2 ~= 'bed' then
					table.insert(blocks, v2)
				end
			end
			for i2,v2 in next, (getallblocks2(pos + Vector3.new(0, 0, 3), v)) do	
				if table.find(blocks, v2) == nil and v2 ~= 'bed' then
					table.insert(blocks, v2)
				end
			end
		end
		return blocks
	end

	local function refreshAdornee(v)
		local bedblocks = getallbedblocks(v.Adornee.Position)
		for i2,v2 in next, (v.Frame:GetChildren()) do
			if v2:IsA('ImageLabel') then
				v2:Remove()
			end
		end
		for i3,v3 in next, (bedblocks) do
			local blockimage = Instance.new('ImageLabel')
			blockimage.Size = UDim2.new(0, 32, 0, 32)
			blockimage.BackgroundTransparency = 1
			blockimage.Image = bedwars.getIcon({itemType = v3}, true)
			blockimage.Parent = v.Frame
		end
	end

	local BedPlatesFolder = Instance.new('Folder')
	BedPlatesFolder.Name = 'BedPlatesFolder'
	BedPlatesFolder.Parent = GuiLibrary.MainGui
	local BedPlatesTable = {}
	local BedPlates = {Enabled = false}

	local function addBed(v)
		local billboard = Instance.new('BillboardGui')
		billboard.Parent = BedPlatesFolder
		billboard.Name = 'bed'
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 1.5)
		billboard.Size = UDim2.new(0, 42, 0, 42)
		billboard.AlwaysOnTop = true
		billboard.Adornee = v
		BedPlatesTable[v] = billboard
		local frame = Instance.new('Frame')
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundColor3 = Color3.new(0, 0, 0)
		frame.BackgroundTransparency = 0.5
		frame.Parent = billboard
		local uilistlayout = Instance.new('UIListLayout')
		uilistlayout.FillDirection = Enum.FillDirection.Horizontal
		uilistlayout.Padding = UDim.new(0, 4)
		uilistlayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uilistlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uilistlayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			billboard.Size = UDim2.new(0, math.max(uilistlayout.AbsoluteContentSize.X + 12, 42), 0, 42)
		end)
		uilistlayout.Parent = frame
		local uicorner = Instance.new('UICorner')
		uicorner.CornerRadius = UDim.new(0, 4)
		uicorner.Parent = frame
		refreshAdornee(billboard)
	end

	BedPlates = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'BedPlates',
		Function = function(callback)
			if callback then
				table.insert(BedPlates.Connections, vapeEvents.PlaceBlockEvent.Event:Connect(function(p5)
					for i, v in next, (BedPlatesFolder:GetChildren()) do 
						if v.Adornee then
							if ((p5.blockRef.blockPosition * 3) - v.Adornee.Position).magnitude <= 20 then
								refreshAdornee(v)
							end
						end
					end
				end))
				table.insert(BedPlates.Connections, vapeEvents.BreakBlockEvent.Event:Connect(function(p5)
					for i, v in next, (BedPlatesFolder:GetChildren()) do 
						if v.Adornee then
							if ((p5.blockRef.blockPosition * 3) - v.Adornee.Position).magnitude <= 20 then
								refreshAdornee(v)
							end
						end
					end
				end))
				table.insert(BedPlates.Connections, collectionService:GetInstanceAddedSignal('bed'):Connect(function(v)
					addBed(v)
				end))
				table.insert(BedPlates.Connections, collectionService:GetInstanceRemovedSignal('bed'):Connect(function(v)
					if BedPlatesTable[v] then 
						BedPlatesTable[v]:Destroy()
						BedPlatesTable[v] = nil
					end
				end))
				for i, v in next, (collectionService:GetTagged('bed')) do
					addBed(v)
				end
			else
				BedPlatesFolder:ClearAllChildren()
			end
		end
	})
end)

runFunction(function()
	local ChestESPList = {ObjectList = {}, RefreshList = function() end}
	local function nearchestitem(item)
		for i,v in next, (ChestESPList.ObjectList) do 
			if item:find(v) then return v end
		end
	end
	local function refreshAdornee(v)
		local chest = v.Adornee.ChestFolderValue.Value
        local chestitems = chest and chest:GetChildren() or {}
		for i2,v2 in next, (v.Frame:GetChildren()) do
			if v2:IsA('ImageLabel') then
				v2:Remove()
			end
		end
		v.Enabled = false
		local alreadygot = {}
		for itemNumber, item in next, (chestitems) do
			if alreadygot[item.Name] == nil and (table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name)) then 
				alreadygot[item.Name] = true
				v.Enabled = true
                local blockimage = Instance.new('ImageLabel')
                blockimage.Size = UDim2.new(0, 32, 0, 32)
                blockimage.BackgroundTransparency = 1
                blockimage.Image = bedwars.getIcon({itemType = item.Name}, true)
                blockimage.Parent = v.Frame
            end
		end
	end

	local ChestESPFolder = Instance.new('Folder')
	ChestESPFolder.Name = 'ChestESPFolder'
	ChestESPFolder.Parent = GuiLibrary.MainGui
	local ChestESP = {Enabled = false}
	local ChestESPBackground = {Enabled = true}

	local function chestfunc(v)
		task.spawn(function()
			local billboard = Instance.new('BillboardGui')
			billboard.Parent = ChestESPFolder
			billboard.Name = 'chest'
			billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
			billboard.Size = UDim2.new(0, 42, 0, 42)
			billboard.AlwaysOnTop = true
			billboard.Adornee = v
			local frame = Instance.new('Frame')
			frame.Size = UDim2.new(1, 0, 1, 0)
			frame.BackgroundColor3 = Color3.new(0, 0, 0)
			frame.BackgroundTransparency = ChestESPBackground.Enabled and 0.5 or 1
			frame.Parent = billboard
			local uilistlayout = Instance.new('UIListLayout')
			uilistlayout.FillDirection = Enum.FillDirection.Horizontal
			uilistlayout.Padding = UDim.new(0, 4)
			uilistlayout.VerticalAlignment = Enum.VerticalAlignment.Center
			uilistlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			uilistlayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
				billboard.Size = UDim2.new(0, math.max(uilistlayout.AbsoluteContentSize.X + 12, 42), 0, 42)
			end)
			uilistlayout.Parent = frame
			local uicorner = Instance.new('UICorner')
			uicorner.CornerRadius = UDim.new(0, 4)
			uicorner.Parent = frame
			local chest = v:WaitForChild('ChestFolderValue').Value
			if chest then 
				table.insert(ChestESP.Connections, chest.ChildAdded:Connect(function(item)
					if table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name) then 
						refreshAdornee(billboard)
					end
				end))
				table.insert(ChestESP.Connections, chest.ChildRemoved:Connect(function(item)
					if table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name) then 
						refreshAdornee(billboard)
					end
				end))
				refreshAdornee(billboard)
			end
		end)
	end

	ChestESP = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'ChestESP',
		Function = function(callback)
			if callback then
				task.spawn(function()
					table.insert(ChestESP.Connections, collectionService:GetInstanceAddedSignal('chest'):Connect(chestfunc))
					for i,v in next, (collectionService:GetTagged('chest')) do chestfunc(v) end
				end)
			else
				ChestESPFolder:ClearAllChildren()
			end
		end
	})
	ChestESPList = ChestESP.CreateTextList({
		Name = 'ItemList',
		TempText = 'item or part of item',
		AddFunction = function()
			if ChestESP.Enabled then 
				ChestESP.ToggleButton(false)
				ChestESP.ToggleButton(false)
			end
		end,
		RemoveFunction = function()
			if ChestESP.Enabled then 
				ChestESP.ToggleButton(false)
				ChestESP.ToggleButton(false)
			end
		end
	})
	ChestESPBackground = ChestESP.CreateToggle({
		Name = 'Background',
		Function = function()
			if ChestESP.Enabled then 
				ChestESP.ToggleButton(false)
				ChestESP.ToggleButton(false)
			end
		end,
		Default = true
	})
end)

runFunction(function()
	local FieldOfViewValue = {Value = 70}
	local oldfov
	local oldfov2
	local FieldOfView = {Enabled = false}
	local FieldOfViewZoom = {Enabled = false}
	FieldOfView = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'FOVChanger',
		Function = function(callback)
			if callback then
				if FieldOfViewZoom.Enabled then
					task.spawn(function()
						repeat
							task.wait()
						until not inputService:IsKeyDown(Enum.KeyCode[FieldOfView.Keybind ~= '' and FieldOfView.Keybind or 'C'])
						if FieldOfView.Enabled then
							FieldOfView.ToggleButton(false)
						end
					end)
				end
				oldfov = bedwars.FovController.setFOV
				oldfov2 = bedwars.FovController.getFOV
				bedwars.FovController.setFOV = function(self, fov) return oldfov(self, FieldOfViewValue.Value) end
				bedwars.FovController.getFOV = function(self, fov) return FieldOfViewValue.Value end
			else
				bedwars.FovController.setFOV = oldfov
				bedwars.FovController.getFOV = oldfov2
			end
			bedwars.FovController:setFOV(bedwars.ClientStoreHandler:getState().Settings.fov)
		end
	})
	FieldOfViewValue = FieldOfView.CreateSlider({
		Name = 'FOV',
		Min = 30,
		Max = 120,
		Function = function(val)
			if FieldOfView.Enabled then
				bedwars.FovController:setFOV(bedwars.ClientStoreHandler:getState().Settings.fov)
			end
		end
	})
	FieldOfViewZoom = FieldOfView.CreateToggle({
		Name = 'Zoom',
		Function = function() end,
		HoverText = 'optifine zoom lol'
	})
end)

runFunction(function()
	local old
	local old2
	local oldhitpart 
	local FPSBoost = {Enabled = false}
	local removetextures = {Enabled = false}
	local removetexturessmooth = {Enabled = false}
	local fpsboostdamageindicator = {Enabled = false}
	local fpsboostdamageeffect = {Enabled = false}
	local fpsboostkilleffect = {Enabled = false}
	local originaltextures = {}
	local originaleffects = {}

	local function fpsboosttextures()
		task.spawn(function()
			repeat task.wait() until bedwarsStore.matchState ~= 0
			for i,v in next, (bedwarsStore.blocks) do
				if v:GetAttribute('PlacedByUserId') == 0 then
					v.Material = FPSBoost.Enabled and removetextures.Enabled and Enum.Material.SmoothPlastic or (v.Name:find('glass') and Enum.Material.SmoothPlastic or Enum.Material.Fabric)
					originaltextures[v] = originaltextures[v] or v.MaterialVariant
					v.MaterialVariant = FPSBoost.Enabled and removetextures.Enabled and '' or originaltextures[v]
					for i2,v2 in next, (v:GetChildren()) do 
						pcall(function() 
							v2.Material = FPSBoost.Enabled and removetextures.Enabled and Enum.Material.SmoothPlastic or (v.Name:find('glass') and Enum.Material.SmoothPlastic or Enum.Material.Fabric)
							originaltextures[v2] = originaltextures[v2] or v2.MaterialVariant
							v2.MaterialVariant = FPSBoost.Enabled and removetextures.Enabled and '' or originaltextures[v2]
						end)
					end
				end
			end
		end)
	end

	FPSBoost = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'FPSBoost',
		Function = function(callback)
			local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
			if callback then
				wasenabled = true
				fpsboosttextures()
				if fpsboostdamageindicator.Enabled then 
					damagetab.strokeThickness = 0
					damagetab.textSize = 0
					damagetab.blowUpDuration = 0
					damagetab.blowUpSize = 0
				end
				if fpsboostkilleffect.Enabled then 
					for i,v in next, (bedwars.KillEffectController.killEffects) do 
						originaleffects[i] = v
						bedwars.KillEffectController.killEffects[i] = {new = function(char) return {onKill = function() end, isPlayDefaultKillEffect = function() return char == lplr.Character end} end}
					end
				end
				if fpsboostdamageeffect.Enabled then 
					oldhitpart = bedwars.DamageIndicatorController.hitEffectPart
					bedwars.DamageIndicatorController.hitEffectPart = nil
				end
				old = bedwars.HighlightController.highlight
				old2 = getmetatable(bedwars.StopwatchController).tweenOutGhost
				local highlighttable = {}
				getmetatable(bedwars.StopwatchController).tweenOutGhost = function(p17, p18)
					p18:Destroy()
				end
				bedwars.HighlightController.highlight = function() end
			else
				for i,v in next, (originaleffects) do 
					bedwars.KillEffectController.killEffects[i] = v
				end
				fpsboosttextures()
				if oldhitpart then 
					bedwars.DamageIndicatorController.hitEffectPart = oldhitpart
				end
				debug.setupvalue(bedwars.KillEffectController.KnitStart, 2, bedwars.ClientSyncEvents)
				damagetab.strokeThickness = 1.5
				damagetab.textSize = 28
				damagetab.blowUpDuration = 0.125
				damagetab.blowUpSize = 76
				debug.setupvalue(bedwars.DamageIndicator, 10, tweenService)
				if bedwars.DamageIndicatorController.hitEffectPart then 
					bedwars.DamageIndicatorController.hitEffectPart.Attachment.Cubes.Enabled = true
					bedwars.DamageIndicatorController.hitEffectPart.Attachment.Shards.Enabled = true
				end
				bedwars.HighlightController.highlight = old
				getmetatable(bedwars.StopwatchController).tweenOutGhost = old2
				old = nil
				old2 = nil
			end
		end
	})
	removetextures = FPSBoost.CreateToggle({
		Name = 'Remove Textures',
		Function = function(callback) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
	fpsboostdamageindicator = FPSBoost.CreateToggle({
		Name = 'Remove Damage Indicator',
		Function = function(callback) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
	fpsboostdamageeffect = FPSBoost.CreateToggle({
		Name = 'Remove Damage Effect',
		Function = function(callback) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
	fpsboostkilleffect = FPSBoost.CreateToggle({
		Name = 'Remove Kill Effect',
		Function = function(callback) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
end)

runFunction(function()
	local GameFixer = {Enabled = false}
	local GameFixerHit = {Enabled = false}
	local GameFixerHideNametag = {Enabled = false}
	local setAttribute = game.SetAttribute
	local hideNametagConnection

	GameFixer = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'GameFixer',
		Function = function(callback)
			if callback then
				if GameFixerHit.Enabled then 
					debug.setconstant(bedwars.SwordController.swingSwordAtMouse, 23, 'raycast')
					debug.setupvalue(bedwars.SwordController.swingSwordAtMouse, 4, bedwars.QueryUtil)
				end
				if GameFixerHideNametag.Enabled then
					if hideNametagConnection then
						hideNametagConnection:Disconnect()
					end
					hideNametagConnection = lplr.CharacterAdded:Connect(function(character)
						setAttribute(character, 'NoNametag', true)
					end)
					if lplr.Character then
						setAttribute(lplr.Character, 'NoNametag', true)
					end
				end
				debug.setconstant(bedwars.QueueCard.render, 15, 0.1)
			else
				if GameFixerHit.Enabled then 
					debug.setconstant(bedwars.SwordController.swingSwordAtMouse, 23, 'Raycast')
					debug.setupvalue(bedwars.SwordController.swingSwordAtMouse, 4, workspace)
				end
				if hideNametagConnection then
					hideNametagConnection:Disconnect()
					hideNametagConnection = nil
				end
				if lplr.Character then
					setAttribute(lplr.Character, 'NoNametag', false)
				end
				debug.setconstant(bedwars.QueueCard.render, 15, 0.01)
			end
		end,
		HoverText = 'Fixes game bugs'
	})
	GameFixerHit = GameFixer.CreateToggle({
		Name = 'Hit Fix',
		Function = function(callback)
			if GameFixer.Enabled then
				if callback then 
					debug.setconstant(bedwars.SwordController.swingSwordAtMouse, 23, 'raycast')
					debug.setupvalue(bedwars.SwordController.swingSwordAtMouse, 4, bedwars.QueryUtil)
				else
					debug.setconstant(bedwars.SwordController.swingSwordAtMouse, 23, 'Raycast')
					debug.setupvalue(bedwars.SwordController.swingSwordAtMouse, 4, workspace)
				end
			end
		end,
		HoverText = 'Fixes the raycast function used for extra reach',
		Default = true
	})
	GameFixerHideNametag = GameFixer.CreateToggle({
		Name = 'Hide Nametag',
		Function = function(callback)
			if GameFixer.Enabled then
				if callback then
					if hideNametagConnection then
						hideNametagConnection:Disconnect()
					end
					hideNametagConnection = lplr.CharacterAdded:Connect(function(character)
						setAttribute(character, 'NoNametag', false)
					end)
					if lplr.Character then
						setAttribute(lplr.Character, 'NoNametag', false)
					end
				else
					if hideNametagConnection then
						hideNametagConnection:Disconnect()
						hideNametagConnection = nil
					end
					if lplr.Character then
						setAttribute(lplr.Character, 'NoNametag', true)
					end
				end
			end
		end,
		HoverText = 'Fixes the raycast function used for extra reach',
		Default = true
	})
end)

runFunction(function()
	local transformed = false
	local GameTheme = {Enabled = false}
	local GameThemeMode = {Value = 'GameTheme'}

	local themefunctions = {
		Old = function()
			task.spawn(function()
				local oldbedwarstabofimages = "{'clay_orange':'rbxassetid://7017703219','iron':'rbxassetid://6850537969','glass':'rbxassetid://6909521321','log_spruce':'rbxassetid://6874161124','ice':'rbxassetid://6874651262','marble':'rbxassetid://6594536339','zipline_base':'rbxassetid://7051148904','iron_helmet':'rbxassetid://6874272559','marble_pillar':'rbxassetid://6909323822','clay_dark_green':'rbxassetid://6763635916','wood_plank_birch':'rbxassetid://6768647328','watering_can':'rbxassetid://6915423754','emerald_helmet':'rbxassetid://6931675766','pie':'rbxassetid://6985761399','wood_plank_spruce':'rbxassetid://6768615964','diamond_chestplate':'rbxassetid://6874272898','wool_pink':'rbxassetid://6910479863','wool_blue':'rbxassetid://6910480234','wood_plank_oak':'rbxassetid://6910418127','diamond_boots':'rbxassetid://6874272964','clay_yellow':'rbxassetid://4991097283','tnt':'rbxassetid://6856168996','lasso':'rbxassetid://7192710930','clay_purple':'rbxassetid://6856099740','melon_seeds':'rbxassetid://6956387796','apple':'rbxassetid://6985765179','carrot_seeds':'rbxassetid://6956387835','log_oak':'rbxassetid://6763678414','emerald_chestplate':'rbxassetid://6931675868','wool_yellow':'rbxassetid://6910479606','emerald_boots':'rbxassetid://6931675942','clay_light_brown':'rbxassetid://6874651634','balloon':'rbxassetid://7122143895','cannon':'rbxassetid://7121221753','leather_boots':'rbxassetid://6855466456','melon':'rbxassetid://6915428682','wool_white':'rbxassetid://6910387332','log_birch':'rbxassetid://6763678414','clay_pink':'rbxassetid://6856283410','grass':'rbxassetid://6773447725','obsidian':'rbxassetid://6910443317','shield':'rbxassetid://7051149149','red_sandstone':'rbxassetid://6708703895','diamond_helmet':'rbxassetid://6874272793','wool_orange':'rbxassetid://6910479956','log_hickory':'rbxassetid://7017706899','guitar':'rbxassetid://7085044606','wool_purple':'rbxassetid://6910479777','diamond':'rbxassetid://6850538161','iron_chestplate':'rbxassetid://6874272631','slime_block':'rbxassetid://6869284566','stone_brick':'rbxassetid://6910394475','hammer':'rbxassetid://6955848801','ceramic':'rbxassetid://6910426690','wood_plank_maple':'rbxassetid://6768632085','leather_helmet':'rbxassetid://6855466216','stone':'rbxassetid://6763635916','slate_brick':'rbxassetid://6708836267','sandstone':'rbxassetid://6708657090','snow':'rbxassetid://6874651192','wool_red':'rbxassetid://6910479695','leather_chestplate':'rbxassetid://6876833204','clay_red':'rbxassetid://6856283323','wool_green':'rbxassetid://6910480050','clay_white':'rbxassetid://7017705325','wool_cyan':'rbxassetid://6910480152','clay_black':'rbxassetid://5890435474','sand':'rbxassetid://6187018940','clay_light_green':'rbxassetid://6856099550','clay_dark_brown':'rbxassetid://6874651325','carrot':'rbxassetid://3677675280','clay':'rbxassetid://6856190168','iron_boots':'rbxassetid://6874272718','emerald':'rbxassetid://6850538075','zipline':'rbxassetid://7051148904'}"
				local oldbedwarsicontab = game:GetService('HttpService'):JSONDecode(oldbedwarstabofimages)
				local oldbedwarssoundtable = {
					['QUEUE_JOIN'] = 'rbxassetid://6691735519',
					['QUEUE_MATCH_FOUND'] = 'rbxassetid://6768247187',
					['UI_CLICK'] = 'rbxassetid://6732690176',
					['UI_OPEN'] = 'rbxassetid://6732607930',
					['BEDWARS_UPGRADE_SUCCESS'] = 'rbxassetid://6760677364',
					['BEDWARS_PURCHASE_ITEM'] = 'rbxassetid://6760677364',
					['SWORD_SWING_1'] = 'rbxassetid://6760544639',
					['SWORD_SWING_2'] = 'rbxassetid://6760544595',
					['DAMAGE_1'] = 'rbxassetid://6765457325',
					['DAMAGE_2'] = 'rbxassetid://6765470975',
					['DAMAGE_3'] = 'rbxassetid://6765470941',
					['CROP_HARVEST'] = 'rbxassetid://4864122196',
					['CROP_PLANT_1'] = 'rbxassetid://5483943277',
					['CROP_PLANT_2'] = 'rbxassetid://5483943479',
					['CROP_PLANT_3'] = 'rbxassetid://5483943723',
					['ARMOR_EQUIP'] = 'rbxassetid://6760627839',
					['ARMOR_UNEQUIP'] = 'rbxassetid://6760625788',
					['PICKUP_ITEM_DROP'] = 'rbxassetid://6768578304',
					['PARTY_INCOMING_INVITE'] = 'rbxassetid://6732495464',
					['ERROR_NOTIFICATION'] = 'rbxassetid://6732495464',
					['INFO_NOTIFICATION'] = 'rbxassetid://6732495464',
					['END_GAME'] = 'rbxassetid://6246476959',
					['GENERIC_BLOCK_PLACE'] = 'rbxassetid://4842910664',
					['GENERIC_BLOCK_BREAK'] = 'rbxassetid://4819966893',
					['GRASS_BREAK'] = 'rbxassetid://5282847153',
					['WOOD_BREAK'] = 'rbxassetid://4819966893',
					['STONE_BREAK'] = 'rbxassetid://6328287211',
					['WOOL_BREAK'] = 'rbxassetid://4842910664',
					['TNT_EXPLODE_1'] = 'rbxassetid://7192313632',
					['TNT_HISS_1'] = 'rbxassetid://7192313423',
					['FIREBALL_EXPLODE'] = 'rbxassetid://6855723746',
					['SLIME_BLOCK_BOUNCE'] = 'rbxassetid://6857999096',
					['SLIME_BLOCK_BREAK'] = 'rbxassetid://6857999170',
					['SLIME_BLOCK_HIT'] = 'rbxassetid://6857999148',
					['SLIME_BLOCK_PLACE'] = 'rbxassetid://6857999119',
					['BOW_DRAW'] = 'rbxassetid://6866062236',
					['BOW_FIRE'] = 'rbxassetid://6866062104',
					['ARROW_HIT'] = 'rbxassetid://6866062188',
					['ARROW_IMPACT'] = 'rbxassetid://6866062148',
					['TELEPEARL_THROW'] = 'rbxassetid://6866223756',
					['TELEPEARL_LAND'] = 'rbxassetid://6866223798',
					['CROSSBOW_RELOAD'] = 'rbxassetid://6869254094',
					['VOICE_1'] = 'rbxassetid://5283866929',
					['VOICE_2'] = 'rbxassetid://5283867710',
					['VOICE_HONK'] = 'rbxassetid://5283872555',
					['FORTIFY_BLOCK'] = 'rbxassetid://6955762535',
					['EAT_FOOD_1'] = 'rbxassetid://4968170636',
					['KILL'] = 'rbxassetid://7013482008',
					['ZIPLINE_TRAVEL'] = 'rbxassetid://7047882304',
					['ZIPLINE_LATCH'] = 'rbxassetid://7047882233',
					['ZIPLINE_UNLATCH'] = 'rbxassetid://7047882265',
					['SHIELD_BLOCKED'] = 'rbxassetid://6955762535',
					['GUITAR_LOOP'] = 'rbxassetid://7084168540',
					['GUITAR_HEAL_1'] = 'rbxassetid://7084168458',
					['CANNON_MOVE'] = 'rbxassetid://7118668472',
					['CANNON_FIRE'] = 'rbxassetid://7121064180',
					['BALLOON_INFLATE'] = 'rbxassetid://7118657911',
					['BALLOON_POP'] = 'rbxassetid://7118657873',
					['FIREBALL_THROW'] = 'rbxassetid://7192289445',
					['LASSO_HIT'] = 'rbxassetid://7192289603',
					['LASSO_SWING'] = 'rbxassetid://7192289504',
					['LASSO_THROW'] = 'rbxassetid://7192289548',
					['GRIM_REAPER_CONSUME'] = 'rbxassetid://7225389554',
					['GRIM_REAPER_CHANNEL'] = 'rbxassetid://7225389512',
					['TV_STATIC'] = 'rbxassetid://7256209920',
					['TURRET_ON'] = 'rbxassetid://7290176291',
					['TURRET_OFF'] = 'rbxassetid://7290176380',
					['TURRET_ROTATE'] = 'rbxassetid://7290176421',
					['TURRET_SHOOT'] = 'rbxassetid://7290187805',
					['WIZARD_LIGHTNING_CAST'] = 'rbxassetid://7262989886',
					['WIZARD_LIGHTNING_LAND'] = 'rbxassetid://7263165647',
					['WIZARD_LIGHTNING_STRIKE'] = 'rbxassetid://7263165347',
					['WIZARD_ORB_CAST'] = 'rbxassetid://7263165448',
					['WIZARD_ORB_TRAVEL_LOOP'] = 'rbxassetid://7263165579',
					['WIZARD_ORB_CONTACT_LOOP'] = 'rbxassetid://7263165647',
					['BATTLE_PASS_PROGRESS_LEVEL_UP'] = 'rbxassetid://7331597283',
					['BATTLE_PASS_PROGRESS_EXP_GAIN'] = 'rbxassetid://7331597220',
					['FLAMETHROWER_UPGRADE'] = 'rbxassetid://7310273053',
					['FLAMETHROWER_USE'] = 'rbxassetid://7310273125',
					['BRITTLE_HIT'] = 'rbxassetid://7310273179',
					['EXTINGUISH'] = 'rbxassetid://7310273015',
					['RAVEN_SPACE_AMBIENT'] = 'rbxassetid://7341443286',
					['RAVEN_WING_FLAP'] = 'rbxassetid://7341443378',
					['RAVEN_CAW'] = 'rbxassetid://7341443447',
					['JADE_HAMMER_THUD'] = 'rbxassetid://7342299402',
					['STATUE'] = 'rbxassetid://7344166851',
					['CONFETTI'] = 'rbxassetid://7344278405',
					['HEART'] = 'rbxassetid://7345120916',
					['SPRAY'] = 'rbxassetid://7361499529',
					['BEEHIVE_PRODUCE'] = 'rbxassetid://7378100183',
					['DEPOSIT_BEE'] = 'rbxassetid://7378100250',
					['CATCH_BEE'] = 'rbxassetid://7378100305',
					['BEE_NET_SWING'] = 'rbxassetid://7378100350',
					['ASCEND'] = 'rbxassetid://7378387334',
					['BED_ALARM'] = 'rbxassetid://7396762708',
					['BOUNTY_CLAIMED'] = 'rbxassetid://7396751941',
					['BOUNTY_ASSIGNED'] = 'rbxassetid://7396752155',
					['BAGUETTE_HIT'] = 'rbxassetid://7396760547',
					['BAGUETTE_SWING'] = 'rbxassetid://7396760496',
					['TESLA_ZAP'] = 'rbxassetid://7497477336',
					['SPIRIT_TRIGGERED'] = 'rbxassetid://7498107251',
					['SPIRIT_EXPLODE'] = 'rbxassetid://7498107327',
					['ANGEL_LIGHT_ORB_CREATE'] = 'rbxassetid://7552134231',
					['ANGEL_LIGHT_ORB_HEAL'] = 'rbxassetid://7552134868',
					['ANGEL_VOID_ORB_CREATE'] = 'rbxassetid://7552135942',
					['ANGEL_VOID_ORB_HEAL'] = 'rbxassetid://7552136927',
					['DODO_BIRD_JUMP'] = 'rbxassetid://7618085391',
					['DODO_BIRD_DOUBLE_JUMP'] = 'rbxassetid://7618085771',
					['DODO_BIRD_MOUNT'] = 'rbxassetid://7618085486',
					['DODO_BIRD_DISMOUNT'] = 'rbxassetid://7618085571',
					['DODO_BIRD_SQUAWK_1'] = 'rbxassetid://7618085870',
					['DODO_BIRD_SQUAWK_2'] = 'rbxassetid://7618085657',
					['SHIELD_CHARGE_START'] = 'rbxassetid://7730842884',
					['SHIELD_CHARGE_LOOP'] = 'rbxassetid://7730843006',
					['SHIELD_CHARGE_BASH'] = 'rbxassetid://7730843142',
					['ROCKET_LAUNCHER_FIRE'] = 'rbxassetid://7681584765',
					['ROCKET_LAUNCHER_FLYING_LOOP'] = 'rbxassetid://7681584906',
					['SMOKE_GRENADE_POP'] = 'rbxassetid://7681276062',
					['SMOKE_GRENADE_EMIT_LOOP'] = 'rbxassetid://7681276135',
					['GOO_SPIT'] = 'rbxassetid://7807271610',
					['GOO_SPLAT'] = 'rbxassetid://7807272724',
					['GOO_EAT'] = 'rbxassetid://7813484049',
					['LUCKY_BLOCK_BREAK'] = 'rbxassetid://7682005357',
					['AXOLOTL_SWITCH_TARGETS'] = 'rbxassetid://7344278405',
					['HALLOWEEN_MUSIC'] = 'rbxassetid://7775602786',
					['SNAP_TRAP_SETUP'] = 'rbxassetid://7796078515',
					['SNAP_TRAP_CLOSE'] = 'rbxassetid://7796078695',
					['SNAP_TRAP_CONSUME_MARK'] = 'rbxassetid://7796078825',
					['GHOST_VACUUM_SUCKING_LOOP'] = 'rbxassetid://7814995865',
					['GHOST_VACUUM_SHOOT'] = 'rbxassetid://7806060367',
					['GHOST_VACUUM_CATCH'] = 'rbxassetid://7815151688',
					['FISHERMAN_GAME_START'] = 'rbxassetid://7806060544',
					['FISHERMAN_GAME_PULLING_LOOP'] = 'rbxassetid://7806060638',
					['FISHERMAN_GAME_PROGRESS_INCREASE'] = 'rbxassetid://7806060745',
					['FISHERMAN_GAME_FISH_MOVE'] = 'rbxassetid://7806060863',
					['FISHERMAN_GAME_LOOP'] = 'rbxassetid://7806061057',
					['FISHING_ROD_CAST'] = 'rbxassetid://7806060976',
					['FISHING_ROD_SPLASH'] = 'rbxassetid://7806061193',
					['SPEAR_HIT'] = 'rbxassetid://7807270398',
					['SPEAR_THROW'] = 'rbxassetid://7813485044',
				}
				for i,v in next, (bedwars.CombatController.killSounds) do 
					bedwars.CombatController.killSounds[i] = oldbedwarssoundtable.KILL
				end
				for i,v in next, (bedwars.CombatController.multiKillLoops) do 
					bedwars.CombatController.multiKillLoops[i] = ''
				end
				for i,v in next, (bedwars.ItemTable) do 
					if oldbedwarsicontab[i] then 
						v.image = oldbedwarsicontab[i]
					end
				end			
				for i,v in next, (oldbedwarssoundtable) do 
					local item = bedwars.SoundList[i]
					if item then
						bedwars.SoundList[i] = v
					end
				end	
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(214, 0, 0)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.ViewmodelController.show, 37, '')
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, 'Enabled')
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(0, 0, 0) or Color3.new(1, 1, 1))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				sethiddenproperty(lightingService, 'Technology', 'ShadowMap')
				lightingService.Ambient = Color3.fromRGB(69, 69, 69)
				lightingService.Brightness = 3
				lightingService.EnvironmentDiffuseScale = 1
				lightingService.EnvironmentSpecularScale = 1
				lightingService.OutdoorAmbient = Color3.fromRGB(69, 69, 69)
				lightingService.Atmosphere.Density = 0.1
				lightingService.Atmosphere.Offset = 0.25
				lightingService.Atmosphere.Color = Color3.fromRGB(198, 198, 198)
				lightingService.Atmosphere.Decay = Color3.fromRGB(104, 112, 124)
				lightingService.Atmosphere.Glare = 0
				lightingService.Atmosphere.Haze = 0
				lightingService.ClockTime = 13
				lightingService.GeographicLatitude = 0
				lightingService.GlobalShadows = false
				lightingService.TimeOfDay = '13:00:00'
				lightingService.Sky.SkyboxBk = 'rbxassetid://7018684000'
				lightingService.Sky.SkyboxDn = 'rbxassetid://6334928194'
				lightingService.Sky.SkyboxFt = 'rbxassetid://7018684000'
				lightingService.Sky.SkyboxLf = 'rbxassetid://7018684000'
				lightingService.Sky.SkyboxRt = 'rbxassetid://7018684000'
				lightingService.Sky.SkyboxUp = 'rbxassetid://7018689553'
			end)
		end,
		Winter = function() 
			task.spawn(function()
				for i,v in next, (lightingService:GetChildren()) do
					if v:IsA('Atmosphere') or v:IsA('Sky') or v:IsA('PostEffect') then
						v:Remove()
					end
				end
				local sky = Instance.new('Sky')
				sky.StarCount = 5000
				sky.SkyboxUp = 'rbxassetid://8139676647'
				sky.SkyboxLf = 'rbxassetid://8139676988'
				sky.SkyboxFt = 'rbxassetid://8139677111'
				sky.SkyboxBk = 'rbxassetid://8139677359'
				sky.SkyboxDn = 'rbxassetid://8139677253'
				sky.SkyboxRt = 'rbxassetid://8139676842'
				sky.SunTextureId = 'rbxassetid://6196665106'
				sky.SunAngularSize = 11
				sky.MoonTextureId = 'rbxassetid://8139665943'
				sky.MoonAngularSize = 30
				sky.Parent = lightingService
				local sunray = Instance.new('SunRaysEffect')
				sunray.Intensity = 0.03
				sunray.Parent = lightingService
				local bloom = Instance.new('BloomEffect')
				bloom.Threshold = 2
				bloom.Intensity = 1
				bloom.Size = 2
				bloom.Parent = lightingService
				local atmosphere = Instance.new('Atmosphere')
				atmosphere.Density = 0.3
				atmosphere.Offset = 0.25
				atmosphere.Color = Color3.fromRGB(198, 198, 198)
				atmosphere.Decay = Color3.fromRGB(104, 112, 124)
				atmosphere.Glare = 0
				atmosphere.Haze = 0
				atmosphere.Parent = lightingService
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(70, 255, 255)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, 'Enabled')
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(1, 1, 1) or Color3.new(0, 0, 0))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				debug.setconstant(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar['hotbar-healthbar']).HotbarHealthbar.render, 16, 4653055)
			end)
			task.spawn(function()
				local snowpart = Instance.new('Part')
				snowpart.Size = Vector3.new(240, 0.5, 240)
				snowpart.Name = 'SnowParticle'
				snowpart.Transparency = 1
				snowpart.CanCollide = false
				snowpart.Position = Vector3.new(0, 120, 286)
				snowpart.Anchored = true
				snowpart.Parent = workspace
				local snow = Instance.new('ParticleEmitter')
				snow.RotSpeed = NumberRange.new(300)
				snow.VelocitySpread = 35
				snow.Rate = 28
				snow.Texture = 'rbxassetid://8158344433'
				snow.Rotation = NumberRange.new(110)
				snow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.16939899325371,0),NumberSequenceKeypoint.new(0.23365999758244,0.62841498851776,0.37158501148224),NumberSequenceKeypoint.new(0.56209099292755,0.38797798752785,0.2771390080452),NumberSequenceKeypoint.new(0.90577298402786,0.51912599802017,0),NumberSequenceKeypoint.new(1,1,0)})
				snow.Lifetime = NumberRange.new(8,14)
				snow.Speed = NumberRange.new(8,18)
				snow.EmissionDirection = Enum.NormalId.Bottom
				snow.SpreadAngle = Vector2.new(35,35)
				snow.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.039760299026966,1.3114800453186,0.32786899805069),NumberSequenceKeypoint.new(0.7554469704628,0.98360699415207,0.44038599729538),NumberSequenceKeypoint.new(1,0,0)})
				snow.Parent = snowpart
				local windsnow = Instance.new('ParticleEmitter')
				windsnow.Acceleration = Vector3.new(0,0,1)
				windsnow.RotSpeed = NumberRange.new(100)
				windsnow.VelocitySpread = 35
				windsnow.Rate = 28
				windsnow.Texture = 'rbxassetid://8158344433'
				windsnow.EmissionDirection = Enum.NormalId.Bottom
				windsnow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.16939899325371,0),NumberSequenceKeypoint.new(0.23365999758244,0.62841498851776,0.37158501148224),NumberSequenceKeypoint.new(0.56209099292755,0.38797798752785,0.2771390080452),NumberSequenceKeypoint.new(0.90577298402786,0.51912599802017,0),NumberSequenceKeypoint.new(1,1,0)})
				windsnow.Lifetime = NumberRange.new(8,14)
				windsnow.Speed = NumberRange.new(8,18)
				windsnow.Rotation = NumberRange.new(110)
				windsnow.SpreadAngle = Vector2.new(35,35)
				windsnow.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.039760299026966,1.3114800453186,0.32786899805069),NumberSequenceKeypoint.new(0.7554469704628,0.98360699415207,0.44038599729538),NumberSequenceKeypoint.new(1,0,0)})
				windsnow.Parent = snowpart
				repeat
					task.wait()
					if entityLibrary.isAlive then 
						snowpart.Position = entityLibrary.character.HumanoidRootPart.Position + Vector3.new(0, 100, 0)
					end
				until not vapeInjected
			end)
		end,
		Halloween = function()
			task.spawn(function()
				for i,v in next, (lightingService:GetChildren()) do
					if v:IsA('Atmosphere') or v:IsA('Sky') or v:IsA('PostEffect') then
						v:Remove()
					end
				end
				lightingService.TimeOfDay = '00:00:00'
				pcall(function() workspace.Clouds:Destroy() end)
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(255, 100, 0)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, 'Enabled')
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(0, 0, 0) or Color3.new(0, 0, 0))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				local colorcorrection = Instance.new('ColorCorrectionEffect')
				colorcorrection.TintColor = Color3.fromRGB(255, 185, 81)
				colorcorrection.Brightness = 0.05
				colorcorrection.Parent = lightingService
				debug.setconstant(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar['hotbar-healthbar']).HotbarHealthbar.render, 16, 16737280)
			end)
		end,
		Valentines = function()
			task.spawn(function()
				for i,v in next, (lightingService:GetChildren()) do
					if v:IsA('Atmosphere') or v:IsA('Sky') or v:IsA('PostEffect') then
						v:Remove()
					end
				end
				local sky = Instance.new('Sky')
				sky.SkyboxBk = 'rbxassetid://1546230803'
				sky.SkyboxDn = 'rbxassetid://1546231143'
				sky.SkyboxFt = 'rbxassetid://1546230803'
				sky.SkyboxLf = 'rbxassetid://1546230803'
				sky.SkyboxRt = 'rbxassetid://1546230803'
				sky.SkyboxUp = 'rbxassetid://1546230451'
				sky.Parent = lightingService
				pcall(function() workspace.Clouds:Destroy() end)
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(255, 132, 178)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, 'Enabled')
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(0, 0, 0) or Color3.new(0, 0, 0))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				local colorcorrection = Instance.new('ColorCorrectionEffect')
				colorcorrection.TintColor = Color3.fromRGB(255, 199, 220)
				colorcorrection.Brightness = 0.05
				colorcorrection.Parent = lightingService
				debug.setconstant(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar['hotbar-healthbar']).HotbarHealthbar.render, 16, 16745650)
			end)
		end
	}

	GameTheme = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'GameTheme',
		Function = function(callback) 
			if callback then 
				if not transformed then
					transformed = true
					themefunctions[GameThemeMode.Value]()
				else
					GameTheme.ToggleButton(false)
				end
			else
				warningNotification('GameTheme', 'Disabled Next Game', 10)
			end
		end,
		ExtraText = function()
			return GameThemeMode.Value
		end
	})
	GameThemeMode = GameTheme.CreateDropdown({
		Name = 'Theme',
		Function = function() end,
		List = {'Old', 'Winter', 'Halloween', 'Valentines'}
	})
end)

runFunction(function()
	local oldkilleffect
	local KillEffectMode = {Value = 'Gravity'}
	local KillEffectList = {Value = 'None'}
	local KillEffectName2 = {}
	local killeffects = {
		Gravity = function(p3, p4, p5, p6)
			p5:BreakJoints()
			task.spawn(function()
				local partvelo = {}
				for i,v in next, (p5:GetDescendants()) do 
					if v:IsA('BasePart') then 
						partvelo[v.Name] = v.Velocity * 3
					end
				end
				p5.Archivable = true
				local clone = p5:Clone()
				clone.Humanoid.Health = 100
				clone.Parent = workspace
				local nametag = clone:FindFirstChild('Nametag', true)
				if nametag then nametag:Destroy() end
				game:GetService('Debris'):AddItem(clone, 30)
				p5:Destroy()
				task.wait(0.01)
				clone.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				clone:BreakJoints()
				task.wait(0.01)
				for i,v in next, (clone:GetDescendants()) do 
					if v:IsA('BasePart') then 
						local bodyforce = Instance.new('BodyForce')
						bodyforce.Force = Vector3.new(0, (workspace.Gravity - 10) * v:GetMass(), 0)
						bodyforce.Parent = v
						v.CanCollide = true
						v.Velocity = partvelo[v.Name] or Vector3.zero
					end
				end
			end)
		end,
		Lightning = function(p3, p4, p5, p6)
			p5:BreakJoints()
			local startpos = 1125
			local startcf = p5.PrimaryPart.CFrame.p - Vector3.new(0, 8, 0)
			local newpos = Vector3.new((math.random(1, 10) - 5) * 2, startpos, (math.random(1, 10) - 5) * 2)
			for i = startpos - 75, 0, -75 do 
				local newpos2 = Vector3.new((math.random(1, 10) - 5) * 2, i, (math.random(1, 10) - 5) * 2)
				if i == 0 then 
					newpos2 = Vector3.zero
				end
				local part = Instance.new('Part')
				part.Size = Vector3.new(1.5, 1.5, 77)
				part.Material = Enum.Material.SmoothPlastic
				part.Anchored = true
				part.Material = Enum.Material.Neon
				part.CanCollide = false
				part.CFrame = CFrame.new(startcf + newpos + ((newpos2 - newpos) * 0.5), startcf + newpos2)
				part.Parent = workspace
				local part2 = part:Clone()
				part2.Size = Vector3.new(3, 3, 78)
				part2.Color = Color3.new(0.7, 0.7, 0.7)
				part2.Transparency = 0.7
				part2.Material = Enum.Material.SmoothPlastic
				part2.Parent = workspace
				game:GetService('Debris'):AddItem(part, 0.5)
				game:GetService('Debris'):AddItem(part2, 0.5)
				bedwars.QueryUtil:setQueryIgnored(part, true)
				bedwars.QueryUtil:setQueryIgnored(part2, true)
				if i == 0 then 
					local soundpart = Instance.new('Part')
					soundpart.Transparency = 1
					soundpart.Anchored = true 
					soundpart.Size = Vector3.zero
					soundpart.Position = startcf
					soundpart.Parent = workspace
					bedwars.QueryUtil:setQueryIgnored(soundpart, true)
					local sound = Instance.new('Sound')
					sound.SoundId = 'rbxassetid://6993372814'
					sound.Volume = 2
					sound.Pitch = 0.5 + (math.random(1, 3) / 10)
					sound.Parent = soundpart
					sound:Play()
					sound.Ended:Connect(function()
						soundpart:Destroy()
					end)
				end
				newpos = newpos2
			end
		end
	}
	local KillEffectName = {}
	for i,v in next, (bedwars.KillEffectMeta) do 
		table.insert(KillEffectName, v.name)
		KillEffectName[v.name] = i
	end
	table.sort(KillEffectName, function(a, b) return a:lower() < b:lower() end)
	local KillEffect = {Enabled = false}
	KillEffect = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'KillEffect',
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat task.wait() until bedwarsStore.matchState ~= 0 or not KillEffect.Enabled
					if KillEffect.Enabled then
						lplr:SetAttribute('KillEffectType', 'none')
						if KillEffectMode.Value == 'Bedwars' then 
							lplr:SetAttribute('KillEffectType', KillEffectName[KillEffectList.Value])
						end
					end
				end)
				oldkilleffect = bedwars.DefaultKillEffect.onKill
				bedwars.DefaultKillEffect.onKill = function(p3, p4, p5, p6)
					killeffects[KillEffectMode.Value](p3, p4, p5, p6)
				end
			else
				bedwars.DefaultKillEffect.onKill = oldkilleffect
			end
		end
	})
	local modes = {'Bedwars'}
	for i,v in next, (killeffects) do 
		table.insert(modes, i)
	end
	KillEffectMode = KillEffect.CreateDropdown({
		Name = 'Mode',
		Function = function() 
			if KillEffect.Enabled then 
				KillEffect.ToggleButton(false)
				KillEffect.ToggleButton(false)
			end
		end,
		List = modes
	})
	KillEffectList = KillEffect.CreateDropdown({
		Name = 'Bedwars',
		Function = function() 
			if KillEffect.Enabled then 
				KillEffect.ToggleButton(false)
				KillEffect.ToggleButton(false)
			end
		end,
		List = KillEffectName
	})
end)

runFunction(function()
	local KitESP = {Enabled = false}
	local espobjs = {}
	local espfold = Instance.new('Folder')
	espfold.Parent = GuiLibrary.MainGui

	local function espadd(v, icon)
		local billboard = Instance.new('BillboardGui')
		billboard.Parent = espfold
		billboard.Name = 'iron'
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 1.5)
		billboard.Size = UDim2.new(0, 32, 0, 32)
		billboard.AlwaysOnTop = true
		billboard.Adornee = v
		local image = Instance.new('ImageLabel')
		image.BackgroundTransparency = 0.5
		image.BorderSizePixel = 0
		image.Image = bedwars.getIcon({itemType = icon}, true)
		image.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		image.Size = UDim2.new(0, 32, 0, 32)
		image.AnchorPoint = Vector2.new(0.5, 0.5)
		image.Parent = billboard
		local uicorner = Instance.new('UICorner')
		uicorner.CornerRadius = UDim.new(0, 4)
		uicorner.Parent = image
		espobjs[v] = billboard
	end

	local function addKit(tag, icon)
		table.insert(KitESP.Connections, collectionService:GetInstanceAddedSignal(tag):Connect(function(v)
			espadd(v.PrimaryPart, icon)
		end))
		table.insert(KitESP.Connections, collectionService:GetInstanceRemovedSignal(tag):Connect(function(v)
			if espobjs[v.PrimaryPart] then
				espobjs[v.PrimaryPart]:Destroy()
				espobjs[v.PrimaryPart] = nil
			end
		end))
		for i,v in next, (collectionService:GetTagged(tag)) do 
			espadd(v.PrimaryPart, icon)
		end
	end

	KitESP = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'KitESP',
		Function = function(callback) 
			if callback then
				task.spawn(function()
					repeat task.wait() until bedwarsStore.equippedKit ~= ''
					if KitESP.Enabled then
						if bedwarsStore.equippedKit == 'metal_detector' then
							addKit('hidden-metal', 'iron')
						elseif bedwarsStore.equippedKit == 'beekeeper' then
							addKit('bee', 'bee')
						elseif bedwarsStore.equippedKit == 'bigman' then
							addKit('treeOrb', 'natures_essence_1')
						end
					end
				end)
			else
				espfold:ClearAllChildren()
				table.clear(espobjs)
			end
		end
	})
end)

runFunction(function()
	local function floorNameTagPosition(pos)
		return Vector2.new(math.floor(pos.X), math.floor(pos.Y))
	end

	local function removeTags(str)
        str = str:gsub('<br%s*/>', '\n')
        return (str:gsub('<[^<>]->', ''))
    end

	local NameTagsFolder = Instance.new('Folder')
	NameTagsFolder.Name = 'NameTagsFolder'
	NameTagsFolder.Parent = GuiLibrary.MainGui
	local nametagsfolderdrawing = {}
	local NameTagsColor = {Value = 0.44}
	local NameTagsDisplayName = {Enabled = false}
	local NameTagsHealth = {Enabled = false}
	local NameTagsDistance = {Enabled = false}
	local NameTagsBackground = {Enabled = true}
	local NameTagsScale = {Value = 10}
	local NameTagsFont = {Value = 'SourceSans'}
	local NameTagsTeammates = {Enabled = true}
	local NameTagsShowInventory = {Enabled = false}
	local NameTagsRangeLimit = {Value = 0}
	local fontitems = {'SourceSans'}
	local nametagstrs = {}
	local nametagsizes = {}
	local kititems = {
		jade = 'jade_hammer',
		archer = 'tactical_crossbow',
		angel = '',
		cowgirl = 'lasso',
		dasher = 'wood_dao',
		axolotl = 'axolotl',
		yeti = 'snowball',
		smoke = 'smoke_block',
		trapper = 'snap_trap',
		pyro = 'flamethrower',
		davey = 'cannon',
		regent = 'void_axe', 
		baker = 'apple',
		builder = 'builder_hammer',
		farmer_cletus = 'carrot_seeds',
		melody = 'guitar',
		barbarian = 'rageblade',
		gingerbread_man = 'gumdrop_bounce_pad',
		spirit_catcher = 'spirit',
		fisherman = 'fishing_rod',
		oil_man = 'oil_consumable',
		santa = 'tnt',
		miner = 'miner_pickaxe',
		sheep_herder = 'crook',
		beast = 'speed_potion',
		metal_detector = 'metal_detector',
		cyber = 'drone',
		vesta = 'damage_banner',
		lumen = 'light_sword',
		ember = 'infernal_saber',
		queen_bee = 'bee'
	}

	local nametagfuncs1 = {
		Normal = function(plr)
			if NameTagsTeammates.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
			local thing = Instance.new('TextLabel')
			thing.BackgroundColor3 = Color3.new()
			thing.BorderSizePixel = 0
			thing.Visible = false
			thing.RichText = true
			thing.AnchorPoint = Vector2.new(0.5, 1)
			thing.Name = plr.Player.Name
			thing.Font = Enum.Font[NameTagsFont.Value]
			thing.TextSize = 14 * (NameTagsScale.Value / 10)
			thing.BackgroundTransparency = NameTagsBackground.Enabled and 0.5 or 1
			nametagstrs[plr.Player] = WhitelistFunctions:GetTag(plr.Player)..(NameTagsDisplayName.Enabled and plr.Player.DisplayName or plr.Player.Name)
			if NameTagsHealth.Enabled then
				local color = Color3.fromHSV(math.clamp(plr.Humanoid.Health / plr.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
				nametagstrs[plr.Player] = nametagstrs[plr.Player]..' <font color="rgb('..tostring(math.floor(color.R * 255))..','..tostring(math.floor(color.G * 255))..','..tostring(math.floor(color.B * 255))..')">'..math.round(plr.Humanoid.Health)..'</font>'
			end
			if NameTagsDistance.Enabled then 
				nametagstrs[plr.Player] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '..nametagstrs[plr.Player]
			end
			local nametagSize = textService:GetTextSize(removeTags(nametagstrs[plr.Player]), thing.TextSize, thing.Font, Vector2.new(100000, 100000))
			thing.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
			thing.Text = nametagstrs[plr.Player]
			thing.TextColor3 = getPlayerColor(plr.Player) or Color3.fromHSV(NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
			thing.Parent = NameTagsFolder
			local hand = Instance.new('ImageLabel')
			hand.Size = UDim2.new(0, 30, 0, 30)
			hand.Name = 'Hand'
			hand.BackgroundTransparency = 1
			hand.Position = UDim2.new(0, -30, 0, -30)
			hand.Image = ''
			hand.Parent = thing
			local helmet = hand:Clone()
			helmet.Name = 'Helmet'
			helmet.Position = UDim2.new(0, 5, 0, -30)
			helmet.Parent = thing
			local chest = hand:Clone()
			chest.Name = 'Chestplate'
			chest.Position = UDim2.new(0, 35, 0, -30)
			chest.Parent = thing
			local boots = hand:Clone()
			boots.Name = 'Boots'
			boots.Position = UDim2.new(0, 65, 0, -30)
			boots.Parent = thing
			local kit = hand:Clone()
			kit.Name = 'Kit'
			task.spawn(function()
				repeat task.wait() until plr.Player:GetAttribute('PlayingAsKit') ~= ''
				if kit then
					kit.Image = kititems[plr.Player:GetAttribute('PlayingAsKit')] and bedwars.getIcon({itemType = kititems[plr.Player:GetAttribute('PlayingAsKit')]}, NameTagsShowInventory.Enabled) or ''
				end
			end)
			kit.Position = UDim2.new(0, -30, 0, -65)
			kit.Parent = thing
			nametagsfolderdrawing[plr.Player] = {entity = plr, Main = thing}
		end,
		Drawing = function(plr)
			if NameTagsTeammates.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
			local thing = {Main = {}, entity = plr}
			thing.Main.Text = Drawing.new('Text')
			thing.Main.Text.Size = 17 * (NameTagsScale.Value / 10)
			thing.Main.Text.Font = (math.clamp((table.find(fontitems, NameTagsFont.Value) or 1) - 1, 0, 3))
			thing.Main.Text.ZIndex = 2
			thing.Main.BG = Drawing.new('Square')
			thing.Main.BG.Filled = true
			thing.Main.BG.Transparency = 0.5
			thing.Main.BG.Visible = NameTagsBackground.Enabled
			thing.Main.BG.Color = Color3.new()
			thing.Main.BG.ZIndex = 1
			nametagstrs[plr.Player] = WhitelistFunctions:GetTag(plr.Player)..(NameTagsDisplayName.Enabled and plr.Player.DisplayName or plr.Player.Name)
			if NameTagsHealth.Enabled then
				local color = Color3.fromHSV(math.clamp(plr.Humanoid.Health / plr.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
				nametagstrs[plr.Player] = nametagstrs[plr.Player]..' '..math.round(plr.Humanoid.Health)
			end
			if NameTagsDistance.Enabled then 
				nametagstrs[plr.Player] = '[%s] '..nametagstrs[plr.Player]
			end
			thing.Main.Text.Text = nametagstrs[plr.Player]
			thing.Main.BG.Size = Vector2.new(thing.Main.Text.TextBounds.X + 4, thing.Main.Text.TextBounds.Y)
			thing.Main.Text.Color = getPlayerColor(plr.Player) or Color3.fromHSV(NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
			nametagsfolderdrawing[plr.Player] = thing
		end
	}

	local nametagfuncs2 = {
		Normal = function(ent)
			local v = nametagsfolderdrawing[ent]
			nametagsfolderdrawing[ent] = nil
			if v then 
				v.Main:Destroy()
			end
		end,
		Drawing = function(ent)
			local v = nametagsfolderdrawing[ent]
			nametagsfolderdrawing[ent] = nil
			if v then 
				for i2,v2 in next, (v.Main) do
					pcall(function() v2.Visible = false v2:Remove() end)
				end
			end
		end
	}

	local nametagupdatefuncs = {
		Normal = function(ent)
			local v = nametagsfolderdrawing[ent.Player]
			if v then 
				nametagstrs[ent.Player] = WhitelistFunctions:GetTag(ent.Player)..(NameTagsDisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name)
				if NameTagsHealth.Enabled then
					local color = Color3.fromHSV(math.clamp(ent.Humanoid.Health / ent.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
					nametagstrs[ent.Player] = nametagstrs[ent.Player]..' <font color="rgb('..tostring(math.floor(color.R * 255))..','..tostring(math.floor(color.G * 255))..','..tostring(math.floor(color.B * 255))..')">'..math.round(ent.Humanoid.Health)..'</font>'
				end
				if NameTagsDistance.Enabled then 
					nametagstrs[ent.Player] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '..nametagstrs[ent.Player]
				end
				if NameTagsShowInventory.Enabled then 
					local inventory = bedwarsStore.inventories[ent.Player] or {armor = {}}
					if inventory.hand then
						v.Main.Hand.Image = bedwars.getIcon(inventory.hand, NameTagsShowInventory.Enabled)
						if v.Main.Hand.Image:find('rbxasset://') then
							v.Main.Hand.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Hand.Image = ''
					end
					if inventory.armor[4] then
						v.Main.Helmet.Image = bedwars.getIcon(inventory.armor[4], NameTagsShowInventory.Enabled)
						if v.Main.Helmet.Image:find('rbxasset://') then
							v.Main.Helmet.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Helmet.Image = ''
					end
					if inventory.armor[5] then
						v.Main.Chestplate.Image = bedwars.getIcon(inventory.armor[5], NameTagsShowInventory.Enabled)
						if v.Main.Chestplate.Image:find('rbxasset://') then
							v.Main.Chestplate.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Chestplate.Image = ''
					end
					if inventory.armor[6] then
						v.Main.Boots.Image = bedwars.getIcon(inventory.armor[6], NameTagsShowInventory.Enabled)
						if v.Main.Boots.Image:find('rbxasset://') then
							v.Main.Boots.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Boots.Image = ''
					end
				end
				local nametagSize = textService:GetTextSize(removeTags(nametagstrs[ent.Player]), v.Main.TextSize, v.Main.Font, Vector2.new(100000, 100000))
				v.Main.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
				v.Main.Text = nametagstrs[ent.Player]
			end
		end,
		Drawing = function(ent)
			local v = nametagsfolderdrawing[ent.Player]
			if v then 
				nametagstrs[ent.Player] = WhitelistFunctions:GetTag(ent.Player)..(NameTagsDisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name)
				if NameTagsHealth.Enabled then
					nametagstrs[ent.Player] = nametagstrs[ent.Player]..' '..math.round(ent.Humanoid.Health)
				end
				if NameTagsDistance.Enabled then 
					nametagstrs[ent.Player] = '[%s] '..nametagstrs[ent.Player]
					v.Main.Text.Text = entityLibrary.isAlive and string.format(nametagstrs[ent.Player], math.floor((entityLibrary.character.HumanoidRootPart.Position - ent.RootPart.Position).Magnitude)) or nametagstrs[ent.Player]
				else
					v.Main.Text.Text = nametagstrs[ent.Player]
				end
				v.Main.BG.Size = Vector2.new(v.Main.Text.TextBounds.X + 4, v.Main.Text.TextBounds.Y)
				v.Main.Text.Color = getPlayerColor(ent.Player) or Color3.fromHSV(NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
			end
		end
	}

	local nametagcolorfuncs = {
		Normal = function(hue, sat, value)
			local color = Color3.fromHSV(hue, sat, value)
			for i,v in next, (nametagsfolderdrawing) do 
				v.Main.TextColor3 = getPlayerColor(v.entity.Player) or color
			end
		end,
		Drawing = function(hue, sat, value)
			local color = Color3.fromHSV(hue, sat, value)
			for i,v in next, (nametagsfolderdrawing) do 
				v.Main.Text.Color = getPlayerColor(v.entity.Player) or color
			end
		end
	}

	local nametagloop = {
		Normal = function()
			for i,v in next, (nametagsfolderdrawing) do 
				local headPos, headVis = worldtoscreenpoint((v.entity.RootPart:GetRenderCFrame() * CFrame.new(0, v.entity.Head.Size.Y + v.entity.RootPart.Size.Y, 0)).Position)
				if not headVis then 
					v.Main.Visible = false
					continue
				end
				local mag = entityLibrary.isAlive and math.floor((entityLibrary.character.HumanoidRootPart.Position - v.entity.RootPart.Position).Magnitude) or 0
				if NameTagsRangeLimit.Value ~= 0 and mag > NameTagsRangeLimit.Value then 
					v.Main.Visible = false
					continue
				end
				if NameTagsDistance.Enabled then
					local stringsize = tostring(mag):len()
					if nametagsizes[v.entity.Player] ~= stringsize then 
						local nametagSize = textService:GetTextSize(removeTags(string.format(nametagstrs[v.entity.Player], mag)), v.Main.TextSize, v.Main.Font, Vector2.new(100000, 100000))
						v.Main.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
					end
					nametagsizes[v.entity.Player] = stringsize
					v.Main.Text = string.format(nametagstrs[v.entity.Player], mag)
				end
				v.Main.Position = UDim2.new(0, headPos.X, 0, headPos.Y)
				v.Main.Visible = true
			end
		end,
		Drawing = function()
			for i,v in next, (nametagsfolderdrawing) do 
				local headPos, headVis = worldtoscreenpoint((v.entity.RootPart:GetRenderCFrame() * CFrame.new(0, v.entity.Head.Size.Y + v.entity.RootPart.Size.Y, 0)).Position)
				if not headVis then 
					v.Main.Text.Visible = false
					v.Main.BG.Visible = false
					continue
				end
				local mag = entityLibrary.isAlive and math.floor((entityLibrary.character.HumanoidRootPart.Position - v.entity.RootPart.Position).Magnitude) or 0
				if NameTagsRangeLimit.Value ~= 0 and mag > NameTagsRangeLimit.Value then 
					v.Main.Text.Visible = false
					v.Main.BG.Visible = false
					continue
				end
				if NameTagsDistance.Enabled then
					local stringsize = tostring(mag):len()
					v.Main.Text.Text = string.format(nametagstrs[v.entity.Player], mag)
					if nametagsizes[v.entity.Player] ~= stringsize then 
						v.Main.BG.Size = Vector2.new(v.Main.Text.TextBounds.X + 4, v.Main.Text.TextBounds.Y)
					end
					nametagsizes[v.entity.Player] = stringsize
				end
				v.Main.BG.Position = Vector2.new(headPos.X - (v.Main.BG.Size.X / 2), (headPos.Y + v.Main.BG.Size.Y))
				v.Main.Text.Position = v.Main.BG.Position + Vector2.new(2, 0)
				v.Main.Text.Visible = true
				v.Main.BG.Visible = NameTagsBackground.Enabled
			end
		end
	}

	local methodused

	local NameTags = {Enabled = false}
	NameTags = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'NameTags', 
		Function = function(callback) 
			if callback then
				methodused = NameTagsDrawing.Enabled and 'Drawing' or 'Normal'
				if nametagfuncs2[methodused] then
					table.insert(NameTags.Connections, entityLibrary.entityRemovedEvent:Connect(nametagfuncs2[methodused]))
				end
				if nametagfuncs1[methodused] then
					local addfunc = nametagfuncs1[methodused]
					for i,v in next, (entityLibrary.entityList) do 
						if nametagsfolderdrawing[v.Player] then nametagfuncs2[methodused](v.Player) end
						addfunc(v)
					end
					table.insert(NameTags.Connections, entityLibrary.entityAddedEvent:Connect(function(ent)
						if nametagsfolderdrawing[ent.Player] then nametagfuncs2[methodused](ent.Player) end
						addfunc(ent)
					end))
				end
				if nametagupdatefuncs[methodused] then
					table.insert(NameTags.Connections, entityLibrary.entityUpdatedEvent:Connect(nametagupdatefuncs[methodused]))
					for i,v in next, (entityLibrary.entityList) do 
						nametagupdatefuncs[methodused](v)
					end
				end
				if nametagcolorfuncs[methodused] then 
					table.insert(NameTags.Connections, GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.FriendColorRefresh.Event:Connect(function()
						nametagcolorfuncs[methodused](NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
					end))
				end
				if nametagloop[methodused] then 
					RunLoops:BindToRenderStep('NameTags', nametagloop[methodused])
				end
			else
				RunLoops:UnbindFromRenderStep('NameTags')
				if nametagfuncs2[methodused] then
					for i,v in next, (nametagsfolderdrawing) do 
						nametagfuncs2[methodused](i)
					end
				end
			end
		end,
		HoverText = 'Renders nametags on entities through walls.'
	})
	for i,v in next, (Enum.Font:GetEnumItems()) do 
		if v.Name ~= 'SourceSans' then 
			table.insert(fontitems, v.Name)
		end
	end
	NameTagsFont = NameTags.CreateDropdown({
		Name = 'Font',
		List = fontitems,
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
	})
	NameTagsColor = NameTags.CreateColorSlider({
		Name = 'Player Color', 
		Function = function(hue, sat, val) 
			if NameTags.Enabled and nametagcolorfuncs[methodused] then 
				nametagcolorfuncs[methodused](hue, sat, val)
			end
		end
	})
	NameTagsScale = NameTags.CreateSlider({
		Name = 'Scale',
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = 10,
		Min = 1,
		Max = 50
	})
	NameTagsRangeLimit = NameTags.CreateSlider({
		Name = 'Range',
		Function = function() end,
		Min = 0,
		Max = 1000,
		Default = 0
	})
	NameTagsBackground = NameTags.CreateToggle({
		Name = 'Background', 
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsDisplayName = NameTags.CreateToggle({
		Name = 'Use Display Name', 
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsHealth = NameTags.CreateToggle({
		Name = 'Health', 
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end
	})
	NameTagsDistance = NameTags.CreateToggle({
		Name = 'Distance', 
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end
	})
	NameTagsShowInventory = NameTags.CreateToggle({
		Name = 'Equipment',
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsTeammates = NameTags.CreateToggle({
		Name = 'Teammates', 
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsDrawing = NameTags.CreateToggle({
		Name = 'Drawing',
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
	})
end)

runFunction(function()
	local nobobdepth = {Value = 8}
	local nobobhorizontal = {Value = 8}
	local nobobvertical = {Value = -2}
	local rotationx = {Value = 0}
	local rotationy = {Value = 0}
	local rotationz = {Value = 0}
	local oldc1
	local oldfunc
	local nobob = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'NoBob',
		Function = function(callback) 
			local viewmodel = gameCamera:FindFirstChild('Viewmodel')
			if viewmodel then
				if callback then
					oldfunc = bedwars.ViewmodelController.playAnimation
					bedwars.ViewmodelController.playAnimation = function(self, animid, details)
						if animid == bedwars.AnimationType.FP_WALK then
							return
						end
						return oldfunc(self, animid, details)
					end
					bedwars.ViewmodelController:setHeldItem(lplr.Character and lplr.Character:FindFirstChild('HandInvItem') and lplr.Character.HandInvItem.Value and lplr.Character.HandInvItem.Value:Clone())
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_DEPTH_OFFSET', -(nobobdepth.Value / 10))
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_HORIZONTAL_OFFSET', (nobobhorizontal.Value / 10))
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_VERTICAL_OFFSET', (nobobvertical.Value / 10))
					oldc1 = viewmodel.RightHand.RightWrist.C1
					viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
				else
					bedwars.ViewmodelController.playAnimation = oldfunc
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_DEPTH_OFFSET', 0)
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_HORIZONTAL_OFFSET', 0)
					lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_VERTICAL_OFFSET', 0)
					viewmodel.RightHand.RightWrist.C1 = oldc1
				end
			end
		end,
		HoverText = 'Removes the ugly bobbing when you move and makes sword farther'
	})
	nobobdepth = nobob.CreateSlider({
		Name = 'Depth',
		Min = 0,
		Max = 24,
		Default = 8,
		Function = function(val)
			if nobob.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_DEPTH_OFFSET', -(val / 10))
			end
		end
	})
	nobobhorizontal = nobob.CreateSlider({
		Name = 'Horizontal',
		Min = 0,
		Max = 24,
		Default = 8,
		Function = function(val)
			if nobob.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_HORIZONTAL_OFFSET', (val / 10))
			end
		end
	})
	nobobvertical= nobob.CreateSlider({
		Name = 'Vertical',
		Min = 0,
		Max = 24,
		Default = -2,
		Function = function(val)
			if nobob.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel['viewmodel-controller']:SetAttribute('ConstantManager_VERTICAL_OFFSET', (val / 10))
			end
		end
	})
	rotationx = nobob.CreateSlider({
		Name = 'RotX',
		Min = 0,
		Max = 360,
		Function = function(val)
			if nobob.Enabled then
				gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
	rotationy = nobob.CreateSlider({
		Name = 'RotY',
		Min = 0,
		Max = 360,
		Function = function(val)
			if nobob.Enabled then
				gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
	rotationz = nobob.CreateSlider({
		Name = 'RotZ',
		Min = 0,
		Max = 360,
		Function = function(val)
			if nobob.Enabled then
				gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
end)

runFunction(function()
	local SongBeats = {Enabled = false}
	local SongBeatsList = {ObjectList = {}}
	local SongBeatsIntensity = {Value = 5}
	local SongTween
	local SongAudio

	local function PlaySong(arg)
		local args = arg:split(':')
		local song = isfile(args[1]) and getcustomasset(args[1]) or tonumber(args[1]) and 'rbxassetid://'..args[1]
		if not song then 
			warningNotification('SongBeats', 'missing music file '..args[1], 5)
			SongBeats.ToggleButton(false)
			return
		end
		local bpm = 1 / (args[2] / 60)
		SongAudio = Instance.new('Sound')
		SongAudio.SoundId = song
		SongAudio.Parent = workspace
		SongAudio:Play()
		repeat
			repeat task.wait() until SongAudio.IsLoaded or (not SongBeats.Enabled) 
			if (not SongBeats.Enabled) then break end
			local newfov = math.min(bedwars.FovController:getFOV() * (bedwars.SprintController.sprinting and 1.1 or 1), 120)
			gameCamera.FieldOfView = newfov - SongBeatsIntensity.Value
			if SongTween then SongTween:Cancel() end
			SongTween = game:GetService('TweenService'):Create(gameCamera, TweenInfo.new(0.2), {FieldOfView = newfov})
			SongTween:Play()
			task.wait(bpm)
		until (not SongBeats.Enabled) or SongAudio.IsPaused
	end

	SongBeats = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'SongBeats',
		Function = function(callback)
			if callback then 
				task.spawn(function()
					if #SongBeatsList.ObjectList <= 0 then 
						warningNotification('SongBeats', 'no songs', 5)
						SongBeats.ToggleButton(false)
						return
					end
					local lastChosen
					repeat
						local newSong
						repeat newSong = SongBeatsList.ObjectList[Random.new():NextInteger(1, #SongBeatsList.ObjectList)] task.wait() until newSong ~= lastChosen or #SongBeatsList.ObjectList <= 1
						lastChosen = newSong
						PlaySong(newSong)
						if not SongBeats.Enabled then break end
						task.wait(2)
					until (not SongBeats.Enabled)
				end)
			else
				if SongAudio then SongAudio:Destroy() end
				if SongTween then SongTween:Cancel() end
				gameCamera.FieldOfView = bedwars.FovController:getFOV() * (bedwars.SprintController.sprinting and 1.1 or 1)
			end
		end
	})
	SongBeatsList = SongBeats.CreateTextList({
		Name = 'SongList',
		TempText = 'songpath:bpm'
	})
	SongBeatsIntensity = SongBeats.CreateSlider({
		Name = 'Intensity',
		Function = function() end,
		Min = 1,
		Max = 10,
		Default = 5
	})
end)

runFunction(function()
	local performed = false
	GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = 'UICleanup',
		Function = function(callback)
			if callback and not performed then 
				performed = true
				task.spawn(function()
					local hotbar = require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui['hotbar-app']).HotbarApp
					local hotbaropeninv = require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui['hotbar-open-inventory']).HotbarOpenInventory
					local topbarbutton = require(replicatedStorageService['rbxts_include']['node_modules']['@easy-games']['game-core'].out).TopBarButton
					local gametheme = require(replicatedStorageService['rbxts_include']['node_modules']['@easy-games']['game-core'].out.shared.ui['game-theme']).GameTheme
					bedwars.AppController:closeApp('TopBarApp')
					local oldrender = topbarbutton.render
					topbarbutton.render = function(self) 
						local res = oldrender(self)
						if not self.props.Text then
							return bedwars.Roact.createElement('TextButton', {Visible = false}, {})
						end
						return res
					end
					hotbaropeninv.render = function(self) 
						return bedwars.Roact.createElement('TextButton', {Visible = false}, {})
					end
					debug.setconstant(hotbar.render, 52, 0.9975)
					debug.setconstant(hotbar.render, 73, 100)
					debug.setconstant(hotbar.render, 89, 1)
					debug.setconstant(hotbar.render, 90, 0.04)
					debug.setconstant(hotbar.render, 91, -0.03)
					debug.setconstant(hotbar.render, 109, 1.35)
					debug.setconstant(hotbar.render, 110, 0)
					debug.setconstant(debug.getupvalue(hotbar.render, 11).render, 30, 1)
					debug.setconstant(debug.getupvalue(hotbar.render, 11).render, 31, 0.175)
					debug.setconstant(debug.getupvalue(hotbar.render, 11).render, 33, -0.101)
					debug.setconstant(debug.getupvalue(hotbar.render, 18).render, 71, 0)
					debug.setconstant(debug.getupvalue(hotbar.render, 18).tweenPosition, 16, 0)
					gametheme.topBarBGTransparency = 0.5
					bedwars.TopBarController:mountHud()
					game:GetService('StarterGui'):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
					bedwars.AbilityUIController.abilityButtonsScreenGui.Enabled = false
					bedwars.MatchEndScreenController.waitUntilDisplay = function() return false end
					task.spawn(function()
						repeat
							task.wait()
							local gui = lplr.PlayerGui:FindFirstChild('StatusEffectHudScreen')
							if gui then gui.Enabled = false break end
						until false
					end)
					task.spawn(function()
						repeat task.wait() until bedwarsStore.matchState ~= 0
						if bedwars.ClientStoreHandler:getState().Game.customMatch == nil then 
							debug.setconstant(bedwars.QueueCard.render, 15, 0.1)
						end
					end)
					local slot = bedwars.ClientStoreHandler:getState().Inventory.observedInventory.hotbarSlot
					bedwars.ClientStoreHandler:dispatch({
						type = 'InventorySelectHotbarSlot',
						slot = slot + 1 % 8
					})
					bedwars.ClientStoreHandler:dispatch({
						type = 'InventorySelectHotbarSlot',
						slot = slot
					})
				end)
			end
		end
	})
end)

runFunction(function()
	local AntiAFK = {Enabled = false}
	AntiAFK = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AntiAFK',
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat 
						task.wait(5) 
						bedwars.ClientHandler:Get('AfkInfo'):SendToServer({
							afk = false
						})
					until (not AntiAFK.Enabled)
				end)
			end
		end
	})
end)

runFunction(function()
	local AutoBalloonPart
	local AutoBalloonConnection
	local AutoBalloonDelay = {Value = 10}
	local AutoBalloonLegit = {Enabled = false}
	local AutoBalloonypos = 0
	local balloondebounce = false
	local AutoBalloon = {Enabled = false}
	AutoBalloon = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoBalloon', 
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until bedwarsStore.matchState ~= 0 or  not vapeInjected
					if vapeInjected and AutoBalloonypos == 0 and AutoBalloon.Enabled then
						local lowestypos = 99999
						for i,v in next, (bedwarsStore.blocks) do 
							local newray = workspace:Raycast(v.Position + Vector3.new(0, 800, 0), Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							if i % 200 == 0 then 
								task.wait(0.06)
							end
							if newray and newray.Position.Y <= lowestypos then
								lowestypos = newray.Position.Y
							end
						end
						AutoBalloonypos = lowestypos - 8
					end
				end)
				task.spawn(function()
					repeat task.wait() until AutoBalloonypos ~= 0
					if AutoBalloon.Enabled then
						AutoBalloonPart = Instance.new('Part')
						AutoBalloonPart.CanCollide = false
						AutoBalloonPart.Size = Vector3.new(10000, 1, 10000)
						AutoBalloonPart.Anchored = true
						AutoBalloonPart.Transparency = 1
						AutoBalloonPart.Material = Enum.Material.Neon
						AutoBalloonPart.Color = Color3.fromRGB(135, 29, 139)
						AutoBalloonPart.Position = Vector3.new(0, AutoBalloonypos - 50, 0)
						AutoBalloonConnection = AutoBalloonPart.Touched:Connect(function(touchedpart)
							if entityLibrary.isAlive and touchedpart:IsDescendantOf(lplr.Character) and balloondebounce == false then
								autobankballoon = true
								balloondebounce = true
								local oldtool = bedwarsStore.localHand.tool
								for i = 1, 3 do
									if getItem('balloon') and (AutoBalloonLegit.Enabled and getHotbarSlot('balloon') or AutoBalloonLegit.Enabled == false) and (lplr.Character:GetAttribute('InflatedBalloons') and lplr.Character:GetAttribute('InflatedBalloons') < 3 or lplr.Character:GetAttribute('InflatedBalloons') == nil) then
										if AutoBalloonLegit.Enabled then
											if getHotbarSlot('balloon') then
												bedwars.ClientStoreHandler:dispatch({
													type = 'InventorySelectHotbarSlot', 
													slot = getHotbarSlot('balloon')
												})
												task.wait(AutoBalloonDelay.Value / 100)
												bedwars.BalloonController:inflateBalloon()
											end
										else
											task.wait(AutoBalloonDelay.Value / 100)
											bedwars.BalloonController:inflateBalloon()
										end
									end
								end
								if AutoBalloonLegit.Enabled and oldtool and getHotbarSlot(oldtool.Name) then
									task.wait(0.2)
									bedwars.ClientStoreHandler:dispatch({
										type = 'InventorySelectHotbarSlot', 
										slot = (getHotbarSlot(oldtool.Name) or 0)
									})
								end
								balloondebounce = false
								autobankballoon = false
							end
						end)
						AutoBalloonPart.Parent = workspace
					end
				end)
			else
				if AutoBalloonConnection then AutoBalloonConnection:Disconnect() end
				if AutoBalloonPart then
					AutoBalloonPart:Remove() 
				end
			end
		end, 
		HoverText = 'Automatically Inflates Balloons'
	})
	AutoBalloonDelay = AutoBalloon.CreateSlider({
		Name = 'Delay',
		Min = 1,
		Max = 50,
		Default = 20,
		Function = function() end,
		HoverText = 'Delay to inflate balloons.'
	})
	AutoBalloonLegit = AutoBalloon.CreateToggle({
		Name = 'Legit Mode',
		Function = function() end,
		HoverText = 'Switches to balloons in hotbar and inflates them.'
	})
end)

local autobankapple = false
runFunction(function()
	local AutoBuy = {Enabled = false}
	local AutoBuyArmor = {Enabled = false}
	local AutoBuySword = {Enabled = false}
	local AutoBuyUpgrades = {Enabled = false}
	local AutoBuyGen = {Enabled = false}
	local AutoBuyProt = {Enabled = false}
	local AutoBuySharp = {Enabled = false}
	local AutoBuyDestruction = {Enabled = false}
	local AutoBuyDiamond = {Enabled = false}
	local AutoBuyAlarm = {Enabled = false}
	local AutoBuyGui = {Enabled = false}
	local AutoBuyTierSkip = {Enabled = true}
	local AutoBuyRange = {Value = 20}
	local AutoBuyCustom = {ObjectList = {}, RefreshList = function() end}
	local AutoBankUIToggle = {Enabled = false}
	local AutoBankDeath = {Enabled = false}
	local AutoBankStay = {Enabled = false}
	local buyingthing = false
	local shoothook
	local bedwarsshopnpcs = {}
	local id
	local armors = {
		[1] = 'leather_chestplate',
		[2] = 'iron_chestplate',
		[3] = 'diamond_chestplate',
		[4] = 'emerald_chestplate'
	}

	local swords = {
		[1] = 'wood_sword',
		[2] = 'stone_sword',
		[3] = 'iron_sword',
		[4] = 'diamond_sword',
		[5] = 'emerald_sword'
	}

	local axes = {
		[1] = 'wood_axe',
		[2] = 'stone_axe',
		[3] = 'iron_axe',
		[4] = 'diamond_axe'
	}

	local pickaxes = {
		[1] = 'wood_pickaxe',
		[2] = 'stone_pickaxe',
		[3] = 'iron_pickaxe',
		[4] = 'diamond_pickaxe'
	}

	task.spawn(function()
		repeat task.wait() until bedwarsStore.matchState ~= 0 or not vapeInjected
		for i,v in next, (collectionService:GetTagged('BedwarsItemShop')) do
			table.insert(bedwarsshopnpcs, {Position = v.Position, TeamUpgradeNPC = true, Id = v.Name})
		end
		for i,v in next, (collectionService:GetTagged('BedwarsTeamUpgrader')) do
			table.insert(bedwarsshopnpcs, {Position = v.Position, TeamUpgradeNPC = false, Id = v.Name})
		end
	end)

	local function nearNPC(range)
		local npc, npccheck, enchant, newid = nil, false, false, nil
		if entityLibrary.isAlive then
			local enchanttab = {}
			for i,v in next, (collectionService:GetTagged('broken-enchant-table')) do 
				table.insert(enchanttab, v)
			end
			for i,v in next, (collectionService:GetTagged('enchant-table')) do 
				table.insert(enchanttab, v)
			end
			for i,v in next, (enchanttab) do 
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= 6 then
					if ((not v:GetAttribute('Team')) or v:GetAttribute('Team') == lplr:GetAttribute('Team')) then
						npc, npccheck, enchant = true, true, true
					end
				end
			end
			for i, v in next, (bedwarsshopnpcs) do
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= (range or 20) then
					npc, npccheck, enchant = true, (v.TeamUpgradeNPC or npccheck), false
					newid = v.TeamUpgradeNPC and v.Id or newid
				end
			end
			local suc, res = pcall(function() return lplr.leaderstats.Bed.Value == '✅'  end)
			if AutoBankDeath.Enabled and (workspace:GetServerTimeNow() - lplr.Character:GetAttribute('LastDamageTakenTime')) < 2 and suc and res then 
				return nil, false, false
			end
			if AutoBankStay.Enabled then 
				return nil, false, false
			end
		end
		return npc, not npccheck, enchant, newid
	end

	local function buyItem(itemtab, waitdelay)
		if not id then return end
		local res
		bedwars.ClientHandler:Get('BedwarsPurchaseItem'):CallServerAsync({
			shopItem = itemtab,
			shopId = id
		}):andThen(function(p11)
			if p11 then
				bedwars.SoundManager:playSound(bedwars.SoundList.BEDWARS_PURCHASE_ITEM)
				bedwars.ClientStoreHandler:dispatch({
					type = 'BedwarsAddItemPurchased', 
					itemType = itemtab.itemType
				})
			end
			res = p11
		end)
		if waitdelay then 
			repeat task.wait() until res ~= nil
		end
	end

	local function buyUpgrade(upgradetype, inv, upgrades)
		if not AutoBuyUpgrades.Enabled then return end
		local teamupgrade = bedwars.Shop.getUpgrade(bedwars.Shop.TeamUpgrades, upgradetype)
		local teamtier = teamupgrade.tiers[upgrades[upgradetype] and upgrades[upgradetype] + 2 or 1]
		if teamtier then 
			local teamcurrency = getItem(teamtier.currency, inv.items)
			if teamcurrency and teamcurrency.amount >= teamtier.price then 
				bedwars.ClientHandler:Get('BedwarsPurchaseTeamUpgrade'):CallServerAsync({
					upgradeId = upgradetype, 
					tier = upgrades[upgradetype] and upgrades[upgradetype] + 1 or 0
				}):andThen(function(suc)
					if suc then
						bedwars.SoundManager:playSound(bedwars.SoundList.BEDWARS_PURCHASE_ITEM)
					end
				end)
			end
		end
	end

	local function getAxeNear(inv)
		for i5, v5 in next, (inv or bedwarsStore.localInventory.inventory.items) do
			if v5.itemType:find('axe') and v5.itemType:find('pickaxe') == nil then
				return v5.itemType
			end
		end
		return nil
	end

	local function getPickaxeNear(inv)
		for i5, v5 in next, (inv or bedwarsStore.localInventory.inventory.items) do
			if v5.itemType:find('pickaxe') then
				return v5.itemType
			end
		end
		return nil
	end

	local function getShopItem(itemType)
		if itemType == 'axe' then 
			itemType = getAxeNear() or 'wood_axe'
			itemType = axes[table.find(axes, itemType) + 1] or itemType
		end
		if itemType == 'pickaxe' then 
			itemType = getPickaxeNear() or 'wood_pickaxe'
			itemType = pickaxes[table.find(pickaxes, itemType) + 1] or itemType
		end
		for i,v in next, (bedwars.ShopItems) do 
			if v.itemType == itemType then return v end
		end
		return nil
	end

	local buyfunctions = {
		Armor = function(inv, upgrades, shoptype) 
			if AutoBuyArmor.Enabled == false or shoptype ~= 'item' then return end
			local currentarmor = (inv.armor[2] ~= 'empty' and inv.armor[2].itemType:find('chestplate') ~= nil) and inv.armor[2] or nil
			local armorindex = (currentarmor and table.find(armors, currentarmor.itemType) or 0) + 1
			if armors[armorindex] == nil then return end
			local highestbuyable = nil
			for i = armorindex, #armors, 1 do 
				local shopitem = getShopItem(armors[i])
				if shopitem and (AutoBuyTierSkip.Enabled or i == armorindex) then 
					local currency = getItem(shopitem.currency, inv.items)
					if currency and currency.amount >= shopitem.price then 
						highestbuyable = shopitem
						bedwars.ClientStoreHandler:dispatch({
							type = 'BedwarsAddItemPurchased', 
							itemType = shopitem.itemType
						})
					end
				end
			end
			if highestbuyable and (highestbuyable.ignoredByKit == nil or table.find(highestbuyable.ignoredByKit, bedwarsStore.equippedKit) == nil) then 
				buyItem(highestbuyable)
			end
		end,
		Sword = function(inv, upgrades, shoptype)
			if AutoBuySword.Enabled == false or shoptype ~= 'item' then return end
			local currentsword = getItemNear('sword', inv.items)
			local swordindex = (currentsword and table.find(swords, currentsword.itemType) or 0) + 1
			if currentsword ~= nil and table.find(swords, currentsword.itemType) == nil then return end
			local highestbuyable = nil
			for i = swordindex, #swords, 1 do 
				local shopitem = getShopItem(swords[i])
				if shopitem then 
					local currency = getItem(shopitem.currency, inv.items)
					if currency and currency.amount >= shopitem.price and (shopitem.category ~= 'Armory' or upgrades.armory) then 
						highestbuyable = shopitem
						bedwars.ClientStoreHandler:dispatch({
							type = 'BedwarsAddItemPurchased', 
							itemType = shopitem.itemType
						})
					end
				end
			end
			if highestbuyable and (highestbuyable.ignoredByKit == nil or table.find(highestbuyable.ignoredByKit, bedwarsStore.equippedKit) == nil) then 
				buyItem(highestbuyable)
			end
		end,
		Protection = function(inv, upgrades)
			if not AutoBuyProt.Enabled then return end
			buyUpgrade('armor', inv, upgrades)
		end,
		Sharpness = function(inv, upgrades)
			if not AutoBuySharp.Enabled then return end
			buyUpgrade('damage', inv, upgrades)
		end,
		Generator = function(inv, upgrades)
			if not AutoBuyGen.Enabled then return end
			buyUpgrade('generator', inv, upgrades)
		end,
		Destruction = function(inv, upgrades)
			if not AutoBuyDestruction.Enabled then return end
			buyUpgrade('destruction', inv, upgrades)
		end,
		Diamond = function(inv, upgrades)
			if not AutoBuyDiamond.Enabled then return end
			buyUpgrade('diamond_generator', inv, upgrades)
		end,
		Alarm = function(inv, upgrades)
			if not AutoBuyAlarm.Enabled then return end
			buyUpgrade('alarm', inv, upgrades)
		end
	}

	AutoBuy = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoBuy', 
		Function = function(callback)
			if callback then 
				buyingthing = false 
				task.spawn(function()
					repeat
						task.wait()
						local found, npctype, enchant, newid = nearNPC(AutoBuyRange.Value)
						id = newid
						if found then
							local inv = bedwarsStore.localInventory.inventory
							local currentupgrades = bedwars.ClientStoreHandler:getState().Bedwars.teamUpgrades
							if bedwarsStore.equippedKit == 'dasher' then 
								swords = {
									[1] = 'wood_dao',
									[2] = 'stone_dao',
									[3] = 'iron_dao',
									[4] = 'diamond_dao',
									[5] = 'emerald_dao'
								}
							elseif bedwarsStore.equippedKit == 'ice_queen' then 
								swords[5] = 'ice_sword'
							elseif bedwarsStore.equippedKit == 'ember' then 
								swords[5] = 'infernal_saber'
							elseif bedwarsStore.equippedKit == 'lumen' then 
								swords[5] = 'light_sword'
							end
							if (AutoBuyGui.Enabled == false or (bedwars.AppController:isAppOpen('BedwarsItemShopApp') or bedwars.AppController:isAppOpen('BedwarsTeamUpgradeApp'))) and (not enchant) then
								for i,v in next, (AutoBuyCustom.ObjectList) do 
									local autobuyitem = v:split('/')
									if #autobuyitem >= 3 and autobuyitem[4] ~= 'true' then 
										local shopitem = getShopItem(autobuyitem[1])
										if shopitem then 
											local currency = getItem(shopitem.currency, inv.items)
											local actualitem = getItem(shopitem.itemType == 'wool_white' and getWool() or shopitem.itemType, inv.items)
											if currency and currency.amount >= shopitem.price and (actualitem == nil or actualitem.amount < tonumber(autobuyitem[2])) then 
												buyItem(shopitem, tonumber(autobuyitem[2]) > 1)
											end
										end
									end
								end
								for i,v in next, (buyfunctions) do v(inv, currentupgrades, npctype and 'upgrade' or 'item') end
								for i,v in next, (AutoBuyCustom.ObjectList) do 
									local autobuyitem = v:split('/')
									if #autobuyitem >= 3 and autobuyitem[4] == 'true' then 
										local shopitem = getShopItem(autobuyitem[1])
										if shopitem then 
											local currency = getItem(shopitem.currency, inv.items)
											local actualitem = getItem(shopitem.itemType == 'wool_white' and getWool() or shopitem.itemType, inv.items)
											if currency and currency.amount >= shopitem.price and (actualitem == nil or actualitem.amount < tonumber(autobuyitem[2])) then 
												buyItem(shopitem, tonumber(autobuyitem[2]) > 1)
											end
										end
									end
								end
							end
						end
					until (not AutoBuy.Enabled)
				end)
			end
		end,
		HoverText = 'Automatically Buys Swords, Armor, and Team Upgrades\nwhen you walk near the NPC'
	})
	AutoBuyRange = AutoBuy.CreateSlider({
		Name = 'Range',
		Function = function() end,
		Min = 1,
		Max = 20,
		Default = 20
	})
	AutoBuyArmor = AutoBuy.CreateToggle({
		Name = 'Buy Armor',
		Function = function() end, 
		Default = true
	})
	AutoBuySword = AutoBuy.CreateToggle({
		Name = 'Buy Sword',
		Function = function() end, 
		Default = true
	})
	AutoBuyUpgrades = AutoBuy.CreateToggle({
		Name = 'Buy Team Upgrades',
		Function = function(callback) 
			if AutoBuyUpgrades.Object then AutoBuyUpgrades.Object.ToggleArrow.Visible = callback end
			if AutoBuyGen.Object then AutoBuyGen.Object.Visible = callback end
			if AutoBuyProt.Object then AutoBuyProt.Object.Visible = callback end
			if AutoBuySharp.Object then AutoBuySharp.Object.Visible = callback end
			if AutoBuyDestruction.Object then AutoBuyDestruction.Object.Visible = callback end
			if AutoBuyDiamond.Object then AutoBuyDiamond.Object.Visible = callback end
			if AutoBuyAlarm.Object then AutoBuyAlarm.Object.Visible = callback end
		end, 
		Default = true
	})
	AutoBuyGen = AutoBuy.CreateToggle({
		Name = 'Buy Team Generator',
		Function = function() end, 
	})
	AutoBuyProt = AutoBuy.CreateToggle({
		Name = 'Buy Protection',
		Function = function() end, 
		Default = true
	})
	AutoBuySharp = AutoBuy.CreateToggle({
		Name = 'Buy Sharpness',
		Function = function() end, 
		Default = true
	})
	AutoBuyDestruction = AutoBuy.CreateToggle({
		Name = 'Buy Destruction',
		Function = function() end, 
	})
	AutoBuyDiamond = AutoBuy.CreateToggle({
		Name = 'Buy Diamond Generator',
		Function = function() end, 
	})
	AutoBuyAlarm = AutoBuy.CreateToggle({
		Name = 'Buy Alarm',
		Function = function() end, 
	})
	AutoBuyGui = AutoBuy.CreateToggle({
		Name = 'Shop GUI Check',
		Function = function() end, 	
	})
	AutoBuyTierSkip = AutoBuy.CreateToggle({
		Name = 'Tier Skip',
		Function = function() end, 
		Default = true
	})
	AutoBuyGen.Object.BackgroundTransparency = 0
	AutoBuyGen.Object.BorderSizePixel = 0
	AutoBuyGen.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuyGen.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuyProt.Object.BackgroundTransparency = 0
	AutoBuyProt.Object.BorderSizePixel = 0
	AutoBuyProt.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuyProt.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuySharp.Object.BackgroundTransparency = 0
	AutoBuySharp.Object.BorderSizePixel = 0
	AutoBuySharp.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuySharp.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuyDestruction.Object.BackgroundTransparency = 0
	AutoBuyDestruction.Object.BorderSizePixel = 0
	AutoBuyDestruction.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuyDestruction.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuyDiamond.Object.BackgroundTransparency = 0
	AutoBuyDiamond.Object.BorderSizePixel = 0
	AutoBuyDiamond.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuyDiamond.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuyAlarm.Object.BackgroundTransparency = 0
	AutoBuyAlarm.Object.BorderSizePixel = 0
	AutoBuyAlarm.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuyAlarm.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuyCustom = AutoBuy.CreateTextList({
		Name = 'BuyList',
		TempText = 'item/amount/priority/after',
		SortFunction = function(a, b)
			local amount1 = a:split('/')
			local amount2 = b:split('/')
			amount1 = #amount1 and tonumber(amount1[3]) or 1
			amount2 = #amount2 and tonumber(amount2[3]) or 1
			return amount1 < amount2
		end
	})
	AutoBuyCustom.Object.AddBoxBKG.AddBox.TextSize = 14

	local AutoBank = {Enabled = false}
	local AutoBankRange = {Value = 20}
	local AutoBankApple = {Enabled = false}
	local AutoBankBalloon = {Enabled = false}
	local AutoBankTransmitted, AutoBankTransmittedType = false, false
	local autobankoldapple
	local autobankoldballoon
	local autobankui

	local function refreshbank()
		if autobankui then
			local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name..'_personal')
			for i,v in next, (autobankui:GetChildren()) do 
				if echest:FindFirstChild(v.Name) then 
					v.Amount.Text = echest[v.Name]:GetAttribute('Amount')
				else
					v.Amount.Text = ''
				end
			end
		end
	end

	AutoBank = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoBank',
		Function = function(callback)
			if callback then
				autobankui = Instance.new('Frame')
				autobankui.Size = UDim2.new(0, 240, 0, 40)
				autobankui.AnchorPoint = Vector2.new(0.5, 0)
				autobankui.Position = UDim2.new(0.5, 0, 0, -240)
				autobankui.Visible = AutoBankUIToggle.Enabled
				task.spawn(function()
					repeat
						task.wait()
						if autobankui then 
							local hotbar = lplr.PlayerGui:FindFirstChild('hotbar')
							if hotbar then 
								local healthbar = hotbar['1']:FindFirstChild('HotbarHealthbarContainer')
								if healthbar then 
									autobankui.Position = UDim2.new(0.5, 0, 0, healthbar.AbsolutePosition.Y - 50)
								end
							end
						else
							break
						end
					until (not AutoBank.Enabled)
				end)
				autobankui.BackgroundTransparency = 1
				autobankui.Parent = GuiLibrary.MainGui
				local emerald = Instance.new('ImageLabel')
				emerald.Image = bedwars.getIcon({itemType = 'emerald'}, true)
				emerald.Size = UDim2.new(0, 40, 0, 40)
				emerald.Name = 'emerald'
				emerald.Position = UDim2.new(0, 120, 0, 0)
				emerald.BackgroundTransparency = 1
				emerald.Parent = autobankui
				local emeraldtext = Instance.new('TextLabel')
				emeraldtext.TextSize = 20
				emeraldtext.BackgroundTransparency = 1
				emeraldtext.Size = UDim2.new(1, 0, 1, 0)
				emeraldtext.Font = Enum.Font.SourceSans
				emeraldtext.TextStrokeTransparency = 0.3
				emeraldtext.Name = 'Amount'
				emeraldtext.Text = ''
				emeraldtext.TextColor3 = Color3.new(1, 1, 1)
				emeraldtext.Parent = emerald
				local diamond = emerald:Clone()
				diamond.Image = bedwars.getIcon({itemType = 'diamond'}, true)
				diamond.Position = UDim2.new(0, 80, 0, 0)
				diamond.Name = 'diamond'
				diamond.Parent = autobankui
				local gold = emerald:Clone()
				gold.Image = bedwars.getIcon({itemType = 'gold'}, true)
				gold.Position = UDim2.new(0, 40, 0, 0)
				gold.Name = 'gold'
				gold.Parent = autobankui
				local iron = emerald:Clone()
				iron.Image = bedwars.getIcon({itemType = 'iron'}, true)
				iron.Position = UDim2.new(0, 0, 0, 0)
				iron.Name = 'iron'
				iron.Parent = autobankui
				local apple = emerald:Clone()
				apple.Image = bedwars.getIcon({itemType = 'apple'}, true)
				apple.Position = UDim2.new(0, 160, 0, 0)
				apple.Name = 'apple'
				apple.Parent = autobankui
				local balloon = emerald:Clone()
				balloon.Image = bedwars.getIcon({itemType = 'balloon'}, true)
				balloon.Position = UDim2.new(0, 200, 0, 0)
				balloon.Name = 'balloon'
				balloon.Parent = autobankui
				local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name..'_personal')
				if entityLibrary.isAlive and echest then
					task.spawn(function()
						local chestitems = bedwarsStore.localInventory.inventory.items
						for i3,v3 in next, (chestitems) do
							if (v3.itemType == 'emerald' or v3.itemType == 'iron' or v3.itemType == 'diamond' or v3.itemType == 'gold' or (v3.itemType == 'apple' and AutoBankApple.Enabled) or (v3.itemType == 'balloon' and AutoBankBalloon.Enabled)) then
								bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGiveItem'):CallServer(echest, v3.tool)
								refreshbank()
							end
						end
					end)
				else
					task.spawn(function()
						refreshbank()
					end)
				end
				table.insert(AutoBank.Connections, replicatedStorageService.Inventories.DescendantAdded:Connect(function(p3)
					if p3.Parent.Name == lplr.Name then
						if echest == nil then 
							echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name..'_personal')
						end	
						if not echest then return end
						if p3.Name == 'apple' and AutoBankApple.Enabled then 
							if autobankapple then return end
						elseif p3.Name == 'balloon' and AutoBankBalloon.Enabled then 
							if autobankballoon then vapeEvents.AutoBankBalloon:Fire() return end
						elseif (p3.Name == 'emerald' or p3.Name == 'iron' or p3.Name == 'diamond' or p3.Name == 'gold') then
							if not ((not AutoBankTransmitted) or (AutoBankTransmittedType and p3.Name ~= 'diamond')) then return end
						else
							return
						end
						bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGiveItem'):CallServer(echest, p3)
						refreshbank()
					end
				end))
				task.spawn(function()
					repeat
						task.wait()
						local found, npctype = nearNPC(AutoBankRange.Value)
						if echest == nil then 
							echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name..'_personal')
						end
						if autobankballoon then 
							local chestitems = echest and echest:GetChildren() or {}
							if #chestitems > 0 then
								for i3,v3 in next, (chestitems) do
									if v3:IsA('Accessory') and v3.Name == 'balloon' then
										if (not getItem('balloon')) then
											task.spawn(function()
												bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGetItem'):CallServer(echest, v3)
												refreshbank()
											end)
										end
									end
								end
							end
						end
						if autobankballoon ~= autobankoldballoon and AutoBankBalloon.Enabled then 
							if entityLibrary.isAlive then
								if not autobankballoon then
									local chestitems = bedwarsStore.localInventory.inventory.items
									if #chestitems > 0 then
										for i3,v3 in next, (chestitems) do
											if v3 and v3.itemType == 'balloon' then
												task.spawn(function()
													bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGiveItem'):CallServer(echest, v3.tool)
													refreshbank()
												end)
											end
										end
									end
								end
							end
							autobankoldballoon = autobankballoon
						end
						if autobankapple then 
							local chestitems = echest and echest:GetChildren() or {}
							if #chestitems > 0 then
								for i3,v3 in next, (chestitems) do
									if v3:IsA('Accessory') and v3.Name == 'apple' then
										if (not getItem('apple')) then
											task.spawn(function()
												bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGetItem'):CallServer(echest, v3)
												refreshbank()
											end)
										end
									end
								end
							end
						end
						if (autobankapple ~= autobankoldapple) and AutoBankApple.Enabled then 
							if entityLibrary.isAlive then
								if not autobankapple then
									local chestitems = bedwarsStore.localInventory.inventory.items
									if #chestitems > 0 then
										for i3,v3 in next, (chestitems) do
											if v3 and v3.itemType == 'apple' then
												task.spawn(function()
													bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGiveItem'):CallServer(echest, v3.tool)
													refreshbank()
												end)
											end
										end
									end
								end
							end
							autobankoldapple = autobankapple
						end
						if found ~= AutoBankTransmitted or npctype ~= AutoBankTransmittedType then
							AutoBankTransmitted, AutoBankTransmittedType = found, npctype
							if entityLibrary.isAlive then
								local chestitems = bedwarsStore.localInventory.inventory.items
								if #chestitems > 0 then
									for i3,v3 in next, (chestitems) do
										if v3 and (v3.itemType == 'emerald' or v3.itemType == 'iron' or v3.itemType == 'diamond' or v3.itemType == 'gold') then
											if (not AutoBankTransmitted) or (AutoBankTransmittedType and v3.Name ~= 'diamond') then 
												task.spawn(function()
													pcall(function()
														bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGiveItem'):CallServer(echest, v3.tool)
													end)
													refreshbank()
												end)
											end
										end
									end
								end
							end
						end
						if found then 
							local chestitems = echest and echest:GetChildren() or {}
							if #chestitems > 0 then
								for i3,v3 in next, (chestitems) do
									if v3:IsA('Accessory') and ((npctype == false and (v3.Name == 'emerald' or v3.Name == 'iron' or v3.Name == 'gold')) or v3.Name == 'diamond') then
										task.spawn(function()
											pcall(function()
												bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGetItem'):CallServer(echest, v3)
											end)
											refreshbank()
										end)
									end
								end
							end
						end
					until (not AutoBank.Enabled)
				end)
			else
				if autobankui then
					autobankui:Destroy()
					autobankui = nil
				end
				local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name..'_personal')
				local chestitems = echest and echest:GetChildren() or {}
				if #chestitems > 0 then
					for i3,v3 in next, (chestitems) do
						if v3:IsA('Accessory') and (v3.Name == 'emerald' or v3.Name == 'iron' or v3.Name == 'diamond' or v3.Name == 'apple' or v3.Name == 'balloon') then
							task.spawn(function()
								pcall(function()
									bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGetItem'):CallServer(echest, v3)
								end)
								refreshbank()
							end)
						end
					end
				end
			end
		end
	})
	AutoBankUIToggle = AutoBank.CreateToggle({
		Name = 'UI',
		Function = function(callback)
			if autobankui then autobankui.Visible = callback end
		end,
		Default = true
	})
	AutoBankApple = AutoBank.CreateToggle({
		Name = 'Apple',
		Function = function(callback) 
			if not callback then 
				local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name..'_personal')
				local chestitems = echest and echest:GetChildren() or {}
				for i3,v3 in next, (chestitems) do
					if v3:IsA('Accessory') and v3.Name == 'apple' then
						task.spawn(function()
							bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGetItem'):CallServer(echest, v3)
							refreshbank()
						end)
					end
				end
			end
		end,
		Default = true
	})
	AutoBankBalloon = AutoBank.CreateToggle({
		Name = 'Balloon',
		Function = function(callback) 
			if not callback then 
				local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name..'_personal')
				local chestitems = echest and echest:GetChildren() or {}
				for i3,v3 in next, (chestitems) do
					if v3:IsA('Accessory') and v3.Name == 'balloon' then
						task.spawn(function()
							bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGetItem'):CallServer(echest, v3)
							refreshbank()
						end)
					end
				end
			end
		end,
		Default = true
	})
	AutoBankDeath = AutoBank.CreateToggle({
		Name = 'Damage',
		Function = function() end,
		HoverText = 'puts away resources when you take damage to prevent losing on death'
	})
	AutoBankStay = AutoBank.CreateToggle({
		Name = 'Stay',
		Function = function() end,
		HoverText = 'keeps resources until toggled off'
	})
	AutoBankRange = AutoBank.CreateSlider({
		Name = 'Range',
		Function = function() end,
		Min = 1,
		Max = 20,
		Default = 20
	})
end)

runFunction(function()
	local AutoConsume = {Enabled = false}
	local AutoConsumeHealth = {Value = 100}
	local AutoConsumeSpeed = {Enabled = true}
	local AutoConsumeDelay = tick()

	local function AutoConsumeFunc()
		if entityLibrary.isAlive then
			local speedpotion = getItem('speed_potion')
			if lplr.Character:GetAttribute('Health') <= (lplr.Character:GetAttribute('MaxHealth') - (100 - AutoConsumeHealth.Value)) then
				autobankapple = true
				local item = getItem('apple')
				local pot = getItem('heal_splash_potion')
				if (item or pot) and AutoConsumeDelay <= tick() then
					if item then
						bedwars.ClientHandler:Get(bedwars.EatRemote):CallServerAsync({
							item = item.tool
						})
						AutoConsumeDelay = tick() + 0.6
					else
						local newray = workspace:Raycast((oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, Vector3.new(0, -76, 0), bedwarsStore.blockRaycast)
						if newray ~= nil then
							bedwars.ClientHandler:Get(bedwars.ProjectileRemote):CallServerAsync(pot.tool, 'heal_splash_potion', 'heal_splash_potion', (oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, (oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, Vector3.new(0, -70, 0), game:GetService('HttpService'):GenerateGUID(), {drawDurationSeconds = 1})
						end
					end
				end
			else
				autobankapple = false
			end
			if speedpotion and (not lplr.Character:GetAttribute('StatusEffect_speed')) and AutoConsumeSpeed.Enabled then 
				bedwars.ClientHandler:Get(bedwars.EatRemote):CallServerAsync({
					item = speedpotion.tool
				})
			end
			if lplr.Character:GetAttribute('Shield_POTION') and ((not lplr.Character:GetAttribute('Shield_POTION')) or lplr.Character:GetAttribute('Shield_POTION') == 0) then
				local shield = getItem('big_shield') or getItem('mini_shield')
				if shield then
					bedwars.ClientHandler:Get(bedwars.EatRemote):CallServerAsync({
						item = shield.tool
					})
				end
			end
		end
	end

	AutoConsume = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoConsume',
		Function = function(callback)
			if callback then
				table.insert(AutoConsume.Connections, vapeEvents.InventoryAmountChanged.Event:Connect(AutoConsumeFunc))
				table.insert(AutoConsume.Connections, vapeEvents.AttributeChanged.Event:Connect(function(changed)
					if changed:find('Shield') or changed:find('Health') or changed:find('speed') then 
						AutoConsumeFunc()
					end
				end))
				AutoConsumeFunc()
			end
		end,
		HoverText = 'Automatically heals for you when health or shield is under threshold.'
	})
	AutoConsumeHealth = AutoConsume.CreateSlider({
		Name = 'Health',
		Min = 1,
		Max = 99,
		Default = 70,
		Function = function() end
	})
	AutoConsumeSpeed = AutoConsume.CreateToggle({
		Name = 'Speed Potions',
		Function = function() end,
		Default = true
	})
end)

runFunction(function()
	local AutoHotbarList = {Hotbars = {}, CurrentlySelected = 1}
	local AutoHotbarMode = {Value = 'Toggle'}
	local AutoHotbarClear = {Enabled = false}
	local AutoHotbar = {Enabled = false}
	local AutoHotbarActive = false

	local function getCustomItem(v2)
		local realitem = v2.itemType
		if realitem == 'swords' then
			local sword = getSword()
			realitem = sword and sword.itemType or 'wood_sword'
		elseif realitem == 'pickaxes' then
			local pickaxe = getPickaxe()
			realitem = pickaxe and pickaxe.itemType or 'wood_pickaxe'
		elseif realitem == 'axes' then
			local axe = getAxe()
			realitem = axe and axe.itemType or 'wood_axe'
		elseif realitem == 'bows' then
			local bow = getBow()
			realitem = bow and bow.itemType or 'wood_bow'
		elseif realitem == 'wool' then
			realitem = getWool() or 'wool_white'
		end
		return realitem
	end
	
	local function findItemInTable(tab, item)
		for i, v in next, (tab) do
			if v and v.itemType then
				if item.itemType == getCustomItem(v) then
					return i
				end
			end
		end
		return nil
	end

	local function findinhotbar(item)
		for i,v in next, (bedwarsStore.localInventory.hotbar) do
			if v.item and v.item.itemType == item.itemType then
				return i, v.item
			end
		end
	end

	local function findininventory(item)
		for i,v in next, (bedwarsStore.localInventory.inventory.items) do
			if v.itemType == item.itemType then
				return v
			end
		end
	end

	local function AutoHotbarSort()
		task.spawn(function()
			if AutoHotbarActive then return end
			AutoHotbarActive = true
			local items = (AutoHotbarList.Hotbars[AutoHotbarList.CurrentlySelected] and AutoHotbarList.Hotbars[AutoHotbarList.CurrentlySelected].Items or {})
			for i, v in next, (bedwarsStore.localInventory.inventory.items) do 
				local customItem
				local hotbarslot = findItemInTable(items, v)
				if hotbarslot then
					local oldhotbaritem = bedwarsStore.localInventory.hotbar[tonumber(hotbarslot)]
					if oldhotbaritem.item and oldhotbaritem.item.itemType == v.itemType then continue end
					if oldhotbaritem.item then 
						bedwars.ClientStoreHandler:dispatch({
							type = 'InventoryRemoveFromHotbar', 
							slot = tonumber(hotbarslot) - 1
						})
						vapeEvents.InventoryChanged.Event:Wait()
					end
					local newhotbaritemslot, newhotbaritem = findinhotbar(v)
					if newhotbaritemslot then
						bedwars.ClientStoreHandler:dispatch({
							type = 'InventoryRemoveFromHotbar', 
							slot = newhotbaritemslot - 1
						})
						vapeEvents.InventoryChanged.Event:Wait()
					end
					if oldhotbaritem.item and newhotbaritemslot then 
						local nextitem1, nextitem1num = findininventory(oldhotbaritem.item)
						bedwars.ClientStoreHandler:dispatch({
							type = 'InventoryAddToHotbar', 
							item = nextitem1, 
							slot = newhotbaritemslot - 1
						})
						vapeEvents.InventoryChanged.Event:Wait()
					end
					local nextitem2, nextitem2num = findininventory(v)
					bedwars.ClientStoreHandler:dispatch({
						type = 'InventoryAddToHotbar', 
						item = nextitem2, 
						slot = tonumber(hotbarslot) - 1
					})
					vapeEvents.InventoryChanged.Event:Wait()
				else
					if AutoHotbarClear.Enabled then 
						local newhotbaritemslot, newhotbaritem = findinhotbar(v)
						if newhotbaritemslot then
							bedwars.ClientStoreHandler:dispatch({
								type = 'InventoryRemoveFromHotbar', 
								slot = newhotbaritemslot - 1
							})
							vapeEvents.InventoryChanged.Event:Wait()
						end
					end
				end
			end
			AutoHotbarActive = false
		end)
	end

	AutoHotbar = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoHotbar',
		Function = function(callback) 
			if callback then
				AutoHotbarSort()
				if AutoHotbarMode.Value == 'On Key' then
					if AutoHotbar.Enabled then 
						AutoHotbar.ToggleButton(false)
					end
				else
					table.insert(AutoHotbar.Connections, vapeEvents.InventoryAmountChanged.Event:Connect(function()
						if not AutoHotbar.Enabled then return end
						AutoHotbarSort()
					end))
				end
			end
		end,
		HoverText = 'Automatically arranges hotbar to your liking.'
	})
	AutoHotbarMode = AutoHotbar.CreateDropdown({
		Name = 'Activation',
		List = {'On Key', 'Toggle'},
		Function = function(val)
			if AutoHotbar.Enabled then
				AutoHotbar.ToggleButton(false)
				AutoHotbar.ToggleButton(false)
			end
		end
	})
	AutoHotbarList = CreateAutoHotbarGUI(AutoHotbar.Children, {
		Name = 'lol'
	})
	AutoHotbarClear = AutoHotbar.CreateToggle({
		Name = 'Clear Hotbar',
		Function = function() end
	})
end)

runFunction(function()
	local AutoKit = {Enabled = false}
	local AutoKitTrinity = {Value = 'Void'}
	local oldfish
	local function GetTeammateThatNeedsMost()
		local plrs = AllNearPosition(1000, 30)
		local lowest, lowestplayer = 10000, nil
		for i,v in next, (plrs) do
			if not v.Targetable then
				if v.Character:GetAttribute('Health') <= lowest and v.Character:GetAttribute('Health') < v.Character:GetAttribute('MaxHealth') then
					lowest = v.Character:GetAttribute('Health')
					lowestplayer = v
				end
			end
		end
		return lowestplayer
	end
	local oldPullOutSword

	AutoKit = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoKit',
		Function = function(callback)
			if callback then
				oldfish = bedwars.FishermanTable.startMinigame
				bedwars.FishermanTable.startMinigame = function(Self, dropdata, func) func({win = true}) end
				task.spawn(function()
					repeat task.wait() until bedwarsStore.equippedKit ~= ''
					if AutoKit.Enabled then
						if bedwarsStore.equippedKit == 'melody' then
							task.spawn(function()
								repeat
									task.wait(0.1)
									if getItem('guitar') then
										local plr = GetTeammateThatNeedsMost()
										if plr and healtick <= tick() then
											bedwars.ClientHandler:Get(bedwars.GuitarHealRemote):SendToServer({
												healTarget = plr.Character
											})
											healtick = tick() + 2
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == 'bigman' then
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = collectionService:GetTagged('treeOrb')
									for i,v in next, (itemdrops) do
										if entityLibrary.isAlive and v:FindFirstChild('Spirit') and (entityLibrary.character.HumanoidRootPart.Position - v.Spirit.Position).magnitude <= 20 then
											if bedwars.ClientHandler:Get(bedwars.TreeRemote):CallServer({
												treeOrbSecret = v:GetAttribute('TreeOrbSecret')
											}) then
												v:Destroy()
												collectionService:RemoveTag(v, 'treeOrb')
											end
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == 'metal_detector' then
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = collectionService:GetTagged('hidden-metal')
									for i,v in next, (itemdrops) do
										if entityLibrary.isAlive and v.PrimaryPart and (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude <= 20 then
											bedwars.ClientHandler:Get(bedwars.PickupMetalRemote):SendToServer({
												id = v:GetAttribute('Id')
											}) 
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == 'battery' then 
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = bedwars.BatteryEffectController.liveBatteries
									for i,v in next, (itemdrops) do
										if entityLibrary.isAlive and (entityLibrary.character.HumanoidRootPart.Position - v.position).magnitude <= 10 then
											bedwars.ClientHandler:Get(bedwars.BatteryRemote):SendToServer({
												batteryId = i
											})
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == 'grim_reaper' then
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = bedwars.GrimReaperController.soulsByPosition
									for i,v in next, (itemdrops) do
										if entityLibrary.isAlive and lplr.Character:GetAttribute('Health') <= (lplr.Character:GetAttribute('MaxHealth') / 4) and v.PrimaryPart and (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude <= 120 and (not lplr.Character:GetAttribute('GrimReaperChannel')) then
											bedwars.ClientHandler:Get(bedwars.ConsumeSoulRemote):CallServer({
												secret = v:GetAttribute('GrimReaperSoulSecret')
											})
											v:Destroy()
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == 'farmer_cletus' then 
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = collectionService:GetTagged('BedwarsHarvestableCrop')
									for i,v in next, (itemdrops) do
										if entityLibrary.isAlive and (entityLibrary.character.HumanoidRootPart.Position - v.Position).magnitude <= 10 then
											bedwars.ClientHandler:Get('BedwarsHarvestCrop'):CallServerAsync({
												position = bedwars.BlockController:getBlockPosition(v.Position)
											}):andThen(function(suc)
												if suc then
													bedwars.GameAnimationUtil.playAnimation(lplr.Character, 1)
													bedwars.SoundManager:playSound(bedwars.SoundList.CROP_HARVEST)
												end
											end)
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == 'dragon_slayer' then
							task.spawn(function()
								repeat
									task.wait(0.1)
									if entityLibrary.isAlive then
										for i,v in next, (bedwars.DragonSlayerController.dragonEmblems) do 
											if v.stackCount >= 3 then 
												bedwars.DragonSlayerController:deleteEmblem(i)
												local localPos = lplr.Character:GetPrimaryPartCFrame().Position
												local punchCFrame = CFrame.new(localPos, (i:GetPrimaryPartCFrame().Position * Vector3.new(1, 0, 1)) + Vector3.new(0, localPos.Y, 0))
												lplr.Character:SetPrimaryPartCFrame(punchCFrame)
												bedwars.DragonSlayerController:playPunchAnimation(punchCFrame - punchCFrame.Position)
												bedwars.ClientHandler:Get(bedwars.DragonRemote):SendToServer({
													target = i
												})
											end
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == 'mage' then
							task.spawn(function()
								repeat
									task.wait(0.1)
									if entityLibrary.isAlive then
										for i, v in next, (collectionService:GetTagged('TomeGuidingBeam')) do 
											local obj = v.Parent and v.Parent.Parent and v.Parent.Parent.Parent
											if obj and (entityLibrary.character.HumanoidRootPart.Position - obj.PrimaryPart.Position).Magnitude < 5 and obj:GetAttribute('TomeSecret') then
												local res = bedwars.ClientHandler:Get(bedwars.MageRemote):CallServer({
													secret = obj:GetAttribute('TomeSecret')
												})
												if res.success and res.element then 
													bedwars.GameAnimationUtil.playAnimation(lplr, bedwars.AnimationType.PUNCH)
													bedwars.ViewmodelController:playAnimation(bedwars.AnimationType.FP_USE_ITEM)
													bedwars.MageController:destroyTomeGuidingBeam()
													bedwars.MageController:playLearnLightBeamEffect(lplr, obj)
													local sound = bedwars.MageKitUtil.MageElementVisualizations[res.element].learnSound
													if sound and sound ~= '' then 
														bedwars.SoundManager:playSound(sound)
													end
													task.delay(bedwars.BalanceFile.LEARN_TOME_DURATION, function()
														bedwars.MageController:fadeOutTome(obj)
														if lplr.Character and res.element then
															bedwars.MageKitUtil.changeMageKitAppearance(lplr, lplr.Character, res.element)	
														end
													end)
												end
											end
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == 'angel' then 
							table.insert(AutoKit.Connections, vapeEvents.AngelProgress.Event:Connect(function(angelTable)
								task.wait(0.5)
								if not AutoKit.Enabled then return end
								if bedwars.ClientStoreHandler:getState().Kit.angelProgress >= 1 and lplr.Character:GetAttribute('AngelType') == nil then
									bedwars.ClientHandler:Get(bedwars.TrinityRemote):SendToServer({
										angel = AutoKitTrinity.Value
									})
								end
							end))
						elseif bedwarsStore.equippedKit == 'miner' then
							task.spawn(function()
								repeat
									task.wait(0.1)
									if entityLibrary.isAlive then
										for i,v in next, (collectionService:GetTagged('petrified-player')) do 
											bedwars.ClientHandler:Get(bedwars.MinerRemote):SendToServer({
												petrifyId = v:GetAttribute('PetrifyId')
											})
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == 'hannah' then
							task.spawn(function()
								oldPullOutSword = bedwars.HannahController.pullOutSword
								bedwars.HannahController.pullOutSword = function() end
								repeat
									task.wait(0.1)
									if entityLibrary.isAlive then
										for i, v in next, (collectionService:GetTagged('HannahExecuteInteraction')) do
											if v.PrimaryPart and (v.PrimaryPart.Position - entityLibrary.character.HumanoidRootPart.Position).Magnitude <= AutoKitExecuteRange.Value then
												if bedwars.ClientHandler:Get('HannahPromptTrigger'):CallServer({ user = lplr, victimEntity = v }) then
													task.spawn(function()
														local icon = v:FindFirstChild('Hannah Execution Icon', true)
														for i = 1, 100 do
															if icon then
																icon:Destroy()
															end
															icon = v:FindFirstChild('Hannah Execution Icon', true)
															task.wait(0.1)
														end
														v:Destroy()
														collectionService:RemoveTag(v, 'HannahExecuteInteraction')
													end)
												end
											end
										end
									end
								until (not AutoKit.Enabled)
							end)
						end
					end
				end)
			else
				if oldfish then
					bedwars.FishermanTable.startMinigame = oldfish
					oldfish = nil
				end
				if oldPullOutSword then
					bedwars.HannahController.pullOutSword = oldPullOutSword
					oldPullOutSword = nil
				end
			end
		end,
		HoverText = 'Automatically uses a kits ability'
	})
	AutoKitTrinity = AutoKit.CreateDropdown({
		Name = 'Angel',
		List = {'Void', 'Light'},
		Function = function() end
	})
	AutoKitExecuteRange = AutoKit.CreateSlider({
		Name = 'Execute Range',
		Min = 0,
		Max = 1000,
		Function = function() end
	})
end)

--[==[
	runFunction(function()
		local AutoRelicCustom = {ObjectList = {}}

		local function findgoodmeta(relics)
			local tab = #AutoRelicCustom.ObjectList > 0 and AutoRelicCustom.ObjectList or {
				'embers_anguish',
				'knights_code',
				'quick_forge',
				'glass_cannon'
			}
			for i,v in next, (relics) do 
				for i2,v2 in next, (tab) do 
					if v.relic == v2 then
						return v.relic
					end
				end
			end
			return relics[1].relic
		end

		local AutoRelic = {Enabled = false}
		AutoRelic = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
			Name = 'AutoRelic',
			Function = function(callback)
				if callback then 
					task.spawn(function()
						repeat
							task.wait()
							if bedwars.AppController:isAppOpen('RelicVotingInterface') then 
								bedwars.AppController:closeApp('RelicVotingInterface')
								local relictable = bedwars.ClientStoreHandler:getState().Bedwars.relic.voteState
								if relictable then 
									bedwars.RelicController:voteForRelic(findgoodmeta(relictable))
								end
								break
							end
							if matchState ~= 0 then break end
						until (not AutoRelic.Enabled)
					end)
				end
			end
		})
		AutoRelicCustom = AutoRelic.CreateTextList({
			Name = 'Custom',
			TempText = 'custom (relic id)'
		})
	end)

	runFunction(function()
		local AutoForge = {Enabled = false}
		local AutoForgeWeapon = {Value = 'Sword'}
		local AutoForgeBow = {Enabled = false}
		local AutoForgeArmor = {Enabled = false}
		local AutoForgeSword = {Enabled = false}
		local AutoForgeBuyAfter = {Enabled = false}
		local AutoForgeSingleScythe = {Enabled = true}
		local AutoForgeNotification = {Enabled = true}

		local function buyForge(i)
			if not bedwarsStore.forgeUpgrades[i] or bedwarsStore.forgeUpgrades[i] < 6 then
				local cost = bedwars.ForgeUtil:getUpgradeCost(1, bedwarsStore.forgeUpgrades[i] or 0)
				if bedwarsStore.forgeMasteryPoints >= cost then 
					if AutoForgeNotification.Enabled then
						local forgeType = 'none'
						for name,v in next, (bedwars.ForgeConstants) do
							if v == i then forgeType = name:lower() end
						end
						warningNotification('AutoForge', 'Purchasing '..forgeType..'.', bedwars.ForgeUtil.FORGE_DURATION_SEC)
					end
					bedwars.ClientHandler:Get('ForgePurchaseUpgrade'):SendToServer(i)
					task.wait(bedwars.ForgeUtil.FORGE_DURATION_SEC + 0.2)
				end
			end
		end

		AutoForge = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
			Name = 'AutoForge',
			Function = function(callback)
				if callback then 
					task.spawn(function()
						repeat
							task.wait()
							if bedwarsStore.matchState == 1 and entityLibrary.isAlive then
								if bedwarsStore.forgeMasteryPoints <= 0 then
									continue
								end 
								if AutoForgeSingleScythe.Enabled then
									if not bedwarsStore.hasScythe then
										local weapon = bedwars.ForgeConstants[AutoForgeWeapon.Value:upper()]
										if weapon then
											buyForge(weapon)
											continue
										end
									end
								end
								if entityLibrary.character.HumanoidRootPart.Velocity.Magnitude > 0.01 then continue end
								if AutoForgeArmor.Enabled then buyForge(bedwars.ForgeConstants.ARMOR) end
								if entityLibrary.character.HumanoidRootPart.Velocity.Magnitude > 0.01 then continue end
								if AutoForgeBow.Enabled then buyForge(bedwars.ForgeConstants.RANGED) end
								if entityLibrary.character.HumanoidRootPart.Velocity.Magnitude > 0.01 then continue end
								if AutoForgeSword.Enabled then
									if AutoForgeArmor.Enabled and AutoForgeBuyAfter.Enabled then
										if not bedwarsStore.forgeUpgrades[bedwars.ForgeConstants.ARMOR] or bedwarsStore.forgeUpgrades[bedwars.ForgeConstants.ARMOR] < 6 then continue end
									end
									local weapon = bedwars.ForgeConstants[AutoForgeWeapon.Value:upper()]
									if weapon then buyForge(weapon) end
								end
							end
						until (not AutoForge.Enabled)
					end)
				end
			end
		})
		AutoForgeWeapon = AutoForge.CreateDropdown({
			Name = 'Weapon',
			Function = function() end,
			List = {'Sword', 'Dagger', 'Scythe', 'Great_Hammer'}
		})
		AutoForgeArmor = AutoForge.CreateToggle({
			Name = 'Armor',
			Function = function() end,
			Default = true
		})
		AutoForgeSword = AutoForge.CreateToggle({
			Name = 'Weapon',
			Function = function() end
		})
		AutoForgeBow = AutoForge.CreateToggle({
			Name = 'Bow',
			Function = function() end
		})
		AutoForgeSingleScythe = AutoForge.CreateToggle({
			Name = 'Single Scythe',
			Function = function() end,
			HoverText = 'buy a weapon once before armor is maxed'
		})
		AutoForgeBuyAfter = AutoForge.CreateToggle({
			Name = 'Buy After',
			Function = function() end,
			HoverText = 'buy a weapon after armor is maxed'
		})
		AutoForgeNotification = AutoForge.CreateToggle({
			Name = 'Notification',
			Function = function() end,
			Default = true
		})
	end)
--]==]

runFunction(function()
	local alreadyreportedlist = {}
	local AutoReportV2 = {Enabled = false}
	local AutoReportV2Notify = {Enabled = false}
	AutoReportV2 = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoReportV2',
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat
						task.wait(bedwarsStore.matchState ~= 0 and 1 or 0)
						for i,v in next, (playersService:GetPlayers()) do 
							if v ~= lplr and alreadyreportedlist[v] == nil and v:GetAttribute('PlayerConnected') and WhitelistFunctions:GetWhitelist(v) == 0 then 
								task.wait(1)
								alreadyreportedlist[v] = true
								bedwars.ClientHandler:Get(bedwars.ReportRemote):SendToServer(v.UserId)
								bedwarsStore.statistics.reported = bedwarsStore.statistics.reported + 1
								if AutoReportV2Notify.Enabled then 
									warningNotification('AutoReportV2', 'Reported '..v.Name, 15)
								end
							end
						end
					until (not AutoReportV2.Enabled)
				end)
			end	
		end,
		HoverText = 'dv mald'
	})
	AutoReportV2Notify = AutoReportV2.CreateToggle({
		Name = 'Notify',
		Function = function() end
	})
end)

runFunction(function()
	local justsaid = ''
	local leavesaid = false
	local alreadyreported = {}

	local function removerepeat(str)
		local newstr = ''
		local lastlet = ''
		for i,v in next, (str:split('')) do 
			if v ~= lastlet then
				newstr = newstr..v 
				lastlet = v
			end
		end
		return newstr
	end

	local reporttable = {
		gay = 'Bullying',
		gae = 'Bullying',
		gey = 'Bullying',
		hack = 'Scamming',
		exploit = 'Scamming',
		cheat = 'Scamming',
		hecker = 'Scamming',
		haxker = 'Scamming',
		hacer = 'Scamming',
		report = 'Bullying',
		fat = 'Bullying',
		black = 'Bullying',
		getalife = 'Bullying',
		fatherless = 'Bullying',
		report = 'Bullying',
		fatherless = 'Bullying',
		disco = 'Offsite Links',
		yt = 'Offsite Links',
		dizcourde = 'Offsite Links',
		retard = 'Swearing',
		bad = 'Bullying',
		trash = 'Bullying',
		nolife = 'Bullying',
		nolife = 'Bullying',
		loser = 'Bullying',
		killyour = 'Bullying',
		kys = 'Bullying',
		hacktowin = 'Bullying',
		bozo = 'Bullying',
		kid = 'Bullying',
		adopted = 'Bullying',
		linlife = 'Bullying',
		commitnotalive = 'Bullying',
		vape = 'Offsite Links',
		futureclient = 'Offsite Links',
		download = 'Offsite Links',
		youtube = 'Offsite Links',
		die = 'Bullying',
		lobby = 'Bullying',
		ban = 'Bullying',
		wizard = 'Bullying',
		wisard = 'Bullying',
		witch = 'Bullying',
		magic = 'Bullying',
	}
	local reporttableexact = {
		L = 'Bullying',
	}
	

	local function findreport(msg)
		local checkstr = removerepeat(msg:gsub('%W+', ''):lower())
		for i,v in next, (reporttable) do 
			if checkstr:find(i) then 
				return v, i
			end
		end
		for i,v in next, (reporttableexact) do 
			if checkstr == i then 
				return v, i
			end
		end
		for i,v in next, (AutoToxicPhrases5.ObjectList) do 
			if checkstr:find(v) then 
				return 'Bullying', v
			end
		end
		return nil
	end

	AutoToxic = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'AutoToxic',
		Function = function(callback)
			if callback then 
				table.insert(AutoToxic.Connections, vapeEvents.BedwarsBedBreak.Event:Connect(function(bedTable)
					if AutoToxicBedDestroyed.Enabled and bedTable.brokenBedTeam.id == lplr:GetAttribute('Team') then
						local custommsg = #AutoToxicPhrases6.ObjectList > 0 and AutoToxicPhrases6.ObjectList[math.random(1, #AutoToxicPhrases6.ObjectList)] or 'How dare you break my bed >:( <name> | vxpe on top'
						if custommsg then
							custommsg = custommsg:gsub('<name>', (bedTable.player.DisplayName or bedTable.player.Name))
						end
						textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(custommsg)
					elseif AutoToxicBedBreak.Enabled and bedTable.player.UserId == lplr.UserId then
						local custommsg = #AutoToxicPhrases7.ObjectList > 0 and AutoToxicPhrases7.ObjectList[math.random(1, #AutoToxicPhrases7.ObjectList)] or 'nice bed <teamname> | vxpe on top'
						if custommsg then
							local team = bedwars.QueueMeta[bedwarsStore.queueType].teams[tonumber(bedTable.brokenBedTeam.id)]
							local teamname = team and team.displayName:lower() or 'white'
							custommsg = custommsg:gsub('<teamname>', teamname)
						end
						textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(custommsg)
					end
				end))
				table.insert(AutoToxic.Connections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if deathTable.finalKill then
						local killer = playersService:GetPlayerFromCharacter(deathTable.fromEntity)
						local killed = playersService:GetPlayerFromCharacter(deathTable.entityInstance)
						if not killed or not killer then return end
						if killed == lplr then 
							if (not leavesaid) and killer ~= lplr and AutoToxicDeath.Enabled then
								leavesaid = true
								local custommsg = #AutoToxicPhrases3.ObjectList > 0 and AutoToxicPhrases3.ObjectList[math.random(1, #AutoToxicPhrases3.ObjectList)] or 'My gaming chair expired midfight, thats why you won <name> | vxpe on top'
								if custommsg then
									custommsg = custommsg:gsub('<name>', (killer.DisplayName or killer.Name))
								end
								textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(custommsg)
							end
						else
							if killer == lplr and AutoToxicFinalKill.Enabled then 
								local custommsg = #AutoToxicPhrases2.ObjectList > 0 and AutoToxicPhrases2.ObjectList[math.random(1, #AutoToxicPhrases2.ObjectList)] or 'L <name> | vxpe on top'
								if custommsg == lastsaid then
									custommsg = #AutoToxicPhrases2.ObjectList > 0 and AutoToxicPhrases2.ObjectList[math.random(1, #AutoToxicPhrases2.ObjectList)] or 'L <name> | vxpe on top'
								else
									lastsaid = custommsg
								end
								if custommsg then
									custommsg = custommsg:gsub('<name>', (killed.DisplayName or killed.Name))
								end
								textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(custommsg)
							end
						end
					end
				end))
				table.insert(AutoToxic.Connections, vapeEvents.MatchEndEvent.Event:Connect(function(winstuff)
					local myTeam = bedwars.ClientStoreHandler:getState().Game.myTeam
					if myTeam and myTeam.id == winstuff.winningTeamId or lplr.Neutral then
						if AutoToxicGG.Enabled then
							textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync('gg')
							if shared.ggfunction then
								shared.ggfunction()
							end
						end
						if AutoToxicWin.Enabled then
							textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(#AutoToxicPhrases.ObjectList > 0 and AutoToxicPhrases.ObjectList[math.random(1, #AutoToxicPhrases.ObjectList)] or 'EZ L TRASH KIDS | vxpe on top')
						end
					end
				end))
				table.insert(AutoToxic.Connections, vapeEvents.LagbackEvent.Event:Connect(function(plr)
					if AutoToxicLagback.Enabled then
						local custommsg = #AutoToxicPhrases8.ObjectList > 0 and AutoToxicPhrases8.ObjectList[math.random(1, #AutoToxicPhrases8.ObjectList)]
						if custommsg then
							custommsg = custommsg:gsub('<name>', (plr.DisplayName or plr.Name))
						end
						local msg = custommsg or 'Imagine lagbacking L '..(plr.DisplayName or plr.Name)..' | vxpe on top'
						textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(msg)
					end
				end))
				table.insert(AutoToxic.Connections, textChatService.MessageReceived:Connect(function(tab)
					if AutoToxicRespond.Enabled then
						local plr = playersService:GetPlayerByUserId(tab.TextSource.UserId)
						local args = tab.Text:split(' ')
						if plr and plr ~= lplr and not alreadyreported[plr] then
							local reportreason, reportedmatch = findreport(tab.Text)
							if reportreason then 
								alreadyreported[plr] = true
								local custommsg = #AutoToxicPhrases4.ObjectList > 0 and AutoToxicPhrases4.ObjectList[math.random(1, #AutoToxicPhrases4.ObjectList)]
								if custommsg then
									custommsg = custommsg:gsub('<name>', (plr.DisplayName or plr.Name))
								end
								local msg = custommsg or 'I don\'t care about the fact that I\'m hacking, I care about you dying in a block game. L '..(plr.DisplayName or plr.Name)..' | vxpe on top'
								textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(msg)
							end
						end
					end
				end))
			end
		end
	})
	AutoToxicGG = AutoToxic.CreateToggle({
		Name = 'AutoGG',
		Function = function() end, 
		Default = true
	})
	AutoToxicWin = AutoToxic.CreateToggle({
		Name = 'Win',
		Function = function() end, 
		Default = true
	})
	AutoToxicDeath = AutoToxic.CreateToggle({
		Name = 'Death',
		Function = function() end, 
		Default = true
	})
	AutoToxicBedBreak = AutoToxic.CreateToggle({
		Name = 'Bed Break',
		Function = function() end, 
		Default = true
	})
	AutoToxicBedDestroyed = AutoToxic.CreateToggle({
		Name = 'Bed Destroyed',
		Function = function() end, 
		Default = true
	})
	AutoToxicRespond = AutoToxic.CreateToggle({
		Name = 'Respond',
		Function = function() end, 
		Default = true
	})
	AutoToxicFinalKill = AutoToxic.CreateToggle({
		Name = 'Final Kill',
		Function = function() end, 
		Default = true
	})
	AutoToxicTeam = AutoToxic.CreateToggle({
		Name = 'Teammates',
		Function = function() end, 
	})
	AutoToxicLagback = AutoToxic.CreateToggle({
		Name = 'Lagback',
		Function = function() end, 
		Default = true
	})
	AutoToxicPhrases = AutoToxic.CreateTextList({
		Name = 'ToxicList',
		TempText = 'phrase (win)',
	})
	AutoToxicPhrases2 = AutoToxic.CreateTextList({
		Name = 'ToxicList2',
		TempText = 'phrase (kill) <name>',
	})
	AutoToxicPhrases3 = AutoToxic.CreateTextList({
		Name = 'ToxicList3',
		TempText = 'phrase (death) <name>',
	})
	AutoToxicPhrases7 = AutoToxic.CreateTextList({
		Name = 'ToxicList7',
		TempText = 'phrase (bed break) <teamname>',
	})
	AutoToxicPhrases7.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases6 = AutoToxic.CreateTextList({
		Name = 'ToxicList6',
		TempText = 'phrase (bed destroyed) <name>',
	})
	AutoToxicPhrases6.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases4 = AutoToxic.CreateTextList({
		Name = 'ToxicList4',
		TempText = 'phrase (text to respond with) <name>',
	})
	AutoToxicPhrases4.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases5 = AutoToxic.CreateTextList({
		Name = 'ToxicList5',
		TempText = 'phrase (text to respond to)',
	})
	AutoToxicPhrases5.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases8 = AutoToxic.CreateTextList({
		Name = 'ToxicList8',
		TempText = 'phrase (lagback) <name>',
	})
	AutoToxicPhrases8.Object.AddBoxBKG.AddBox.TextSize = 12
end)

runFunction(function()
	local ChestStealer = {Enabled = false}
	local ChestStealerDistance = {Value = 1}
	local ChestStealerDelay = {Value = 1}
	local ChestStealerOpen = {Enabled = false}
	local ChestStealerSkywars = {Enabled = true}
	local cheststealerdelays = {}
	local cheststealerfuncs = {
		Open = function()
			if bedwars.AppController:isAppOpen('ChestApp') then
				local chest = lplr.Character:FindFirstChild('ObservedChestFolder')
				local chestitems = chest and chest.Value and chest.Value:GetChildren() or {}
				if #chestitems > 1 then
					for i3,v3 in next, (chestitems) do
						if v3:IsA('Accessory') and (cheststealerdelays[v3] == nil or cheststealerdelays[v3] < tick()) then
							task.spawn(function()
								pcall(function()
									cheststealerdelays[v3] = tick() + 0.2
									bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGetItem'):CallServer(chest.Value, v3)
								end)
							end)
							task.wait(ChestStealerDelay.Value / 100)
						end
					end
				end
			end
		end,
		Closed = function()
			for i, v in next, (collectionService:GetTagged('chest')) do
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= ChestStealerDistance.Value then
					local chest = v:FindFirstChild('ChestFolderValue')
					chest = chest and chest.Value or nil
					local chestitems = chest and chest:GetChildren() or {}
					if #chestitems > 1 then
						bedwars.ClientHandler:GetNamespace('Inventory'):Get('SetObservedChest'):SendToServer(chest)
						for i3,v3 in next, (chestitems) do
							if v3:IsA('Accessory') then
								task.spawn(function()
									pcall(function()
										bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGetItem'):CallServer(v.ChestFolderValue.Value, v3)
									end)
								end)
								task.wait(ChestStealerDelay.Value / 100)
							end
						end
						bedwars.ClientHandler:GetNamespace('Inventory'):Get('SetObservedChest'):SendToServer(nil)
					end
				end
			end
		end
	}

	ChestStealer = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'ChestStealer',
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until bedwarsStore.queueType ~= 'bedwars_test'
					if (not ChestStealerSkywars.Enabled) or bedwarsStore.queueType:find('skywars') then
						repeat 
							task.wait(0.1)
							if entityLibrary.isAlive then
								cheststealerfuncs[ChestStealerOpen.Enabled and 'Open' or 'Closed']()
							end
						until (not ChestStealer.Enabled)
					end
				end)
			end
		end,
		HoverText = 'Grabs items from near chests.'
	})
	ChestStealerDistance = ChestStealer.CreateSlider({
		Name = 'Range',
		Min = 0,
		Max = 18,
		Function = function() end,
		Default = 18
	})
	ChestStealerDelay = ChestStealer.CreateSlider({
		Name = 'Delay',
		Min = 1,
		Max = 50,
		Function = function() end,
		Default = 1,
		Double = 100
	})
	ChestStealerOpen = ChestStealer.CreateToggle({
		Name = 'GUI Check',
		Function = function() end
	})
	ChestStealerSkywars = ChestStealer.CreateToggle({
		Name = 'Only Skywars',
		Function = function() end,
		Default = true
	})
end)

runFunction(function()
	local FastDrop = {Enabled = false}
	FastDrop = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'FastDrop',
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						if entityLibrary.isAlive and (not bedwarsStore.localInventory.opened) and (inputService:IsKeyDown(Enum.KeyCode.Q) or inputService:IsKeyDown(Enum.KeyCode.Backspace)) and inputService:GetFocusedTextBox() == nil then
							task.spawn(bedwars.DropItem)
						end
					until (not FastDrop.Enabled)
				end)
			end
		end,
		HoverText = 'Drops items fast when you hold Q'
	})
end)

runFunction(function()
	local MissileTP = {Enabled = false}
	local MissileTeleportDelaySlider = {Value = 30}
	MissileTP = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'MissileTP',
		Function = function(callback)
			if callback then
				task.spawn(function()
					if getItem('guided_missile') then
						local plr = EntityNearMouse(1000)
						if plr then
							local projectile = bedwars.RuntimeLib.await(bedwars.MissileController.fireGuidedProjectile:CallServerAsync('guided_missile'))
							if projectile then
								local projectilemodel = projectile.model
								if not projectilemodel.PrimaryPart then
									projectilemodel:GetPropertyChangedSignal('PrimaryPart'):Wait()
								end;
								local bodyforce = Instance.new('BodyForce')
								bodyforce.Force = Vector3.new(0, projectilemodel.PrimaryPart.AssemblyMass * workspace.Gravity, 0)
								bodyforce.Name = 'AntiGravity'
								bodyforce.Parent = projectilemodel.PrimaryPart

								repeat
									task.wait()
									if projectile.model then
										if plr then
											projectile.model:SetPrimaryPartCFrame(CFrame.new(plr.RootPart.CFrame.p, plr.RootPart.CFrame.p + gameCamera.CFrame.lookVector))
										else
											warningNotification('MissileTP', 'Player died before it could TP.', 3)
											break
										end
									end
								until projectile.model.Parent == nil
							else
								warningNotification('MissileTP', 'Missile on cooldown.', 3)
							end
						else
							warningNotification('MissileTP', 'Player not found.', 3)
						end
					else
						warningNotification('MissileTP', 'Missile not found.', 3)
					end
				end)
				MissileTP.ToggleButton(true)
			end
		end,
		HoverText = 'Spawns and teleports a missile to a player\nnear your mouse.'
	})
end)

runFunction(function()
	local OpenEnderchest = {Enabled = false}
	OpenEnderchest = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'OpenEnderchest',
		Function = function(callback)
			if callback then
				local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name..'_personal')
				if echest then
					bedwars.AppController:openApp('ChestApp', {})
					bedwars.ChestController:openChest(echest)
				else
					warningNotification('OpenEnderchest', 'Enderchest not found', 5)
				end
				OpenEnderchest.ToggleButton(false)
			end
		end,
		HoverText = 'Opens the enderchest'
	})
end)

runFunction(function()
	local PickupRangeRange = {Value = 1}
	local PickupRange = {Enabled = false}
	PickupRange = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'PickupRange', 
		Function = function(callback)
			if callback then
				local pickedup = {}
				task.spawn(function()
					repeat
						local itemdrops = collectionService:GetTagged('ItemDrop')
						for i,v in next, (itemdrops) do
							if entityLibrary.isAlive and (v:GetAttribute('ClientDropTime') and tick() - v:GetAttribute('ClientDropTime') > 2 or v:GetAttribute('ClientDropTime') == nil) then
								if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= PickupRangeRange.Value and (pickedup[v] == nil or pickedup[v] <= tick()) then
									task.spawn(function()
										pickedup[v] = tick() + 0.2
										bedwars.ClientHandler:Get(bedwars.PickupRemote):CallServerAsync({
											itemDrop = v
										}):andThen(function(suc)
											if suc then
												bedwars.SoundManager:playSound(bedwars.SoundList.PICKUP_ITEM_DROP)
											end
										end)
									end)
								end
							end
						end
						task.wait()
					until (not PickupRange.Enabled)
				end)
			end
		end
	})
	PickupRangeRange = PickupRange.CreateSlider({
		Name = 'Range',
		Min = 1,
		Max = 10, 
		Function = function() end,
		Default = 10
	})
end)

runFunction(function()
	local BowExploit = {Enabled = false}
	local BowExploitIgnore = {Enabled = false}
	local BowExploitFunny = {Enabled = false}
	local BowExploitTarget = {Value = 'Mouse'}
	local BowExploitAutoShootFOV = {Value = 1000}
	local oldrealremote
	local noveloproj = {
		'fireball',
		'telepearl'
	}

	BowExploit = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'ProjectileExploit',
		Function = function(callback)
			if callback then 
				oldrealremote = bedwars.ClientConstructor.Function.new
				bedwars.ClientConstructor.Function.new = function(self, ind, ...)
					local res = oldrealremote(self, ind, ...)
					local oldRemote = res.instance
					if oldRemote and oldRemote.Name == bedwars.ProjectileRemote then 
						res.instance = {InvokeServer = function(self, shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, ...) 
							local plr
							if BowExploitTarget.Value == 'Mouse' then
								plr = EntityNearMouse(10000, BowExploitIgnore.Enabled)
							else
								plr = EntityNearPosition(BowExploitAutoShootFOV.Value, BowExploitIgnore.Enabled)
							end
							if plr then	
								if not ({WhitelistFunctions:GetWhitelist(plr.Player)})[2] then 
									return oldRemote:InvokeServer(shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, ...)
								end
		
								tab1.drawDurationSeconds = BowExploitFunny.Enabled and not plr.Player.DisplayName and 'nan(bdafr)' or 3
								tab1.shotId = game:GetService('HttpService'):GenerateGUID(false)
								repeat
									task.wait(0.03)
									local offsetStartPos = plr.RootPart.CFrame.p - plr.RootPart.CFrame.lookVector
									local pos = plr.RootPart.Position
									local playergrav = workspace.Gravity
									local balloons = plr.Character:GetAttribute('InflatedBalloons')
									if balloons and balloons > 0 then 
										playergrav = (workspace.Gravity * (1 - ((balloons >= 4 and 1.2 or balloons >= 3 and 1 or 0.975))))
									end
									if plr.Character.PrimaryPart:FindFirstChild('rbxassetid://8200754399') then 
										playergrav = (workspace.Gravity * 0.3)
									end
									local newLaunchVelo = bedwars.ProjectileMeta[proj2].launchVelocity
									local shootpos, shootvelo = predictGravity(pos, plr.RootPart.Velocity, (pos - offsetStartPos).Magnitude / newLaunchVelo, plr, playergrav)
									if table.find(noveloproj, proj2) then
										shootpos = pos
										shootvelo = Vector3.zero
									end
									local newlook = CFrame.new(offsetStartPos, shootpos) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))
									shootpos = newlook.p + (newlook.lookVector * (offsetStartPos - shootpos).magnitude)
									local calculated = LaunchDirection(offsetStartPos, shootpos, newLaunchVelo, workspace.Gravity, false)
									if calculated then 
										launchvelo = calculated
										launchpos1 = offsetStartPos
										launchpos2 = offsetStartPos
									else
										break
									end
									if oldRemote:InvokeServer(shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, workspace:GetServerTimeNow() - 0.045) then break end
								until false
							else
								return oldRemote:InvokeServer(shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, ...)
							end
						end}
					end
					return res
				end
			else
				bedwars.ClientConstructor.Function.new = oldrealremote
				oldrealremote = nil
			end
		end
	})
	BowExploitTarget = BowExploit.CreateDropdown({
		Name = 'Mode',
		List = {'Mouse', 'Range'},
		Function = function() end
	})
	BowExploitAutoShootFOV = BowExploit.CreateSlider({
		Name = 'FOV',
		Function = function() end,
		Min = 1,
		Max = 1000,
		Default = 1000
	})
	BowExploitFunny = BowExploit.CreateToggle({
		Name = 'Funny',
		HoverText = 'Funny exploit for non-player entities',
		Function = function() end
	})
	BowExploitIgnore = BowExploit.CreateToggle({
		Name = 'Only Players',
		Function = function() end
	})
end)

runFunction(function()
	local RavenTP = {Enabled = false}
	RavenTP = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'RavenTP',
		Function = function(callback)
			if callback then
				task.spawn(function()
					if getItem('raven') then
						local plr = EntityNearMouse(1000)
						if plr then
							local projectile = bedwars.ClientHandler:Get(bedwars.SpawnRavenRemote):CallServerAsync():andThen(function(projectile)
								if projectile then
									local projectilemodel = projectile
									if not projectilemodel then
										projectilemodel:GetPropertyChangedSignal('PrimaryPart'):Wait()
									end
									local bodyforce = Instance.new('BodyForce')
									bodyforce.Force = Vector3.new(0, projectilemodel.PrimaryPart.AssemblyMass * workspace.Gravity, 0)
									bodyforce.Name = 'AntiGravity'
									bodyforce.Parent = projectilemodel.PrimaryPart
	
									if plr then
										projectilemodel:SetPrimaryPartCFrame(CFrame.new(plr.RootPart.CFrame.p, plr.RootPart.CFrame.p + gameCamera.CFrame.lookVector))
										task.wait(0.3)
										bedwars.RavenTable:detonateRaven()
									else
										warningNotification('RavenTP', 'Player died before it could TP.', 3)
									end
								else
									warningNotification('RavenTP', 'Raven on cooldown.', 3)
								end
							end)
						else
							warningNotification('RavenTP', 'Player not found.', 3)
						end
					else
						warningNotification('RavenTP', 'Raven not found.', 3)
					end
				end)
				RavenTP.ToggleButton(true)
			end
		end,
		HoverText = 'Spawns and teleports a raven to a player\nnear your mouse.'
	})
end)

runFunction(function()
	local tiered = {}
	local nexttier = {}

	for i,v in next, (bedwars.ShopItems) do
		if type(v) == 'table' then 
			if v.tiered then
				tiered[v.itemType] = v.tiered
			end
			if v.nextTier then
				nexttier[v.itemType] = v.nextTier
			end
		end
	end

	GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = 'ShopTierBypass',
		Function = function(callback) 
			if callback then
				for i,v in next, (bedwars.ShopItems) do
					if type(v) == 'table' then 
						v.tiered = nil
						v.nextTier = nil
					end
				end
			else
				for i,v in next, (bedwars.ShopItems) do
					if type(v) == 'table' then 
						if tiered[v.itemType] then
							v.tiered = tiered[v.itemType]
						end
						if nexttier[v.itemType] then
							v.nextTier = nexttier[v.itemType]
						end
					end
				end
			end
		end,
		HoverText = 'Allows you to access tiered items early.'
	})
end)

local lagbackedaftertouch = false
runFunction(function()
	local AntiVoidPart
	local AntiVoidConnection
	local AntiVoidMode = {Value = 'Normal'}
	local AntiVoidMoveMode = {Value = 'Normal'}
	local AntiVoid = {Enabled = false}
	local AntiVoidTransparent = {Value = 50}
	local AntiVoidColor = {Hue = 1, Sat = 1, Value = 0.55}
	local lastvalidpos

	local function closestpos(block)
		local startpos = block.Position - (block.Size / 2) + Vector3.new(1.5, 1.5, 1.5)
		local endpos = block.Position + (block.Size / 2) - Vector3.new(1.5, 1.5, 1.5)
		local newpos = block.Position + (entityLibrary.character.HumanoidRootPart.Position - block.Position)
		return Vector3.new(math.clamp(newpos.X, startpos.X, endpos.X), endpos.Y + 3, math.clamp(newpos.Z, startpos.Z, endpos.Z))
	end

	local function getclosesttop(newmag)
		local closest, closestmag = nil, newmag * 3
		if entityLibrary.isAlive then 
			local tops = {}
			for i,v in next, (bedwarsStore.blocks) do 
				local close = getScaffold(closestpos(v), false)
				if getPlacedBlock(close) then continue end
				if close.Y < entityLibrary.character.HumanoidRootPart.Position.Y then continue end
				if (close - entityLibrary.character.HumanoidRootPart.Position).magnitude <= newmag * 3 then 
					table.insert(tops, close)
				end
			end
			for i,v in next, (tops) do 
				local mag = (v - entityLibrary.character.HumanoidRootPart.Position).magnitude
				if mag <= closestmag then 
					closest = v
					closestmag = mag
				end
			end
		end
		return closest
	end

	local antivoidypos = 0
	local antivoiding = false
	AntiVoid = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'AntiVoid', 
		Function = function(callback)
			if callback then
				task.spawn(function()
					AntiVoidPart = Instance.new('Part')
					AntiVoidPart.CanCollide = AntiVoidMode.Value == 'Collide'
					AntiVoidPart.Size = Vector3.new(10000, 1, 10000)
					AntiVoidPart.Anchored = true
					AntiVoidPart.Material = Enum.Material.Neon
					AntiVoidPart.Color = Color3.fromHSV(AntiVoidColor.Hue, AntiVoidColor.Sat, AntiVoidColor.Value)
					AntiVoidPart.Transparency = 1 - (AntiVoidTransparent.Value / 100)
					AntiVoidPart.Position = Vector3.new(0, antivoidypos, 0)
					AntiVoidPart.Parent = workspace
					if AntiVoidMoveMode.Value == 'Classic' and antivoidypos == 0 then 
						AntiVoidPart.Parent = nil
					end
					AntiVoidConnection = AntiVoidPart.Touched:Connect(function(touchedpart)
						if touchedpart.Parent == lplr.Character and entityLibrary.isAlive then
							if (not antivoiding) and (not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) and entityLibrary.character.Humanoid.Health > 0 and AntiVoidMode.Value ~= 'Collide' then
								if AntiVoidMode.Value == 'Velocity' then
									entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 100, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								else
									antivoiding = true
									local pos = getclosesttop(1000)
									if pos then
										local lastTeleport = lplr:GetAttribute('LastTeleported')
										RunLoops:BindToHeartbeat('AntiVoid', function(dt)
											if entityLibrary.isAlive and entityLibrary.character.Humanoid.Health > 0 and isnetworkowner(entityLibrary.character.HumanoidRootPart) and (entityLibrary.character.HumanoidRootPart.Position - pos).Magnitude > 1 and AntiVoid.Enabled and lplr:GetAttribute('LastTeleported') == lastTeleport then 
												local hori1 = Vector3.new(entityLibrary.character.HumanoidRootPart.Position.X, 0, entityLibrary.character.HumanoidRootPart.Position.Z)
												local hori2 = Vector3.new(pos.X, 0, pos.Z)
												local newpos = (hori2 - hori1).Unit
												local realnewpos = CFrame.new(newpos == newpos and entityLibrary.character.HumanoidRootPart.CFrame.p + (newpos * ((3 + getSpeed()) * dt)) or Vector3.zero)
												entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(realnewpos.p.X, pos.Y, realnewpos.p.Z)
												antivoidvelo = newpos == newpos and newpos * 20 or Vector3.zero
												entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(antivoidvelo.X, entityLibrary.character.HumanoidRootPart.Velocity.Y, antivoidvelo.Z)
												if getPlacedBlock((entityLibrary.character.HumanoidRootPart.CFrame.p - Vector3.new(0, 1, 0)) + entityLibrary.character.HumanoidRootPart.Velocity.Unit) or getPlacedBlock(entityLibrary.character.HumanoidRootPart.CFrame.p + Vector3.new(0, 3)) then
													pos = pos + Vector3.new(0, 1, 0)
												end
											else
												RunLoops:UnbindFromHeartbeat('AntiVoid')
												antivoidvelo = nil
												antivoiding = false
											end
										end)
									else
										entityLibrary.character.HumanoidRootPart.CFrame += Vector3.new(0, 100000, 0)
										antivoiding = false
									end
								end
							end
						end
					end)
					repeat
						if entityLibrary.isAlive and AntiVoidMoveMode.Value == 'Normal' then 
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							if ray or GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled or GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled then 
								AntiVoidPart.Position = entityLibrary.character.HumanoidRootPart.Position - Vector3.new(0, 21, 0)
							end
						end
						task.wait()
					until (not AntiVoid.Enabled)
				end)
			else
				if AntiVoidConnection then AntiVoidConnection:Disconnect() end
				if AntiVoidPart then
					AntiVoidPart:Destroy() 
				end
			end
		end, 
		HoverText = 'Gives you a chance to get on land (Bouncing Twice, abusing, or bad luck will lead to lagbacks)'
	})
	AntiVoidMoveMode = AntiVoid.CreateDropdown({
		Name = 'Position Mode',
		Function = function(val) 
			if val == 'Classic' then 
				task.spawn(function()
					repeat task.wait() until bedwarsStore.matchState ~= 0 or not vapeInjected
					if vapeInjected and AntiVoidMoveMode.Value == 'Classic' and antivoidypos == 0 and AntiVoid.Enabled then
						local lowestypos = 99999
						for i,v in next, (bedwarsStore.blocks) do 
							local newray = workspace:Raycast(v.Position + Vector3.new(0, 800, 0), Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							if i % 200 == 0 then 
								task.wait(0.06)
							end
							if newray and newray.Position.Y <= lowestypos then
								lowestypos = newray.Position.Y
							end
						end
						antivoidypos = lowestypos - 8
					end
					if AntiVoidPart then 
						AntiVoidPart.Position = Vector3.new(0, antivoidypos, 0)
						AntiVoidPart.Parent = workspace
					end
				end)
			end
		end,
		List = {'Normal', 'Classic'}
	})
	AntiVoidMode = AntiVoid.CreateDropdown({
		Name = 'Move Mode',
		Function = function(val) 
			if AntiVoidPart then 
				AntiVoidPart.CanCollide = val == 'Collide'
			end
		end,
		List = {'Normal', 'Collide', 'Velocity'}
	})
	AntiVoidTransparent = AntiVoid.CreateSlider({
		Name = 'Invisible',
		Min = 1,
		Max = 100,
		Default = 50,
		Function = function(val) 
			if AntiVoidPart then
				AntiVoidPart.Transparency = 1 - (val / 100)
			end
		end,
	})
	AntiVoidColor = AntiVoid.CreateColorSlider({
		Name = 'Color',
		Function = function(h, s, v) 
			if AntiVoidPart then
				AntiVoidPart.Color = Color3.fromHSV(h, s, v)
			end
		end
	})
end)

runFunction(function()
	local oldenable2
	local olddisable2
	local oldhitblock
	local blockplacetable2 = {}
	local blockplaceenabled2 = false

	local AutoTool = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'AutoTool',
		Function = function(callback)
			if callback then
				oldenable2 = bedwars.BlockBreaker.enable
				olddisable2 = bedwars.BlockBreaker.disable
				oldhitblock = bedwars.BlockBreaker.hitBlock
				bedwars.BlockBreaker.enable = function(Self, tab)
					blockplaceenabled2 = true
					blockplacetable2 = Self
					return oldenable2(Self, tab)
				end
				bedwars.BlockBreaker.disable = function(Self)
					blockplaceenabled2 = false
					return olddisable2(Self)
				end
				bedwars.BlockBreaker.hitBlock = function(...)
					if entityLibrary.isAlive and (GuiLibrary.ObjectsThatCanBeSaved['Lobby CheckToggle'].Api.Enabled == false or bedwarsStore.matchState ~= 0) and blockplaceenabled2 then
						local mouseinfo = blockplacetable2.clientManager:getBlockSelector():getMouseInfo(0)
						if mouseinfo and mouseinfo.target and not mouseinfo.target.blockInstance:GetAttribute('NoBreak') and not mouseinfo.target.blockInstance:GetAttribute('Team'..(lplr:GetAttribute('Team') or 0)..'NoBreak') then
							if switchToAndUseTool(mouseinfo.target.blockInstance, true) then
								return
							end
						end
					end
					return oldhitblock(...)
				end
			else
				RunLoops:UnbindFromRenderStep('AutoTool')
				bedwars.BlockBreaker.enable = oldenable2
				bedwars.BlockBreaker.disable = olddisable2
				bedwars.BlockBreaker.hitBlock = oldhitblock
				oldenable2 = nil
				olddisable2 = nil
				oldhitblock = nil
			end
		end,
		HoverText = 'Automatically swaps your hand to the appropriate tool.'
	})
end)

runFunction(function()
	local BedProtector = {Enabled = false}
	local bedprotector1stlayer = {
		Vector3.new(0, 3, 0),
		Vector3.new(0, 3, 3),
		Vector3.new(3, 0, 0),
		Vector3.new(3, 0, 3),
		Vector3.new(-3, 0, 0),
		Vector3.new(-3, 0, 3),
		Vector3.new(0, 0, 6),
		Vector3.new(0, 0, -3)
	}
	local bedprotector2ndlayer = {
		Vector3.new(0, 6, 0),
		Vector3.new(0, 6, 3),
		Vector3.new(0, 3, 6),
		Vector3.new(0, 3, -3),
		Vector3.new(0, 0, -6),
		Vector3.new(0, 0, 9),
		Vector3.new(3, 3, 0),
		Vector3.new(3, 3, 3),
		Vector3.new(3, 0, 6),
		Vector3.new(3, 0, -3),
		Vector3.new(6, 0, 3),
		Vector3.new(6, 0, 0),
		Vector3.new(-3, 3, 3),
		Vector3.new(-3, 3, 0),
		Vector3.new(-6, 0, 3),
		Vector3.new(-6, 0, 0),
		Vector3.new(-3, 0, 6),
		Vector3.new(-3, 0, -3),
	}

	local function getItemFromList(list)
		local selecteditem
		for i3,v3 in next, (list) do
			local item = getItem(v3)
			if item then 
				selecteditem = item
				break
			end
		end
		return selecteditem
	end

	local function placelayer(layertab, obj, selecteditems)
		for i2,v2 in next, (layertab) do
			local selecteditem = getItemFromList(selecteditems)
			if selecteditem then
				bedwars.placeBlock(obj.Position + v2, selecteditem.itemType)
			else
				return false
			end
		end
		return true
	end

	local bedprotectorrange = {Value = 1}
	BedProtector = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'BedProtector',
		Function = function(callback)
            if callback then
                task.spawn(function()
                    for i, obj in next, (collectionService:GetTagged('bed')) do
                        if entityLibrary.isAlive and obj:GetAttribute('Team'..(lplr:GetAttribute('Team') or 0)..'NoBreak') and obj.Parent ~= nil then
                            if (entityLibrary.character.HumanoidRootPart.Position - obj.Position).magnitude <= bedprotectorrange.Value then
                                local firstlayerplaced = placelayer(bedprotector1stlayer, obj, {'obsidian', 'stone_brick', 'plank_oak', getWool()})
							    if firstlayerplaced then
									placelayer(bedprotector2ndlayer, obj, {getWool()})
							    end
                            end
                            break
                        end
                    end
                    BedProtector.ToggleButton(false)
                end)
            end
		end,
		HoverText = 'Automatically places a bed defense (Toggle)'
	})
	bedprotectorrange = BedProtector.CreateSlider({
		Name = 'Place range',
		Min = 1, 
		Max = 20, 
		Function = function(val) end, 
		Default = 20
	})
end)

runFunction(function()
	local Nuker = {Enabled = false}
	local nukerrange = {Value = 1}
	local nukereffects = {Enabled = false}
	local nukeranimation = {Enabled = false}
	local nukernofly = {Enabled = false}
	local nukerlegit = {Enabled = false}
	local nukerown = {Enabled = false}
    local nukerluckyblock = {Enabled = false}
	local nukerironore = {Enabled = false}
    local nukerbeds = {Enabled = false}
	local nukercustom = {RefreshValues = function() end, ObjectList = {}}
    local luckyblocktable = {}

	Nuker = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'Nuker',
		Function = function(callback)
            if callback then
				for i,v in next, (bedwarsStore.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find('lucky')) or (nukerironore.Enabled and v.Name == 'iron_ore') then
						table.insert(luckyblocktable, v)
					end
				end
				table.insert(Nuker.Connections, collectionService:GetInstanceAddedSignal('block'):Connect(function(v)
                    if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find('lucky')) or (nukerironore.Enabled and v.Name == 'iron_ore') then
                        table.insert(luckyblocktable, v)
                    end
                end))
                table.insert(Nuker.Connections, collectionService:GetInstanceRemovedSignal('block'):Connect(function(v)
                    if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find('lucky')) or (nukerironore.Enabled and v.Name == 'iron_ore') then
                        table.remove(luckyblocktable, table.find(luckyblocktable, v))
                    end
                end))
                task.spawn(function()
                    repeat
						if (not nukernofly.Enabled or not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) then
							local broke = not entityLibrary.isAlive
							local tool = (not nukerlegit.Enabled) and {Name = 'wood_axe'} or bedwarsStore.localHand.tool
							if nukerbeds.Enabled then
								for i, obj in next, (collectionService:GetTagged('bed')) do
									if broke then break end
									if obj.Parent ~= nil then
										if obj:GetAttribute('BedShieldEndTime') then 
											if obj:GetAttribute('BedShieldEndTime') > workspace:GetServerTimeNow() then continue end
										end
										if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - obj.Position).magnitude <= nukerrange.Value then
											if tool and bedwars.ItemTable[tool.Name].breakBlock and bedwars.BlockController:isBlockBreakable({blockPosition = obj.Position / 3}, lplr) then
												local res, amount = getBestBreakSide(obj.Position)
												local res2, amount2 = getBestBreakSide(obj.Position + Vector3.new(0, 0, 3))
												broke = true
												bedwars.breakBlock((amount < amount2 and obj.Position or obj.Position + Vector3.new(0, 0, 3)), nukereffects.Enabled, (amount < amount2 and res or res2), false, nukeranimation.Enabled)
												break
											end
										end
									end
								end
							end
							broke = broke and not entityLibrary.isAlive
							for i, obj in next, (luckyblocktable) do
								if broke then break end
								if entityLibrary.isAlive then
									if obj and obj.Parent ~= nil then
										if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - obj.Position).magnitude <= nukerrange.Value and (nukerown.Enabled or obj:GetAttribute('PlacedByUserId') ~= lplr.UserId) then
											if tool and bedwars.ItemTable[tool.Name].breakBlock and bedwars.BlockController:isBlockBreakable({blockPosition = obj.Position / 3}, lplr) then
												bedwars.breakBlock(obj.Position, nukereffects.Enabled, getBestBreakSide(obj.Position), true, nukeranimation.Enabled)
												break
											end
										end
									end
								end
							end
						end
						task.wait()
                    until (not Nuker.Enabled)
                end)
            else
                luckyblocktable = {}
            end
		end,
		HoverText = 'Automatically destroys beds & luckyblocks around you.'
	})
	nukerrange = Nuker.CreateSlider({
		Name = 'Break range',
		Min = 1, 
		Max = 30, 
		Function = function(val) end, 
		Default = 30
	})
	nukerlegit = Nuker.CreateToggle({
		Name = 'Hand Check',
		Function = function() end
	})
	nukereffects = Nuker.CreateToggle({
		Name = 'Show HealthBar & Effects',
		Function = function(callback) 
			if not callback then
				bedwars.BlockBreaker.healthbarMaid:DoCleaning()
			end
		 end,
		Default = true
	})
	nukeranimation = Nuker.CreateToggle({
		Name = 'Break Animation',
		Function = function() end
	})
	nukerown = Nuker.CreateToggle({
		Name = 'Self Break',
		Function = function() end,
	})
    nukerbeds = Nuker.CreateToggle({
		Name = 'Break Beds',
		Function = function(callback) end,
		Default = true
	})
	nukernofly = Nuker.CreateToggle({
		Name = 'Fly Disable',
		Function = function() end
	})
    nukerluckyblock = Nuker.CreateToggle({
		Name = 'Break LuckyBlocks',
		Function = function(callback) 
			if callback then 
				luckyblocktable = {}
				for i,v in next, (bedwarsStore.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find('lucky')) or (nukerironore.Enabled and v.Name == 'iron_ore') then
						table.insert(luckyblocktable, v)
					end
				end
			else
				luckyblocktable = {}
			end
		 end,
		Default = true
	})
	nukerironore = Nuker.CreateToggle({
		Name = 'Break IronOre',
		Function = function(callback) 
			if callback then 
				luckyblocktable = {}
				for i,v in next, (bedwarsStore.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find('lucky')) or (nukerironore.Enabled and v.Name == 'iron_ore') then
						table.insert(luckyblocktable, v)
					end
				end
			else
				luckyblocktable = {}
			end
		end
	})
	nukercustom = Nuker.CreateTextList({
		Name = 'NukerList',
		TempText = 'block (tesla_trap)',
		AddFunction = function()
			luckyblocktable = {}
			for i,v in next, (bedwarsStore.blocks) do
				if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find('lucky')) then
					table.insert(luckyblocktable, v)
				end
			end
		end
	})
end)


runFunction(function()
	local controlmodule = require(lplr.PlayerScripts.PlayerModule).controls
	local oldmove
	local SafeWalk = {Enabled = false}
	local SafeWalkMode = {Value = 'Optimized'}
	SafeWalk = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'SafeWalk',
		Function = function(callback)
			if callback then
				oldmove = controlmodule.moveFunction
				controlmodule.moveFunction = function(Self, vec, facecam)
					if entityLibrary.isAlive and (not Scaffold.Enabled) and (not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) then
						if SafeWalkMode.Value == 'Optimized' then 
							local newpos = (entityLibrary.character.HumanoidRootPart.Position - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight * 2, 0))
							local ray = getPlacedBlock(newpos + Vector3.new(0, -6, 0) + vec)
							for i = 1, 50 do 
								if ray then break end
								ray = getPlacedBlock(newpos + Vector3.new(0, -i * 6, 0) + vec)
							end
							local ray2 = getPlacedBlock(newpos)
							if ray == nil and ray2 then
								local ray3 = getPlacedBlock(newpos + vec) or getPlacedBlock(newpos + (vec * 1.5))
								if ray3 == nil then 
									vec = Vector3.zero
								end
							end
						else
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position + vec, Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							local ray2 = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -entityLibrary.character.Humanoid.HipHeight * 2, 0), bedwarsStore.blockRaycast)
							if ray == nil and ray2 then
								local ray3 = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position + (vec * 1.8), Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
								if ray3 == nil then 
									vec = Vector3.zero
								end
							end
						end
					end
					return oldmove(Self, vec, facecam)
				end
			else
				controlmodule.moveFunction = oldmove
			end
		end,
		HoverText = 'lets you not walk off because you are bad'
	})
	SafeWalkMode = SafeWalk.CreateDropdown({
		Name = 'Mode',
		List = {'Optimized', 'Accurate'},
		Function = function() end
	})
end)

runFunction(function()
	local Schematica = {Enabled = false}
	local SchematicaBox = {Value = ''}
	local SchematicaTransparency = {Value = 30}
	local positions = {}
	local tempfolder
	local tempgui
	local aroundpos = {
		[1] = Vector3.new(0, 3, 0),
		[2] = Vector3.new(-3, 3, 0),
		[3] = Vector3.new(-3, -0, 0),
		[4] = Vector3.new(-3, -3, 0),
		[5] = Vector3.new(0, -3, 0),
		[6] = Vector3.new(3, -3, 0),
		[7] = Vector3.new(3, -0, 0),
		[8] = Vector3.new(3, 3, 0),
		[9] = Vector3.new(0, 3, -3),
		[10] = Vector3.new(-3, 3, -3),
		[11] = Vector3.new(-3, -0, -3),
		[12] = Vector3.new(-3, -3, -3),
		[13] = Vector3.new(0, -3, -3),
		[14] = Vector3.new(3, -3, -3),
		[15] = Vector3.new(3, -0, -3),
		[16] = Vector3.new(3, 3, -3),
		[17] = Vector3.new(0, 3, 3),
		[18] = Vector3.new(-3, 3, 3),
		[19] = Vector3.new(-3, -0, 3),
		[20] = Vector3.new(-3, -3, 3),
		[21] = Vector3.new(0, -3, 3),
		[22] = Vector3.new(3, -3, 3),
		[23] = Vector3.new(3, -0, 3),
		[24] = Vector3.new(3, 3, 3),
		[25] = Vector3.new(0, -0, 3),
		[26] = Vector3.new(0, -0, -3)
	}

	local function isNearBlock(pos)
		for i,v in next, (aroundpos) do
			if getPlacedBlock(pos + v) then
				return true
			end
		end
		return false
	end

	local function gethighlightboxatpos(pos)
		if tempfolder then
			for i,v in next, (tempfolder:GetChildren()) do
				if v.Position == pos then
					return v 
				end
			end
		end
		return nil
	end

	local function removeduplicates(tab)
		local actualpositions = {}
		for i,v in next, (tab) do
			if table.find(actualpositions, Vector3.new(v.X, v.Y, v.Z)) == nil then
				table.insert(actualpositions, Vector3.new(v.X, v.Y, v.Z))
			else
				table.remove(tab, i)
			end
			if v.blockType == 'start_block' then
				table.remove(tab, i)
			end
		end
	end

	local function rotate(tab)
		for i,v in next, (tab) do
			local radvec, radius = entityLibrary.character.HumanoidRootPart.CFrame:ToAxisAngle()
			radius = (radius * 57.2957795)
			radius = math.round(radius / 90) * 90
			if radvec == Vector3.new(0, -1, 0) and radius == 90 then
				radius = 270
			end
			local rot = CFrame.new() * CFrame.fromAxisAngle(Vector3.new(0, 1, 0), math.rad(radius))
			local newpos = CFrame.new(0, 0, 0) * rot * CFrame.new(Vector3.new(v.X, v.Y, v.Z))
			v.X = math.round(newpos.p.X)
			v.Y = math.round(newpos.p.Y)
			v.Z = math.round(newpos.p.Z)
		end
	end

	local function getmaterials(tab)
		local materials = {}
		for i,v in next, (tab) do
			materials[v.blockType] = (materials[v.blockType] and materials[v.blockType] + 1 or 1)
		end
		return materials
	end

	local function schemplaceblock(pos, blocktype, removefunc)
		local fail = false
		local ok = bedwars.RuntimeLib.try(function()
			bedwars.ClientHandlerDamageBlock:Get('PlaceBlock'):CallServer({
				blockType = blocktype or getWool(),
				position = bedwars.BlockController:getBlockPosition(pos)
			})
		end, function(thing)
			fail = true
		end)
		if (not fail) and bedwars.BlockController:getStore():getBlockAt(bedwars.BlockController:getBlockPosition(pos)) then
			removefunc()
		end
	end

	Schematica = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = 'Schematica',
		Function = function(callback)
			if callback then
				local mouseinfo = bedwars.BlockEngine:getBlockSelector():getMouseInfo(0)
				if mouseinfo and isfile(SchematicaBox.Value) then
					tempfolder = Instance.new('Folder')
					tempfolder.Parent = workspace
					local newpos = mouseinfo.placementPosition * 3
					positions = game:GetService('HttpService'):JSONDecode(readfile(SchematicaBox.Value))
					if positions.blocks == nil then
						positions = {blocks = positions}
					end
					rotate(positions.blocks)
					removeduplicates(positions.blocks)
					if positions['start_block'] == nil then
						bedwars.placeBlock(newpos)
					end
					for i2,v2 in next, (positions.blocks) do
						local texturetxt = bedwars.ItemTable[(v2.blockType == 'wool_white' and getWool() or v2.blockType)].block.greedyMesh.textures[1]
						local newerpos = (newpos + Vector3.new(v2.X, v2.Y, v2.Z))
						local block = Instance.new('Part')
						block.Position = newerpos
						block.Size = Vector3.new(3, 3, 3)
						block.CanCollide = false
						block.Transparency = (SchematicaTransparency.Value == 10 and 0 or 1)
						block.Anchored = true
						block.Parent = tempfolder
						for i3,v3 in next, (Enum.NormalId:GetEnumItems()) do
							local texture = Instance.new('Texture')
							texture.Face = v3
							texture.Texture = texturetxt
							texture.Name = tostring(v3)
							texture.Transparency = (SchematicaTransparency.Value == 10 and 0 or (1 / SchematicaTransparency.Value))
							texture.Parent = block
						end
					end
					task.spawn(function()
						repeat
							task.wait(.1)
							if not Schematica.Enabled then break end
							for i,v in next, (positions.blocks) do
								local newerpos = (newpos + Vector3.new(v.X, v.Y, v.Z))
								if entityLibrary.isAlive and (entityLibrary.character.HumanoidRootPart.Position - newerpos).magnitude <= 30 and isNearBlock(newerpos) and bedwars.BlockController:isAllowedPlacement(lplr, getWool(), newerpos / 3, 0) then
									schemplaceblock(newerpos, (v.blockType == 'wool_white' and getWool() or v.blockType), function()
										table.remove(positions.blocks, i)
										if gethighlightboxatpos(newerpos) then
											gethighlightboxatpos(newerpos):Remove()
										end
									end)
								end
							end
						until #positions.blocks == 0 or (not Schematica.Enabled)
						if Schematica.Enabled then 
							Schematica.ToggleButton(false)
							warningNotification('Schematica', 'Finished Placing Blocks', 4)
						end
					end)
				end
			else
				positions = {}
				if tempfolder then
					tempfolder:Remove()
				end
			end
		end,
		HoverText = 'Automatically places structure at mouse position.'
	})
	SchematicaBox = Schematica.CreateTextBox({
		Name = 'File',
		TempText = 'File (location in workspace)',
		FocusLost = function(enter) 
			local suc, res = pcall(function() return game:GetService('HttpService'):JSONDecode(readfile(SchematicaBox.Value)) end)
			if tempgui then
				tempgui:Remove()
			end
			if suc then
				if res.blocks == nil then
					res = {blocks = res}
				end
				removeduplicates(res.blocks)
				tempgui = Instance.new('Frame')
				tempgui.Name = 'SchematicListOfBlocks'
				tempgui.BackgroundTransparency = 1
				tempgui.LayoutOrder = 9999
				tempgui.Parent = SchematicaBox.Object.Parent
				local uilistlayoutschmatica = Instance.new('UIListLayout')
				uilistlayoutschmatica.Parent = tempgui
				uilistlayoutschmatica:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
					tempgui.Size = UDim2.new(0, 220, 0, uilistlayoutschmatica.AbsoluteContentSize.Y)
				end)
				for i4,v4 in next, (getmaterials(res.blocks)) do
					local testframe = Instance.new('Frame')
					testframe.Size = UDim2.new(0, 220, 0, 40)
					testframe.BackgroundTransparency = 1
					testframe.Parent = tempgui
					local testimage = Instance.new('ImageLabel')
					testimage.Size = UDim2.new(0, 40, 0, 40)
					testimage.Position = UDim2.new(0, 3, 0, 0)
					testimage.BackgroundTransparency = 1
					testimage.Image = bedwars.getIcon({itemType = i4}, true)
					testimage.Parent = testframe
					local testtext = Instance.new('TextLabel')
					testtext.Size = UDim2.new(1, -50, 0, 40)
					testtext.Position = UDim2.new(0, 50, 0, 0)
					testtext.TextSize = 20
					testtext.Text = v4
					testtext.Font = Enum.Font.SourceSans
					testtext.TextXAlignment = Enum.TextXAlignment.Left
					testtext.TextColor3 = Color3.new(1, 1, 1)
					testtext.BackgroundTransparency = 1
					testtext.Parent = testframe
				end
			end
		end
	})
	SchematicaTransparency = Schematica.CreateSlider({
		Name = 'Transparency',
		Min = 0,
		Max = 10,
		Default = 7,
		Function = function()
			if tempfolder then
				for i2,v2 in next, (tempfolder:GetChildren()) do
					v2.Transparency = (SchematicaTransparency.Value == 10 and 0 or 1)
					for i3,v3 in next, (v2:GetChildren()) do
						v3.Transparency = (SchematicaTransparency.Value == 10 and 0 or (1 / SchematicaTransparency.Value))
					end
				end
			end
		end
	})
end)

runFunction(function()
	bedwarsStore.TPString = shared.vapeoverlay or nil
	local origtpstring = bedwarsStore.TPString
	local Overlay = GuiLibrary.CreateCustomWindow({
		Name = 'Overlay',
		Icon = 'vape/assets/TargetIcon1.png',
		IconSize = 16
	})
	local overlayframe = Instance.new('Frame')
	overlayframe.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	overlayframe.Size = UDim2.new(0, 200, 0, 120)
	overlayframe.Position = UDim2.new(0, 0, 0, 5)
	overlayframe.Parent = Overlay.GetCustomChildren()
	local overlayframe2 = Instance.new('Frame')
	overlayframe2.Size = UDim2.new(1, 0, 0, 10)
	overlayframe2.Position = UDim2.new(0, 0, 0, -5)
	overlayframe2.Parent = overlayframe
	local overlayframe3 = Instance.new('Frame')
	overlayframe3.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	overlayframe3.Size = UDim2.new(1, 0, 0, 6)
	overlayframe3.Position = UDim2.new(0, 0, 0, 6)
	overlayframe3.BorderSizePixel = 0
	overlayframe3.Parent = overlayframe2
	local oldguiupdate = GuiLibrary.UpdateUI
	GuiLibrary.UpdateUI = function(h, s, v, ...)
		overlayframe2.BackgroundColor3 = Color3.fromHSV(h, s, v)
		return oldguiupdate(h, s, v, ...)
	end
	local framecorner1 = Instance.new('UICorner')
	framecorner1.CornerRadius = UDim.new(0, 5)
	framecorner1.Parent = overlayframe
	local framecorner2 = Instance.new('UICorner')
	framecorner2.CornerRadius = UDim.new(0, 5)
	framecorner2.Parent = overlayframe2
	local label = Instance.new('TextLabel')
	label.Size = UDim2.new(1, -7, 1, -5)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.Font = Enum.Font.Arial
	label.LineHeight = 1.2
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	label.TextSize = 16
	label.Text = ''
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.Position = UDim2.new(0, 7, 0, 5)
	label.Parent = overlayframe
	local OverlayFonts = {'Arial'}
	for i,v in next, (Enum.Font:GetEnumItems()) do 
		if v.Name ~= 'Arial' then
			table.insert(OverlayFonts, v.Name)
		end
	end
	local OverlayFont = Overlay.CreateDropdown({
		Name = 'Font',
		List = OverlayFonts,
		Function = function(val)
			label.Font = Enum.Font[val]
		end
	})
	OverlayFont.Bypass = true
	Overlay.Bypass = true
	local overlayconnections = {}
	local oldnetworkowner
	local teleported = {}
	local teleported2 = {}
	local teleportedability = {}
	local teleportconnections = {}
	local pinglist = {}
	local fpslist = {}
	local matchstatechanged = 0
	local mapname = 'Unknown'
	local overlayenabled = false
	
	task.spawn(function()
		pcall(function()
			mapname = workspace:WaitForChild('Map'):WaitForChild('Worlds'):GetChildren()[1].Name
			mapname = string.gsub(string.split(mapname, '_')[2] or mapname, '-', '') or 'Blank'
		end)
	end)

	local function didpingspike()
		local currentpingcheck = pinglist[1] or math.floor(tonumber(game:GetService('Stats'):FindFirstChild('PerformanceStats').Ping:GetValue()))
		for i,v in next, (pinglist) do 
			if v ~= currentpingcheck and math.abs(v - currentpingcheck) >= 100 then 
				return currentpingcheck..' => '..v..' ping'
			else
				currentpingcheck = v
			end
		end
		return nil
	end

	local function notlasso()
		for i,v in next, (collectionService:GetTagged('LassoHooked')) do 
			if v == lplr.Character then 
				return false
			end
		end
		return true
	end
	local matchstatetick = tick()

	GuiLibrary.ObjectsThatCanBeSaved.GUIWindow.Api.CreateCustomToggle({
		Name = 'Overlay', 
		Icon = 'vape/assets/TargetIcon1.png', 
		Function = function(callback)
			overlayenabled = callback
			Overlay.SetVisible(callback) 
			if callback then 
				table.insert(overlayconnections, bedwars.ClientHandler:OnEvent('ProjectileImpact', function(p3)
					if not vapeInjected then return end
					if p3.projectile == 'telepearl' then 
						teleported[p3.shooterPlayer] = true
					elseif p3.projectile == 'swap_ball' then
						if p3.hitEntity then 
							teleported[p3.shooterPlayer] = true
							local plr = playersService:GetPlayerFromCharacter(p3.hitEntity)
							if plr then teleported[plr] = true end
						end
					end
				end))
		
				table.insert(overlayconnections, replicatedStorageService['events-@easy-games/game-core:shared/game-core-networking@getEvents.Events'].abilityUsed.OnClientEvent:Connect(function(char, ability)
					if ability == 'recall' or ability == 'hatter_teleport' or ability == 'spirit_assassin_teleport' or ability == 'hannah_execute' then 
						local plr = playersService:GetPlayerFromCharacter(char)
						if plr then
							teleportedability[plr] = tick() + (ability == 'recall' and 12 or 1)
						end
					end
				end))

				table.insert(overlayconnections, vapeEvents.BedwarsBedBreak.Event:Connect(function(bedTable)
					if bedTable.player.UserId == lplr.UserId then
						bedwarsStore.statistics.beds = bedwarsStore.statistics.beds + 1
					end
				end))

				local victorysaid = false
				table.insert(overlayconnections, vapeEvents.MatchEndEvent.Event:Connect(function(winstuff)
					local myTeam = bedwars.ClientStoreHandler:getState().Game.myTeam
					if myTeam and myTeam.id == winstuff.winningTeamId or lplr.Neutral then
						victorysaid = true
					end
				end))

				table.insert(overlayconnections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if deathTable.finalKill then
						local killer = playersService:GetPlayerFromCharacter(deathTable.fromEntity)
						local killed = playersService:GetPlayerFromCharacter(deathTable.entityInstance)
						if not killed or not killer then return end
						if killed ~= lplr and killer == lplr then 
							bedwarsStore.statistics.kills = bedwarsStore.statistics.kills + 1
						end
					end
				end))
				
				task.spawn(function()
					repeat
						local ping = math.floor(tonumber(game:GetService('Stats'):FindFirstChild('PerformanceStats').Ping:GetValue()))
						if #pinglist >= 10 then 
							table.remove(pinglist, 1)
						end
						table.insert(pinglist, ping)
						task.wait(1)
						if bedwarsStore.matchState ~= matchstatechanged then 
							if bedwarsStore.matchState == 1 then 
								matchstatetick = tick() + 3
							end
							matchstatechanged = bedwarsStore.matchState
						end
						if not bedwarsStore.TPString then
							bedwarsStore.TPString = tick()..'/'..bedwarsStore.statistics.kills..'/'..bedwarsStore.statistics.beds..'/'..(victorysaid and 1 or 0)..'/'..(1)..'/'..(0)..'/'..(0)..'/'..(0)
							origtpstring = bedwarsStore.TPString
						end
						if entityLibrary.isAlive and (not oldcloneroot) then 
							local newnetworkowner = isnetworkowner(entityLibrary.character.HumanoidRootPart)
							if oldnetworkowner ~= nil and oldnetworkowner ~= newnetworkowner and newnetworkowner == false and notlasso() then 
								local respawnflag = math.abs(lplr:GetAttribute('SpawnTime') - lplr:GetAttribute('LastTeleported')) > 3
								if (not teleported[lplr]) and respawnflag then
									task.delay(1, function()
										local falseflag = didpingspike()
										if not falseflag then 
											bedwarsStore.statistics.lagbacks = bedwarsStore.statistics.lagbacks + 1
										end
									end)
								end
							end
							oldnetworkowner = newnetworkowner
						else
							oldnetworkowner = nil
						end
						teleported[lplr] = nil
						for i, v in next, (entityLibrary.entityList) do 
							if teleportconnections[v.Player.Name..'1'] then continue end
							teleportconnections[v.Player.Name..'1'] = v.Player:GetAttributeChangedSignal('LastTeleported'):Connect(function()
								if not vapeInjected then return end
								for i = 1, 15 do 
									task.wait(0.1)
									if teleported[v.Player] or teleported2[v.Player] or matchstatetick > tick() or math.abs(v.Player:GetAttribute('SpawnTime') - v.Player:GetAttribute('LastTeleported')) < 3 or (teleportedability[v.Player] or tick() - 1) > tick() then break end
								end
								if v.Player ~= nil and (not v.Player.Neutral) and teleported[v.Player] == nil and teleported2[v.Player] == nil and (teleportedability[v.Player] or tick() - 1) < tick() and math.abs(v.Player:GetAttribute('SpawnTime') - v.Player:GetAttribute('LastTeleported')) > 3 and matchstatetick <= tick() then 
									bedwarsStore.statistics.universalLagbacks = bedwarsStore.statistics.universalLagbacks + 1
									vapeEvents.LagbackEvent:Fire(v.Player)
								end
								teleported[v.Player] = nil
							end)
							teleportconnections[v.Player.Name..'2'] = v.Player:GetAttributeChangedSignal('PlayerConnected'):Connect(function()
								teleported2[v.Player] = true
								task.delay(5, function()
									teleported2[v.Player] = nil
								end)
							end)
						end
						local splitted = origtpstring:split('/')
						label.Text = 'Session Info\nTime Played : '..os.date('!%X',math.floor(tick() - splitted[1]))..'\nKills : '..(splitted[2] + bedwarsStore.statistics.kills)..'\nBeds : '..(splitted[3] + bedwarsStore.statistics.beds)..'\nWins : '..(splitted[4] + (victorysaid and 1 or 0))..'\nGames : '..splitted[5]..'\nLagbacks : '..(splitted[6] + bedwarsStore.statistics.lagbacks)..'\nUniversal Lagbacks : '..(splitted[7] + bedwarsStore.statistics.universalLagbacks)..'\nReported : '..(splitted[8] + bedwarsStore.statistics.reported)..'\nMap : '..mapname
						local textsize = textService:GetTextSize(label.Text, label.TextSize, label.Font, Vector2.new(9e9, 9e9))
						overlayframe.Size = UDim2.new(0, math.max(textsize.X + 19, 200), 0, (textsize.Y * 1.2) + 6)
						bedwarsStore.TPString = splitted[1]..'/'..(splitted[2] + bedwarsStore.statistics.kills)..'/'..(splitted[3] + bedwarsStore.statistics.beds)..'/'..(splitted[4] + (victorysaid and 1 or 0))..'/'..(splitted[5] + 1)..'/'..(splitted[6] + bedwarsStore.statistics.lagbacks)..'/'..(splitted[7] + bedwarsStore.statistics.universalLagbacks)..'/'..(splitted[8] + bedwarsStore.statistics.reported)
					until not overlayenabled
				end)
			else
				for i, v in next, (overlayconnections) do 
					if v.Disconnect then pcall(function() v:Disconnect() end) continue end
					if v.disconnect then pcall(function() v:disconnect() end) continue end
				end
				table.clear(overlayconnections)
			end
		end, 
		Priority = 2
	})
end)

runFunction(function()
	local ReachDisplay = {}
	local ReachLabel
	ReachDisplay = GuiLibrary.CreateLegitModule({
		Name = 'Reach Display',
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat
						task.wait(0.4)
						ReachLabel.Text = bedwarsStore.attackReachUpdate > tick() and bedwarsStore.attackReach..' studs' or '0.00 studs'
					until (not ReachDisplay.Enabled)
				end)
			end
		end
	})
	ReachLabel = Instance.new('TextLabel')
	ReachLabel.Size = UDim2.new(0, 100, 0, 41)
	ReachLabel.BackgroundTransparency = 0.5
	ReachLabel.TextSize = 15
	ReachLabel.Font = Enum.Font.Gotham
	ReachLabel.Text = '0.00 studs'
	ReachLabel.TextColor3 = Color3.new(1, 1, 1)
	ReachLabel.BackgroundColor3 = Color3.new()
	ReachLabel.Parent = ReachDisplay.GetCustomChildren()
	local ReachCorner = Instance.new('UICorner')
	ReachCorner.CornerRadius = UDim.new(0, 4)
	ReachCorner.Parent = ReachLabel
end)

task.spawn(function()
	local function createannouncement(announcetab)
		local vapenotifframe = Instance.new('TextButton')
		vapenotifframe.AnchorPoint = Vector2.new(0.5, 0)
		vapenotifframe.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
		vapenotifframe.Size = UDim2.new(1, -10, 0, 50)
		vapenotifframe.Position = UDim2.new(0.5, 0, 0, -100)
		vapenotifframe.AutoButtonColor = false
		vapenotifframe.Text = ''
		vapenotifframe.Parent = shared.GuiLibrary.MainGui
		local vapenotifframecorner = Instance.new('UICorner')
		vapenotifframecorner.CornerRadius = UDim.new(0, 256)
		vapenotifframecorner.Parent = vapenotifframe
		local vapeicon = Instance.new('Frame')
		vapeicon.Size = UDim2.new(0, 40, 0, 40)
		vapeicon.Position = UDim2.new(0, 5, 0, 5)
		vapeicon.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
		vapeicon.Parent = vapenotifframe
		local vapeiconicon = Instance.new('ImageLabel')
		vapeiconicon.BackgroundTransparency = 1
		vapeiconicon.Size = UDim2.new(1, -10, 1, -10)
		vapeiconicon.AnchorPoint = Vector2.new(0.5, 0.5)
		vapeiconicon.Position = UDim2.new(0.5, 0, 0.5, 0)
		vapeiconicon.Image = getcustomasset('vape/assets/VapeIcon.png')
		vapeiconicon.Parent = vapeicon
		local vapeiconcorner = Instance.new('UICorner')
		vapeiconcorner.CornerRadius = UDim.new(0, 256)
		vapeiconcorner.Parent = vapeicon
		local vapetext = Instance.new('TextLabel')
		vapetext.Size = UDim2.new(1, -55, 1, -10)
		vapetext.Position = UDim2.new(0, 50, 0, 5)
		vapetext.BackgroundTransparency = 1
		vapetext.TextScaled = true
		vapetext.RichText = true
		vapetext.Font = Enum.Font.Ubuntu
		vapetext.Text = announcetab.Text
		vapetext.TextColor3 = Color3.new(1, 1, 1)
		vapetext.TextXAlignment = Enum.TextXAlignment.Left
		vapetext.Parent = vapenotifframe
		tweenService:Create(vapenotifframe, TweenInfo.new(0.3), {Position = UDim2.new(0.5, 0, 0, 5)}):Play()
		local sound = Instance.new('Sound')
		sound.PlayOnRemove = true
		sound.SoundId = 'rbxassetid://6732495464'
		sound.Parent = workspace
		sound:Destroy()
		vapenotifframe.MouseButton1Click:Connect(function()
			local sound = Instance.new('Sound')
			sound.PlayOnRemove = true
			sound.SoundId = 'rbxassetid://6732690176'
			sound.Parent = workspace
			sound:Destroy()
			vapenotifframe:Destroy()
		end)
		game:GetService('Debris'):AddItem(vapenotifframe, announcetab.Time or 20)
	end

	local function rundata(datatab, olddatatab)
		if not olddatatab then
			if datatab.Disabled then 
				coroutine.resume(coroutine.create(function()
					repeat task.wait() until shared.VapeFullyLoaded
					task.wait(1)
					GuiLibrary.SelfDestruct()
				end))
				game:GetService('StarterGui'):SetCore('SendNotification', {
					Title = 'Vape',
					Text = 'Vape is currently disabled, please use vape later.',
					Duration = 30,
				})
			end
			if datatab.KickUsers and datatab.KickUsers[tostring(lplr.UserId)] then
				lplr:Kick(datatab.KickUsers[tostring(lplr.UserId)])
			end
		else
			if datatab.Disabled then 
				coroutine.resume(coroutine.create(function()
					repeat task.wait() until shared.VapeFullyLoaded
					task.wait(1)
					GuiLibrary.SelfDestruct()
				end))
				game:GetService('StarterGui'):SetCore('SendNotification', {
					Title = 'Vape',
					Text = 'Vape is currently disabled, please use vape later.',
					Duration = 30,
				})
			end
			if datatab.KickUsers and datatab.KickUsers[tostring(lplr.UserId)] then
				lplr:Kick(datatab.KickUsers[tostring(lplr.UserId)])
			end
			if datatab.Announcement and datatab.Announcement.ExpireTime >= os.time() and (datatab.Announcement.ExpireTime ~= olddatatab.Announcement.ExpireTime or datatab.Announcement.Text ~= olddatatab.Announcement.Text) then 
				task.spawn(function()
					createannouncement(datatab.Announcement)
				end)
			end	
		end
	end
	task.spawn(function()
		pcall(function()
			if (inputService.TouchEnabled or inputService:GetPlatform() == Enum.Platform.UWP) and lplr.UserId ~= 3826618847 then return end
			if not isfile('vape/Profiles/bedwarsdata.txt') then 
				local commit = 'main'
				for i,v in next, (game:HttpGet('https://github.com/skiddinglua/NewVapeUnpatched4Roblox'):split('\n')) do 
					if v:find('commit') and v:find('fragment') then 
						local str = v:split('/')[5]
						commit = str:sub(0, str:find('\'') - 1)
						break
					end
				end
				writefile('vape/Profiles/bedwarsdata.txt', game:HttpGet('https://raw.githubusercontent.com/skiddinglua/NewVapeUnpatched4Roblox/'..commit..'/CustomModules/bedwarsdata', true))
			end
			local olddata = readfile('vape/Profiles/bedwarsdata.txt')

			repeat
				local commit = 'main'
				for i,v in next, (game:HttpGet('https://github.com/skiddinglua/NewVapeUnpatched4Roblox'):split('\n')) do 
					if v:find('commit') and v:find('fragment') then 
						local str = v:split('/')[5]
						commit = str:sub(0, str:find('\'') - 1)
						break
					end
				end
				
				local newdata = game:HttpGet('https://raw.githubusercontent.com/skiddinglua/NewVapeUnpatched4Roblox/'..commit..'/CustomModules/bedwarsdata', true)
				if newdata ~= olddata then 
					rundata(game:GetService('HttpService'):JSONDecode(newdata), game:GetService('HttpService'):JSONDecode(olddata))
					olddata = newdata
					writefile('vape/Profiles/bedwarsdata.txt', newdata)
				end

				task.wait(10)
			until not vapeInjected
		end)
	end)
end)

task.spawn(function()
	repeat task.wait() until shared.VapeFullyLoaded
	if not AutoLeave.Enabled then 
		AutoLeave.ToggleButton(false)
	end
end)

--[===[
			                                                  $$\                     $$\ 
			                                                  $$ |                    $$ |
			 $$$$$$$\  $$$$$$$\  $$$$$$\ $$\   $$\  $$$$$$\ $$$$$$\    $$$$$$\   $$$$$$$ |
			$$  _____|$$  _____|$$  __$$\\$$\ $$  |$$  __$$\\_$$  _|  $$  __$$\ $$  __$$ |
			\$$$$$$\  $$ /      $$ |  \__|\$$$$  / $$ /  $$ | $$ |    $$$$$$$$ |$$ /  $$ |
			 \____$$\ $$ |      $$ |      $$  $$<  $$ |  $$ | $$ |$$\ $$   ____|$$ |  $$ |
			$$$$$$$  |\$$$$$$$\ $$ |     $$  /\$$\ $$$$$$$  | \$$$$  |\$$$$$$$\ \$$$$$$$ |
			\_______/  \_______|\__|     \__/  \__|$$  ____/   \____/  \_______| \_______|
			                                       $$ |                                   
			                                       $$ |                                   
			                                       \__|                                   
]===]

GuiLibrary.RemoveObject('PanicOptionsButton')
GuiLibrary.RemoveObject('MissileTPOptionsButton')
GuiLibrary.RemoveObject('SwimOptionsButton')
GuiLibrary.RemoveObject('FullbrightOptionsButton')
--GuiLibrary.RemoveObject('AutoRelicOptionsButton')
GuiLibrary.RemoveObject('XrayOptionsButton')
GuiLibrary.RemoveObject('SchematicaOptionsButton')
--GuiLibrary.RemoveObject('FirewallBypassOptionsButton')

local OldGetService = game.GetService
getgenv().getService = newcclosure(function(s : String) -- for bypassing weaktable detections (bedwars doesn't have these)
	return cloneref(OldGetService(game, s)) -- no namecall because yes
end)

-- why doesn't xylex localize this
local coreGui = getService('CoreGui')
local starterGui = getService('StarterGui')
local httpService = getService('HttpService')
local statsService = getService('Stats')
local inputManager = getService('VirtualInputManager')
local guiService = getService('GuiService')

local localMouse = lplr:GetMouse()
local singleWarning
do
	local warningCache = {}
	singleWarning = function(title : String, text : String, delay : Number, ...)
		if warningCache[title..text] then
			return nil
		end
		warningCache[title..text] = true
		return warningNotification(title, text, delay, ...)
	end
end

local exceptionHandler = {}
do
	function exceptionHandler.throw(Self : Table, Exception : String)
		local exception = `Exception: {Exception or 'Unknown'}\nTraceback: {debug.traceback()}\n`
		setclipboard(exception)
		return singleWarning('Please send this to scrxpted\nexception copied to clipboard', exception, 60)
	end
end

local useAbility
do
	local networkingEvents = replicatedStorageService:FindFirstChild('events-@easy-games/game-core:shared/game-core-networking@getEvents.Events', true)
	local useAbilityRemote = networkingEvents.useAbility
	useAbility = function(ability : String, ...)
		useAbilityRemote:FireServer(ability, ...)
	end
	table.insert(vapeConnections, networkingEvents.abilityUsed.OnClientEvent:Connect(function(...)
		vapeEvents.abilityUsed:Fire(...)
	end))
end

local GuiHandler = {}
do
	local GuiPositions = {}
	local DraggableGuis = {}
	--pistonware reference
	local SavePath = string.format('vape/Profiles/%sPistonwareGUIPositions.json', shared.CustomSaveVape or game.PlaceId)

	function GuiHandler.Save()
		writefile(SavePath, httpService:JSONEncode(GuiPositions))
	end

	function GuiHandler.Get(Tag : String)
		if isfile(SavePath) then
			GuiPositions = httpService:JSONDecode(readfile(SavePath))
		end
		local Tagged = GuiPositions[Tag]
		if Tagged then
			return UDim2.new(Tagged.XS, Tagged.XO or 0, Tagged.YS, Tagged.YO or 0)
		end
	end

	local SaveAsync = false
	task.spawn(function()
		repeat
			task.wait()
		until shared.VapeFullyLoaded
		for _, obj in next, (DraggableGuis) do
			local position = GuiHandler.Get(obj.Tag)
			if position then
				obj.Gui.Position = position
			end
		end
		if SaveAsync then
			SaveAsync = false
			GuiHandler.Save()
		end
	end)

	local getScreenResolution = guiService.getScreenResolution
	function GuiHandler.dragGui(gui : Instance, touchGui : Instance | Nil, checkFunc : Function | Nil, Tag : String)
		touchGui = touchGui or gui
		table.insert(DraggableGuis, { Tag = Tag, Gui = gui })
		local dragging
		local dragInput
		local dragStart = Vector3.zero
		local startPos
		local function update(input)
			local delta = input.Position - dragStart
			local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (delta.X * (1 / GuiLibrary.MainRescale.Scale)), startPos.Y.Scale, startPos.Y.Offset + (delta.Y * (1 / GuiLibrary.MainRescale.Scale)))
			tweenService:Create(gui, TweenInfo.new(0.20), {Position = Position}):Play()
			local RefTable = GuiPositions[Tag]
			if RefTable == nil then
				RefTable = {}
				GuiPositions[Tag] = RefTable
			end
			RefTable.XS = getScreenResolution(guiService) / gui.AbsolutePosition.X
			RefTable.YS = getScreenResolution(guiService) / gui.AbsolutePosition.Y
			if shared.VapeFullyLoaded then
				GuiHandler.Save()
			else
				SaveAsync = true
			end
		end
		local guiConnections = {}
		if gui ~= touchGui then
			table.insert(guiConnections, gui.InputBegan:Connect(function(input)
				if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
					dragStart = input.Position
					local delta = (dragStart - Vector3.new(gui.AbsolutePosition.X, gui.AbsolutePosition.Y, 0)) * (1 / GuiLibrary.MainRescale.Scale)
					if delta.Y <= 40 then
						dragging = GuiLibrary.MainGui.ScaledGui.ClickGui.Visible
						startPos = gui.Position
						
						table.insert(guiConnections, input.Changed:Connect(function()
							if input.UserInputState == Enum.UserInputState.End then
								dragging = false
							end
						end))
					end
				end
			end))
			table.insert(guiConnections, gui.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					dragInput = input
				end
			end))
		end
		table.insert(guiConnections, touchGui.InputBegan:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
				dragStart = input.Position
				local delta = (dragStart - Vector3.new(gui.AbsolutePosition.X, gui.AbsolutePosition.Y, 0)) * (1 / GuiLibrary.MainRescale.Scale)
				if delta.Y <= 40 then
					dragging = GuiLibrary.MainGui.ScaledGui.ClickGui.Visible
					startPos = gui.Position
					
					table.insert(guiConnections, input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
						end
					end))
				end
			end
		end))
		table.insert(guiConnections, touchGui.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end))
		table.insert(guiConnections, inputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging and (checkFunc and checkFunc() or checkFunc == nil) then
				update(input)
			end
		end))
		if shared.VapeFullyLoaded then
			local position = GuiHandler.Get(Tag)
			if position then
				gui.Position = position
			end
		end
		for i, v in next, guiConnections do -- in case you don't insert the result into a connection handler
			table.insert(vapeConnections, v)
		end
		local _return = { -- for vape's uninject system
			Disconnect = function(self, ...)
				for i, v in next, guiConnections do
					v:Disconnect()
				end
				table.clear(guiConnections)
				table.clear(_return)
			end
		}
		return _return
	end
end

MessageHandler = {MessageCache = {}} -- localized on line 27
do
	local success, frame = pcall(function() return coreGui.ExperienceChat.appLayout.chatWindow.scrollingView.bottomLockedScrollView.RCTScrollView.RCTScrollContentView end)
	if not (success and frame) then
		task.spawn(function()
			repeat
				task.wait(0.1)
				success, frame = pcall(function() return coreGui.ExperienceChat.appLayout.chatWindow.scrollingView.bottomLockedScrollView.RCTScrollView.RCTScrollContentView end)
			until success and frame
			MessageHandler.ChatMessageFrame = frame
		end)
	end
	MessageHandler.ChatMessageFrame = frame

	function MessageHandler:register(message : String) : Boolean
		local started = tick()
		local connection
		local found
		connection = MessageHandler.ChatMessageFrame.ChildAdded:Connect(function(object)
			local fixed = object.Name:gsub('$%d+-', '')
			if fixed == message.MessageId and object.Text == message.Text then
				connection:Disconnect()
				found = object
			end
		end)
		for i, v in next, (MessageHandler.ChatMessageFrame:GetChildren()) do
			local fixed = v.Name:gsub('$%d+-', '')
			if fixed == message.MessageId and v.Text == message.Text then
				found = found or v
				break
			end
		end
		repeat
			task.wait(0.1)
		until found or (tick() - started) > 5
		return found
	end

	function MessageHandler:sanitize(text : String) : String
		return text:gsub('%W+', ''):lower()
	end

	function MessageHandler:format(text : String) : Table
		text = text:split('font')
		local isWhisper = text[1]:find('From') ~= nil or text[1]:find('To') ~= nil
		return {
			isWhisper = isWhisper,
			text = text[#text]
		}
	end

	function MessageHandler:scan(text : String, find : Boolean | Nil) : Table
		local list = {}
		if not MessageHandler.ChatMessageFrame then
			exceptionHandler:throw('MessageHandler.ChatMessageFrame not found')
			return list
		end
		for i, v in next, (MessageHandler.ChatMessageFrame:GetChildren()) do
			if v:IsA('TextLabel') then
				local formatted = MessageHandler:format(v.Text).text
				if formatted == text or (find and formatted:find(text)) then
					local msgInfo = MessageHandler:format(text)
					table.insert(list, {
						Name = v.Name,
						Object = v,
						isWhisper = msgInfo.isWhisper,
						Text = msgInfo.text
					})
				end
			end
		end
		return list
	end

	function MessageHandler:remove(id : String) : Boolean
		if MessageHandler.MessageCache[id] then
			MessageHandler.MessageCache[id].Visible = false
			MessageHandler.MessageCache[id] = nil
			return true
		end
		return false
	end

	local hashes = {}
	function MessageHandler:publish(text : String, id : String, NoCounter : Boolean) : Instance | Boolean
		MessageHandler:remove(id)
		local channel = textChatService.ChatInputBarConfiguration.TargetTextChannel
		if channel == nil then
			return false
		end
		if hashes[id] == nil then
			hashes[id] = 0
		end
		hashes[id] += 1
		local message = channel:DisplaySystemMessage(text..(NoCounter and '' or ' [x'..hashes[id]..']'))
		if message then
			local found = MessageHandler:register(message)
			if found then
				MessageHandler.MessageCache[id] = found
				return found
			end
		end
		exceptionHandler:throw(`MessageHandler:publish({text}) failed`)
		return false
	end
end

local DataPing = statsService:FindFirstChild('Data Ping', true)
local function getPing()
	DataPing = DataPing or statsService:FindFirstChild('Data Ping', true)
	local PingValue = DataPing and DataPing:GetValueString() and DataPing:GetValueString():split('.')[1]
	
	if PingValue and PingValue:match('%d+$') then
		return tonumber(PingValue)
	end
	return math.round(statsService.PerformanceStats.Ping:GetValue())
end

local pinglist = {}

function getAveragePing(deviation)
	local currentpingcheck = pinglist[1] or getPing()
	local counted = 1
	for i, v in next, pinglist do
		if i ~= 1 then
			if math.abs(v - currentpingcheck) <= deviation then
				currentpingcheck += v
				counted += 1
			end
		end
	end
	return currentpingcheck
end

local function didpingspike(max)
	max = max or 100
	local currentpingcheck = pinglist[1] or getPing()
	for i,v in next, pinglist do 
		if v ~= currentpingcheck and math.abs(v - currentpingcheck) >= max then 
			return currentpingcheck..' => '..v..' ping'
		else
			currentpingcheck = v
		end
	end
	return nil
end

local pinglist2 = {}
local function didpingspike2(max)
	max = max or 100
	local currentpingcheck = pinglist2[1] or getPing()
	for i,v in next, pinglist2 do 
		if v ~= currentpingcheck and math.abs(v - currentpingcheck) >= max then 
			if v == 999999 then
				table.clear(pinglist2)
			end
			return currentpingcheck..' => '..v..' ping'
		else
			currentpingcheck = v
		end
	end
	return nil
end

local realregionremote = bedwars.ClientHandler:Get('FetchServerRegion').instance
task.spawn(function()
	repeat
		task.wait(0.2)
		if #pinglist2 >= 10 then 
			table.remove(pinglist2, 1)
		end
		local _tick = tick()
		local result
		task.spawn(function()
			result = realregionremote:InvokeServer()
		end)
		repeat
			task.wait()
			if result then
				result = tick() - _tick
				break
			end
		until (tick() - _tick) > 1 -- hard coded for now...
		result = result or 999999
		table.insert(pinglist2, result)
		bedwarsStore.pingSpiking = didpingspike2(300)
	until not vapeInjected
end)
	
task.spawn(function()
	repeat
		task.wait(0.03)
		if #pinglist >= 10 then 
			table.remove(pinglist, 1)
		end
		table.insert(pinglist, getPing())
	until not vapeInjected
end)


local allowedTeleports = 0
local allowedTeleportTick = tick()

local xzFix = Vector3.new(1, 0, 1)
local function fixVec(vec)
	return vec * xzFix
end

local function notlasso()
	for i, v in next, collectionService:GetTagged('LassoHooked') do 
		if v == lplr.Character then 
			return false
		end
	end
	return true
end

table.insert(vapeConnections, bedwars.ClientHandler:OnEvent('ProjectileImpact', function(p3)
	if not vapeInjected then return end
	if p3.projectile == 'telepearl' and p3.shooterPlayer == lplr then 
		allowedTeleports += 1
	elseif p3.projectile == 'swap_ball' then
		if p3.hitEntity then
			if p3.shooterPlayer == lplr then
				allowedTeleports += 1
			end
			local plr = playersService:GetPlayerFromCharacter(p3.hitEntity)
			if plr == lplr then allowedTeleports += 1 end
		end
	end
end))

table.insert(vapeConnections, replicatedStorageService['events-@easy-games/game-core:shared/game-core-networking@getEvents.Events'].abilityUsed.OnClientEvent:Connect(function(char, ability)
	if ability == 'recall' or ability == 'hatter_teleport' or ability == 'spirit_assassin_teleport' or ability == 'hannah_execute' then 
		local player = playersService:GetPlayerFromCharacter(char)
		if player == lplr then
			if ability == 'recall' then
				allowedTeleportTick = tick() + 12
			else
				allowedTeleports += 1
			end
		end
	end
end))

table.insert(vapeConnections, vapeEvents.TweenTeleport.Event:Connect(function(data)
	if data.player == lplr then 
		allowedTeleports += 1
	end
end))

table.insert(vapeConnections, vapeEvents.HannahTeleport.Event:Connect(function(data)
	allowedTeleports += 1
end))

table.insert(vapeConnections, lplr:GetAttributeChangedSignal('LastTeleported'):Connect(function()
	if not vapeInjected then return end
	if notlasso() then
		local allowed = false
		for i = 1, 7 do
			task.wait(0.1)
			if (bedwarsStore.matchStateChanged > tick()) or (math.abs(lplr:GetAttribute('SpawnTime') - lplr:GetAttribute('LastTeleported')) < 3) or (allowedTeleportTick > tick()) then allowed = true break end
		end
		if not allowed then
			if (allowedTeleports > 0) then return end
			local pingspike = didpingspike2(200)
			if pingspike then
				warningNotification('Anticheat', 'Lagspike detected\n'..pingspike, 5)
			end
			warningNotification('Anticheat', 'Lagback detected', 5)
			networkownerswitch = tick() + 3
		end
		if allowedTeleports > 0 then
			allowedTeleports -= 1
		end
	end
end))

isnetworkowner = function(part)
	if part and ((part == oldcloneroot) or (part == vapeOriginalRoot) or (entityLibrary.isAlive and part == entityLibrary.character.HumanoidRootPart)) then
		return networkownerswitch <= tick()
	else
		return false
	end
end

local fakesword = {
	sword = {
		damage = 0.00001,
		attackSpeed = 0.00001
	}
}
local function getStrength2(plr : Player, prediction : Boolean)
	local inv = bedwars.getInventory(plr)
	local health = plr.Character:GetAttribute('Health') or 150 + getShieldAttribute(plr.Character)
	local armor = 0
	local damage = 0
	if inv then
		for i,v in next, inv.items do 
			local itemmeta = bedwars.ItemTable[v.itemType]
			if itemmeta and itemmeta.sword then
				local predictedDamage = prediction and (itemmeta.sword.damage / itemmeta.sword.attackSpeed) or itemmeta.sword.damage
				if predictedDamage > damage then
					damage = predictedDamage
					sword = itemmeta
				end
			end	
		end
		for i,v in next, inv.armor do
			local itemmeta = bedwars.ItemTable[v.itemType]
			if itemmeta and itemmeta.armor then 
				armor += (itemmeta.armor.damageReductionMultiplier or 0)
			end
		end
	end
	sword = sword or fakesword
	return armor, sword, health
end

local function calculateHits(plr : Entity, prediction : Boolean)
	local armor, sword, health = getStrength2(lplr, prediction)
	local _armor, _sword, _health = getStrength2(plr, prediction)
	local hits = math.ceil(_health / (sword.sword.damage * (1 - _armor))) * (prediction and sword.sword.attackSpeed or 1)
	local _hits = math.ceil(health / (_sword.sword.damage * (1 - armor))) * (prediction and _sword.sword.attackSpeed or 1)
	return hits < _hits, hits, _hits
end

local Colorize = {}
do
	function Colorize:set(hex : String)
		return '<font color="#'..hex..'"></font>'
	end
	
	function Colorize:embed(hex : String, ...)
		local embeds = {...}
		for i, v in next, embeds do
			embeds[i] = tostring(v)
		end
		return '<font color="#'..hex..'">'..table.concat(embeds, ' ')..'</font>'
	end
end

runFunction(function()
	local ChatMover = {Enabled = false}
	local chatApp
	local oldChatPosition

	ChatMover = GuiLibrary.ObjectsThatCanBeSaved.NewVapeWindow.Api.CreateOptionsButton({
		Name = 'ChatMover',
		Function = function(callback)
			if callback then
				task.spawn(function()
					if chatApp == nil then
						chatApp = coreGui:WaitForChild('ExperienceChat'):WaitForChild('appLayout')
						local chatWindowApp = chatWindow
						oldChatPosition = chatApp.Position
						GuiHandler.dragGui(chatApp, chatWindowApp, function() return ChatMover.Enabled end, 'NewChatApp')
					end
				end)
			else
				if chatApp then
					chatApp.Position = oldChatPosition or UDim2.new(0, 8, 0, 4)
					oldChatPosition = nil
				end
			end
		end
	})
end)

runFunction(function()
	local InvisNoCollide = {Enabled = false}
	local partslist = {}

	local InvisAnims = {
		--HANNAH_JUMP_DOWN = 'rbxassetid://10725339583', -- HANNAH_JUMP_DOWN [PATCHED]
		CLETUS_BOSS_SPAWN = 'rbxassetid://11198021943', -- CLETUS_BOSS_SPAWN
		SKELETON_SPAWN = 'rbxassetid://11330409797', -- SKELETON_SPAWN
		HALLOWEEN_BOSS_SPAWN = 'rbxassetid://11335949902',  -- HALLOWEEN_BOSS_SPAWN
	}

	local animsinvis = {}
	for i,v in next, InvisAnims do
		animsinvis[#animsinvis+1] = i
	end

	local InvisMethod = {Value = 'HALLOWEEN_BOSS_SPAWN'}
	local newSize = 3

	local function setCollisions(character, state)
		if state then
			RunLoops:UnbindFromStepped('InvisPhase')
			if entityLibrary.isAlive then
				for i, v in next, partslist do
					v.CanCollide = true
					v.CanTouch = true
				end
				table.clear(partslist)
				character.HumanoidRootPart.Size = Vector3.new(1.9, 2, 1)
				character.HumanoidRootPart.Transparency = 1
				character.Humanoid.CameraOffset = Vector3.new(0, 0, 0)
			end
		else
			RunLoops:BindToStepped('InvisPhase', function()
				for _, part in next, character:GetDescendants() do
					if part:IsA('BasePart') and part ~= character.PrimaryPart and part.CanCollide then
						part.CanCollide = false
						part.CanTouch = false
						table.insert(partslist, part)
					end
				end
				character.Humanoid.CameraOffset = Vector3.new(0, newSize / -2, 0)
			end)
			character.HumanoidRootPart.Transparency = 0.8
			character.HumanoidRootPart.Size = Vector3.new(2, newSize, 1.1)
		end
	end

	local function invisibility(char)
		if not entityLibrary.isAlive then return nil end
		local animator = char.Humanoid:WaitForChild('Animator', 5)
		local function playAnim(id)
			local anim = Instance.new('Animation', char)
			anim.AnimationId = id
			return animator:LoadAnimation(anim)
		end
		local anim = playAnim(InvisAnims[InvisMethod.Value])
		anim.Priority = Enum.AnimationPriority.Action4
		setCollisions(lplr.Character, false)
		repeat
			if not anim.IsPlaying then
				anim:Play(1 / 999999, 999999, 1 / 999999)
			end
			task.wait(1)
		until not Invis.Enabled or not entityLibrary.isAlive
		if anim then
			anim.Looped = false
			anim:AdjustSpeed(9999)
			local c
			c = anim.Ended:Connect(function()
				c:Disconnect()
				anim:Destroy()
			end)
		end
		if lplr.Character then
			setCollisions(lplr.Character, true)
		end
	end
	Invis = GuiLibrary.ObjectsThatCanBeSaved.NewVapeWindow.Api.CreateOptionsButton({
		Name = 'Invis',
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until bedwarsStore.matchState ~= 0
					local oldchar
					table.insert(Invis.Connections, lplr.CharacterAdded:Connect(function(char)
						task.wait(1)
						char:WaitForChild('Humanoid', 5):WaitForChild('Animator', 5)
						invisibility(char)
					end))
					if lplr.Character then
						task.wait(1)
						lplr.Character:WaitForChild('Humanoid', 5):WaitForChild('Animator', 5)
						invisibility(lplr.Character)
					end
				end)
			end
		end
	})
	InvisMethod = Invis.CreateDropdown({
		Name = 'Method',
		List = animsinvis,
		Function = function() end,
		Default = 'HALLOWEEN_BOSS_SPAWN'
	})
end)

runFunction(function()
	local Teleport = {Enabled = false}
	local TeleportMethod = {Value = 'Redirect'}
	local TeleportMode = {Value = 'Bed'}
	local TeleportPlayerSort = {Value = 'Distance'}
	local TeleportSpeed = {Value = 800}

	local function getNearestBed(Self : Boolean, overridepos : Vector3)
		local bed, distance = nil, math.huge
		if entityLibrary.isAlive then
			for i, obj in next, collectionService:GetTagged('bed') do
				if obj.Parent ~= nil then
					if bedwars.BlockController:isBlockBreakable({blockPosition = obj.Position / 3}, lplr) then
						local mag = (overridepos or entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position).magnitude
						if mag < distance then
							bed = obj
							distance = mag
						end
					else
						if Self then
							bed = obj
							distance = -1
							break
						end
					end
				end
			end
		end
		return bed
	end

	local function calculateTime(Distance : Number, Speed : Number)
		return Distance / Speed
	end

	local function safeTeleport(position)
		return not (getPlacedBlock(position) and getPlacedBlock(position + Vector3.new(0, 3, 0)))
	end

	local function keepRotations(position)
		local origcf = {entityLibrary.character.HumanoidRootPart.CFrame:GetComponents()}
		origcf[1] = position.X
		origcf[2] = position.Y
		origcf[3] = position.Z
		local newcf = CFrame.new(unpack(origcf))
		table.clear(origcf)
		entityLibrary.character.HumanoidRootPart.CFrame = newcf
		return newcf
	end

	local function keepRotations2(y)
		local origcf = {entityLibrary.character.HumanoidRootPart.CFrame:GetComponents()}
		origcf[2] = y
		local newcf = CFrame.new(unpack(origcf))
		table.clear(origcf)
		entityLibrary.character.HumanoidRootPart.CFrame = newcf
		return newcf
	end

	local function rotateTo(position)
		local newcf = CFrame.lookAt(entityLibrary.character.HumanoidRootPart.Position, position)
		entityLibrary.character.HumanoidRootPart.CFrame = newcf
		return newcf
	end

	local projectileRemote = bedwars.ClientHandler:Get(bedwars.ProjectileRemote).instance

	local function pearlTeleport(position)
		local telepearl = getItem('telepearl')
		if telepearl then
			switchItem(telepearl.tool)
			local tag = httpService:GenerateGUID(true)
			local ammo = 'telepearl'
			local launchpos = position + Vector3.new(0, 3, 0)
			local launchvelo = Vector3.new(0, -1, 0)
			task.spawn(function()
				projectileRemote:InvokeServer(telepearl.tool, ammo, ammo, launchpos, launchpos, launchvelo, tag, { drawDurationSeconds = 3, shotId = httpService:GenerateGUID(false)}, workspace:GetServerTimeNow() - 0.045)
				task.wait(0.2)
				local newray = workspace:Raycast(launchpos, Vector3.new(0, -15, 0), bedwarsStore.blockRaycast)
				if newray then
					for i = 1, 3 do
						bedwars.ClientHandler:Get(bedwars.Main.ProjectileHitRemote):SendToServer(tag, newray.Instance)
					end
				end
			end)
			return true
		end
		return false
	end

	local function getStrength(plr)
		local inv = bedwarsStore.inventories[plr.Player]
		local strength = 0
		local strongestsword = 0
		if inv then
			for i, v in next, inv.items do 
				local itemmeta = bedwars.ItemTable[v.itemType]
				if itemmeta and itemmeta.sword and itemmeta.sword.damage > strongestsword then 
					strongestsword = itemmeta.sword.damage / 100
				end	
			end
			strength = strength + strongestsword
			for i, v in next, inv.armor do 
				local itemmeta = bedwars.ItemTable[v.itemType]
				if itemmeta and itemmeta.armor then 
					strength = strength + (itemmeta.armor.damageReductionMultiplier or 0)
				end
			end
			strength = strength
		end
		return strength
	end

	local function getItemWealth(plr)
		local inv = bedwarsStore.inventories[plr.Player]
		local wealth = 0
		if inv then
			for i,v in next, inv.items do 
				if v.itemType == 'emerald' then
					wealth += v.amount * 4
				elseif v.itemType == 'diamond' then
					wealth += v.amount * 2
				elseif v.itemType == 'iron' then
					wealth +=  v.amount
				end
			end
		end
		return wealth
	end

	local function getArmorWealth(plr)
		local inv = bedwarsStore.inventories[plr.Player]
		local wealth = 0
		if inv then
			for i, v in next, inv.armor do 
				local itemmeta = bedwars.ItemTable[v.itemType]
				if itemmeta and itemmeta.armor then 
					wealth += itemmeta.armor.damageReductionMultiplier or 0
				end
			end
		end
		return wealth
	end

	local kitpriolist = {
		hannah = 5,
		spirit_assassin = 4,
		dasher = 3,
		jade = 2,
		regent = 1
	}

	local teleportSortMethods = {
		Distance = function(a, b)
			return (a.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).Magnitude < (b.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).Magnitude
		end,
		Health = function(a, b) 
			return a.Humanoid.Health < b.Humanoid.Health
		end,
		Threat = function(a, b) 
			return getStrength(a) > getStrength(b)
		end,
		Wealth = function(a, b)
			return getItemWealth(a) > getItemWealth(b)
		end,
		Weakest = function(a, b)
			return getStrength(a) < getStrength(b)
		end,
		Kit = function(a, b)
			return (kitpriolist[a.Player:GetAttribute('PlayingAsKit')] or 0) > (kitpriolist[b.Player:GetAttribute('PlayingAsKit')] or 0)
		end,

	}

	local teleportMethods = {
		Redirect = function(position, updatefunc)
			if bedwarsStore.matchState ~= 0 then
				if getNearestBed(true) then
					bedwars.ClientHandler:Get(bedwars.ResetRemote):SendToServer()
				end
			end
			lplr:GetAttributeChangedSignal('LastTeleported'):Wait()
			repeat task.wait() until entityLibrary.isAlive
			-- yes yes yes I loooooove using tweenService - scrxpted
			local newpos = fixVec(entityLibrary.character.HumanoidRootPart.Position)
			local newpos2 = fixVec(updatefunc and updatefunc() or position) + Vector3.new(0, entityLibrary.character.HumanoidRootPart.Position.Y, 0)
			local teleportTween = tweenService:Create(entityLibrary.character.HumanoidRootPart, TweenInfo.new(calculateTime((newpos2 - newpos).Magnitude, TeleportSpeed.Value), Enum.EasingStyle.Sine, Enum.EasingDirection.In), {CFrame = CFrame.new(newpos2)})
			teleportTween:Play()
			local teleportConnection = lplr:GetAttributeChangedSignal('LastTeleported'):Once(function()
				teleportTween:Cancel()
			end)
			teleportTween.Completed:Wait()
			teleportConnection:Disconnect()
			keepRotations2(position.Y)
		end,
		Dao = function(position, updatefunc)
			local item = getItemNear('dao')
			if item then
				position -= Vector3.new(0, 1, 0)
				local rotation = rotateTo(updatefunc and updatefunc() - Vector3.new(0, 1, 0) or position)
				local oldpos = entityLibrary.character.HumanoidRootPart.Position
				useAbility('dash', {
					direction = rotation.lookVector,
					origin = entityLibrary.character.HumanoidRootPart.Position,
					weapon = item.itemType,
				})
				keepRotations(entityLibrary.character.HumanoidRootPart.CFrame, updatefunc and updatefunc() - Vector3.new(0, 1, 0) or position)
				task.wait(0.03)
				if isnetworkowner(entityLibrary.character.HumanoidRootPart) then
					warningNotification('Teleport', `Teleported {(oldpos - entityLibrary.character.HumanoidRootPart.Position).Magnitude} studs`, 10)
				end
			end
		end,
		Jade = function(position, updatefunc)
			if getItem('jade_hammer') then
				position -= Vector3.new(0, 1, 0)
				rotateTo(position)
				local oldpos = entityLibrary.character.HumanoidRootPart.Position
				useAbility('jade_hammer_jump')
				keepRotations(updatefunc and updatefunc() - Vector3.new(0, 1, 0) or position)
				task.wait(0.03)
				if isnetworkowner(entityLibrary.character.HumanoidRootPart) then
					warningNotification('Teleport', `Teleported {(oldpos - entityLibrary.character.HumanoidRootPart.Position).Magnitude} studs`, 10)
				end
			end
		end,
		Telepearl = function(position, updatefunc)
			warningNotification('Teleport', pearlTeleport(updatefunc and updatefunc() or position) and 'Success' or 'No telepearl', 5)
		end
	}

	local teleportModes = {
		Bed = function(selfBed)
			local bed = getNearestBed(false, selfBed and selfBed.Position)
			if bed then
				local newray = bedwars.QueryUtil:raycast(bed.Position + Vector3.new(0, 100, 0), Vector3.new(0, -200, 0), bedwarsStore.blockRaycast)
				if newray then
					return newray.Position
				end
			else
				warningNotification('Teleport', 'no beds found', 5)
			end
		end,
		Click = function(selfBed)
			local rayparams = RaycastParams.new()
			rayparams.FilterDescendantsInstances = {lplr.Character, gameCamera, bedwarsStore.bedwarsBlocks}
			rayparams.RespectCanCollide = true
			local hitposition = localMouse and localMouse.Hit
			if hitposition then
				local newray = bedwars.QueryUtil:raycast(gameCamera.CFrame.p, (hitposition.p - gameCamera.CFrame.p).Unit * 10000, rayparams)
				if newray then
					newray = bedwars.QueryUtil:raycast(newray.Position + Vector3.new(0, 800, 0), Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
					if newray then
						return newray.Position
					end
				end
			elseif inputService.TouchEnabled then
				local newray = bedwars.QueryUtil:raycast(gameCamera.CFrame.p, gameCamera.CFrame.lookVector.Unit * 10000, rayparams)
				if newray then
					newray = bedwars.QueryUtil:raycast(newray.Position + Vector3.new(0, 800, 0), Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
					if newray then
						return newray.Position
					end
				end
			end
		end,
		Player = function(selfBed)
			local plrs = AllNearPosition(999999, 10, teleportSortMethods[TeleportPlayerSort.Value], true, nil, true, false)
			if #plrs > 0 then
				for i, plr in next, (plrs) do
					if plr.Character:GetAttribute('CompletedSetup') then
						if safeTeleport(plr.RootPart.Position) then
							return plr.RootPart.Position
						else
							local newray = bedwars.QueryUtil:raycast(plr.RootPart.Position + Vector3.new(0, 800, 0), Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							if newray then
								return newray.Position, function()
									local newray2 = bedwars.QueryUtil:raycast(plr.RootPart.Position + Vector3.new(0, 800, 0), Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
									return newray2 and newray2.Position or newray.Position
								end
							end
						end
						break
					end
				end
				table.clear(plrs)
			else
				singleWarning('Teleport', 'no players found', 5)
			end
		end
	}

	Teleport = GuiLibrary.ObjectsThatCanBeSaved.NewVapeWindow.Api.CreateOptionsButton({
		Name = 'Teleport',
		Function = function(callback)
			if callback then
				task.spawn(function()
					if entityLibrary.isAlive then
						local selfBed = getNearestBed(true)
						local position, updatefunc = teleportModes[TeleportMode.Value](selfBed)
						if position then
							teleportMethods[TeleportMethod.Value](position, updatefunc)
						end
					end
					Teleport.ToggleButton(false)
				end)
			else
				local movementControls = require(lplr.PlayerScripts.PlayerModule):GetControls()
				movementControls:Enable()
			end
		end
	})
	TeleportSpeed = Teleport.CreateSlider({
		Name = 'Speed',
		Min = 600,
		Max = 1000,
		Default = 800,
		Function = function() end
	})
	local teleportmodes = {}
	for i, v in next, teleportModes do
		table.insert(teleportmodes, i)
	end
	TeleportMode = Teleport.CreateDropdown({
		Name = 'Mode',
		List = teleportmodes,
		Function = function() end
	})
	local teleportmethods = {}
	for i, v in next, teleportMethods do
		table.insert(teleportmethods, i)
	end
	TeleportMethod = Teleport.CreateDropdown({
		Name = 'Method',
		List = teleportmethods,
		Function = function() end
	})
end)

runFunction(function()
	task.wait(0.3)
	local AnticheatBypass = {Enabled = false}
	local AnticheatBypassShowRoot = {Enabled = false}

	local BypassNumbers = {
		Lerp = 0.3,
		Frequency = 0.33,
		TPLowest = 0.05,
		TPPrecise = 20,
		TPRecheck = 20,
		SlowdownDistance = 300,
		Slowdown = 0.7,
	}

	local clonesuccess = false
	local disabledproper = true
	local cloned
	local clone
	local hip
	local predictcloneroot

	local function disablefunc()
		disabledproper = true
		if not vapeOriginalRoot or not vapeOriginalRoot.Parent then return end
		lplr.Character.Parent = game
		entityLibrary.character.HumanoidRootPart:Destroy()
		entityLibrary.character.HumanoidRootPart = vapeOriginalRoot
		vapeOriginalRoot.Parent = lplr.Character
		vapeOriginalRoot.Transparency = 1
		lplr.Character.PrimaryPart = vapeOriginalRoot
		lplr.Character.PrimaryPart.Transparency = 1
		lplr.Character.Parent = workspace
		vapeOriginalRoot.CanCollide = true
		for i,v in next, (lplr.Character:GetDescendants()) do 
			if v:IsA('Weld') or v:IsA('Motor6D') then 
				if v.Part0 == clone then v.Part0 = vapeOriginalRoot end
				if v.Part1 == clone then v.Part1 = vapeOriginalRoot end
			end
			if v:IsA('BodyVelocity') then 
				v:Destroy()
			end
		end
		for i,v in next, (vapeOriginalRoot:GetChildren()) do 
			if v:IsA('BodyVelocity') then 
				v:Destroy()
			end
		end
		local oldclonepos = clone.Position.Y
		if clone then 
			clone:Destroy()
			clone = nil
		end
		if predictcloneroot then
			predictcloneroot:Destroy()
			predictcloneroot = nil
		end
		lplr.Character.Humanoid.HipHeight = hip or 2
		local origcf = {vapeOriginalRoot.CFrame:GetComponents()}
		origcf[2] = oldclonepos
		vapeOriginalRoot.CFrame = CFrame.new(unpack(origcf))
		table.clear(origcf)
		vapeOriginalRoot = nil
	end

	table.insert(vapeConnections, lplr:GetAttributeChangedSignal('LastTeleported'):Connect(function()
		if vapeOriginalRoot and cloned == lplr.Character and clone and math.abs(lplr:GetAttribute('SpawnTime') - lplr:GetAttribute('LastTeleported')) > 3 then
			clone.CFrame = vapeOriginalRoot.CFrame
		end
	end))

	table.insert(vapeConnections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
		if AnticheatBypass.Enabled and deathTable.entityInstance == lplr.Character and not deathTable.finalKill then
			AnticheatBypass.ToggleButton(false)
			repeat task.wait(0.03) until entityLibrary.isAlive and entityLibrary.character.Humanoid.Health > 0 and isnetworkowner(entityLibrary.character.HumanoidRootPart)
			task.wait(0.7)
			if not AnticheatBypass.Enabled then
				AnticheatBypass.ToggleButton(false)
			end
		end
	end))

	local oldseattab = Instance.new('BindableEvent')

	local function check()
		if clone and vapeOriginalRoot and (vapeOriginalRoot.Position - clone.Position).magnitude >= (BypassNumbers.TPRecheck + getSpeed()) and cananticheatbypass then
			clone.CFrame = vapeOriginalRoot.CFrame
		end
	end
	
	local bodyvelo
	local teleportDistance = 0

	local lastMove = tick()
	local function teleportTo(cframe)
		local offset = (cframe.p - vapeOriginalRoot.CFrame.p)
		if offset.magnitude > 0.3 then
			lastMove = tick()
		end
		vapeLookAtPosition = cframe.p
		local lookAt = CFrame.lookAt(vapeOriginalRoot.CFrame.p * Vector3.new(1, 0, 1), cframe.p * Vector3.new(1, 0, 1))
		local newcf
		if lookAt == lookAt then
			newcf = lookAt + Vector3.new(offset.X, cframe.Y, offset.Z)
		else
			newcf = cframe
		end
		vapeOriginalRoot.CFrame = newcf
		vapeLookAtPosition = nil
		teleportDistance += offset.magnitude
	end

	local fpslist = {}
	local function getaverageframerate()
		local frames = 0
		for i,v in next, (fpslist) do 
			frames = frames + v
		end
		return #fpslist > 0 and (frames / (60 * #fpslist)) <= 1.2 or #fpslist <= 0
	end

	local listenerCreated = false
	local attemptedBypass

	local function updateRotations()
		if vapeLookAtPosition then
			local newposition = (killaurarotatey.Enabled and bedwarsStore.matchState ~= 0) and vapeLookAtPosition or Vector3.new(vapeLookAtPosition.X, vapeOriginalRoot.Position.Y, vapeLookAtPosition.Z)
			local newcf = CFrame.lookAt(vapeOriginalRoot.Position, newposition)
			if newcf == newcf then
				vapeOriginalRoot.CFrame = newcf
			end
			return true
		end
	end

	local pausedvelo = false
	AnticheatBypass = GuiLibrary.ObjectsThatCanBeSaved.NewVapeWindow.Api.CreateOptionsButton({
		Name = 'AnticheatAbuse',
		HoverText = 'gives the anticheat ptsd so you don\'t get lagbacked',
		Function = function(callback)
			if callback then
				task.spawn(function()
					if bedwarsStore.matchState == 0 then
						repeat task.wait() until bedwarsStore.matchState ~= 0 or not AnticheatBypass.Enabled
						if not AnticheatBypass.Enabled then
							return
						end
					end
					if not entityLibrary.isAlive then 
						disabledproper = true
					end
					if not disabledproper then 
						warningNotification('AnticheatAbuse', 'Wait until AnticheatBypass finishes', 3)
						AnticheatBypass.ToggleButton(false)
						return
					end
					clonesuccess = false
					if not listenerCreated then
						listenerCreated = true
						task.delay(0.03, function()
							repeat
								if clonesuccess then break end
								if AnticheatBypass.Enabled then
									AnticheatBypass.ToggleButton(false)
								end
								repeat task.wait(0.03) until entityLibrary.isAlive and entityLibrary.character.Humanoid.Health > 0 and isnetworkowner(entityLibrary.character.HumanoidRootPart)
								task.wait(attemptedBypass and attemptedBypass == lplr.Character and 0 or 0.7)
								if not AnticheatBypass.Enabled then
									AnticheatBypass.ToggleButton(false)
								end
							until clonesuccess
							listenerCreated = false
						end)
					end
					attemptedBypass = lplr.Character
					if entityLibrary.isAlive and entityLibrary.character.Humanoid.Health > 0 and isnetworkowner(entityLibrary.character.HumanoidRootPart) then
						cloned = lplr.Character
						vapeOriginalRoot = entityLibrary.character.HumanoidRootPart
						if not lplr.Character.Parent then
							AnticheatBypass.ToggleButton(false)
							return
						end
						lplr.Character.Parent = game
						clone = vapeOriginalRoot:Clone()
						clone.Parent = lplr.Character
						vapeOriginalRoot.Parent = gameCamera
						bedwars.QueryUtil:setQueryIgnored(vapeOriginalRoot, true)
						predictcloneroot = vapeOriginalRoot:Clone()
						predictcloneroot.Color = Color3.fromRGB(222, 173, 247)
						predictcloneroot.Anchored = true
						predictcloneroot.CanCollide = false
						predictcloneroot.CanQuery = false
						predictcloneroot.CanTouch = false
						predictcloneroot.Parent = gameCamera
						if AnticheatBypassShowRoot.Enabled then
							predictcloneroot.Transparency = 0.7
							vapeOriginalRoot.Transparency = 0.7
							vapeOriginalRoot.Color = Color3.new(0.4, 1, 0.4)
						else
							predictcloneroot.Transparency = 1
							vapeOriginalRoot.Transparency = 1
						end
						clone.CFrame = vapeOriginalRoot.CFrame
						lplr.Character.PrimaryPart = clone
						lplr.Character.Parent = workspace
						for i,v in next, (lplr.Character:GetDescendants()) do 
							if v:IsA('Weld') or v:IsA('Motor6D') then 
								if v.Part0 == vapeOriginalRoot then v.Part0 = clone end
								if v.Part1 == vapeOriginalRoot then v.Part1 = clone end
							end
							if v:IsA('BodyVelocity') then 
								v:Destroy()
							end
						end
						for i,v in next, (vapeOriginalRoot:GetChildren()) do 
							if v:IsA('BodyVelocity') then 
								v:Destroy()
							end
						end
						bodyvelo = Instance.new('BodyVelocity')
						bodyvelo.MaxForce = Vector3.new(0, 9e9, 0)
						bodyvelo.Velocity = Vector3.zero
						bodyvelo.Parent = vapeOriginalRoot
						lplr.Character.Humanoid.HipHeight = hip or 2
						hip = lplr.Character.Humanoid.HipHeight
						entityLibrary.character.HumanoidRootPart = clone
						clonesuccess = true
					end
					if not clonesuccess then 
						warningNotification('AnticheatAbuse', 'Character missing', 3)
						AnticheatBypass.ToggleButton(false)
						return
					end
					task.spawn(function()
						table.clear(fpslist)
						repeat
							if not AnticheatBypass.Enabled then break end
							local fps = math.floor(1 / runService.Heartbeat:Wait())
							if #fpslist >= 10 then 
								table.remove(fpslist, 1)
							end
							table.insert(fpslist, fps)
							task.wait(1)
						until not AnticheatBypass.Enabled
					end)
					RunLoops:BindToHeartbeat('AnticheatAbuse', function()
						local root = entityLibrary.isAlive and entityLibrary.character.HumanoidRootPart
						predictcloneroot.Position = vapeOverridePosition or vapeOriginalRoot.Position
						if isnetworkowner(vapeOriginalRoot) and root then
							if GuiLibrary.ObjectsThatCanBeSaved.LongJumpOptionsButton.Enabled then
								if not cananticheatbypass then
									if bodyvelo then
										bodyvelo:Destroy()
										bodyvelo = nil
									end
								end
								updateRotations()
								vapeOriginalRoot.Velocity = root.Velocity
								return
							end
							local sit = entityLibrary.character.Humanoid.Sit
							if sit ~= oldseat then 
								if sit then 
									for i,v in next, (workspace:GetDescendants()) do 
										if not v:IsA('Seat') then continue end
										local weld = v:FindFirstChild('SeatWeld')
										if weld and weld.Part1 == vapeOriginalRoot then 
											weld.Part1 = clone
											pcall(function()
												for i,v in next, (getconnections(v:GetPropertyChangedSignal('Occupant'))) do
													local newfunc = debug.getupvalue(debug.getupvalue(v.Function, 1), 3) 
													debug.setupvalue(newfunc, 4, {
														GetPropertyChangedSignal = function(self, prop)
															return oldseattab.Event
														end
													})
													newfunc()
												end
											end)
										end
									end
								else
									oldseattab:Fire(false)
								end
								oldseat = sit	
							end
							if not cananticheatbypass then
								if bodyvelo then
									bodyvelo:Destroy()
									bodyvelo = nil
								end
								return
							else
								if bodyvelo == nil then
									bodyvelo = Instance.new('BodyVelocity')
									bodyvelo.MaxForce = Vector3.new(0, 9e9, 0)
									bodyvelo.Velocity = Vector3.zero
									bodyvelo.Parent = vapeOriginalRoot
								end
							end
							local targetvelo = root.AssemblyLinearVelocity
							local speed = (sit or bedwars.HangGliderController.hangGliderActive) and targetvelo.Magnitude or (23 + getSpeed())
							targetvelo = (targetvelo.Unit == targetvelo.Unit and targetvelo.Unit or Vector3.zero) * 20
							bodyvelo.Velocity = Vector3.new(0, math.abs(root.Velocity.Y) <= 0.05 and 0 or root.Velocity.Y, 0)
							local alreadyRotated = updateRotations()
							if root.Velocity.Magnitude <= 0.01 then
								vapeOriginalRoot.Velocity = Vector3.zero
							else
								local newvelo = Vector3.new(math.clamp(root.Velocity.X, -speed, speed), root.Velocity.Y, math.clamp(root.Velocity.Z, -speed, speed))
								vapeOriginalRoot.Velocity = newvelo
							end
							if pausedvelo then
								pausedvelo = false
								noSpeed = nil
							end
						else
							if not noSpeed then
								noSpeed = true
								pausedvelo = true
							end
							if bodyvelo then
								bodyvelo.Velocity = Vector3.zero
							end
							root.Velocity = Vector3.zero
							root.AssemblyLinearVelocity = Vector3.zero
							root.AssemblyAngularVelocity = Vector3.zero
							vapeOriginalRoot.Velocity = Vector3.zero
							vapeOriginalRoot.AssemblyLinearVelocity = Vector3.zero
							vapeOriginalRoot.AssemblyAngularVelocity = Vector3.zero
						end
						vapeOriginalRoot.AssemblyAngularVelocity = Vector3.zero
					end)
					task.spawn(function()
						lastMove = tick()
						repeat
							task.wait()
							if entityLibrary.isAlive then
								if isnetworkowner(vapeOriginalRoot) then
									if not entityLibrary.character.Humanoid.Sit then
										if not cananticheatbypass then
											continue
										end
										if NoFlag then
											NoFlag = nil
											clone.CFrame = vapeOriginalRoot.CFrame
											continue
										end
										--[=[if GuiLibrary.ObjectsThatCanBeSaved.LongJumpOptionsButton.Enabled or (NewDisabler.Enabled and NewDisablerSlowdown.Enabled and (bedwarsStore.attackReachUpdate > tick())) then
											vapeOriginalRoot.CFrame = clone.CFrame
											continue
										end]=]
										if (cloned.Humanoid.FloorMaterial ~= Enum.Material.Air or bedwarsStore.disabledFloat) and (teleportDistance >= BypassNumbers.SlowdownDistance) then
											teleportDistance = 0
											noSpeed = true
											warningNotification('AnticheatAbuse', 'slowdown', BypassNumbers.Slowdown)
											task.delay(BypassNumbers.Slowdown, function()
												noSpeed = nil
											end)
										end
										if (tick() - lastMove) > BypassNumbers.Slowdown then
											teleportDistance = 0
										end
										local frameratecheck = getaverageframerate()
										local framerate = frameratecheck and -0.22 or 0
										local framerate2 = frameratecheck and -0.01 or 0
										framerate = math.floor((BypassNumbers.Lerp + framerate) * 100) / 100
										framerate2 = math.floor((((bedwarsStore.attackReachUpdate - 0.8 > tick()) and 0.3 or BypassNumbers.Frequency) + framerate2) * 100) / 100
										local needsfix = false
										for i = 1, 2 do
											check()
											task.wait(i % 2 == 0 and 0.01 or 0.02)
											check()
											if vapeOriginalRoot then
												if (vapeOriginalRoot.CFrame.p - clone.CFrame.p).magnitude >= BypassNumbers.TPLowest then
													local offsety = entityLibrary.character.HumanoidRootPart.Position.Y - vapeOriginalRoot.Position.Y
													if math.abs(offsety) <= 1 then
														local newcf = vapeOriginalRoot.CFrame:lerp(clone.CFrame + Vector3.new(0, offsety, 0), framerate)
														if not getPlacedBlock(newcf.p) then
															teleportTo(newcf)
														else
															needsfix = true
														end
													else
														local newcf = vapeOriginalRoot.CFrame:lerp(clone.CFrame, framerate)
														if not getPlacedBlock(newcf.p) then
															teleportTo(newcf)
														else
															needsfix = true
														end
													end
												end
											end
										end
										check()
										--[=[task.delay(framerate2 / 2, function()
											if vapeOriginalRoot then
												local offset = (clone.CFrame.p - vapeOriginalRoot.CFrame.p)
												vapeOverridePosition = clone.CFrame.p + offset.Unit * math.min(offset.magnitude, 4)
											end
										end)]=]
										task.wait(framerate2)
										check()
										vapeOverridePosition = nil
										if vapeOriginalRoot then
											local mag = (vapeOriginalRoot.CFrame.p - clone.CFrame.p).magnitude
											if mag >= BypassNumbers.TPLowest and (mag <= BypassNumbers.TPPrecise or needsfix) then
												local offsety = entityLibrary.character.HumanoidRootPart.Position.Y - vapeOriginalRoot.Position.Y
												if math.abs(offsety) <= 1 then
													teleportTo(clone.CFrame + Vector3.new(0, offsety, 0))
												else
													teleportTo(clone.CFrame)
												end
											end
										end
									else
										clone.CFrame = vapeOriginalRoot.CFrame
									end
								else
									if clone and vapeOriginalRoot then
										clone.CFrame = vapeOriginalRoot.CFrame
									end
									teleportDistance = 0
								end
							end
						until not AnticheatBypass.Enabled
					end)
				end)
			else
				RunLoops:UnbindFromHeartbeat('AnticheatAbuse')
				if clonesuccess and vapeOriginalRoot and clone and lplr.Character.Parent == workspace and vapeOriginalRoot.Parent ~= nil and disabledproper and cloned == lplr.Character then 
					local origcf = {clone.CFrame:GetComponents()}
					origcf[1] = vapeOriginalRoot.Position.X
					origcf[2] = vapeOriginalRoot.Position.Y
					origcf[3] = vapeOriginalRoot.Position.Z
					vapeOriginalRoot.CFrame = CFrame.new(unpack(origcf))
					table.clear(origcf)
					entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
					disabledproper = false
					disablefunc()
				end
				vapeOverridePosition = nil
				if pausedvelo then
					pausedvelo = false
					noSpeed = nil
				end
			end
		end
	})
	AnticheatBypass.CreateSlider({
		Name = 'Lerp',
		Min = 0,
		Max = 100,
		Default = BypassNumbers.Lerp * 100,
		Double = 100,
		Function = function(val) BypassNumbers.Lerp = val / 100 end
	})
	AnticheatBypass.CreateSlider({
		Name = 'Frequency',
		Min = 0,
		Max = 100,
		Default = BypassNumbers.Frequency * 100,
		Double = 100,
		Function = function(val) BypassNumbers.Frequency = val / 100 end
	})
	AnticheatBypass.CreateSlider({
		Name = 'Lowest Distance',
		Min = 0.05,
		Max = 23,
		Default = BypassNumbers.TPLowest,
		Function = function(val) BypassNumbers.TPLowest = val end
	})
	AnticheatBypass.CreateSlider({
		Name = 'Precision',
		Min = 0.05,
		Max = 23,
		Default = BypassNumbers.TPPrecise,
		Function = function(val) BypassNumbers.TPPrecise = val end
	})
	AnticheatBypass.CreateSlider({
		Name = 'Recheck',
		Min = 0,
		Max = 23,
		Default = BypassNumbers.TPRecheck,
		Function = function(val) BypassNumbers.TPRecheck = val end
	})
	AnticheatBypass.CreateSlider({
		Name = 'Slowdown Distance',
		Min = 300,
		Max = 600,
		Default = BypassNumbers.SlowdownDistance,
		Function = function(val) BypassNumbers.SlowdownDistance = val end
	})
	AnticheatBypass.CreateSlider({
		Name = 'Slowdown',
		Min = 0,
		Max = 200,
		Default = BypassNumbers.Slowdown * 100,
		Double = 100,
		Function = function(val) BypassNumbers.Slowdown = val / 100 end
	})
	AnticheatBypassShowRoot = AnticheatBypass.CreateToggle({
		Name = 'Show Root',
		Function = function(callback)
			if callback then
				if vapeOriginalRoot then
					vapeOriginalRoot.Transparency = 0.7
					vapeOriginalRoot.Color = Color3.new(0.4, 1, 0.4)
				end
				if predictcloneroot then
					predictcloneroot.Transparency = 0.7
				end
			else
				if vapeOriginalRoot then
					vapeOriginalRoot.Transparency = 1
				end
				if predictcloneroot then
					predictcloneroot.Transparency = 1
				end
			end
		end,
		Default = true
	})
end)

runFunction(function()
	local KeepInventory = {Enabled = false}
	local KeepInventoryLagback = {Enabled = false}

	local enderchest
	local function getEnderchest()
		enderchest = enderchest or replicatedStorageService.Inventories[lplr.Name..'_personal']
		return enderchest
	end

	local GetItem = bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGetItem')
	local GiveItem = bedwars.ClientHandler:GetNamespace('Inventory'):Get('ChestGiveItem')
	local ResetRemote = bedwars.ClientHandler:Get(bedwars.ResetRemote)
	local deposited = false

	local function collectEnderchest()
		if deposited then
			deposited = false
			repeat task.wait() until entityLibrary.isAlive
			lplr.Character:WaitForChild('InventoryFolder', 999999)
			repeat task.wait() until lplr.Character.InventoryFolder.Value ~= nil
			local enderchest = getEnderchest()
			for _, item in next, enderchest:GetChildren() do
				GetItem:CallServerAsync(enderchest, item)
			end
		end
	end

	local function depositAndWaitForRespawn(yield)
		if not deposited then
			deposited = true
			local inventory = lplr.Character:FindFirstChild('InventoryFolder')
			if inventory then 
				inventory = inventory.Value
				local enderchest = getEnderchest()
				local count = 0
				for _, item in next, inventory:GetChildren() do
					task.spawn(function()
						GiveItem:CallServer(enderchest, item)
						count -= 1
					end)
					count = count + 1
				end
				if yield then
					repeat task.wait() until count <= 0
				end
				lplr.CharacterAdded:Once(collectEnderchest)
			end
		end
	end

	local resetCallback = Instance.new('BindableEvent')
	resetCallback.Event:Connect(function()
		warningNotification('KeepInventory', 'Resetting, storing items', 5)
		depositAndWaitForRespawn(true)
		ResetRemote:SendToServer()
	end)

	KeepInventory = GuiLibrary.ObjectsThatCanBeSaved.NewVapeWindow.Api.CreateOptionsButton({
		Name = 'KeepInventory',
		Function = function(callback)
			if callback then
				starterGui:SetCore('ResetButtonCallback', resetCallback)
				if KeepInventoryLagback.Enabled then
					task.spawn(function()
						repeat
							task.wait(0.1)
							if entityLibrary.isAlive then
								if not isnetworkowner(entityLibrary.character.HumanoidRootPart) and bedwarsStore.queueType:find('skywars') == nil then
									if not deposited then
										warningNotification('KeepInventory', 'Lagback detected, storing items', 5)
										task.spawn(function()
											local suc, res = pcall(function() return lplr.leaderstats.Bed.Value == '✅'  end)
											repeat task.wait() until not KeepInventory.Enabled or (isnetworkowner(entityLibrary.character.HumanoidRootPart) and suc and res) or (suc and res == nil)
											if entityLibrary.isAlive then
												collectEnderchest()
											end
										end)
									end
									depositAndWaitForRespawn(true)
								end
							end
						until not (KeepInventory and KeepInventoryLagback.Enabled)
					end)
				end
				table.insert(KeepInventory.Connections, vapeEvents.EntityDamageEvent.Event:Connect(function(damageTable)
					if damageTable.entityInstance == lplr.Character and damageTable.fromEntity and damageTable.damage and bedwarsStore.queueType:find('skywars') == nil then
						local plr = playersService:GetPlayerFromCharacter(damageTable.fromEntity)
						local health = lplr.Character:GetAttribute('Health') or 150
						local stash = (health / damageTable.damage) <= 2
						if plr then
							local winning, hits, _hits = calculateHits(plr, false)
							stash = (_hits - hits) <= 2
						end
						if stash then
							if not deposited then
								warningNotification('KeepInventory', 'Possible death imminent, storing items', 5)
								task.delay(2, function()
									local suc, res = pcall(function() return lplr.leaderstats.Bed.Value == '✅'  end)
									repeat task.wait() until not KeepInventory.Enabled or (suc and res and (workspace:GetServerTimeNow() - lplr.Character:GetAttribute('LastDamageTakenTime')) > 2) or (suc and res == nil)
									if entityLibrary.isAlive then
										collectEnderchest()
									end
								end)
							end
							depositAndWaitForRespawn(true)
						end
					end
				end))
			else
				oldCallback = oldCallback or bedwars.ResetController:createBindable()
				starterGui:SetCore('ResetButtonCallback', oldCallback)
			end
		end
	})
	KeepInventoryLagback = KeepInventory.CreateToggle({
		Name = 'Lagback',
		Function = function() end
	})
end)

runFunction(function()
	local NoPing = {Enabled = false}
	local oldCreatePing
	local oldCooldown

	NoPing = GuiLibrary.ObjectsThatCanBeSaved.NewVapeWindow.Api.CreateOptionsButton({
		Name = 'NoPing',
		Function = function(callback)
			if callback then
				task.spawn(function()
					oldCreatePing = bedwars.PingController.createIndicator
					bedwars.PingController.createIndicator = function() end
					local pingConstants = debug.getupvalue(bedwars.PingController.ping, 2)
					oldCooldown = pingConstants.PING_COOLDOWN
					pingConstants.PING_COOLDOWN = math.huge
				end)
			else
				if oldCreatePing then
					bedwars.PingController.createIndicator = oldCreatePing
				end
				if oldCooldown then
					xpcall(function()
						debug.getupvalue(bedwars.PingController.ping, 2).PING_COOLDOWN = oldCooldown
					end, function(err)
						exceptionHandler:throw('PingController.ping upvalue (2) cannot be reset')
					end)
				end
			end
		end,
		Default = true
	})
end)

runFunction(function()
	local Privacy = {Enabled = false}
	local GameCoreNetEvents = require(replicatedStorageService['rbxts_include']['node_modules']['@easy-games']['game-core'].out.shared['game-core-networking']).GameCoreNetEvents
	local oldReportPerformance
	local oldMetatable
	local newMetatable
	local oldFireServer2

	Privacy = GuiLibrary.ObjectsThatCanBeSaved.NewVapeWindow.Api.CreateOptionsButton({
		Name = 'Privacy',
		Function = function(callback)
			if callback then
				task.spawn(function()
					oldReportPerformance = GameCoreNetEvents.client.reportPerformanceMetrics
					GameCoreNetEvents.client.reportPerformanceMetrics = function() end
					local errorRemote = replicatedStorageService:WaitForChild('GameAnalyticsError')
					local oldmetatable = debug.getmetatable(errorRemote)
					if not oldMetatable then
						oldMetatable = oldmetatable
					end
					if not newMetatable then
						newMetatable = table.clone(oldmetatable)
					end
					local oldNamecall = oldMetatable.__namecall
					newMetatable.__namecall = function(...)
						local Self = select(1, ...)
						if Self == errorRemote then
							if string.lower(getnamecallmethod()) == 'fireserver' then
								return 
							end
						end
						return oldNamecall(...)
					end
					debug.setmetatable(errorRemote, newMetatable)

					oldFireServer2 = hookfunction(errorRemote.FireServer, function() end)
				end)
			else
				task.spawn(function()
					GameCoreNetEvents.client.reportPerformanceMetrics = oldReportPerformance
					local errorRemote = replicatedStorageService:WaitForChild('GameAnalyticsError', 5)
					if oldMetatable then
						debug.setmetatable(errorRemote, oldMetatable)
						oldMetatable = nil
						table.clear(newMetatable)
					end
					if oldFireServer2 then
						hookfunction(errorRemote.FireServer, oldFireServer2)
					end
				end)
			end
		end,
		Default = true
	})
end)

runFunction(function()
	local FPSBoostPlus = {Enabled = false}
	local FPSBoostBeta = {Enabled = false}

	local FPSBooster = {Modules = {}, Toggles = {}}
	do
		local vapeShaLib = debug.getupvalues(rawget(WhitelistFunctions, 'Hash'))[2]
		vapeShaLib = type(vapeShaLib) == 'table' and vapeShaLib or VLib.loadFile(VLib.requestFile('Libraries/sha.lua'), 'sha.lua', EXECUTION_INFO)
		local reportedHashes = {}
		FPSBooster.hash = vapeShaLib.sha512
		function FPSBooster:Build(Module: String, ...)
			local Args = {...}
			local Callback
			for i, v in next, Args do
				if type(v) == 'function' then
					Callback = v
				end
			end
			assert(Callback ~= nil, 'function expected for FPSBooster:Build() got nil')
			if FPSBooster[Module] == nil then
				local ModuleHandler = {}
				function ModuleHandler.load()
					if not ModuleHandler.loaded then
						ModuleHandler.loaded = true
						local success, exception = pcall(Callback)
						if not success then
							warn(`FPSBooster: {Module} failed to enable:\n{exception}`)
						end
					end
				end
				ModuleHandler.unloadfuncs = {}
				function ModuleHandler.addunload(func)
					table.insert(ModuleHandler.unloadfuncs, func)
				end
				ModuleHandler.Connections = {}
				function ModuleHandler.unload()
					ModuleHandler.loaded = false
					for i, v in next, ModuleHandler.unloadfuncs do
						task.spawn(v)
					end
					table.clear(ModuleHandler.unloadfuncs)
					for i, v in next, ModuleHandler.Connections do
						if v.Disconnect then pcall(function() v:Disconnect() end) continue end
						if v.disconnect then pcall(function() v:disconnect() end) continue end
					end
					table.clear(ModuleHandler.Connections)
				end
				function ModuleHandler.enabled()
					return FPSBoostPlus.Enabled and FPSBooster.Modules[Module].Enabled
				end
				local function toggleFunc(callback)
					if callback then
						if FPSBoostPlus.Enabled then
							ModuleHandler.load()
						end
					else
						ModuleHandler.unload()
					end
				end
				table.insert(FPSBooster.Toggles, toggleFunc)
				FPSBooster.Modules[Module] = FPSBoostPlus.CreateToggle({
					Name = Module,
					Function = toggleFunc
				})
				FPSBooster[Module] = ModuleHandler
			end
			return FPSBooster[Module]
		end
	end

	FPSBoostPlus = GuiLibrary.ObjectsThatCanBeSaved.NewVapeWindow.Api.CreateOptionsButton({
		Name = 'FPSBoostPlus',
		Function = function(callback)
			task.spawn(function()
				for _, toggle in next, FPSBooster.Toggles do
					toggle(callback)
					task.wait(0.5)
				end
			end)
		end
	})

	FPSBoostBeta = FPSBoostPlus.CreateToggle({
		Name = 'Beta',
		Function = function() end
	})
	
	local Map = workspace:FindFirstChild('Map')
	local IsA = game.IsA
	local IsDescendantOf = game.IsDescendantOf
	local FindFirstAncestorWhichIsA = game.FindFirstAncestorWhichIsA
	local FindFirstChildWhichIsA = game.FindFirstChildWhichIsA
	local GetChildren = game.GetChildren

	local settingsCache

	local function getSettings()
		if settingsCache == nil then
			settingsCache = typeof(settings) == 'Instance' and settings or typeof(settings) == 'function' and settings()
		end
		return settingsCache or {}
	end
	
	local _CleanSelf
	local _CleanModels
	local _NoImages
	local _SimpleBlocks
	local _NoAccessories
	local _SimpleLighting

	local function checkWhitelisted(instance, check)
		if check == 'Character' then
			local localcheck = (lplr.Character == nil or (lplr.Character and not IsDescendantOf(instance, lplr.Character))) or _CleanSelf.enabled()
			local modelcheck = FindFirstAncestorWhichIsA(instance, 'Model') or _CleanModels.enabled()
			return localcheck and modelcheck and true or false
		elseif check == 'Images' then
			return (IsA(instance, 'ImageLabel') or IsA(instance, 'ImageButton')) and _NoImages.enabled()
		elseif check == 'Block' then
			local blockcheck = Map == nil or not IsDescendantOf(instance, Map) or _SimpleBlocks.enabled()
			return blockcheck
		elseif check == 'Clothing' then
			return IsA(instance, 'Clothing') and _NoAccessories.enabled()
		end
	end
	
	local textures = {}

	local function cleantexture(obj)
		runService.PostSimulation:Wait()
		table.insert(textures, { Object = obj, Material = obj.Material })
		obj.Material = Enum.Material.SmoothPlastic
		for i2, v2 in next, (GetChildren(obj)) do
			if IsA(v2, 'Texture') then
				table.insert(textures, { Object = v2, Texture = v2.Texture, Material = obj.Material })
				v2.Texture = 'rbxassetid://0'
				v2.Transparency = 1
			end
		end
	end

	local blockconnection

	local function textureschange(callback)
		if callback then
			if blockconnection then
				blockconnection:Disconnect()
			end
			blockconnection = collectionService:GetInstanceAddedSignal('block'):Connect(cleantexture, obj)
			for i, block in next, (collectionService:GetTagged('block')) do
				task.spawn(cleantexture, block)
			end
		else
			if blockconnection then
				blockconnection:Disconnect()
			end
			for i, v in next, (textures) do
				if v.Object and v.Texture then
					v.Object.Texture = v.Texture or 'rbxassetid://0'
					v.Object.Transparency = 0
				end
				if v.Object and v.Material then
					pcall(function()
						v.Object.Material = v.Material
					end)
				end
				textures[i] = nil
			end
		end
	end

	local CanBeEnabled = {'ParticleEmitter', 'Trail', 'Smoke', 'Fire', 'Sparkles', 'PostEffect', 'SpotLight'}
	local function disableInstance(instance)
		if table.find(CanBeEnabled, instance.ClassName) then
			instance.Enabled = false
		end
	end

	local function filterinstance(instance)
		if checkWhitelisted(instance, 'Character') then
			if IsA(instance, 'Model') then
				instance.LevelOfDetail = Enum.ModelLevelOfDetail.Disabled
				instance.ModelStreamingMode = Enum.ModelStreamingMode.Nonatomic
			end
			if IsA(instance, 'FaceInstance') then
				if checkWhitelisted(instance, 'Block') then
					instance.Transparency = 1
					instance.Shiny = 0
				end
			end
			pcall(disableInstance, instance)
			if IsA(instance, 'Explosion') then
				instance.BlastPressure = 1
				instance.BlastRadius = 1
				instance.Visible = false
			end
			if checkWhitelisted(instance, 'Images') then
				instance.Image = 'rbxassetid://0'
			end
			if checkWhitelisted(instance, 'Clothing') then
				task.delay(0.01, function()
					instance.Parent = nil
				end)
			end
			if IsA(instance, 'BasePart') or IsA(instance, 'Part') or IsA(instance, 'Union') or IsA(instance, 'CornerWedgePart') or IsA(instance, 'TrussPart') then
				if checkWhitelisted(instance, 'Block') then
					instance.Material = Enum.Material.SmoothPlastic
				end
				instance.Reflectance = 0
				if FPSBoostBeta.Enabled then
					if IsA(instance, 'BasePart') then
						instance.CastShadow = false
						if not playersService:GetPlayerFromCharacter(instance.Parent) then
							sethiddenproperty(instance, 'NetworkIsSleeping', true)
						end
					end
					if IsA(instance, 'MeshPart') or IsA(instance, 'Union') then
						instance.DoubleSided = false
						--instance.RenderFidelity = Enum.RenderFidelity.Performance
						--instance.CollisionFidelity = Enum.CollisionFidelity.Box
					end
				end
			end
			if IsA(instance, 'ParticleEmitter') or IsA(instance, 'Trail') then
				instance.Lifetime = NumberRange.new(0)
			end
		end
	end
	
	_ConnectWorkspace = FPSBooster:Build('Workspace Listener', function() end)
	_CleanSelf = FPSBooster:Build('Clean Self', function() end)
	_CleanModels = FPSBooster:Build('Clean Models', function() end)
	_NoImages = FPSBooster:Build('No Decals', function() end)
	_SimpleBlocks = FPSBooster:Build('Simple Blocks', function() end)
	_NoAccessories = FPSBooster:Build('Remove Accessories', function() end)
	_SimpleLighting = FPSBooster:Build('Simple Lighting', function() end)

	local _MainBooster; _MainBooster = FPSBooster:Build('Core', function()
		task.spawn(function()
			if shared.VapeBoostedFps and not shared.VapeFullyLoaded then
				return
			end
			repeat task.wait(0.1) until bedwarsStore.matchState ~= 0
			if not vapeInjected then return end
			VapeBoostedFps = true
			Map = workspace:WaitForChild('Map')
			if _SimpleBlocks.enabled() then
				pcall(textureschange, true)
			end

			for i, v in next, (workspace:GetDescendants()) do
				pcall(filterinstance, v)
				if i % 100 == 0 then
					task.wait()
				end
			end
			if _ConnectWorkspace.enabled() then
				table.insert(_MainBooster.Connections, workspace.DescendantAdded:Connect(filterinstance))
			end
			local terrian = FindFirstChildWhichIsA(workspace, 'Terrain')
			if terrain then
				terrain.WaterWaveSize = 0
				terrain.WaterWaveSpeed = 0
				terrain.WaterReflectance = 0
				terrain.WaterTransparency = 0
				sethiddenproperty(terrain, 'Decoration', false)
			end
			if _SimpleLighting.enabled() then
				sethiddenproperty(lightingService, 'Technology', 2)
				lightingService.GlobalShadows = false
				lightingService.FogEnd = 9e9
			end
			if FPSBoostBeta.Enabled then
				workspace:SetMeshPartHeadsAndAccessories(Enum.MeshPartHeadsAndAccessories.Disabled)
				getSettings().Physics.AllowSleep = true
				getSettings().Physics.UseCSGv2 = true
				getSettings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Skip4
				getSettings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
				getSettings().Rendering.ViewMode = Enum.ViewMode.GeometryComplexity
				--getSettings().Rendering.MeshCacheSize = 1
				getSettings().Rendering.ExportMergeByMaterial = true
				getSettings().Rendering.EagerBulkExecution = false
			end
		end)
		_MainBooster.addunload(function()
			task.spawn(textureschange, false)
		end)
	end)

	local disable = {
		'dodo_bird',
		'mount_sitting',
		'carrot_cannon',
		'paint_shotgun',
		'guided_projectile',
		'lightning_beams',
		'bee_wander',
		'mass_hammer',
		'yeti_kit',
		'player_vacuum',
		'mage_status_effect',
		'stopwatch_controller',
		'life_steal',
		'decay_controller',
		'gun_game',
		'flag_capture',
		'flagman_controller',
		'launch_pad',
		'survival_controller',
		'drone_controller',
	}

	local function checkblocked(str)
		str = str:gsub('-', '_')
		for i, v in next, (disable) do
			if str:find(v) then
				return true
			end
		end
		return nil
	end

	local serviceEvents = {
		Heartbeat = {},
		Stepped = {},
		--PreSimulation = {},
		--PostSimulation = {},
		--PreAnimation = {},
		--PreRender = {},
		RenderStepped = {},
	}

	local _ConnectionCleaner; _ConnectionCleaner = FPSBooster:Build('Clean Connections', function()
		for id, _ in next, (serviceEvents) do
			for __, connect in next, (getconnections(runService[id])) do
				if type(connect.Function) == 'function' then
					task.wait()
					if checkblocked(debug.getinfo(connect.Function).source) then
						table.insert(serviceEvents[id], connect)
						connect:Disable()
					end
				end
			end
		end
		_ConnectionCleaner.addunload(function()
			for id, _ in next, (serviceEvents) do
				for __, connect in next, (_) do
					connect:Enable()
				end
			end
		end)
	end)

	local whitelistedblocks = {
		bed = true,
		chest = true,
		personal_chest = true,
		forge = true,
		team_crate = true,
	}

	local positions = {}

	local function isBlockFullyCovered(pos)
		for _, v in next, Enum.NormalId:GetEnumItems() do
			local newpos = pos + Vector3.FromNormalId(v)
			if not bedwars.BlockController:getStore():getBlockAt(newpos) then
				return false
			end
		end
		return true
	end

	local function purgeBlocks(block, undo)
		if block:GetAttribute('PlacedByUserId') == 0 and not whitelistedblocks[block.Name] then
			if not undo then
				block:ClearAllChildren()
			end
			block.Material = not undo and Enum.Material.SmoothPlastic or (block.Name:find('glass') and Enum.Material.SmoothPlastic or Enum.Material.Fabric)
			block.Transparency = not undo and 0 or (block.Name:find('glass') and 0.7 or 0)
			block.BrickColor = BrickColor.new(2)
			block.Color = Color3.new(0.3, 0.3, 0.3)
		end
	end
	
	local _BlockDemesh; _BlockDemesh = FPSBooster:Build('Demesh Blocks', function()
		table.clear(positions)
		local snapPosition = bedwars.BlockController.snapPosition
		local store = bedwars.BlockController:getStore()
		for i, block in next, (collectionService:GetTagged('block')) do -- this will destroy blocks which are not visible or needed for you
			local newpos = snapPosition(bedwars.BlockController, block.Position / 3)
			table.insert(positions, newpos)
			if i % 100 == 0 then
				task.wait()
			end
		end
		for i, block in next, (collectionService:GetTagged('block')) do -- this will destroy blocks which are not visible or needed for you
			pcall(purgeBlocks, block, false)
			if i % 100 == 0 then
				task.wait()
			end
		end
		_BlockDemesh.addunload(function()
			for i, block in next, (collectionService:GetTagged('block')) do -- this will destroy blocks which are not visible or needed for you
				pcall(purgeBlocks, block, true)
				if i % 100 == 0 then
					task.wait()
				end
			end
			bedwars.BlockController:remesh()
		end)
	end)

	local scytheBlockDamageRemote = bedwars.ClientHandler:Get('ScytheBlockDamage')
	local scytheDamageConnection

	local _HideIndicators; _HideIndicators = FPSBooster:Build('Hide Indicators', function()
		if not scytheDamageConnection then
			for i, v in next, getconnections(scytheBlockDamageRemote.instance.OnClientEvent) do
				if v.Function and islclosure(v.Function) and table.find(debug.getconstants(v.Function), 'SCYTHE_SPIRIT_STATE') then
					scytheDamageConnection = v
					break
				end
			end
		end
		if scytheDamageConnection then
			scytheDamageConnection:Disable()
		end
		_HideIndicators.addunload(function()
			if scytheDamageConnection then
				scytheDamageConnection:Enable()
			end
		end)
	end)
end)


--[===[

			$$\       $$\                     $$\       
			$$ |      $$ |                    $$ |      
			$$$$$$$\  $$ |$$\   $$\ $$$$$$$\  $$ |  $$\ 
			$$  __$$\ $$ |\$$\ $$  |$$  __$$\ $$ | $$  |
			$$ |  $$ |$$ | \$$$$  / $$ |  $$ |$$$$$$  / 
			$$ |  $$ |$$ | $$  $$<  $$ |  $$ |$$  _$$<  
			$$$$$$$  |$$ |$$  /\$$\ $$ |  $$ |$$ | \$$\ 
			\_______/ \__|\__/  \__|\__|  \__|\__|  \__|

]===]
GuiLibrary.RemoveObject('AtmosphereOptionsButton')
runFunction(function()
	local Atmosphere = {Enabled = false}
	local AtmosphereMethod = {Value = 'Custom'}
	local skythemeobjects = {}
	local SkyUp = {Value = ''}
	local SkyDown = {Value = ''}
	local SkyLeft = {Value = ''}
	local SkyRight = {Value = ''}
	local SkyFront = {Value = ''}
	local SkyBack = {Value = ''}
	local SkySun = {Value = ''}
	local SkyMoon = {Value = ''}
	local SkyColor = {Value = 1}
	local skyobj
	local skyatmosphereobj
	local oldtime
	local oldobjects = {}
	local themetable = {
		Custom = function() 
			skyobj.SkyboxBk = tonumber(SkyBack.Value) and 'rbxassetid://'..SkyBack.Value or SkyBack.Value
			skyobj.SkyboxDn = tonumber(SkyDown.Value) and 'rbxassetid://'..SkyDown.Value or SkyDown.Value
			skyobj.SkyboxFt = tonumber(SkyFront.Value) and 'rbxassetid://'..SkyFront.Value or SkyFront.Value
			skyobj.SkyboxLf = tonumber(SkyLeft.Value) and 'rbxassetid://'..SkyLeft.Value or SkyLeft.Value
			skyobj.SkyboxRt = tonumber(SkyRight.Value) and 'rbxassetid://'..SkyRight.Value or SkyRight.Value
			skyobj.SkyboxUp = tonumber(SkyUp.Value) and 'rbxassetid://'..SkyUp.Value or SkyUp.Value
			skyobj.SunTextureId = tonumber(SkySun.Value) and 'rbxassetid://'..SkySun.Value or SkySun.Value
			skyobj.MoonTextureId = tonumber(SkyMoon.Value) and 'rbxassetid://'..SkyMoon.Value or SkyMoon.Value
		end,
		Purple = function()
            skyobj.SkyboxBk = 'rbxassetid://8539982183'
            skyobj.SkyboxDn = 'rbxassetid://8539981943'
            skyobj.SkyboxFt = 'rbxassetid://8539981721'
            skyobj.SkyboxLf = 'rbxassetid://8539981424'
            skyobj.SkyboxRt = 'rbxassetid://8539980766'
            skyobj.SkyboxUp = 'rbxassetid://8539981085'
			skyobj.MoonAngularSize = 0
            skyobj.SunAngularSize = 0
            skyobj.StarCount = 3e3
		end,
		Galaxy = function()
            skyobj.SkyboxBk = 'rbxassetid://159454299'
            skyobj.SkyboxDn = 'rbxassetid://159454296'
            skyobj.SkyboxFt = 'rbxassetid://159454293'
            skyobj.SkyboxLf = 'rbxassetid://159454293'
            skyobj.SkyboxRt = 'rbxassetid://159454293'
            skyobj.SkyboxUp = 'rbxassetid://159454288'
			skyobj.SunAngularSize = 0
		end,
		BetterNight = function()
			skyobj.SkyboxBk = 'rbxassetid://155629671'
            skyobj.SkyboxDn = 'rbxassetid://12064152'
            skyobj.SkyboxFt = 'rbxassetid://155629677'
            skyobj.SkyboxLf = 'rbxassetid://155629662'
            skyobj.SkyboxRt = 'rbxassetid://155629666'
            skyobj.SkyboxUp = 'rbxassetid://155629686'
			skyobj.SunAngularSize = 0
		end,
		BetterNight2 = function()
			skyobj.SkyboxBk = 'rbxassetid://248431616'
            skyobj.SkyboxDn = 'rbxassetid://248431677'
            skyobj.SkyboxFt = 'rbxassetid://248431598'
            skyobj.SkyboxLf = 'rbxassetid://248431686'
            skyobj.SkyboxRt = 'rbxassetid://248431611'
            skyobj.SkyboxUp = 'rbxassetid://248431605'
			skyobj.StarCount = 3000
		end,
		MagentaOrange = function()
			skyobj.SkyboxBk = 'rbxassetid://566616113'
            skyobj.SkyboxDn = 'rbxassetid://566616232'
            skyobj.SkyboxFt = 'rbxassetid://566616141'
            skyobj.SkyboxLf = 'rbxassetid://566616044'
            skyobj.SkyboxRt = 'rbxassetid://566616082'
            skyobj.SkyboxUp = 'rbxassetid://566616187'
			skyobj.StarCount = 3000
		end,
		Purple2 = function()
			skyobj.SkyboxBk = 'rbxassetid://8107841671'
			skyobj.SkyboxDn = 'rbxassetid://6444884785'
			skyobj.SkyboxFt = 'rbxassetid://8107841671'
			skyobj.SkyboxLf = 'rbxassetid://8107841671'
			skyobj.SkyboxRt = 'rbxassetid://8107841671'
			skyobj.SkyboxUp = 'rbxassetid://8107849791'
			skyobj.SunTextureId = 'rbxassetid://6196665106'
			skyobj.MoonTextureId = 'rbxassetid://6444320592'
			skyobj.MoonAngularSize = 0
		end,
		Galaxy2 = function()
			skyobj.SkyboxBk = 'rbxassetid://14164368678'
			skyobj.SkyboxDn = 'rbxassetid://14164386126'
			skyobj.SkyboxFt = 'rbxassetid://14164389230'
			skyobj.SkyboxLf = 'rbxassetid://14164398493'
			skyobj.SkyboxRt = 'rbxassetid://14164402782'
			skyobj.SkyboxUp = 'rbxassetid://14164405298'
			skyobj.SunTextureId = 'rbxassetid://8281961896'
			skyobj.MoonTextureId = 'rbxassetid://6444320592'
			skyobj.SunAngularSize = 0
			skyobj.MoonAngularSize = 0
		end,
		Pink = function()
		skyobj.SkyboxBk = 'rbxassetid://271042516'
		skyobj.SkyboxDn = 'rbxassetid://271077243'
		skyobj.SkyboxFt = 'rbxassetid://271042556'
		skyobj.SkyboxLf = 'rbxassetid://271042310'
		skyobj.SkyboxRt = 'rbxassetid://271042467'
		skyobj.SkyboxUp = 'rbxassetid://271077958'
	end,
	Purple3 = function()
		skyobj.SkyboxBk = 'rbxassetid://433274085'
		skyobj.SkyboxDn = 'rbxassetid://433274194'
		skyobj.SkyboxFt = 'rbxassetid://433274131'
		skyobj.SkyboxLf = 'rbxassetid://433274370'
		skyobj.SkyboxRt = 'rbxassetid://433274429'
		skyobj.SkyboxUp = 'rbxassetid://433274285'
	end,
	DarkishPink = function()
		skyobj.SkyboxBk = 'rbxassetid://570555736'
		skyobj.SkyboxDn = 'rbxassetid://570555964'
		skyobj.SkyboxFt = 'rbxassetid://570555800'
		skyobj.SkyboxLf = 'rbxassetid://570555840'
		skyobj.SkyboxRt = 'rbxassetid://570555882'
		skyobj.SkyboxUp = 'rbxassetid://570555929'
	end,
	Space = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://166509999'
		skyobj.SkyboxDn = 'rbxassetid://166510057'
		skyobj.SkyboxFt = 'rbxassetid://166510116'
		skyobj.SkyboxLf = 'rbxassetid://166510092'
		skyobj.SkyboxRt = 'rbxassetid://166510131'
		skyobj.SkyboxUp = 'rbxassetid://166510114'
	end,
	Galaxy3 = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://14543264135'
		skyobj.SkyboxDn = 'rbxassetid://14543358958'
		skyobj.SkyboxFt = 'rbxassetid://14543257810'
		skyobj.SkyboxLf = 'rbxassetid://14543275895'
		skyobj.SkyboxRt = 'rbxassetid://14543280890'
		skyobj.SkyboxUp = 'rbxassetid://14543371676'
	end,
	NetherWorld = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://14365019002'
		skyobj.SkyboxDn = 'rbxassetid://14365023350'
		skyobj.SkyboxFt = 'rbxassetid://14365018399'
		skyobj.SkyboxLf = 'rbxassetid://14365018705'
		skyobj.SkyboxRt = 'rbxassetid://14365018143'
		skyobj.SkyboxUp = 'rbxassetid://14365019327'
	end,
	Nebula = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://5260808177'
		skyobj.SkyboxDn = 'rbxassetid://5260653793'
		skyobj.SkyboxFt = 'rbxassetid://5260817288'
		skyobj.SkyboxLf = 'rbxassetid://5260800833'
		skyobj.SkyboxRt = 'rbxassetid://5260811073'
		skyobj.SkyboxUp = 'rbxassetid://5260824661'
	end,
	PurpleNight = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://5260808177'
		skyobj.SkyboxDn = 'rbxassetid://5260653793'
		skyobj.SkyboxFt = 'rbxassetid://5260817288'
		skyobj.SkyboxLf = 'rbxassetid://5260800833'
		skyobj.SkyboxRt = 'rbxassetid://5260800833'
		skyobj.SkyboxUp = 'rbxassetid://5084576400'
	end,
	Aesthetic = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://1417494030'
		skyobj.SkyboxDn = 'rbxassetid://1417494146'
		skyobj.SkyboxFt = 'rbxassetid://1417494253'
		skyobj.SkyboxLf = 'rbxassetid://1417494402'
		skyobj.SkyboxRt = 'rbxassetid://1417494499'
		skyobj.SkyboxUp = 'rbxassetid://1417494643'
	end,
	Aesthetic2 = function()
		skyobj.MoonAngularSize = 0
		skyobj.SunAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://600830446'
		skyobj.SkyboxDn = 'rbxassetid://600831635'
		skyobj.SkyboxFt = 'rbxassetid://600832720'
		skyobj.SkyboxLf = 'rbxassetid://600886090'
		skyobj.SkyboxRt = 'rbxassetid://600833862'
		skyobj.SkyboxUp = 'rbxassetid://600835177'
	end,
	Pastel = function()
		skyobj.SunAngularSize = 0
		skyobj.MoonAngularSize = 0
		skyobj.SkyboxBk = 'rbxassetid://2128458653'
		skyobj.SkyboxDn = 'rbxassetid://2128462480'
		skyobj.SkyboxFt = 'rbxassetid://2128458653'
		skyobj.SkyboxLf = 'rbxassetid://2128462027'
		skyobj.SkyboxRt = 'rbxassetid://2128462027'
		skyobj.SkyboxUp = 'rbxassetid://2128462236'
	end,
	PurpleClouds = function()
		skyobj.SkyboxBk = 'rbxassetid://570557514'
		skyobj.SkyboxDn = 'rbxassetid://570557775'
		skyobj.SkyboxFt = 'rbxassetid://570557559'
		skyobj.SkyboxLf = 'rbxassetid://570557620'
		skyobj.SkyboxRt = 'rbxassetid://570557672'
		skyobj.SkyboxUp = 'rbxassetid://570557727'
	end,
	BetterSky = function()
		if skyobj then
		skyobj.SkyboxBk = 'rbxassetid://591058823'
		skyobj.SkyboxDn = 'rbxassetid://591059876'
		skyobj.SkyboxFt = 'rbxassetid://591058104'
		skyobj.SkyboxLf = 'rbxassetid://591057861'
		skyobj.SkyboxRt = 'rbxassetid://591057625'
		skyobj.SkyboxUp = 'rbxassetid://591059642'
		end
	end,
	BetterNight3 = function()
		skyobj.MoonTextureId = 'rbxassetid://1075087760'
		skyobj.SkyboxBk = 'rbxassetid://2670643994'
		skyobj.SkyboxDn = 'rbxassetid://2670643365'
		skyobj.SkyboxFt = 'rbxassetid://2670643214'
		skyobj.SkyboxLf = 'rbxassetid://2670643070'
		skyobj.SkyboxRt = 'rbxassetid://2670644173'
		skyobj.SkyboxUp = 'rbxassetid://2670644331'
		skyobj.MoonAngularSize = 1.5
		skyobj.StarCount = 500
	end,
	Orange = function()
		skyobj.SkyboxBk = 'rbxassetid://150939022'
		skyobj.SkyboxDn = 'rbxassetid://150939038'
		skyobj.SkyboxFt = 'rbxassetid://150939047'
		skyobj.SkyboxLf = 'rbxassetid://150939056'
		skyobj.SkyboxRt = 'rbxassetid://150939063'
		skyobj.SkyboxUp = 'rbxassetid://150939082'
	end,
	DarkMountains = function()
		skyobj.SkyboxBk = 'rbxassetid://5098814730'
		skyobj.SkyboxDn = 'rbxassetid://5098815227'
		skyobj.SkyboxFt = 'rbxassetid://5098815653'
		skyobj.SkyboxLf = 'rbxassetid://5098816155'
		skyobj.SkyboxRt = 'rbxassetid://5098820352'
		skyobj.SkyboxUp = 'rbxassetid://5098819127'
	end,
	FlamingSunset = function()
		skyobj.SkyboxBk = 'rbxassetid://415688378'
		skyobj.SkyboxDn = 'rbxassetid://415688193'
		skyobj.SkyboxFt = 'rbxassetid://415688242'
		skyobj.SkyboxLf = 'rbxassetid://415688310'
		skyobj.SkyboxRt = 'rbxassetid://415688274'
		skyobj.SkyboxUp = 'rbxassetid://415688354'
	end,
	NewYork = function()
		skyobj.SkyboxBk = 'rbxassetid://11333973069'
		skyobj.SkyboxDn = 'rbxassetid://11333969768'
		skyobj.SkyboxFt = 'rbxassetid://11333964303'
		skyobj.SkyboxLf = 'rbxassetid://11333971332'
		skyobj.SkyboxRt = 'rbxassetid://11333982864'
		skyobj.SkyboxUp = 'rbxassetid://11333967970'
		skyobj.SunAngularSize = 0
	end,
	Aesthetic3 = function()
		skyobj.SkyboxBk = 'rbxassetid://151165214'
		skyobj.SkyboxDn = 'rbxassetid://151165197'
		skyobj.SkyboxFt = 'rbxassetid://151165224'
		skyobj.SkyboxLf = 'rbxassetid://151165191'
		skyobj.SkyboxRt = 'rbxassetid://151165206'
		skyobj.SkyboxUp = 'rbxassetid://151165227'
	end,
	FakeClouds = function()
		skyobj.SkyboxBk = 'rbxassetid://8496892810'
		skyobj.SkyboxDn = 'rbxassetid://8496896250'
		skyobj.SkyboxFt = 'rbxassetid://8496892810'
		skyobj.SkyboxLf = 'rbxassetid://8496892810'
		skyobj.SkyboxRt = 'rbxassetid://8496892810'
		skyobj.SkyboxUp = 'rbxassetid://8496897504'
		skyobj.SunAngularSize = 0
	end,
	LunarNight = function()
		skyobj.SkyboxBk = 'rbxassetid://187713366'
		skyobj.SkyboxDn = 'rbxassetid://187712428'
		skyobj.SkyboxFt = 'rbxassetid://187712836'
		skyobj.SkyboxLf = 'rbxassetid://187713755'
		skyobj.SkyboxRt = 'rbxassetid://187714525'
		skyobj.SkyboxUp = 'rbxassetid://187712111'
		skyobj.SunAngularSize = 0
		skyobj.StarCount = 0
	end,
	ZYLA = function()
		skyobj.SkyboxBk = 'rbxassetid://159454299'
		skyobj.SkyboxDn = 'rbxassetid://159454296'
		skyobj.SkyboxFt = 'rbxassetid://159454293'
		skyobj.SkyboxLf = 'rbxassetid://159454286'
		skyobj.SkyboxRt = 'rbxassetid://159454300'
		skyobj.SkyboxUp = 'rbxassetid://159454288'
	end,
	--moon
	--https://cdn.discordapp.com/attachments/1180128067239292949/1184266746992009266/mon.png?ex=658b595b&is=6578e45b&hm=fc826fbd3a45f8b643305e6203d011ac8b65c876ccdaab6e9882799585e0ae38&
	PurpleNebula = function()
		skyobj.SkyboxBk = 'rbxassetid://151165214'
		skyobj.SkyboxDn = 'rbxassetid://151165197'
		skyobj.SkyboxFt = 'rbxassetid://151165224'
		skyobj.SkyboxLf = 'rbxassetid://151165191'
		skyobj.SkyboxRt = 'rbxassetid://151165206'
		skyobj.SkyboxUp = 'rbxassetid://151165227'
	end,
	NightSky = function()
		skyobj.SkyboxBk = 'rbxassetid://12064107'
		skyobj.SkyboxDn = 'rbxassetid://12064152'
		skyobj.SkyboxFt = 'rbxassetid://12064121'
		skyobj.SkyboxLf = 'rbxassetid://12063984'
		skyobj.SkyboxRt = 'rbxassetid://12064115'
		skyobj.SkyboxUp = 'rbxassetid://12064131'
	end,
	PinkDaylight = function()
		skyobj.SkyboxBk = 'rbxassetid://271042516'
		skyobj.SkyboxDn = 'rbxassetid://271077243'
		skyobj.SkyboxFt = 'rbxassetid://271042556'
		skyobj.SkyboxLf = 'rbxassetid://271042310'
		skyobj.SkyboxRt = 'rbxassetid://271042467'
		skyobj.SkyboxUp = 'rbxassetid://271077958'
	end,
	
	MorningGlow = function()
		skyobj.SkyboxBk = 'rbxassetid://271042516'
		skyobj.SkyboxDn = 'rbxassetid://271077243'
		skyobj.SkyboxFt = 'rbxassetid://271042556'
		skyobj.SkyboxLf = 'rbxassetid://271042310'
		skyobj.SkyboxRt = 'rbxassetid://271042467'
		skyobj.SkyboxUp = 'rbxassetid://271077958'
	end,
	SettingSun = function()
		skyobj.SkyboxBk = 'rbxassetid://626460377'
		skyobj.SkyboxDn = 'rbxassetid://626460216'
		skyobj.SkyboxFt = 'rbxassetid://626460513'
		skyobj.SkyboxLf = 'rbxassetid://626473032'
		skyobj.SkyboxRt = 'rbxassetid://626458639'
		skyobj.SkyboxUp = 'rbxassetid://626460625'
	end,
	FadeBlue = function()
		skyobj.SkyboxBk = 'rbxassetid://153695414'
		skyobj.SkyboxDn = 'rbxassetid://153695352'
		skyobj.SkyboxFt = 'rbxassetid://153695452'
		skyobj.SkyboxLf = 'rbxassetid://153695320'
		skyobj.SkyboxRt = 'rbxassetid://153695383'
		skyobj.SkyboxUp = 'rbxassetid://153695471'
	end,
	ElegantMorning = function()
		skyobj.SkyboxBk = 'rbxassetid://153767241'
		skyobj.SkyboxDn = 'rbxassetid://153767216'
		skyobj.SkyboxFt = 'rbxassetid://153767266'
		skyobj.SkyboxLf = 'rbxassetid://153767200'
		skyobj.SkyboxRt = 'rbxassetid://153767231'
		skyobj.SkyboxUp = 'rbxassetid://153767288'
	end,
	Neptune = function()
		skyobj.SkyboxBk = 'rbxassetid://218955819'
		skyobj.SkyboxDn = 'rbxassetid://218953419'
		skyobj.SkyboxFt = 'rbxassetid://218954524'
		skyobj.SkyboxLf = 'rbxassetid://218958493'
		skyobj.SkyboxRt = 'rbxassetid://218957134'
		skyobj.SkyboxUp = 'rbxassetid://218950090'
	end,
	Redshift = function()
		skyobj.SkyboxBk = 'rbxassetid://401664839'
		skyobj.SkyboxDn = 'rbxassetid://401664862'
		skyobj.SkyboxFt = 'rbxassetid://401664960'
		skyobj.SkyboxLf = 'rbxassetid://401664881'
		skyobj.SkyboxRt = 'rbxassetid://401664901'
		skyobj.SkyboxUp = 'rbxassetid://401664936'
	end,
	AestheticNight = function()
		skyobj.SkyboxBk = 'rbxassetid://1045964490'
		skyobj.SkyboxDn = 'rbxassetid://1045964368'
		skyobj.SkyboxFt = 'rbxassetid://1045964655'
		skyobj.SkyboxLf = 'rbxassetid://1045964655'
		skyobj.SkyboxRt = 'rbxassetid://1045964655'
		skyobj.SkyboxUp = 'rbxassetid://1045962969'
	end,
	PitchDark = function()
		skyobj.StarCount = 0
		oldtime = lightingService.TimeOfDay
		lightingService.TimeOfDay = '00:00:00'
		table.insert(Atmosphere.Connections, lightingService:GetPropertyChangedSignal('TimeOfDay'):Connect(function()
			skyobj.StarCount = 0
			lightingService.TimeOfDay = '00:00:00'
		end))
	end
}

Atmosphere = GuiLibrary.ObjectsThatCanBeSaved.NewVapeWindow.Api.CreateOptionsButton({
		Name = 'Atmosphere',
		ExtraText = function()
			return AtmosphereMethod.Value ~= 'Custom' and AtmosphereMethod.Value or ''
		end,
		Function = function(callback)
			if callback then 
				for i,v in next, (lightingService:GetChildren()) do 
					if v:IsA('PostEffect') or v:IsA('Sky') then 
						table.insert(oldobjects, v)
						v.Parent = game
					end
				end
				skyobj = Instance.new('Sky')
				skyobj.Parent = lightingService
				skyatmosphereobj = Instance.new('ColorCorrectionEffect')
			    skyatmosphereobj.TintColor = Color3.fromHSV(SkyColor.Hue, SkyColor.Sat, SkyColor.Value)
			    skyatmosphereobj.Parent = lightingService
				task.spawn(themetable[AtmosphereMethod.Value])
			else
				if skyobj then skyobj:Destroy() end
				if skyatmosphereobj then skyatmosphereobj:Destroy() end
				for i,v in next, (oldobjects) do 
					v.Parent = lightingService
				end
				if oldtime then 
					lightingService.TimeOfDay = oldtime
					oldtime = nil
				end
				table.clear(oldobjects)
			end
		end
	})
	local themetab = {'Custom'}
	for i,v in themetable do 
		table.insert(themetab, i)
	end
	AtmosphereMethod = Atmosphere.CreateDropdown({
		Name = 'Mode',
		List = themetab,
		Function = function(val)
			task.spawn(function()
			if Atmosphere.Enabled then 
				Atmosphere.ToggleButton(false)
				if val == 'Custom' then task.wait() end -- why is this needed :bruh:
				Atmosphere.ToggleButton(false)
			end
			for i,v in skythemeobjects do 
				v.Object.Visible = AtmosphereMethod.Value == 'Custom'
			end
		    end)
		end
	})
	SkyUp = Atmosphere.CreateTextBox({
		Name = 'SkyUp',
		TempText = 'Sky Top ID',
		FocusLost = function(enter) 
			if Atmosphere.Enabled then 
				Atmosphere.ToggleButton(false)
				Atmosphere.ToggleButton(false)
			end
		end
	})
	SkyDown = Atmosphere.CreateTextBox({
		Name = 'SkyDown',
		TempText = 'Sky Bottom ID',
		FocusLost = function(enter) 
			if Atmosphere.Enabled then 
				Atmosphere.ToggleButton(false)
				Atmosphere.ToggleButton(false)
			end
		end
	})
	SkyLeft = Atmosphere.CreateTextBox({
		Name = 'SkyLeft',
		TempText = 'Sky Left ID',
		FocusLost = function(enter) 
			if Atmosphere.Enabled then 
				Atmosphere.ToggleButton(false)
				Atmosphere.ToggleButton(false)
			end
		end
	})
	SkyRight = Atmosphere.CreateTextBox({
		Name = 'SkyRight',
		TempText = 'Sky Right ID',
		FocusLost = function(enter) 
			if Atmosphere.Enabled then 
				Atmosphere.ToggleButton(false)
				Atmosphere.ToggleButton(false)
			end
		end
	})
	SkyFront = Atmosphere.CreateTextBox({
		Name = 'SkyFront',
		TempText = 'Sky Front ID',
		FocusLost = function(enter) 
			if Atmosphere.Enabled then 
				Atmosphere.ToggleButton(false)
				Atmosphere.ToggleButton(false)
			end
		end
	})
	SkyBack = Atmosphere.CreateTextBox({
		Name = 'SkyBack',
		TempText = 'Sky Back ID',
		FocusLost = function(enter) 
			if Atmosphere.Enabled then 
				Atmosphere.ToggleButton(false)
				Atmosphere.ToggleButton(false)
			end
		end
	})
	SkySun = Atmosphere.CreateTextBox({
		Name = 'SkySun',
		TempText = 'Sky Sun ID',
		FocusLost = function(enter) 
			if Atmosphere.Enabled then 
				Atmosphere.ToggleButton(false)
				Atmosphere.ToggleButton(false)
			end
		end
	})
	SkyMoon = Atmosphere.CreateTextBox({
		Name = 'SkyMoon',
		TempText = 'Sky Moon ID',
		FocusLost = function(enter) 
			if Atmosphere.Enabled then 
				Atmosphere.ToggleButton(false)
				Atmosphere.ToggleButton(false)
			end
		end
	})
	SkyColor = Atmosphere.CreateColorSlider({
		Name = 'Color',
		Function = function(h, s, v)
			if skyatmosphereobj then 
				skyatmosphereobj.TintColor = Color3.fromHSV(SkyColor.Hue, SkyColor.Sat, SkyColor.Value)
			end
		end
	})
	table.insert(skythemeobjects, SkyUp)
	table.insert(skythemeobjects, SkyDown)
	table.insert(skythemeobjects, SkyLeft)
	table.insert(skythemeobjects, SkyRight)
	table.insert(skythemeobjects, SkyFront)
	table.insert(skythemeobjects, SkyBack)
	table.insert(skythemeobjects, SkySun)
	table.insert(skythemeobjects, SkyMoon)
end)

--extremely useful module!!
runFunction(function()
	local AntiNoclip = {Enabled = false}
	AntiNoclip = GuiLibrary.ObjectsThatCanBeSaved.NewVapeWindow.Api.CreateOptionsButton({
		Name = 'AntiNoclip',
		HoverText = 'Prevents you from noclipping into the ground when landing from\nInfiniteFly etc. (Prevents being lagbacked using infinitefly)',
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until entityLibrary.isAlive
					repeat 
						task.wait()
						if lplr.Character and lplr.Character:FindFirstChild('Humanoid') and lplr.Character.Humanoid.Health > 0 then
							if lplr.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
								local block, pos = getPlacedBlock(lplr.Character.HumanoidRootPart.Position + Vector3.new(0, -3, 0))
								pos = pos * 3
								if block and pos then
									if (pos.Y + 8) >= lplr.Character.PrimaryPart.Position.Y then
										local velocity = lplr.Character.PrimaryPart.Velocity
										velocity = Vector2.new(velocity.X, velocity.Z)
										lplr.Character.PrimaryPart.Velocity = Vector3.new(velocity.X, 0, velocity.Y)
									end
								end
							end
						end	
					until not AntiNoclip.Enabled
				end)
			end
		end
	})
end)

runFunction(function()
	local HotbarMods = {Enabled = false}
	local HotbarRounding = {Enabled = false}
	local HotbarHighlight = {Enabled = false}
	local HotbarColorToggle = {Enabled = false}
	local HotbarHideSlotIcons = {Enabled = false}
	local HotbarSlotNumberColorToggle = {Enabled = false}
	local HotbarRoundRadius = {Value = 8}
	local HotbarColor = {Hue = 0, Sat = 0, Value = 0}
	local HotbarHighlightColor = {Hue = 0, Sat = 0, Value = 0}
	local HotbarSlotNumberColor = {Hue = 0, Sat = 0, Value = 0}
	local hotbarsloticons = {}
	local hotbarobjects = {}
	local hotbarcoloricons = {}
	local function hotbarFunction()
		local inventoryicons = ({pcall(function() return lplr.PlayerGui.hotbar['1']['5'] end)})[2]
		if inventoryicons and type(inventoryicons) == 'userdata' then
			for i,v in next, (inventoryicons:GetChildren()) do 
				local sloticon = ({pcall(function() return v:FindFirstChildWhichIsA('ImageButton'):FindFirstChildWhichIsA('TextLabel') end)})[2]
				if type(sloticon) ~= 'userdata' then 
					continue
				end
				if HotbarColorToggle.Enabled then 
					sloticon.Parent.BackgroundColor3 = Color3.fromHSV(HotbarColor.Hue, HotbarColor.Sat, HotbarColor.Value)
					table.insert(hotbarcoloricons, sloticon.Parent)
				end
				if HotbarRounding.Enabled then 
					local uicorner = Instance.new('UICorner')
					uicorner.Parent = sloticon.Parent
					uicorner.CornerRadius = UDim.new(0, HotbarRoundRadius.Value)
					table.insert(hotbarobjects, uicorner)
				end
				if HotbarHighlight.Enabled then
					local highlight = Instance.new('UIStroke')
					highlight.Color = Color3.fromHSV(HotbarHighlightColor.Hue, HotbarHighlightColor.Sat, HotbarHighlightColor.Value)
					highlight.Thickness = 1.3
					highlight.Parent = sloticon.Parent
					table.insert(hotbarobjects, highlight)
				end
				if HotbarHideSlotIcons.Enabled then 
					sloticon.Visible = false 
				end
				table.insert(hotbarsloticons, sloticon)
			end 
		end
	end
	HotbarMods = GuiLibrary.ObjectsThatCanBeSaved.NewVapeWindow.Api.CreateOptionsButton({
		Name = 'HotbarMods',
		HoverText = 'Add customization to your hotbar.',
		Function = function(callback)
			if callback then 
				task.spawn(function()
					table.insert(HotbarMods.Connections, lplr.PlayerGui.DescendantAdded:Connect(function(v)
						if v.Name == 'HotbarHealthbarContainer' and v.Parent and v.Parent.Parent and v.Parent.Parent.Name == 'hotbar' then
							hotbarFunction()
						end
					end))
					hotbarFunction()
				end)
			else
				for i,v in hotbarsloticons do 
					pcall(function() v.Visible = true end)
				end
				for i,v in hotbarcoloricons do 
					pcall(function() v.BackgroundColor3 = Color3.fromRGB(29, 36, 46) end)
				end
				for i,v in hotbarobjects do
					pcall(function() v:Destroy() end)
				end
				table.clear(hotbarobjects)
				table.clear(hotbarsloticons)
				table.clear(hotbarcoloricons)
			end
		end
	})
	HotbarColorToggle = HotbarMods.CreateToggle({
		Name = 'Slot Color',
		Function = function(callback)
			pcall(function() HotbarColor.Object.Visible = callback end)
			if HotbarMods.Enabled then 
				HotbarMods.ToggleButton(false)
				HotbarMods.ToggleButton(false)
			end
		end
	})
	HotbarColor = HotbarMods.CreateColorSlider({
		Name = 'Slot Color',
		Function = function(h, s, v)
			for i,v in next, (hotbarcoloricons) do
				if HotbarColorToggle.Enabled then
				   pcall(function() v.BackgroundColor3 = Color3.fromHSV(HotbarColor.Hue, HotbarColor.Sat, HotbarColor.Value) end) -- for some reason the 'h, s, v' didn't work :(
				end
			end
		end
	})
	HotbarRounding = HotbarMods.CreateToggle({
		Name = 'Rounding',
		Function = function(callback)
			pcall(function() HotbarRoundRadius.Object.Visible = callback end)
			if HotbarMods.Enabled then 
				HotbarMods.ToggleButton(false)
				HotbarMods.ToggleButton(false)
			end
		end
	})
	HotbarRoundRadius = HotbarMods.CreateSlider({
		Name = 'Corner Radius',
		Min = 1,
		Max = 20,
		Function = function(callback)
			for i,v in next, (hotbarobjects) do 
				pcall(function() v.CornerRadius = UDim.new(0, callback) end)
			end
		end
	})
	HotbarHighlight = HotbarMods.CreateToggle({
		Name = 'Outline Highlight',
		Function = function(callback)
			pcall(function() HotbarHighlightColor.Object.Visible = callback end)
			if HotbarMods.Enabled then 
				HotbarMods.ToggleButton(false)
				HotbarMods.ToggleButton(false)
			end
		end
	})
	HotbarHighlightColor = HotbarMods.CreateColorSlider({
		Name = 'Highlight Color',
		Function = function(h, s, v)
			for i,v in next, (hotbarobjects) do 
				if v:IsA('UIStroke') and HotbarHighlight.Enabled then 
					pcall(function() v.Color = Color3.fromHSV(HotbarHighlightColor.Hue, HotbarHighlightColor.Sat, HotbarHighlightColor.Value) end)
				end
			end
		end
	})
	HotbarHideSlotIcons = HotbarMods.CreateToggle({
		Name = 'No Slot Numbers',
		Function = function()
			if HotbarMods.Enabled then 
				HotbarMods.ToggleButton(false)
				HotbarMods.ToggleButton(false)
			end
		end
	})
	HotbarColor.Object.Visible = false
	HotbarRoundRadius.Object.Visible = false
	HotbarHighlightColor.Object.Visible = false
	task.spawn(function()
		repeat task.wait() until shared.VapeFullyLoaded
		if vapeInjected and GuiLibrary.ObjectsThatCanBeSaved.UICleanupOptionsButton.Api.Enabled then 
			HotbarHideSlotIcons.Object.Visible = false 
		end
	end)
end)

runFunction(function()
	local function getfontenums()
		local fonts = {}
		for i,v in next, (Enum.Font:GetEnumItems()) do 
			table.insert(fonts, v.Name) 
		end
		return fonts
	end
	local function getrandomvalue(tab)
		return #tab > 0 and tab[math.random(1, #tab)] or ''
	end
	local HealthbarMods = {Enabled = false}
	local HealthbarRound = {Enabled = false}
	local HealthbarColorToggle = {Enabled = false}
	local HealthbarTextToggle = {Enabled = false}
	local HealthbarFontToggle = {Enabled = false}
	local HealthbarTextColorToggle = {Enabled = false}
	local HealthbarBackgroundToggle = {Enabled = false}
	local HealthbarText = {ObjectList = {}}
	local HealthbarFont = {value = 'LuckiestGuy'}
	local HealthbarColor = {Hue = 0, Sat = 0, Value = 0}
	local HealthbarBackground = {Hue = 0, Sat = 0, Value = 0}
	local HealthbarTextColor = {Hue = 0, Sat = 0, Value = 0}
	local healthbarobjects = {}
	local oldhealthbar
	local textconnection
	local function healthbarFunction()
		if not HealthbarMods.Enabled then 
			return 
		end
		local healthbar = ({pcall(function() return lplr.PlayerGui.hotbar['1'].HotbarHealthbarContainer.HealthbarProgressWrapper['1'] end)})[2]
		if healthbar and type(healthbar) == 'userdata' then 
			oldhealthbar = healthbar
			healthbar.BackgroundColor3 = HealthbarColorToggle.Enabled and Color3.fromHSV(HealthbarColor.Hue, HealthbarColor.Sat, HealthbarColor.Value) or healthbar.BackgroundColor3
			for i,v in next, (healthbar.Parent:GetChildren()) do 
				if v:IsA('Frame') and v:FindFirstChildWhichIsA('UICorner') == nil and HealthbarRound.Enabled then 
					table.insert(healthbarobjects, Instance.new('UICorner', v))
				end
			end
			local healthbarbackground = ({pcall(function() return healthbar.Parent.Parent end)})[2]
			if healthbarbackground and type(healthbarbackground) == 'userdata' then
				if healthbar.Parent.Parent:FindFirstChildWhichIsA('UICorner') == nil and HealthbarRound.Enabled then 
					table.insert(healthbarobjects, Instance.new('UICorner', healthbar.Parent.Parent))
				end 
				if HealthbarBackgroundToggle.Enabled then
					healthbarbackground.BackgroundColor3 = Color3.fromHSV(HealthbarBackground.Hue, HealthbarBackground.Sat, HealthbarBackground.Value)
				end
			end
			local healthbartext = ({pcall(function() return healthbar.Parent.Parent['1'] end)})[2]
			if healthbartext and type(healthbartext) == 'userdata' then 
				local randomtext = getrandomvalue(HealthbarText.ObjectList)
				if HealthbarTextColorToggle.Enabled then
					healthbartext.TextColor3 = Color3.fromHSV(HealthbarTextColor.Hue, HealthbarTextColor.Sat, HealthbarTextColor.Value)
				end
				if HealthbarFontToggle.Enabled then 
					healthbartext.Font = Enum.Font[HealthbarFont.Value]
				end
				if randomtext ~= '' and HealthbarTextToggle.Enabled then 
					healthbartext.Text = randomtext:gsub('<health>', entityLibrary.isAlive and tostring(math.floor(lplr.Character:GetAttribute('Health') or 0)) or '0')
				else
					pcall(function() healthbartext.Text = tostring(lplr.Character:GetAttribute('Health')) end)
				end
				if not textconnection then 
					textconnection = healthbartext:GetPropertyChangedSignal('Text'):Connect(function()
						local randomtext = getrandomvalue(HealthbarText.ObjectList)
						if randomtext ~= '' then 
							healthbartext.Text = randomtext:gsub('<health>', isAlive() and tostring(math.floor(lplr.Character:GetAttribute('Health') or 0)) or '0')
						else
							pcall(function() healthbartext.Text = tostring(math.floor(lplr.Character:GetAttribute('Health'))) end)
						end
					end)
				end
			end
		end
	end
	HealthbarMods = GuiLibrary.ObjectsThatCanBeSaved.NewVapeWindow.Api.CreateOptionsButton({
		Name = 'HealthbarMods',
		HoverText = 'Customize the color of your healthbar.\nAdd \'<health>\' to your custom text dropdown (if custom text enabled)to insert your health.',
		Function = function(callback)
			if callback then 
				task.spawn(function()
					table.insert(HealthbarMods.Connections, lplr.PlayerGui.DescendantAdded:Connect(function(v)
						if v.Name == 'HotbarHealthbarContainer' and v.Parent and v.Parent.Parent and v.Parent.Parent.Name == 'hotbar' then
							healthbarFunction()
						end
					end))
					healthbarFunction()
				end)
			else
				pcall(function() textconnection:Disconnect() end)
				pcall(function() oldhealthbar.Parent.Parent.BackgroundColor3 = Color3.fromRGB(41, 51, 65) end)
				pcall(function() oldhealthbar.BackgroundColor3 = Color3.fromRGB(203, 54, 36) end)
				pcall(function() oldhealthbar.Parent.Parent['1'].Text = tostring(lplr.Character:GetAttribute('Health')) end)
				pcall(function() oldhealthbar.Parent.Parent['1'].TextColor3 = Color3.fromRGB(255, 255, 255) end)
				pcall(function() oldhealthbar.Parent.Parent['1'].Font = Enum.Font.LuckiestGuy end)
				oldhealthbar = nil
				textconnection = nil
				for i,v in next, (healthbarobjects) do 
					pcall(function() v:Destroy() end)
				end
				table.clear(healthbarobjects)
			end
		end
	})
	HealthbarColorToggle = HealthbarMods.CreateToggle({
		Name = 'Main Color',
		Default = true,
		Function = function(callback)
			pcall(function() HealthbarColor.Object.Visible = callback end)
			if HealthbarMods.Enabled then
				HealthbarMods.ToggleButton(false)
				HealthbarMods.ToggleButton(false)
			end
		end 
	})
	HealthbarColor = HealthbarMods.CreateColorSlider({
		Name = 'Main Color',
		Function = function()
			task.spawn(healthbarFunction)
		end
	})
	HealthbarBackgroundToggle = HealthbarMods.CreateToggle({
		Name = 'Background Color',
		Function = function(callback)
			pcall(function() HealthbarBackground.Object.Visible = callback end)
			if HealthbarMods.Enabled then
				HealthbarMods.ToggleButton(false)
				HealthbarMods.ToggleButton(false)
			end
		end 
	})
	HealthbarBackground = HealthbarMods.CreateColorSlider({
		Name = 'Background Color',
		Function = function() 
			task.spawn(healthbarFunction)
		end
	})
	HealthbarTextToggle = HealthbarMods.CreateToggle({
		Name = 'Text',
		Function = function(callback)
			pcall(function() HealthbarText.Object.Visible = callback end)
			if HealthbarMods.Enabled then
				HealthbarMods.ToggleButton(false)
				HealthbarMods.ToggleButton(false)
			end
		end 
	})
	HealthbarText = HealthbarMods.CreateTextList({
		Name = 'Text',
		TempText = 'Healthbar Text',
		AddFunction = function()
			if HealthbarMods.Enabled then
				HealthbarMods.ToggleButton(false)
				HealthbarMods.ToggleButton(false)
			end
		end,
		RemoveFunction = function()
			if HealthbarMods.Enabled then
				HealthbarMods.ToggleButton(false)
				HealthbarMods.ToggleButton(false)
			end
		end
	})
	HealthbarTextColorToggle = HealthbarMods.CreateToggle({
		Name = 'Text Color',
		Function = function(callback)
			pcall(function() HealthbarTextColor.Object.Visible = callback end)
			if HealthbarMods.Enabled then
				HealthbarMods.ToggleButton(false)
				HealthbarMods.ToggleButton(false)
			end
		end 
	})
	HealthbarTextColor = HealthbarMods.CreateColorSlider({
		Name = 'Text Color',
		Function = function() 
			task.spawn(healthbarFunction)
		end
	})
	HealthbarFontToggle = HealthbarMods.CreateToggle({
		Name = 'Text Font',
		Function = function(callback)
			pcall(function() HealthbarFont.Object.Visible = callback end)
			if HealthbarMods.Enabled then
				HealthbarMods.ToggleButton(false)
				HealthbarMods.ToggleButton(false)
			end
		end 
	})
	HealthbarFont = HealthbarMods.CreateDropdown({
		Name = 'Text Font',
		List = getfontenums(),
		Function = function(callback)
			if HealthbarMods.Enabled then
				HealthbarMods.ToggleButton(false)
				HealthbarMods.ToggleButton(false)
			end
		end
	})
	HealthbarRound = HealthbarMods.CreateToggle({
		Name = 'Round',
		Function = function() 
			if HealthbarMods.Enabled then
				HealthbarMods.ToggleButton(false)
				HealthbarMods.ToggleButton(false)
			end
		end
	})
	HealthbarBackground.Object.Visible = false
	HealthbarText.Object.Visible = false
	HealthbarTextColor.Object.Visible = false
	HealthbarFont.Object.Visible = false
end)


--[[runFunction(function()
	local NameHider = {Enabled = true}

	local fakeplr = {Name = 'normal', UserId = '239702688'}
	local otherfakeplayers = {Name = 'immigrant', UserId = '1'}

	local function sanitizeString(_instance : Instance, property : String)
		for i,v in next, playersService:GetPlayers() do
			if v ~= lplr then
				_instance[property] = _instance[property]:gsub(v.Name, otherfakeplayers.Name)
				_instance[property] = _instance[property]:gsub(v.DisplayName, otherfakeplayers.Name)
				_instance[property] = _instance[property]:gsub(v.UserId, otherfakeplayers.UserId)
			else
				_instance[property] = _instance[property]:gsub(v.Name, fakeplr.Name)
				_instance[property] = _instance[property]:gsub(v.DisplayName, fakeplr.Name)
				_instance[property] = _instance[property]:gsub(v.UserId, fakeplr.UserId)
			end
		end
	end

	local function fixInstance(_instance : Instance)
		if _instance:IsA('TextLabel') or _instance:IsA('TextButton') then
			table.insert(NameHider.Connections, _instance:GetPropertyChangedSignal('Text'):Connect(function()
				sanitizeString(_instance, 'Text')
			end))
			sanitizeString(_instance, 'Text')
		end
		if _instance:IsA('ImageLabel') then
			table.insert(NameHider.Connections, _instance:GetPropertyChangedSignal('Image'):Connect(function()
				sanitizeString(_instance, 'Image')
			end))
			sanitizeString(_instance, 'Image')
		end
	end

	local function cleanDescendants(parent : Instance)
		for _, _instance in next, parent:GetDescendants() do
			fixInstance(_instance)
		end
		table.insert(NameHider.Connections, parent.DescendantAdded:Connect(fixInstance))
	end

	NameHider = GuiLibrary.ObjectsThatCanBeSaved.NewVapeWindow.Api.CreateOptionsButton({
		Name = 'NameHider',
		Function = function(callback)
			if callback then
				cleanDescendants(workspace)
				cleanDescendants(lplr.PlayerGui)
				cleanDescendants(coreGui)
			else
				singleWarning('NameHider', 'Join a new match to see names normally', 3) -- Not caching names and userids for disabling due to memory overloading + shit preformance
			end
		end
	})
end)]]

runFunction(function()
	local InfiniteJump = {Enabled = false}
	local InfiniteJumpHold = {Enabled = false}

	InfiniteJump = GuiLibrary.ObjectsThatCanBeSaved.NewVapeWindow.Api.CreateOptionsButton({
		Name = 'InfiniteJump',
		HoverText = 'Jump without touching the ground',
		Function = function(callback)
			if callback then
				local held = false
				table.insert(InfiniteJump.Connections, inputService.InputBegan:Connect(function(input)
					if input.KeyCode == Enum.KeyCode.Space and not inputService:GetFocusedTextBox() then
						held = true
						if entityLibrary.isAlive then
							if InfiniteJumpHold.Enabled then
								repeat
									entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
									task.wait()
								until not held or not InfiniteJump.Enabled or not InfiniteJumpHold.Enabled or inputService:GetFocusedTextBox()
							else
								entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
							end
						end
					end
				end))
				table.insert(InfiniteJump.Connections, inputService.InputEnded:Connect(function(input)
					if input.KeyCode == Enum.KeyCode.Space and not inputService:GetFocusedTextBox() then
						held = false
					end
				end))
			end
		end
	})
	InfiniteJumpHold = InfiniteJump.CreateToggle({
		Name = 'Hold',
		Function = function() end,
		HoverText = 'Hold down space to jump'
	})
end)
																																																																																																																																																																																																																																																																																												
																																																																																																																																																																																																																																																																																												
runFunction(function()
	local InfernalKill = {Enabled = false}
  InfernalKill = GuiLibrary["ObjectsThatCanBeSaved"]["NewVapeWindow"]["Api"].CreateOptionsButton({
	  ["Name"] = "4BigGuysExploit",
	  ["Function"] = function(callback)
		  if callback then
			  repeat
			  wait(0.001)
			  function getNil(name,class) for _,v in next, getnilinstances() do if v.ClassName==class and v.Name==name then return v;end end end
			  local args = {
				  [1] = {
					  ["chargeTime"] = 0.9,
					  ["player"] = game:GetService("Players").LocalPlayer,
					  ["weapon"] = getNil("infernal_saber", "Accessory")
				  }
			  }

			  game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("HellBladeRelease"):FireServer(unpack(args))
		  until not InfernalKill["Enabled"]
	  end
		  end,
		  ["HoverText"] = "Found By The Vape Private Team | Recreated By Skids"
	  })
  end)
