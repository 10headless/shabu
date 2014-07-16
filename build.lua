require "map"
require "materials"
build = {}
build.curPos = {}
build.chosenBlock = 1

function build.load(pX, pY)
	for i, v in ipairs(currentMap.map) do
		for j = 1, currentMap.size.w do 
			local x, y = (j-1)*40, (i-1)*40
			if x/40 == math.floor(x/40) then
				x=x+1
			end
			if y/40 == math.floor(y/40) then
				y=y+1
			end
			if pX > x and pX < x+40 then
				if pY > y and pY < y+40 then
					build.curPos = {x = j, y = i}
				end
			end
		end
	end
end

function build.update(key)
	if key == "ok" then
		if currentMap.map[build.curPos.y][build.curPos.y] == " " then
			currentMap.map[build.curPos.y][build.curPos.x] = buildMat[build.chosenBlock].char
			currentMap.health[build.curPos.y][build.curPos.x] = buildMat[build.chosenBlock].health
		end
	elseif key == "down" then
		build.curPos.y = build.curPos.y + 1
	elseif key == "up" then
		build.curPos.y = build.curPos.y - 1
	elseif key == "left" then
		build.curPos.x = build.curPos.x - 1
	elseif key == "right" then
		build.curPos.x = build.curPos.x + 1
	elseif key == "change" then
		if build.chosenBlock == #buildMat then
			build.chosenBlock = 1
		else
			build.chosenBlock = build.chosenBlock + 1
		end
	end
end

function build.draw()
	for i, v in ipairs(currentMap.map) do
		for j = 1, currentMap.size.w do 
			local x, y = (j-1)*40, (i-1)*40
			if j == build.curPos.x and i == build.curPos.y then
				love.graphics.setColor(0,255,0)
				love.graphics.rectangle("line", x+2, y+2, 36, 36)
			else
				love.graphics.setColor(150,150,150)
				love.graphics.rectangle("line", x, y, 40, 40)
			end
		end
	end
	love.graphics.setColor(135, 175, 199)
	love.graphics.rectangle("fill", 0+camera.x, 720-60, #buildMat*45+5, 60)
	for i = 1, #buildMat do
		local block = buildMat[i]
		if block.char == "#" then
			love.graphics.setColor(100, 100, 100)
			love.graphics.rectangle("fill", 0+camera.x+5*i+40*(i-1), 720-45, 40, 40)
		elseif block.char == "%" then
			love.graphics.setColor(155,118,83)
			love.graphics.rectangle("fill", 0+camera.x+5*i+40*(i-1), 720-45, 40, 40)
		elseif block.char == "$" then
			love.graphics.setColor(50,50,50)
			love.graphics.rectangle("fill", 0+camera.x+5*i+40*(i-1), 720-45, 40, 40)
			love.graphics.setColor(255,0,0)
			love.graphics.circle("fill", 0+camera.x+5*i+40*(i-1)+20, 720-25, 12.5)
		end
		if i == build.chosenBlock then
			love.graphics.setColor(0,255,0)
			love.graphics.rectangle("line", 0+camera.x+5*i+40*(i-1), 720-45, 40, 40)
		end
	end
end
