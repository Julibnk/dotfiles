-- Install with: @vtsls/language-server

local jsts_settings = {
	updateImportsOnFileMove = "always",
	suggest = { completeFunctionCalls = true },
	inlayHints = {
		parameterNames = { enabled = "literals" },
		parameterTypes = { enabled = true },
		variableTypes = { enabled = true },
		propertyDeclarationTypes = { enabled = true },
		functionLikeReturnTypes = { enabled = true },
		enumMemberValues = { enabled = true },
	},
	-- inlayHints = {
	--
	-- 	functionLikeReturnTypes = { enabled = true },
	-- 	parameterNames = { enabled = "literals" },
	-- 	variableTypes = { enabled = true },
	-- },
}

-- local function get_global_tsdk()
-- 	-- Use VS Code's bundled copy if available.
-- 	local vscode_tsdk_path = "/Applications/%s/Contents/Resources/app/extensions/node_modules/typescript/lib"
-- 	local vscode_tsdk = vscode_tsdk_path:format("Visual Studio Code.app")
-- 	local vscode_insiders_tsdk = vscode_tsdk_path:format("Visual Studio Code - Insiders.app")
--
-- 	if vim.fn.isdirectory(vscode_tsdk) == 1 then
-- 		return vscode_tsdk
-- 	elseif vim.fn.isdirectory(vscode_insiders_tsdk) == 1 then
-- 		return vscode_insiders_tsdk
-- 	else
-- 		return nil
-- 	end
-- end

---@module vim
---@type vim.lsp.Config
return {
	cmd = { "vtsls", "--stdio" },
	init_options = {
		hostInfo = "neovim",
	},
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},
	root_dir = function(bufnr, on_dir)
		-- The project root is where the LSP can be started from
		-- As stated in the documentation above, this LSP supports monorepos and simple projects.
		-- We select then from the project root, which is identified by the presence of a package
		-- manager lock file.
		local root_markers = { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock" }
		-- Give the root markers equal priority by wrapping them in a table
		root_markers = vim.fn.has("nvim-0.11.3") == 1 and { root_markers, { ".git" } }
			or vim.list_extend(root_markers, { ".git" })
		-- exclude deno
		local deno_root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc" })
		local deno_lock_root = vim.fs.root(bufnr, { "deno.lock" })
		local project_root = vim.fs.root(bufnr, root_markers)
		if deno_lock_root and (not project_root or #deno_lock_root > #project_root) then
			-- deno lock is closer than package manager lock, abort
			return
		end
		if deno_root and (not project_root or #deno_root >= #project_root) then
			-- deno config is closer than or equal to package manager lock, abort
			return
		end
		-- project is standard TS, not deno
		-- We fallback to the current working directory if no project root is found
		on_dir(project_root or vim.fn.getcwd())

		-- Old
		-- local fname = vim.uri_to_fname(vim.uri_from_bufnr(bufnr))
		--
		-- local ts_root = vim.fs.find("tsconfig.json", { upward = true, path = fname })[1]
		-- -- Use the git root to deal with monorepos where TypeScript is installed in the root node_modules folder.
		-- local git_root = vim.fs.find(".git", { upward = true, path = fname })[1]
		--
		-- if git_root then
		-- 	cb(vim.fn.fnamemodify(git_root, ":h"))
		-- elseif ts_root then
		-- 	cb(vim.fn.fnamemodify(ts_root, ":h"))
		-- end
	end,

	settings = {
		typescript = jsts_settings,
		javascript = jsts_settings,
		vtsls = {
			-- typescript = {
			-- 	globalTsdk = get_global_tsdk(),
			-- },
			-- Automatically use workspace version of TypeScript lib on startup.
			enableMoveToFileCodeAction = true,
			autoUseWorkspaceTsdk = true,
			experimental = {
				-- Inlay hint truncation.
				maxInlayHintLength = 30,
				-- For completion performance.
				completion = {
					enableServerSideFuzzyMatch = true,
				},
			},
		},
	},
}
