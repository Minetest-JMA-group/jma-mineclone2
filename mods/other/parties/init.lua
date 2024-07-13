local version = "2.2.0"
local modpath = minetest.get_modpath("parties")
local srcpath = modpath .. "/src"

parties = {}
parties.settings = {}

dofile(modpath .. "/libs/chatcmdbuilder.lua")

dofile(srcpath .. "/_load.lua")
dofile(minetest.get_worldpath() .. "/parties/SETTINGS.lua")

dofile(srcpath .. "/api.lua")
dofile(srcpath .. "/callbacks.lua")
dofile(srcpath .. "/commands.lua")
dofile(srcpath .. "/player_manager.lua")
dofile(srcpath .. "/utils.lua")

minetest.log("action", "[PARTIES] Mod initialised, running version " .. version)
