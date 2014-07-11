camera = {}
camera.x = 0
camera.y = 0
camera.xvel = 0
camera.yvel = 0
camera.scaleX = 1.0
camera.scaleY = 1.0
camera.speed = 10
camera.rotation = 0

function camera:set()
  love.graphics.push()
  love.graphics.rotate(-self.rotation)
  love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
  love.graphics.translate(-self.x, -self.y)
end
function camera:set2()
  love.graphics.push()
  love.graphics.rotate(-self.rotation)
  love.graphics.scale(1 / self.scaleX + 0.5,1 / self.scaleY + 0.5)
  love.graphics.translate(-self.x, -self.y)
end
function camera.unset2()
  love.graphics.pop()
end
function camera:unset()
  love.graphics.pop()
end

function camera:move(dx, dy)
  self.x = self.x + (dx or 0)
  self.y = self.y + (dy or 0)
end

function camera:rotate(dr)
  self.rotation = self.rotation + dr
end

function camera:scale(sx, sy)
  sx = sx or 1
  self.scaleX = self.scaleX * sx
  self.scaleY = self.scaleY * (sy or sx)
end

function camera:setPosition(x, y)
  self.x = x or self.x
  self.y = y or self.y
end

function camera:setScale(sx, sy)
  self.scaleX = sx or self.scaleX
  self.scaleY = sy or self.scaleY
end
function camera:change_focuse(scale)
 self.scaleX = scale
 self.scaleY = scale
 love.graphics.pop()
 love.graphics.push()
 love.graphics.translate(-self.x, -self.y)
 love.graphics.scale(1/ self.scaleX, 1/ self.scaleY)
end
camera.width = love.graphics.getWidth() / 3.3

camera.layers = {}


function camera:newLayer(scale, func)
  table.insert(self.layers, { draw = func, scale = scale })
  table.sort(self.layers, function(a, b) return a.scale < b.scale end)
end

function camera:draw()
  local bx, by = self.x, self.y
  
  for _, v in ipairs(self.layers) do
    self.x = bx * v.scale
    self.y = by * v.scale
    camera:set()
    v.draw()
    camera:unset()
  end
end











