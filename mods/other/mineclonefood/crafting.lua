
--cherry
minetest.register_craft({
	type = "shapeless",
	output = "mineclonefood:cherry",
	recipe = {"mcl_cherry_blossom:cherryleaves"},
})



--cherryjuce

minetest.register_craft({
	output = "mineclonefood:cherryjuce",
	recipe = {
		{"mineclonefood:cherry"},
		{"mineclonefood:cherry"},
		{"mcl_potions:glass_bottle"}
	},
})



--cerrycake

minetest.register_craft({
	output = "mineclonefood:cherry_cake",
	recipe = {
		{"mineclonefood:cherry", "mineclonefood:cherry", "mineclonefood:cherry"},
		{"mineclonefood:cherry", "mcl_mobitems:milk_bucket", "mineclonefood:cherry"},
		{"mcl_farming:wheat_item", "mcl_farming:wheat_item", "mcl_farming:wheat_item"}
	},
	replacements = {
		{"mcl_mobitems:milk_bucket", "mcl_buckets:bucket_empty"},
	},
})






--cherrysugar

minetest.register_craft({
	output = "mineclonefood:cherrysugar",
	recipe = {
		{"mcl_core:sugar"},
		{"mineclonefood:cherry"},
	},
})







--cherryloly

minetest.register_craft({
	output = "mineclonefood:cherryloly",
	recipe = {
		{"mineclonefood:cherrybonbon"},
		{"mcl_core:stick"},
	}
})









--sandcake

minetest.register_craft({
	output = "mineclonefood:sandcake",
	recipe = {
		{"mcl_core:sand", "mcl_core:sand", "mcl_core:sand"},
		{"mcl_core:sand", "mcl_mobitems:milk_bucket", "mcl_core:sand"},
		{"mcl_farming:wheat_item", "mcl_farming:wheat_item", "mcl_farming:wheat_item"}
	},
	replacements = {
		{"mcl_mobitems:milk_bucket", "mcl_buckets:bucket_empty"},
	},
})









--firecake

minetest.register_craft({
	output = "mineclonefood:firecake",
	recipe = {
		{"mcl_mobitems:blaze_powder", "mcl_mobitems:blaze_powder", "mcl_mobitems:blaze_powder"},
		{"mcl_mobitems:blaze_powder", "mcl_mobitems:milk_bucket", "mcl_mobitems:blaze_powder"},
		{"mcl_farming:wheat_item", "mcl_farming:wheat_item", "mcl_farming:wheat_item"}
	},
	replacements = {
		{"mcl_mobitems:milk_bucket", "mcl_buckets:bucket_empty"},
	},
})










--Sunfloweroil

minetest.register_craft({
	output = "mineclonefood:sunfloweroil",
	recipe = {
		{"mcl_flowers:sunflower"},
		{"mcl_potions:glass_bottle"},
	}
})








--Cherrybonbon

minetest.register_craft({
	type = "cooking",
	output = "mineclonefood:cherrybonbon",
	recipe = "mineclonefood:cherrysugar",
	cooktime = 10
})


















--Icecream(






--Cherry_Icecream

minetest.register_craft({
	output = "mineclonefood:cherry_icecream",
	recipe = {
		{"mineclonefood:cherry"},
		{"mcl_mobitems:milk_bucket"},
		{"mcl_core:bowl"}
	},
	replacements = {
		{"mcl_mobitems:milk_bucket", "mcl_buckets:bucket_empty"},
	},
})







--Sweet_berry_Icecream

minetest.register_craft({
	output = "mineclonefood:sweet_berry_icecream",
	recipe = {
		{"mcl_farming:sweet_berry"},
		{"mcl_mobitems:milk_bucket"},
		{"mcl_core:bowl"}
	},
	replacements = {
		{"mcl_mobitems:milk_bucket", "mcl_buckets:bucket_empty"},
	},
})



--Icecream)



minetest.register_craft({
	output = "mineclonefood:roasted_potatoes",
	recipe = {
		{"mcl_farming:potato_item_baked"},
		{"mcl_farming:potato_item_baked"},
		{"mineclonefood:sunfloweroil"}
	},
	replacements = {
		{"mineclonefood:sunfloweroil", "mcl_potions:glass_bottle"},
	},
})
