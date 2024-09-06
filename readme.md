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
For the default setup telescope.nvim and telescope-file-browser.nvim are  needed.

- Packer
```lua
use {
  "startup-nvim/startup.nvim",
  requires = {"nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim", "nvim-telescope/telescope-file-browser.nvim"},
  config = function()
    require"startup".setup()
  end
}
```

- Lazy.nvim
```lua
{
  "startup-nvim/startup.nvim",
  dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim", "nvim-telescope/telescope-file-browser.nvim" },
  config = function()
    require "startup".setup()
  end
}
```

⚙️Customization
-------------

Call the setup function with your configurations.

```lua
require"startup".setup({
  section_1 = <section> -- for the structure of a section see below
  section_2 = <section> -- as much sections as you like
  options = {
      mapping_keys = true, -- display mapping (e.g. <leader>ff)

      -- if < 1 fraction of screen width
      -- if > 1 numbers of column
      cursor_column = 0.5,

      after = function() -- function that gets executed at the end
        <lua commands>
      end,
      empty_lines_between_mappings = true, -- add an empty line between mapping/commands
      disable_statuslines = true, -- disable status-, buffer- and tablines
      paddings = {1,2}, -- amount of empty lines before each section (must be equal to amount of sections)
  },
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
  },
  parts = {"section_1", "section_2"} -- all sections in order
})
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
    type = "text", -- can be mapping or oldfiles
    oldfiles_directory = false, -- if the oldfiles of the current directory should be displayed
    align = "center", -- "center", "left" or "right"
    fold_section = false, -- whether to fold or not
    title = "title", -- title for the folded section
    -- if < 1 fraction of screen width
    -- if > 1 numbers of column
    margin = 5, -- the margin for left or right alignment
    -- type of content depends on `type`
    -- "text" -> a table with string or a function that requires a function that returns a table of strings
    -- "mapping" -> a table with tables in the format:
    -- {
    --   {<displayed_command_name>, <command>, <mapping>}
    --   {<displayed_command_name>, <command>, <mapping>}
    -- }
    -- e.g. {" Find File", "Telescope find_files", "<leader>ff" }
    -- "oldfiles" -> ""
    content = <content>
    highlight = "String", -- highlight group in which the section text should be highlighted
    default_color = "#FF0000", -- a hex color that gets used if you don't specify `highlight`
    oldfiles_amount = 5, -- the amount of oldfiles to be displayed
}
```

### User Mappings
You can easily add your own mappings with a function.
You just have to provide a table with keys, command pairs like this:
```lua
require"startup".create_mappings({
  ["<leader>ff"]="<cmd>Telescope find_files<CR>",
  ["<leader>lg"]="<cmd>Telescope live_grep<CR>"
})
```
Those mappings will automatically be added to the help.

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


🎨Themes
----------

At the moment there are three themes:
- dashboard (default)
- evil
- startify

You can use themes like this:

```lua
require("startup").setup({theme = "dashboard"}) -- put theme name here
```

### Dashboard

The dashboard theme is a simple theme with some commands and a header.
  
![dashboard theme](https://user-images.githubusercontent.com/81827001/146725450-5c3ddc5b-e4aa-47b9-88b1-446810bebcea.png)

### Startify

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
![startify](https://user-images.githubusercontent.com/81827001/146543552-1224495e-329f-49f1-bcbf-7414f929f9e0.jpg)


### Evil

The evil theme is just a bloated theme with oldfiles, commands, additional info and a quote.
  
![evil theme](https://user-images.githubusercontent.com/81827001/145632108-04c5d972-0d51-42fc-ad92-91ea716b92a7.png)

### Custom theme

You can put your theme in `lua/startup/themes/my_theme.lua`
The file has to return settings with the structure like you put them into `setup()`.
You can also overwrite a theme (e.g. `dashboard`).
Just copy all the setting from it and change whatever you want.
You can use some functions from `lua/startup/functions.lua` with `require("startup.functions").function_name()`.
They are documented in `:help startup_nvim.functions`.
The same applies to headers.
Here you can use them with `require("startup.headers").header_name`.
They are documented in `:help startup_nvim.headers`.
A good tool to create your own headers is [image to braille](https://505e06b2.github.io/Image-to-Braille/).

Conflicts with other plugins like auto-session
----------------------------------------------
If this plugin conflict with other plugins you can disable it on startup.
For this you need to set `vim.g.startup_disable_on_startup` to `true`.
You can do that like this:
```lua
config = function()
    vim.g.startup_disable_on_startup = true
    require("startup").setup(require("configs.startup_nvim"))
end
```

You can still display it later then with `:Startup display`.
  
👀 Screenshots
--------------
  
### Easily open Files (in splits)
  
![file_split](https://user-images.githubusercontent.com/81827001/146543610-cf700baa-0e72-4c13-9be8-02d8e7f12c14.jpg)

  
### Builtin Key Help (user mappings included)

  ![key help](https://user-images.githubusercontent.com/81827001/145632803-71bf8e78-43d7-4230-b46e-9fd6ae621d3a.png)
  
### Folds and commands with mappings
 
![folds mappings](https://user-images.githubusercontent.com/81827001/145632434-9cdba6e6-c381-43a6-8a60-3af201fda1da.png)

Credits
-------

- Thanks to Binx, for making that logo for free!
  - [Github](https://github.com/Binx-Codes/)
  - [Reddit](https://www.reddit.com/u/binxatmachine)


Similar plugins:
* [dashboard-nvim](https://github.com/glepnir/dashboard-nvim)
* [alpha-nvim](https://github.com/goolord/alpha-nvim)
* [vim-startify](https://github.com/mhinz/vim-startify)

## ❤️ Support
If you like the projects I do and they can help you in your life you can support my work with [github sponsors](https://github.com/sponsors/max397574).
Every support motivates me to continue working on my open source projects.
