Gameloop = Object:extend()

function Gameloop:new(font)
    self.state = 'titlescreen'

    -- title screen
    self.titlescreen = Ui(font)
    local y = 410
    -- local y = 220
    local height = 50
    local width = 170
    local button_new_game = Button(50,y,width,height,1,'New game',font) -- new game button
    self.titlescreen.button[0] = button_new_game

    local button_quit = Button(50,y+60,width,height,2,'Quit',font) -- quit button
    self.titlescreen.button[1] = button_quit

    local button_credit = Button(50,y+120,width,height,3,'Credit',font) -- credit button
    self.titlescreen.button[2] = button_credit

    -- loose menu

    -- win menu

    -- pause menu
end

function Gameloop:update()
    if self.state == 'titlescreen' then
        self.titlescreen:update()
    end
end

function Gameloop:draw()
    if self.state == 'titlescreen' then
        self.titlescreen:draw()
    end
end
