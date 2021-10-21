local M = {}
local ns = vim.api.nvim_create_namespace "startup"
-- tables with tables: {line, align, cursor_should move on}
M.lines = {}
M.formatted_text = {}
M.sections = {}
M.open_sections = {}

local section_alignments = {}

local current_section = ""

local opts = { noremap = true, silent = true }
local settings = require "startup.config"

local utils = require "startup.utils"
local spaces = utils.spaces

function M.open_section()
  vim.api.nvim_buf_set_option(0, "modifiable", true)
  local line_nr = vim.api.nvim_win_get_cursor(0)[1]
  local section_name = vim.trim(vim.api.nvim_get_current_line())
  local section_align = section_alignments[section_name]
  local section_entries = M.sections[section_name]
  if section_name == "" then
    return
  end
  local valid_section = false
  for title, _ in pairs(M.sections) do
    if section_name == title then
      valid_section = true
    end
  end
  if not valid_section then
    return
  end
  section_entries = require("startup").align(section_entries, section_align)
  for i, section in ipairs(M.open_sections) do
    if section == section_name then
      vim.api.nvim_buf_set_lines(
        0,
        line_nr,
        line_nr + #section_entries,
        false,
        {}
      )
      table.remove(M.open_sections, i)
      return
    end
  end
  vim.api.nvim_buf_set_lines(0, line_nr, line_nr, false, section_entries)
  table.insert(M.open_sections, section_name)
  vim.cmd [[silent! %s/\s\+$//]] -- clear trailing whitespace
  vim.api.nvim_win_set_cursor(0, { line_nr, vim.o.columns / 2 })
  vim.api.nvim_buf_set_option(0, "modifiable", false)
end

local function create_mappings(mappings)
  vim.api.nvim_buf_set_keymap(
    0,
    "n",
    "<CR>",
    ":lua require'startup'.check_line()<CR>",
    opts
  )
  vim.api.nvim_buf_set_keymap(
    0,
    "n",
    "o",
    "<cmd>lua require('startup').open_file()<CR>",
    opts
  )
  vim.api.nvim_buf_set_keymap(
    0,
    "n",
    "<tab>",
    "<cmd>lua require'startup'.open_section()<CR>",
    opts
  )
  vim.api.nvim_buf_set_keymap(
    0,
    "n",
    "<c-o>",
    "<cmd>lua require('startup').open_file_vsplit()<CR>",
    opts
  )
  if mappings ~= {} then
    for _, cmd in pairs(mappings) do
      vim.api.nvim_buf_set_keymap(
        0,
        "n",
        cmd[2],
        "<cmd>" .. cmd[1] .. "<CR>",
        opts
      )
    end
  end
end

function M.new_file()
  local name = vim.fn.input "Filename: > "
  vim.cmd("e " .. name)
end

local sections_with_mappings = {}

function M.check_line()
  local line = vim.api.nvim_get_current_line()
  for _, section in ipairs(sections_with_mappings) do
    for name, command in pairs(settings[section].content) do
      if line:match(name) then
        vim.cmd(command[1])
      end
    end
  end
end

function M.open_file()
  local line = vim.api.nvim_get_current_line()
  local filename = line
  print(filename)
  vim.cmd("e " .. filename)
end

function M.open_file_vsplit()
  local line = vim.api.nvim_get_current_line()
  local filename = line
  print(filename)
  vim.cmd("vsplit " .. filename)
end
function M.align(dict, alignment)
  local margin_calculated = 0
  if settings[current_section].margin < 1 then
    margin_calculated = vim.o.columns * settings[current_section].margin
  else
    margin_calculated = settings[current_section].margin
  end
  local aligned = {}
  local max_len = utils.longest_line(dict)
  if alignment == "center" then
    local space_left = vim.o.columns - max_len
    for _, line in ipairs(dict) do
      table.insert(aligned, spaces(space_left / 2) .. line)
    end
  elseif alignment == "left" then
    for _, line in ipairs(dict) do
      table.insert(aligned, spaces(margin_calculated) .. line)
    end
  elseif alignment == "right" then
    for _, line in ipairs(dict) do
      table.insert(
        aligned,
        spaces(vim.o.columns - max_len - margin_calculated - 10) .. line
      )
    end
  end
  margin_calculated = 0
  return aligned
end
local function align(dict, alignment)
  local margin_calculated = 0
  if settings[current_section].margin < 1 then
    margin_calculated = vim.o.columns * settings[current_section].margin
  else
    margin_calculated = settings[current_section].margin
  end
  local aligned = {}
  local max_len = utils.longest_line(dict)
  if alignment == "center" then
    local space_left = vim.o.columns - max_len
    for _, line in ipairs(dict) do
      table.insert(aligned, spaces(space_left / 2) .. line)
    end
  elseif alignment == "left" then
    for _, line in ipairs(dict) do
      table.insert(aligned, spaces(margin_calculated) .. line)
    end
  elseif alignment == "right" then
    for _, line in ipairs(dict) do
      table.insert(
        aligned,
        spaces(vim.o.columns - max_len - margin_calculated - 10) .. line
      )
    end
  end
  margin_calculated = 0
  return aligned
end

local count = 1
local function set_lines(len, text, alignment, hi, pass)
  vim.api.nvim_buf_set_lines(
    0,
    count,
    count + len,
    false,
    align(text, alignment)
  )
  vim.api.nvim_win_set_cursor(0, { count, 0 })
  if pass then
    vim.g.section_length = count
  end
  for i = count, count + len do
    vim.api.nvim_buf_add_highlight(0, ns, hi, i, 1, -1)
  end
  count = count + len
end

local function empty(amount)
  for _ = 1, amount, 1 do
    table.insert(M.lines, { " ", "center", false, "normal" })
  end
end
function M.mapping_names(mappings)
  local mapnames = {}
  local length = utils.longest_line(mappings) + 5
  for name, cmd in pairs(mappings) do
    if settings.options.empty_lines_between_mappings then
      table.insert(mapnames, " ")
    end
    if settings.options.mapping_keys then
      local space = utils.spaces(length - #cmd[2] - #name)
      table.insert(mapnames, name .. space .. cmd[2])
    else
      local space = utils.spaces(length - #name)
      table.insert(mapnames, name .. space)
    end
  end

  return mapnames
end
local function mapping_names(mappings)
  local mapnames = {}
  local strings = {}
  for title, command in pairs(mappings) do
    if settings.options.mapping_keys then
      table.insert(strings, title .. command[2])
    else
      table.insert(strings, title)
    end
  end
  local length = utils.longest_line(strings) + 18
  -- local length = vim.o.columns * 0.4
  for name, cmd in pairs(mappings) do
    if settings.options.empty_lines_between_mappings then
      table.insert(mapnames, " ")
    end
    if settings.options.mapping_keys then
      local space = utils.spaces(length - #cmd[2] - #name)
      table.insert(mapnames, name .. space .. cmd[2])
    else
      local space = utils.spaces(length - #name)
      table.insert(mapnames, name .. space)
    end
  end

  return mapnames
end

function M.display()
  vim.schedule(function()
    local padding_nr = 1
    U.set_buf_options()
    local parts = settings.parts
    for _, part in ipairs(parts) do
      empty(settings.options.paddings[padding_nr])
      padding_nr = padding_nr + 1
      current_section = part
      local options = settings[part]
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
          M.sections[vim.trim(options.title)] = options.content
          table.insert(
            M.lines,
            { options.title, options.align, true, options.highlight }
          )
        else
          for _, line in ipairs(options.content) do
            table.insert(
              M.lines,
              { line, options.align, false, options.highlight }
            )
          end
        end
      elseif options.type == "mapping" then
        if options.fold_section then
          section_alignments[vim.trim(options.title)] = options.align
          M.sections[vim.trim(options.title)] = mapping_names(options.content)
          table.insert(
            M.lines,
            { options.title, options.align, true, options.highlight }
          )
        else
          for _, line in ipairs(mapping_names(options.content)) do
            table.insert(
              M.lines,
              { line, options.align, true, options.highlight }
            )
          end
        end
        table.insert(sections_with_mappings, part)
        create_mappings(options.content)
      elseif options.type == "oldfiles" then
        local oldfiles = {}
        if options.oldfiles_directory then
          old_files = utils.get_oldfiles_directory(options.oldfiles_amount)
        else
          old_files = utils.get_oldfiles(options.oldfiles_amount)
        end
        if options.fold_section then
          section_alignments[vim.trim(options.title)] = options.align
          M.sections[vim.trim(options.title)] = old_files
          table.insert(
            M.lines,
            { options.title, options.align, true, options.highlight }
          )
        else
          for _, line in ipairs(old_files) do
            table.insert(
              M.lines,
              { line, options.align, true, options.highlight }
            )
          end
        end
      end
      create_mappings {}
      vim.cmd(options.command)
    end
    -- current_section = ""
    for _, line in ipairs(M.lines) do
      table.insert(M.formatted_text, align({ line[1] }, line[2])[1])
    end
    vim.api.nvim_buf_set_option(0, "modifiable", true)
    vim.api.nvim_buf_set_lines(0, 0, -1, true, {})
    vim.api.nvim_buf_set_lines(0, 0, -1, false, M.formatted_text)
    vim.cmd [[silent! %s/\s\+$//]] -- clear trailing whitespace
    for linenr, line in ipairs(M.lines) do
      vim.api.nvim_buf_add_highlight(0, ns, line[4], linenr - 1, 0, -1)
    end
    vim.api.nvim_buf_set_option(0, "modifiable", false)
    vim.api.nvim_win_set_cursor(0, { 1, 1 })
    vim.api.nvim_win_set_cursor(0, {
      #settings.header.content + settings.options.paddings[1] + 1,
      math.floor(vim.o.columns / 2),
    })
  end)
  vim.cmd [[autocmd CursorMoved * lua require"startup.utils".reposition_cursor()]]
end

function M.setup(update)
  if vim.g.startup_nvim_loaded then
    return
  end
  vim.g.startup_nvim_loaded = true

  settings = vim.tbl_deep_extend("force", settings, update or {})
  vim.cmd [[
  autocmd VimEnter * lua if vim.fn.argc() == 0 then require"startup".display() end
  ]]
end

return M
