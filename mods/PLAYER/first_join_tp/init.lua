minetest.register_on_joinplayer(function(player)
	local meta = player:get_meta()
	if meta:get_string("player_already_joined") ~= "true" then
		player:set_pos({x = 223.0, y = 144.5, z = 518.1})
		meta:set_string("player_already_joined", "true")
	end
end)
