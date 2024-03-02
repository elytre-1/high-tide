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
require 'func/gameloop'
require 'func/ui'
require 'func/button'
require 'func/clock'
local screen_ratio = 1920/1080
WIND_H = 600 -- les variables globales sont écrites en majuscule
WIND_W = 1000
love.graphics.setDefaultFilter('nearest','nearest') -- pas de filtre pour les sprites
love.window.setMode(WIND_W, WIND_H, {borderless = true, display = 1})
love.window.setTitle('node-node')
BACKGROUND = love.graphics.newImage('assets/background/background_star_1000x600.png')
CMU_serif = love.graphics.newFont("assets/fonts/computer-modern/cmunui.ttf", 40)
local can_spawn = true
local can_reduce_rate = true
local dt_ennemy_spawn = 12

function love.load()
	sound = love.audio.newSource("assets/sounds/callsix_onda_lunar_120bpm.wav", "static")
	ennemies = {} -- list of ennemies
	spawn_timer = Timer()
	spawn_rate_timer = Timer()
	planet = Planet(WIND_W/2, WIND_H/2)
	moon = Moon(planet)
	ocean = Ocean(planet,moon)
	gameloop = Gameloop(CMU_serif, ennemies, ocean, planet)
	gameloop.state = 'titlescreen'
end


function love.update(dt)
	gameloop:update(dt)
	planet:update(dt)
	moon:update(planet)
	ocean:update(planet, moon, dt)

	-- spawn ennemies
	spawn_timer:update(dt)
	spawn_rate_timer:update(dt)	

	if gameloop.state == 'game' then
		-- reduce time between two spawns
		if can_reduce_rate then
			can_reduce_rate = false
			if dt_ennemy_spawn >=4 then
				-- print('reduce spawn delay')
				spawn_rate_timer:after(10,
					function()
						dt_ennemy_spawn = dt_ennemy_spawn - 2
						can_reduce_rate = true
					end)
			end
		end

		-- spawn ennemy
		if can_spawn then
			can_spawn = false
			table.insert(ennemies, Ennemy(ocean, planet))
			spawn_timer:after(dt_ennemy_spawn, function() can_spawn = true end)
		end

		-- update ennemies
		for i, ennemy in ipairs(ennemies) do
			ennemies[i]:update(dt, ocean, planet, gameloop)
		end
	end

	-- soundtrack
	if not sound:isPlaying() then
		love.audio.play(sound)
	end
end


function love.draw()
	love.graphics.draw(BACKGROUND, 0, 0, 0, 1, 1)
	for i, ennemy in ipairs(ennemies) do
		ennemies[i]:draw()
	end

	gameloop:draw()
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