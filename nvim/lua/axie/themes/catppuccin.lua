-- https://github.com/catppuccin/nvim --

return function()
  local catppuccin = require("catppuccin")
  catppuccin.setup({
    transparent_background = true,
    integrations = {
      lsp_trouble = true,
      cmp = true,
      lsp_saga = true,
      gitgutter = false,
      gitsigns = true,
      telescope = true,
      neotree = {
        enabled = true,
        show_root = false,
        transparent_panel = true,
      },
      which_key = true,
      indent_blankline = {
        enabled = true,
        colored_indent_levels = false,
      },
      dashboard = true,
      neogit = true,
      vim_sneak = true,
      fern = true,
      barbar = true,
      bufferline = true,
      markdown = true,
      lightspeed = true,
      ts_rainbow = true,
      hop = true,
      notify = true,
      telekasten = true,
    },
  })

  -- highlight group overrides
  local cp = require("catppuccin.api.colors").get_colors()
  catppuccin.remap({
    NormalFloat = { bg = cp.black2 }, -- NOTE: catppuccin needs a bg colour
    ColorColumn = { link = "CursorLine" },
    CursorLineNr = { fg = cp.magenta },
    WhichKeyFloat = { link = "NormalFloat" },
    SpellBad = { fg = cp.red, style = "italic,undercurl" },
    SpellCap = { fg = cp.red, style = "italic,undercurl" },
    SpellLocal = { fg = cp.red, style = "italic,undercurl" },
    SpellRare = { fg = cp.red, style = "italic,undercurl" },
    -- SpellBad = { fg = cp.maroon },
    -- SpellCap = { fg = cp.peach },
    -- SpellLocal = { fg = cp.lavender },
    -- SpellRare = { fg = cp.teal },
  })

  vim.cmd("colorscheme catppuccin")
end
