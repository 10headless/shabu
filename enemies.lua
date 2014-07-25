require "player"
require "bullets"

enemy = {}
enemies = {}
enemy.counter = 1

function enemy.load(x, y, w, speed, health,dmg, friction)
	table.insert(enemies, {id = enemy.counter, x = x, y = y, w = w, speed = speed, friction = friction,health = health, maxHealth = health, damage = dmg, xvel = 0, yvel =0})
	enemy.counter = enemy.counter + 1
end


--UPDATING**********************************
function enemy.update(dt)
	enemy.move(dt)
	enemy.collisionCheck(dt)
end

function enemy.move(dt)
	for i, v in ipairs(enemies) do
		rX = v.x - player.x
		rY = v.y - player.y
		local at = math.atan2(math.abs(rY), math.abs(rX))
		local abY = math.sin(at) * v.speed
		local abX = math.sqrt(v.speed^2 - abY^2 )
		if rX > 0 then
			abX = -abX
		end
		if rY > 0 then
			abY = -abY
		end
		v.xvel = v.xvel + abX * dt
		v.yvel = v.yvel + abY * dt
		v.xvel = v.xvel * (1 - math.min(dt*v.friction, 1))
		v.yvel = v.yvel * (1 - math.min(dt*v.friction, 1))
		v.x = v.x + v.xvel*dt
		v.y = v.y + v.yvel*dt
	end
end

function enemy.collisionCheck(dt)
	remEnemy = {}
	remShots = {}
	for i, v in ipairs(enemies) do
		for j, b in ipairs(bullets) do
			if checkCircleDis({x = b.x, y = b.y, w = b.w},{x = v.x, y = v.y, w = v.w}) then
				v.health = v.health - b.dmg
				table.insert(remShots, j)
			end
		end
		if checkColl("cc", player, v) then
			player.health = player.health - v.damage
			table.insert(remEnemy, i)
			if player.health <= 0 then
				love.event.quit()
			end
		end
		if v.health <= 0 then
			table.insert(remEnemy, i)
		end
	end

	for i, v in ipairs(remEnemy) do
		table.remove(enemies, v)
	end
	for i, v in ipairs(remShots) do
		table.remove(bullets, v)
	end
end


--DRAWING************************************
function enemy.draw()
	for i, v in ipairs(enemies) do
		love.graphics.setColor(255,255,255)
		love.graphics.draw(enemy_img, v.x-v.w, v.y-v.w)
	end
end