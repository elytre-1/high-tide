Button = Object:extend()

local pink = {228/255, 167/255, 239/255, 1}
local light_grey = {133/255, 133/255, 133/255, 1}
local green = {80/255, 250/255, 123/255, 1}
local white = {1, 1, 1, 1}

function Button:new(x,y,w,h,index,text,font)
	self.x, self.y, self.w0, self.h = x, y, w, h -- position and dimensions
	self.text = text
	self.font = font
	self.func = function() end -- function to execute when the button is pushed

	self.w = w -- initial width of the rectangle
	self.velocity = 3 -- animation velocity
	self.colorTouching = pink -- if the mouse is on the button
	self.colorClicked = green -- if the mouse clicks on the button
	self.colorBase = {1,1,1} -- if nothing happens :(
	self.colorText = {31/255, 36/255, 48/255}
	self.index = index
	self.state = false -- state false by default and true if clicked
	self.mouseReleased = true -- triggers the release of the mouse button(1)
	self.persistant = false
end


function Button:update()
	if love.mouse.isDown(1) then -- state
		if self:collide() then
			if self.mouseReleased == true then
				self.func() -- executed when clicking the button
			end

			if self.mouseReleased == true and self.state == false then
				self.state = true
				self.mouseReleased = false
			elseif self.mouseReleased == true and self.state == true then
				self.state = false
				self.mouseReleased = false
			end
		end
	else
		self.mouseReleased = true 
	end
end


function Button:draw()
	if self:collide() then
		love.graphics.setColor(self.colorTouching)
		if love.mouse.isDown(1) then
			love.graphics.setColor(self.colorClicked)
		end
	else
		love.graphics.setColor(self.colorBase)
		if love.mouse.isDown(1) then
			self.state = false
		end

		if self.state == true and self.persistant == true then
			love.graphics.setColor(self.colorClicked)
		end
	end

	love.graphics.rectangle("fill",self.x, self.y, self.w, self.h,0,0) -- draw the button shape
	love.graphics.setColor(self.colorText)
	love.graphics.printf(self.text,self.font,self.x,self.y+5,self.w,"center",0,1,1)
	love.graphics.setColor(1,1,1)
end


function Button:collide()
	-- true if the mouse is on the button
	local x,y = love.mouse.getPosition()
	if x > self.x and x < self.x + self.w and y < self.y + self.h and y > self.y then
		return true
	else
		return false
	end
end