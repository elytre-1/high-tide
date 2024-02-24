Moon = Object:extend()

local orbit = 250 -- radius of the orbit
local mass_center_orbit = 120 -- radius of the orbit
local moon_radius = 30
local minimum_acceleration = 3e-3
local maximum_acceleration = 6*minimum_acceleration
local acceleration_rate = 0.5e-3

function Moon:new(planet)
    self.x = planet.x
    self.y = planet.y - orbit
    self.x_mass_center = planet.x
    self.y_mass_center = planet.y - mass_center_orbit
    self.theta = math.atan(math.abs((planet.y-self.y)/(planet.x-self.x)))
    self.acceleration = minimum_acceleration
    self.direction = 1
end


function Moon:update(planet)
    -- distance to the planet
    -- local distance = math.sqrt((self.x-planet.x)^2 + (self.y-planet.y)^2)

    if love.keyboard.isDown("left") then
        self.direction = 1
        self:accelerate()
    elseif love.keyboard.isDown("right") then
        self.direction = -1
        self:accelerate()
    else
        self:decelerate()
    end

    self.theta = self.theta + self.direction * self.acceleration
    if self.theta < 0 then
        self.theta = 2*math.pi 
    elseif self.theta > 2*math.pi then
        self.theta = 0
    end
    -- changement de repère
    self.x = planet.x + orbit * math.cos(self.theta)
    self.y = planet.y + orbit * math.sin(self.theta)

    self.x_mass_center = planet.x + mass_center_orbit * math.cos(self.theta)
    self.y_mass_center = planet.y + mass_center_orbit * math.sin(self.theta)
end

function Moon:accelerate()
    if self.acceleration <= maximum_acceleration then
        self.acceleration = self.acceleration + acceleration_rate
    end
end

function Moon:decelerate()
    if self.acceleration >= minimum_acceleration then
        self.acceleration = self.acceleration - acceleration_rate
    end
end

function Moon:attack()
    
end

function Moon:draw()
    love.graphics.setColor(1,1,1,1)
    love.graphics.circle('fill', self.x, self.y, moon_radius)
    love.graphics.setColor(1,1,1,1)
end
