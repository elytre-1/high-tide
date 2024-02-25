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

local screen_ratio = 1920/1080
WIND_H = 600 -- les variables globales sont écrites en majuscule
WIND_W = 1000
love.graphics.setDefaultFilter('nearest','nearest') -- pas de filtre pour les sprites
love.window.setMode(WIND_W, WIND_H, {borderless = true})
love.window.setTitle('node-node')
background = love.graphics.newImage('assets/background/background_star_1000x600.png')
CMU_serif = love.graphics.newFont("assets/fonts/computer-modern/cmunvt.ttf", 40)

local can_spawn = true

function love.load()
	sound = love.audio.newSource("assets/sounds/callsix__onda_lunar__120bpm_.wav", "static") 
	spawn_timer = Timer()
	planet = Planet(WIND_W/2, WIND_H/2)
	moon = Moon(planet)
	ocean = Ocean(planet,moon)
	gameloop = Gameloop(CMU_serif)

	--initialize ennemies
	ennemies = {}
end


function love.update(dt)
	gameloop:update()
	
	planet:update(dt)
	moon:update(planet)
	ocean:update(planet, moon, dt)

	-- spawn ennemies
	spawn_timer:update(dt)
	if not gameloop.state == 'titlescreen' then
		if can_spawn then
			can_spawn = false
			table.insert(ennemies, Ennemy(ocean, planet))
			spawn_timer:after(4, function() can_spawn = true end)
		end

		-- update ennemies
		for i, ennemy in ipairs(ennemies) do
			ennemies[i]:update(dt, ocean, planet)
		end
	end

	-- soundtrack
	if not sound:isPlaying() then
		love.audio.play(sound)
	end
end


function love.draw()
	love.graphics.draw(background, 0, 0, 0, 1, 1)
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