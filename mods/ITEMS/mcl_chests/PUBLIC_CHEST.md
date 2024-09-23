Public chests are regular chests, but allow all players to take/move/put items.
This is done by modifying the default callback that checks if the chest is protected (and stops the action if so). A custom callback is given when registering the public chest, in which it always allows interactions.
Breaking the chest is still blocked.

By default, nothing is logged.
You can enable verbose mode by adding `verbose_public_chest = true` into minetest.conf, this will log every item moved, inserted or taken from chests. Due to API limitations moving does not give what item is moved, only how many items are in the stack, but the other two actions return both the item and the stack amount.

A public chest is crafted like:

\[W]\[W]\[W]
\[W]\[E]\[W]
\[W]\[W]\[W]

Where W is any wood plank and E is an emerald.