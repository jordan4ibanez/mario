--table for breaking aesthetic
breakage = {}
minetest.register_globalstep(function(dtime)
	for _,player in ipairs(minetest.get_connected_players()) do
		if player:get_hp() > 0 or not minetest.setting_getbool("enable_damage") then
			local pos = player:getpos()
			pos.y = pos.y+1.9
			local itemer = minetest.get_node(pos).name
			if itemer ~= "air" and itemer ~= "ignore" then
				--do this so blocks don't instantly dissapear, removing the illusion that the player
				--is breaking it with their head
				if breakage[player:get_player_name()] == false or breakage[player:get_player_name()] == nil then
					breakage[player:get_player_name()] = true
					minetest.after(0.05, function()
						breakage[player:get_player_name()] = false
						minetest.remove_node(pos)
						minetest.add_item(pos, itemer)
						minetest.sound_play("break", {
							pos = pos,
							max_hear_distance = 20,
							gain = 1.0,
						})
						--particles
						local texture = minetest.registered_nodes[itemer].tiles[1]
						minetest.add_particlespawner({
							amount = 10,
							time = 0.01,
							minpos = {x=pos.x-0.5, y=pos.y, z=pos.z-0.5},
							maxpos = {x=pos.x+0.5, y=pos.y, z=pos.z+0.5},
							minvel = {x=-1, y=0, z=-1},
							maxvel = {x=1, y=0, z=1},
							minacc = {x=0, y=-10, z=0},
							maxacc = {x=0, y=-10, z=0},
							minexptime = 1,
							maxexptime = 1,
							minsize = 1,
							maxsize = 1,
							collisiondetection = true,
							vertical = false,
							texture = texture,
						})
					end)
				end
			end			
		end
	end
end)
minetest.register_globalstep(function(dtime)
	for _,player in ipairs(minetest.get_connected_players()) do
		if player:get_hp() > 0 or not minetest.setting_getbool("enable_damage") then
			local pos = player:getpos()
			local inv = player:get_inventory()
			--collect coins
			for _,object in ipairs(minetest.env:get_objects_inside_radius(pos, 1)) do
				if not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "__builtin:item" then
					if inv and inv:room_for_item("main", ItemStack(object:get_luaentity().itemstring)) then
						if object:get_luaentity().itemstring ~= "" and object:get_luaentity().age > 2 then
							inv:add_item("main", ItemStack(object:get_luaentity().itemstring))
							minetest.sound_play("coin", {
								pos = pos,
								gain = 0.4,
							})
							object:get_luaentity().itemstring = ""
							object:remove()
						end

					end
				end
			end
		end
	end
end)
