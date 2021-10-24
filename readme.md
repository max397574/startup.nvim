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

For one of the default themes this can be done like this: (startify theme)

```lua
local settings = require"startup.themes.startify"

return settings
```
<!-- NOTE: update this -->
These themes are currently available:

* Default
* Startify
* Evil_startup

### 🏗️The basic structure of the settings

```lua
-- General structure of the settings
settings = {
    section_1 = <section> -- as much sections as you like
    section_2 = <section>
    options = {
        mapping_keys = true/false, -- display mapping (e.g. <leader>ff)
        empty_lines_between_mappings = true/false, -- add an empty line between mapping/commands
        paddings = <paddings>,
    }
    mappings = {
        -- keys in normal vim mapping format e.g. <c-o>
        -- string
        execute_command = <key>,
        open_file = <key>,
        open_file_split = <key>,
        open_section = <key>,
    },
    colors = {
        background = <color>, -- hex color code
    }
    parts = {"section_1", "section_2"} -- all sections in order
}

-- Structure of a section
section = {
    type = <type>,
    oldfiles_directory = true/false,
    align = <alignment>,
    fold = true/false, --whether wo fold or not
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

<details>
<summary>
A complete configuration
</summary>
<p>

```lua
local settings = {
    header = {
        type = "text",
        oldfiles_directory = false,
        align = "center",
        fold = false,
        title = "",
        margin = 5,
        content = require"startup.buildingblocks.headers".hydra(),
        highlight = "TSString",
        default_color = "",
        -- use `I` to edit init.lua and `C` to search config files
        command = [[
            nnoremap I :e ~/.config/nvim/init.lua<CR>
            nnoremap C :lua require'telescope.builtin'.find_files({cwd="~/.config"})<CR>
        ]],
        oldfiles_amount = 0,
    }

    body_1 = {
        type = "oldfiles"
        oldfiles_directory = false,
        align = "center",
        fold = true,
        title = "Last Opened Files"
        margin = 5,
        content = "",
        highlight = "",
        default_color = "#db4b4b",
        command = "",
        oldfiles_amount = 8,
    }

    body_2 = {
        type = "mappings",
        oldfiles_directory = false,
        align = "center",
        fold = false,
        title = "",
        margin = 5,
        content = {
          [" Find File"] = { "Telescope find_files", "<leader>ff" },
          [" Find Word"] = { "Telescope live_grep", "<leader>lg" },
          [" Recent Files"] = { "Telescope oldfiles", "<leader>of" },
          [" File Browser"] = { "Telescope file_browser", "<leader>fb" },
          [" Colorschemes"] = { "Telescope colorscheme", "<leader>cs" },
          [" New File"] = { "lua require'startup'.new_file()", "<leader>nf" },
        },
        highlight = "Number",
        default_color = "#699999",
        command = "",
        oldfiles_amount = 0,
    }

    footer = {
        type = "text",
        oldfiles_directory = false,
        align = "center",
        fold = false,
        title = "",
        margin = 5,
        content = require"startup.buildingblocks.functions".quote(),
        highlight = "Constant",
        default_color = "",
        command = "",
        oldfiles_amount = 0,
    }

    options = {
        mapping_keys = true,
        empty_lines_between_mappings = false,
        paddings = { 1, 2, 2, 1 }
    }

    colors = {
        background = "#1e222a"
    }
    parts = { "header", "body_1", "body_2", "footer" }
}

return settings
```

</p>
</details>

Credits
-------
Similar plugins:
* [dashboard-nvim](https://github.com/glepnir/dashboard-nvim)
* [alpha-nvim](https://github.com/goolord/alpha-nvim)
* [vim-startify](https://github.com/mhinz/vim-startify)
