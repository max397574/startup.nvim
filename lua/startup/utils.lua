U = {}
local flag = false
local settings = require "startup.config"
local function start_timeout()
  flag = true
  vim.defer_fn(function()
    flag = false
  end, 150)
end

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

function U.key_help()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_keymap(
    buf,
    "n",
    "<ESC>",
    "<cmd>q<CR>",
    { noremap = true, silent = true, nowait = true }
  )
  vim.api.nvim_buf_set_keymap(
    buf,
    "n",
    "q",
    "<cmd>q<CR>",
    { noremap = true, silent = true, nowait = true }
  )
  local lines = {
    "startup.nvim mapping:",
    "",
    "Execute command: " .. settings.mappings.execute_command,
    "Open file: " .. settings.mappings.open_file,
    "Open file in split: " .. settings.mappings.open_file_split,
    "Open section: " .. settings.mappings.open_section,
  }
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "cursor",
    width = 30,
    height = 6,
    col = 1,
    row = 1,
    border = "shadow",
    style = "minimal",
  })
  vim.api.nvim_win_set_option(win, "winblend", 20)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
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
  local directory = vim.api.nvim_exec([[pwd]], true)
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

-- BUG: weird behavior when displaywidth != strlen
function U.reposition_cursor()
  if vim.o.filetype ~= "startup" or flag then
    return
  end
  local column = math.floor(vim.o.columns / 2)
  local new_cursor_pos = vim.api.nvim_win_get_cursor(0)
  if
      -- current line is not empty and cursor is on correct column
      -- moved straight up or down
    vim.trim(vim.api.nvim_get_current_line())
      ~= ""
    and new_cursor_pos[2] == column
  then
    start_timeout()
    return
  elseif
      -- moved to the right
    vim.trim(vim.api.nvim_get_current_line())
      ~= ""
    and new_cursor_pos[2] > column
    and new_cursor_pos[1] == U.cursor_pos[1]
  then
    if new_cursor_pos[1] == vim.api.nvim_buf_line_count(0) then
      vim.api.nvim_win_set_cursor(0, { new_cursor_pos[1], column })
      start_timeout()
      return
    end
    local i = 1
    vim.api.nvim_win_set_cursor(0, { new_cursor_pos[1] + i, column })
    while vim.trim(vim.api.nvim_get_current_line()) == "" do
      vim.api.nvim_win_set_cursor(0, { new_cursor_pos[1] + i, column })
      i = i + 1
    end
    start_timeout()
  elseif
      -- moved to the left
    vim.trim(vim.api.nvim_get_current_line())
      ~= ""
    and new_cursor_pos[2] < column
    and new_cursor_pos[1] == U.cursor_pos[1]
  then
    local i = 1
    if new_cursor_pos[1] == 1 then
      vim.api.nvim_win_set_cursor(0, { new_cursor_pos[1], column })
      start_timeout()
      return
    end
    vim.api.nvim_win_set_cursor(0, { new_cursor_pos[1] - i, column })
    while vim.trim(vim.api.nvim_get_current_line()) == "" do
      if new_cursor_pos[1] - i == 1 then
        vim.api.nvim_win_set_cursor(0, { new_cursor_pos[1], column })
        start_timeout()
        return
      end
      vim.api.nvim_win_set_cursor(0, { new_cursor_pos[1] - i, column })
      i = i + 1
    end
    start_timeout()
  elseif
      -- moved up to empty line
    vim.trim(vim.api.nvim_get_current_line())
      == ""
    and new_cursor_pos[1] < U.cursor_pos[1]
  then
    if new_cursor_pos[1] == 1 then
      vim.api.nvim_win_set_cursor(0, { new_cursor_pos[1], column })
      start_timeout()
      return
    end
    local i = 1
    vim.api.nvim_win_set_cursor(0, { new_cursor_pos[1] - i, column })
    while vim.trim(vim.api.nvim_get_current_line()) == "" do
      vim.api.nvim_win_set_cursor(0, { new_cursor_pos[1] - i, column })
      i = i + 1
    end
    start_timeout()
  elseif
      -- moved down to empty line
    vim.trim(vim.api.nvim_get_current_line())
      == ""
    and new_cursor_pos[1] > U.cursor_pos[1]
  then
    local i = 1
    vim.api.nvim_win_set_cursor(0, { new_cursor_pos[1] + i, column })
    while vim.trim(vim.api.nvim_get_current_line()) == "" do
      vim.api.nvim_win_set_cursor(0, { new_cursor_pos[1] + i, column })
      i = i + 1
    end
    start_timeout()
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

function U.validate_settings(options)
  -- NOTE: vim.validate
  vim.validate {
    type = {
      options.type,
      function(arg)
        for _, v in ipairs { "mapping", "oldfiles", "text" } do
          if v == arg then
            return true
          end
        end
        return false
      end,
      '"mapping" "text" or "oldfiles"',
    },
    oldfiles_directory = {
      options.oldfiles_directory,
      "boolean",
    },
    align = {
      options.align,
      function(arg)
        for _, v in ipairs { "right", "left", "center" } do
          if v == arg then
            return true
          end
        end
        return false
      end,
      '"center" "left" or "right"',
    },
    fold_section = { options.fold_section, "boolean" },
    title = { options.title, "string" },
    margin = { options.margin, "number" },
    command = { options.command, "string" },
    content = {options.content,
    function(content)
      if options.type =="text" and (type(content)== "table" or type(content == "function")) then
        return true
      elseif options.type == "mapping" and type(content) == "table" then
        return true
      end
    end},
    default_color = { options.default_color, "string" },
    highlight = { options.highlight, "string" },
    oldfiles_amount = {
      options.oldfiles_amount,
      "number",
    },
  }
end

return U
