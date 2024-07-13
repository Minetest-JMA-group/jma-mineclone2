local S = minetest.get_translator("parties")



local function load_world_folder()
  local wrld_dir = minetest.get_worldpath() .. "/parties"
  local content = minetest.get_dir_list(wrld_dir)

  -- se la cartella di parties non esiste/è vuota, copio la cartella base `IGNOREME`
  if not next(content) then
    local src_dir = minetest.get_modpath("parties") .. "/IGNOREME"
    minetest.cpdir(src_dir, wrld_dir)
    os.remove(wrld_dir .. "/README.md")
    content = minetest.get_dir_list(wrld_dir)
  end
end

load_world_folder()





----------------------------------------------
------------------AUDIO_LIB-------------------
----------------------------------------------

if not minetest.get_modpath("audio_lib") then return end

audio_lib.register_type("parties", "notifications", S("Notifications"))

audio_lib.register_sound("notifications", "parties_invite", S("Party invite jingle"))
audio_lib.register_sound("notifications", "parties_join", S("Someone joins the party"))
audio_lib.register_sound("notifications", "parties_leave", S("Someone leaves the party"))
