return {
  'sindrets/diffview.nvim',
  config = function()
    require('diffview').setup {
      enhanced_diff_hl = true, -- Better diff highlights
      view = {
        merge_tool = {
          -- Config for conflicted files in diff views during a merge or rebase.
          layout = 'diff3_mixed',
          -- disable_diagnostics = true, -- Temporarily disable diagnostics for diff buffers while in the view.
          -- winbar_info = true, -- See |diffview-config-view.x.winbar_info|
        },
      },
    }
  end,
}
