Ui = Object:extend()
require 'func/textbox'


function Ui:new(font)
	self.font = font

	-- textboxes
	self.textbox = {}
	-- self.textbox[0] = Textbox("", 0.5*wind_w, 0.8*wind_h, self.font, "What is your command?")
	-- self.textbox[0].empty_msg = "What is your command?"
	-- self.textbox[0].w = 300
	-- self.textbox[0].x = 0.33*wind_w
	-- self.textbox[0].y = 0.8*wind_h

	-- slidebars
	self.slidebar = {}

	-- buttons
	self.button = {}
end


function Ui:update()
	-- buttons
	if next(self.button) ~= nil then
		for i = 0, #self.button do
			self.button[i]:update()
		end
	end

	-- slidebars
	if next(self.slidebar) ~= nil then
		for i = 0, #self.slidebar do 
			self.slidebar[i]:update()
		end
	end

	-- textboxes
	-- if next(self.textbox) ~= nil then
	-- 	for i = 0, #self.textbox do 
	-- 		self.textbox[i]:update()
	-- 	end
	-- end
end


function Ui:draw()
	-- buttons
	if next(self.button) ~= nil then
		for i = 0, #self.button do -- draw menu buttons
			self.button[i]:draw()
		end
	end

	-- slidebars
	if next(self.slidebar) ~= nil then
		for i = 0, #self.slidebar do -- draw menu buttons
			self.slidebar[i]:draw()
		end
	end

	-- textboxes
	-- if next(self.textbox) ~= nil then
	-- 	for i = 0, #self.textbox do 
	-- 		self.textbox[i]:draw()
	-- 	end
	-- end
end


