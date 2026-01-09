
-- lua/keymaps.lua
-- Central place for custom keybindings

-- Shorten function call
local map = vim.keymap.set

-- Set leader key (if not already set in init.lua)
vim.g.mapleader = " "
vim.g.maplocalleader = " "


-- ==============================
-- General keymaps
-- ==============================

-- Save and quit
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })    -- Format is ( mode, binds, action, description )
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit window" })

-- Insert mode: typing "jj" quickly goes back to normal mode
map("i", "jj", "<Esc>", { desc = "Exit insert mode with jk" })
map("n", "<leader>n", "<cmd>bp<CR>", {desc = "Previous buffer"})
map("n", "<leader>m", "<cmd>bn<CR>", {desc = "Next buffer"})
map("n", "<leader>u", "<cmd>bd<CR>", {desc = "Close buffer"})
map("n", "<leader>e", vim.diagnostic.open_float, { noremap = true, silent = true, desc = "Show diagnostics in float" })

map("n", "<M-h>", "<cmd>wincmd h<CR>", {desc = "Focus on left window"})
map("n", "<M-j>", "<cmd>wincmd j<CR>", {desc = "Focus on down window"})
map("n", "<M-k>", "<cmd>wincmd k<CR>", {desc = "Focus on up window"})
map("n", "<M-l>", "<cmd>wincmd l<CR>", {desc = "Focus on right window"})
