local CircularBuffer = {}
CircularBuffer.__index = CircularBuffer

function CircularBuffer.new(Size: number)
	local NewBuffer = setmetatable({
		Size = Size,
		Buffer = table.create(Size),
		ReadIndex = 1,
		WriteIndex = 0,
	}, CircularBuffer)
	
	return NewBuffer
end

function CircularBuffer:GetSize(Current)
	return Current and #self.Buffer or self.Size
end

function CircularBuffer:IsEmpty()
	return self:GetSize(true) == 0
end

function CircularBuffer:IsFull()
	return self:GetSize(true) == self:GetSize()
end

function CircularBuffer:Enqueue(...)
	local ToQueue = {...}
	
	assert(#ToQueue > 0, "function 'Enqueue' in 'CircularBuffer' takes variable arguments, 0 provided")
	
	for Index, Value in pairs(ToQueue) do
		self.WriteIndex = (self.WriteIndex + 1) % self.Size
		self.Buffer[self.WriteIndex] = Value
		
		if self.ReadIndex == self.WriteIndex then
			self.ReadIndex = (self.ReadIndex + 1) % self.Size
		end
	end
end

function CircularBuffer:Dequeue(EmitAll: boolean): table 
	local Out
	
	if EmitAll then
		Out = {}
		
		while task.wait() do
			if self.Buffer[self.ReadIndex] then
				Out[#Out + 1] = self.Buffer[self.ReadIndex]
				self.Buffer[self.ReadIndex] = nil
			end
			
			if self.ReadIndex == self.WriteIndex or self.WriteIndex == 0 then
				break
			end
			
			self.ReadIndex = (self.ReadIndex + 1) % self.Size
		end
		
		return Out
	end
	
	if self:IsEmpty() then
		return
	end
	
	Out = self.Buffer[self.ReadIndex]
	self.Buffer[self.ReadIndex] = nil
	
	self.ReadIndex = (self.ReadIndex + 1) % self.Size
	
	return Out
end

return CircularBuffer
