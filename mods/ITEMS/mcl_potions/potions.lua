local S = minetest.get_translator(minetest.get_current_modname())
--local brewhelp = S("Try different combinations to create potions.")

local function potion_image(colorstring, opacity)
	if not opacity then
		opacity = 127
	end
	return "mcl_potions_potion_overlay.png^[colorize:"..colorstring..":"..tostring(opacity).."^mcl_potions_potion_bottle.png"
end

local how_to_drink = S("Use the “Place” key to drink it.")
local potion_intro = S("Drinking a potion gives you a particular effect.")

local function time_string(dur)
	if not dur then
		return nil
	end
	return math.floor(dur/60)..string.format(":%02d",math.floor(dur % 60))
end

local function perc_string(num)

	local rem = math.floor((num-1.0)*100 + 0.1) % 5
	local out = math.floor((num-1.0)*100 + 0.1) - rem

	if (num - 1.0) < 0 then
		return out.."%"
	else
		return "+"..out.."%"
	end
end


-- ██████╗░███████╗░██████╗░██╗░██████╗████████╗███████╗██████╗░
-- ██╔══██╗██╔════╝██╔════╝░██║██╔════╝╚══██╔══╝██╔════╝██╔══██╗
-- ██████╔╝█████╗░░██║░░██╗░██║╚█████╗░░░░██║░░░█████╗░░██████╔╝
-- ██╔══██╗██╔══╝░░██║░░╚██╗██║░╚═══██╗░░░██║░░░██╔══╝░░██╔══██╗
-- ██║░░██║███████╗╚██████╔╝██║██████╔╝░░░██║░░░███████╗██║░░██║
-- ╚═╝░░╚═╝╚══════╝░╚═════╝░╚═╝╚═════╝░░░░╚═╝░░░╚══════╝╚═╝░░╚═╝
--
-- ██████╗░░█████╗░████████╗██╗░█████╗░███╗░░██╗░██████╗
-- ██╔══██╗██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝
-- ██████╔╝██║░░██║░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░
-- ██╔═══╝░██║░░██║░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗
-- ██║░░░░░╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝
-- ╚═╝░░░░░░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░


function return_on_use(def, effect, dur)
	return function (itemstack, user, pointed_thing)
		if pointed_thing.type == "node" or def.no_potion then
			if user and not user:get_player_control().sneak then
				-- Use pointed node's on_rightclick function first, if present
				local node = minetest.get_node(pointed_thing.under)
				if user and not user:get_player_control().sneak then
					if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
						return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
					end
				end
			end
		elseif pointed_thing.type == "object" then
			return itemstack
		end

		local old_name, old_count = itemstack:get_name(), itemstack:get_count()
		itemstack = minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		if old_name ~= itemstack:get_name() or old_count ~= itemstack:get_count() or minetest.is_creative_enabled(user:get_player_name()) then
			mcl_potions._use_potion(itemstack, user, def.color)
			def.on_use(user, effect, dur)
		end
		return itemstack
	end
end

