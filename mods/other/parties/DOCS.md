# Parties docs

Because it's always good to understand the API without surfing the code, innit? :D

## 1 API

### 1.1 Utils

* `parties.is_player_invited(p_name)`: (bool) checks whether a player has a pending invite
* `parties.is_player_in_party(p_name, <party_leader>)`: (bool) checks whether a player is in any party. If `party_leader` is specified, it checks whether if the player is in that party leader's party
* `parties.is_player_party_leader(p_name)`: (bool) checks whether a player is the party leader of any party
* `parties.chat_send_party(p_name, msg, as_broadcast)`: (nil) sends a message to every player inside the party where `p_name` is (`p_name` doesn't necessarily have to be the party leader). If `as_broadcast` is true, it'll be sent without following Minetest chat format. If false, `p_name` will be pointed as the sender when formatting the message
* `parties.change_party_leader(old_leader, new_leader)`: (nil) changes the party leader
* `parties.cancel_invite(p_name, inviter)`: (nil) cancels a pending invite from `inviter`
* `parties.cancel_invites(p_name)`: (nil) cancels all the pending invites of `p_name`

### 1.2 Getters

* `parties.get_inviters(p_name)`: (table) returns a table containing as key the name(s) of the player(s) who invited `p_name`
* `parties.get_party_leader(p_name)`: (string) returns the party leader of the party where `p_name` is in, or `nil` if it's not in a party
* `parties.get_party_members(p_name, <online_only>)`: (table) returns a table containing as value the name(s) of the player(s) inside the party where `p_name` is in, or `nil` if it's not in a party. `online_only` is an optional boolean that, when `true`, only returns the members who are currently online


## 2 Customisation

### 2.1 Callbacks

* `parties.register_on_pre_party_invite(function(sender, p_name))`: use it to run additional checks. Returning `true` keeps executing the invite, returning `false`/`nil` cancels it
* `parties.register_on_party_invite(function(sender, p_name))`: called when an invite has been successfully sent
* `parties.register_on_pre_party_join(function(pt_leader, p_name))`: use it to run additional checks. Returning `true` keeps executing the join function, returning `false`/`nil` cancels it
* `parties.register_on_party_join(function(party_leader, p_name))`: called when a player successfully joins a party. It also runs on the party leader when they create the party
* `parties.register_on_party_leave(function(party_leader, p_name, reason))`: called when a player leaves a party, before they get removed. `reason` is an int:
  * `1`: left
  * `2`: kick
  * `3`: party disbanded

### 2.2 Chat

Chat is light blue by default and it adds the `[Party] ` prefix at the beginning of every message. It then follows the format of the chat set by the owner. By default is:
`[Party] <playername> message`

## 3. About the author(s)
I'm Zughy (Marco), a professional Italian pixel artist who fights for FOSS and digital ethics. If this library spared you a lot of time and you want to support me somehow, please consider donating on [Liberapay](https://liberapay.com/Zughy/). Also, this project wouldn't have been possible if it hadn't been for some friends who helped me testing through: `Giov4`, `_Zaizen_`, `MrFreeman` and `Xx_Crazyminer_xX`


