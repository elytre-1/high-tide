Planet = Object:extend()


function Planet:new(x,y)
    -- initial location
    self.x_0 = x
    self.y_0 = y

    -- time dependant location
    self.x = x
    self.y = y
    
    -- planet radius
    self.radius = 100
end


function Planet:update(dt)
end

function Planet:draw()
    love.graphics.setColor(1,1,1,1)
    love.graphics.circle('fill', self.x, self.y, self.radius)
    love.graphics.setColor(1,1,1,1)
end
