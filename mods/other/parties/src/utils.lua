function parties.play_sound(track_name, p_name)
  if minetest.get_modpath("audio_lib") then
    audio_lib.play_sound(track_name, {to_player = p_name})
  else
    minetest.sound_play(track_name, { to_player = p_name })
  end
end