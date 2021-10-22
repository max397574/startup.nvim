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
* Evil-startup

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

-- table with all the paddings
paddings = {
    <padding_before_section_1>, -- for as as many sections as you have
    padding_before_section_2,
}

-- e.g. #FF000D
color = hex_color_string

-- text: content is a table of strings as content which will be displayed
-- mapping: content a table with commands/mapping which will be displayed
-- and can be used with <CR>
-- oldfiles: leave content empty
-- you can specify the amount of oldfiles and whether to display only one from the current directory
type = "text"/"mapping"/"oldfiles"

-- display only oldfiles of current directory
-- only relevant if type = "oldfiles"
oldfiles_directory = true/false 

-- how to align the section
align = "left"/"center"/"right"

-- whether the section should be "folded" with a title
-- title must be set
fold = true/false

-- title of folded section
-- e.g. "Oldfiles"
title = title_string

-- only relevant if alignment is left or right
-- if < 0 fraction of screen width
-- if > 0 numbers of column
margin = margin_number

-- when type = "olfiles" -> leave empty
-- when type = "mapping" -> table with the format
{
    [<displayed_command_name>] = {<command>, <mapping>}
}
e.g.
{
      [" Find File"] = { "Telescope find_files", "<leader>ff" },
      [" Find Word"] = { "Telescope live_grep", "<leader>lg" },
}
-- when type = "text" -> table with strings of text
-- those can be returned by a function
e.g.
{ "startup.nvim", "by max397574"}, -- example for a footer
content = <content>

-- the highlight group to highlight the section with
-- leave empty to use a color
highlight = highlight_group

-- color used if no highlight group is specified (highlight = "")
-- hex color code
default_color = <color>,

-- vim command to be executed, when section get set
-- for example to create mappings
command = <command>,

-- the amount of oldfiles to be displayed
oldfiles_amount = <amount>,
```
### Examples
<details>
<summary>
Content for type = "text", table
</summary>
```lua
content = {
    "This is:",
    "Startup.nvim",
    "by max397574"
}
```
</details>
<details>
<summary>
Content for type = "text", function
</summary>
```lua
content = function()
    local clock = " " .. os.date "%H:%M"
    local date = " " .. os.date "%d-%m-%y"
    return {clock,date}
end
```
</details>
