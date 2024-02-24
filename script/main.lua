Object = require 'lib/classic'
Camera = require 'lib/hump.camera'
Timer = require 'lib/hump.timer'
Vector = require 'lib/hump.vector'
Colors = require 'lib/colors' -- où je stocke mes couleurs préférées
require 'lib/misc'
require 'func/planet'
require 'func/moon'
require 'func/ocean'
require 'func/ennemy'
require 'func/droplet'

local screen_ratio = 1920/1080
WIND_H = 600 -- les variables globales sont écrites en majuscule
WIND_W = 600
love.graphics.setDefaultFilter('nearest','nearest') -- pas de filtre pour les sprites
love.window.setMode(WIND_W, WIND_H, {borderless = true})
love.window.setTitle('node-node')
background = love.graphics.newImage('assets/background/background_600x600.png')

local can_spawn = true

function love.load()
	spawn_timer = Timer()
	planet = Planet(WIND_W/2, WIND_H/2)
	moon = Moon(planet)
	ocean = Ocean(planet,moon)

	--initialize ennemies
	local n_ennemies = 1
	ennemies = {Ennemy(ocean, planet)}
end


function love.update(dt)
	planet:update(dt)
	moon:update(planet)
	ocean:update(planet, moon, dt)

	-- spawn ennemies
	spawn_timer:update(dt)
	if can_spawn then
		can_spawn = false
		table.insert(ennemies, Ennemy(ocean, planet))
		spawn_timer:after(4, function() can_spawn = true end)
	end

	-- update ennemies
	for i, ennemy in ipairs(ennemies) do
		ennemies[i]:update(dt, ocean)
	end
end


function love.draw()
	love.graphics.draw(background, 0, 0, 0, 1, 1)
	for i, ennemy in ipairs(ennemies) do
		ennemies[i]:draw()
	end
	ocean:draw()
	planet:draw()
	moon:draw()
end


function love.keypressed(key, unicode)
	-- leave the game quickly fiouuuu
	if key == "escape" then
		love.event.quit()
	end

	if key == 'up' then
		ocean:big_wave()
		moon:attack()
	end
end