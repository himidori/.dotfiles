return {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	dependencies = {
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-nvim-lsp",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
		"rafamadriz/friendly-snippets",
		"Snikimonkd/cmp-go-pkgs",
	},
	config = function()
		local cmp = require("cmp")
		local snip = require("luasnip")
		local types = require("cmp.types")

		require("luasnip.loaders.from_vscode").lazy_load()

		cmp.setup({
			completion = {
				completeopt = "menu,menuone,noselect",
			},
			snippet = {
				expand = function(args)
					snip.lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-k>"] = cmp.mapping.select_prev_item(),
				["<C-j>"] = cmp.mapping.select_next_item(),
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"] = cmp.mapping.abort(),
				["<TAB>"] = cmp.mapping.confirm(),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
				{ name = "buffer" },
				{ name = "path" },
				{ name = "go_pkgs" },
			}),
			sorting = {
				comparators = {
					cmp.config.compare.offset,
					cmp.config.compare.exact,
					cmp.config.compare.score,
					function(entry1, entry2)
						local kind1 = entry1:get_kind()
						kind1 = kind1 == types.lsp.CompletionItemKind.Text and 100 or kind1
						local kind2 = entry2:get_kind()
						kind2 = kind2 == types.lsp.CompletionItemKind.Text and 100 or kind2
						if kind1 ~= kind2 then
							if kind1 == types.lsp.CompletionItemKind.Snippet then
								return false
							end
							if kind2 == types.lsp.CompletionItemKind.Snippet then
								return true
							end
							local diff = kind1 - kind2
							if diff < 0 then
								return true
							elseif diff > 0 then
								return false
							end
						end
					end,
					cmp.config.compare.sort_text,
					cmp.config.compare.length,
					cmp.config.compare.order,
				},
			},
		})
	end,
}
