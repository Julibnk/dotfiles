return {
  'nvim-lualine/lualine.nvim',
  dependencies = {
    {
      'bwpge/lualine-pretty-path',
      -- dev = true,
    },
  },
  config = function(_, opts)
    local lazy_status = require 'lazy.status' -- to configure lazy pending updates count

    --- From: https://github.com/nvim-lualine/lualine.nvim/wiki/Component-snippets
    --- @param trunc_width number trunctates component when screen width is less then trunc_width
    --- @param trunc_len number truncates component to trunc_len number of chars
    --- @param hide_width number hides component when window width is smaller then hide_width
    --- @param no_ellipsis boolean whether to disable adding '...' at end after truncation
    --- return function that can format the component accordingly
    local function trunc(trunc_width, trunc_len, hide_width, no_ellipsis)
      return function(str)
        local win_width = vim.fn.winwidth(0)
        if hide_width and win_width < hide_width then
          return ''
        elseif trunc_width and trunc_len and win_width < trunc_width and #str > trunc_len then
          return str:sub(1, trunc_len) .. (no_ellipsis and '' or '…')
        end
        return str
      end
    end

    -- Show LSP status, borrowed from Heirline cookbook
    -- https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md#lsp
    local function lsp_status_all()
      local haveServers = false
      local names = {}
      for _, server in pairs(vim.lsp.get_clients { bufnr = 0 }) do
        -- msg = ' '
        haveServers = true
        table.insert(names, server.name)
      end
      if not haveServers then
        return ''
      end
      -- return ' ' .. table.concat(names, ',')
      return ' '
    end

    -- Override 'encoding': Don't display if encoding is UTF-8.
    local encoding_only_if_not_utf8 = function()
      local ret, _ = (vim.bo.fenc or vim.go.enc):gsub('^utf%-8$', '')
      return ret
    end
    -- fileformat: Don't display if &ff is unix.
    local fileformat_only_if_not_unix = function()
      local ret, _ = vim.bo.fileformat:gsub('^unix$', '')
      return ret
    end

    opts = {
      options = {
        ignore_focus = { 'trouble' },
      },
      sections = {
        lualine_a = {
          {
            'mode',
            fmt = trunc(130, 3, 0, true),
          },
        },
        lualine_b = {
          {
            'branch',
            fmt = trunc(70, 15, 65, true),
            separator = '',
          },

          {
            'diff',
            symbols = {
              added = ' ',
              modified = ' ',
              removed = ' ',
            },
            fmt = trunc(0, 0, 60, true),
          },
          {
            'diagnostics',
            -- symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' },
            symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
          },
        },
        lualine_c = {
          {
            'pretty_path',
            providers = {
              -- default = require 'util/pretty_path_harpoon',
            },
            directories = {
              max_depth = 4,
            },
            highlights = {
              newfile = 'LazyProgressDone',
            },
            separator = '',
          },
        },
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = '#ff9e64' },
            fmt = trunc(0, 0, 160, true), -- hide when window is < 100 columns
            separator = '',
          },

          -- require('util.lualine').cmp_source('supermaven', '󰰣'),

          {
            lsp_status_all,
            fmt = trunc(0, 8, 140, false),
            separator = '',
          },
          {
            encoding_only_if_not_utf8,
            fmt = trunc(0, 0, 140, true), -- hide when window is < 80 columns
            separator = '',
          },
          {
            fileformat_only_if_not_unix,
            fmt = trunc(0, 0, 140, true), -- hide when window is < 80 columns
            separator = '',
          },
        },
        lualine_y = {
          { 'progress', fmt = trunc(0, 0, 40, true) },
        },
        lualine_z = {
          { 'location', fmt = trunc(0, 0, 80, true) },
        },
      },
      inactive_sections = {
        lualine_c = {
          {
            'pretty_path',
            -- 'filename',
            symbols = {
              modified = '+', -- Text to show when the file is modified.
              readonly = '', -- Text to show when the file is non-modifiable or readonly.
            },
          },
        },
      },
      extensions = {
        'fzf',
        'lazy',
        'mason',
        'neo-tree',
        'nvim-dap-ui',
        'oil',
        'quickfix',
        'trouble',
      },
    }

    require('lualine').setup(opts)
  end,
}
