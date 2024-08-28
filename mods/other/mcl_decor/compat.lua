-- mcl_decor/compat.lua

local S = minetest.get_translator(minetest.get_current_modname())

-- MCL2 -> MCLA migration fix
minetest.register_alias("mcl_decor:oak_chair", "mcl_decor:wooden_chair")
minetest.register_alias("mcl_decor:wooden_chair", "mcl_decor:oak_chair")

-- Coalquartz -> Checkerboard
minetest.register_alias("mcl_decor:coalquartz_tile", "mcl_decor:checkerboard_tile")
minetest.register_alias("mcl_stairs:stair_coalquartz_tile", "mcl_stairs:stair_checkerboard_tile")
minetest.register_alias("mcl_stairs:stair_coalquartz_tile_outer", "mcl_stairs:stair_checkerboard_tile_outer")
minetest.register_alias("mcl_stairs:stair_coalquartz_tile_inner", "mcl_stairs:stair_checkerboard_tile_inner")
minetest.register_alias("mcl_stairs:slab_coalquartz_tile", "mcl_stairs:slab_checkerboard_tile")
minetest.register_alias("mcl_stairs:slab_coalquartz_tile_top", "mcl_stairs:slab_checkerboard_tile_top")
minetest.register_alias("mcl_stairs:slab_coalquartz_tile_double", "mcl_stairs:slab_checkerboard_tile_double")

-- Subtitles support
if minetest.global_exists("subtitles") then
	subtitles.register_description("mcl_decor_fridge_open", S("Fridge opens"))
	subtitles.register_description("mcl_decor_fridge_close", S("Fridge closes"))
	subtitles.register_description("mcl_decor_curtain", S("Curtain moves"))
end
