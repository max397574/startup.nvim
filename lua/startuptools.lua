local M = {}
local ns = vim.api.nvim_create_namespace('startuptools')

local opts = { noremap = true, silent = true }

local settings = {
  -- every line should be same width without escaped \
  header = {
"                                          /$$              ",
"                                         |__/              ",
" /$$$$$$$   /$$$$$$   /$$$$$$  /$$    /$$ /$$ /$$$$$$/$$$$ ",
"| $$__  $$ /$$__  $$ /$$__  $$|  $$  /$$/| $$| $$_  $$_  $$",
"| $$  \\ $$| $$$$$$$$| $$  \\ $$ \\  $$/$$/ | $$| $$ \\ $$ \\ $$",
"| $$  | $$| $$_____/| $$  | $$  \\  $$$/  | $$| $$ | $$ | $$",
"| $$  | $$|  $$$$$$$|  $$$$$$/   \\  $/   | $$| $$ | $$ | $$",
"|__/  |__/ \\_______/ \\______/     \\_/    |__/|__/ |__/ |__/",
  },
  -- name which will be displayed and command
  tools = {
    [" Find File"] = "Telescope find_files",
    [" Find Word"]  = "Telescope live_grep",
    [" Recent Files"] = "Telescope oldfiles",
    [" File Browser"] = "Telescope file_browser",
    [" Config Files"] = 'lua require("telescope.builtin").find_files({cwd="~/.config"})',
    [" Colorschemes"] = "Telescope colorscheme",
    [" New File"] = "lua require'startuptools'.new_file()",
  },
  mappings = {
  }
}

function M.new_file()
  local name = vim.fn.input("Filename: > ")
  vim.cmd("e "..name)
end

function M.check_line()
  local line = vim.api.nvim_get_current_line()
  for name, command in pairs(settings.tools) do
    if line:match(name) then
      vim.cmd(command)
    end
  end
end

local function center(dict)
  local centered = {}
  local space_left = vim.o.columns - string.len(dict[1])
  for _, line in ipairs(dict) do
    table.insert(centered, string.rep(" ", space_left/2) .. line)
  end
  return centered
end

local count = 1
local function set_lines(len, text, hi, pass)
  vim.api.nvim_buf_set_lines(0, count, count+len, false, center(text))
  vim.api.nvim_win_set_cursor(0, {count, 0})
  if pass then vim.g.section_length = count end
  for i=count,count+len do
    vim.api.nvim_buf_add_highlight(0, ns, hi, i, 1, -1)
  end
  count = count + len
end

local function empty()
  set_lines(1, {" "}, "TSString")
end

local function set_options()
  vim.api.nvim_buf_set_option(0, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(0, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(0, 'swapfile', false)
  vim.cmd[[set nonumber
  set norelativenumber
  ]]
end

function M.display()
  vim.api.nvim_buf_set_keymap(0, "n", "<CR>", ":lua require'startuptools'.check_line()<CR>", opts)
  vim.api.nvim_buf_set_keymap(0, "n", "j", "2j", opts)
  vim.api.nvim_buf_set_keymap(0, "n", "k", "2k", opts)
  -- vim.api.nvim_buf_set_keymap(0, "n", "h", "<NOP>", opts)
  -- vim.api.nvim_buf_set_keymap(0, "n", "l", "<NOP>", opts)
  empty()
  set_lines(#settings.header, settings.header, 'TSString')
  local toolnames = {}
  for name, _ in pairs(settings.tools) do
    table.insert(toolnames, " ")
    table.insert(toolnames, name)
  end
  empty()
  set_lines(#toolnames, toolnames, 'TSString')
  vim.cmd[[silent! %s/\s\+$//]] -- clear trailing whitespace
  set_options()
  vim.api.nvim_win_set_cursor(0,{#settings.header + 5,vim.o.columns/2})
end

function M.setup(update)
  settings = vim.tbl_deep_extend("force", settings, update or {})

  vim.cmd[[
  autocmd StdinReadPre * let s:std_in=1
  autocmd VimEnter * lua if vim.fn.argc() == 0 and vim.fn.exists('std_in') then require"startuptools".display() end
  ]]
end

return M
