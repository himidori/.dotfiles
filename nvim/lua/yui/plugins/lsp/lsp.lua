return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"neovim/nvim-lspconfig",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		{ "j-hui/fidget.nvim", opts = {} },
		"ray-x/lsp_signature.nvim",
	},
	config = function()
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		mason.setup()
		mason_lspconfig.setup()

		local tool_installer = require("mason-tool-installer")

		local lspconfig = require("lspconfig")
		local cmp = require("cmp_nvim_lsp")
		local keymap = vim.keymap
		local builtin = require("telescope.builtin")

		local on_attach = function(_, bufnr)
			local map = function(keys, func, desc)
				keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc, noremap = true, silent = true })
			end

			map("gd", builtin.lsp_definitions, "[G]oto [D]efinitions")
			map("gr", builtin.lsp_references, "[G]oto [R]eferences")
			map("gi", builtin.lsp_implementations, "[G]oto [I]mplementations")
			map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
			map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
			map("<leader>D", builtin.lsp_type_definitions, "Type [D]efinition")
			map("<leader>ds", builtin.lsp_document_symbols, "[D]ocument [S]ymbols")
			map("<leader>ws", builtin.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
			map("K", vim.lsp.buf.hover, "Hover documentation")
			map("[d", vim.diagnostic.goto_prev, "")
			map("]d", vim.diagnostic.goto_next, "")
			map("<C-h>", vim.lsp.buf.signature_help, "")
			map("<C-space>", vim.lsp.buf.completion, "")

			require("lsp_signature").on_attach({}, bufnr)
		end

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = vim.tbl_deep_extend("force", capabilities, cmp.default_capabilities())

		local servers = {
			-- clangd = {},
			-- cssls = {},
			gopls = {
				settings = {
					gopls = {
						analyzes = {
							unusedparams = true,
						},
						staticcheck = true,
					},
				},
			},
			-- html = {},
			lua_ls = {
				Lua = {
					workspace = {
						checkThirdParty = false,
						library = {
							[vim.fn.expand("$VIMRUNTIME/lua")] = true,
							[vim.fn.stdpath("config") .. "/lua"] = true,
						},
					},
					telemetry = { enable = false },
					diagnostics = {
						globals = { "vim" },
					},
				},
			},
			-- rust_analyzer = {},
			-- tsserver = {},
			-- eslint = {},
			-- emmet_ls = {},
		}

		mason_lspconfig.setup({
			ensure_installed = vim.tbl_keys(servers),
		})

		tool_installer.setup({
			ensure_installed = {
				"stylua",
			},
		})

		mason_lspconfig.setup_handlers({
			function(server_name)
				lspconfig[server_name].setup({
					capabilities = capabilities,
					on_attach = on_attach,
					settings = servers[server_name],
					filetypes = (servers[server_name] or {}).filetypes,
				})
			end,
		})

		vim.api.nvim_create_augroup("GoImports", { clear = true })
		vim.api.nvim_create_autocmd({ "BufWritePre" }, {
			group = "GoImports",
			pattern = "*.go",
			callback = function()
				local params = vim.lsp.util.make_range_params()
				params.context = { only = { "source.organizeImports" } }
				local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
				for cid, res in pairs(result or {}) do
					for _, r in pairs(res.result or {}) do
						if r.edit then
							local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
							vim.lsp.util.apply_workspace_edit(r.edit, enc)
						end
					end
				end
				vim.lsp.buf.format({ async = false })
			end,
		})
	end,
}
