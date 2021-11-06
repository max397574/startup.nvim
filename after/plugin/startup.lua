vim.defer_fn(function()
  if vim.bo.ft == "startup" then
    require"startup.utils".set_buf_options()
  end
end,1)
