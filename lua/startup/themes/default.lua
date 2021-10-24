local settings = {
  -- every line should be same width without escaped \
  header = {
    type = "text",
    align = "center",
    margin = 5,
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
    highlight = "markdownH1",
    default_color = "#FFFFFF",
    command = "",
  },
  -- name which will be displayed and command
  body = {
    type = "mapping",
    align = "center",
    margin = 5,
    content = {
      [" Find File"] = { "Telescope find_files", "<leader>ff" },
      [" Find Word"] = { "Telescope live_grep", "<leader>lg" },
      [" Recent Files"] = { "Telescope oldfiles", "<leader>of" },
      [" File Browser"] = { "Telescope file_browser", "<leader>fb" },
      [" Colorschemes"] = { "Telescope colorscheme", "<leader>cs" },
      [" New File"] = { "lua require'startup'.new_file()", "<leader>nf" },
    },
    highlight = "TSString",
    default_color = "#FFFFFF",
    command = "",
  },
  footer = {
    type = "text",
    align = "center",
    margin = 5,
    content = { "startup.nvim" },
    highlight = "TSString",
    default_color = "#FFFFFF",
    command = "",
  },

  options = {
    mapping_keys = true,
    empty_lines_between_mappings = true,
    paddings = { 1, 3, 3, 0 },
  },
  mappings = {
    execute_command = "<CR>",
    open_file = "o",
    open_file_split = "<c-o>",
    open_section = "<TAB>",
  },
  colors = {
    background = "#1f2227",
  },
  parts = { "header", "body", "footer" },
}
return settings