function mcl_potions.register_potion(def)
	local function get_tt(dur, is_II)
		local _tt
		if def.custom_tt then
			_tt = def.custom_tt(dur, is_II)
		elseif def.no_effect then
			_tt = minetest.colorize("grey", S("No effect"))
		elseif def.is_dur then
			_tt = minetest.colorize("#5454ff", ("%s (%s)"):format(S(def.description) .. (is_II and " II" or ""), time_string(dur)))
		else
			_tt = minetest.colorize("#5454ff", def.description .. (is_II and " II" or ""))
		end
		if def.on_apply then
			_tt = _tt .. "\n\n" .. minetest.colorize("#b800ae", S("When Applied:")) .. "\n" .. def.on_apply(dur, is_II)
		end
		return _tt
	end
	local function get_splash_fun(effect, sp_dur)
		if def.is_dur then
			return function(player, redx) def.on_use(player, effect, sp_dur*redx) end
		elseif not def.no_effect then
			return function(player, redx) def.on_use(player, effect*redx, sp_dur) end
		end
		return function() end
	end
	local function get_lingering_fun(effect, ling_dur)
		if def.is_dur then
			return function(player) def.on_use(player, effect, ling_dur) end
		elseif not def.no_effect then
			return function(player) def.on_use(player, effect*0.5, ling_dur) end
		end
		return function() end
	end
	local function get_arrow_fun(effect, dur)
		if def.is_dur and not def.no_effect then
			return function(player) def.on_use(player, effect, dur) end
		end
		return function() end
	end

	local duration = def.duration and def.duration[1] or 0
	local on_use = return_on_use(def, 1, duration)
	minetest.register_craftitem("mcl_potions:"..def.name, {
		description = (def.custom_desc and def.custom_desc or ("%s %s"):format(S("Potion"), S("of "..def.description))),
		_tt_help = get_tt(duration),
		stack_max = 1,
		inventory_image = def.image or potion_image(def.color, def.opacity),
		wield_image = def.image or potion_image(def.color, def.opacity),
		groups = def.groups or {brewitem=1, food=3, can_eat_when_full=1 },
		on_place = on_use,
		on_secondary_use = on_use,
	})

	if def.color and not def.no_throwable then
		local splash_def = {
			tt = get_tt(duration),
			longdesc = def._longdesc,
			potion_fun = get_splash_fun(1, duration),
			no_effect = def.no_effect,
			instant = def.instant,
		}
		local ling_def = {
			tt = get_tt(math.floor(duration/4)),
			longdesc = def._longdesc,
			potion_fun = get_lingering_fun(1, math.floor(duration/4)),
			no_effect = def.no_effect,
			instant = def.instant,
		}
		local arrow_def = {
			tt = get_tt(math.floor(duration/8)),
			longdesc = def._longdesc,
			potion_fun = get_arrow_fun(1, math.floor(duration/8)),
			no_effect = def.no_effect,
			instant = def.instant,
		}
		mcl_potions.register_splash(def.name, (def.custom_desc and def.custom_desc or S("Splash Potion") .. " " .. S("of " .. def.description)), def.color, splash_def)
		mcl_potions.register_lingering(def.name, (def.custom_desc and def.custom_desc or S("Lingering Potion") .. " " .. S("of " .. def.description)), def.color, ling_def)
		if not def.no_arrow then
			mcl_potions.register_arrow(def.name, (def.custom_desc and def.custom_desc or S("Arrow") .. " " .. S("of " .. def.description)), def.color, arrow_def)
		end
	end

	if def.is_plus then
		local duration = def.duration and def.duration[2] or 0
		local on_use = return_on_use(def, 1, def.duration[2])
		minetest.register_craftitem("mcl_potions:"..def.name.."_plus", {
			description = (def.custom_desc and def.custom_desc or ("%s %s"):format(S("Potion"), S("of "..def.description))),
			_tt_help = get_tt(duration),
			stack_max = 1,
			inventory_image = def.image or potion_image(def.color, def.opacity),
			wield_image = def.image or potion_image(def.color, def.opacity),
			groups = def.groups or {brewitem=1, food=3, can_eat_when_full=1},
			on_place = on_use,
			on_secondary_use = on_use,
		})

		if def.color and not def.no_throwable then
			local splash_def_pl = {
				tt = get_tt(duration),
				longdesc = def._longdesc,
				potion_fun = get_splash_fun(1, duration),
				no_effect = def.no_effect,
				instant = def.instant,
			}
			local ling_def_pl = {
				tt = get_tt(math.floor(duration/4)),
				longdesc = def._longdesc,
				potion_fun = get_lingering_fun(1, math.floor(duration/4)),
				no_effect = def.no_effect,
				instant = def.instant,
			}
			local arrow_def_pl = {
				tt = get_tt(math.floor(duration/8)),
				longdesc = def._longdesc,
				potion_fun = get_arrow_fun(1, math.floor(duration/8)),
				no_effect = def.no_effect,
				instant = def.instant,
			}
			mcl_potions.register_splash(def.name.."_plus", (def.custom_desc and def.custom_desc or S("Splash Potion") .. " " .. S("of " .. def.description)), def.color, splash_def_pl)
			mcl_potions.register_lingering(def.name.."_plus", (def.custom_desc and def.custom_desc or S("Lingering Potion") .. " " .. S("of " .. def.description)), def.color, ling_def_pl)
			if not def.no_arrow then
				mcl_potions.register_arrow(def.name.."_plus", (def.custom_desc and def.custom_desc or S("Arrow") .. " " .. S("of " .. def.description)), def.color, arrow_def_pl)
			end
		end
	end

	if def.is_II then
		local duration = def.duration and def.duration[3] or 0
		local on_use = return_on_use(def, 2, duration)
		minetest.register_craftitem("mcl_potions:"..def.name.."_2", {
			description = (def.custom_desc and def.custom_desc or ("%s %s"):format(S("Potion"), S("of "..def.description))),
			_tt_help = get_tt(duration, true),
			stack_max = 1,
			inventory_image = def.image or potion_image(def.color, def.opacity),
			wield_image = def.image or potion_image(def.color, def.opacity),
			groups = def.groups or {brewitem=1, food=3, can_eat_when_full=1},
			on_place = on_use,
			on_secondary_use = on_use,
		})

		if def.color and not def.no_throwable then
			local splash_def_2 = {
				tt = get_tt(duration, true),
				longdesc = def._longdesc,
				potion_fun = get_splash_fun(2, duration),
				no_effect = def.no_effect,
				instant = def.instant,
			}
			local ling_def_2 = {
				tt = get_tt(math.floor(duration/4), true),
				longdesc = def._longdesc,
				potion_fun = get_lingering_fun(2, math.floor(duration/4)),
				no_effect = def.no_effect,
				instant = def.instant,
			}
			local arrow_def_2 = {
				tt = get_tt(math.floor(duration/8), true),
				longdesc = def._longdesc,
				potion_fun = get_arrow_fun(2, math.floor(duration/8)),
				no_effect = def.no_effect,
				instant = def.instant,
			}
			mcl_potions.register_splash(def.name.."_2", (def.custom_desc and def.custom_desc or S("Splash Potion") .. " " .. S("of " .. def.description)), def.color, splash_def_2)
			mcl_potions.register_lingering(def.name.."_2", (def.custom_desc and def.custom_desc or S("Lingering Potion") .. " " .. S("of " .. def.description)), def.color, ling_def_2)
			if not def.no_arrow then
				mcl_potions.register_arrow(def.name.."_2", (def.custom_desc and def.custom_desc or S("Arrow") .. " " .. S("of " .. def.description)), def.color, arrow_def_2)
			end
		end
	end
