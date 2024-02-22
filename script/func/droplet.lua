Droplet = Object:extend()

local droplet_radius = 10

function Droplet:new(x_spawn, y_spawn, x_end, y_end)
    self.x_spawn = x
    self.y_spawn = y
    self.x_end = x_end
    self.y_end = y_end
    self.direction_x = x_end-x_spawn
    self.direction_y = y_end-y_spawn

    -- compute animation
end


function Droplet:update()

end

function Droplet:draw()
    -- draw the ennemy
    love.graphics.setColor(1,0,1,1)
    love.graphics.circle('fill', self.x, self.y, droplet_radius)
    love.graphics.setColor(1,1,1,1)
end
