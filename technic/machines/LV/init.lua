
technic.register_tier("LV", "Low Voltage")

local path = technic.modpath.."/machines/LV"

-- Wiring stuff
dofile(path.."/cables.lua")
dofile(path.."/battery_box.lua")

-- Generators
if technic.config:get_bool("enable_producers") then
	dofile(path.."/solar_panel.lua")
	dofile(path.."/solar_array.lua")
	dofile(path.."/geothermal.lua")
	dofile(path.."/water_mill.lua")
	dofile(path.."/generator.lua")
end

-- Machines
dofile(path.."/alloy_furnace.lua")
dofile(path.."/electric_furnace.lua")
dofile(path.."/grinder.lua")
dofile(path.."/extractor.lua")
dofile(path.."/compressor.lua")

dofile(path.."/music_player.lua")

dofile(path.."/cnc.lua")
dofile(path.."/cnc_api.lua")
dofile(path.."/cnc_nodes.lua")

