require "bullets"

player = {}

function player.load(x, y)
	player.x = x
	player.y = y
	player.w = 40
	player.speed = 1400
	player.friction = 3
	player.xvel = 0
	player.yvel = 0
end

--UPDATING**********************************
function player.update(dt)
	bullet.time = bullet.time +dt
	player.control(dt)
	player.physics(dt)
end

function player.physics(dt)
	player.x = player.x + player.xvel * dt
	player.y = player.y + player.yvel * dt
	player.xvel = player.xvel * (1 - math.min(dt*player.friction, 1))
	player.yvel = player.yvel * (1 - math.min(dt*player.friction, 1))
end

function player.control(dt)
	if joystick:getGamepadAxis("leftx") > 0 and player.xvel < player.speed then
		player.xvel = player.xvel + player.speed*dt*math.abs(joystick:getGamepadAxis("leftx"))/(1*(math.abs(joystick:getGamepadAxis("lefty"))+1))
	end
	if joystick:getGamepadAxis("leftx") < 0 and player.xvel > -player.speed then
		player.xvel = player.xvel - player.speed*dt*math.abs(joystick:getGamepadAxis("leftx"))/(1*(math.abs(joystick:getGamepadAxis("lefty"))+1))
	end
	if joystick:getGamepadAxis("lefty") > 0 and player.yvel < player.speed then
		player.yvel = player.yvel + player.speed*dt*math.abs(joystick:getGamepadAxis("lefty"))
	end
	if joystick:getGamepadAxis("lefty") < 0 and player.yvel > -player.speed then
		player.yvel = player.yvel - player.speed*dt*math.abs(joystick:getGamepadAxis("lefty"))
	end
	if joystick:isGamepadDown("rightshoulder") then
		if bullet.slowDown < bullet.time then
	        player.shoot()
	        bullet.time = 0
	    end
    elseif joystick:isGamepadDown("leftshoulder") then
    	if bullet.powTime < bullet.maxPowTime then
    		bullet.powTime = bullet.powTime + dt
   		elseif bullet.powTime > bullet.maxPowTime then
   			bullet.powTime = bullet.maxPowTime
    	end
    else
    	bullet.powTime = 0
    end
end

function player.shoot()
	bullet.create(joystick:getGamepadAxis("rightx"), joystick:getGamepadAxis("righty"), player.x, player.y, player.w+5)
end

--DRAWING************************************
function player.draw()
	love.graphics.setColor(0,0,0)
	love.graphics.circle("fill", player.x, player.y, player.w)
end