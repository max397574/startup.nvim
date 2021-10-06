local M = {}
local ns = vim.api.nvim_create_namespace "startup"

local opts = { noremap = true, silent = true }
local settings = require "startup.config"

local utils = require "startup.utils"
local spaces = utils.spaces
local empty = utils.empty

local function create_mappings()
  vim.api.nvim_buf_set_keymap(
    0,
    "n",
    "<CR>",
    ":lua require'startup'.check_line()<CR>",
    opts
  )
  for _, cmd in pairs(settings.tools) do
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

function M.check_line()
  local line = vim.api.nvim_get_current_line()
  for name, command in pairs(settings.tools) do
    if line:match(name) then
      vim.cmd(command[1])
    end
  end
end

local function align(dict)
  local aligned = {}
  if settings.options.align == "center" then
    local max_len = utils.longest_line(dict)
    local space_left = vim.o.columns - max_len
    for _, line in ipairs(dict) do
      table.insert(aligned, spaces(space_left / 2) .. line)
    end
  elseif settings.options.align == "padding" then
    for _, line in ipairs(dict) do
      table.insert(aligned, spaces(settings.options.padding) .. line)
    end
  end
  return aligned
end

local count = 1
local function set_lines(len, text, hi, pass)
  vim.api.nvim_buf_set_lines(0, count, count + len, false, align(text))
  vim.api.nvim_win_set_cursor(0, { count, 0 })
  if pass then
    vim.g.section_length = count
  end
  for i = count, count + len do
    vim.api.nvim_buf_add_highlight(0, ns, hi, i, 1, -1)
  end
  count = count + len
end

local function empty()
  set_lines(1, { " " }, "StartupTools")
end

local function body()
  local toolnames = {}
  for name, cmd in pairs(settings.tools) do
    if not limited_space then
      table.insert(toolnames, " ")
    end
    if settings.options.mapping_names then
      table.insert(toolnames, name .. "  " .. cmd[2])
    else
      table.insert(toolnames, name)
    end
  end

  return toolnames
end

function M.display()
  local limited_space = false
  local rly_limited_space = false

  if vim.o.lines < (#settings.header + (#settings.tools * 2) + 20) then
    limited_space = true
  end

  create_mappings()
  utils.create_hls()
  -- vim.api.nvim_buf_set_keymap(0, "n", "j", "2j", opts)
  -- vim.api.nvim_buf_set_keymap(0, "n", "k", "2k", opts)
  if not limited_space then
    empty()
  end
  set_lines(#settings.header, settings.header, "StartupHeading")

  local toolnames = body()
  empty()
  set_lines(#toolnames, toolnames, "StartupTools")

  vim.cmd [[silent! %s/\s\+$//]] -- clear trailing whitespace
  U.set_buf_options()
  if limited_space then
    vim.api.nvim_win_set_cursor(
      0,
      { #settings.header + 3, math.floor(vim.o.columns / 2) }
    )
  end
end

function M.setup(update)
  settings = vim.tbl_deep_extend("force", settings, update or {})
  vim.cmd [[
  autocmd StdinReadPre * let s:std_in=1
  autocmd VimEnter * lua if vim.fn.argc() == 0 and vim.fn.exists('std_in') then require"startup".display() end
  ]]
end

return M
