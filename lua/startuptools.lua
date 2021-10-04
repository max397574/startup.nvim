local M = {}
local nb = vim.api.nvim_create_namespace('noiceboard')

local settings = {
  header = {
    " ▄▄▄█████▓    ▄▄▄          ▄▄▄██▀▀▀ ",
    " ▓  ██▒ ▓▒   ▒████▄          ▒██    ",
    " ▒ ▓██░ ▒░   ▒██  ▀█▄        ░██    ",
    " ░ ▓██▓ ░    ░██▄▄▄▄██    ▓██▄██▓   ",
    "   ▒██▒ ░     ▓█   ▓██▒    ▓███▒    ",
    "   ▒ ░░       ▒▒   ▓▒█░    ▒▓▒▒░    ",
    "     ░         ▒   ▒▒ ░    ▒ ░▒░    ",
    "   ░           ░   ▒       ░ ░ ░    ",
    "                   ░  ░    ░   ░    ",
  }
}


local function center(dict)
  local centered = {}
  for _, line in ipairs(dict) do
    local space_left = vim.o.columns - string.len(line)
    table.insert(centered, string.rep(" ", space_left) .. line)
    space_left = 0
  end
  return centered
end

function M.print_header()
  dump(center(settings.header))
end

local count = 1
local function set_lines(len, text, hi, pass)
  vim.api.nvim_buf_set_lines(0, count, count+len, false, center(text))
  vim.api.nvim_win_set_cursor(0, {count, 0})
  if pass then vim.g.section_length = count end
  for i=count,count+len do
    vim.api.nvim_buf_add_highlight(0, nb, hi, i, 1, -1)
  end
  count = count + len
end

function M.set_header()
  set_lines(#settings.header, settings.header, 'TSString')
end

function M.setup()
  vim.cmd("command! -bang -nargs=0 StartuptoolsHeader :lua require('startuptools').set_header()")
end

return M
