local Warpable = Class(function(self, inst)
    self.inst = inst
    self.onopen = nil
    self.onclose = nil
    self.widgetname = nil
	self.wascontainer = false
	self.colradius = nil
end)

function Warpable:Warp(warper)
	if warper and warper:HasTag("player") then

		-- deployable
		if self.inst:HasTag("eyeturret") or self.inst:HasTag("wall") then
			self.inst:Remove()
        	if warper.components.inventory then
        		local deployable = SpawnPrefab(self.inst.prefab .. "_item")
				warper.components.inventory:GiveItem(deployable)
			end
		end

		-- houses
		if self.inst.components.spawner
		  and self.inst.components.spawner:IsOccupied() then
        	self.inst.components.spawner:ReleaseChild()
        end

    	-- fire source
    	if self.inst.components.burnable then
    		self.inst.components.burnable:Extinguish()
    	end

		-- store Physics info
		if self.inst.Physics then
			self.colradius = self.inst.Physics:GetRadius()
			self.inst.Physics = nil
		end

		-- store container info
		if self.inst.components.container then
			self.wascontainer = true
			self.onopen = self.inst.components.container.onopenfn
			self.onclose = self.inst.components.container.onclosefn
			self.widgetname = self.inst.prefab
	    	self.inst.components.container:DropEverything()
    		self.inst:RemoveComponent("container")
		end

		self.inst:AddComponent("inventoryitem")
	end
end

return Warpable