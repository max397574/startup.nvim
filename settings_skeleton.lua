local opts = { noremap = true, silent = true }
local function example_settings()
  vim.api.nvim_buf_set_keymap(0, "n", "x", "<cmd>lua print('test')<CR>", opts)
  return { "entry_1", "entry_2" }
end

---[[
local example_section = {
  -- text: content is a table of string (directly or from function)
  -- mapping: content is mapping in format from below
  type = "text",
  -- left: text on left side with padding
  -- right: text on right side with padding
  -- center: text will be in center
  align = "left",
  -- int: amount of columns,
  -- float: fraction of screen
  -- only if right or left align
  padding = 5,
  -- table: a table with strings
  -- function: a call to a function which returns a table with strings and does some other things
  -- mapping: ["<mapping name>"] = { "<command>", "<keys>"}
  content = { "line 1", "line 2" }, --table or function or mapping
  highlight = "example", -- highlight group
  default_color = "#FFFFFF", -- hex color code
  command = "echo 'test worked'", -- a command which will be exected when section gets loaded
}
local settings = {
  header = {},
  body = {},
  footer = {},
  options = {
    mapping_keys = true, -- display keys for mappings (e.g. <leader>ff)
    empty_lines_between_mappings = true, -- empty lines between mapping names
    gap1 = 3, -- space between header and body -1
    gap2 = 4, -- space between body and footer -1
  },
  colors = {
    background = "#1f2227", -- the default background color
  },
}
-- ]]--
local settings = {
  -- every line should be same width without escaped \
  header = {
    type = "text",
    align = "center",
    padding = 5,
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
    highlight = "TSString",
    default_color = "#009900",
    command = "echo 'header works'",
  },
  -- name which will be displayed and command
  body = {
    type = "mapping",
    align = "left",
    padding = 0.3,
    content = {
      [" Find File"] = { "Telescope find_files", "<leader>ff" },
      [" Find Word"] = { "Telescope live_grep", "<leader>lg" },
      [" Recent Files"] = { "Telescope oldfiles", "<leader>of" },
      [" New File"] = { "lua require'startup'.new_file()", "<leader>nf" },
    },
    highlight = "CoolHighlight",
    default_color = "",
    command = "highlight CoolHighlight guifg=#FF0000",
  },
  footer = {
    type = "text",
    align = "right",
    padding = 15,
    content = example_settings(),
    highlight = "",
    default_color = "#990000",
    command = "",
  },

  options = {
    mapping_keys = true, -- display keys for mappings (e.g. <leader>ff)
    empty_lines_between_mappings = true, -- empty lines between mapping names
    gap1 = 3, -- space between header and body -1
    gap2 = 4, -- space between body and footer -1
  },
  colors = {
    background = "#1f2227",
  },
}
return settings
