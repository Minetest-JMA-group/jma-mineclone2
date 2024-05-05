spawn_command = {}
spawn_command.pos = {x=0, y=3, z=0}
local cursed_world_exists = minetest.get_modpath("cursed_world")

if minetest.setting_get_pos("static_spawnpoint") then
	spawn_command.pos = minetest.setting_get_pos("static_spawnpoint")
end

function teleport_to_spawn(name)
	local player = minetest.get_player_by_name(name)
	if player == nil then
		return false
	end
	local pos = player:get_pos()
	if math.abs(spawn_command.pos.x-pos.x)<20 and math.abs(spawn_command.pos.z-pos.z)<20 then
		minetest.chat_send_player(name, "Already close to spawn!")
	else
		player:set_pos(spawn_command.pos)
		minetest.chat_send_player(name, "Teleported to spawn!")
	end
end

minetest.register_chatcommand("spawn", {
	description = "Teleport you to spawn point.",
	func = teleport_to_spawn,
})
