# Contributing to JMA Mineclone
Thank you for contributing!
We strive to create a fun server to play on, so we have some custom mods and modifications to VoxeLibre's code.
Below we have listed our changes. Please take care to not overwrite these if you are updating to a newer version or such.
Also, if you make any changes to VoxeLibre's code, please do include those here for future reference.

## Changes from VoxeLibre

- **mods/other/** and **mods/extras/**
    This is where we keep our custom mods. These will not be documented here as they are not directly in VoxeLibre's code.

- **mods/ITEMS/mcl_enchanting/enchantments.lua**
    We have a custom enchantment, "Drill", which is registered in this file.

- ~~**mods/ITEMS/mcl_mobitems/init.lua**~~
    ~~Dino Nuggets, a custom food craftable from Cooked Chicken, is registered here.~~
    Moved to a standalone mod (mods/other/dino_nuggets)

- **mods/HUD/mcl_credits/people.lua**
    The JMA developers and staff have been added to the end of this file to be seen at the end of the credits.

- **mods/ITEMS/REDSTONE/mcl_dispensers/init.lua**
    We've added some custom code here that allows dispensers to plant crops when pointing at soil.

- **mods/ITEMS/mcl_anvils/init.lua**
    Added support for color blocks in item names. The color blocks are parsed and applied to the item metadata.
