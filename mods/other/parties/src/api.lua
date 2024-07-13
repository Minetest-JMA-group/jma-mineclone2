local function add_party_prefix() end
local function wait_for_join() end
local function format_party_message() end

local S = minetest.get_translator("parties")
local current_parties = {}                  -- KEY party_leader; VALUE: {members (party_leader included)}
local players_in_parties = {}               -- KEY p_name; VALUE: party_leader
local players_invited = {}                  -- KEY p_name; VALUE: {inviter1 = countdown(), inviter2 = countdown() etc.}





----------------------------
-- INTERNAL USE ONLY
function parties.init_player(p_name)
  players_invited[p_name] = {}
end
----------------------------



function parties.invite(sender, p_name)
  -- se si è in un gruppo ma non si è il capo gruppo
  if players_in_parties[sender] and not current_parties[sender] then
    minetest.chat_send_player(sender, minetest.colorize("#e6482e", S("[!] Only the party leader can perform this action!")))
    return end

  -- se si invita se stessi
  if sender == p_name then
    minetest.chat_send_player(sender, minetest.colorize("#e6482e", S("[!] You can't invite yourself!")))
    return end

  -- se il giocatore non è online
  if not minetest.get_player_by_name(p_name) then
    minetest.chat_send_player(sender, minetest.colorize("#e6482e", S("[!] This player is not online!")))
    return end

  -- se si è raggiunto il limite di giocatorɜ
  if players_in_parties[sender] and #parties.get_party_members(sender) == parties.settings.MAX_PLAYERS_PER_PARTY then
    minetest.chat_send_player(sender, minetest.colorize("#e6482e", S("[!] The party has reached the maximum amount of players! (@1)", parties.settings.MAX_PLAYERS_PER_PARTY)))
    return end

  -- se è già in un gruppo
  if players_in_parties[p_name] then
    minetest.chat_send_player(sender, minetest.colorize("#e6482e", S("[!] This player is already in a party!")))
    return end

  -- se è già stato invitato dalla stessa persona
  if players_invited[p_name][sender] then
    minetest.chat_send_player(sender, minetest.colorize("#e6482e", S("[!] You've already invited this player!")))
    return end

  -- se non può essere invitato (callback)
  for _, callback in ipairs(parties.registered_on_pre_party_invite) do
    if not callback(sender, p_name) then return end
  end

  parties.play_sound("parties_invite", p_name)
  minetest.chat_send_player(sender, add_party_prefix(S("Invite to @1 successfully sent", p_name)))
  minetest.chat_send_player(p_name, add_party_prefix(S("@1 has invited you to a party, would you like to join? (/party join, or /party join @2 within 60 seconds)", sender, sender)))

  -- se non ha accettato dopo 60 secondi, annullo l'invito
  players_invited[p_name][sender] = wait_for_join(sender, p_name)

  -- eventuali callback
  for _, callback in ipairs(parties.registered_on_party_invite) do
    callback(sender, p_name)
  end
end



