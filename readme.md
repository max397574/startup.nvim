<div align="center">
<img src="https://user-images.githubusercontent.com/81827001/140657509-1199b444-687f-4f6b-b10a-2eeca35040aa.png" width=315>

# 🔧startup.nvim

The fully customizable greeter for neovim

</div>

✨Features
--------

* Fully customizable
* Themes
* Easier customization with building blocks

📦Installation
------------

Use your favourite package manager and call setup function.
Plenary.nvim is a dependency and must be installed.
For the default setup telescope.nvim is needed.
```lua
-- lua and packer.nvim

use {
  "startup-nvim/startup.nvim",
  requires = {"nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim"},
  config = function()
    require"startup".setup()
  end
}
```

⚙️Customization
-------------

Call the setup function with your configurations.

```lua
-- lua and packer.nvim

use {
  "startup-nvim/startup.nvim",
  requires = {"nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim"},
  config = function()
    require"startup".setup({
      section_1 = <section> -- for the structure of a section see below
      section_2 = <section> -- as much sections as you like
      options = {
          mapping_keys = true, -- display mapping (e.g. <leader>ff)

          -- if < 0 fraction of screen width
          -- if > 0 numbers of column
          cursor_column = 0.5

          after = function() -- function that gets executed at the end
            <lua commands>
          end
          empty_lines_between_mappings = true, -- add an empty line between mapping/commands
          disable_statuslines = true -- disable status-, buffer- and tablines
          paddings = {1,2}, -- amount of empty lines before each section (must be equal to amount of sections)
      }
      mappings = {
        execute_command = "<CR>",
        open_file = "o",
        open_file_split = "<c-o>",
        open_section = "<TAB>",
        open_help = "?",
      },
      colors = {
        background = "#1f2227",
        folded_section = "#56b6c2", -- the color of folded sections
          -- this can also be changed with the `StartupFoldedSection` highlight group
      }
      parts = {"section_1", "section_2"} -- all sections in order
    })
  end
}
```

You could also put the configurations into a file.
For example `/lua/config/startup_nvim.lua`.
The file should then look like this:
```lua
local settings = {<settings>}
return settings
```
The plugin setup should then require the file:
```lua
use {
  "startup-nvim/startup.nvim",
  requires = {"nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim"},
  config = function()
    require"startup".setup(require"configs.startup_nvim")
  end
}
```


The filetype of the startup screen is `startup`.
You can use this to disable plugins like statuslines.

### The Structure of a section

```lua
section = {
    -- "text" -> text that will be displayed
    -- "mapping" -> create mappings for commands that can be used
    -- use mappings.execute_command on the commands to execute
    -- "oldfiles" -> display oldfiles (can be opened with mappings.open_file/open_file_split)
    type = "text", -- can be mappings or oldfiles
    oldfiles_directory = false, -- if the oldfiles of the current directory should be displayed
    align = "center", -- "center", "left" or "right"
    fold_section = false, -- whether to fold or not
    title = "title", title for the folded section
    -- if < 0 fraction of screen width
    -- if > 0 numbers of column
    margin = 5, the margin for left or right alignment
    -- type of content depends on `type`
    -- "text" -> a table with string or a function that requires a function that returns a table of strings
    -- "mapping" -> a table in the format:
    -- {[<displayed_command_name>] = {<command>, <mapping>}}
    -- e.g. [" Find File"] = { "Telescope find_files", "<leader>ff" }
    -- "oldfiles" -> ""
    content = <content>
    highlight = "String", -- highlight group in which the section text should be highlighted
    default_color = "#FF0000", -- a hex color that gets used if you don't specify `highlight`
    oldfiles_amount = 5, -- the amount of oldfiles to be displayed
}
```

### Buildingblocks

You can use some functions from `lua/startup/functions.lua`.
For that you would use:
```lua
type = "text",
content = function()
    require("startup.functions").function_name()
  end,
```

The functions are documented in `:help startup_nvim.functions`.

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

settings = {
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

Check out the [themes](https://github.com/startup-nvim/startup.nvim/tree/master/lua/startup/themes) for full examples.


🎨The themes
----------

At the moment there are three themes:
- dashboard (default)
- evil
- startify

You can use themes like this:

```lua
require("startup").setup({theme = "dashboard"}) -- put theme name here
```

#### Dashbaord

The dashboard theme is a simple theme with some commands and a header.

#### Startify

The startify theme is a theme like `vim-startify`.
It has oldfiles, bookmarks and a random quote.
You can open the oldfiles with the number written before it (`[2] ~/.config/nvim/init.lua` can be opened by pressing `2`).
You can open a bookmark with the key written in front of it.

Customize bookmarks with `vim.g.startup_booksmarks`:
```lua
vim.g.startup_bookmarks = {
  ["Q"] = '~/.config/qtile/config.py',
  ["I"] = '~/.config/nvim/init.lua',
  ["F"] = '~/.config/fish/config.fish',
  ["K"] = '~/.config/kitty/kitty.conf',
  ["A"] = '~/.config/alacritty/alacritty.yml',
}
```

#### Evil

The evil theme is just a bloated theme with oldfiles, commands, additional info and a quote.

#### Custom theme

You can put your theme in `lua/startup/themes/my_theme.lua`
The file has to return settings with the structure like you put them into `setup()`.
You can also overwrite a theme (e.g. `dashboard`).
Just copy all the setting from it and change whatever you want.
You can use some functions from `lua/startup/functions.lua` with `require("startup.functions").function_name()`.
They are documented in `:help startup_nvim.functions`.

Credits
-------

- Thanks to Binx, for making that logo for free!
  - [Github](https://github.com/Binx-Codes/)
  - [Reddit](https://www.reddit.com/u/binxatmachine)


Similar plugins:
* [dashboard-nvim](https://github.com/glepnir/dashboard-nvim)
* [alpha-nvim](https://github.com/goolord/alpha-nvim)
* [vim-startify](https://github.com/mhinz/vim-startify)
