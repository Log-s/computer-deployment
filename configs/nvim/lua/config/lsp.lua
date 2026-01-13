-- LSP configuration
local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_nvim_lsp = require("cmp_nvim_lsp")
capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

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

-- LSP keymaps
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { desc = "Add workspace folder", buffer = ev.buf })
    vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { desc = "Remove workspace folder", buffer = ev.buf })
    vim.keymap.set("n", "<leader>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, { desc = "List workspace folders", buffer = ev.buf })
    vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, { desc = "Type definition", buffer = ev.buf })
    vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename symbol", buffer = ev.buf })
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action", buffer = ev.buf })
    vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "References", buffer = ev.buf })
  end,
})

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

