<div align="center">
<img src="https://user-images.githubusercontent.com/81827001/140657509-1199b444-687f-4f6b-b10a-2eeca35040aa.png" width=315>
  
# 🔧startup.nvim

The fully customizable greeter for neovim
  
</div>

✨Features
--------

* Fully customizable
* Themes
* Easy Customization with building blocks

📦Installation
------------
Use your favourite package manager and call setup function.
Plenary.nvim is a dependency and must be installed.
For the default setup telescope.nvim is needed.
```lua
-- lua and packer.nvim

use {
  "max397574/startup.nvim",
  requires = {"nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim"},
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
  requires = {"nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim"},
  config = function()
    require"starup".setup(require"configs.startup") -- recommended to use a file for this
  end
}
```

Here the file would be located at `/lua/configs/startup.lua`.
The file has to return settings.

For one of the default themes this can be done like this: (example with the startify theme)

```lua
local settings = require"startup.themes.startify"

return settings
```
<!-- NOTE: update this -->
These themes are currently available:

* Default
* Startify
* Evil_startup

The filetype of the startup screen is `startup`.
You can use this to disable plugins like statuslines.

### 🏗️The basic structure of the settings

```lua
-- General structure of the settings
settings = {
    section_1 = <section> -- as much sections as you like
    section_2 = <section>
    options = {
        mapping_keys = true/false, -- display mapping (e.g. <leader>ff)
        -- if < 0 fraction of screen width
        -- if > 0 numbers of column
        cursor_column = <number>
        empty_lines_between_mappings = true/false, -- add an empty line between mapping/commands
        disable_statuslines = true/false -- disable status and bufferlines
        paddings = <paddings>,
    }
    mappings = {
        -- keys in normal vim mapping format e.g. <c-o>
        -- string
        execute_command = <key>,
        open_file = <key>,
        open_file_split = <key>,
        open_section = <key>,
        open_help = <key>,
    },
    colors = {
        background = <color>, -- hex color code
        folded_section = <color>, -- the colors of the folded section titles
        -- this can also be changed with the `StartupFoldedSection` highlight group
    }
    parts = {"section_1", "section_2"} -- all sections in order
}

-- Structure of a section
section = {
    type = <type>,
    oldfiles_directory = true/false,
    align = <alignment>,
    fold_section = true/false, --whether to fold or not
    title = <title>,
    margin = <margin>,
    content = <content>,
    highlight = <highlight>,
    default_color = <color>,
    command = <command>,
    oldfiles_amount = <amount>,
}

-- the padding before each section
-- table with integers
paddings = {
    <padding_before_section_1>, -- for as as many sections as you have
    <padding_before_section_2>,
}

-- a hex color
-- e.g. "#FF000D"
-- string
color = <color>

-- text: just text will be displayed

-- mapping: commands/mapping which will be displayed
-- those can be executed with <CR>
-- the mappings can be used

-- oldfiles: oldfiles will be displayed
-- those can be opened with 'o'
-- you can specify the amount of oldfiles and whether to display only one from the current directory
-- string
type = "text"/"mapping"/"oldfiles"

-- display only oldfiles of current directory
-- only relevant if type = "oldfiles"
-- boolean
oldfiles_directory = true/false

-- how to align the section
-- string
align = "left"/"center"/"right"

-- whether the section should be "folded" with the title <title>
-- title must be set
-- string
fold_section = true/false

-- title of folded section
-- string
title = <title>

-- only relevant if alignment is left or right
-- if < 0 fraction of screen width
-- if > 0 numbers of column
-- integer or float
margin = <margin>

-- when type = "olfiles" -> leave empty
-- when type = "mapping" -> table with the format
{
    [<displayed_command_name>] = {<command>, <mapping>}
}

-- when type = "text" -> table with strings of text
-- those can be returned by a function
content = <content>

-- the highlight group to highlight the section with
-- leave empty to use a color
-- string
highlight = highlight_group

-- color used if no highlight group is specified (highlight = "")
-- hex color
-- string
default_color = <color>,

-- vim command to be executed, when section get set
-- for example to create mappings
-- string
command = <command>,

-- the amount of oldfiles to be displayed
-- integer
oldfiles_amount = <amount>,
```

### Buildingblocks
<!-- TODO: -->

### Examples
<details>
<summary>
Content for type = "text", table
</summary>
<p>

```lua
content = {
    "This is:",
    "Startup.nvim",
    "by max397574"
}
```

</p>
</details>
<details>
<summary>
Content for type = "text", function
</summary>
<p>

```lua
content = function()
    local clock = " " .. os.date "%H:%M"
    local date = " " .. os.date "%d-%m-%y"
    return {clock,date}
end
```

With a separate function:

```lua
local function time()
    local clock = " " .. os.date "%H:%M"
    local date = " " .. os.date "%d-%m-%y"
    return {clock,date}
end

setting = {
    ...
    content = time()
    ...
}
```

</p>
</details>

<details>
<summary>
Content for type = "mapping"
</summary>
<p>

```lua
content = {
  [" Find File"] = { "Telescope find_files", "<leader>ff" },
  [" Find Word"] = { "Telescope live_grep", "<leader>lg" },
  [" Recent Files"] = { "Telescope oldfiles", "<leader>of" },
  [" File Browser"] = { "Telescope file_browser", "<leader>fb" },
  [" Colorschemes"] = { "Telescope colorscheme", "<leader>cs" },
  [" New File"] = { "lua require'startup'.new_file()", "<leader>nf" },
},
```

</p>
</details>

Check out the [themes](https://github.com/max397574/startup.nvim/tree/dev/lua/startup/themes) for full examples.

👀Screenshots
---------------

### The themes

#### Default

#### Startify

#### Evil Startup

Credits
-------
Similar plugins:
* [dashboard-nvim](https://github.com/glepnir/dashboard-nvim)
* [alpha-nvim](https://github.com/goolord/alpha-nvim)
* [vim-startify](https://github.com/mhinz/vim-startify)
