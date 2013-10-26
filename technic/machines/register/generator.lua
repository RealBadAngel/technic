function technic.register_generator(data) 
	local tier = data.tier
	local ltier = string.lower(tier)
	local tube_side_texture = data.tube and "technic_generator_"..ltier.."_side_tube.png"
			or "technic_generator_"..ltier.."_side.png"
	local generator_formspec =
		"invsize[8, 9;]"..
		"label[0, 0;Generator]"..
		"list[current_name;src;3, 1;1, 1;]"..
			"image[4, 1;1, 1;default_furnace_fire_bg.png]"..
		"list[current_player;main;0, 5;8, 4;]"
	
	local des=ltier.." Generator"
	minetest.register_node("technic:generator_"..ltier, {
		description = des, 
		tiles = {"technic_generator_"..ltier.."_top.png", "technic_machine_bottom.png", tube_side_texture, 
			tube_side_texture, tube_side_texture, "technic_generator_"..ltier.."_front.png"}, 
		paramtype2 = "facedir", 
		groups = {snappy=2, choppy=2, oddly_breakable_by_hand=2}, 
		legacy_facedir_simple = true, 
		sounds = default.node_sound_wood_defaults(), 
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("infotext", des)
			meta:set_int(data.tier.."_EU_supply", 0)
			-- Signal to the switching station that this device burns some
			-- sort of fuel and needs special handling
			meta:set_int(data.tier.."_EU_from_fuel", 1)
			meta:set_int("burn_time", 0)
			meta:set_string("formspec", generator_formspec)
			local inv = meta:get_inventory()
			inv:set_size("src", 1)
		end, 	
		can_dig = function(pos, player)
			local meta = minetest.get_meta(pos);
			local inv = meta:get_inventory()
			if not inv:is_empty("src") then
				minetest.chat_send_player(player:get_player_name(), 
					"Machine cannot be removed because it is not empty");
				return false
			else
				return true
			end
		end, 
	})
	minetest.register_node("technic:generator_"..ltier.."_active", {
		description = des, 
		tiles = {"technic_generator_"..ltier.."_top.png", "technic_machine_bottom.png", 
			tube_side_texture, tube_side_texture, 
			tube_side_texture, "technic_generator_"..ltier.."_front_active.png"}, 
		paramtype2 = "facedir", 
		groups = {snappy=2, choppy=2, oddly_breakable_by_hand=2, 
			not_in_creative_inventory=1}, 
		legacy_facedir_simple = true, 
		sounds = default.node_sound_wood_defaults(), 
		drop = "technic:generator_"..ltier, 
		can_dig = function(pos, player)
			local meta = minetest.get_meta(pos);
			local inv = meta:get_inventory()
			if not inv:is_empty("src") then
				minetest.chat_send_player(player:get_player_name(), 
					"Machine cannot be removed because it is not empty");
				return false
			else
				return true
			end
		end, 
	})
	minetest.register_abm({
		nodenames = {"technic:generator_"..ltier, "technic:generator_"..ltier.."_active"}, 
		interval = 1, 
		chance = 1, 
		action = function(pos, node, active_object_count, active_object_count_wider)
			local meta = minetest.get_meta(pos)
			local burn_time = meta:get_int("burn_time")
			local burn_totaltime = meta:get_int("burn_totaltime")
			-- If more to burn and the energy produced was used: produce some more
			if burn_time > 0 then
				meta:set_int(data.tier.."_EU_supply", data.supply) -- Give 200EUs
				burn_time = burn_time - 1
				meta:set_int("burn_time", burn_time)
			end
			-- Burn another piece of fuel
			if burn_time == 0 then
				local inv = meta:get_inventory()
				if not inv:is_empty("src") then 
					local fuellist = inv:get_list("src")
					fuel = minetest.get_craft_result({method = "fuel", width = 1, items = fuellist})
					if not fuel or fuel.time == 0 then
						meta:set_string("infotext", "Generator out of fuel")
						hacky_swap_node(pos, "technic:generator_"..ltier)
						return
					end
					meta:set_int("burn_time", fuel.time)
					meta:set_int("burn_totaltime", fuel.time)
					local stack = inv:get_stack("src", 1)
					stack:take_item()
					inv:set_stack("src", 1, stack)
					hacky_swap_node(pos, "technic:generator_"..ltier.."_active")
					meta:set_int(data.tier.."_EU_supply", data.supply)
				else
					hacky_swap_node(pos, "technic:generator_"..ltier)
					meta:set_int(data.tier.."_EU_supply", 0)
				end
			end
			local percent = math.floor((burn_time / burn_totaltime) * 100)
			meta:set_string("infotext", des.." ("..percent.."%)")
				meta:set_string("formspec", 
					"size[8, 9]"..
					"label[0, 0;Generator]"..
					"list[current_name;src;3, 1;1, 1;]"..
					"image[4, 1;1, 1;default_furnace_fire_bg.png^[lowpart:"..
					(percent)..":default_furnace_fire_fg.png]"..
					"list[current_player;main;0, 5;8, 4;]")
		end
	})
	technic.register_machine(data.tier, "technic:generator_"..ltier, technic.producer)
	technic.register_machine(data.tier, "technic:generator_"..ltier.."_active", technic.producer)
end