function parties.join(p_name, inviter)
  -- se non ha nesssun invito
  if not next(players_invited[p_name]) then
    minetest.chat_send_player(p_name, minetest.colorize("#e6482e", S("[!] You have no pending invites!")))
    return end

  -- se chi lo ha invitato è specificato ma non esiste come giocatore
  if inviter and not players_invited[p_name][inviter] then
     minetest.chat_send_player(p_name, minetest.colorize("#e6482e", S("[!] You have no pending invites from this player!")))
     return end

  local party_leader

  -- ottenimento capo gruppo
  if not inviter then
    local inverted_invites_table = {}
    for k, v in pairs(players_invited[p_name]) do
      table.insert(inverted_invites_table, k)
    end

    -- se ha più inviti e non ha specificato chi ha invitato, annullo
    if #inverted_invites_table > 1 then
      minetest.chat_send_player(p_name, minetest.colorize("#e6482e", S("[!] More players have invited you in their party: please specify the nick of the one you want to join!")))
      return end

    party_leader = inverted_invites_table[1]
  else
    party_leader = inviter
  end

  -- se si è raggiunto il limite di giocatorɜ
  if parties.is_player_party_leader(party_leader) and #parties.get_party_members(party_leader) == parties.settings.MAX_PLAYERS_PER_PARTY then
    minetest.chat_send_player(p_name, minetest.colorize("#e6482e", S("[!] The party has reached the maximum amount of players! (@1)", parties.settings.MAX_PLAYERS_PER_PARTY)))
    minetest.chat_send_player(party_leader, add_party_prefix(minetest.colorize("#ededed", S("@1 has tried to enter but the party is full", p_name))))
    return end

  -- se il capo gruppo si è disconnesso nei secondi d'invito
  if not minetest.get_player_by_name(party_leader) then
    minetest.chat_send_player(p_name, minetest.colorize("#e6482e", S("[!] The party leader has disconnected!")))
    players_invited[p_name][party_leader]:cancel()
    players_invited[p_name][party_leader] = nil
    return
  end

  -- se non può accettare (richiamo)
  for _, callback in ipairs(parties.registered_on_pre_party_join) do
    if not callback(party_leader, p_name) then
      minetest.chat_send_player(party_leader, add_party_prefix(minetest.colorize("#ededed", S("@1 has tried to enter but an external condition has prevented them from doing it", p_name))))
      players_invited[p_name][party_leader]:cancel()
      players_invited[p_name][party_leader] = nil
      return
    end
  end

  local new_group = players_in_parties[party_leader] == nil

  -- se non esisteva un gruppo, lo creo. Non controllo se il capo gruppo può entrare
  -- dato che spetta alla mod esterna tramite pre_party_join
  if new_group then
    current_parties[party_leader] = {party_leader}
    players_in_parties[party_leader] = party_leader

    for old_inviter, job in pairs(players_invited[party_leader]) do
      if minetest.get_player_by_name(old_inviter) then
        minetest.chat_send_player(old_inviter, add_party_prefix(minetest.colorize("#ededed", S("@1 has joined another party", party_leader))))
        job:cancel()
      end
    end
  end

  -- riproduzione suono
  for _, pl_name in pairs(current_parties[party_leader]) do
    parties.play_sound("parties_join", pl_name)
  end

  parties.chat_send_party(party_leader, S("@1 has joined the party", p_name), true)

  for old_inviter, job in pairs(players_invited[p_name]) do
    if old_inviter ~= party_leader and minetest.get_player_by_name(old_inviter) then
      minetest.chat_send_player(old_inviter, add_party_prefix(minetest.colorize("#ededed", S("@1 has joined another party", p_name))))
    end
    job:cancel()
  end

  players_invited[p_name] = {}
  players_in_parties[p_name] = party_leader

  table.insert(current_parties[party_leader], p_name)
  parties.play_sound("parties_join", p_name)
  minetest.chat_send_player(p_name, add_party_prefix(S("You've joined @1's party", party_leader)))

  -- eventuali richiami
  for _, callback in ipairs(parties.registered_on_party_join) do
    callback(party_leader, p_name)
  end

  if new_group then
    for _, callback in ipairs(parties.registered_on_party_join) do
      callback(party_leader, party_leader)
    end
  end
end



function parties.leave(p_name)
  -- se non si è in un gruppo
  if not players_in_parties[p_name] then
    minetest.chat_send_player(p_name, minetest.colorize("#e6482e", S("[!] You must enter a party first!")))
    return end

  local party_leader = players_in_parties[p_name]

  -- riproduzione suono
  for _, pl_name in pairs(current_parties[party_leader]) do
    parties.play_sound("parties_leave", pl_name)
  end

  -- eventuali richiami
  for _, callback in ipairs(parties.registered_on_party_leave) do
    callback(party_leader, p_name, 1)
  end

  -- rimuovo dal gruppo
  for k, pl_name in pairs(current_parties[party_leader]) do
    if pl_name == p_name then
      table.remove(current_parties[party_leader], k)
      break
    end
  end

  players_in_parties[p_name] = nil
  minetest.chat_send_player(p_name, add_party_prefix(S("You've left the party")), true)

  -- se ad abbandonare è stato il capo gruppo, lo cambio
  if p_name == party_leader then
    local new_leader = current_parties[party_leader][1]

    parties.chat_send_party(new_leader, S("@1 has left the party", p_name), true)
    parties.change_party_leader(p_name, new_leader)

    -- ...sciolgo se sono rimasti in 2
    if #current_parties[new_leader] == 1 then
      parties.disband(new_leader)
    end

  else
    parties.chat_send_party(party_leader, S("@1 has left the party", p_name), true)

    if #current_parties[party_leader] == 1 then
      parties.disband(party_leader)
    end
  end
end



function parties.kick(p_name, t_name)
  -- se non si è in un gruppo
  if not players_in_parties[p_name] then
    minetest.chat_send_player(p_name, minetest.colorize("#e6482e", S("[!] You must enter a party first!")))
    return end

  -- se si è in un gruppo ma non si è il capo gruppo
  if players_in_parties[p_name] and not current_parties[p_name] then
    minetest.chat_send_player(p_name, minetest.colorize("#e6482e", S("[!] Only the party leader can perform this action!")))
    return end

  -- se la persona non è in gruppo
  if not parties.is_player_in_party(t_name, p_name) then
    minetest.chat_send_player(p_name, minetest.colorize("#e6482e", S("[!] There is no player called @1 in your party!", t_name)))
    return end

  -- se si prova ad auto-cacciarsi
  if p_name == t_name then
    minetest.chat_send_player(p_name, minetest.colorize("#e6482e", S("[!] You can't kick yourself!")))
    return end

  -- riproduzione suono
  for _, pl_name in pairs(current_parties[p_name]) do
    parties.play_sound("parties_leave", pl_name)
  end

  -- eventuali richiami
  for _, callback in ipairs(parties.registered_on_party_leave) do
    callback(p_name, t_name, 2)
  end

  -- rimuovo dal gruppo
  for k, pl_name in pairs(current_parties[p_name]) do
    if pl_name == t_name then
      table.remove(current_parties[p_name], k)
      break
    end
  end

  players_in_parties[t_name] = nil
  parties.chat_send_party(p_name, S("@1 has been kicked from the party", t_name), true)
  minetest.chat_send_player(t_name,  add_party_prefix(S("@1 has kicked you from the party", p_name)))

  if #current_parties[p_name] == 1 then
    parties.disband(p_name)
  end
