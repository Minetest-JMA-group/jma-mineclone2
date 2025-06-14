local nodeboxes = {
    ["parasol"] = {-0.05, -0.5, -0.05, 0.05, 1.5, 0.05},
    ["sunbed"] = {-0.5, -0.2, -0.6, 0.5, -0.1, 1.1},
}

local function lay(pos, node, player) -- Wrapper for mcl_cozy.lay to account for the longer sunbed length
	if node.param2 == 0 then
		pos.z = pos.z + 0.5
	elseif node.param2 == 1 then
		pos.x = pos.x + 0.5
	elseif node.param2 == 2 then
		pos.z = pos.z - 0.5
	elseif node.param2 == 3 then
		pos.x = pos.x - 0.5
	end
	return mcl_cozy.lay(pos, node, player)
end

core.register_node("summer_cosmetics:parasol_red", {
    description = "Red Parasol",
    drawtype = "mesh",
    mesh = "parasol.gltf",
    tiles = {"parasol_red.png"},
    paramtype = "light",
    sunlight_propagates = true,
    walkable = true,
    groups = {axey = 1},
    collision_box = {
        type = "fixed",
        fixed = nodeboxes.parasol
    },
    selection_box = {
        type = "fixed",
        fixed = nodeboxes.parasol
    }
})

core.register_node("summer_cosmetics:sunbed", {
    description = "Sunbed",
    drawtype = "mesh",
    mesh = "sunbed.gltf",
    tiles = {"sunbed_red.png"},
    paramtype = "light",
    sunlight_propagates = true,
    walkable = true,
    paramtype2 = "facedir",
    groups = {axey = 1},
    collision_box = {
        type = "fixed",
        fixed = nodeboxes.sunbed
    },
    selection_box = {
        type = "fixed",
        fixed = nodeboxes.sunbed
    },
    on_rightclick = lay,
})

core.register_node("summer_cosmetics:tropical_drink", {
    description = "Tropical drink",
    drawtype = "mesh",
    mesh = "tropical_drink.gltf",
    tiles = {"tropical_drink.png"},
    paramtype = "light",
    sunlight_propagates = true,
    use_texture_alpha = "clip",
})

if core.get_modpath("mcl_jukebox") then
    mcl_jukebox.register_record("Beach", "fancyfinn9, Ottobunny", "summer_cosmetics_beach", "summer_cosmetics_beach_disc.png", "summer_cosmetics_beach")
end