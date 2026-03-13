-- LSP configuration
local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_nvim_lsp = require("cmp_nvim_lsp")
capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

-- Resolve path to absolute so Ruff never receives "file://./" (which it cannot convert).
-- root_dir can be called with a path string or a buffer number (e.g. from Neo-tree).
local function absolute_root(path)
	if type(path) == "number" then
		path = vim.api.nvim_buf_get_name(path)
	end
	if type(path) ~= "string" or path == "" or path == "." then
		return vim.fs.normalize(vim.fn.fnamemodify(vim.fn.getcwd(), ":p"))
	end
	local search_path = path
	local found = vim.fs.find({ "pyproject.toml", "ruff.toml", ".ruff.toml" }, { path = search_path, upward = true })[1]
	local root = found and vim.fs.dirname(found) or vim.fs.dirname(path) or vim.fn.getcwd()
	if root == "" or root == "." then
		root = vim.fn.getcwd()
	end
	return vim.fs.normalize(vim.fn.fnamemodify(root, ":p"))
end

-- Ruff LSP (lint/format) - use absolute root_dir to avoid "Failed to convert workspace URL: file://./"
vim.lsp.config("ruff", {
	capabilities = capabilities,
	root_dir = absolute_root,
})
vim.lsp.enable("ruff")

-- Python LSP (Pyright) - using new vim.lsp.config API (Neovim 0.11+)
vim.lsp.config("pyright", {
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
      },
    },
  },
})
vim.lsp.enable("pyright")

-- TypeScript/JavaScript LSP
vim.lsp.config("ts_ls", {
  capabilities = capabilities,
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
})
vim.lsp.enable("ts_ls")

-- Vue LSP (vue_ls)
vim.lsp.config("vue_ls", {
  capabilities = capabilities,
  filetypes = { "vue" },
  init_options = {
    vue = {
      hybridMode = false,
    },
  },
})
vim.lsp.enable("vue_ls")

-- Rust LSP (rust-analyzer)
vim.lsp.config("rust_analyzer", {
  capabilities = capabilities,
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = {
        command = "clippy",
      },
    },
  },
})
vim.lsp.enable("rust_analyzer")

-- LSP keymaps are defined in lua/config/keymaps.lua

-- Show diagnostics in a floating window
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})

