Ennemy = Object:extend()

local ennemy_radius = 10
local attacking_orbit = 160
local pump_timer = Timer()
local direction_x = 0
local direction_y = 0
local droplets = {} -- initialize droplet list
local can_pump = true

function Ennemy:new(ocean, planet)
    -- attacking location: pick a random location among the ocean vertices
    math.randomseed(os.time()) -- seed for the RNG
    local dtheta = 2*math.pi / ocean.n_vertices
    self.position_above_ocean = math.random(1, ocean.n_vertices)
    local attacking_angle = self.position_above_ocean * dtheta
    self.x_attacking = planet.x + attacking_orbit * math.cos(attacking_angle)
    self.y_attacking = planet.y + attacking_orbit * math.sin(attacking_angle)

    -- find the normalized direction the ennemy should come from
    direction_x = (planet.x - self.x_attacking) / attacking_orbit
    direction_y = (planet.y - self.y_attacking) / attacking_orbit

    -- compute the trajectory
    local n_points = 10 -- number of points of the trajectory
    local max_range = 300
    local dx = max_range/n_points
    local dy = dx
    self.trajectory_x = {self.x_attacking}
    self.trajectory_y = {self.y_attacking}
    self.velocity = 0.5
    for i = 2, n_points do
        -- compute backward
        local x = math.ceil(self.trajectory_x[i-1] - direction_x*dx*self.velocity)
        local y = math.ceil(self.trajectory_y[i-1] - direction_y*dy*self.velocity)

        -- fill the trajectory tables
        table.insert(self.trajectory_x, x)
        table.insert(self.trajectory_y, y)

        -- velocity increases
        self.velocity = self.velocity + 0.01*self.velocity
    end

    -- spawn location
    self.x = self.trajectory_x[#self.trajectory_x]
    self.y = self.trajectory_y[#self.trajectory_y]
    self.t = #self.trajectory_y

    -- state machine can be 'travelling' and pumping
    self.state = 'travelling'

end


function Ennemy:update(dt, ocean, planet)
    pump_timer:update(dt)    

    -- state machine
    if self.state == 'travelling' then
        if self.t >= 1 then
            self.x = self.trajectory_x[self.t]
            self.y = self.trajectory_y[self.t]
            self.t = self.t - 1
        else
            self.state = 'attacking'
            print('attacking')
        end

    elseif self.state == 'attacking' then
        -- check if a wave is destroying the little dude
        if ocean.vertices_radii[self.position_above_ocean] >= attacking_orbit-ennemy_radius then
            self.state = 'destroyed'
        end

        -- trigger the pumping event
        if can_pump then
            can_pump = false
            pump_timer:after(4, function() can_pump = true end)
            self:pump_water(planet)
        end
    
        for i, droplet in ipairs(droplets) do
            -- update droplet location
            droplet:update()

            -- remove the droplets when they reach the ship
        end
    end
end

function Ennemy:draw()
    -- draw the ennemy
    love.graphics.setColor(1,1,1,1)
    if self.state == 'destroyed' then
        love.graphics.setColor(1,1,1,0.1)
    end
    love.graphics.circle('fill', self.x, self.y, ennemy_radius)

    -- draw the droplets
    for i, droplet in ipairs(droplets) do
        droplet:draw()
    end

    love.graphics.setColor(1,1,1,1)
end

function Ennemy:pump_water(planet)
    print('spawn')
    -- spwan droplet in the center of the planet
    table.insert(droplets, Droplet(planet.x, planet.y, self.x, self.y))
end