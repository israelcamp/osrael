return {
  {
    'navarasu/onedark.nvim',
    config = function()
      require('onedark').setup {
        style = 'dark',
      }
      -- Enable theme
      require('onedark').load()
    end,
  },
  {

    'scottmckendry/cyberdream.nvim',
    lazy = false,
    priority = 1000, -- make sure to load this before all the other start plugins
  },
  {
    'folke/tokyonight.nvim',
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('tokyonight').setup {
        styles = {
          comments = { italic = false }, -- Disable italics in comments
        },
      }
      vim.cmd.colorscheme 'onedark'
    end,
  },
}
