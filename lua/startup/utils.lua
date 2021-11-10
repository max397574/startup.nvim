local U = {}
local flag = false
local new_cursor_pos
local help_window
-- local startup = require"startup"

---sets cursor to position in current window
---@param cursor table table in form {row,column}
local function set_cursor(cursor)
  vim.api.nvim_win_set_cursor(0, cursor)
end

local function bad_line()
  for _, line in ipairs(require("startup").good_lines) do
    if line == vim.trim(vim.api.nvim_get_current_line()) and line ~= "" then
      return false
    end
  end
  return true
end

U.cursor_pos = vim.api.nvim_win_get_cursor(0)

---returns string with specified amount of spaces
---@param amount number the amount of space to return
---@return string
function U.spaces(amount)
  return string.rep(" ", amount)
end

---open float with all the keybindings
function U.key_help()
  local settings = require("startup").settings
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  local lines = {
    "    Startup.nvim Mappings    ",
    "",
    " Execute command:    " .. settings.mappings.execute_command,
    " Open file:          " .. settings.mappings.open_file,
    " Open file in split: " .. settings.mappings.open_file_split,
    " Open section:       " .. settings.mappings.open_section,
    "",
  }
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  help_window = vim.api.nvim_open_win(buf, false, {
    relative = "cursor",
    width = 30,
    height = 6,
    col = 0,
    row = 1,
    border = "shadow",
    style = "minimal",
  })
  vim.api.nvim_win_set_option(help_window, "winblend", 20)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.cmd(
    [[autocmd CursorMoved * ++once lua require"startup.utils".close_help()]]
  )
end

---close the help window
function U.close_help()
  vim.api.nvim_win_close(help_window, false)
  -- vim.cmd([[autocmd! CursorMoved * lua require"startup.utils".close_help() ++once]])
end

---the default header
---@return table header strings with the default header
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

---get oldfiles
---@param amount number amount of oldfiles to return
---@return table oldfiles table with all the oldfiles in it
function U.get_oldfiles(amount)
  local oldfiles = { "Last files", "" }
  local oldfiles_raw = vim.fn.execute("oldfiles")
  local oldfiles_amount = 0
  for file in oldfiles_raw:gmatch("[^\n]+") do
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

---get oldfiles of current directory
---@param amount number amount of oldfiles to return
---@return table oldfiles table with all the oldfiles in it
function U.get_oldfiles_directory(amount)
  local oldfiles_raw = vim.fn.execute("oldfiles")
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

---return column on which cursor should be positioned
local column = function()
  local settings = require("startup").settings
  local column_calc
  if settings.options.cursor_column < 1 then
    column_calc = math.floor(vim.o.columns * settings.options.cursor_column)
  else
    column_calc = settings.options.cursor_column
  end
  return column_calc
end

---reposition cursor if cursor moved up
local function move_up()
  flag = true
  local i
  if new_cursor_pos[1] < U.cursor_pos[1] then
    if new_cursor_pos[1] == 1 then
      set_cursor(new_cursor_pos)
      i = 1
      while true do
        if not bad_line() then
          flag = false
          return
        end
        set_cursor({ new_cursor_pos[1] + i, column() })
        i = i + 1
      end
    else
      set_cursor(new_cursor_pos)
      i = 0
    end
  else
    set_cursor(U.cursor_pos)
    i = 1
  end
  while true do
    set_cursor({ new_cursor_pos[1] - i, column() })
    if not bad_line() then
      flag = false
      return
    end
    i = i + 1
    if new_cursor_pos[1] - i <= 1 then
      i = 1
      set_cursor({ 1, column() })
      while true do
        if not bad_line() then
          flag = false
          return
        end
        set_cursor({ new_cursor_pos[1] - 1  + i, column() })
        i = i + 1
      end
    end
  end
  flag = false
  return
end

---reposition cursor if cursor moved down
local function move_down()
  flag = true
  local i
  if new_cursor_pos[1] > U.cursor_pos[1] then
    if new_cursor_pos[1] == vim.api.nvim_buf_line_count(0) then
      set_cursor(new_cursor_pos)
      i = 1
      while true do
        if not bad_line() then
          flag = false
          return
        end
        set_cursor({ new_cursor_pos[1] - i, column() })
        i = i + 1
      end
      i = 0
    else
      set_cursor(new_cursor_pos)
      i = 0
    end
  else
    set_cursor(U.cursor_pos)
    i = 1
  end
  while true do
    set_cursor({ new_cursor_pos[1] + i, column() })
    if not bad_line() then
      flag = false
      return
    end
    i = i + 1
    if new_cursor_pos[1] + i >= vim.api.nvim_buf_line_count(0) then
      set_cursor(U.cursor_pos)
      flag = false
      return
    end
  end
  flag = false
  return
end

---reposition cursor after it moved
function U.reposition_cursor()
  if vim.o.filetype ~= "startup" or flag then
    return
  end
  new_cursor_pos = vim.api.nvim_win_get_cursor(0)
  if new_cursor_pos[1] > U.cursor_pos[1] then
    move_down()
  elseif
    (new_cursor_pos[1] < U.cursor_pos[1])
    or new_cursor_pos[2] < U.cursor_pos[2]
  then
    move_up()
  elseif
    (new_cursor_pos[1] > U.cursor_pos[1])
    or new_cursor_pos[2] > U.cursor_pos[2]
  then
    move_down()
  end
  U.cursor_pos = vim.api.nvim_win_get_cursor(0)
end

---return longest line length
---@param lines table
---@return number longest
function U.longest_line(lines)
  local longest = 0
  for _, line in ipairs(lines) do
    if vim.fn.strdisplaywidth(line) > longest then
      longest = vim.fn.strdisplaywidth(line)
    end
  end
  return longest
end

---set all the options that should be set for the startup buffer
function U.set_buf_options()
  local settings = require("startup").settings
  vim.api.nvim_buf_set_option(0, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(0, "buftype", "nofile")
  vim.cmd([[set wrap]])
  vim.defer_fn(function()
    if settings.options.disable_statuslines then
      vim.opt.laststatus = 0
      vim.opt.showtabline = 0
    end
  end,1
  )
  vim.api.nvim_buf_set_option(0, "filetype", "startup")
  vim.api.nvim_buf_set_option(0, "swapfile", false)
  vim.cmd([[setlocal nonu nornu]])
end

---validate the settings
---@param options table the settings for a section
function U.validate_settings(options)
  -- NOTE: vim.validate
  vim.validate({
    type = {
      options.type,
      function(arg)
        for _, v in ipairs({ "mapping", "oldfiles", "text" }) do
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
        for _, v in ipairs({ "right", "left", "center" }) do
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
    content = {
      options.content,
      function(content)
        if
          options.type == "text"
          and (type(content) == "table" or type(content) == "function")
        then
          return true
        elseif options.type == "mapping" and type(content) == "table" then
          return true
        elseif options.type == "oldfiles" then
          return true
        end
        return false
      end,
      "table for type=mapping and table or function for type=text",
    },
    default_color = { options.default_color, "string" },
    highlight = { options.highlight, "string" },
    oldfiles_amount = {
      options.oldfiles_amount,
      "number",
    },
  })
end

return U
