local js_based_languages = {
  'typescript',
  'javascript',
  'typescriptreact',
  'javascriptreact',
  'vue',
  'svelte',
}
return {
  'mfussenegger/nvim-dap',
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'
    local dap_vt = require 'nvim-dap-virtual-text'
    local dap_utils = require 'dap.utils'
    dap.set_log_level 'TRACE'
    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- ╭──────────────────────────────────────────────────────────╮
    -- │ DAP Virtual Text Setup                                   │
    -- ╰──────────────────────────────────────────────────────────╯
    dap_vt.setup {
      enabled = true, -- enable this plugin (the default)
      enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
      highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
      highlight_new_as_changed = false, -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
      show_stop_reason = true, -- show stop reason when stopped for exceptions
      commented = false, -- prefix virtual text with comment string
      only_first_definition = true, -- only show virtual text at first definition (if there are multiple)
      all_references = false, -- show virtual text on all all references of the variable (not only definitions)
      filter_references_pattern = '<module', -- filter references (not definitions) pattern when all_references is activated (Lua gmatch pattern, default filters out Python modules)
      -- Experimental Features:
      virt_text_pos = 'eol', -- position of virtual text, see `:h nvim_buf_set_extmark()`
      all_frames = false, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
      virt_lines = false, -- show virtual lines instead of virtual text (will flicker!)
      virt_text_win_col = nil, -- position the virtual text at a fixed window column (starting from the first text column) ,
    }
    -- Enable virtual text
    vim.g.dap_virtual_text = true

    -- ╭──────────────────────────────────────────────────────────╮
    -- │ Icons                                                    │
    -- ╰──────────────────────────────────────────────────────────╯
    -- vim.fn.sign_define('DapBreakpoint', { text = '🟥', texthl = '', linehl = '', numhl = '' })
    -- vim.fn.sign_define('DapStopped', { text = '⭐️', texthl = '', linehl = '', numhl = '' })

    vim.fn.sign_define('DapBreakpoint', { text = ' ', texthl = '', linehl = '', numhl = '' })
    vim.fn.sign_define('LogPoint', { text = '.>', texthl = '', linehl = '', numhl = '' })
    vim.fn.sign_define('DapBreakpointCondition', { text = ' ', texthl = '', linehl = '', numhl = '' })
    vim.fn.sign_define('DapBreakpointRejected', { text = ' ', texthl = '', linehl = '', numhl = '' })
    vim.fn.sign_define('DapStopped', { text = '󰁕 ', texthl = '', linehl = '', numhl = '' })
    -- ╭──────────────────────────────────────────────────────────╮
    -- │ Adapters                                                 │
    -- ╰──────────────────────────────────────────────────────────╯
    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }

    -- Python specific config
    require('dap-python').setup 'python3'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
      },
    }
    -- ╭──────────────────────────────────────────────────────────╮
    -- │ Configurations                                           │
    -- ╰──────────────────────────────────────────────────────────╯
    for _, language in ipairs(js_based_languages) do
      dap.configurations[language] = {
        -- Debug web applications (client side)
        {
          type = 'pwa-chrome',
          request = 'launch',
          name = 'Launch & Debug Chrome',
          url = function()
            local co = coroutine.running()
            return coroutine.create(function()
              vim.ui.input({
                prompt = 'Enter URL: ',
                default = 'http://localhost:5173',
              }, function(url)
                if url == nil or url == '' then
                  return
                else
                  coroutine.resume(co, url)
                end
              end)
            end)
          end,
          webRoot = vim.fn.getcwd(),
          protocol = 'inspector',
          sourceMaps = true,
          userDataDir = false,
        },
        -- Debug single nodejs files
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch file',
          program = '${file}',
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
        },
        -- Debug nodejs processes (make sure to add --inspect when you run the process)
        {
          type = 'pwa-node',
          request = 'attach',
          name = 'Attach',
          processId = require('dap.utils').pick_process,
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
        },

        -- Debug web applications (client side)
        -- {
        --   type = 'pwa-chrome',
        --   request = 'launch',
        --   name = 'Launch & Debug Brave',
        --   url = function()
        --     local co = coroutine.running()
        --     return coroutine.create(function()
        --       vim.ui.input({
        --         prompt = 'Enter URL: ',
        --         default = 'http://localhost:5173',
        --       }, function(url)
        --         if url == nil or url == '' then
        --           return
        --         else
        --           coroutine.resume(co, url)
        --         end
        --       end)
        --     end)
        --   end,
        --   webRoot = vim.fn.getcwd(),
        --   runtimeExecutable = '/Applications/Brave Browser.app/Contents/MacOS/Brave Browser',
        --   runtimeArgs = { '--remote-debugging-port=9222' },
        --   protocol = 'inspector',
        --   sourceMaps = true,
        --   userDataDir = false,
        -- },
        -- Divider for the launch.json derived configs
        {
          name = '----- ↓ launch.json configs ↓ -----',
          type = '',
          request = 'launch',
        },
      }
    end
  end,
  keys = function(_, keys)
    local dap = require 'dap'
    local dapui = require 'dapui'
    return {
      -- Basic debugging keymaps, feel free to change to your liking!
      { '<F5>', dap.continue, desc = 'Debug: Start/Continue' },
      { '<F1>', dap.step_into, desc = 'Debug: Step Into' },
      { '<F2>', dap.step_over, desc = 'Debug: Step Over' },
      { '<F3>', dap.step_out, desc = 'Debug: Step Out' },
      { '<leader>db', dap.toggle_breakpoint, desc = 'Debug: Toggle Breakpoint' },
      {
        '<leader>dB',
        function()
          dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end,
        desc = 'Debug: Set Breakpoint',
      },
      -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
      { '<F7>', dapui.toggle, desc = 'Debug: See last session result.' },
      unpack(keys),
    }
  end,
  dependencies = {
    -- DAP UI
    {
      'rcarriga/nvim-dap-ui',
      keys = {
        {
          '<leader>du',
          function()
            require('dapui').toggle {}
          end,
          desc = 'Dap UI',
        },
        {
          '<leader>de',
          function()
            require('dapui').eval()
          end,
          desc = 'Eval',
          mode = { 'n', 'v' },
        },
      },
      opts = {
        -- Set icons to characters that are more likely to work in every terminal.
        --    Feel free to remove or use ones that you like more! :)
        --    Don't feel like these are good choices.
        icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
        controls = {
          icons = {
            pause = '⏸',
            play = '▶',
            step_into = '⏎',
            step_over = '⏭',
            step_out = '⏮',
            step_back = 'b',
            run_last = '▶▶',
            terminate = '⏹',
            disconnect = '⏏',
          },
        },
      },
      config = function(_, opts)
        local dap = require 'dap'
        local dapui = require 'dapui'
        dapui.setup(opts)
        dap.listeners.after.event_initialized['dapui_config'] = function()
          dapui.open {}
        end
        dap.listeners.before.event_terminated['dapui_config'] = function()
          dapui.close {}
        end
        dap.listeners.before.event_exited['dapui_config'] = function()
          dapui.close {}
        end
      end,
    },
    -- Install the vscode-js-debug adapter
    {
      'microsoft/vscode-js-debug',
      -- After install, build it and rename the dist directory to out
      build = 'npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle && rm -rf out && mv dist out',
      version = '1.*',
    },
    {

      'mxsdev/nvim-dap-vscode-js',
      config = function()
        ---@diagnostic disable-next-line: missing-fields
        require('dap-vscode-js').setup {
          -- Path of node executable. Defaults to $NODE_PATH, and then "node"
          -- node_path = "node",

          -- Path to vscode-js-debug installation.
          debugger_path = vim.fn.resolve(vim.fn.stdpath 'data' .. '/lazy/vscode-js-debug'),

          -- Command to use to launch the debug server. Takes precedence over "node_path" and "debugger_path"
          -- debugger_cmd = { "js-debug-adapter" },

          -- which adapters to register in nvim-dap
          adapters = {
            'chrome',
            'pwa-node',
            'pwa-chrome',
            'pwa-msedge',
            'pwa-extensionHost',
            'node-terminal',
          },

          -- Path for file logging
          -- log_file_path = "(stdpath cache)/dap_vscode_js.log",

          -- Logging level for output to file. Set to false to disable logging.
          -- log_file_level = false,

          -- Logging level for output to console. Set to false to disable console output.
          -- log_console_level = vim.log.levels.ERROR,
        }
      end,
    },
    'nvim-neotest/nvim-nio',
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    'leoluz/nvim-dap-go',
    'mfussenegger/nvim-dap-python',
    'theHamsta/nvim-dap-virtual-text',
  },
}
