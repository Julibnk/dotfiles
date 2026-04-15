return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"https://codeberg.org/mfussenegger/nluarepl",
			{
				"jbyuki/one-small-step-for-vimkind",
				keys = {
					{
						"<leader>dl",
						function()
							require("osv").launch({ port = 8086 })
						end,
					},
				},
			},
			{
				"igorlfs/nvim-dap-view",
				-- let the plugin lazy load itself
				lazy = false,
				version = "1.*",
				---@module 'dap-view'
				---@type dapview.Config
				opts = {
					virtual_text = {
						-- Control with `DapViewVirtualTextToggle`
						enabled = true,
						format = function(variable, _, _)
							-- Strip out excessive whitespace
							return " " .. variable.value:gsub("%s+", " ")
						end,
					},
					winbar = {
						sections = { "watches", "threads", "scopes", "exceptions", "breakpoints", "repl", "console" },
					},
					windows = {
						position = "below",
						size = 0.3,
					},
				},
			},
		},
		keys = function()
			local dap = require("dap")

			return {
				{
					"<F5>",
					function()
						dap.continue()
					end,
				},
				{
					"<F1>",
					function()
						dap.step_into()
					end,
				},
				{
					"<F2>",
					function()
						dap.step_over()
					end,
				},
				{
					"<F3>",
					function()
						dap.step_out()
					end,
				},

				{
					"<F4>",
					function()
						dap.run_to_cursor()
					end,
				},
				{
					"<leader>b",
					function()
						dap.toggle_breakpoint()
					end,
				},
				{
					"<leader>B",
					function()
						dap.set_breakpoint(vim.fn.input("Break condition: "))
					end,
				},
				{
					"<leader>db",
					function()
						dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
					end,
				},
				{
					"<leader>dr",
					function()
						dap.repl.open()
					end,
				},
				{
					"<leader>dh",
					function()
						require("dap.ui.widgets").hover()
					end,
				},
				{
					"<leader>dp",
					function()
						require("dap.ui.widgets").preview()
					end,
				},
				{
					"<leader>df",
					function()
						local widgets = require("dap.ui.widgets")
						widgets.centered_float(widgets.frames)
					end,
				},
				-- vim.keymap.set("n", "<Leader>dl", function()
				-- 	dap.run_last()
				-- end)
				-- vim.keymap.set("n", "<Leader>ds", function()
				-- 	local widgets = require("dap.ui.widgets")
				-- 	widgets.centered_float(widgets.scopes)
				-- end)
			}
		end,
		config = function()
			local masonPath = os.getenv("XDG_DATA_HOME") .. "/nvim/mason/packages"
			local delvePath = masonPath .. "/delve/dlv"
			local jsAdapterPath = masonPath .. "/js-debug-adapter/js-debug/src/dapDebugServer.js"
			local csAdapterPath = os.getenv("XDG_DATA_HOME") .. "/netcoredbg/netcoredbg"
			local dap = require("dap")
			local dv = require("dap-view")

			-- Automatically open the UI when a new debug session is created.
			dap.listeners.before.attach["dap-view-config"] = function()
				dv.open()
			end
			dap.listeners.before.launch["dap-view-config"] = function()
				dv.open()
			end
			dap.listeners.before.event_terminated["dap-view-config"] = function()
				dv.close()
			end
			dap.listeners.before.event_exited["dap-view-config"] = function()
				dv.close()
			end

			dap.adapters = vim.tbl_extend("force", dap.adapters, {
				-- Lua
				nlua = function(callback, config)
					callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
				end,

				-- Node
				["pwa-node"] = function(callback, config)
					if config.mode == "remote" and config.request == "attach" then
						callback({
							type = "server",
							host = config.host or "127.0.0.1",
							port = config.port or "9229",
						})
					else
						callback({
							type = "server",
							host = "localhost",
							port = "${port}",
							executable = {
								command = "tsx",
								args = { jsAdapterPath, "${port}" },
							},
						})
					end
				end,

				-- GO
				delve = function(callback, config)
					if config.mode == "remote" and config.request == "attach" then
						callback({
							type = "server",
							host = config.host or "127.0.0.1",
							port = config.port or "38697",
						})
					else
						callback({
							type = "server",
							port = "${port}",
							executable = {
								command = "dlv",
								args = { "dap", "-l", "127.0.0.1:${port}", "--log", "--log-output=dap" },
								detached = vim.fn.has("win32") == 0,
							},
						})
					end
				end,
				coreclr = {
					type = "executable",
					command = csAdapterPath,
					args = { "--interpreter=vscode" },
				},
			})

			local nodeConfig = {
				{
					type = "pwa-node",
					request = "launch",
					name = "Node launch file",
					program = "${file}",
					cwd = "${workspaceFolder}",
				},
				{
					type = "pwa-node",
					request = "attach",
					name = "Attach node",
				},
			}

			dap.configurations = vim.tbl_extend("force", dap.configurations, {
				javascript = nodeConfig,
				typescript = nodeConfig,
				go = {
					{
						type = "delve",
						name = "Debug",
						request = "launch",
						program = "${file}",
						dlvToolPath = delvePath,
					},
					{
						type = "delve",
						name = "Debug test", -- configuration for debugging test files
						request = "launch",
						mode = "test",
						program = "${file}",
						dlvToolPath = delvePath,
					},
					{
						type = "delve",
						name = "Debug test (go.mod)",
						request = "launch",
						mode = "test",
						program = "./${relativeFileDirname}",
						dlvToolPath = delvePath,
					},
				},
				lua = {
					{
						type = "nlua",
						request = "attach",
						name = "Nvim instance",
					},
				},
				cs = {
					{
						type = "coreclr",
						name = "launch - netcoredbg",
						request = "launch",
						program = function()
							return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/bin/Debug/", "file")
						end,
					},
				},
			})
		end,
	},
}
