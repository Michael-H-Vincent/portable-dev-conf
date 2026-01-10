return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  config = function()
    vim.g.tmux_navigator_no_mappings = 1
    vim.keymap.set('n', '<M-h>', ':<C-U>TmuxNavigateLeft<CR>')
    vim.keymap.set('n', '<M-j>', ':<C-U>TmuxNavigateDown<CR>')
    vim.keymap.set('n', '<M-k>', ':<C-U>TmuxNavigateUp<CR>')
    vim.keymap.set('n', '<M-l>', ':<C-U>TmuxNavigateRight<CR>')
  end,
}
