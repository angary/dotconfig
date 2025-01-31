local M = {}

M.dev_mode = false
M.nvchad_theme = true
M.copilot_enabled = true
M.colorscheme = "catppuccin"
M.default_folds = false

-- Icons
M.diagnostics_icons = {
  Error = "",
  Warn = "",
  Hint = "󰍉",
  -- Hint = "",
  Info = "",
  VirtualText = "",
}

M.fileformat_icons = {
  unix = "",
  mac = "",
  dos = "",
}

return M
