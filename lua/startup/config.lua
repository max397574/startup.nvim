local settings = {
  -- every line should be same width without escaped \
  header = {
    "                                          /$$              ",
    "                                         |__/              ",
    " /$$$$$$$   /$$$$$$   /$$$$$$  /$$    /$$ /$$ /$$$$$$/$$$$ ",
    "| $$__  $$ /$$__  $$ /$$__  $$|  $$  /$$/| $$| $$_  $$_  $$",
    "| $$  \\ $$| $$$$$$$$| $$  \\ $$ \\  $$/$$/ | $$| $$ \\ $$ \\ $$",
    "| $$  | $$| $$_____/| $$  | $$  \\  $$$/  | $$| $$ | $$ | $$",
    "| $$  | $$|  $$$$$$$|  $$$$$$/   \\  $/   | $$| $$ | $$ | $$",
    "|__/  |__/ \\_______/ \\______/     \\_/    |__/|__/ |__/ |__/",
  },
  -- header = utils.get_oldfiles(10),
  -- header = require("startup.utils").default_header(),
  -- name which will be displayed and command
  tools = {
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
  options = {
    align = "center", -- center, left or right
    mapping_names = true,
    -- can be an integer (columns)
    -- float < 1 -> percentage of screen width
    padding = 5, -- only used if align left or right
  },
  colors = {
    background = "#1f2227",
    heading_fg = "#009900",
    tools_fg = "#009900",
  },
}

return settings
