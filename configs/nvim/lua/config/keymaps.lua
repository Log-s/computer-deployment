-- Key mappings
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Window navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Window left", noremap = true, silent = true })
keymap("n", "<C-j>", "<C-w>j", { desc = "Window down", noremap = true, silent = true })
keymap("n", "<C-k>", "<C-w>k", { desc = "Window up", noremap = true, silent = true })
keymap("n", "<C-l>", "<C-w>l", { desc = "Window right", noremap = true, silent = true })

-- Diagnostic navigation
keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic", noremap = true, silent = true })
keymap("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic", noremap = true, silent = true })

-- File explorer (Neotree)
keymap("n", "<leader>n", function()
	local ok, neo_tree = pcall(require, "neo-tree.command")
	if ok then
		neo_tree.execute({ toggle = true })
	else
		vim.notify("Neo-tree not loaded", vim.log.levels.WARN)
	end
end, { desc = "Toggle Neotree", noremap = true, silent = true })

-- Toggle line numbers
keymap("n", "<leader>tn", function()
	vim.opt.number = not vim.opt.number:get()
end, { desc = "Toggle line numbers", noremap = true, silent = true })

-- Toggle relative line numbers
keymap("n", "<leader>tr", function()
	vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = "Toggle relative line numbers", noremap = true, silent = true })

-- Telescope (fuzzy finder)
keymap("n", "<leader>ff", function()
	require("telescope.builtin").find_files()
end, { desc = "Find files", noremap = true, silent = true })

keymap("n", "<leader>fg", function()
	require("telescope.builtin").live_grep()
end, { desc = "Live grep", noremap = true, silent = true })

keymap("n", "<leader>fb", function()
	require("telescope.builtin").buffers()
end, { desc = "Find buffers", noremap = true, silent = true })

keymap("n", "<leader>fh", function()
	require("telescope.builtin").help_tags()
end, { desc = "Find help", noremap = true, silent = true })

-- Window splitting
keymap("n", "<leader>wv", function()
	vim.cmd("vsplit")
end, { desc = "Split window vertically", noremap = true, silent = true })

keymap("n", "<leader>ws", function()
	vim.cmd("split")
end, { desc = "Split window horizontally", noremap = true, silent = true })

keymap("n", "<leader>wc", function()
	vim.cmd("close")
end, { desc = "Close window", noremap = true, silent = true })

-- Format code
keymap("n", "<leader>cf", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format code", noremap = true, silent = true })

-- LSP keymaps (set when LSP attaches to a buffer)
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local buf_opts = { buffer = ev.buf, noremap = true, silent = true }
		keymap("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", buf_opts, { desc = "Go to declaration" }))
		keymap("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", buf_opts, { desc = "Go to definition" }))
		keymap("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", buf_opts, { desc = "Hover documentation" }))
		keymap(
			"n",
			"gi",
			vim.lsp.buf.implementation,
			vim.tbl_extend("force", buf_opts, { desc = "Go to implementation" })
		)
		keymap("n", "<C-k>", vim.lsp.buf.signature_help, vim.tbl_extend("force", buf_opts, { desc = "Signature help" }))
		keymap(
			"n",
			"<leader>wa",
			vim.lsp.buf.add_workspace_folder,
			vim.tbl_extend("force", buf_opts, { desc = "Add workspace folder" })
		)
		keymap(
			"n",
			"<leader>wr",
			vim.lsp.buf.remove_workspace_folder,
			vim.tbl_extend("force", buf_opts, { desc = "Remove workspace folder" })
		)
		keymap("n", "<leader>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, vim.tbl_extend("force", buf_opts, { desc = "List workspace folders" }))
		keymap(
			"n",
			"<leader>D",
			vim.lsp.buf.type_definition,
			vim.tbl_extend("force", buf_opts, { desc = "Type definition" })
		)
		keymap("n", "<leader>cr", vim.lsp.buf.rename, vim.tbl_extend("force", buf_opts, { desc = "Rename symbol" }))
		keymap(
			{ "n", "v" },
			"<leader>ca",
			vim.lsp.buf.code_action,
			vim.tbl_extend("force", buf_opts, { desc = "Code action" })
		)
		keymap("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", buf_opts, { desc = "References" }))
	end,
})

-- Cursor AI keymaps
keymap("n", "<leader>ai", function()
	local ok, cursor = pcall(require, "neovim-cursor")
	if ok then
		cursor.toggle()
	else
		vim.notify("neovim-cursor not loaded", vim.log.levels.WARN)
	end
end, { desc = "Toggle agent window", noremap = true, silent = true })

keymap("n", "<leader>an", function()
	local ok, cursor = pcall(require, "neovim-cursor")
	if ok then
		cursor.new()
	else
		vim.notify("neovim-cursor not loaded", vim.log.levels.WARN)
	end
end, { desc = "New agent terminal", noremap = true, silent = true })

keymap("n", "<leader>at", function()
	local ok, cursor = pcall(require, "neovim-cursor")
	if ok then
		cursor.select()
	else
		vim.notify("neovim-cursor not loaded", vim.log.levels.WARN)
	end
end, { desc = "Select agent terminal", noremap = true, silent = true })

keymap("n", "<leader>ar", function()
	local ok, cursor = pcall(require, "neovim-cursor")
	if ok then
		cursor.rename()
	else
		vim.notify("neovim-cursor not loaded", vim.log.levels.WARN)
	end
end, { desc = "Rename agent terminal", noremap = true, silent = true })
