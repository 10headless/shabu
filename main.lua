require "player"
require "bullets"
require "enemies"
require "map"
require "camera"
utils = require 'pl.utils'
require('pl.stringx').import()
require "build"

keys = {left = "a",right = "d",up = "w",down = "s",build = "lctrl", ok = "return"}
gamestate = "game"


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
end

function love.update(dt)
    if gamestate == "game" then
        player.update(dt)
        bullet.update(dt)
        enemy.update(dt)
        map.updateSpawners(dt)
    end
    if gamestate == "pause" then
        build.update(dt)
    end
end

function love.draw()
    camera:set()
    if gamestate == "pause" then
        build.draw()
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
    camera:unset()
    love.graphics.setShader()
end

function checkCircleDis(circleA, circleB)
    local dist = (circleA.x - circleB.x)^2 + (circleA.y - circleB.y)^2
    return dist <= (circleA.w + circleB.w)^2
end

function checkColl(type, o1, o2)
	if type == "cc" then
		return checkCircleDis(o1, o2)
	elseif type == "rc" then
        if o1.autom ~= nil then
            local tmpx1 = o1.x3 - o1.x4
            local tmpy1 = o1.y3 - o1.y4
            o1.w = math.sqrt(tmpx1^2 + tmpy1^2)
            o1.x = o1.x1+20
            o1.y = o1.y1+20 
        end
		if checkCircleDis({x = o1.x+o1.w/2, y = o1.y+o1.w/2, w = o1.w/2}, o2) then
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