UI = class('UI')

function UI:initialize()
	self.bar = Bar:new(love.graphics.getWidth()/2, 0)
end

function UI:mousepressed(x, y, mbutton)
	if mbutton == 'l' then
		self.bar:mousepressed(x, y)
	end
end

function UI:draw()
	self.bar:draw()
end

function UI:updateButton(tag)
	self.bar:updateButton(tag)
end


Bar = class('Bar')

function Bar:initialize(x, y)
	self.x = x
	self.y = y

	self.objects = {}
	
	self.height = 50
	table.insert(self.objects, Button:new('Trace', '(F1)', 'img/traceIcon32.png', 50, self.height, function() game:toggleTrace() end, true, true))
	table.insert(self.objects, Button:new('Objects', '(F2)', 'img/objectIcon32.png', 50, self.height, function() game:toggleObjects() end, true, true))
	table.insert(self.objects, Button:new('Absorb', '(F3)', 'img/absorbIcon32alt.png', 50, self.height, function() game:toggleAbsorb() end, true, false))
	
	table.insert(self.objects, Button:new('Directions', '(F4)', 'img/directionIcon32.png', 50, self.height, function() game:toggleLimit() end, true, false))
	table.insert(self.objects, ChangeButton:new(100, self.height, function() return game:getDirections() end,
		function() game:changeDirections(1) end,
		function() game:changeDirections(-1) end))
		
	table.insert(self.objects, Button:new('Follow', '(F5)', 'img/cameraIcon32.png', 50, self.height, function() game:toggleFollow() end, true, false))
	table.insert(self.objects, ChangeButton:new(100, self.height, function() return game:getCameraTarget() end,
		function() game:changeCameraTarget(1) end,
		function() game:changeCameraTarget(-1) end))
	
	table.insert(self.objects, Button:new('Pause', '(Space)', 'img/pause32.png', 50, self.height, function() game:toggleFreeze() end, true, false))
	table.insert(self.objects, Button:new('Origin', '(F6)', 'img/origin32.png', 50, self.height, function() game:resetCamera() end, false))
	table.insert(self.objects, Button:new('Clear', '(F7)', 'img/clearIcon32X.png', 50, self.height, function() game:clear() end, false))
	
	
	
	local width = 0
	for i, object in ipairs(self.objects) do
		width = width + object.width
	end
	
	self.width = width
	
	local leftX = self.x - width/2
	for i, object in ipairs(self.objects) do
		object.x = leftX + object.width/2
		object.y = self.y
		
		object:posSet()
		
		leftX = leftX + object.width
	end
end

function Bar:update()
	for i, object in ipairs(self.objects) do
		object:update()
	end
end

function Bar:mousepressed(x, y)
	if y <= self.height then -- height is uniform for all objects on the bar
		for i, object in ipairs(self.objects) do
			object:mousepressed(x, y, i)
		end
		
		return true
	end
end

function Bar:draw()
	for i, object in ipairs(self.objects) do
		local mod = 0
		if i == 1 then mod = -1 end
		if i == #self.objects then mod = 1 end
		object:draw(mod)
	end
	
	for i, object in ipairs(self.objects) do
		object:drawTag()
	end
end

function Bar:updateButton(tag)
	for k, button in pairs(self.objects) do
		if button.tag == tag then
			button:mousepressed(nil, nil, nil, true)
		end
	end
end



Button = class('Button')

function Button:initialize(tag, key, img, width, height, action, toggle, default)
	self.tag = tag
	self.key = key
	self.img = love.graphics.newImage(img)
	
	self.x = nil
	self.y = nil
	
	self.width = width
	self.height = height
	self.tabHeight = 5
	
	self.toggle = toggle
	self.on = default or false
	
	self.font = font[32]
	
	self.color = {28, 28, 28}
	self.tabColor = {21, 166, 189}
	self.defaultIconColor = {255, 255, 255}
	self.hoveredIconColor = {204, 144, 41}
	self.clickedIconColor = {15, 209, 154}
	
	self.currentIconColor = {r = self.defaultIconColor[1], g = self.defaultIconColor[2], b = self.defaultIconColor[3]}
	self.hovered = false
	self.clickLight = false
	self.action = action or function() end
	
	self.tagWidth = self.font:getWidth(self.tag..' '..self.key)
	self.tagHeight = self.font:getHeight()
end

function Button:update(x, y)
	self.hovered = false
	
	local x, y = love.mouse.getPosition()
	if y <= self.height then
		if x > self.x - self.width/2 and x < self.x + self.width/2 then
			self.hovered = true
		end
	end
end

function Button:mousepressed(x, y, i, override)
	if override or x > self.x - self.width/2 and x < self.x + self.width/2 then -- y check has already happened at a higher level
		self.action()
		
		if self.toggle then
			if self.on then
				self.on = false
			else
				self.on = true
			end
		else
			--[[
			self.clickLight = true
			
			self.currentIconColor = {r = self.clickedIconColor[1], g = self.clickedIconColor[2], b = self.clickedIconColor[3]}
			tween.start(.5, game.UI.bar.objects[i].currentIconColor, {r = self.defaultIconColor[1], g = self.defaultIconColor[2], b = self.defaultIconColor[3]}, 'inOutQuad', function() 
					self.clickLight = false
					self.hovered = false
				end)
			]]
		end
	end
end

function Button:draw(mod)
    love.graphics.setFont(self.font)
	
	local x, y = self.x, self.y
	local w, h = self.width, self.height
	love.graphics.setColor(self.color)
	love.graphics.rectangle('fill', x - w/2, y, w, h)
	
	if mod == 1 then
		love.graphics.polygon('fill', x+w/2, y, x+w/2+h+self.tabHeight, y, x+w/2, y+h+self.tabHeight)
	elseif mod == -1 then
		love.graphics.polygon('fill', x-w/2, y, x-w/2-h-self.tabHeight, y, x-w/2, y+h+self.tabHeight)
	end
	
	love.graphics.setColor(self.tabColor)
	love.graphics.rectangle('fill', x - w/2, y + h, w, self.tabHeight)
	
	if mod == 1 then
		love.graphics.polygon('fill', x+w/2, y+h, x+w/2+self.tabHeight, y+h, x+w/2, y+h+self.tabHeight)
	elseif mod == -1 then
		love.graphics.polygon('fill', x-w/2, y+h, x-w/2-self.tabHeight, y+h, x-w/2, y+h+self.tabHeight)
	end
	
	love.graphics.setColor(self.currentIconColor.r, self.currentIconColor.g, self.currentIconColor.b)
	if self.on then
		love.graphics.setColor(self.clickedIconColor)
	elseif self.hovered and not self.clickLight then
		love.graphics.setColor(self.hoveredIconColor)
	end
	
	love.graphics.draw(self.img, x - self.img:getWidth()/2, y + h/2 - self.img:getHeight()/2)
end

function Button:drawTag()
	if self.hovered then
		local mX, mY = love.mouse:getPosition()
		local border = 4
		
		love.graphics.setColor(150, 150, 150, 125)
		love.graphics.rectangle('fill', mX, mY, self.tagWidth + border*2, self.tagHeight + border*2)
		
		love.graphics.setColor(0, 0, 0)
		love.graphics.print(self.tag..' '..self.key, mX+border, mY+border)
	end
end

function Button:posSet()

end