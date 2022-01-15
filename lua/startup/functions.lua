---@tag startup_nvim.functions
---@brief [[
--- This are functions which you can use to build your own startup.nvim theme.
---@brief ]]
local functions = {}

local quotes = require("startup.quotes")

---Returns a random programming quote
---@return table: Lines of text for the quote
function functions.quote()
    math.randomseed(os.clock())
    local index = math.random() * #quotes
    return quotes[math.floor(index) + 1]
end

---Returns a string with the number of loaded Packer Plugins
---@return string: String with info about the number of loaded plugins
function functions.packer_plugins()
    if packer_plugins then
        return {
            string.format(
                "Total plugins (packer.nvim): %d",
                vim.tbl_count(packer_plugins)
            ),
        }
    else
        return ""
    end
end

---Returns the current date and time
---@return table: Table with a string for the date and one for the time
function functions.date_time()
    local clock = " " .. os.date("%H:%M")
    local date = " " .. os.date("%d-%m-%y")
    return { clock, date }
end

return functions
