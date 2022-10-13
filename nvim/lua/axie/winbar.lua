local M = {}

local utils = require("axie.utils")
local ignored_filetypes = {
  "",
  "alpha",
  "neo-tree", -- NOTE: managed by neo-tree
  "toggleterm",
  "packer",
  "lspinfo",
  "null-ls-info",
  "glowpreview",
  "help",
  "man",
  "prompt",
  "mason",
  "aerial",
  "checkhealth",
}

local function decorate(hl_group, content)
  return string.format("%%#%s#%s%%*", hl_group, content)
end

local function clickable(callback, content)
  callback = "v:lua.require'axie.winbar'." .. callback
  return string.format("%%0@%s@%s%%T", callback, content)
end

function M.file_icon()
  local filetype = vim.fn.expand("%:p:e")
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if ok then
    local icon = devicons.get_icon(nil, filetype)
    if icon then
      return icon
    end
  end
  return ""
end

function M.file_name()
  return vim.fn.expand("%:p:t")
end

-- REFERENCE: nvim-navic
local kind_icons = {
  File = "",
  Module = "",
  Namespace = "",
  Package = "",
  Class = "",
  Method = "",
  Property = "",
  Field = "",
  Constructor = "",
  Enum = "",
  Interface = "",
  Function = "",
  Variable = "",
  Constant = "",
  String = "",
  Number = "",
  Boolean = "◩",
  Array = "",
  Object = "",
  Key = "",
  Null = "ﳠ",
  EnumMember = "",
  Struct = "",
  Event = "",
  Operator = "",
  TypeParameter = "",
  Macro = "",
}

local show_context = true

function M.toggle_context()
  show_context = not show_context
end

function M.context()
  if not show_context then
    return ""
  end

  local ok, aerial = pcall(require, "aerial")
  if not ok then
    return ""
  end

  local symbols = aerial.get_location(false)
  local context = vim.fn.join(
    vim.tbl_map(function(symbol)
      return decorate("NavicIcons" .. symbol.kind, kind_icons[symbol.kind])
        .. " "
        .. decorate("NavicText", symbol.name:gsub("<Anonymous>", "-"))
    end, symbols),
    "  "
  )
  return utils.ternary(context ~= "", decorate("NavicSeparator", ":: ") .. context, "")
end

local focused_win = vim.api.nvim_get_current_win()

function M.eval()
  local is_nc = focused_win ~= vim.api.nvim_get_current_win()
  local file_hl = "NavicIconsFile" .. utils.ternary(is_nc, "NC", "")
  local modified = vim.api.nvim_buf_get_option(0, "modified")

  local _, value = pcall(function()
    local components = {
      { "WinBarModified", modified and "*" or "" },
      { file_hl, M.file_icon() },
      { file_hl, clickable("toggle_context", M.file_name()) },
    }
    if not is_nc then
      table.insert(components, { "WinBarContext", M.context() })
    end

    return vim.fn.join(
      vim.tbl_map(function(component)
        if type(component) == "table" then
          return decorate(unpack(component))
        else
          return component
        end
      end, components),
      " "
    )
  end)
  return value
end

function M.activate()
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = vim.api.nvim_create_augroup("WinBarGroup", {}),
    callback = function()
      vim.schedule(function()
        if not vim.tbl_contains(ignored_filetypes, vim.bo.filetype) then
          vim.wo.winbar = "%{%v:lua.require'axie.winbar'.eval()%}"
        end
        focused_win = vim.api.nvim_get_current_win()
      end)
    end,
  })
  vim.schedule(function()
    local float_bg = vim.api.nvim_get_hl_by_name("NormalFloat", true).background
    vim.api.nvim_set_hl(0, "WinBar", { bg = float_bg })
    vim.api.nvim_set_hl(0, "WinBarNC", { bg = float_bg })
    local bufferline_modified_fg = vim.api.nvim_get_hl_by_name("BufferCurrentMod", true).foreground
    vim.api.nvim_set_hl(0, "WinBarModified", { fg = bufferline_modified_fg, bg = float_bg })
    vim.api.nvim_set_hl(0, "NavicIconsFileNC", { fg = "#f2cdcd", bg = float_bg })
  end)
end

return M
