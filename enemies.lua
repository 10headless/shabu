require "player"
require "bullets"

enemy = {}
enemies = {}

function enemy.load(x, y, w, speed, health,dmg)
	table.insert(enemies, {x = x, y = y, w = w, speed = speed, health = health, maxHealth = health, damage = dmg, xvel = 0, yvel =0})
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
		v.x = v.x + v.xvel * dt
		v.y = v.y + v.yvel * dt
		v.xvel = abX
		v.yvel = abY
	end
	enemy.collisionCheck(dt)
end

function enemy.collisionCheck(dt)
	remEnemy = {}
	remShots = {}
	for i, v in ipairs(enemies) do
		for j, b in ipairs(bullets) do
			if checkCircleDis({x = b.x, y = b.y, w = b.w},{x = v.x, y = v.y, w = v.w}) then
				v.health = v.health - b.dmg
				table.insert(remShots, j)
				if v.health <= 0 then
					table.insert(remEnemy, i)
				end
			end
		end
		if checkColl("cc", player, v) then
			player.health = player.health - v.damage
			table.insert(remEnemy, i)
			if player.health <= 0 then
				love.event.quit()
			end
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
		love.graphics.setColor(0,0,255)
		love.graphics.circle("fill", v.x, v.y, v.w)
		love.graphics.setColor(255,0,0)
		love.graphics.arc( "fill", v.x, v.y, v.w, 0, (math.pi*2)*(v.health/v.maxHealth))
		love.graphics.setColor(0,0,255)
		love.graphics.circle("fill", v.x, v.y, v.w-7)
	end
end