return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"neovim/nvim-lspconfig",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
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

		local on_attach = function(_, bufnr)
			local opts = { noremap = true, silent = true, buffer = bufnr }

			keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
			keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
			keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
			keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
			keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
			keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
			keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
			keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
			keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
			keymap.set("n", "K", vim.lsp.buf.hover, opts)
			keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
			keymap.set("n", "<leader>ds", "<cmd>Telescope lsp_document_symbols<CR>", opts)
			keymap.set("n", "<C-space>", vim.lsp.buf.completion, opts)
		end

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = cmp.default_capabilities(capabilities)

		local servers = {
			clangd = {},
			cssls = {},
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
			html = {},
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
			rust_analyzer = {},
			tsserver = {},
			eslint = {},
			emmet_ls = {},
		}

		mason_lspconfig.setup({
			ensure_installed = vim.tbl_keys(servers),
		})

		tool_installer.setup({
			ensure_installed = {
				"eslint_d",
				"clang-format",
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
				-- buf_request_sync defaults to a 1000ms timeout. Depending on your
				-- machine and codebase, you may want longer. Add an additional
				-- argument after params if you find that you have to write the file
				-- twice for changes to be saved.
				-- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
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
