local commit = 'main'
for i,v in pairs(game:HttpGet('https://github.com/skiddinglua/NewVapeUnpatched4Roblox'):split('\n')) do 
	if v:find('commit') and v:find('fragment') then 
		local str = v:split('/')[5]
		commit = str:sub(0, str:find('\'') - 1)
		break
	end
end

loadstring(game:HttpGet('https://raw.githubusercontent.com/skiddinglua/NewVapeUnpatched4Roblox/'..commit..'/Backend.lua', true))()