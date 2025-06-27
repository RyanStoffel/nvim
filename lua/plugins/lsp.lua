return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
	config = function()
		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = {
				"lua_ls", -- Lua
				"pyright", -- Python
				"ts_ls", -- JavaScript, TypeScript
				"clangd", -- C, C++
				"jdtls", -- Java
				"html", -- HTML
				"cssls", -- CSS
				"tailwindcss", -- Tailwind CSS
				"emmet_ls", -- Emmet (HTML, CSS, React, etc.)
				"jsonls", -- JSON
				"eslint", -- JavaScript/TypeScript linting
				"bashls", -- Bash
				"marksman", -- Markdown
				"omnisharp", -- C#
				"prismals", -- Prisma (for Next.js)
				"graphql", -- GraphQL (for Next.js)
			},
			automatic_installation = true,
		})

		local lspconfig = require("lspconfig")
		local servers = {
			"lua_ls",
			"pyright",
			"ts_ls",
			"clangd",
			"jdtls",
			"html",
			"cssls",
			"tailwindcss",
			"emmet_ls",
			"jsonls",
			"eslint",
			"bashls",
			"marksman",
			"omnisharp",
			"prismals",
			"graphql",
		}

		for _, server in ipairs(servers) do
			lspconfig[server].setup({})
		end
	end,
}
