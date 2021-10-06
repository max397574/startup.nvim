U = {}
local colors = require("startup.config").colors

function U.spaces(amount)
  return string.rep(" ", amount)
end

function U.longest_line(lines)
  local longest = 0
  for _, line in ipairs(lines) do
    if line:len() > longest then
      longest = line:len()
    end
  end
  return longest
end

function U.create_hls()
  vim.cmd( "hi StartupHeading guifg=" .. colors.heading_fg)
  vim.cmd( "hi StartupTools guifg=" .. colors.tools_fg)
end

function U.set_buf_options()
  vim.api.nvim_buf_set_option(0, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(0, "buftype", "nofile")
  vim.api.nvim_buf_set_option(0, "filetype", "dashboard")
  vim.api.nvim_buf_set_option(0, "swapfile", false)
  vim.cmd [[setlocal nonu nornu]]
end

return U
