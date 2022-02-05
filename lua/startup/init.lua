local startup = {}
local ns = vim.api.nvim_create_namespace("startup")
local log = require("startup.log")

startup.window_id = 0
startup.buffer_nr = nil
-- tables with tables: {line, align, cursor should move on, highlight}
startup.lines = {}
startup.formatted_text = {}
startup.sections = {}
startup.section_highlights = {}
startup.open_sections = {}
startup.good_lines = {}
startup.user_mappings = {}
startup.settings = require("startup.themes.dashboard")

local directory_oldfiles

local get_cur_line = vim.api.nvim_get_current_line

---set option in buffer
local set_buf_opt = vim.api.nvim_buf_set_option

local section_alignments = {}
local sections_with_mappings = {}

local startup_nvim_displayed
local startup_nvim_loaded

local current_section = ""

local old_cmd_syntax = false

local opts = { noremap = true, silent = true }
local settings = require("startup.themes.dashboard")

local function parse_mapping(mapping)
    mapping = string.gsub(mapping, "C%-", "ctrl+")
        :gsub("c%-", "ctrl+")
        :gsub("%<leader%>", "leader+")
        :gsub("%<(.+)%>", "%1")
    return mapping
end

---@type startup.utils
local utils = require("startup.utils")

---creates a mapping for the current buffer
---@param mapping string the mapping to use
---@param command string the command to be mapped
local buf_map = function(mapping, command)
    vim.api.nvim_buf_set_keymap(0, "n", mapping, command, opts)
end

function startup.commands(arg)
    if arg == "redraw" then
        startup.redraw()
    end
    if arg == "display" then
        startup.display(true)
        vim.defer_fn(function()
            startup.redraw()
        end, 2)
    end
    if arg == "breaking_changes" then
        utils.breaking_changes()
    end
end

