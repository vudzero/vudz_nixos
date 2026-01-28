-- Main Lua entry point
-- This file orchestrates loading all configuration modules

-- Load vudz configuration first (sets leader key and basic settings)
require("vudz")

-- Load lazy.nvim plugin manager (needs leader key to be set)
require("plugins")
