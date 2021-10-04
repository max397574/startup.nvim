local M = {}
local nb = vim.api.nvim_create_namespace('noiceboard')

local settings = {
  header = {
"                                          /$$              ",
"                                         |__/              ",
" /$$$$$$$   /$$$$$$   /$$$$$$  /$$    /$$ /$$ /$$$$$$/$$$$ ",
"| $$__  $$ /$$__  $$ /$$__  $$|  $$  /$$/| $$| $$_  $$_  $$",
"| $$  \\ $$| $$$$$$$$| $$  \\ $$ \\  $$/$$/ | $$| $$ \\ $$ \\ $$",
"| $$  | $$| $$_____/| $$  | $$  \\  $$$/  | $$| $$ | $$ | $$",
"| $$  | $$|  $$$$$$$|  $$$$$$/   \\  $/   | $$| $$ | $$ | $$",
"|__/  |__/ \\_______/ \\______/     \\_/    |__/|__/ |__/ |__/",
  }
}


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
    vim.api.nvim_buf_add_highlight(0, nb, hi, i, 1, -1)
  end
  count = count + len
end

function M.set_header()
  set_lines(#settings.header, settings.header, 'TSString')
end

return M
