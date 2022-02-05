---@class startup.utils
local U = {}
local flag = false
local new_cursor_pos
local help_window

local log = require("startup.log")

local oldfiles_total = 0
local all_oldfiles = {}

local set_buf_opt = vim.api.nvim_buf_set_option

local line_count = function()
    return vim.api.nvim_buf_line_count(0)
end
-- local startup = require"startup"

---sets cursor to position in current window
---@param cursor table table in form {row,column}
local function set_cursor(cursor)
    vim.api.nvim_win_set_cursor(0, cursor)
end

function U.breaking_changes()
    local buf = vim.api.nvim_create_buf(false, true)
    local ns = vim.api.nvim_create_namespace("Startup_breaking_changes")
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_keymap(
        buf,
        "n",
        "q",
        "<cmd>q<CR>",
        { noremap = true, silent = true, nowait = true }
    )
    local lines = {
        "",
        "  # Breaking Changes in startup.nvim",
        "",
        "  ## 18-12-2021:",
        "  The syntax for mappings has changed. This is because",
        "  before it wasn't possible to keep the mappings in the",
        "  order in which they were defined.",
        "",
        "  ### Old syntax:",
        "  ```lua",
        "  content = {",
        '    [" Find File"] = { "Telescope find_files", "<leader>ff" }',
        '    [" Find Word"] = { "Telescope live_grep", "<leader>lg" }',
        '    [" Recent Files"] = { "Telescope oldfiles", "<leader>of" }',
        '    [" File Browser"] = { "Telescope file_browser", "<leader>fb" }',
        '    [" Colorschemes"] = { "Telescope colorscheme", "<leader>cs" }',
        [[    [" New File"] = { "lua require'startup'.new_file()", "<leader>nf" }]],
        "  }",
        "  ```",
        "",
        "  ### New syntax:",
        "  ```lua",
        "  content = {",
        '    {" Find File",  "Telescope find_files", "<leader>ff" }',
        '    {" Find Word",  "Telescope live_grep", "<leader>lg" }',
        '    {" Recent Files", "Telescope oldfiles", "<leader>of" }',
        '    {" File Browser", "Telescope file_browser", "<leader>fb" }',
        '    {" Colorschemes", "Telescope colorscheme", "<leader>cs" }',
        [[    {" New File", "lua require'startup'.new_file()", "<leader>nf" }]],
        "  }",
        "  ```",
    }
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    local width = vim.api.nvim_win_get_width(0)
    local height = vim.api.nvim_win_get_height(0)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "win",
        win = 0,
        -- width = math.floor(width * 0.8),
        width = 85,
        height = math.floor(height * 0.9),
        col = math.floor((width - 80) * 0.4),
        row = math.floor(height * 0.1),
        border = "shadow",
        style = "minimal",
    })
    -- vim.api.nvim_buf_add_highlight(buf, ns, "Special", 1, 0, -1)
    vim.api.nvim_win_set_option(win, "winblend", 0)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
end

---load the theme specified
---@param theme_name string theme to load
---@return table settings
function U.load_theme(theme_name)
    local path = "lua/startup/themes/" .. theme_name .. ".lua"
    local files = vim.api.nvim_get_runtime_file(path, true)
    local settings
    if #files == 0 then
        path = "lua/startup/themes" .. theme_name .. "/init.lua"
        files = vim.api.nvim_get_runtime_file(path, true)
    end
    if #files == 0 then
        error("lua/startup/themes/" .. theme_name .. ".lua" .. " not found")
    elseif #files == 1 then
        settings = dofile(files[1])
    else
        local startup_pattern = "startup.nvim/lua/startup"
        local valid_file = false
        for _, file in ipairs(files) do
            if not file:find(startup_pattern) then
                settings = dofile(file)
                valid_file = true
            end
        end
        if not valid_file then
            -- multiple files but in startup repo shouldn't happen so just use first one
            settings = dofile(files[1])
        end
    end
    return settings
end

---checks if cursor should be able to move on current line
local function bad_line()
    for _, line in ipairs(require("startup").good_lines) do
        if line == vim.trim(vim.api.nvim_get_current_line()) and line ~= "" then
            return false
        end
    end
    return true
end

U.cursor_pos = vim.api.nvim_win_get_cursor(0)

---returns string with specified amount of spaces
---@param amount number the amount of space to return
---@return string
function U.spaces(amount)
    return string.rep(" ", amount)
end

---returns table with empty strings
---@param amount number amount of empty strings
function U.empty(amount)
    for _ = 1, amount, 1 do
        table.insert(
            require("startup").lines,
            { " ", "center", false, "normal" }
        )
    end
