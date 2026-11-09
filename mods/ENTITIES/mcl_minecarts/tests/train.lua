-- Run with: luajit tests/train.lua [path/to/mcl_minecarts]
local modpath = arg[1] or arg[0]:match("^(.*)/tests/[^/]+$") or "."
if jit then jit.off() end -- Instruction budgets must also catch tight loops.

local carts, saved, logs
local mod = {
	MAX_TRAIN_LENGTH = 4,
	get_cart_data = function(uuid) return carts[uuid] end,
	save_cart_data = function(uuid) saved[uuid] = true end,
	reverse_cart_direction = function(cart) cart.reversed = not cart.reversed end,
}
mcl_minecarts = mod
minetest = {log = function(level, message) logs[#logs + 1] = {level, message} end}
dofile(modpath .. "/train.lua")

local function reset()
	carts, saved, logs = {}, {}, {}
end

local function chain(prefix, count)
	local result = {}
	for i = 1, count do
		local cart = {uuid = prefix .. i, velocity = 0, mass = 1}
		carts[cart.uuid] = cart
		result[i] = cart
		if i > 1 then
			result[i - 1].ahead = cart.uuid
			cart.behind = result[i - 1].uuid
		end
	end
	return result
end

local function collect(cart)
	local result, seen = {}, {}
	for c in mod.train_cars(cart) do
		assert(not seen[c.uuid], "cart yielded twice: " .. c.uuid)
		seen[c.uuid] = true
		result[#result + 1] = c.uuid
		assert(#result <= mod.MAX_TRAIN_LENGTH, "train exceeds limit")
	end
	return table.concat(result, ",")
end

local function topology()
	local result = {}
	for uuid, cart in pairs(carts) do
		result[#result + 1] = uuid .. ":" .. (cart.behind or "-") .. ":" .. (cart.ahead or "-")
	end
	table.sort(result)
	return table.concat(result, ";")
end

local passed = 0
local function test(name, fn)
	reset()
	debug.sethook(function() error("instruction budget exceeded: " .. name) end, "", 1000000)
	fn()
	debug.sethook()
	passed = passed + 1
	print("PASS " .. name)
end

test("healthy traversal and double reversal from every train position", function()
	for n = 1, 4 do
		reset()
		local train = chain("A", n)
		local before = topology()
		for _, cart in ipairs(train) do
			assert(mod.train_length(cart) == n)
			assert(mod.is_in_same_train(cart, train[1]))
			collect(cart)
			assert(topology() == before)
			mod.reverse_train(cart)
			local reverse = {}
			for i = n, 1, -1 do
				reverse[#reverse + 1] = train[i].uuid
				assert(train[i].reversed)
			end
			assert(collect(cart) == table.concat(reverse, ","))
			mod.reverse_train(cart)
			assert(topology() == before)
		end
		assert(not next(saved) and #logs == 0, "healthy trains must not be repaired")
	end
end)

test("observed two-cart ring is repaired and both records are saved", function()
	local train = chain("A", 2)
	train[1].behind, train[2].ahead = train[2].uuid, train[1].uuid
	assert(mod.train_length(train[1]) == 2)
	assert(mod.is_in_same_train(train[1], train[2]))
	collect(train[2])
	assert(saved.A1 and saved.A2 and #logs == 1)
	local repaired = topology()
	collect(train[1])
	assert(topology() == repaired and #logs == 1)
end)

test("self-links in either direction are removed", function()
	for _, field in ipairs({"ahead", "behind"}) do
		reset()
		local cart = chain("A", 1)[1]
		cart[field] = cart.uuid
		assert(collect(cart) == cart.uuid)
		assert(not cart.ahead and not cart.behind and saved[cart.uuid])
	end
end)

test("cycles and oversized trains are bounded from every starting position", function()
	for n = 2, 8 do
		for origin = 1, n do
			for _, cyclic in ipairs({false, true}) do
				reset()
				local train = chain("A", n)
				if cyclic then
					train[1].behind, train[n].ahead = train[n].uuid, train[1].uuid
				end
				collect(train[origin])
				for _, cart in ipairs(train) do collect(cart) end
				for _, cart in ipairs(train) do
					if cart.ahead then assert(carts[cart.ahead].behind == cart.uuid) end
					if cart.behind then assert(carts[cart.behind].ahead == cart.uuid) end
				end
			end
		end
	end
end)

test("missing neighbors are cleared and saved", function()
	for _, field in ipairs({"ahead", "behind"}) do
		reset()
		local cart = chain("A", 1)[1]
		cart[field] = "missing"
		assert(collect(cart) == cart.uuid)
		assert(not cart[field] and saved[cart.uuid])
	end
end)

test("repairing nonreciprocal links preserves the neighbor's valid train", function()
	for _, field in ipairs({"ahead", "behind"}) do
		reset()
		local other = chain("B", 2)
		local cart = chain("A", 1)[1]
		cart[field] = other[1].uuid
		assert(collect(cart) == cart.uuid)
		assert(collect(other[1]) == "B1,B2")
		assert(saved.A1 and not saved.B1 and not saved.B2)
	end
end)

test("linking enforces the combined length and joins free ends", function()
	for a = 1, 4 do
		for b = 1, 4 do
			reset()
			local first, second = chain("A", a), chain("B", b)
			local before = topology()
			local linked = mod.link_cart_ahead(first[a], second[1])
			assert(linked == (a + b <= mod.MAX_TRAIN_LENGTH))
			if linked then
				assert(mod.train_length(first[1]) == a + b)
				assert(first[a].ahead == second[1].uuid and second[1].behind == first[a].uuid)
			else
				assert(topology() == before and #logs == 0)
			end
		end
	end
end)

test("self-linking, ring closure, and occupied ends are rejected without changes", function()
	local first, second = chain("A", 2), chain("B", 2)
	local before = topology()
	assert(not mod.link_cart_ahead(first[2], first[2]))
	assert(not mod.link_cart_ahead(first[2], first[1]))
	assert(not mod.link_cart_ahead(first[1], second[1]))
	assert(not mod.link_cart_ahead(first[2], second[2]))
	assert(topology() == before and not next(saved) and #logs == 0)
end)

-- Exercise the actual local collision handler without loading a whole world.
local function upvalue(fn, wanted)
	for i = 1, math.huge do
		local name, value = debug.getupvalue(fn, i)
		assert(name, "missing upvalue " .. wanted)
		if name == wanted then return value end
	end
end

core = minetest
core.settings = {get_bool = function(_, _, default) return default end}
core.get_current_modname = function() return "mcl_minecarts" end
core.get_translator = function() return function(s) return s end end
core.get_modpath = function() end
mcl_util = {make_mcl_logger = function() return function() end, false end}
vl_tuning = {setting = function() end}
vector = {
	add = function(a, b) return {x=a.x+b.x, y=a.y+b.y, z=a.z+b.z} end,
	direction = function() return {x=1, y=0, z=0} end,
	dot = function(a, b) return a.x*b.x + a.y*b.y + a.z*b.z end,
}
local movement = dofile(modpath .. "/movement.lua")
local collide = upvalue(upvalue(movement.do_movement, "do_movement_step"), "handle_cart_collision")

local function collision(a, b)
	a.velocity, b.velocity = 3, 0
	a.connected_at, b.connected_at = {x=0,y=0,z=0}, {x=1,y=0,z=0}
	a.dir, b.dir = {x=1,y=0,z=0}, {x=1,y=0,z=0}
	core.get_meta = function() return {get_string = function() return "carts" end} end
	core.deserialize = function() return {[b.uuid]=true} end
	local rail_calls = 0
	mod.get_rail_direction = function(_, dir) rail_calls = rail_calls + 1; return dir end
	collide(a, a.connected_at, a.dir)
	return rail_calls
end

test("collision accepts a valid link and sets the second cart in motion", function()
	local a, b = chain("A", 1)[1], chain("B", 1)[1]
	assert(collision(a, b) == 1)
	assert(a.ahead == b.uuid and b.behind == a.uuid and b.velocity == 3)
end)

test("collision falls back to elastic response when linking is rejected", function()
	local a, b = chain("A", 2), chain("B", 3)
	local before = topology()
	assert(collision(a[2], b[1]) == 0)
	assert(topology() == before)
	assert(a[2].velocity == 0 and b[1].velocity == 3)
end)

test("same-train collision cannot close the observed ring", function()
	local train = chain("A", 2)
	local before = topology()
	assert(collision(train[2], train[1]) == 0)
	assert(topology() == before and mod.train_length(train[1]) == 2)
end)

print(passed .. " tests passed")
