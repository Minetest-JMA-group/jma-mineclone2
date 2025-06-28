local modname = core.get_current_modname()
local S = core.get_translator(modname)

local mod_target = core.get_modpath("mcl_target")
local how_to_throw = S("Use the punch key to throw.")

-- Snowball
core.register_craftitem("mcl_throwing:snowball", {
	description = S("Snowball"),
	_tt_help = S("Throwable"),
	_doc_items_longdesc = S("Snowballs can be thrown or launched from a dispenser for fun. Hitting something with a snowball does nothing."),
	_doc_items_usagehelp = how_to_throw,
	inventory_image = "mcl_throwing_snowball.png",
	stack_max = 64,
	groups = {weapon_ranged = 1},
	on_use = mcl_throwing.get_player_throw_function("mcl_throwing:snowball_entity"),
	_on_dispense = mcl_throwing.dispense_function,
})

-- The snowball entity
local function snowball_particles(pos, vel)
	local vel = vector.normalize(vector.multiply(vel, -1))
	core.add_particlespawner({
		amount = 20,
		time = 0.001,
		minpos = pos,
		maxpos = pos,
		minvel = vector.offset(vel, -2, 3, -2),
		maxvel = vector.offset(vel, 2, 5, 2),
		minacc = {x=0, y=-9.81, z=0},
		maxacc = {x=0, y=-9.81, z=0},
		minexptime = 1,
		maxexptime = 3,
		minsize = 0.7,
		maxsize = 0.7,
		collisiondetection = true,
		collision_removal = true,
		object_collision = false,
		texture = "weather_pack_snow_snowflake"..math.random(1,2)..".png",
	})
end
vl_projectile.register("mcl_throwing:snowball_entity", {
	physical = true,
	timer=0,
	textures = {"mcl_throwing_snowball.png"},
	visual_size = {x=0.5, y=0.5},
	collisionbox = {-0.1,-0.1,-0.1,0.1,0.1,0.1},
	pointable = false,

	get_staticdata = mcl_throwing.get_staticdata,
	on_activate = mcl_throwing.on_activate,
	_vl_projectile = {
		behaviors = {
			vl_projectile.collides_with_solids,
			vl_projectile.collides_with_entities,
		},
		allow_punching = function(self, _, _, object)
			if self.timer < 1 and self._owner == mcl_util.get_entity_id(object) then return false end

			local le = object:get_luaentity()
			return le and (le.is_mob or le._hittable_by_projectile) or object:is_player()
		end,
		on_collide_with_solid = function(self, pos, node)
			if mod_target and node.name == "mcl_target:target_off" then
				mcl_target.hit(vector.round(pos), 0.4) --4 redstone ticks
			end

			snowball_particles(self._last_pos or pos, self.object:get_velocity())
		end,
		on_collide_with_entity = function(self, pos, entity)
			snowball_particles(self._last_pos or pos, self.object:get_velocity())
		end,
		sounds = {
			on_solid_collision = {"mcl_throwing_snowball_impact_hard", {max_hear_distance=16, gain=0.7}, true},
			on_entity_collision = {"mcl_throwing_snowball_impact_soft", {max_hear_distance=16, gain=0.7}, true}
		},
		damage_groups = {snowball_vulnerable = 3},
	},
})
mcl_throwing.register_throwable_object("mcl_throwing:snowball", "mcl_throwing:snowball_entity", mcl_throwing.default_velocity)

