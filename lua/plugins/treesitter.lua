return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"lua",
				"python",
				"javascript",
				"typescript",
				"json",
				"yaml",
				"html",
				"css",
				"c",
				"cpp",
				"java",
				"markdown",
				"c_sharp",
				"apex",
				"sql",
			},
			highlight = { enable = true },
			indent = { enable = true },
			incremental_selection = { enable = true },
			autotag = { enable = true },
		})
	end,
}
