-- theme template (kinda)
local settings = {
  header = {
    type = "text",
    content = {
      "                                          /$$              ",
      "                                         |__/              ",
      " /$$$$$$$   /$$$$$$   /$$$$$$  /$$    /$$ /$$ /$$$$$$/$$$$ ",
      "| $$__  $$ /$$__  $$ /$$__  $$|  $$  /$$/| $$| $$_  $$_  $$",
      "| $$  \\ $$| $$$$$$$$| $$  \\ $$ \\  $$/$$/ | $$| $$ \\ $$ \\ $$",
      "| $$  | $$| $$_____/| $$  | $$  \\  $$$/  | $$| $$ | $$ | $$",
      "| $$  | $$|  $$$$$$$|  $$$$$$/   \\  $/   | $$| $$ | $$ | $$",
      "|__/  |__/ \\_______/ \\______/     \\_/    |__/|__/ |__/ |__/",
    },
  },
  body = {
    content = {
      [" Find File"] = { "Telescope find_files", "<leader>ff" },
      [" Find Word"] = { "Telescope live_grep", "<leader>lg" },
      [" Recent Files"] = { "Telescope oldfiles", "<leader>of" },
      [" File Browser"] = { "Telescope file_browser", "<leader>fb" },
      [" Config Files"] = {
        'lua require("telescope.builtin").find_files({cwd="~/.config"})',
        "<leader>cf",
      },
      [" Colorschemes"] = { "Telescope colorscheme", "<leader>cs" },
      [" New File"] = { "lua require'startup'.new_file()", "<leader>nf" },
      ["ﲉ Help Files"] = { "Telescope help_tags", "<leader>fh" },
    },
  },
  footer = {},
}
return settings

--[[
type can be text or mapping

text -> table with strings in it, can also be from a function
in function additional stuff can be done/defined
mapping -> ["title that will be displayed"] = { "command", "keys"}
e.g.     [" Find File"] = { "Telescope find_files", "<leader>ff" },
symbols can be found at
https://www.nerdfonts.com/cheat-sheet
]]
--
