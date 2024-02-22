Ocean = Object:extend()

local moon_distances = {}
local planet_distances = {}

function Ocean:new(planet, moon)
    self.n_vertices = 100
    self.maximum_radius = planet.radius + 65

    -- initialize the vertices to planet distances
    self.vertices_radii = {}
    self.initial_radius = planet.radius + 20
    for i = 1, self.n_vertices do
        table.insert(self.vertices_radii, self.initial_radius)
    end

    -- compute initial vertices
    self.vertices_x = {}
    self.vertices_y = {}
    
    local dtheta = 2*math.pi / self.n_vertices
    local theta = 0
    self.vertices_x, self.vertices_y = self:compute_vertices_positions(planet.x, planet.y, self.vertices_radii, self.n_vertices, theta)

    -- fill the vertice table for the drawing step
    self.vertices = fill_vertice_table(self.vertices_x, self.vertices_y)

    -- initialize the moon distance
    moon_distances = self:compute_distances(moon.x, moon.y)
    planet_distance = self:compute_distances(planet.x, planet.y)

end


function Ocean:update(planet,moon)
    -- compute distances between vertices points and the moon
    moon_distances = self:compute_distances(moon.x_mass_center, moon.y_mass_center)
    planet_distances = self:compute_distances(planet.x, planet.y)

    local k_moon = 1/(1.1e-5)
    local k_planet = 6*k_moon -- 1/(3.7e-05)
    local k_pression = 1e-9

    -- apply force to the vertices depending of the distance to the moon
    for i = 1, #self.vertices_radii do
        local direction_to_moon_x = -(moon.x_mass_center - self.vertices_x[i]) / moon_distances[i]
        
        local moon_gravity = k_moon * direction_to_moon_x / moon_distances[i]^2
        local planet_gravity = - k_planet * direction_to_moon_x / planet_distances[i]^2
        local pression = k_pression * (planet.radius - planet_distances[i])^3

        self.vertices_radii[i] = self.vertices_radii[i] + moon_gravity + planet_gravity + pression

        if i == 1 then
            print('r = '..self.vertices_radii[i])
            print('moon_gravity = '..moon_gravity)
            print('planet_gravity = '..planet_gravity)
            print('pression = '..pression)
            print('---------------')
        end

        -- -- roughly working
        -- if self.vertices_radii[i] < self.maximum_radius then
        --     self.vertices_radii[i] = self.vertices_radii[i] + 4e6*(1/moon_distances[i]^4)
        -- end

        -- if self.vertices_radii[i] >= self.initial_radius then
        --     local gravity = 7e-5
        --     self.vertices_radii[i] = self.vertices_radii[i] - 9e-4*planet_distances[i]
        -- end
    end

    -- update vertice location
    self.vertices_x, self.vertices_y = self:compute_vertices_positions(planet.x, planet.y, self.vertices_radii, self.n_vertices, 0)

    -- fill the vertice table for the drawing step
    self.vertices = fill_vertice_table(self.vertices_x, self.vertices_y)
end

function Ocean:compute_vertices_positions(x_0, y_0, radii, n_vertices, theta_0)
    local x_table = {}
    local y_table = {}
    local theta = theta_0
    local dtheta = 2*math.pi / n_vertices

    for i = 1, n_vertices do
        local x = x_0 + radii[i] * math.cos(theta)
        local y = y_0 + radii[i] * math.sin(theta)
        
        table.insert(x_table, x)
        table.insert(y_table, y)

        theta = theta + dtheta
    end

    return x_table, y_table
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