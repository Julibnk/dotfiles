return {
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      CustomOilBar = function()
        local path = vim.fn.expand '%'
        path = path:gsub('oil://', '')

        return '  ' .. vim.fn.fnamemodify(path, ':.')
      end
      local oil = require 'oil'

      oil.setup {
        columns = { 'icon' },
        keymaps = {
          ['l'] = { 'actions.select', mode = 'n' },
          ['h'] = { 'actions.parent', mode = 'n' },
          ['-'] = 'actions.close',
          ['<C-h>'] = false,
          ['<C-l>'] = false,
          ['<C-k>'] = false,
          ['<C-j>'] = false,
          ['<M-h>'] = 'actions.select_split',
        },
        win_options = {
          winbar = '%{v:lua.CustomOilBar()}',
        },
        view_options = {
          show_hidden = true,
        },
      }
      -- Open parent directory in current window
      vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
      -- Open oil in preview mode
      -- vim.keymap.set('n', '-', function()
      --   oil.open()
      --   -- Wait until oil has opened, for a maximum of 1 second.
      --   vim.wait(1000, function()
      --     return oil.get_cursor_entry() ~= nil
      --   end)
      --   if oil.get_cursor_entry() then
      --     oil.open_preview()
      --   end
      -- end)
      -- Open parent directory in floating window
      -- vim.keymap.set('n', '<space>-', require('oil').toggle_float)
    end,
  },
}
