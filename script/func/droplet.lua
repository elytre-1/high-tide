Droplet = Object:extend()

local droplet_radius = 10
local n_points = 100 -- number of points of the trajectory

function Droplet:new(x_spawn, y_spawn, x_end, y_end)
    self.x_spawn = x_spawn
    self.y_spawn = x_spawn
    self.x_end = x_end
    self.y_end = y_end
    self.x = x_spawn
    self.y = y_spawn

    local distance = math.sqrt((x_end-x_spawn)^2 + (y_end-y_spawn)^2)
    local distance_x = (x_end-x_spawn)
    local distance_y = (y_end-y_spawn)
    
    -- normalized direction
    self.direction_x = (x_end-x_spawn) / distance_x
    self.direction_y = (y_end-y_spawn) / distance_y
    self.animation_step = n_points

    -- compute trajectory
    local dx = distance_x/n_points-- * self.direction_x
    local dy = distance_y/n_points-- * self.direction_y
    self.trajectory_x = {self.x_end}
    self.trajectory_y = {self.y_end}
    self.velocity = 0.3

    for i = 2, n_points do
        -- compute backward
        local x = math.ceil(self.trajectory_x[i-1] - dx)
        local y = math.ceil(self.trajectory_y[i-1] - dy)

        -- fill the trajectory tables
        table.insert(self.trajectory_x, x)
        table.insert(self.trajectory_y, y)

        -- velocity increases
        self.velocity = self.velocity + 0.01*self.velocity
    end
end


function Droplet:update()
    if self.animation_step >= 1 and self.animation_step <= n_points then
        self.x = self.trajectory_x[self.animation_step]
        self.y = self.trajectory_y[self.animation_step]
        self.animation_step = self.animation_step - 1
    else
        self.state = ''
    end
end

function Droplet:draw()
    -- draw the ennemy
    -- love.graphics.setColor(52/255, 235/255, 174/255 , 0.5)
    love.graphics.setColor(1, 0, 0 , 1)
    love.graphics.circle('fill', self.x, self.y, droplet_radius)
    love.graphics.setColor(1,1,1,1)
end
