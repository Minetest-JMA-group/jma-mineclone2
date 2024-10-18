local positions = {}

local function barrier_can_dig(pos,player)
    if player then
        local allowed, missing = minetest.check_player_privs(player, "barrier")
        return allowed
    else
        return false
    end
end

local function barrier_on_place(itemstack, placer, pointed_thing)
    if not barrier_can_dig(nil,placer) then
        minetest.chat_send_player(placer:get_player_name(),
        "You do not have permission to place barriers.")
        return
    else
        return minetest.item_place(itemstack, placer, pointed_thing)
    end
end

minetest.register_privilege("barrier", {
    give_to_admin = false,
    give_to_singleplayer = false,
    description = "Allowed to place and break barriers.",
})

minetest.register_privilege("barrier_see", {
    give_to_admin = false,
    give_to_singleplayer = false,
    description = "Allowed to see nearby invisible barriers.",
})

minetest.register_node("barrier:barrier", {
	description = "Barrier",
    node_dig_prediction = "",
    tiles = {"barrier_barrier.png"},
    groups = {cracky = 1},
    can_dig = barrier_can_dig,
    on_place = barrier_on_place,
})
minetest.register_node("barrier:barrier_transparent", {
	description = "Transparent Barrier",
    node_dig_prediction = "",
    tiles = {"barrier_barrier_transparent.png"},
	use_texture_alpha = "clip",
    groups = {cracky = 1},
    drawtype = "glasslike",
    sunlight_propagates = true,
    paramtype = "light",
    can_dig = barrier_can_dig,
    on_place = barrier_on_place,
})
minetest.register_node("barrier:barrier_invisible", {
	description = "Invisible Barrier",
    node_dig_prediction = "",
    tiles = {"barrier_barrier_transparent.png"},
    groups = {cracky = 1},
    drawtype = "airlike",
    sunlight_propagates = true,
    paramtype = "light",
    can_dig = barrier_can_dig,
    on_place = barrier_on_place,
})
minetest.register_node("barrier:barrier_liquid", {
	description = "Liquid Barrier",
    node_dig_prediction = "",
    tiles = {"barrier_barrier_transparent.png"},
    groups = {cracky = 1},
    drawtype = "airlike",
    sunlight_propagates = true,
    paramtype = "light",
    can_dig = barrier_can_dig,
    on_place = barrier_on_place,
    walkable = false,
    pointable=false,
    pointabilities = {nodes={["barrier:barrier_liquid"]=true}},
    buildable_to = true,
})

local castamount = 192

local function sunraydown(pos)
    for i = 1, castamount, 1 do
        pos.y = pos.y - 1
        local n = minetest.get_node(pos).name
        if minetest.registered_nodes[n] and not 
        minetest.registered_nodes[n].sunlight_propagates then
            return pos
        end
    end
    return pos
end

local function update_light(pos)
    local pos2 = sunraydown(pos)
    local vm = minetest.get_voxel_manip(pos2, pos)
    local l = vm:get_light_data()
    for index, value in ipairs(l) do
        l[index] = 255;
    end
    vm:set_light_data(l)
    vm:write_to_map(false)
end

minetest.register_node("barrier:barrier_sky", {
	description = "Sky Barrier",
    node_dig_prediction = "",
    tiles = {{name="barrier_barrier_sky.png",scale=1,align_style="world"}},
    --tiles = {"barrier_barrier_sky.png"},
	use_texture_alpha = "clip",
    groups = {cracky = 1},
    --drawtype = "glasslike",
    sunlight_propagates = true,
    light_source = minetest.LIGHT_MAX,
    paramtype = "light",
    can_dig = barrier_can_dig,
    on_place = barrier_on_place,
    after_place_node = function (pos, placer, itemstack, pointed_thing)
        update_light(pos)
    end
})



local timer = 0
local radius = 8 -- Node search radius around player
local cycle = 2 -- Cycle time for updates

local function barrier_particle(player)
    local ppos = player:get_pos()
    local areamin = vector.subtract(ppos, radius)
    local areamax = vector.add(ppos, radius)
    local fpos, num = minetest.find_nodes_in_area(
        areamin,
        areamax,
        {"barrier:barrier_invisible"}
    )
    for index, value in ipairs(fpos) do
        minetest.add_particle({
            pos = value,
            expirationtime = 2.1,
            texture = "barrier_particle.png",
            playername = player:get_player_name(),
            size = 6,
        })
    end
end

minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer < cycle then
        return
    end

    timer = 0
    local players = minetest.get_connected_players()
    for n = 1, #players do
        local allowed, missing = minetest.check_player_privs(players[n],"barrier_see")
        if allowed then
            barrier_particle(players[n])
        end
    end
end)


--TODO: make this betterer and turn offable

--[[local oldfixlight = minetest.fix_light

function minetest.fix_light(pos1,pos2)
    local old_succ = oldfixlight(pos1,pos2)
    --do stuff
    local cid = minetest.get_content_id("barrier:barrier_sky")
    local vm = minetest.get_voxel_manip(pos1,pos2)
    local dat = vm:get_data()
    for index, value in ipairs(dat) do
        print(minetest.get_name_from_content_id(value))
    end
    vm:set_light_data(dat)
    vm:write_to_map(false)
    --done
    return old_succ
end]]

minetest.register_on_dignode(function(pos, oldnode, digger)
    for i = 1, castamount, 1 do
        pos.y = pos.y+1
        if minetest.get_node(pos).name == "barrier:barrier_sky" then
            update_light(pos)
        end
    end
end)

minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
    for i = 1, castamount, 1 do
        pos.y = pos.y+1
        if minetest.get_node(pos).name == "barrier:barrier_sky" then
            update_light(pos)
        end
    end
end)