-- NOTE: Right now i dont need nvim-lspconfig because the options are written under lsp folder
return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"saghen/blink.cmp",
			"ibhagwan/fzf-lua",
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(event)
					-- Jump to the definition of the word under your cursor.
					--  This is where a variable was first declared, or where a function is defined, etc.
					--  To jump back, press <C-t>
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					local fzf = require("fzf-lua")

					map("gd", function()
						fzf.lsp_definitions({ jump1 = true })
					end, "[G]oto [D]efinition")

					map("gt", function()
						fzf.lsp_typedefs()
					end, "[G]oto [t]ype definition")

					map("gD", function()
						fzf.lsp_declarations()
					end, "[G]oto [D]efinition")

					map("gr", function()
						fzf.lsp_references({ ignore_current_line = true })
					end, "[G]oto [R]eferences")

					map("gi", function()
						fzf.lsp_implementations()
					end, "[G]oto [R]eferences")

					map("<leader>ca", function()
						fzf.lsp_code_actions()
					end, "[C]ode [A]ction", { "n", "x" })

					map("<leader>ws", function()
						fzf.lsp_workspace_symbols()
					end, "[W]orkspace [S]ymbols")

					map("<leader>K", vim.lsp.buf.hover, "Hover docs")

					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()

			capabilities =
				vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities({}, false))

			-- load Lsp configs
			local lsp_configs = {
				-- "angularls",
				"astrols",
				"bashls",
				"composels",
				"clangd",
				"cssls",
				-- "css-modules",
				"dockerls",
				"lua_ls",
				"gopls",
				"basedpyright",
				"prisma-language-server",
				"tailwindls",
				"vstls",
				"phpactor",
			}

			-- for _, f in pairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
			-- 	local server_name = vim.fn.fnamemodify(f, ":t:r")
			-- 	table.insert(lsp_configs, server_name)
			-- end

			vim.lsp.enable(lsp_configs)
		end,
	},
}
