-- Helper functions
-- TODO: augroup (https://github.com/kazhala/dotfiles/blob/master/.config/nvim/lua/kaz/utils/au.lua), apply highlight group
local M = {}

-- Applies options to a meta-accessor
-- @param meta_accessor (table) vim meta-accessor, such as vim.opt
-- @param options (table) key-value table for settings to be applied
function M.vim_apply(meta_accessor, options)
  for k, v in pairs(options) do
    meta_accessor[k] = v
  end
end

-- Default options for keymap settings
local default_options = {
  noremap = true,
  silent = true,
  expr = false,
  script = false,
  buffer = false,
}

-- Registers a keymapping
-- @param bind (table) consisting of {
--    mode (positional, string)
--    before (positional, string)
--    after (positional, string)
--    noremap (optional keyword, boolean)
--    silent (optional keyword, boolean)
--    expr (optional keyword, boolean)
--    script (optional keyword, boolean)
--    buffer (optional keyword, boolean)
-- }
function M.map(bind)
  -- TODO: try to use which-key instead?
  -- HELPFUL: https://www.reddit.com/r/neovim/comments/rltfgz/using_inline_functions_with_nvim_set_keymap/
  -- Get options
  local mode, before, after = unpack(bind, 1, 3)

  local buffer = M.fallback_value(bind.buffer, default_options.buffer)
  local opts = {
    noremap = M.fallback_value(bind.noremap, default_options.noremap),
    silent = M.fallback_value(bind.silent, default_options.silent),
    expr = M.fallback_value(bind.expr, default_options.expr),
    script = M.fallback_value(bind.script, default_options.script),
  }

  -- Register keymap with specified options
  if buffer then
    vim.api.nvim_buf_set_keymap(0, mode, before, after, opts)
  else
    -- TODO: try which-key
    vim.api.nvim_set_keymap(mode, before, after, opts)
  end
end

-- Returns value or fallback (nullish coalescing)
-- @param value to be checked
-- @param fallback value which may be used
-- @param fallback_comparison used to compare with value, leave empty for default nil
function M.fallback_value(value, fallback, fallback_comparison)
  return (value == fallback_comparison and fallback) or value
end

-- Helper function for mimicking the ternary operator
-- @param condition
-- @param first
-- @param second
function M.ternary(condition, first, second)
  return (condition and first) or second
end

-- Debug printing
function M.display(...)
  print(vim.inspect(...))
end

-- Send a notification
-- NOTE: notify plugin accepts table as multi-line string, vim.notify has opts
function M.notify(...)
  local ok, notifier = pcall(require, "notify")
  if not ok then
    notifier = vim
  end
  notifier.notify(...)
end

-- Display path of current buffer
function M.display_path()
  M.notify(vim.fn.fnamemodify(vim.fn.expand("%"), ":p"), "info", {
    title = "path",
    render = "default",
  })
end

-- Display path of current working directory
function M.display_cwd()
  M.notify(vim.loop.cwd(), "info", {
    title = "cwd",
    render = "default",
  })
end

-- Get an attribute from a highlight group
-- @param group highlight group to be checked
-- @param attribute specific attribute from highlight group to be returned
function M.highlight_group_get(group, attribute)
  return vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(group)), attribute)
end

local signcolumn_enabled = true
function M.toggle_signcolumn()
  vim.o.signcolumn = M.ternary(signcolumn_enabled, "no", "auto")
  signcolumn_enabled = not signcolumn_enabled
end

-- vim.tbl_flatten limited to only once (top-level)
function M.list_flatten_once(list)
  local result = {}
  for _, t in ipairs(list) do
    for _, v in ipairs(t) do
      table.insert(result, v)
    end
  end
  return result
end

function M.get_os()
  return vim.loop.os_uname().sysname:lower():gsub("darwin", "mac")
end

function M.glob_split(pattern)
  return vim.split(vim.fn.glob(pattern), "\n")
end

function M.reload_module(...)
  local ok, plenary = pcall(require, "plenary.reload")
  if ok then
    plenary.reload_module(...)
  else
    M.notify("Could not reload module: " .. select(1, ...))
  end
end

return M