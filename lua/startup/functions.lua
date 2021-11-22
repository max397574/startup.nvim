local functions = {}

local quotes = require("startup.quotes")

function functions.quote()
  math.randomseed(os.clock())
  local index = math.random() * #quotes
  return quotes[math.floor(index) + 1]
end

function functions.packer_plugins()
  return {
    string.format(
      "Total plugins (packer.nvim): %d",
      vim.tbl_count(packer_plugins)
    ),
  }
end

return functions
