-- Conform.nvim configuration (formatting with Black)
require("conform").setup({
  formatters_by_ft = {
    python = { "black" },
    lua = { "stylua" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
  formatters = {
    black = {
      prepend_args = { "--line-length", "88" },
    },
  },
})

