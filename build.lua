require "map"
build = {}
build.curPos = {}

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
		currentMap.map[build.curPos.y][build.curPos.x] = "*"
		currentMap.health[build.curPos.y][build.curPos.x] = 60
	elseif key == "down" then
		build.curPos.y = build.curPos.y + 1
	elseif key == "up" then
		build.curPos.y = build.curPos.y - 1
	elseif key == "left" then
		build.curPos.x = build.curPos.x - 1
	elseif key == "right" then
		build.curPos.x = build.curPos.x + 1
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
end
