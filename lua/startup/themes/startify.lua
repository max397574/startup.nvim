local settings = {
  header = {
    type = "text",
    align = "left",
    margin = 5,
    content = require("startup.buildingblocks.headers").default_header(),
  },
  body = {
    type = "oldfiles",
    align = "left",
  },
  footer = {
    type = "text",
    content = require("startup.buildingblocks.functions").quote(),
  },
  options = {
    oldfiles_amount = 3,
    padding = {
      body_footer = 2,
    },
  },
}

return settings