end



function parties.disband(p_name)
  -- se non si è in un gruppo
  if not players_in_parties[p_name] then
    minetest.chat_send_player(p_name, minetest.colorize("#e6482e", S("[!] You must enter a party first!")))
    return end

  -- se si è in un gruppo ma non si è il capo gruppo
  if players_in_parties[p_name] and not current_parties[p_name] then
    minetest.chat_send_player(p_name, minetest.colorize("#e6482e", S("[!] Only the party leader can perform this action!")))
    return end

  -- riproduzione suono
  for _, pl_name in pairs(current_parties[p_name]) do
    parties.play_sound("parties_leave", pl_name)
  end

  parties.chat_send_party(p_name, S("The party has been disbanded"), true)

  -- eventuali richiami
  for _, callback in ipairs(parties.registered_on_party_leave) do
    for _, pl_name in pairs(current_parties[p_name]) do
      callback(p_name, pl_name, 3)
    end
  end

  for _, pl_name in pairs(current_parties[p_name]) do
    players_in_parties[pl_name] = nil
  end

  current_parties[p_name] = nil
end





----------------------------------------------
--------------------UTILS---------------------
----------------------------------------------

function parties.is_player_invited(p_name)
  return next(players_invited[p_name])
end



function parties.is_player_in_party(p_name, party_leader)
  if not party_leader then
    return players_in_parties[p_name] ~= nil
  else
   return players_in_parties[p_name] == party_leader
  end
end



function parties.is_player_party_leader(p_name)
  return current_parties[p_name] ~= nil
end



function parties.chat_send_party(p_name, msg, as_broadcast)
  if not players_in_parties[p_name] then
    minetest.chat_send_player(p_name, minetest.colorize("#e6482e", S("[!] You must enter a party first!")))
    return end

  local party_leader = players_in_parties[p_name]

  if as_broadcast then
    for _, pl_name in pairs(current_parties[party_leader]) do
      minetest.chat_send_player(pl_name, add_party_prefix(msg))
    end
  else
    for _, pl_name in pairs(current_parties[party_leader]) do
      minetest.chat_send_player(pl_name,  add_party_prefix(format_party_message(p_name, msg)))
    end
  end
end



function parties.change_party_leader(old_leader, new_leader)
  current_parties[new_leader] = {}

  for k, v in pairs(current_parties[old_leader]) do
    current_parties[new_leader][k] = v
    players_in_parties[v] = new_leader
  end

  current_parties[old_leader] = nil

  if #current_parties[new_leader] > 1 then
    parties.chat_send_party(new_leader, S("@1 is the new party leader", new_leader), true)
  end
end



function parties.cancel_invite(p_name, inviter)
  players_invited[p_name][inviter]:cancel()
  players_invited[p_name][inviter] = nil
end



function parties.cancel_invites(p_name)
  for inviter, _ in pairs(players_invited[p_name]) do
    parties.cancel_invite(p_name, inviter)
  end
end




----------------------------------------------
-----------------GETTERS----------------------
----------------------------------------------

function parties.get_inviters(p_name)
  return players_invited[p_name]
end



function parties.get_party_leader(p_name)
  return players_in_parties[p_name]
end



function parties.get_party_members(p_name, online_only)
  if not parties.is_player_in_party(p_name) then return end

  local pt_leader = parties.is_player_party_leader(p_name) and p_name or parties.get_party_leader(p_name)

  if not online_only then
    return current_parties[pt_leader]

  else
    local online_members = {}

    for _, pl_name in ipairs(current_parties[pt_leader]) do
      if minetest.get_player_by_name(pl_name) then
        table.insert(online_members, pl_name)
      end
    end

    return online_members
  end
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function add_party_prefix(msg)
  return minetest.colorize("#ddffdd", "[" .. S("Party") .. "] " .. msg)
end



function wait_for_join(inviter, p_name)
  return minetest.after(60, function()
    local is_party_full = parties.is_player_in_party(inviter) and #parties.get_party_members(inviter) == parties.settings.MAX_PLAYERS_PER_PARTY

    -- non mostrare il messaggio se la squadra è piena
    if minetest.get_player_by_name(inviter) and not is_party_full then
      minetest.chat_send_player(inviter, add_party_prefix(minetest.colorize("#ededed", S("No answer from @1...", p_name))))
    end

    players_invited[p_name][inviter] = nil
  end)
end



function format_party_message(p_name, msg)
  local msg_format = minetest.settings:get("chat_message_format")
  return minetest.colorize("#ddffdd", msg_format:gsub("@name", p_name):gsub("@message", msg))
end
