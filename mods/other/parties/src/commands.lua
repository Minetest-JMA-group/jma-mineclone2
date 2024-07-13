local S = minetest.get_translator("parties")



ChatCmdBuilder.new("party", function(cmd)
  -- nulla
  cmd:sub("", function(sender)
    minetest.chat_send_player(sender, minetest.colorize("#ffff00", S("Do '/party help' to see all the subcommands")))
    end)

  -- aiuto
  cmd:sub("help", function(sender)
    minetest.chat_send_player(sender,
      minetest.colorize("#ffff00", S("COMMANDS")) .. "\n"
      .. minetest.colorize("#00ffff", "/party disband") .. ": " .. S("disbands your party") .. "\n"
      .. minetest.colorize("#00ffff", "/party invite") .. " <" .. S("player") .. ">: " .. S("invites a player to join your party. It creates one if there is none") .. "\n"
      .. minetest.colorize("#00ffff", "/party join") .. " (<" .. S("player") .. ">): " .. S("accepts an invitation. If you've received more than one, specify 'player'") .. "\n"
      .. minetest.colorize("#00ffff", "/party kick") .. " <" .. S("player") .. ">: " .. S("kicks a player from the party") .. "\n"
      .. minetest.colorize("#00ffff", "/party leave") .. ": " .. S("leaves the party you're in") .. "\n"
      .. minetest.colorize("#00ffff", "/p") .. " <" .. S("message") .. ">: " .. S("sends a message in the party chat"))
  end)

  -- invito
  cmd:sub("invite :target", function(sender, p_name)
    parties.invite(sender, p_name)
    end)

  -- accettazione
  cmd:sub("join", function(sender)
    parties.join(sender)
    end)

  -- accettazione con nick
  cmd:sub("join :inviter", function(sender, inviter)
    parties.join(sender, inviter)
    end)

  -- abbandono
  cmd:sub("leave", function(sender)
    parties.leave(sender)
    end)

  -- espulsione
  cmd:sub("kick :target", function(sender, p_name)
    parties.kick(sender, p_name)
    end)

  -- scioglimento
  cmd:sub("disband", function(sender)
    parties.disband(sender)
    end)
end,{
    description = minetest.colorize("#ffff00", S("manage parties") .. ". " .. S("Do '/party help' to see all the subcommands")),
})



ChatCmdBuilder.new("p", function(cmd)
  -- nulla
  cmd:sub("", function(sender)
    minetest.chat_send_player(sender, minetest.colorize("#e6482e", S("[!] You must enter a message after '/p'!")))
    end)

  -- chat gruppo
  cmd:sub(":message:text", function(sender, message)
    parties.chat_send_party(sender, message)
    end)
end,{
  params = "<" .. S("message") .. ">",
  description = S("sends a message in the party chat")
})
