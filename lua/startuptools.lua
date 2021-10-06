local M = {}
local ns = vim.api.nvim_create_namespace "startuptools"

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
    [" Find File"] = {"Telescope find_files", "<leader>ff"},
    [" Find Word"] = {"Telescope live_grep", "<leader>lg"},
    [" Recent Files"] = {"Telescope oldfiles", "<leader>of"},
    [" File Browser"] = {"Telescope file_browser", "<leader>fb"},
    [" Config Files"] = {'lua require("telescope.builtin").find_files({cwd="~/.config"})', "<leader>cf"},
    [" Colorschemes"] = {"Telescope colorscheme", "<leader>cs"},
    [" New File"] = {"lua require'startuptools'.new_file()", "<leader>nf"},
    ["ﲉ Help Files"] = {"Telescope help_tags", "<leader>fh"},
  },
  options = {
    align = "center", -- center or padding
    mapping_names = true,
    padding = 5, -- only used if align padding
  },
  colors = {
    background = "#1f2227",
    heading_fg = "#009900",
    tools_fg = "#009900",
  }
}

local function spaces(amount)
  return string.rep(" ", amount)
end

local function longest_line(lines)
  local longest = 0
  for _, line in ipairs(lines) do
    if line:len() > longest then
      longest = line:len()
    end
  end
  return longest
end

local function create_mappings()
  vim.api.nvim_buf_set_keymap(
    0,
    "n",
    "<CR>",
    ":lua require'startuptools'.check_line()<CR>",
    opts
  )
  for _, cmd in pairs(settings.tools) do
    vim.api.nvim_buf_set_keymap(0, "n", cmd[2], "<cmd>"..cmd[1].."<CR>", opts)
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

local function create_hls()
  vim.cmd('highlight StartuptoolsHeading guibg=' .. settings.colors.background .. ' guifg=' .. settings.colors.heading_fg)
  vim.cmd('highlight StartuptoolsTools guibg=' .. settings.colors.background .. ' guifg=' .. settings.colors.tools_fg)
end

local function align(dict)
  local aligned = {}
  if settings.options.align == "center" then
    local max_len = longest_line(dict)
    local space_left = vim.o.columns - max_len
    for _, line in ipairs(dict) do
      table.insert(aligned, spaces(space_left/2).. line)
    end
  elseif settings.options.align == "padding" then
    for _, line in ipairs(dict) do
      table.insert(aligned, spaces(settings.options.padding).. line)
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
  set_lines(1, { " " }, "StartuptoolsTools")
end

local function set_options()
  vim.api.nvim_buf_set_option(0, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(0, "buftype", "nofile")
  vim.api.nvim_buf_set_option(0, "swapfile", false)
  vim.cmd [[set nonumber
  set norelativenumber
  ]]
end

function M.display()
  local limited_space = false
  local rly_limited_space = false
  if vim.o.lines < (#settings.header + (#settings.tools*2) + 20) then
    limited_space = true
  end
  create_mappings()
  create_hls()
  vim.api.nvim_buf_set_keymap(0, "n", "j", "2j", opts)
  vim.api.nvim_buf_set_keymap(0, "n", "k", "2k", opts)
  if not limited_space then
    empty()
  end
  set_lines(#settings.header, settings.header, "StartuptoolsHeading")
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
  empty()
  set_lines(#toolnames, toolnames, "StartuptoolsTools")
  vim.cmd [[silent! %s/\s\+$//]] -- clear trailing whitespace
  set_options()
  if limited_space then
    vim.api.nvim_win_set_cursor(0, {#settings.header + 3, math.floor(vim.o.columns/2)})
  end
end

function M.setup(update)
  settings = vim.tbl_deep_extend("force", settings, update or {})
  vim.cmd [[
  autocmd StdinReadPre * let s:std_in=1
  autocmd VimEnter * lua if vim.fn.argc() == 0 and vim.fn.exists('std_in') then require"startuptools".display() end
  ]]
end

return M
