Clock = Object:extend()

function Clock:new(x,y,font)
    self.time = 0
    self.x = x
    self.y = y
    self.font = font
    self.run = true
    self.minutes = 0
    self.seconds = 0
end

function Clock:update(dt)
    if self.run then
        self.time = self.time + dt
        self.minutes = math.floor( self.time / 60 ) -- calculate how many minutes are left
    	self.seconds = math.floor( self.time % 60 ) -- calculate how many seconds are left
    end
end

function Clock:draw()
    love.graphics.setColor(1,1,1,1)
	love.graphics.print(string.format("%02d:%02d",self.minutes,self.seconds), self.font, self.x, self.y )
    love.graphics.setColor(1,1,1,1)
end

function Clock:reset()
    self.time = 0
end

function Clock:stop()
    self.run = false
end

function Clock:start()
    self.run = true
end