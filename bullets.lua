bullet = {}
bullets = {}
bullet.speed = 500
bullet.w = 5
bullet.slowDown = .3
bullet.time = 0
bullet.powTime = 0
bullet.maxPowTime = 1
bullet.wAddPow = 10
bullet.DMG = 20

function bullet.create(axisX, axisY, pX, pY, pW)
	if not (axisY == 0 and axisX == 0) then
		local tmp = math.atan2(math.abs(axisY), math.abs(axisX))
		local yv = math.sin(tmp)*bullet.speed
		local xv1 = bullet.speed^2 - yv^2 
		local xv2 = math.sqrt(xv1) 
		if axisX < 0 then
			xv2 = -xv2
		end
		if axisY < 0 then
			yv = -yv
		end
		local ymove = math.sin(tmp)*pW
		local xmove1 = pW^2 - ymove^2 
		local xmove2 = math.sqrt(xmove1) 
		if axisX < 0 then
			xmove2 = -xmove2
		end
		if axisY < 0 then
			ymove = -ymove
		end
		if power ~= 0 then
			table.insert(bullets, {x = pX+xmove2, y = pY+ymove, xvel = xv2, yvel = yv, w = bullet.w+bullet.wAddPow*(bullet.powTime/bullet.maxPowTime), dmg = bullet.DMG+bullet.DMG*(bullet.powTime/bullet.maxPowTime)})
			bullet.powTime = 0
		else
			table.insert(bullets, {x = pX+xmove2, y = pY+ymove, xvel = xv2, yvel = yv, w = bullet.w, dmg = bullet.DMG})
		end
	end 
end

function bullet.draw()
	for i, v in ipairs(bullets) do
		love.graphics.setColor(0,255,0)
		love.graphics.circle("fill", v.x, v.y, v.w)
	end
end

function bullet.update(dt)
	for i, v in ipairs(bullets) do
		v.x = v.x + v.xvel*dt
		v.y = v.y + v.yvel*dt
	end
end