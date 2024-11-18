S = minetest.get_translator("afk_indicator")

minetest.register_chatcommand("afk_stat",{
	description = S("Get the AFK time of players"),
	privs = {kick = true},
	func = function(name,param)
		local rs = ""
		for x,y in pairs(afk_indicator.get_all()) do
			if x ~= name then -- updates.lua:58, checking the player themself is meaningless
				rs = rs .. S("@1: @2",x,y) .. "\n"
			end
		end
		rs = rs .. S("Done.")
		return true, rs
	end,
})
