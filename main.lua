require "player"
require "bullets"
require "enemies"
require "map"
require "camera"
require "strong"
require "build"
anim8 = require 'anim8'

keys = {left = "a",right = "d",up = "w",down = "s",build = "lctrl", ok = "return", change = " "}
gamestate = "game"
explosions = {}


function love.load()
    local joysticks = love.joystick.getJoysticks()
    joystick = joysticks[1]
    love.graphics.setBackgroundColor(200,200,200)
    player.load(200, 200)
    map.load("testMap.lua")
    myShader = love.graphics.newShader[[vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
        {
            vec4 texcolor = Texel(texture, texture_coords);
            return texcolor * color/2;
        }]]
        myShader3 = love.graphics.newShader[[vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
        {
            vec4 texcolor = Texel(texture, texture_coords);
            vec4 tmp = texcolor * color;
            tmp.r = 0;
            return tmp;
        }]]
    myShader2 = love.graphics.newShader[[vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
        {
            return vec4(1,0,0,10);
        }]]

    explosion_image = love.graphics.newImage('assets/explosion.png')
    explosion_grid = anim8.newGrid(64,64, 320,320, 0, 2)
    explosion_anim = anim8.newAnimation(explosion_grid('1-5',1,'1-5',2,'1-5',3,'1-5',4,'1-5',5), {['1-3']= 0.01,['4-16'] = 0.02, ['17-25']=0.045}, "pauseAtEnd")
    explosion_size = 64
end

function love.update(dt)
    if gamestate == "game" then
        player.update(dt)
        bullet.update(dt)
        enemy.update(dt)
        map.update(dt)

        local remExplosions = {}
        for i, v in ipairs(explosions) do
            v.anim:update(dt)
            if v.anim.status == "paused" then
                table.insert(remExplosions, i)
            end
        end
        for i, v in ipairs(remExplosions) do
            table.remove(explosions, v)
        end
    end
    if gamestate == "pause" then
        build.update(dt)
    end
end

function love.draw()
    camera:set()
    if gamestate == "pause" then
        love.graphics.setShader(myShader)
    end
    if player.x >= (1280/2)-(player.w/2) and player.x <= currentMap.size.w*40-(1280/2)-(player.w/2)then
        camera.x = player.x-(1280/2)+(player.w/2)
    end 
    if player.y >= (720/2)-(player.w/2) and player.y <= currentMap.size.h*40-(720/2)-(player.w/2)then
        camera.y = player.y-(720/2)+(player.w/2)
    end 
    
    player.draw()
    bullet.draw()
    enemy.draw()
    map.draw()
    for i, v in ipairs(explosions) do
        love.graphics.setColor(255,255,255)
        v.anim:draw(explosion_image, v.x-explosion_size*v.scale/2, v.y-explosion_size*v.scale/2, 0, v.scale)
    end

    love.graphics.setShader()
     if gamestate == "pause" then
        build.draw()
        
    end
    camera:unset()
end

function checkCircleDis(circleA, circleB)
    local dist = (circleA.x - circleB.x)^2 + (circleA.y - circleB.y)^2
    return dist <= (circleA.w + circleB.w)^2
end

function checkColl(type, o1, o2)
	if type == "cc" then
		return checkCircleDis(o1, o2)
	elseif type == "rc" then
        o1.w1 = o1.w
        if o1.autom ~= nil then
            local tmpx1 = o1.x3 - o1.x4
            local tmpy1 = o1.y3 - o1.y4
            o1.w = math.sqrt(tmpx1^2 + tmpy1^2)
            o1.x = o1.x1
            o1.y = o1.y1 +40
            o1.w1 = 0
        end
		if checkCircleDis({x = o1.x+o1.w1/2, y = o1.y+o1.w1/2, w = o1.w/2}, o2) then
            return true
        else
            for tmp = 1, 4 do
                local tmpX = 0
                local tmpY = 0
                if o1.autom == nil then
                    if tmp == 1 then
                        tmpX = o1.x
                        tmpY = o1.y
                    elseif tmp == 2 then
                        tmpX = o1.x + o1.w
                        tmpY = o1.y
                    elseif tmp == 3 then
                        tmpX = o1.x + o1.w
                        tmpY = o1.y + o1.w
                    elseif tmp == 4 then
                        tmpX = o1.x
                        tmpY = o1.y + o1.w
                    end
                else
                    if tmp == 1 then
                        tmpX = o1.x1
                        tmpY = o1.y1
                    elseif tmp ==2 then
                        tmpX = o1.x2
                        tmpY = o1.y2
                    elseif tmp ==3 then
                        tmpX = o1.x3
                        tmpY = o1.y3
                    elseif tmp ==4 then
                        tmpX = o1.x4
                        tmpY = o1.y4
                    end
                end
                if checkCircleDis({x = tmpX, y= tmpY, w = 1}, o2) then
                    return true
                end
            end
            return false
        end
	elseif type == "rr" then
		local ax2,ay2,bx2,by2 = o1.x + o1.w, o1.y + o1.h, o2.x + o2.w, o2.y + o2.h
  		return ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1
	elseif type == "OMG" then

    end
end

function love.joystickpressed(joystick,button)
    if gamestate == "pause" then
        if joystick:isGamepadDown("a") then
            build.update("ok")
        end
        if joystick:isGamepadDown("b") then
            build.update("change")
        end
        if joystick:isGamepadDown("dpup") then
            build.update("up")
        end
        if joystick:isGamepadDown("dpdown") then
            build.update("down")
        end
        if joystick:isGamepadDown("dpleft") then
            build.update("left")
        end
        if joystick:isGamepadDown("dpright") then
            build.update("right")
        end
    end
    if joystick:isGamepadDown("x") then
        if gamestate == "game" then
            gamestate = "pause"
            build.load(player.x, player.y)
        else
            if gamestate =="pause" then
                gamestate = "game"
            end
        end
    end
end
function love.keypressed( key, isrepeat )
    if gamestate == "pause" then
        if key == keys.ok then
            build.update("ok")
        end
        if key == keys.up then
            build.update("up")
        end
        if key == keys.down then
            build.update("down")
        end
        if key == keys.left then
            build.update("left")
        end
        if key == keys.right then
            build.update("right")
        end
        if key == keys.change then
            build.update("change")
        end
    end
    if key == keys.build then
        if gamestate == "game" then
            gamestate = "pause"
            build.load(player.x, player.y)
        else
            if gamestate =="pause" then
                gamestate = "game"
            end
        end
    end
end

function isBlockSolid(char)
    if char == "?" then
        return false
    end
    for i, v in ipairs(solids) do
        if v == char then
            return true
        end
    end
    return false
end

function checkGamepadAxis(axis)
    if joystick ~= nil then
        return joystick:getGamepadAxis(axis) 
    else
        return 0
    end
end

function checkGamepadButton(button)
    if joystick ~= nil then
        return joystick:isGamepadDown(button) 
    else
        return false
    end
end

function deepcopy(t)
if type(t) ~= 'table' then return t end
local mt = getmetatable(t)
local res = {}
for k,v in pairs(t) do
if type(v) == 'table' then
v = deepcopy(v)
end
res[k] = v
end
setmetatable(res,mt)
return res
end

function calcDis(x1, y1, w1, x2, y2, w2)
    return math.sqrt(math.abs(x1-x2)^2+math.abs(y1-y2)^2)-w1-w2
end