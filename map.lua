require "player"
require "bullets"
require "enemies"
require "materials"
map = {}
currentMap = {}
currentMap.health = {{}}
currentMap.color = {}
currentMap.destroyWalls = {}
currentMap.bombs = {}
ids = {}
bomb = {}
bomb.range = 140

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
	currentMap.spawners = deepcopy(spa)
	currentMap.map = MAPP
	currentMap.health = {}
	local spawnersCount = 1
	for i, v in ipairs(MAPP) do
		currentMap.health[i] = {}
		for j, b in ipairs(v) do
			currentMap.health[i][j] = materials.load(b, j, i, spawnersCount)
			if b == "^" then
				spawnersCount = spawnersCount + 1
			end
		end
	end
	currentMap.size = s
end

function map.draw()
	spawnersCount = 1
	destroyWalls = {}
	for i, v in ipairs(currentMap.map) do
		for j = 1, currentMap.size.w do 
			materials.draw(v[j], j, i)
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
			player.xvel = 0
			player.x = player.x -0.1
			cRight = true
		else
			cRight = false
		end
		if player.x-player.w <= mX+mW and player.x-player.w >= mX + mW/2 and player.xvel < 0 then
			player.xvel = 0
			player.x = player.x +0.1
			cLeft = true
		else
			cLeft = false
		end
		if player.y+player.w >= mY and player.y+player.w <= mY + mW/2 and player.yvel > 0 then
			player.yvel = 0
			player.y = player.y -0.1
			cDown = true
		else
			cDown = false
		end
		if player.y-player.w <= mY+mW and player.y-player.w >= mY + mW/2 and player.yvel < 0 then
			player.yvel = 0
			player.y = player.y +0.1
			cUp = true
		else
			cUp = false
		end
	else
		cUp = false
		cDown = false
		cLeft = false
		cRight = false
	end
	local remDess = {}
	for j,b in ipairs(currentMap.destroyWalls) do
		local hap = false
		for i, v in ipairs(ids) do
			if b.enemyID == v then
				hap = true
			end
		end
		if not hap then
			table.insert(remDess, j)
		end
	end
	for i, v in ipairs(remDess) do
		table.remove(currentMap.destroyWalls, v)
	end
	local wallTouched = false
	local enemyPower = 0
	local enemyID = 0
	

	for i, v in ipairs(enemies) do
		if checkColl("rc", {x = mX, y = mY, w = mW}, v) then
			if v.x+v.w >= mX and v.x+v.w <= mX + mW/2 and v.xvel > 0 then
				v.xvel = 0
				v.x = v.x -1
			end
			if v.x-v.w <= mX+mW and v.x-v.w >= mX + mW/2 and v.xvel < 0 then
				v.xvel = 0
				v.x = v.x +1
			end
			if v.y+v.w >= mY and v.y+v.w <= mY + mW/2 and v.yvel > 0 then
				v.yvel = 0
				v.y = v.y -1
			end
			if v.y-v.w <= mY+mW and v.y-v.w >= mY + mW/2 and v.yvel < 0 then
				v.yvel = 0
				v.y = v.y + 1
			end
			local yes = true
			for j, b in ipairs(notDestroy) do
				if b == ch then yes = false end
			end
			if yes then
				wallTouched = true
				table.insert(ids, enemyID)
				if enemyPower < v.damage then
					enemyPower = v.damage
					enemyID = v.id
				end
			end
		end
	end
	if wallTouched then
		local sth = false
		for i, v in ipairs(currentMap.destroyWalls) do
			if v.enemyID == enemyID then
				sth = true
			end
			if v.x == mX/40+1 and v.y == mY/40+1 then
				sth = true
			end
		end
		if not sth then
			table.insert(currentMap.destroyWalls, {x = mX/40+1, y = mY/40+1, dmgPS = enemyPower, enemyID = enemyID, des = false})
		end
	end
	remWalls = {}
	remShots = {}
	for i, v in ipairs(bullets) do
		if ch == "^" then
			if checkColl("rc", {x1 = mX+20, y1 = mY-20, x2 = mX+60, y2 = mY+20, x3 = mX+20, y3 = mY+60, x4 = mX-20, y4 = mY+20, autom = true}, {x= v.x, y = v.y, w = bullet.w}) then
				local RTx = mX/40+1
				local RTy = mY/40+1
				currentMap.health[RTy][RTx] = currentMap.health[RTy][RTx] - v.dmg
				table.insert(remShots, i)
				if currentMap.health[RTy][RTx] <= 0 then
					table.insert(remWalls, {x = RTx, y = RTy})
					for j, b in ipairs(currentMap.spawners) do
						if b.x == RTx and b.y == RTy then
							b.spawn = false
						end
					end
					table.insert(explosions, {anim = explosion_anim:clone(), x =mX+20, y = mY+20, scale = 1.5})
				end
			end
		else
			if checkColl("rc", {x = mX, y = mY, w = mW}, {x= v.x, y = v.y, w = bullet.w}) then
				local RTx = mX/40+1
				local RTy = mY/40+1
				currentMap.health[RTy][RTx] = currentMap.health[RTy][RTx] - v.dmg
				table.insert(remShots, i)
				if currentMap.health[RTy][RTx] <= 0 then
					table.insert(remWalls, {x = RTx, y = RTy})
					table.insert(explosions, {anim = explosion_anim:clone(), x = mX+20, y = mY+20, scale = 0.8})
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

