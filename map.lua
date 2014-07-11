require "player"
require "bullets"
require "enemies"
map = {}
currentMap = {}
currentMap.health = {{}}
currentMap.color = {}
solids = {"*", "^"}

function map.load(name)
	love.filesystem.load("maps/"..name) ()
	local rows = m:split("\n")
	local MAPP = {}
	for i, v in ipairs(rows) do
		local tmp1 = {}
		for j = 1, s.w do
			table.insert(tmp1, v:sub(j,j))
		end
		table.insert(MAPP, tmp1)
	end
	currentMap.map = MAPP
	currentMap.health = {}
	local spawnersCount = 1
	for i, v in ipairs(MAPP) do
		currentMap.health[i] = {}
		for j, b in ipairs(v) do
			if b == "*" then
				currentMap.health[i][j] = 60 
			elseif b == " " then
				currentMap.health[i][j] = 0
			elseif b == "^" then
				currentMap.health[i][j] = 100
				spa[spawnersCount].x = j
				spa[spawnersCount].y = i
				spa[spawnersCount].spawn = true
				spawnersCount= spawnersCount+1
			end
		end
	end
	currentMap.size = s
	currentMap.spawners = spa
end

function map.draw()
	spawnersCount = 1
	for i, v in ipairs(currentMap.map) do
		for j = 1, currentMap.size.w do 
			local char = v[j]
			if char == "*" then
				love.graphics.setColor(50,50,50)
				love.graphics.rectangle("fill", (j-1)*40, (i-1)*40, 40, 40)
				--COLLISION HANDLING****
				map.checkCollision((j-1)*40, (i-1)*40, 40, char)
			end
			if char == "^" then
				local tmpSpawner = currentMap.spawners[spawnersCount]
				if tmpSpawner.typ == 1 then
					love.graphics.setColor(50,50,50)
					love.graphics.rectangle("fill", (j-1)*40, (i-1)*40, 40, 40)
					love.graphics.setColor(0,0,255)
					love.graphics.circle("fill", (j-1)*40+20, (i-1)*40+20, 12.5)
				end
				map.checkCollision((j-1)*40, (i-1)*40, 40, char)
				spawnersCount = spawnersCount + 1
			end
		end
	end
end

function map.checkCollision(mX, mY, mW, ch)
	remShots = {}
	for i, v in ipairs(bullets) do
		if v.x <= 0 or v.x >= currentMap.size.w*40 or v.y <= 0 or v.y >= currentMap.size.h*40 then
			table.insert(remShots, i)
		end
	end
	for i, v in ipairs(remShots) do
		table.remove(bullets, v)
	end
	if checkColl("rc", {x = mX, y = mY, w = mW}, player) then
		sth = ""
		if player.x+player.w >= mX and player.x+player.w <= mX + mW/2 and player.xvel > 0 then
			sth = sth .. "r"
		end
		if player.x-player.w <= mX+mW and player.x-player.w >= mX + mW/2 and player.xvel < 0 then
			sth = sth .. "l"
		end
		if player.y+player.w >= mY and player.y+player.w <= mY + mW/2 and player.yvel > 0 then
			sth = sth .. "d"
		end
		if player.y-player.w <= mY+mW and player.y-player.w >= mY + mW/2 and player.yvel < 0 then
			sth = sth .. "u"
		end
		if sth == "r" then
			player.xvel = 0
			player.x = mX-player.w
		elseif sth == "l" then
			player.xvel = 0
			player.x = mX+player.w*2
		elseif sth == "d" then
			player.yvel = 0
			player.y = mY-player.w
		elseif sth == "u" then
			player.yvel = 0
			player.y = mY+player.w*2
		end
	end
	for i, v in ipairs(enemies) do
		if checkColl("rc", {x = mX, y = mY, w = mW}, v) then
			sth = ""
			if v.x+v.w >= mX and v.x+v.w <= mX + mW/2 and v.xvel > 0 then
				sth = sth .. "r"
			end
			if v.x-v.w <= mX+mW and v.x-v.w >= mX + mW/2 and v.xvel < 0 then
				sth = sth .. "l"
			end
			if v.y+v.w >= mY and v.y+v.w <= mY + mW/2 and v.yvel > 0 then
				sth = sth .. "d"
			end
			if v.y-v.w <= mY+mW and v.y-v.w >= mY + mW/2 and v.yvel < 0 then
				sth = sth .. "u"
			end
			if sth == "r" then
				v.xvel = 0
				v.x = mX-v.w
			elseif sth == "l" then
				v.xvel = 0
				v.x = mX+v.w*2
			elseif sth == "d" then
				v.yvel = 0
				v.y = mY-v.w
			elseif sth == "u" then
				v.yvel = 0
				v.y = mY+v.w*2
			end
		end
	end
	remWalls = {}
	remShots = {}
	for i, v in ipairs(bullets) do
		if checkColl("rc", {x = mX, y = mY, w = mW}, {x= v.x, y = v.y, w = bullet.w}) then
			local RTx = mX/40+1
			local RTy = mY/40+1
			currentMap.health[RTy][RTx] = currentMap.health[RTy][RTx] - v.dmg
			table.insert(remShots, i)
			if currentMap.health[RTy][RTx] <= 0 then
				table.insert(remWalls, {x = RTx, y = RTy})
				if ch == "^" then
					for j, b in ipairs(currentMap.spawners) do
						if b.x == RTx and b.y == RTy then
							b.spawn = false
						end
					end
				end
			end
		end
	end
	for i, v in ipairs(remWalls) do
		currentMap.map[v.y][v.x] =" "
	end
	for i, v in ipairs(remShots) do
		table.remove(bullets, v)
	end
end

function map.updateSpawners(dt)
	for i, v in ipairs(currentMap.spawners) do
		if v.spawn then
			v.timer = v.timer + dt
			if v.timer >= v.spawnTime then
				v.timer = 0
				if v.typ == 1 then
					local happend = false
					if not isBlockSolid(currentMap.map[v.y][v.x-1]) and not isBlockSolid(currentMap.map[v.y][v.x-2]) and not isBlockSolid(currentMap.map[v.y-1][v.x-1]) and not isBlockSolid(currentMap.map[v.y+1][v.x-1]) then
						enemy.load((v.x-3)*40+20, (v.y-1)*40+20, 40, 100,100)
						happend = true
					end
					if not happend and not isBlockSolid(currentMap.map[v.y][v.x+1]) and not isBlockSolid(currentMap.map[v.y][v.x+2]) and not isBlockSolid(currentMap.map[v.y-1][v.x+1]) and not isBlockSolid(currentMap.map[v.y+1][v.x+1]) then
						enemy.load((v.x+1)*40+20, (v.y-1)*40+20, 40, 100,100)
						happend = true
					end
					if not happend and not isBlockSolid(currentMap.map[v.y-1][v.x]) and not isBlockSolid(currentMap.map[v.y-2][v.x]) and not isBlockSolid(currentMap.map[v.y-1][v.x-1]) and not isBlockSolid(currentMap.map[v.y-1][v.x+1]) then
						enemy.load((v.x-1)*40+20, (v.y-3)*40+20, 40, 100,100)
						happend = true
					end
					if not happend and not isBlockSolid(currentMap.map[v.y+1][v.x]) and not isBlockSolid(currentMap.map[v.y+2][v.x]) and not isBlockSolid(currentMap.map[v.y+1][v.x-1]) and not isBlockSolid(currentMap.map[v.y-1][v.x+1]) then
						enemy.load((v.x-1)*40+20, (v.y+1)*40+20, 40, 100,100)
						happend = true
					end
				end
			end
		end
	end
end