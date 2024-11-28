return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    -- format_on_save = function(bufnr)
    --   -- Disable "format_on_save lsp_fallback" for languages that don't
    --   -- have a well standardized coding style. You can add additional
    --   -- languages here or re-enable it for the disabled ones.
    --   local disable_filetypes = { c = true, cpp = true }
    --   local lsp_format_opt
    --   if disable_filetypes[vim.bo[bufnr].filetype] then
    --     lsp_format_opt = 'never'
    --   else
    --     lsp_format_opt = 'fallback'
    --   end
    --   return {
    --     timeout_ms = 500,
    --     lsp_format = lsp_format_opt,
    --   }
    format_on_save = {
      lsp_fallback = true,
      async = false,
      timeout_ms = 500,
    }, -- end,
    formatters_by_ft = {
      css = { { 'prettied', 'prettier' } },
      graphql = { { 'prettied', 'prettier' } },
      html = { { 'prettied', 'prettier' } },
      javascript = { { 'prettied', 'prettier' } },
      javascriptreact = { { 'prettied', 'prettier' } },
      json = { { 'prettied', 'prettier' } },
      lua = { 'stylua' },
      markdown = { { 'prettied', 'prettier' } },
      python = { 'isort', 'black' },
      sql = { 'sql-formatter' },
      svelte = { { 'prettied', 'prettier' } },
      typescript = { { 'prettied', 'prettier', 'sql-formatter' } },
      typescriptreact = { { 'prettied', 'prettier' } },
      yaml = { 'prettier' },
      liquid = { 'prettier' },
    },
  },
}