function map.update(dt)
	for i, v in ipairs(currentMap.spawners) do
		if v.spawn then
			v.timer = v.timer + dt
			if v.timer >= v.spawnTime then
				v.timer = 0
				local tmpTh = {}
				if v.typ == 1 then
					tmpTh.speed = 100
					tmpTh.maxHealth = 100
					tmpTh.radius = 40
					tmpTh.damage = 50
				end
				if v.typ == 2 then
					tmpTh.speed = 150
					tmpTh.maxHealth = 50
					tmpTh.radius = 20
					tmpTh.damage = 20
				end
				local happend = false
				if not isBlockSolid(currentMap.map[v.y][v.x-1]) and not isBlockSolid(currentMap.map[v.y][v.x-2]) and not isBlockSolid(currentMap.map[v.y-1][v.x-1]) and not isBlockSolid(currentMap.map[v.y+1][v.x-1]) then
					enemy.load((v.x-3)*40+20, (v.y-1)*40+20, tmpTh.radius, tmpTh.speed,tmpTh.maxHealth, tmpTh.damage)
					happend = true
				end
				if not happend and not isBlockSolid(currentMap.map[v.y][v.x+1]) and not isBlockSolid(currentMap.map[v.y][v.x+2]) and not isBlockSolid(currentMap.map[v.y-1][v.x+1]) and not isBlockSolid(currentMap.map[v.y+1][v.x+1]) then
					enemy.load((v.x+1)*40+20, (v.y-1)*40+20, tmpTh.radius, tmpTh.speed,tmpTh.maxHealth, tmpTh.damage)
					happend = true
				end
				if not happend and not isBlockSolid(currentMap.map[v.y-1][v.x]) and not isBlockSolid(currentMap.map[v.y-2][v.x]) and not isBlockSolid(currentMap.map[v.y-1][v.x-1]) and not isBlockSolid(currentMap.map[v.y-1][v.x+1]) then
					enemy.load((v.x-1)*40+20, (v.y-3)*40+20, tmpTh.radius, tmpTh.speed,tmpTh.maxHealth, tmpTh.damage)
					happend = true
				end
				if not happend and not isBlockSolid(currentMap.map[v.y+1][v.x]) and not isBlockSolid(currentMap.map[v.y+2][v.x]) and not isBlockSolid(currentMap.map[v.y+1][v.x-1]) and not isBlockSolid(currentMap.map[v.y-1][v.x+1]) then
					enemy.load((v.x-1)*40+20, (v.y+1)*40+20, tmpTh.radius, tmpTh.speed,tmpTh.maxHealth, tmpTh.damage)
					happend = true
				end
			
			end
		end
	end
	local remWalls = {}
	local remFromDestroy = {}
	local remFromBombs = {}
	for i, v in ipairs(currentMap.destroyWalls) do
		currentMap.health[v.y][v.x] = currentMap.health[v.y][v.x] - v.dmgPS *dt
		if currentMap.health[v.y][v.x] <= 0 then
			table.insert(remWalls, {x = v.x, y = v.y})
			table.insert(remFromDestroy, i)
		end
	end
	for i, v in ipairs(currentMap.bombs) do
		if v.activated then
			currentMap.health[v.y][v.x] = currentMap.health[v.y][v.x] - 1*dt
			if currentMap.health[v.y][v.x] <= 0 then
				table.insert(remWalls, {x = v.x, y = v.y})
				table.insert(remFromBombs, i)
				table.insert(explosions, {anim = explosion_anim:clone(), x = v.x*40-20, y = v.y*40-20, scale = 3.5})
				for j, b in ipairs(enemies) do
					local di = calcDis(b.x, b.y, b.w, v.x*40-20, v.y*40-20, bomb.range)
					if di < 0 then
						local damage = bomb.range/math.abs(di)*60+40
						b.health = b.health-damage
					end
 				end
			end
		end
	end
	for i, v in ipairs(remWalls) do
		currentMap.map[v.y][v.x] =" "
		table.insert(explosions, {anim = explosion_anim:clone(), x = v.x*40-20, y = v.y*40-20, scale = 0.7})
	end
	for i, v in ipairs(remFromDestroy) do
		table.remove(currentMap.destroyWalls, v)
	end
	for i, v in ipairs(remFromBombs) do
		table.remove(currentMap.bombs, v)
	end
end