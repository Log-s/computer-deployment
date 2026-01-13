-- Treesitter configuration
local ok, configs = pcall(require, "nvim-treesitter.configs")
if not ok then
  vim.notify("nvim-treesitter.configs not found", vim.log.levels.WARN)
  return
end

configs.setup({
  ensure_installed = { "python", "lua", "vim", "vimdoc" },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
  },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
})

