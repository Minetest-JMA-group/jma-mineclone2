mcl_throwing = {
	default_velocity = 22,
}

local modpath = core.get_modpath(core.get_current_modname())

--
-- Snowballs and other throwable items
--

local entity_mapping = {}
local velocities = {}

function mcl_throwing.register_throwable_object(name, entity, velocity)
	entity_mapping[name] = entity
	velocities[name] = velocity
	assert(core.registered_entities[entity], entity.." not registered")
	assert(core.registered_entities[entity]._vl_projectile)
end

function mcl_throwing.throw(throw_item, pos, dir, velocity, thrower)
	velocity = velocity or velocities[throw_item] or mcl_throwing.default_velocity
	core.sound_play("mcl_throwing_throw", {pos=pos, gain=0.4, max_hear_distance=16}, true)

	local itemstring = ItemStack(throw_item):get_name()
	local obj = vl_projectile.create(entity_mapping[itemstring], {
		pos = pos,
		owner = thrower,
		dir = dir,
		velocity = velocity,
		drag = 3,
	})
	obj:get_luaentity()._thrower = thrower
	return obj
end

-- Throw item
function mcl_throwing.get_player_throw_function(entity_name, velocity)
	local function func(item, player, pointed_thing)
		local playerpos = player:get_pos()
		local dir = player:get_look_dir()
		mcl_throwing.throw(item, {x=playerpos.x, y=playerpos.y+1.5, z=playerpos.z}, dir, velocity, player)
		if not minetest.is_creative_enabled(player:get_player_name()) then
			item:take_item()
		end
		return item
	end
	return func
end

function mcl_throwing.dispense_function(stack, dispenserpos, droppos, dropnode, dropdir)
	-- Launch throwable item
	local shootpos = vector.add(dispenserpos, vector.multiply(dropdir, 0.51))
	mcl_throwing.throw(stack:get_name(), shootpos, dropdir)
end

-- Staticdata handling because objects may want to be reloaded
function mcl_throwing.get_staticdata(self)
	local thrower
	-- Only save thrower if it's a player name
	if type(self._thrower) == "string" then
		thrower = self._thrower
	end
	local data = {
		_lastpos = self._lastpos,
		_thrower = thrower,
	}
	return minetest.serialize(data)
end

function mcl_throwing.on_activate(self, staticdata, dtime_s)
	local data = core.deserialize(staticdata)
	self._staticdata = data
	if data then
		self._lastpos = data._lastpos
		self._thrower = data._thrower
	end
end

dofile(modpath.."/register.lua")
