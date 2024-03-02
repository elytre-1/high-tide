Gameloop = Object:extend()

function Gameloop:new(font, ennemies, ocean, planet)
    self.font = font
    self.state = 'titlescreen'
    self.timer = Timer()
    self.clock = Clock(WIND_W/2-50, 10, font)
    self.small_font = love.graphics.newFont("assets/fonts/computer-modern/cmunui.ttf", 15)

    --[[ 
        TITLE SCREEN
    ]]
    self.titlescreen = Ui(font)
    local y = 190 -- 410 ?
    local height = 55
    local width = 170

    -- new game button
    local button_new_game = Button(50,y,width,height,1,'Play',font) -- new game button
    button_new_game.func = function()
        -- reset timer
        self.clock:reset()
        self.clock:start()
        self.clock.x = WIND_W/2-50
        self.clock.y = 10
        self.state = 'game'
        
        -- reset ennemies
        for i,ennemy in ipairs(ennemies) do
            ennemy.state = 'destroyed'
        end

        -- reset ocean radius
        ocean.radius = planet.radius + 30
    end
    button_new_game.colorBase = {1,1,1,0.5}
    self.titlescreen.button[0] = button_new_game

    -- credit button
    local button_credit = Button(50,y+120,width,height,3,'Credits',font) -- credit button
    button_credit.func = function()
        self.timer:after(1, function() self.state = 'credit' end)
    end
    button_credit.colorBase = {1,1,1,0.5}
    self.titlescreen.button[2] = button_credit

    -- rules button
    local button_rules = Button(50,y+60,width,height,3,'Rules',font) -- credit button
    button_rules.func = function()
        self.timer:after(1, function() self.state = 'rules' end)
    end
    button_rules.colorBase = {1,1,1,0.5}
    self.titlescreen.button[3] = button_rules
    
    -- quit button
    local button_quit = Button(50,y+180,width,height,2,'Quit',font) -- quit button
    button_quit.func = function()
        love.event.quit()
    end
    button_quit.colorBase = {1,1,1,0.5}
    self.titlescreen.button[1] = button_quit

    --[[ 
        LOOSE MENU
    ]]
    self.loosescreen = Ui(font)
    local button_menu = Button(50,y+30,width,height,1,'Menu',font) -- menu button
    button_menu.func = function()
        self.timer:after(1, function() self.state = 'titlescreen' end)
    end
    button_menu.colorBase = {1,1,1,0.5}
    self.loosescreen.button[0] = button_menu

    local button_quit = Button(50,y+30+60,width,height,2,'Quit',font) -- quit button
    button_quit.func = function()
        love.event.quit()
    end
    button_quit.colorBase = {1,1,1,0.5}
    self.loosescreen.button[1] = button_quit

    --[[ 
        CREDIT MENU
    ]]
    self.credit_screen = Ui(font)
    local button_menu = Button(50,y+120,width,height,1,'Menu',font) -- menu button
    button_menu.func = function()
        self.timer:after(1, function() self.state = 'titlescreen' end)
    end
    button_menu.colorBase = {1,1,1,0.5}
    self.credit_screen.button[0] = button_menu

    --[[ 
        RULES SCREEN
    ]]
    self.rules_screen = Ui(font)
    local button_menu = Button(50,y+160,width,height,1,'Menu',font) -- menu button
    button_menu.func = function()
        self.timer:after(1, function() self.state = 'titlescreen' end)
    end
    button_menu.colorBase = {1,1,1,0.5}
    self.rules_screen.button[0] = button_menu

    -- pause menu
end

function Gameloop:update(dt)
    self.timer:update(dt)
    if self.state == 'titlescreen' then
        self.titlescreen:update()

    elseif self.state == 'rules' then
        self.rules_screen:update()

    elseif self.state == 'credit' then
        self.credit_screen:update()

    elseif self.state == 'game' then
        self.clock:update(dt)

    elseif self.state == 'lose' then
        self.clock:stop()
        self.loosescreen:update()
    end
end

function Gameloop:draw()
    if self.state == 'titlescreen' then
        self.titlescreen:draw()

    elseif self.state == 'rules' then
        local rules_str_1 = 'Your little planetary system is getting invaded!\nHelp your planet to get rid of these water\nrobbers by generating colossal tides.\nUse the RIGHT and LEFT arrows of your\nkeyboard to move around your planet. Then,\npress the UP arrow to generate tides and\ndestroy ennemy ships. Otherwise, they will\npump the entire ocean down!'
        love.graphics.print(rules_str_1, self.small_font, 35, 170 )
        self.rules_screen:draw()

    elseif self.state == 'credit' then
        local credit_str = 'Thank you so much for playing\nthis tiny game. It has been designed\nby Elytra and the music was composed\nby Callsix. Also, thank you Robnooz\nfor the late talks about never ending\ntides.'
        love.graphics.print(credit_str, self.small_font, 35, 180 )
        self.credit_screen:draw()

    elseif self.state == 'game' then
        self.clock:draw()

    elseif self.state == 'lose' then
        self.clock.x = 85
        self.clock.y = 160
        self.clock:draw()
    	love.graphics.print('Game over', self.font, 35, 110 )
        self.loosescreen:draw()
    end
end