---open fold under cursor
function startup.open_section()
    set_buf_opt(0, "modifiable", true)
    local line_nr = vim.api.nvim_win_get_cursor(0)[1]
    local section_name = vim.trim(get_cur_line())
    local section_align = section_alignments[section_name]
    local section_highlight = startup.section_highlights[section_name]
    local section_entries = startup.sections[section_name]
    if section_entries == nil or section_name == "" then
        return
    end
    section_entries = startup.align(section_entries, section_align)
    for i, section in ipairs(startup.open_sections) do
        if section == section_name then
            vim.api.nvim_buf_set_lines(
                0,
                line_nr,
                line_nr + #section_entries,
                false,
                {}
            )
            table.remove(startup.open_sections, i)
            startup.redraw()
            return
        end
    end
    vim.api.nvim_buf_set_lines(0, line_nr, line_nr, false, section_entries)
    for number, _ in ipairs(section_entries) do
        vim.api.nvim_buf_add_highlight(
            0,
            ns,
            section_highlight,
            line_nr + number - 1,
            0,
            -1
        )
    end
    table.insert(startup.open_sections, section_name)
    vim.cmd([[silent! %s/\s\+$//]]) -- clear trailing whitespace
    vim.api.nvim_win_set_cursor(
        0,
        { line_nr, math.floor(vim.fn.winwidth(startup.window_id) / 2) }
    )
    set_buf_opt(0, "modifiable", false)
    -- startup.redraw()
end

local function create_mappings(mappings)
    buf_map(
        settings.mappings.execute_command,
        ":lua require'startup'.check_line()<CR>"
    )
    buf_map(
        settings.mappings.open_file,
        "<cmd>lua require('startup').open_file()<CR>"
    )
    buf_map(
        settings.mappings.open_section,
        "<cmd>lua require'startup'.open_section()<CR>"
    )
    buf_map(
        settings.mappings.open_file_split,
        "<cmd>lua require('startup').open_file_vsplit()<CR>"
    )
    buf_map(
        settings.mappings.open_help,
        "<cmd>lua require'startup.utils'.key_help()<CR>"
    )
    if mappings ~= {} then
        for _, cmd in pairs(mappings) do
            buf_map(cmd[3], "<cmd>" .. cmd[2] .. "<CR>")
        end
    end
end

function startup.create_mappings(mappings)
    for lhs, rhs in pairs(mappings) do
        buf_map(lhs, rhs)
        startup.user_mappings[lhs] = rhs
    end
end

---ask for a filename and create file
function startup.new_file()
    local name = vim.fn.input("Filename: > ")
    if name == "" then
        -- log.warn("No Filename")
        return
    end
    vim.cmd("e " .. name)
end

---check if current line is one of the commands
function startup.check_line()
    local line = get_cur_line()
    if old_cmd_syntax then
        for _, section in ipairs(sections_with_mappings) do
            for name, command in pairs(settings[section].content) do
                if line:match(name) then
                    vim.cmd(command[1])
                end
            end
        end
    else
        for _, section in ipairs(sections_with_mappings) do
            for _, command in ipairs(settings[section].content) do
                if line:match(command[1]) then
                    vim.cmd(command[2])
                end
            end
        end
    end
end

local function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

---open file under cursor
function startup.open_file()
    local filename = vim.trim(get_cur_line())
    filename = string.gsub(filename, "%[%d%] (.+)", "%1")
    filename = vim.fn.fnamemodify(filename, ":p")
    if directory_oldfiles then
        local trimmed_oldfiles = vim.tbl_map(function(ele)
            ele = vim.trim(ele)
            ele = string.gsub(ele, "%[%d%] (.+)", "%1")
            return ele
        end, directory_oldfiles)
        if vim.tbl_contains(trimmed_oldfiles, filename) then
            -- if vim.tbl_contains(function(element) return vim.trim(element) end ,directory_oldfiles), filename) then
            local directory = vim.api.nvim_exec([[pwd]], true)
            filename = directory .. filename
        end
    end
    if file_exists(filename) then
        vim.cmd("e " .. filename)
    end
end

---open file under cursor in split
function startup.open_file_vsplit()
    local filename = vim.trim(get_cur_line())
    filename = string.gsub(filename, "%[%d%] (.+)", "%1")
    filename = vim.fn.fnamemodify(filename, ":p")
    if directory_oldfiles then
        local trimmed_oldfiles = vim.tbl_map(function(ele)
            ele = vim.trim(ele)
            ele = string.gsub(ele, "%[%d%] (.+)", "%1")
            return ele
        end, directory_oldfiles)
        if vim.tbl_contains(trimmed_oldfiles, filename) then
            local directory = vim.api.nvim_exec([[pwd]], true)
            filename = directory .. filename
        end
    end
    if file_exists(filename) then
        vim.cmd("vsplit " .. filename)
    end
    startup.redraw(true)
end

---creates a table with the strings in it aligned
---@param dict table the strings to be aligned
---@param alignment string the alignement(left,center or right)
---@return table aligned the aligned strings
function startup.align(dict, alignment)
    local margin_calculated = 0
    local margin = settings.margin and type(settings.margin) == "number" or 5
    if margin == 0 then
        margin_calculated = 0
    elseif margin < 1 then
        margin_calculated = vim.fn.winwidth(startup.window_id) * margin
    else
        margin_calculated = margin
    end
    local aligned = {}
    local max_len = utils.longest_line(dict)
    if alignment == "center" then
        local space_left = vim.fn.winwidth(startup.window_id) - max_len
        for _, line in ipairs(dict) do
            table.insert(aligned, utils.spaces(space_left / 2) .. line)
        end
    elseif alignment == "left" then
        for _, line in ipairs(dict) do
            table.insert(aligned, utils.spaces(margin_calculated) .. line)
        end
    elseif alignment == "right" then
        for _, line in ipairs(dict) do
            table.insert(
                aligned,
                utils.spaces(
                    vim.fn.winwidth(startup.window_id)
                        - max_len
                        - margin_calculated
                        - 10
                ) .. line
            )
        end
    end
    margin_calculated = 0
    return aligned
end

---creates mapping names from table of mappings
---@param mappings table
---@return table
function startup.mapping_names(mappings)
    local mapnames = {}
    local strings = {}
    if not (mappings[1] or mappings[2]) then
        log.warn(
            "It looks like you use old syntax. Check `:Startup breaking_changes`"
        )
        old_cmd_syntax = true
        for title, command in pairs(mappings) do
            if settings.options.mapping_keys then
                table.insert(strings, title .. command[2])
            else
                table.insert(strings, title)
            end
        end
        local length = utils.longest_line(strings) + 18
        for name, cmd in pairs(mappings) do
            if settings.options.mapping_keys then
                local space = utils.spaces(
                    length - #parse_mapping(cmd[2]) - #name
                )
                table.insert(mapnames, name .. space .. parse_mapping(cmd[2]))
            else
                local space = utils.spaces(length - #name)
                table.insert(mapnames, name .. space)
            end
        end
    else
        for _, mapping in pairs(mappings) do
            if settings.options.mapping_keys then
                table.insert(strings, mapping[1] .. mapping[3])
            else
                table.insert(strings, mapping[1])
            end
        end
        local length = utils.longest_line(strings) + 18
        for _, mapping in pairs(mappings) do
            if settings.options.mapping_keys then
                local space = utils.spaces(
                    length - #parse_mapping(mapping[3]) - #mapping[1]
                )
                table.insert(
                    mapnames,
                    mapping[1] .. space .. parse_mapping(mapping[3])
                )
            else
                local space = utils.spaces(length - #mapping[1])
                table.insert(mapnames, mapping[1] .. space)
            end
        end
    end
    return mapnames
end

function startup.remove_buffer(info)
    vim.defer_fn(function()
        if vim.fn.bufexists(startup.buffer_nr) ~= 0 then
            return
        end
        startup_nvim_displayed = false
    end, 1000)
    -- end
end

function startup.display(force)
    if startup_nvim_displayed then
        return
    end
    if vim.tbl_contains({ "quickfix", "help" }, vim.bo.buftype) then
        return
    end
    if not force then
        if vim.fn.bufname() ~= "" then
            return
        end
    else
        startup.buffer_nr = vim.api.nvim_create_buf(false, false)
        vim.cmd("buf " .. startup.buffer_nr)
    end
    startup_nvim_displayed = true
    local padding_nr = 1
    startup.lines = {}
    startup.window_id = vim.fn.win_getid()
    startup.buffer_nr = vim.fn.getbufinfo()[1]["bufnr"]
    utils.set_buf_options()
    if settings.theme then
        settings = vim.tbl_deep_extend(
            "force",
            settings,
            utils.load_theme(settings.theme) or {}
        )
    end
    local parts = settings.parts
    vim.cmd([[hi link StartupFoldedSection Special]])
    for _, part in ipairs(parts) do
        utils.empty(settings.options.paddings[padding_nr])
        padding_nr = padding_nr + 1
        current_section = part
        local options = settings[part]
        options = utils.validate_settings(options)
        if type(options.content) == "function" then
            options.content = options.content()
        end
        if options.highlight == "" then
            vim.cmd(
                "highlight Startup"
                    .. part
                    .. " guifg="
                    .. options.default_color
                    .. " guibg="
                    .. settings.colors.background
            )
            options.highlight = "Startup" .. part
        end
        if options.type == "text" then
            if options.fold_section then
                section_alignments[vim.trim(options.title)] = options.align
                startup.sections[vim.trim(options.title)] = options.content
                startup.section_highlights[vim.trim(options.title)] =
                    options.highlight
                startup.good_lines[#startup.good_lines + 1] = vim.trim(
                    options.title
                )
                table.insert(
                    startup.lines,
                    { options.title, options.align, true, "StartupFoldedSection" }
                )
            else
                for _, line in ipairs(options.content) do
                    table.insert(
                        startup.lines,
                        { line, options.align, false, options.highlight }
                    )
                end
            end
        elseif options.type == "mapping" then
            if options.fold_section then
                section_alignments[vim.trim(options.title)] = options.align
                for _, line in ipairs(startup.mapping_names(options.content)) do
                    startup.good_lines[#startup.good_lines + 1] = vim.trim(line)
                end
                startup.sections[vim.trim(options.title)] =
                    startup.mapping_names(
                        options.content
                    )
                startup.section_highlights[vim.trim(options.title)] =
                    options.highlight
                startup.good_lines[#startup.good_lines + 1] = vim.trim(
                    options.title
                )
                table.insert(
                    startup.lines,
                    { options.title, options.align, true, "StartupFoldedSection" }
                )
                for _, line in ipairs(startup.mapping_names(options.content)) do
                    startup.good_lines[#startup.good_lines + 1] = vim.trim(line)
                end
            else
                for _, line in ipairs(startup.mapping_names(options.content)) do
                    startup.good_lines[#startup.good_lines + 1] = vim.trim(line)
                    table.insert(
                        startup.lines,
                        { line, options.align, true, options.highlight }
                    )
                    if settings.options.empty_lines_between_mappings then
                        utils.empty(1)
                    end
                end
            end
            table.insert(sections_with_mappings, part)
            create_mappings(options.content)
        elseif options.type == "oldfiles" then
            local old_files
            if options.oldfiles_directory then
                old_files = utils.get_oldfiles_directory(
                    options.oldfiles_amount or 5
                )
                directory_oldfiles = old_files
            else
                old_files = utils.get_oldfiles(options.oldfiles_amount or 5)
            end
            if options.fold_section then
                section_alignments[vim.trim(options.title)] = options.align
                startup.sections[vim.trim(options.title)] = old_files
                startup.section_highlights[vim.trim(options.title)] =
                    options.highlight
                startup.good_lines[#startup.good_lines + 1] = vim.trim(
                    options.title
                )
                for _, line in ipairs(old_files) do
                    startup.good_lines[#startup.good_lines + 1] = vim.trim(line)
                end
                table.insert(
                    startup.lines,
                    { options.title, options.align, true, "StartupFoldedSection" }
                )
            else
                for _, line in ipairs(old_files) do
                    startup.good_lines[#startup.good_lines + 1] = vim.trim(line)
                    table.insert(
                        startup.lines,
                        { line, options.align, true, options.highlight }
                    )
                end
            end
        end
        create_mappings({})
    end
    if settings.folded_section_color ~= "" then
        vim.cmd(
            [[highlight StartupFoldedSection guifg=]]
                .. settings.colors.folded_section
        )
    end
    for _, line in ipairs(startup.lines) do
        table.insert(
            startup.formatted_text,
            startup.align({ line[1] }, line[2])[1]
        )
    end
    set_buf_opt(0, "modifiable", true)
    vim.api.nvim_buf_set_lines(0, 0, -1, true, {})
    vim.api.nvim_buf_set_lines(0, 0, -1, false, startup.formatted_text)
    vim.cmd([[silent! %s/\s\+$//]]) -- clear trailing whitespace
    for linenr, line in ipairs(startup.lines) do
        vim.api.nvim_buf_add_highlight(0, ns, line[4], linenr - 1, 0, -1)
    end
    if settings.options.after and settings.options.after ~= "" then
        settings.options.after()
    end
    set_buf_opt(0, "modifiable", false)
    vim.api.nvim_win_set_cursor(0, { 1, 1 })
    vim.cmd(
        [[autocmd CursorMoved * lua require"startup.utils".reposition_cursor()]]
    )
    vim.cmd([[
        autocmd BufDelete * lua require"startup".remove_buffer(vim.fn.getbufinfo()[1])
        autocmd BufHidden * lua require"startup".remove_buffer(vim.fn.getbufinfo()[1])
        autocmd BufLeave * lua require"startup".remove_buffer(vim.fn.getbufinfo()[1])
    ]])
    vim.defer_fn(function()
        vim.api.nvim_win_set_cursor(0, {
            2,
            2,
        })
        startup.buffer_nr = vim.api.nvim_get_current_buf()
    end, 1)
    if force then
        startup.buffer_nr = vim.api.nvim_get_current_buf()
        vim.defer_fn(function()
            startup.redraw(false)
        end, 1)
    end
end

local function create_settings(update)
    settings = require("startup.themes.empty")
    if update then
        settings = vim.tbl_deep_extend("force", settings, update or {})
    else
        settings = require("startup.themes.dashboard")
    end
    return settings
end

---Create autocmds for startup.nvim and update settings with update
---@param update table the settings to use
function startup.setup(update)
    if startup_nvim_loaded then
        return
    end
    startup_nvim_loaded = true
    startup.settings = create_settings(update)
    vim.cmd(
        [[command! -nargs=*  Startup :lua require'startup'.commands('<args>')]]
    )
    if not vim.g.startup_disable_on_startup then
        vim.cmd(
            [[autocmd VimEnter * lua if vim.fn.argc() == 0 then require("startup").display() end
        autocmd BufRead * lua if vim.fn.argc() == 0 then require("startup").display() end]]
        )
        vim.cmd(
            [[autocmd VimResized * lua if vim.bo.ft == "startup" then require"startup".redraw() end
        autocmd BufEnter * lua if vim.bo.ft == "startup" then require"startup".redraw() end]]
        )
    end
end

---Clears the screen and redraws the whole startup screen
function startup.redraw(other_file)
    local temp_cursor
    local temp_id
    local cursor
    if other_file then
        temp_id = vim.fn.win_getid()
        temp_cursor = vim.api.nvim_win_get_cursor(temp_id)
        vim.fn.win_gotoid(startup.window_id)
        cursor = vim.api.nvim_win_get_cursor(startup.window_id)
    else
        if
            vim.fn.bufname() == ""
            and vim.api.nvim_get_current_buf() ~= startup.buffer_nr
        then
            return
        end
    end
    startup.formatted_text = {}
    for _, line in ipairs(startup.lines) do
        table.insert(
            startup.formatted_text,
            startup.align({ line[1] }, line[2])[1]
        )
    end
    set_buf_opt(0, "modifiable", true)
    vim.api.nvim_buf_set_lines(0, 0, -1, true, {})
    vim.api.nvim_buf_set_lines(0, 0, -1, false, startup.formatted_text)
    vim.cmd([[silent! %s/\s\+$//]]) -- clear trailing whitespace
    for linenr, line in ipairs(startup.lines) do
        vim.api.nvim_buf_add_highlight(0, ns, line[4], linenr - 1, 0, -1)
    end
    set_buf_opt(0, "modifiable", false)
    if other_file then
        vim.fn.feedkeys("gg", "n")
        vim.api.nvim_win_set_cursor(startup.window_id, { 1, cursor[2] })
        vim.fn.win_gotoid(temp_id)
        vim.api.nvim_win_set_cursor(0, temp_cursor)
    end
end

return startup
