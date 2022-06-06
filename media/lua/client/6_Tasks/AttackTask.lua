AttackTask = {}
AttackTask.__index = AttackTask

function AttackTask:new(superSurvivor)

	local o = {}
	setmetatable(o, self)
	self.__index = self
		
	o.parent = superSurvivor
	o.Name = "Attack"
	o.OnGoing = false
	o.parent:DebugSay("--------- NPC DEBUG: "..tostring(o.parent:getName()).."Starting Attack")
	return o

end

function AttackTask:isComplete()
	self.parent:DebugSay("--------- NPC DEBUG: "..tostring(self.parent:getName()).." Attack IsComplete Triggered")
	--self.parent.player:Say( tostring(self.parent:needToFollow()) ..",".. tostring(self.parent:getDangerSeenCount() > 0) ..",".. tostring(self.parent.LastEnemeySeen) ..",".. tostring(not self.parent.LastEnemeySeen:isDead()) ..",".. tostring(self.parent:HasInjury() == false) )
	if(not self.parent:needToFollow()) and ((self.parent:getDangerSeenCount() > 0) or (getDistanceBetween(self.parent.LastEnemeySeen, self.parent.player) > 0)) and self.parent:hasWeapon() and (self.parent.LastEnemeySeen) and not self.parent.LastEnemeySeen:isDead() and (self.parent:HasInjury() == false) then 
		self.parent:DebugSay("--------- NPC DEBUG: "..tostring(self.parent:getName()).." [ATTACK TASK] - Starting IsComplete Triggered (It returned FALSE)")
		return false
	else 
		self.parent:StopWalk()
		self.parent:DebugSay("--------- NPC DEBUG: "..tostring(self.parent:getName()).." [ATTACK TASK] - Starting IsComplete Triggered (It returned TRUE)")
		return true 
	end
end

function AttackTask:isValid()
	if (not self.parent) or (not self.parent.LastEnemeySeen) or (not self.parent:isInSameRoom(self.parent.LastEnemeySeen)) or (self.parent.LastEnemeySeen:isDead()) then 
		self.parent:DebugSay("--------- NPC DEBUG: "..tostring(self.parent:getName()).." [ATTACK TASK] -Starting isValid Triggered (It returned FALSE)")
	return false 
	else 
		self.parent:DebugSay("--------- NPC DEBUG: "..tostring(self.parent:getName()).." [ATTACK TASK] -Starting isValid Triggered (It returned TRUE)")
	return true end
end

function AttackTask:update()
	self.parent:DebugSay("--------- NPC DEBUG: "..tostring(self.parent:getName()).." [ATTACK TASK] -Attack Task Update Triggered!")
	if(not self:isValid()) or (self:isComplete()) then 
	self.parent:DebugSay("--------- NPC DEBUG: "..tostring(self.parent:getName()).." [ATTACK TASK] -Attack Task Update Triggered! - [IT RETURNED FALSE & ENDED]")
	return false end
	
	local theDistance = getDistanceBetween(self.parent.LastEnemeySeen, self.parent.player)
	
	if(self.parent:usingGun()) and (self.parent:isWalkingPermitted()) then -- and (theDistance < 2.0) then
			self.parent:DebugSay("--------- NPC DEBUG: "..tostring(self.parent:getName()).." [ATTACK TASK] -Attack Task Trigger Update: Using gun and Walking permitted and distance < 2.0")
		local sq = getFleeSquare(self.parent.player,self.parent.LastEnemeySeen)
		self.parent:walkToDirect(sq)
		self.parent:DebugSay("backing away cuz i got gun" )
	elseif(self.parent.player:IsAttackRange(self.parent.LastEnemeySeen:getX(),self.parent.LastEnemeySeen:getY(),self.parent.LastEnemeySeen:getZ())) or (theDistance < 0.65 )then
			self.parent:DebugSay("--------- NPC DEBUG: "..tostring(self.parent:getName()).." [ATTACK TASK] - Attack Task Trigger Update: Not using gun and walking permitted and distance <= 2.0")
			--print(self.parent:getName().. " int attack range !" )
			local weapon = self.parent.player:getPrimaryHandItem()
			if(not weapon or (not self.parent:usingGun()) or ISReloadWeaponAction.canShoot(weapon))  then
				--print(self.parent:getName().. " can shoot/attack " )
				if (self.parent:CanAttackAlt()) then	
					self.parent:NPC_Attack(self.parent.LastEnemeySeen)
				end
			elseif(self.parent:usingGun()) then
				if(self.parent:ReadyGun(weapon) == false) then self.parent:reEquipMele() end
				--print(self.parent:getName().. " trying to ready gun" )
				--self.parent:Wait(1)
			end	
			--if(self.parent:usingGun()) then self.parent.Reducer = 0 end -- force delay when using gun
		
	end
	if(self.parent:isWalkingPermitted()) or (getDistanceBetween(self.parent.LastEnemeySeen, self.parent.player) > 1.5) then
		local cs = self.parent.LastEnemeySeen:getCurrentSquare()
		local fs = cs:getTileInDirection(self.parent.LastEnemeySeen:getDir())

		self.parent:DebugSay("--------- NPC DEBUG: "..tostring(self.parent:getName()).." [ATTACK TASK] - Attack Task Trigger Update: The last ElseIf Iswalkingpermitted")
		self.parent:ManageMoveSpeed()
		self.parent:walkToDirect(cs)

		if(fs) and (fs:isFree(true)) then
			self.parent:walkToDirect(fs)
		else 
			self.parent:walkToDirect(cs)
		end
	end		

	
	
end