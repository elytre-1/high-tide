Textbox = Object:extend()


local pink = {228/255, 167/255, 239/255, 1}
local light_grey = {133/255, 133/255, 133/255, 1}
local green = {80/255, 250/255, 123/255, 1}
local white = {1, 1, 1, 1}
local timer = 0
local cursor_velocity = 0.02 -- vitesse à laquelle le curseur clignotte
local bubble_velocity = 0.5


function Textbox:new(label, x, y, font, text)
	self.label = label
	self.x = x
	self.y = y
	self.w = 200
	self.h = 30
	self.text = text
	self.font = font
	self.state = "none"

	self.color_text = light_grey
	self.color_line = white
	self.color_label = white
	self.color_cursor = white

	self.bubble_info = ""
	self.bubble_alpha = 0

	self.empty_msg = "Type here"

	self.cursorIdx = 0
	self.msg = ""
end


function Textbox:update()
	if self:collide() then
		if self.state ~= "clicked" then
			self.state = "fly"
		end
		if love.mouse.isDown(1) then
			self.state = "clicked"
			self.cursorIdx = #self.text
			if self.text == self.empty_msg then
				self.text = ""
			end
		end
	else
		if self.state ~= "clicked" then
			self.state = "none"
		end
	end

	if love.mouse.isDown(1) and self:collide() == false then -- if user clicks somewhere else
		self.state = "none"
	end

	local text = self.text
	text = text:sub(1,self.cursorIdx)
	self.cursorx = self.x + self.font:getWidth(text)

	if self.text == "" and self.state ~= "clicked" then
		self.text = self.empty_msg
	end
end


function Textbox:draw()
	local alpha = 0
	timer = timer + cursor_velocity

	if self.state == "none" then
		if self.text == self.empty_msg then
			self.color_text = light_grey
		else
			self.color_text = white
		end
		self.color_line = light_grey
		self.color_label = white
	elseif self.state == "fly" then
		self.color_text = pink
		self.color_line = pink
		self.color_label = pink
	elseif self.state == "clicked" then
		self.color_text = green
		self.color_line = pink
		self.color_label = pink
		alpha = math.abs(math.sin(timer))
	end

	-- label
	local label_size = 120
	local yoffset = -3
	love.graphics.setColor(self.color_label)
	love.graphics.printf(self.label,self.font,self.x-label_size,self.y-yoffset,label_size,"left",0,1,1)

	-- text
	love.graphics.setColor(self.color_text)
	love.graphics.printf(self.text,self.font,self.x,self.y,self.w,"left",0,1,1)

	-- line
	love.graphics.setColor(self.color_line)
	love.graphics.setLineWidth(1)
	love.graphics.line(self.x, self.y + self.h, self.x + self.w, self.y + self.h)

	-- cursor
	self.color_cursor[4] = alpha
	love.graphics.setColor(self.color_cursor)
	self.color_cursor[4] = 1
	love.graphics.line(self.cursorx, self.y + self.h - 4, self.cursorx, self.y + 3)

	-- bubble
	self:bubble()

	love.graphics.setColor(white)
end


function Textbox:collide()
	-- true if the mouse is on the button
	local x,y = love.mouse.getPosition()
	if x > self.x and x < self.x + self.w and y < self.y + self.h and y > self.y then
		return true
	else
		return false
	end
end


function Textbox:getText(text)
	if self.state == "clicked" then
		if self.text == self.empty_msg then self.text = "" end
		self.text = self.text:sub(1, self.cursorIdx) .. text .. self.text:sub(self.cursorIdx+1)
		self.cursorIdx = self.cursorIdx + 1
	end
end


function Textbox:controls()
	if self.state == "clicked" then
		if love.keyboard.isDown("backspace") then
			-- erase
			self.text = self.text:sub(1, self.cursorIdx-1) .. self.text:sub(self.cursorIdx+1)
			self.cursorIdx = self.cursorIdx - 1
						
		elseif love.keyboard.isDown("left") then
			-- move cursor left
			if self.cursorIdx > 0 then
				self.cursorIdx = self.cursorIdx - 1
			end

		elseif love.keyboard.isDown("right") then
			-- move cursor right
			if self.cursorIdx < #self.text then
				self.cursorIdx = self.cursorIdx + 1
			end

		elseif love.keyboard.isDown("return") then
			-- send command
			self.msg = self.text
			-- erase all
			self.text = ""
			self.cursorIdx = 0
		end
	end
end


function Textbox:bubble() -- a découper pour ne pas tout calculer à chaque fois
	if self.bubble_info ~= "" then
		local bubble_w = 250 -- max width of the bubble
		local width, wrapped_text = self.font:getWrap(self.bubble_info, bubble_w) -- max width of the text and text table
		if #wrapped_text == 1 then
			bubble_w = self.font:getWidth(self.bubble_info)
		end
		local bubble_h = self.font:getHeight(self.bubble_info)*#wrapped_text
		local alpha_max = 0.3
		local text_offset = 5
		local bubble_x = self.x+self.w+30
		local bubble_y = self.y +0.5*self.h - bubble_h*0.5

		if self.state == "fly" then
			if self.bubble_alpha < alpha_max then -- apparition
				self.bubble_alpha = self.bubble_alpha + 0.02
			end
		else
			if self.bubble_alpha > 0 then -- disparition
				self.bubble_alpha = self.bubble_alpha - 0.02
			end
		end
		love.graphics.setColor(0,0,0,self.bubble_alpha)
		love.graphics.rectangle("fill", bubble_x, bubble_y, bubble_w+2*text_offset, bubble_h, 5, 5)
		love.graphics.setColor(1,1,1,self.bubble_alpha)
		for i, text in pairs(wrapped_text) do
			local y = bubble_y + (i-1)*self.font:getHeight(self.bubble_info)
			love.graphics.printf(text, self.font, bubble_x+text_offset, y, bubble_w, "left",0,1,1)
		end
		-- love.graphics.printf(self.bubble_info,self.font,self.x+self.w+30+text_offset, self.y - bubble_h*0.5,bubble_w,"left",0,1,1)
		love.graphics.setColor(1,1,1,1)
	end
end