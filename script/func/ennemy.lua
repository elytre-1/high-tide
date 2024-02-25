Ennemy = Object:extend()

local ennemy_radius = 10
local attacking_orbit = 180
local spawn_orbit = 800
local direction_x = 0
local direction_y = 0
local n_points = 100 -- number of points of the trajectory
local tank_capacity = 9
local tank_increase_rate = 3
local pumping_rate = 3

function Ennemy:new(ocean, planet)
    self.attacking_orbit = planet.radius + 80
    self.sprite = love.graphics.newImage('assets/sprites/ennemy_sprite.png')
    self.tank_radius = 0 -- how big the reservoir is
    self.can_pump = true
    self.pump_timer = Timer()
    self.droplets = {} -- initialize droplet list

    -- attacking location: pick a random location among the ocean vertices
    math.randomseed(os.time()) -- seed for the RNG
    local dtheta = 2*math.pi / ocean.n_vertices
    self.position_above_ocean = math.random(1, ocean.n_vertices)
    self.attacking_angle = self.position_above_ocean * dtheta
    local x_attacking = planet.x + self.attacking_orbit * math.cos(self.attacking_angle)
    local y_attacking = planet.y + self.attacking_orbit * math.sin(self.attacking_angle)
    local x_spawn = planet.x + spawn_orbit * math.cos(self.attacking_angle)
    local y_spawn = planet.y + spawn_orbit * math.sin(self.attacking_angle)

    -- compute the trajectory
    -- TODO add a velocity
    local dr = (spawn_orbit-self.attacking_orbit)/n_points
    self.trajectory_x = {x_spawn}
    self.trajectory_y = {y_spawn}
    local trajectory_r = {spawn_orbit} -- initial radius
    for i = 2, n_points do
        -- compute the next position based on the previous one
        local r = trajectory_r[i-1] - dr
        table.insert(trajectory_r, r)

        -- changement de variable
        local x = planet.x + r * math.cos(self.attacking_angle)
        local y = planet.y + r * math.sin(self.attacking_angle)

        -- fill the trajectory tables
        table.insert(self.trajectory_x, x)
        table.insert(self.trajectory_y, y)

    end

    -- spawn location
    self.x = self.trajectory_x[#self.trajectory_x]
    self.y = self.trajectory_y[#self.trajectory_y]
    self.animation_step = 1

    -- state machine can be 'travelling' and pumping
    self.state = 'travel'

end


function Ennemy:update(dt, ocean, planet)
    self.pump_timer:update(dt)    

    -- state machine
    if self.state == 'travel' then
        if self.animation_step < #self.trajectory_x then
            self.x = self.trajectory_x[self.animation_step]
            self.y = self.trajectory_y[self.animation_step]
            self.animation_step = self.animation_step + 1
        else
            self.state = 'attacking'
        end

    elseif self.state == 'attacking' then
        print('----')
        print('self.attacking_orbit '..self.attacking_orbit)
        print('ennemy_radius '..ennemy_radius)
        print('self.position_above_ocean '..self.position_above_ocean)

        -- check if a wave is destroying the little dude
        if ocean.vertices_radii[self.position_above_ocean+1] >= self.attacking_orbit-ennemy_radius then
            self.state = 'destroyed'
        end

        -- trigger the pumping event
        if self.can_pump then
            self.can_pump = false
            self.pump_timer:after(4, function() self.can_pump = true end)
            self:pump_water(planet)
        end
    
        local droplets_to_remove = {}
        for i, droplet in ipairs(self.droplets) do
            -- update droplet location
            droplet:update()

            -- compute the droplet to ennemy distance
            local distance = math.sqrt((self.x - droplet.x)^2 + (self.y - droplet.y)^2)

            -- when the droplet reaches the ennemy, remove it, increment the tank volume
            -- and decrease the ocean radius
            if distance < ennemy_radius then
                table.insert(droplets_to_remove, i)

                -- increase the tank radius
                self.tank_radius = self.tank_radius + tank_increase_rate
                
                -- reduce the ocean radius
                ocean.radius = ocean.radius - pumping_rate

                if ocean.radius <= planet.radius then
                    -- trigger loose screen
                end

                -- leave when the tank is full
                if self.tank_radius >= tank_capacity then
                    self.state = 'travel_back'
                end
            end
        end

        -- remove droplet that have reached the ennemy
        for i, droplet_index in ipairs(droplets_to_remove) do
            table.remove(self.droplets, droplet_index)
        end

    elseif self.state == 'travel_back' then
        -- travel back home
        if self.animation_step >= 1 then
            self.x = self.trajectory_x[self.animation_step]
            self.y = self.trajectory_y[self.animation_step]
            self.animation_step = self.animation_step - 1
        end

    elseif self.state == 'destroyed' then
        if self.tank_radius > 0 then
            local number_of_droplets = math.floor(self.tank_radius/tank_increase_rate)
            ocean.radius = ocean.radius + number_of_droplets * pumping_rate
            self.tank_radius = 0 -- empty the tank
        end

        if #self.droplets > 0 then
            self.droplets = {}
        end
    end
end

function Ennemy:draw()
    -- draw the ennemy
    love.graphics.setColor(1,1,1,1)

    if self.state == 'destroyed' then
        love.graphics.setColor(1,1,1,0)

    elseif self.state == 'attacking' or self.state == 'travel' or self.state == 'travel_back' then
        -- draw the reservoir
        love.graphics.setColor(52/255, 235/255, 174/255 , 0.5)
        love.graphics.circle('fill', self.x, self.y, self.tank_radius)
        love.graphics.setColor(1,1,1,1)
        
        -- draw the ennemy

        local scale = 0.3 -- scale factor
        local ox, oy = self.sprite:getWidth()/2, self.sprite:getHeight()/2 -- offset
        local kx, ky = 0, 0
        local direction = 1
        if self.state == 'travel_back' then
            direction = -1
        end
        love.graphics.draw(self.sprite, self.x, self.y, self.attacking_angle+direction*math.pi/2, scale, scale, ox, oy, kx, ky )
            
        -- draw the droplets
        for i, droplet in ipairs(self.droplets) do
            droplet:draw()
        end
    end

    love.graphics.setColor(1,1,1,1)
end

function Ennemy:pump_water(planet)
    -- spwan droplet in the center of the planet
    table.insert(self.droplets, Droplet(planet.x, planet.y, self.x, self.y, self.attacking_angle, planet))
end