Droplet = Object:extend()

local droplet_radius = 3
local n_points = 100 -- number of points of the trajectory

function Droplet:new(x_spawn, y_spawn, x_end, y_end, angle, planet)
    -- from cartesian to polar coordinates
    local r_spawn = math.sqrt((planet.x-x_spawn)^2 + (planet.y-y_spawn)^2)
    local r_end = math.sqrt((planet.x-x_end)^2 + (planet.y-y_end)^2)

    -- initialize
    local distance = math.sqrt((x_end-x_spawn)^2 + (y_end-y_spawn)^2)
    local dr = distance/n_points
    local trajectory_r = {r_spawn}
    self.trajectory_x = {x_spawn}
    self.trajectory_y = {y_spawn}

    -- compute trajectory
    for i = 2, n_points do
        local r = trajectory_r[i-1] + dr
        table.insert(trajectory_r, r)

        -- changement de variable
        local x = planet.x + r * math.cos(angle)
        local y = planet.y + r * math.sin(angle)

        -- fill the trajectory tables
        table.insert(self.trajectory_x, x)
        table.insert(self.trajectory_y, y)
    end

    self.animation_step = 1
    self.x = x_spawn
    self.y = y_spawn

end


function Droplet:update()
    if self.animation_step >= 1 and self.animation_step <= n_points then
        self.x = self.trajectory_x[self.animation_step]
        self.y = self.trajectory_y[self.animation_step]
        self.animation_step = self.animation_step + 1
    else
        self.state = ''
    end
end

function Droplet:draw()
    -- draw the ennemy
    love.graphics.setColor(52/255, 235/255, 174/255 , 0.5)
    love.graphics.circle('fill', self.x, self.y, droplet_radius)
    love.graphics.setColor(1,1,1,1)
end
