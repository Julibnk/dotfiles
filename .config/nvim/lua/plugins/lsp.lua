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

					map("gd", "<cmd>FzfLua lsp_definitions<CR>", "[G]oto [D]efinition")

					map("gD", "<cmd>FzfLua lsp_typedefs<CR>", "[G]oto type [D]efinition")

					map("gr", "<cmd>FzfLua lsp_references<CR>", "[G]oto [R]eferences")

					map("gI", "<cmd>FzfLua lsp_implementations<CR>", "[G]oto [R]eferences")

					map("<leader>ca", "<cmd>FzfLua lsp_code_actions<CR>", "[C]ode [A]ction", { "n", "x" })

					-- --  Useful when you're not sure what type a variable is and you want to see
					-- --  the definition of its *type*, not where it was *defined*.
					-- map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
					--
					-- -- Fuzzy find all the symbols in your current document.
					-- --  Symbols are tings like variables, functions, types, etc.
					-- map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
					--
					-- -- Fuzzy find all the symbols in your current workspace.
					-- --  Similar to document symbols, except searches over your entire project.
					map("<leader>ws", "<cmd>FzfLua lsp_workspace_symbols<CR>", "[W]orkspace [S]ymbols")

					map("<leader>K", vim.lsp.buf.hover, "Hover docs")
					--
					-- -- Rename the variable under your cursor.
					-- --  Most Language Servers support renaming across files, etc.
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					-- -- Execute a code action, usually your cursor needs to be on top of an error
					-- -- or a suggestion from your LSP for this to activate.
					-- map("<leader>ca", fzf_lua.lsp_code_actions, )
					--

					--
					-- -- WARN: This is not Goto Definition, this is Goto Declaration.
					-- --  For example, in C this would take you to the header.
					-- map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()

			capabilities =
				vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities({}, false))

			-- load Lsp configs
			local lsp_configs = {
				"angularls",
				"bashls",
				"composels",
				"clangd",
				"cssls",
				"dockerls",
				"lua_ls",
				"gopls",
				"basedpyright",
				"prisma-language-server",
				"tailwindls",
				"vstls",
			}

			-- for _, f in pairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
			-- 	local server_name = vim.fn.fnamemodify(f, ":t:r")
			-- 	table.insert(lsp_configs, server_name)
			-- end

			vim.lsp.enable(lsp_configs)
		end,
	},
	-- {
	-- 	"pmizio/typescript-tools.nvim",
	-- 	dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
	-- 	opts = {},
	-- },
}