end

-- ██████╗░░█████╗░████████╗██╗░█████╗░███╗░░██╗
-- ██╔══██╗██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║
-- ██████╔╝██║░░██║░░░██║░░░██║██║░░██║██╔██╗██║
-- ██╔═══╝░██║░░██║░░░██║░░░██║██║░░██║██║╚████║
-- ██║░░░░░╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║
-- ╚═╝░░░░░░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝
--
-- ██████╗░███████╗███████╗██╗███╗░░██╗██╗████████╗██╗░█████╗░███╗░░██╗░██████╗
-- ██╔══██╗██╔════╝██╔════╝██║████╗░██║██║╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝
-- ██║░░██║█████╗░░█████╗░░██║██╔██╗██║██║░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░
-- ██║░░██║██╔══╝░░██╔══╝░░██║██║╚████║██║░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗
-- ██████╔╝███████╗██║░░░░░██║██║░╚███║██║░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝
-- ╚═════╝░╚══════╝╚═╝░░░░░╚═╝╚═╝░░╚══╝╚═╝░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░


local definitions = {
	awkward = {
		name = "awkward",
		custom_desc = S("Awkward Potion"),
		no_arrow = true,
		no_effect = true,
		color = "#0000FF",
		groups = {brewitem=1, food=3, can_eat_when_full=1},
		on_use = minetest.item_eat(0, "mcl_potions:glass_bottle"),
	},
	mundane = {
		name = "mundane",
		custom_desc = S("Mudane Potion"),
		no_arrow = true,
		no_effect = true,
		color = "#0000FF",
		on_use = minetest.item_eat(0, "mcl_potions:glass_bottle"),
	},
	thick = {
		name = "thick",
		custom_desc = S("Thick Potion"),
		no_arrow = true,
		no_effect = true,
		color = "#0000FF",
		on_use = minetest.item_eat(0, "mcl_potions:glass_bottle"),
	},
	--[[dragon_breath = {
		name = "dragon_breath",
		custom_desc = S("Dragon Breath"),
		no_arrow = true,
		no_potion = true,
		no_throwable = true,
		no_effect = true,
		image = "mcl_potions_dragon_breath.png",
		groups = { brewitem = 1 },
		on_use = nil,
		stack_max = 64,
	},]]
	healing = {
		name = "healing",
		description = "Healing",
		color = "#F82423",
		instant = true,
		on_use = function(player, level)
			local obj = player:get_luaentity()
			local hp = 2*math.pow(2,level)
			if player:get_hp() <= 0 then return end
			if obj and obj.is_mob then
				if obj.harmed_by_heal then hp = -hp end
				obj.health = math.max(obj.health + hp, obj.hp_max)
			elseif player:is_player() then
				player:set_hp(math.min(player:get_hp() + hp, player:get_properties().hp_max), { type = "set_hp", other = "healing" })
			end
		end,
		custom_tt = function(dur, II)
			return minetest.colorize("#5454ff", S("Instant Healing") .. (II and " II" or ""))
		end,
		is_II = true,
		duration = {180, 480, 90}
	},
	harming = {
		name = "harming",
		description = "Harming",
		color = "#430A09",
		instant = true,
		on_use = function(player, level)
			mcl_util.deal_damage(player, 3*math.pow(2,level), {type = "magic"})
		end,
		custom_tt = function(dur, II)
			return minetest.colorize("#ff404b", S("Instant Damage") .. (II and " II" or ""))
		end,
		is_II = true,
		is_inv = true,
	},
	night_vision = {
		name = "night_vision",
		description = "Night Vision",
		color = "#1F1FA1",
		effect = nil,
		is_dur = true,
		on_use = mcl_potions.night_vision_func,
		is_plus = true,
		duration = {180, 480, 90}
	},
	swiftness = {
		name = "swiftness",
		description = "Swiftness",
		color = "#7CAFC6",
		is_dur = true,
		on_use = mcl_potions.swiftness_func,
		on_apply = function(dur, II)
			return minetest.colorize("#5454ff", ("Speed: +%d%%"):format(II and 40 or 20))
		end,
		is_II = true,
		is_plus = true,
		duration = {180, 480, 90}
	},
	slowness = {
		name = "slowness",
		description = "Slowness",
		color = "#5A6C81",
		is_dur = true,
		on_use = function(player, level, duration)
			mcl_potions.slowness_func(player, (level==2 and 4 or 1), duration)
		end,
		on_apply = function(dur, II)
			return minetest.colorize("#ff404b", ("Speed: -%d%%"):format(II and 60 or 15))
		end,
		custom_tt = function(dur, II)
			return minetest.colorize("#ff404b", S("Slowness") .. (II and " IV" or "") .. " (" .. time_string(dur) .. ")")
		end,
		is_II = true,
		is_plus = true,
		is_inv = true,
		duration = {90, 240, 20}
	},
	leaping = {
		name = "leaping",
		description = "Leaping",
		color = "#22FF4C",
		is_dur = true,
		on_use = mcl_potions.leaping_func,
		is_II = true,
		is_plus = true,
		duration = {180, 480, 90}
	},
	poison = {
		name = "poison",
		description = "Poison",
		color = "#4E9331",
		is_dur = true,
		on_use = mcl_potions.poison_func,
		custom_tt = function(dur, II)
			return minetest.colorize("#ff404b", S("Poison") .. (II and " II" or "") .. " (" .. time_string(dur) .. ") ")
		end,
		is_II = true,
		is_plus = true,
		is_inv = true,
		duration = {45, 90, 21}
	},
	regeneration = {
		name = "regeneration",
		description = "Regeneration",
		color = "#CD5CAB",
		is_dur = true,
		on_use = mcl_potions.regeneration_func,
		is_II = true,
		is_plus = true,
		duration = {45, 90, 22}
	},
	invisibility = {
		name = "invisibility",
		description = "Invisibility",
		color = "#7F8392",
		is_dur = true,
		on_use = mcl_potions.invisiblility_func,
		is_plus = true,
		duration = {180, 480}
	},
	water_breathing = {
		name = "water_breathing",
		description = "Water Breathing",
		color = "#2E5299",
		is_dur = true,
		on_use = function(player, level, duration) 
			mcl_potions.apply_usual_effect(player, level, duration, "water_breathing") 
		end,
		is_plus = true,
		duration = {180, 480}
	},
	fire_resistance = {
		name = "fire_resistance",
		description = "Fire Resistance",
		color = "#E49A3A",
		is_dur = true,
		on_use = function(player, level, duration) 
			mcl_potions.apply_usual_effect(player, level, duration, "fire_resistance") 
		end,
		is_plus = true,
		duration = {180, 480}
	},
	weakness = {
		name = "weakness",
		description = "Weakness",
		color = "#494E49",
		is_dur = true,
		on_use = function(player, level, duration) 
			mcl_potions.apply_usual_effect(player, level, duration, "weakness") 
		end,
		on_apply = function() return minetest.colorize("#ff404b", ("Damage: -4")) end,
		is_plus = true,
		duration = {90, 240}
	},
	strength = {
		name = "strength",
		description = "Strength",
		color = "#962524",
		is_dur = true,
		opacity = 500,
		on_use = function(player, level, duration) 
			mcl_potions.apply_usual_effect(player, level, duration, "strength") 
		end,
		on_apply = function(dur, II)
			return minetest.colorize("#5454ff", ("Damage: +%d"):format(II and 6 or 3))
		end,
		is_plus = true,
		is_II = true,
		duration = {180, 480, 90}
	},
	slow_falling = {
		name = "slow_falling",
		description = "Slow Falling",
		color = "#FCF4D5",
		is_dur = true,
		on_use = function(player, level, duration) 
			mcl_potions.apply_usual_effect(player, level, duration, "slow_falling") 
		end,
		is_plus = true,
		duration = {90, 240}
	},
	turtle_master = {
		name = "turtle_master",
		description = "the Turtle Master",
		color = "#8B83E3",
		on_use = function(player, level, duration)
			mcl_potions.apply_usual_effect(player, (level==1 and 3 or 4), duration, "resistance")
			mcl_potions.slowness_func(player, (level==1 and 4 or 6), duration)
		end,
		is_dur = true,
		is_plus = true,
		is_II = true,
		on_apply = function(dur, II)
			return minetest.colorize("#ff404b", ("Speed: -%d%%"):format(II and 90 or 60))
		end,
		custom_tt = function(dur, II)
			return ("%s\n%s"):format(minetest.colorize("#ff404b", S("Slowness") .. (II and " VI" or " IV") .. " ("..time_string(dur)..")"),
			minetest.colorize("#5454ff", S("Resistance") .. (II and " IV" or " III") .. " ("..time_string(dur)..")"))
		end,
		duration = {20, 40, 20}
	}
}

for _, definition in pairs(definitions) do
	mcl_potions.register_potion(definition)
end

mcl_potions.register_splash("disorganization", minetest.colorize("orange", S("Disorganization Potion")), "yellow", {
	tt = "Shuffles player's hotbar",
	potion_fun = function(player, redx)
		if not player:is_player() then return end
		local list = player:get_inventory():get_list("main")
		for i = 9, 2, -1 do
			local j = math.random(i)
			list[i], list[j] = list[j], list[i]
		end
		player:get_inventory():set_list("main", list)
	end
})