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
	SOUND = love.audio.newSource("assets/sounds/callsix_onda_lunar_120bpm.wav", "static")
	ENNEMIES = {} -- list of ennemies
	SPAWN_TIMER = Timer()
	SPAWN_RATE_TIMER = Timer()
	PLANET = Planet(WIND_W/2, WIND_H/2)
	MOON = Moon(PLANET)
	OCEAN = Ocean(PLANET,MOON)
	GAMELOOP = Gameloop(CMU_serif, ENNEMIES, OCEAN, PLANET)
	GAMELOOP.state = 'titlescreen'
end


function love.update(dt)
	GAMELOOP:update(dt)
	PLANET:update(dt)
	MOON:update(PLANET)
	OCEAN:update(PLANET, MOON, dt)

	-- spawn ennemies
	SPAWN_TIMER:update(dt)
	SPAWN_RATE_TIMER:update(dt)	

	if GAMELOOP.state == 'game' then
		-- reduce time between two spawns
		if can_reduce_rate then
			can_reduce_rate = false
			if dt_ennemy_spawn >=4 then
				-- print('reduce spawn delay')
				SPAWN_RATE_TIMER:after(10,
					function()
						dt_ennemy_spawn = dt_ennemy_spawn - 2
						can_reduce_rate = true
					end)
			end
		end

		-- spawn ennemy
		if can_spawn then
			can_spawn = false
			table.insert(ENNEMIES, Ennemy(OCEAN, PLANET))
			SPAWN_TIMER:after(dt_ennemy_spawn, function() can_spawn = true end)
		end

		-- update ennemies
		for i, ennemy in ipairs(ENNEMIES) do
			ENNEMIES[i]:update(dt, OCEAN, PLANET, GAMELOOP)
		end
	end

	-- soundtrack
	if not SOUND:isPlaying() then
		love.audio.play(SOUND)
	end
end


function love.draw()
	love.graphics.draw(BACKGROUND, 0, 0, 0, 1, 1)
	for i, ennemy in ipairs(ENNEMIES) do
		ennemy:draw()
	end

	GAMELOOP:draw()
	OCEAN:draw()
	PLANET:draw()
	MOON:draw()
end


function love.keypressed(key, unicode)
	-- leave the game quickly fiouuuu
	if key == "escape" then
		love.event.quit()
	end

	if key == 'up' then
		OCEAN:big_wave()
		MOON:attack()
	end
end