end

local function parse_mapping(mapping)
    mapping = string.gsub(mapping, "C%-", "ctrl+")
    mapping = string.gsub(mapping, "c%-", "ctrl+")
    mapping = string.gsub(mapping, "%<leader%>", "leader+")
    mapping = string.gsub(mapping, "%<(.+)%>", "%1")
    return mapping
end

---open float with all the keybindings
function U.key_help()
    local ns = vim.api.nvim_create_namespace("Float help")
    local settings = require("startup").settings
    local buf = vim.api.nvim_create_buf(false, true)
    local user_mappings = require("startup").user_mappings
    set_buf_opt(buf, "bufhidden", "wipe")
    local lines = {
        "    Startup.nvim Mappings    ",
        "",
        "    Execute command:    " .. parse_mapping(
            settings.mappings.execute_command
        ),
        "    Open file:          " .. parse_mapping(settings.mappings.open_file),
        "    Open file in split: " .. parse_mapping(
            settings.mappings.open_file_split
        ),
        "    Open section:       " .. parse_mapping(
            settings.mappings.open_section
        ),
    }
    local length
    if not vim.tbl_isempty(user_mappings) then
        local user_map_commands = {}
        table.insert(lines, "")
        table.insert(lines, "   User Mappings:")
        table.insert(lines, "")
        for _, lhs in pairs(user_mappings) do
            table.insert(user_map_commands, lhs)
        end
        length = U.longest_line(user_map_commands)
        for rhs, lhs in pairs(user_mappings) do
            table.insert(
                lines,
                "    "
                    .. lhs
                    .. ":"
                    .. U.spaces(length + 3 - #lhs)
                    .. parse_mapping(rhs)
            )
        end
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    local height = 6
    if not vim.tbl_isempty(user_mappings) then
        height = 9 + vim.tbl_count(user_mappings)
    end
    help_window = vim.api.nvim_open_win(buf, false, {
        relative = "cursor",
        width = 55,
        height = height,
        col = 0,
        row = 1,
        border = "shadow",
        style = "minimal",
    })
    if not vim.tbl_isempty(user_mappings) then
        vim.api.nvim_buf_add_highlight(buf, ns, "Special", 7, 1, -1)
        for i = 9, 9 + vim.tbl_count(user_mappings), 1 do
            vim.api.nvim_buf_add_highlight(buf, ns, "String", i, length + 5, -1)
            vim.api.nvim_buf_add_highlight(buf, ns, "Number", i, 1, length + 5)
        end
    end
    vim.api.nvim_win_set_option(help_window, "winblend", 20)
    vim.api.nvim_buf_add_highlight(buf, ns, "Special", 0, 1, -1)
    for i = 2, 5, 1 do
        vim.api.nvim_buf_add_highlight(buf, ns, "String", i, 24, -1)
        vim.api.nvim_buf_add_highlight(buf, ns, "Number", i, 1, 23)
    end
    set_buf_opt(buf, "modifiable", false)
    vim.cmd(
        [[autocmd CursorMoved * ++once lua require"startup.utils".close_help()]]
    )
end

---close the help window
function U.close_help()
    vim.api.nvim_win_close(help_window, false)
    -- vim.cmd([[autocmd! CursorMoved * lua require"startup.utils".close_help() ++once]])
end

---the default header
---@return table header strings with the default header
function U.default_header()
    local header = {
        "                                          /$$              ",
        "                                         |__/              ",
        " /$$$$$$$   /$$$$$$   /$$$$$$  /$$    /$$ /$$ /$$$$$$/$$$$ ",
        "| $$__  $$ /$$__  $$ /$$__  $$|  $$  /$$/| $$| $$_  $$_  $$",
        "| $$  \\ $$| $$$$$$$$| $$  \\ $$ \\  $$/$$/ | $$| $$ \\ $$ \\ $$",
        "| $$  | $$| $$_____/| $$  | $$  \\  $$$/  | $$| $$ | $$ | $$",
        "| $$  | $$|  $$$$$$$|  $$$$$$/   \\  $/   | $$| $$ | $$ | $$",
        "|__/  |__/ \\_______/ \\______/     \\_/    |__/|__/ |__/ |__/",
    }
    return header
end

---get oldfiles
---@param amount number amount of oldfiles to return
---@return table oldfiles table with all the oldfiles in it
function U.get_oldfiles(amount)
    local home = vim.fn.expand("~")
    local oldfiles = {}
    local oldfiles_raw = vim.fn.execute("oldfiles")
    local oldfiles_amount = 0
    for file in oldfiles_raw:gmatch("[^\n]+") do
        if oldfiles_amount >= amount then
            break
        end
        table.insert(oldfiles, (string.sub(file, 4, -1)))
        table.insert(all_oldfiles, (string.sub(file, 4, -1)))
        oldfiles_amount = oldfiles_amount + 1
    end
    local oldfiles_shortened = {}
    for _, file in ipairs(oldfiles) do
        if oldfiles_total < 10 then
            oldfiles_shortened[#oldfiles_shortened + 1] = "["
                .. oldfiles_total
                .. "] "
                .. string.gsub(file, home, "~")
        else
            oldfiles_shortened[#oldfiles_shortened + 1] = string.gsub(
                file,
                home,
                "~"
            )
        end
        oldfiles_total = oldfiles_total + 1
    end
    oldfiles = oldfiles_shortened
    table.insert(oldfiles, 1, "Last Files:")
    table.insert(oldfiles, 2, "")

    local length = U.longest_line(oldfiles) + 2
    local oldfiles_aligned = {}
    for _, file in ipairs(oldfiles) do
        table.insert(oldfiles_aligned, file .. U.spaces(length - #file))
    end
    return oldfiles_aligned
end

---get oldfiles of current directory
---@param amount number amount of oldfiles to return
---@return table oldfiles table with all the oldfiles in it
function U.get_oldfiles_directory(amount)
    local home = vim.fn.expand("~")
    local oldfiles_raw = vim.fn.execute("oldfiles")
    local oldfiles_amount = 0
    local directory = vim.api.nvim_exec([[pwd]], true)
    local oldfiles = {}
    for file in oldfiles_raw:gmatch(directory .. "[^\n]+") do
        if oldfiles_amount >= amount then
            break
        end
        table.insert(oldfiles, (string.sub(file, #directory + 1, -1)))
        table.insert(all_oldfiles, file)
        oldfiles_amount = oldfiles_amount + 1
    end
    local oldfiles_shortened = {}
    for _, file in ipairs(oldfiles) do
        if oldfiles_total < 10 then
            oldfiles_shortened[#oldfiles_shortened + 1] = "["
                .. oldfiles_total
                .. "] "
                .. string.gsub(file, home, "~")
        else
            oldfiles_shortened[#oldfiles_shortened + 1] = string.gsub(
                file,
                home,
                "~"
            )
        end
        oldfiles_total = oldfiles_total + 1
    end
    oldfiles = oldfiles_shortened
    table.insert(
        oldfiles,
        1,
        "Last Files in " .. string.gsub(directory, home, "~") .. ":"
    )
    table.insert(oldfiles, 2, "")

    local length = U.longest_line(oldfiles) + 2
    local oldfiles_aligned = {}
    for _, file in ipairs(oldfiles) do
        table.insert(oldfiles_aligned, file .. U.spaces(length - #file))
    end
    return oldfiles_aligned
end

function U.oldfiles_mappings()
    if not all_oldfiles then
        return
    end
    for i = 0, #all_oldfiles >= 10 and 9 or #all_oldfiles - 1, 1 do
        vim.api.nvim_buf_set_keymap(
            0,
            "n",
            tostring(i),
            "<cmd>e " .. all_oldfiles[i + 1] .. "<CR>",
            { noremap = true, silent = true }
        )
    end
end

---return column on which cursor should be positioned
local column = function()
    local settings = require("startup").settings
    local column_calc
    local cursor_column = settings.options.cursor_column or 0.5
    if cursor_column < 1 then
        column_calc = math.floor(
            vim.fn.winwidth(require("startup").window_id) * cursor_column
        )
    else
        column_calc = cursor_column
    end
    return column_calc
end

---reposition cursor if cursor moved up
local function move_up()
    flag = true
    local i
    if new_cursor_pos[1] < U.cursor_pos[1] then
        if new_cursor_pos[1] == 1 then
            set_cursor(new_cursor_pos)
            i = 1
            while true do
                if not bad_line() then
                    flag = false
                    return
                end
                set_cursor({ new_cursor_pos[1] + i, column() })
                i = i + 1
            end
        else
            set_cursor(new_cursor_pos)
            i = 0
        end
    else
        set_cursor(U.cursor_pos)
        i = 1
    end
    while true do
        set_cursor({ new_cursor_pos[1] - i, column() })
        if not bad_line() then
            flag = false
            return
        end
        i = i + 1
        if new_cursor_pos[1] - i <= 1 then
            i = 1
            set_cursor({ 1, column() })
            while true do
                if not bad_line() then
                    flag = false
                    return
                end
                set_cursor({ new_cursor_pos[1] - 1 + i, column() })
                i = i + 1
            end
        end
    end
    flag = false
end

---reposition cursor if cursor moved down
local function move_down()
    flag = true
    local i
    if new_cursor_pos[1] > U.cursor_pos[1] then
        if new_cursor_pos[1] == line_count() then
            set_cursor(new_cursor_pos)
            i = 1
            while true do
                if not bad_line() then
                    flag = false
                    return
                end
                set_cursor({ new_cursor_pos[1] - i, column() })
                i = i + 1
            end
            i = 0
        else
            set_cursor(new_cursor_pos)
            i = 0
        end
    else
        set_cursor(U.cursor_pos)
        if new_cursor_pos[1] == line_count() then
            flag = false
            return
        end
        i = 1
    end
    while true do
        set_cursor({ new_cursor_pos[1] + i, column() })
        if not bad_line() then
            flag = false
            return
        end
        i = i + 1
        if new_cursor_pos[1] + i > line_count() then
            set_cursor(U.cursor_pos)
            flag = false
            return
        end
    end
    flag = false
end

---reposition cursor after it moved
function U.reposition_cursor()
    if vim.o.filetype ~= "startup" or flag then
        return
    end
    new_cursor_pos = vim.api.nvim_win_get_cursor(0)
    if new_cursor_pos[1] > U.cursor_pos[1] then
        move_down()
    elseif
        (new_cursor_pos[1] < U.cursor_pos[1])
        or new_cursor_pos[2] < U.cursor_pos[2]
    then
        move_up()
    elseif
        (new_cursor_pos[1] > U.cursor_pos[1])
        or new_cursor_pos[2] > U.cursor_pos[2]
    then
        move_down()
    end
    U.cursor_pos = vim.api.nvim_win_get_cursor(0)
end

---return longest line length
---@param lines table
---@return number longest
function U.longest_line(lines)
    local longest = 0
    for _, line in ipairs(lines) do
        if vim.fn.strdisplaywidth(line) > longest then
            longest = vim.fn.strdisplaywidth(line)
        end
    end
    return longest
end

---set all the options that should be set for the startup buffer
function U.set_buf_options()
    local settings = require("startup").settings
    local last_status = vim.api.nvim_get_option("laststatus")
    local tab_line = vim.api.nvim_get_option("showtabline")
    set_buf_opt(0, "bufhidden", "wipe")
    set_buf_opt(0, "buftype", "nofile")
    vim.cmd([[setlocal wrap]])
    if settings.options.disable_statuslines then
        vim.opt.laststatus = 0
        vim.opt.showtabline = 0
    end
    set_buf_opt(0, "filetype", "startup")
    set_buf_opt(0, "swapfile", false)
    vim.cmd([[setlocal nonu nornu]])
    vim.api.nvim_set_current_dir(
        vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
    )
    vim.cmd(
        [[autocmd BufEnter * lua if vim.opt.filetype~="startup" then vim.opt.laststatus=]]
            .. last_status
            .. [[;vim.opt.showtabline=]]
            .. tab_line
            .. [[ end]]
    )
end

---validate the settings
---@param options table the settings for a section
function U.validate_settings(options)
    if not options.oldfiles_directory then
        options.oldfiles_directory = false
    end
    if not options.fold_section then
        options.fold_section = false
    end
    if not options.margin then
        options.margin = 5
    end
    if not options.title then
        options.title = ""
    end
    if not options.default_color then
        options.default_color = ""
    end
    if not options.highlights then
        options.highlights = ""
    end
    if not options.oldfiles_amount then
        options.oldfiles_amount = 5
    end
    vim.validate({
        type = {
            options.type,
            function(arg)
                for _, v in ipairs({ "mapping", "oldfiles", "text" }) do
                    if v == arg then
                        return true
                    end
                end
                return false
            end,
            '"mapping" "text" or "oldfiles"',
        },
        align = {
            options.align,
            function(arg)
                for _, v in ipairs({ "right", "left", "center" }) do
                    if v == arg then
                        return true
                    end
                end
                return false
            end,
            '"center" "left" or "right"',
        },
        content = {
            options.content,
            function(content)
                if
                    options.type == "text"
                    and (
                        type(content) == "table"
                        or type(content)
                            == "function"
                    )
                then
                    return true
                elseif
                    options.type == "mapping" and type(content) == "table"
                then
                    return true
                elseif options.type == "oldfiles" then
                    return true
                end
                return false
            end,
            "table for type=mapping and table or function for type=text",
        },
    })
    return options
end

return U
