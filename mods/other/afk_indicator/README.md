# API to check player AFK status
Want to know that is a player away-from-keyboard? This mod is for you!

## API Methods
### `afk_indicator.update(name)`
Allow mods to report that the player is active at the time.

* `name`: The name of the player

### `afk_indicator.delete(name)`
INTERNAL: Remove the record of a player. Should only call once when the player leaves.

* `name`: The name of the player

### `afk_indicator.get(name)`
Get the record of a specific player, return the AFK duration, or `false` if the player is not online.

* `name`: The name of the player

### `afk_indicator.get_all()`
Get list of AFK records. It returns a table, with player name as key and AFK duration as value.

### `afk_indicator.get_all_longer_than(p)`
Similar to `afk_indicator.get_all()`, but only return records with AFK duration longer than `p`.

* `p`: The minimum AFK duration for the returned records.

## Variables
### `afk_indicator.last_updates`
A key-value pair of player names and AFK start time.

It's recommended to use `afk_indicator.get_all()` or `afk_indicator.get(name)`, as it calculate the AFK time for you.

## Chatcommands
### `/afk_stat`
A command mostly for debugging purpose, showing the AFK time of the online players.

`basic_privs` is required to use this command.

Executing the chatcommand is also an action. Therefore, it's pointless to include the command executor's own AFK time as it's always `0`.
