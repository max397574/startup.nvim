local settings = require "startup.themes.default"
settings = {
  header = {
    type = "text",
    align = "left",
    margin = 5,
    content = require("startup.buildingblocks.headers").default_header(),
  },
  body = {
    type = "oldfiles",
    oldfiles_directory = false,
    align = "center",
    fold_section = false,
    title = "Oldfiles",
    margin = 5,
    content = { "startup.nvim" },
    highlight = "TSString",
    default_color = "#FFFFFF",
    command = "",
    oldfiles_amount = 10,
  },
  body_2 = {
    type = "oldfiles",
    oldfiles_directory = true,
    align = "center",
    fold_section = false,
    title = "Oldfiles of Directory",
    margin = 5,
    content = {},
    highlight = "TSString",
    default_color = "#FFFFFF",
    command = "",
    oldfiles_amount = 10,
  },

  footer = {
    type = "text",
    content = require("startup.buildingblocks.functions").quote(),
  },
  options = {
    oldfiles_amount = 3,
    paddings = { 1, 2, 2, 3 },
  },
  colors = {
    background = "#1f2227",
  },
  parts = { "header", "body", "body_2", "footer" },
}

return settings
