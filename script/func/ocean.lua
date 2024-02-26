Ocean = Object:extend()

local moon_distances = {}
local planet_distances = {}
timer = Timer()

function Ocean:new(planet, moon)
    -- self.timer = Timer()
    self.n_vertices = 60
    self.maximum_radius = planet.radius + 100
    self.radius = planet.radius + 30
    self.velocities = {0.2, 0.7, 1, 0.7, 0.2}

    -- initialize the vertices to planet distances
    self.vertices_radii = {}
    for i = 1, self.n_vertices do
        table.insert(self.vertices_radii, self.radius)
    end

    -- compute initial vertices
    self.vertices_x = {}
    self.vertices_y = {}
    
    local dtheta = 2*math.pi / self.n_vertices
    local theta = 0
    self.vertices_x, self.vertices_y, self.vertices_theta = self:compute_vertices_positions(planet.x, planet.y, self.vertices_radii, self.n_vertices, theta)

    -- fill the vertice table for the drawing step
    self.vertices = fill_vertice_table(self.vertices_x, self.vertices_y)

    -- initialize the moon distance
    moon_distances = self:compute_distances(moon.x, moon.y)
    planet_distance = self:compute_distances(planet.x, planet.y)
end


function Ocean:update(planet,moon,dt)
    -- update the ocean's timer
    timer:update(dt)

    -- compute distances between vertices points and the moon
    moon_distances = self:compute_distances(moon.x_mass_center, moon.y_mass_center)
    planet_distances = self:compute_distances(planet.x, planet.y)

    -- find the closest vertice to the moon
    local minimum_angle = 2 * math.pi
    self.closest_vertice = nil
    for i, theta in ipairs(self.vertices_theta) do
        local angle_difference = math.abs(moon.theta - theta)
        if angle_difference < minimum_angle then
            minimum_angle = angle_difference
            self.closest_vertice = i
        end
    end

    -- get closest vertice neighbors
    local n_neighbors = 2
    self.neighbors_index = {}
    for i = self.closest_vertice - n_neighbors, self.closest_vertice + n_neighbors do
        index = i
        if i <= 0 then
            index = self.n_vertices - math.abs(i)
        elseif index > self.n_vertices then
            index = i - math.floor(i/self.n_vertices)*(self.n_vertices)
        end
        table.insert(self.neighbors_index, index)
    end

    -- move the neighbors
    for i, neighbor in ipairs(self.neighbors_index) do
        if self.vertices_radii[neighbor] < self.maximum_radius then
            self.vertices_radii[neighbor] = self.vertices_radii[neighbor] + 0.1*self.velocities[i]
        end
    end
    
    -- reset values of other vertices
    for i = 1, #self.vertices_radii do
        if not has_value(self.neighbors_index, i) then
            if self.vertices_radii[i] > self.radius then
                self.vertices_radii[i] = self.vertices_radii[i] - 1e-5*planet_distances[i]^2
            elseif self.vertices_radii[i] < self.radius then
                self.vertices_radii[i] = self.vertices_radii[i] + 1e-5*planet_distances[i]^2
            end
        end
    end

    -- update vertice location
    self.vertices_x, self.vertices_y, self.vertices_theta = self:compute_vertices_positions(planet.x, planet.y, self.vertices_radii, self.n_vertices, 0)

    -- fill the vertice table for the drawing step
    self.vertices = fill_vertice_table(self.vertices_x, self.vertices_y)
end

function Ocean:big_wave()
    local interaction_time = 1
    local dv = 0.06+1

    timer:during(interaction_time,
                    function(dt)
                        self:change_wave_velocity(dv)
                    end)

    timer:after(interaction_time,
                    function()
                        timer:during(interaction_time, function(dt) self:change_wave_velocity(1/dv) end)
                    end)
end

function Ocean:change_wave_velocity(coeff)
    for i = 1, #self.velocities do
        self.velocities[i] = self.velocities[i]*coeff
    end
end

function Ocean:compute_vertices_positions(x_0, y_0, radii, n_vertices, theta_0)
    local x_table = {}
    local y_table = {}
    local theta_table = {}
    local theta = theta_0
    local dtheta = 2*math.pi / n_vertices

    for i = 1, n_vertices do
        local x = x_0 + radii[i] * math.cos(theta)
        local y = y_0 + radii[i] * math.sin(theta)
        
        table.insert(x_table, x)
        table.insert(y_table, y)
        table.insert(theta_table, theta)

        theta = theta + dtheta
    end

    return x_table, y_table, theta_table
end


function Ocean:compute_distances(x,y)
    local distances = {}
    for i = 1, #self.vertices_x do
        local distance = math.sqrt((x-self.vertices_x[i])^2 + (y-self.vertices_y[i])^2)
        table.insert(distances, distance)
    end

    return distances
end


function Ocean:draw()
    love.graphics.setColor(52/255, 235/255, 174/255 , 0.5)
    love.graphics.polygon("fill", self.vertices)
    love.graphics.setColor(52/255, 235/255, 174/255 , 1)
    love.graphics.setLineWidth(5)
    love.graphics.polygon("line", self.vertices)
    love.graphics.setColor(1,1,1,1)
end

function fill_vertice_table(x, y)
    local vertice_table = {}

    for i = 1, #x do
        table.insert(vertice_table, x[i])
        table.insert(vertice_table, y[i])
    end

    return vertice_table
end


function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end
