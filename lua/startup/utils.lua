U = {}
-- local colors = require("startup.config").colors
local colors = {
  background = "#1f2227",
  heading_fg = "#009900",
  tools_fg = "#009900",
}

U.cursor_pos = vim.api.nvim_win_get_cursor(0)

function U.spaces(amount)
  return string.rep(" ", amount)
end

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

function U.get_oldfiles(amount)
  local oldfiles = { "Last files", "" }
  local oldfiles_raw = vim.fn.execute "oldfiles"
  local oldfiles_amount = 0
  for file in oldfiles_raw:gmatch "[^\n]+" do
    if oldfiles_amount >= amount then
      break
    end
    table.insert(oldfiles, (string.sub(file, 4, -1)))
    oldfiles_amount = oldfiles_amount + 1
  end
  local length = U.longest_line(oldfiles) + 2
  local oldfiles_aligned = {}
  for _, file in ipairs(oldfiles) do
    table.insert(oldfiles_aligned, file .. U.spaces(length - #file))
  end
  return oldfiles_aligned
end

function U.get_oldfiles_directory(amount)
  local oldfiles_raw = vim.fn.execute "oldfiles"
  local oldfiles_amount = 0
  local directory = vim.api.nvim_exec([[!pwd]], true)
  directory = string.sub(directory, 9, -2)
  local oldfiles = { "Last files in " .. directory, " " }
  for file in oldfiles_raw:gmatch(directory .. "[^\n]+") do
    if oldfiles_amount >= amount then
      break
    end
    table.insert(oldfiles, (string.sub(file, 1, -1)))
    oldfiles_amount = oldfiles_amount + 1
  end
  local length = U.longest_line(oldfiles) + 2
  local oldfiles_aligned = {}
  for _, file in ipairs(oldfiles) do
    table.insert(oldfiles_aligned, file .. U.spaces(length - #file))
  end
  return oldfiles_aligned
end

-- BUG: check if cursor could get out of bounds
function U.reposition_cursor()
  if vim.o.filetype ~= "startup" then
    return
  end
  local column = math.floor(vim.o.columns / 2)
  local new_cursor_pos = vim.api.nvim_win_get_cursor(0)
  if
    vim.trim(vim.api.nvim_get_current_line()) ~= ""
    and new_cursor_pos[2] == column
  then
    print "returned"
    return
  elseif
    vim.trim(vim.api.nvim_get_current_line()) ~= ""
    and new_cursor_pos[2] > column
    and new_cursor_pos[1] == U.cursor_pos[1]
  then
    local i = 1
    vim.api.nvim_win_set_cursor(0, { new_cursor_pos[1] + i, column })
    while vim.trim(vim.api.nvim_get_current_line()) == "" do
      vim.api.nvim_win_set_cursor(0, { new_cursor_pos[1] + i, column })
      i = i + 1
    end
  elseif
    vim.trim(vim.api.nvim_get_current_line()) ~= ""
    and new_cursor_pos[2] < column
    and new_cursor_pos[1] == U.cursor_pos[1]
  then
    local i = 1
    vim.api.nvim_win_set_cursor(0, { new_cursor_pos[1] - i, column })
    while vim.trim(vim.api.nvim_get_current_line()) == "" do
      vim.api.nvim_win_set_cursor(0, { new_cursor_pos[1] - i, column })
      i = i + 1
    end
  elseif
    vim.trim(vim.api.nvim_get_current_line()) == ""
    and new_cursor_pos[1] < U.cursor_pos[1]
  then
    local i = 1
    vim.api.nvim_win_set_cursor(0, { new_cursor_pos[1] - i, column })
    while vim.trim(vim.api.nvim_get_current_line()) == "" do
      vim.api.nvim_win_set_cursor(0, { new_cursor_pos[1] - i, column })
      i = i + 1
    end
  elseif
    vim.trim(vim.api.nvim_get_current_line()) == ""
    and new_cursor_pos[1] > U.cursor_pos[1]
  then
    local i = 1
    vim.api.nvim_win_set_cursor(0, { new_cursor_pos[1] + i, column })
    while vim.trim(vim.api.nvim_get_current_line()) == "" do
      vim.api.nvim_win_set_cursor(0, { new_cursor_pos[1] + i, column })
      i = i + 1
    end
  end

  U.cursor_pos = vim.api.nvim_win_get_cursor(0)
end

function U.longest_line(lines)
  local longest = 0
  for _, line in ipairs(lines) do
    if vim.fn.strdisplaywidth(line) > longest then
      longest = vim.fn.strdisplaywidth(line)
    end
  end
  return longest
end

function U.create_hls()
  vim.cmd("hi StartupHeading guifg=" .. colors.heading_fg)
  vim.cmd("hi StartupTools guifg=" .. colors.tools_fg)
end

function U.set_buf_options()
  vim.api.nvim_buf_set_option(0, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(0, "buftype", "nofile")
  vim.cmd [[set nowrap]]
  vim.api.nvim_buf_set_option(0, "filetype", "startup")
  vim.api.nvim_buf_set_option(0, "swapfile", false)
  vim.cmd [[setlocal nonu nornu]]
end

return U
