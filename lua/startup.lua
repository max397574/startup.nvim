local M = {}
local ns = vim.api.nvim_create_namespace "startup"

local current_section = ""

local opts = { noremap = true, silent = true }
local settings = require "startup.config"

local utils = require "startup.utils"
local spaces = utils.spaces

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
  local filename = line:gsub "(\\/.-)+"
  print(filename)
  vim.cmd("e " .. filename)
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
    set_lines(1, { " " }, "center", "StartupTools")
  end
end

local function mapping_names(mappings)
  local mapnames = {}
  for name, cmd in pairs(mappings) do
    if settings.options.empty_lines_between_mappings then
      table.insert(mapnames, " ")
    end
    if settings.options.mapping_keys then
      table.insert(mapnames, name .. "  " .. cmd[2])
    else
      table.insert(mapnames, name)
    end
  end

  return mapnames
end

-- TODO: put inside schedule()
function M.display()
  vim.schedule(function()
    U.set_buf_options()
    local parts = { "header", "body", "footer" }
    for _, part in ipairs(parts) do
      current_section = part
      local options = settings[part]
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
        set_lines(
          #options.content,
          options.content,
          options.align,
          options.highlight
        )
      elseif options.type == "mapping" then
        table.insert(sections_with_mappings, part)
        create_mappings(options.content)
        set_lines(
          #mapping_names(options.content),
          mapping_names(options.content),
          options.align,
          options.highlight
        )
      end
      if part == "header" then
        empty(settings.options.padding.header_body)
      elseif part == "body" then
        empty(settings.options.padding.body_footer + 1)
      end
      vim.cmd(options.command)
    end
    current_section = ""
    vim.cmd [[silent! %s/\s\+$//]] -- clear trailing whitespace
    vim.api.nvim_win_set_cursor(0, {
      #settings.header.content + settings.options.padding.header_body + 3,
      math.floor(vim.o.columns / 2),
    })
    vim.api.nvim_buf_set_option(0, "modifiable", false)
  end)
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
