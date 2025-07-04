return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	config = function()
		require("conform").setup({
			format_on_save = {
				lsp_fallback = true,
				timeout_ms = 500,
			},
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "black" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				sh = { "shfmt" },
				c = { "clang_format" },
				cpp = { "clang_format" },
				java = { "google-java-format" },
			},
		})
	end,
}
