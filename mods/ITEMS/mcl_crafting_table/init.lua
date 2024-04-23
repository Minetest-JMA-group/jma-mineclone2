---@diagnostic disable lowercase-global

local S = minetest.get_translator(minetest.get_current_modname())
local F = minetest.formspec_escape
local C = minetest.colorize
local show_formspec = minetest.show_formspec

mcl_crafting_table = {}

mcl_crafting_table.formspec = table.concat({
	"formspec_version[4]",
	"size[11.75,10.425]",

	"label[2.25,0.375;" .. F(C(mcl_formspec.label_color, S("Crafting"))) .. "]",

	mcl_formspec.get_itemslot_bg_v4(2.25, 0.75, 3, 3),
	"list[current_player;craft;2.25,0.75;3,3;]",

	"image[6.125,2;1.5,1;gui_crafting_arrow.png]",

	mcl_formspec.get_itemslot_bg_v4(8.2, 2, 1, 1, 0.2),
	"list[current_player;craftpreview;8.2,2;1,1;]",

	"label[0.375,4.7;" .. F(C(mcl_formspec.label_color, S("Inventory"))) .. "]",

	mcl_formspec.get_itemslot_bg_v4(0.375, 5.1, 9, 3),
	"list[current_player;main;0.375,5.1;9,3;9]",

	mcl_formspec.get_itemslot_bg_v4(0.375, 9.05, 9, 1),
	"list[current_player;main;0.375,9.05;9,1;]",

	"listring[current_player;craft]",
	"listring[current_player;main]",

	--Crafting guide button
	"image_button[0.325,1.95;1.1,1.1;craftguide_book.png;__mcl_craftguide;]",
	"tooltip[__mcl_craftguide;" .. F(S("Recipe book")) .. "]",
})

---@param player ObjectRef
function mcl_crafting_table.show_crafting_form(player)
	local inv = player:get_inventory()
	if inv then
		inv:set_width("craft", 3)
		inv:set_size("craft", 9)
	end

	show_formspec(player:get_player_name(), "main", mcl_crafting_table.formspec)
end

minetest.register_node("mcl_crafting_table:crafting_table", {
	description = S("Crafting Table"),
	_tt_help = S("3×3 crafting grid"),
	_doc_items_longdesc = S("A crafting table is a block which grants you access to a 3×3 crafting grid which allows you to perform advanced crafts."),
	_doc_items_usagehelp = S("Rightclick the crafting table to access the 3×3 crafting grid."),
	_doc_items_hidden = false,
	is_ground_content = false,
	tiles = { "crafting_workbench_top.png", "default_wood.png", "crafting_workbench_side.png",
		"crafting_workbench_side.png", "crafting_workbench_front.png", "crafting_workbench_front.png" },
	paramtype2 = "facedir",
	groups = { handy = 1, axey = 1, deco_block = 1, material_wood = 1, flammable = -1 },
	on_rightclick = function(pos, node, player, itemstack)
		if not player:get_player_control().sneak then
			mcl_crafting_table.show_crafting_form(player)
		end
	end,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 2.5,
})

minetest.register_craft({
	output = "mcl_crafting_table:crafting_table",
	recipe = {
		{ "group:wood", "group:wood" },
		{ "group:wood", "group:wood" }
	},
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_crafting_table:crafting_table",
	burntime = 15,
})

minetest.register_alias("crafting:workbench", "mcl_crafting_table:crafting_table")
minetest.register_alias("mcl_inventory:workbench", "mcl_crafting_table:crafting_table")
