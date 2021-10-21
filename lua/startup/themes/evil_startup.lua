local header_content = {}
for _, line in ipairs(require("startup.buildingblocks.headers").hydra()) do
  table.insert(header_content, line)
end

for _, line in ipairs(require("startup.buildingblocks.functions").quote()) do
  table.insert(header_content, line)
end
local settings = {
  -- every line should be same width without escaped \
  header = {
    type = "text",
    align = "center",
    margin = 5,
    content = header_content,
    highlight = "markdownH1",
    default_color = "#FFFFFF",
    command = "",
  },
  -- name which will be displayed and command
  body = {
    type = "mapping",
    align = "center",
    fold_section = true,
    title = "Basic Commands",
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
  body_2 = {
    type = "oldfiles",
    oldfiles_directory = true,
    align = "center",
    fold_section = true,
    title = "Oldfiles of Directory",
    margin = 5,
    content = {},
    highlight = "TSString",
    default_color = "#FFFFFF",
    command = "",
    oldfiles_amount = 5,
  },
  footer = {
    type = "oldfiles",
    oldfiles_directory = false,
    align = "center",
    fold_section = true,
    title = "Oldfiles",
    margin = 5,
    content = { "startup.nvim" },
    highlight = "TSString",
    default_color = "#FFFFFF",
    command = "",
    oldfiles_amount = 10,
  },

  footer_2 = {
    type = "text",
    content = require("startup.buildingblocks.functions").packer_plugins(),
    oldfiles_directory = false,
    align = "center",
    fold_section = false,
    title = "",
    margin = 5,
    highlight = "TSString",
    default_color = "#FFFFFF",
    command = "",
    oldfiles_amount = 10,
  },

  options = {
    mapping_keys = true,
    empty_lines_between_mappings = true,
    paddings = { 1, 1, 1, 1, 1 },
  },
  colors = {
    background = "#1f2227",
  },
  parts = { "header", "body", "body_2", "footer", "footer_2" },
}
return settings
