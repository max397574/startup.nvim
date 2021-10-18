# 🔧Startup.nvim

## WIP Don't Use

✨Features
--------

* Fully customizable
* Themes
* Easy Customization with building blocks

📦Installation
------------
Use your favourite package manager and call setup function.
For the default setup telescope.nvim is a dependency.
```lua
-- lua and packer.nvim

use {
  "max397574/startup.nvim",
  requires = {"nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim"}
  config = function()
    require"startup".setup()
  end
}
```

⚙️Customization
-------------
<!-- NOTE: -->
<!-- ???See wiki -->

Call the setup function with your configurations

It is recommended to use a file in the setup function. This can be done like this:

```lua
-- lua and packer.nvim

use {
  "max397574/startup.nvim",
  requires = {"nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim"}
  config = function()
    require"starup".setup(require"configs.startup") -- recommended to use a file for this
  end
}
```

Here the file would be located at `/lua/configs/startup.lua`.
The file has to return settings.

For one of the default themes this can be done like this: (startify theme)

```lua
local settings = require"startup.themes.startify"

return settings
```
<!-- NOTE: update this -->
These themes are currently available:

* Default
* Startify
<!-- TODO: evil-startup theme -->
<!-- * Evil-startup -->
