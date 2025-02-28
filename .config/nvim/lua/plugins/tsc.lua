return {
  'dmmulroy/tsc.nvim',
  config = function()
    require('tsc').setup {
      run_as_monorepo = true,
      use_diagnostics = true,
      auto_open_qflist = false,
      flags = {
        noEmit = true,
      },
    }
  end,
}
