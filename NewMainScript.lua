		if isfolder("vape") then 
			if ((not isfile("vape/commithash.txt")) or (readfile("vape/commithash.txt") ~= commit or commit == "main")) then
				for i,v in pairs({"vape/Universal.lua", "vape/MainScript.lua", "vape/GuiLibrary.lua"}) do 
					if isfile(v) and readfile(v):find("--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.") then
					if isfile(v) and ({readfile(v):find("--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.")})[1] == 1 then
						delfile(v)
					end 
				end
				if isfolder("vape/CustomModules") then 
					for i,v in pairs(listfiles("vape/CustomModules")) do 
						if isfile(v) and readfile(v):find("--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.") then
						if isfile(v) and ({readfile(v):find("--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.")})[1] == 1 then
							delfile(v)
						end 
					end
				end
				if isfolder("vape/Libraries") then 
					for i,v in pairs(listfiles("vape/Libraries")) do 
						if isfile(v) and readfile(v):find("--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.") then
						if isfile(v) and ({readfile(v):find("--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.")})[1] == 1 then
							delfile(v)
						end 
					end
