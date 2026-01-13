require("neovim-cursor").setup({
  -- Multi-terminal keybindings (all configurable)
  keybindings = {
    toggle = "<leader>ai",      -- Toggle agent window (show last active)
    new = "<leader>an",          -- Create new agent terminal
    select = "<leader>at",       -- Select agent terminal (fuzzy picker)
    rename = "<leader>ar",       -- Rename current agent terminal
  },

  -- Terminal naming configuration
  terminal = {
    default_name = "Agent",      -- Default name prefix for terminals
    auto_number = true,          -- Auto-append numbers (Agent 1, Agent 2, etc.)
  },

  -- Terminal split configuration
  split = {
    position = "right",  -- "right", "left", "top", "bottom"
    size = 0.3,          -- 50% of editor width/height (0.0-1.0)
  },

  -- CLI command to run
  command = "cursor agent",

  -- Terminal callbacks (optional)
  term_opts = {
    on_open = function()
      -- Called when terminal opens
      print("Cursor agent started")
    end,
    on_close = function(exit_code)
      -- Called when terminal closes
      print("Cursor agent exited with code: " .. exit_code)
    end,
  },
})
