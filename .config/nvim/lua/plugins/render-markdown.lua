return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" }, -- if you use the mini.nvim suite
	-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
	-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
	---@module 'render-markdown'
	---@type render.md.UserConfig
	opts = {
		heading = {
			border = true,
			-- position = "inline",
			-- width = "block",
			-- min_width = 60,
			backgrounds = {
				"RenderMarkdownH2Bg",
				"RenderMarkdownH1Bg",
				"RenderMarkdownH3Bg",
				"RenderMarkdownH5Bg",
				"RenderMarkdownH4Bg",
				"RenderMarkdownH4Bg",
			},
			foregrounds = {
				"RenderMarkdownH2",
				"RenderMarkdownH1",
				"RenderMarkdownH3",
				"RenderMarkdownH5",
				"RenderMarkdownH4",
				"RenderMarkdownH4",
			},
		},
		indent = { enabled = true, skip_heading = true },
	},
}
