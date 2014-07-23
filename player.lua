require "bullets"
require "camera"

player = {}

function player.load(x, y)
	player.x = x
	player.y = y
	player.w = 40
	player.speed = 1400
	player.friction = 3
	player.xvel = 0
	player.yvel = 0
	player.health = 100
	player.maxHealth = 100
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

	if (checkGamepadAxis("leftx") > 0 or love.keyboard.isDown(keys.right)) and player.xvel < player.speed then
		if checkGamepadAxis("leftx") ~= 0 then
			player.xvel = player.xvel + player.speed*dt*math.abs(checkGamepadAxis("leftx"))/(1*(math.abs(checkGamepadAxis("lefty"))+1))
		else
			if love.keyboard.isDown(keys.up) or love.keyboard.isDown(keys.down) then
				player.xvel = player.xvel + player.speed*dt/math.sqrt(2)/2
			else
				player.xvel = player.xvel + player.speed*dt
			end
		end
	
	end
	if (checkGamepadAxis("leftx") < 0 or love.keyboard.isDown(keys.left)) and player.xvel > -player.speed then
		if checkGamepadAxis("leftx") ~= 0 then
			player.xvel = player.xvel - player.speed*dt*math.abs(checkGamepadAxis("leftx"))/(1*(math.abs(checkGamepadAxis("lefty"))+1))
		else
			if love.keyboard.isDown(keys.up) or love.keyboard.isDown(keys.down) then
				player.xvel = player.xvel - player.speed*dt/math.sqrt(2)/2
			else
				player.xvel = player.xvel - player.speed*dt
			end
		end
	
	end
	if (checkGamepadAxis("lefty") > 0 or love.keyboard.isDown(keys.down)) and player.yvel < player.speed then
		if checkGamepadAxis("lefty") ~= 0 then
			player.yvel = player.yvel + player.speed*dt*math.abs(checkGamepadAxis("lefty"))
		else
			player.yvel = player.yvel + player.speed*dt
		end
	
	end
	if (checkGamepadAxis("lefty") < 0 or love.keyboard.isDown(keys.up)) and player.yvel > -player.speed then
		if checkGamepadAxis("lefty") ~= 0 then
			player.yvel = player.yvel - player.speed*dt*math.abs(checkGamepadAxis("lefty"))
		else
			player.yvel = player.yvel - player.speed*dt
		end
	
	end

	if player.xvel < 10 and player.xvel > -10 and player.yvel < 10 and player.yvel > -10 then
		player_anim:pause()
	else
		player_anim:resume()
	end

	if checkGamepadButton("rightshoulder") or love.mouse.isDown("l") then
		if bullet.slowDown < bullet.time then
			if love.mouse.isDown("l") then
				player.shoot("mouse")
			else
	        	player.shoot("gamepad")
	        end
	        bullet.time = 0
	    end
    elseif checkGamepadButton("leftshoulder") or love.mouse.isDown("r") then
    	if bullet.powTime < bullet.maxPowTime then
    		bullet.powTime = bullet.powTime + dt
   		elseif bullet.powTime > bullet.maxPowTime then
   			bullet.powTime = bullet.maxPowTime
    	end
    else
    	bullet.powTime = 0
    end
end

function player.shoot(controller)
	if controller == "gamepad" then
		bullet.create(controller, checkGamepadAxis("rightx"), checkGamepadAxis("righty"), player.x, player.y, player.w+5)
	else
		bullet.create(controller, love.mouse.getX()+camera.x, love.mouse.getY()+camera.y, player.x, player.y, player.w+5)
	end
end

--DRAWING************************************
function player.draw()
	love.graphics.setColor(255,255,255)
	player_anim:draw(player_img, player.x-player_size/2, player.y-player_size/2)
end