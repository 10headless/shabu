materials = {}

function materials.loveLoad()
	solids = {"*", "^", "?", "#", "%", "$"}
	buildMat = {
	{char = "#", health = 100000},
	{char = "%", health = 40},
	{char = "$", health = 5}
	}
	notDestroy = {"$", "^"}
end

function materials.load(char, x, y,sp)
	if char == "^" then
		currentMap.spawners[sp].x = x
		currentMap.spawners[sp].y = y
		currentMap.spawners[sp].spawn = true
		if currentMap.spawners[sp].typ == 1 then
			return 100, 0
		elseif currentMap.spawners[sp].typ == 2 then
			return 100, 0
		end
	elseif char == " " then
		return 0, 0
	elseif char == "*" then
		local r = math.random(1, 3)
		return 100000, r
	end
end

function materials.draw(char, x, y)
	if char == "*" then
		love.graphics.setColor(255,255,255)
		local ori = currentMap.orient[y][x]
		love.graphics.draw(stone_img[currentMap.orient[y][x]], (x-1)*40, (y-1)*40)
		--COLLISION HANDLING****
		map.checkCollision((x-1)*40, (y-1)*40, 40, char)
	end
	if char == "^" then
		local tmpSpawner = currentMap.spawners[spawnersCount]
		if tmpSpawner.typ == 1 or tmpSpawner.typ == 2 then
			love.graphics.setColor(50,50,50)
			love.graphics.rectangle("fill", (x-1)*40, (y-1)*40, 40, 40)
			love.graphics.polygon("fill", (x-1)*40, (y-1)*40, x*40, (y-1)*40, (x-1)*40+20, (y-1)*40-20)
			love.graphics.polygon("fill", (x-1)*40, (y-1)*40, (x-1)*40, (y)*40, (x-1)*40-20, (y-1)*40+20)
			love.graphics.polygon("fill", (x-1)*40, (y)*40, x*40, (y)*40, (x-1)*40+20, (y+1)*40-20)
			love.graphics.polygon("fill", (x)*40, (y-1)*40, x*40, (y)*40, (x)*40+20, (y)*40-20)
			love.graphics.setColor(0,0,255)
			love.graphics.circle("fill", (x-1)*40+20, (y-1)*40+20, 12.5)
		end
		map.checkCollision((x-1)*40, (y-1)*40, 40, char)
		spawnersCount = spawnersCount + 1
	end
	if char == "#" then
		love.graphics.setColor(255,255,255)
		love.graphics.draw(stone_img[1], (x-1)*40, (y-1)*40)
		--COLLISION HANDLING****
		map.checkCollision((x-1)*40, (y-1)*40, 40, char)
	end
	if char == "%" then
		love.graphics.setColor(255,255,255)
		love.graphics.draw(dirt_img, (x-1)*40, (y-1)*40)
		--COLLISION HANDLING****
		map.checkCollision((x-1)*40, (y-1)*40, 40, char)
	end
	if char == "$" then
		love.graphics.setColor(50,50,50)
		love.graphics.rectangle("fill", (x-1)*40, (y-1)*40, 40, 40)
		love.graphics.setColor(255,0,0)
		love.graphics.circle("fill", (x-1)*40+20, (y-1)*40+20, 12.5)
		map.checkCollision((x-1)*40, (y-1)*40, 40, char)
	end
end